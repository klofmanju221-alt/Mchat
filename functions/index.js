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

// ===============================================================
// MCHAT REFERRAL SETTINGS
// ===============================================================

const REFERRAL_REWARD = 1000;

const REFERRAL_PENDING = "pending";
const REFERRAL_COMPLETED = "completed";
const REFERRAL_REJECTED = "rejected";

// ===============================================================
// SECURE REFERRAL REWARD
// ===============================================================
//
// IMPORTANT:
//
// Flutter NEVER adds referral coins directly.
//
// Only this backend function can award the 1000 Coins.
//
// Security checks:
//
// 1. User must be authenticated
// 2. Firebase email must be verified
// 3. Referral must exist
// 4. Referrer must exist
// 5. Referral code must match
// 6. Self referral is blocked
// 7. Duplicate reward is blocked
// 8. Wallet update happens inside Firestore transaction
// 9. Referral history is stored under referrer's account
// 10. Ledger + audit log are created
//
// ===============================================================

exports.claimReferralReward = onCall(
  {
    // App Check will be enforced before production launch
    // after App Check is configured in the Flutter app.
    enforceAppCheck: false,
  },

  async (request) => {
    // =============================================================
    // 1. AUTHENTICATION CHECK
    // =============================================================

    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in.",
      );
    }

    const newUserUid = request.auth.uid;

    // =============================================================
    // 2. GET NEW USER PROFILE
    // =============================================================

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

    const newUser =
        newUserSnapshot.data() || {};

    // =============================================================
    // 3. GET REFERRAL INFORMATION
    // =============================================================

    const referredByUid =
        String(newUser.referredByUid || "").trim();

    const referredByCode =
        String(newUser.referredByCode || "")
            .trim()
            .toUpperCase();

    // No referral attached
    if (
      referredByUid.isEmpty ||
      referredByCode.isEmpty
    ) {
      return {
        success: false,
        status: "no_referral",
        rewardCoins: 0,
        message:
            "No referral is attached to this account.",
      };
    }

    // =============================================================
    // 4. SELF REFERRAL PROTECTION
    // =============================================================

    if (referredByUid === newUserUid) {
      await newUserRef.set(
        {
          referralStatus:
              REFERRAL_REJECTED,

          referralRejectedReason:
              "self_referral",

          referralUpdatedAt:
              admin.firestore.FieldValue
                  .serverTimestamp(),
        },
        { merge: true },
      );

      return {
        success: false,
        status: REFERRAL_REJECTED,
        rewardCoins: 0,
        message:
            "Self referral is not allowed.",
      };
    }

    // =============================================================
    // 5. FIREBASE AUTH EMAIL VERIFICATION
    // =============================================================

    // IMPORTANT:
    // Never trust emailVerified from Firestore.
    //
    // Read the real Firebase Authentication account.

    let authUser;

    try {
      authUser =
          await auth.getUser(newUserUid);
    } catch (error) {
      throw new HttpsError(
        "not-found",
        "Firebase user account was not found.",
      );
    }

    if (!authUser.emailVerified) {
      return {
        success: false,
        status: REFERRAL_PENDING,
        rewardCoins: 0,
        message:
            "Email verification is required before the referral reward can be completed.",
      };
    }

    // =============================================================
    // 6. REFERRER REFERENCES
    // =============================================================

    const referrerRef = db
        .collection("users")
        .doc(referredByUid);

    // IMPORTANT:
    // WalletService uses "coinBalance".
    //
    // Therefore backend must update "coinBalance",
    // NOT "coins".

    const walletRef = db
        .collection("wallets")
        .doc(referredByUid);

    // IMPORTANT:
    // Referral history belongs to the REFERRER.
    //
    // users/{referrerUid}/referrals/{newUserUid}

    const referralRef = referrerRef
        .collection("referrals")
        .doc(newUserUid);

    // Fixed IDs are created before transaction.
    // This keeps the transaction idempotent.

    const ledgerRef = db
        .collection("ledger")
        .doc();

    const auditRef = db
        .collection("audit_logs")
        .doc();

    // =============================================================
    // 7. TRANSACTION
    // =============================================================

    let resultStatus = REFERRAL_PENDING;
    let resultMessage =
        "Referral verification is pending.";
    let rewardGiven = 0;

    await db.runTransaction(
      async (transaction) => {
        // ---------------------------------------------------------
        // READ ALL REQUIRED DOCUMENTS
        // ---------------------------------------------------------

        const referrerSnapshot =
            await transaction.get(referrerRef);

        const currentUserSnapshot =
            await transaction.get(newUserRef);

        const walletSnapshot =
            await transaction.get(walletRef);

        const referralSnapshot =
            await transaction.get(referralRef);

        // ---------------------------------------------------------
        // REFERRER NOT FOUND
        // ---------------------------------------------------------

        if (!referrerSnapshot.exists) {
          transaction.set(
            newUserRef,
            {
              referralStatus:
                  REFERRAL_REJECTED,

              referralRejectedReason:
                  "referrer_not_found",

              referralUpdatedAt:
                  admin.firestore.FieldValue
                      .serverTimestamp(),
            },
            { merge: true },
          );

          resultStatus =
              REFERRAL_REJECTED;

          resultMessage =
              "Referrer account was not found.";

          rewardGiven = 0;

          return;
        }

        // ---------------------------------------------------------
        // GET REFERRER DATA
        // ---------------------------------------------------------

        const referrer =
            referrerSnapshot.data() || {};

        const currentUser =
            currentUserSnapshot.data() || {};

        // ---------------------------------------------------------
        // VERIFY REFERRAL CODE
        // ---------------------------------------------------------

        const realReferralCode =
            String(
              referrer.referralCode || "",
            )
                .trim()
                .toUpperCase();

        if (
          realReferralCode !==
          referredByCode
        ) {
          transaction.set(
            newUserRef,
            {
              referralStatus:
                  REFERRAL_REJECTED,

              referralRejectedReason:
                  "invalid_referral_code",

              referralUpdatedAt:
                  admin.firestore.FieldValue
                      .serverTimestamp(),
            },
            { merge: true },
          );

          resultStatus =
              REFERRAL_REJECTED;

          resultMessage =
              "Invalid referral code.";

          rewardGiven = 0;

          return;
        }

        // ---------------------------------------------------------
        // DUPLICATE PROTECTION - USER STATUS
        // ---------------------------------------------------------

        if (
          currentUser.referralStatus ===
          REFERRAL_COMPLETED
        ) {
          resultStatus =
              "already_completed";

          resultMessage =
              "Referral reward has already been completed.";

          rewardGiven = 0;

          return;
        }

        // ---------------------------------------------------------
        // DUPLICATE PROTECTION - HISTORY
        // ---------------------------------------------------------

        if (referralSnapshot.exists) {
          const referralData =
              referralSnapshot.data() || {};

          if (
            referralData.status ===
            REFERRAL_COMPLETED
          ) {
            transaction.set(
              newUserRef,
              {
                referralStatus:
                    REFERRAL_COMPLETED,

                referralRewardCoins:
                    REFERRAL_REWARD,

                referralUpdatedAt:
                    admin.firestore.FieldValue
                        .serverTimestamp(),
              },
              { merge: true },
            );

            resultStatus =
                "already_completed";

            resultMessage =
                "Referral reward has already been completed.";

            rewardGiven = 0;

            return;
          }
        }

        // ---------------------------------------------------------
        // CURRENT WALLET BALANCE
        // ---------------------------------------------------------

        let currentCoinBalance = 0;

        if (walletSnapshot.exists) {
          const wallet =
              walletSnapshot.data() || {};

          const balance =
              wallet.coinBalance;

          if (typeof balance === "number" &&
              Number.isFinite(balance)) {
            currentCoinBalance =
                Math.max(
                  0,
                  Math.floor(balance),
                );
          }
        }

        const newCoinBalance =
            currentCoinBalance +
            REFERRAL_REWARD;

        // ---------------------------------------------------------
        // REFERRAL COUNTS
        // ---------------------------------------------------------

        let currentReferralCount = 0;

        const referralCount =
            referrer.successfulReferrals;

        if (
          typeof referralCount === "number" &&
          Number.isFinite(referralCount)
        ) {
          currentReferralCount =
              Math.max(
                0,
                Math.floor(referralCount),
              );
        }

        let currentReferralCoins = 0;

        const referralCoins =
            referrer.referralCoins;

        if (
          typeof referralCoins === "number" &&
          Number.isFinite(referralCoins)
        ) {
          currentReferralCoins =
              Math.max(
                0,
                Math.floor(referralCoins),
              );
        }

        // ---------------------------------------------------------
        // UPDATE REFERRER WALLET
        // ---------------------------------------------------------

        transaction.set(
          walletRef,
          {
            coinBalance:
                newCoinBalance,

            updatedAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
          { merge: true },
        );

        // ---------------------------------------------------------
        // UPDATE REFERRER PROFILE
        // ---------------------------------------------------------

        transaction.set(
          referrerRef,
          {
            successfulReferrals:
                currentReferralCount + 1,

            referralCoins:
                currentReferralCoins +
                REFERRAL_REWARD,

            referralUpdatedAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
          { merge: true },
        );

        // ---------------------------------------------------------
        // CREATE REFERRAL HISTORY
        // ---------------------------------------------------------

        transaction.set(
          referralRef,
          {
            referredUid:
                newUserUid,

            referredByUid:
                referredByUid,

            referralCode:
                referredByCode,

            rewardCoins:
                REFERRAL_REWARD,

            status:
                REFERRAL_COMPLETED,

            createdAt:
                referralSnapshot.exists
                    ? (
                        referralSnapshot
                                .data()
                                ?.createdAt ??
                        admin.firestore.FieldValue
                            .serverTimestamp()
                      )
                    : admin.firestore.FieldValue
                        .serverTimestamp(),

            completedAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
          { merge: true },
        );

        // ---------------------------------------------------------
        // MARK NEW USER REFERRAL COMPLETED
        // ---------------------------------------------------------

        transaction.set(
          newUserRef,
          {
            referralStatus:
                REFERRAL_COMPLETED,

            referralRewardCoins:
                REFERRAL_REWARD,

            referralUpdatedAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
          { merge: true },
        );

        // ---------------------------------------------------------
        // FINANCIAL LEDGER
        // ---------------------------------------------------------

        transaction.set(
          ledgerRef,
          {
            type:
                "referral_reward",

            uid:
                referredByUid,

            sourceUid:
                newUserUid,

            amount:
                REFERRAL_REWARD,

            currency:
                "coins",

            description:
                "Successful referral reward",

            createdAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
        );

        // ---------------------------------------------------------
        // SECURITY AUDIT LOG
        // ---------------------------------------------------------

        transaction.set(
          auditRef,
          {
            action:
                "referral_reward_completed",

            referrerUid:
                referredByUid,

            referredUid:
                newUserUid,

            rewardCoins:
                REFERRAL_REWARD,

            createdAt:
                admin.firestore.FieldValue
                    .serverTimestamp(),
          },
        );

        // ---------------------------------------------------------
        // SUCCESS
        // ---------------------------------------------------------

        resultStatus =
            REFERRAL_COMPLETED;

        resultMessage =
            "Referral reward completed successfully.";

        rewardGiven =
            REFERRAL_REWARD;
      },
    );

    // =============================================================
    // RETURN RESULT
    // =============================================================

    return {
      success:
          resultStatus ===
          REFERRAL_COMPLETED,

      status:
          resultStatus,

      rewardCoins:
          rewardGiven,

      message:
          resultMessage,
    };
  },
);
