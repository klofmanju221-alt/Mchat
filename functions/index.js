const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

const REFERRAL_REWARD = 1000;

const REFERRAL_PENDING = "pending";
const REFERRAL_COMPLETED = "completed";
const REFERRAL_REJECTED = "rejected";

/*
 * STEP 1
 *
 * When a new user document is created, only mark the referral
 * as pending.
 *
 * IMPORTANT:
 * No coins are awarded here.
 */
exports.processReferralReward = onDocumentCreated(
  "users/{newUserUid}",
  async (event) => {
    const newUserUid = event.params.newUserUid;
    const newUserSnapshot = event.data;

    if (!newUserSnapshot) {
      return;
    }

    const newUser = newUserSnapshot.data() || {};

    const referredByUid = newUser.referredByUid;
    const referredByCode = newUser.referredByCode;

    if (!referredByUid || !referredByCode) {
      return;
    }

    if (referredByUid === newUserUid) {
      await newUserSnapshot.ref.set(
        {
          referralStatus: REFERRAL_REJECTED,
          referralRejectedReason: "self_referral",
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return;
    }

    const referrerRef = db
      .collection("users")
      .doc(referredByUid);

    const referralRef = newUserSnapshot.ref
      .collection("referrals")
      .doc(referredByUid);

    const referrerSnapshot = await referrerRef.get();

    if (!referrerSnapshot.exists) {
      await newUserSnapshot.ref.set(
        {
          referralStatus: REFERRAL_REJECTED,
          referralRejectedReason: "referrer_not_found",
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return;
    }

    const referrer = referrerSnapshot.data() || {};

    if (referrer.referralCode !== referredByCode) {
      await newUserSnapshot.ref.set(
        {
          referralStatus: REFERRAL_REJECTED,
          referralRejectedReason: "invalid_referral_code",
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return;
    }

    await newUserSnapshot.ref.set(
      {
        referralStatus: REFERRAL_PENDING,
        referralUpdatedAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    await referralRef.set(
      {
        referredUid: newUserUid,
        referredByUid: referredByUid,
        referralCode: referredByCode,
        rewardCoins: REFERRAL_REWARD,
        status: REFERRAL_PENDING,
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  },
);


/*
 * STEP 2
 *
 * Secure backend reward claim.
 *
 * The user must be authenticated.
 * The backend checks Firebase Authentication directly.
 *
 * The client NEVER writes coins directly.
 */
exports.claimReferralReward = onCall(
  {
    // App Check will be enforced before production launch
    // after App Check is configured in the Mchat app.
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in.",
      );
    }

    const newUserUid = request.auth.uid;

    const newUserRef = db
      .collection("users")
      .doc(newUserUid);

    const newUserSnapshot = await newUserRef.get();

    if (!newUserSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Mchat user profile was not found.",
      );
    }

    const newUser = newUserSnapshot.data() || {};

    const referredByUid = newUser.referredByUid;
    const referredByCode = newUser.referredByCode;

    if (!referredByUid || !referredByCode) {
      return {
        success: false,
        status: "no_referral",
        message: "No referral is attached to this account.",
      };
    }

    if (referredByUid === newUserUid) {
      await newUserRef.set(
        {
          referralStatus: REFERRAL_REJECTED,
          referralRejectedReason: "self_referral",
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      throw new HttpsError(
        "invalid-argument",
        "Self referral is not allowed.",
      );
    }

    /*
     * IMPORTANT:
     * Read the real Firebase Authentication user.
     *
     * Do not trust an emailVerified field coming from Firestore.
     */
    const authUser = await auth.getUser(newUserUid);

    if (!authUser.emailVerified) {
      return {
        success: false,
        status: REFERRAL_PENDING,
        message:
          "Email verification is required before the referral reward can be completed.",
      };
    }

    const referrerRef = db
      .collection("users")
      .doc(referredByUid);

    const walletRef = db
      .collection("wallets")
      .doc(referredByUid);

    const referralRef = newUserRef
      .collection("referrals")
      .doc(referredByUid);

    const ledgerRef = db
      .collection("ledger")
      .doc();

    const auditRef = db
      .collection("audit_logs")
      .doc();

    await db.runTransaction(async (transaction) => {
      const referrerSnapshot =
        await transaction.get(referrerRef);

      const newUserSnapshotTx =
        await transaction.get(newUserRef);

      const walletSnapshot =
        await transaction.get(walletRef);

      const referralSnapshot =
        await transaction.get(referralRef);

      if (!referrerSnapshot.exists) {
        transaction.set(
          newUserRef,
          {
            referralStatus: REFERRAL_REJECTED,
            referralRejectedReason: "referrer_not_found",
            referralUpdatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        return;
      }

      const referrer =
        referrerSnapshot.data() || {};

      const newUserData =
        newUserSnapshotTx.data() || {};

      /*
       * Verify that the referral code still belongs
       * to the claimed referrer.
       */
      if (referrer.referralCode !== referredByCode) {
        transaction.set(
          newUserRef,
          {
            referralStatus: REFERRAL_REJECTED,
            referralRejectedReason:
              "invalid_referral_code",
            referralUpdatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        return;
      }

      /*
       * Idempotency protection.
       *
       * If the referral is already completed,
       * never give another 1000 coins.
       */
      if (
        newUserData.referralStatus ===
        REFERRAL_COMPLETED
      ) {
        return;
      }

      if (
        referralSnapshot.exists &&
        referralSnapshot.data().status ===
          REFERRAL_COMPLETED
      ) {
        transaction.set(
          newUserRef,
          {
            referralStatus: REFERRAL_COMPLETED,
            referralRewardCoins: REFERRAL_REWARD,
            referralUpdatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        return;
      }

      let currentCoins = 0;

      if (walletSnapshot.exists) {
        const wallet =
          walletSnapshot.data() || {};

        currentCoins =
          Number.isInteger(wallet.coins)
            ? wallet.coins
            : 0;
      }

      const newBalance =
        currentCoins + REFERRAL_REWARD;

      /*
       * SECURE WALLET UPDATE
       *
       * Firestore client rules must keep wallet writes disabled.
       */
      transaction.set(
        walletRef,
        {
          coins: newBalance,
          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      const currentReferralCount =
        Number.isInteger(
          referrer.successfulReferrals,
        )
          ? referrer.successfulReferrals
          : 0;

      const currentReferralCoins =
        Number.isInteger(
          referrer.referralCoins,
        )
          ? referrer.referralCoins
          : 0;

      transaction.set(
        referrerRef,
        {
          successfulReferrals:
            currentReferralCount + 1,
          referralCoins:
            currentReferralCoins +
            REFERRAL_REWARD,
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      /*
       * Referral history
       */
      transaction.set(
        referralRef,
        {
          referredUid: newUserUid,
          referredByUid: referredByUid,
          referralCode: referredByCode,
          rewardCoins: REFERRAL_REWARD,
          status: REFERRAL_COMPLETED,
          createdAt:
            referralSnapshot.exists
              ? (
                  referralSnapshot.data().createdAt ||
                  admin.firestore.FieldValue.serverTimestamp()
                )
              : admin.firestore.FieldValue.serverTimestamp(),
          completedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      /*
       * Mark referral completed.
       */
      transaction.set(
        newUserRef,
        {
          referralStatus: REFERRAL_COMPLETED,
          referralRewardCoins: REFERRAL_REWARD,
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      /*
       * Immutable financial ledger.
       */
      transaction.set(ledgerRef, {
        type: "referral_reward",
        uid: referredByUid,
        sourceUid: newUserUid,
        amount: REFERRAL_REWARD,
        currency: "coins",
        description:
          "Successful referral reward",
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });

      /*
       * Security audit log.
       */
      transaction.set(auditRef, {
        action:
          "referral_reward_completed",
        referrerUid: referredByUid,
        referredUid: newUserUid,
        rewardCoins: REFERRAL_REWARD,
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return {
      success: true,
      status: REFERRAL_COMPLETED,
      rewardCoins: REFERRAL_REWARD,
      message:
        "Referral reward completed successfully.",
    };
  },
);
