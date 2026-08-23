/// Production rules used by the app architecture.
///
/// IMPORTANT:
/// - Never trust a client-calculated wallet balance.
/// - Coins are created only after a server-verified payment webhook.
/// - Gifts debit the sender and credit the recipient through an atomic server transaction.
/// - Owner commission is calculated server-side.
/// - Withdrawals are created server-side and paid only by a verified payout provider.
/// - Flutter never stores payment secrets, payout secrets, Firebase Admin credentials,
///   or owner passwords.
class ProductionRules {
  static const ownerEmail = 'klofmanju221@gmail.com';

  static const requiredCollections = [
    'users',
    'wallets',
    'ledger',
    'rooms',
    'room_members',
    'gifts',
    'recharges',
    'withdrawals',
    'owner_commissions',
    'reports',
    'audit_logs',
  ];

  static const requiredServerFunctions = [
    'createPaymentOrder',
    'verifyPaymentWebhook',
    'creditCoinsAfterVerifiedPayment',
    'sendGiftAtomic',
    'calculateOwnerCommission',
    'requestOwnerWithdrawal',
    'processVerifiedPayout',
    'refundRecharge',
    'banUser',
  ];
}
