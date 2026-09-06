const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

const REFERRAL_REWARD = 1000;
const REFERRAL_PENDING = "pending";
const REFERRAL_COMPLETED = "completed";
const REFERRAL_REJECTED = "rejected";

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

    // Self-referral protection.
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

    const referralRef = newUserSnapshot.ref.collection("referrals")
      .doc(referredByUid);

    const referrerRef = db.collection("users").doc(referredByUid);
    const newUserRef = db.collection("users").doc(newUserUid);
    const walletRef = db.collection("wallets").doc(referredByUid);

    await db.runTransaction(async (transaction) => {
      const referrerSnapshot = await transaction.get(referrerRef);
      const newUserSnapshotTx = await transaction.get(newUserRef);
      const walletSnapshot = await transaction.get(walletRef);
      const referralSnapshot = await transaction.get(referralRef);

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

      const referrer = referrerSnapshot.data() || {};
      const newUserData = newUserSnapshotTx.data() || {};

      // Referral code must belong to the referrer.
      if (referrer.referralCode !== referredByCode) {
        transaction.set(
          newUserRef,
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

      // Never reward an already completed referral.
      if (newUserData.referralStatus === REFERRAL_COMPLETED) {
        return;
      }

      // Duplicate protection.
      if (referralSnapshot.exists &&
          referralSnapshot.data().status === REFERRAL_COMPLETED) {
        transaction.set(
          newUserRef,
          {
            referralStatus: REFERRAL_COMPLETED,
            referralUpdatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        return;
      }

      let currentCoins = 0;

      if (walletSnapshot.exists) {
        const wallet = walletSnapshot.data() || {};
        currentCoins =
          Number.isInteger(wallet.coins) ? wallet.coins : 0;
      }

      const newBalance = currentCoins + REFERRAL_REWARD;

      // Secure wallet update. Client Firestore rules must keep
      // wallet writes disabled.
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
        Number.isInteger(referrer.successfulReferrals)
          ? referrer.successfulReferrals
          : 0;

      const currentReferralCoins =
        Number.isInteger(referrer.referralCoins)
          ? referrer.referralCoins
          : 0;

      transaction.set(
        referrerRef,
        {
          successfulReferrals: currentReferralCount + 1,
          referralCoins:
            currentReferralCoins + REFERRAL_REWARD,
          referralUpdatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      // Referral history.
      transaction.set(
        referralRef,
        {
          referredUid: newUserUid,
          referredByUid: referredByUid,
          referralCode: referredByCode,
          rewardCoins: REFERRAL_REWARD,
          status: REFERRAL_COMPLETED,
          createdAt:
            admin.firestore.FieldValue.serverTimestamp(),
          completedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      // Mark new user referral as completed.
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

      // Immutable financial ledger record.
      const ledgerRef = db.collection("ledger").doc();

      transaction.set(ledgerRef, {
        type: "referral_reward",
        uid: referredByUid,
        sourceUid: newUserUid,
        amount: REFERRAL_REWARD,
        currency: "coins",
        description: "Successful referral reward",
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });

      // Audit log.
      const auditRef = db.collection("audit_logs").doc();

      transaction.set(auditRef, {
        action: "referral_reward_completed",
        referrerUid: referredByUid,
        referredUid: newUserUid,
        rewardCoins: REFERRAL_REWARD,
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
      });
    });
  },
);
