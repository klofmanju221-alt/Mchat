class WalletLedgerEntry {
  final String id;
  final String userId;
  final int coins;
  final String type;
  final String status;
  final DateTime createdAt;

  const WalletLedgerEntry({
    required this.id,
    required this.userId,
    required this.coins,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}

class OwnerWithdrawal {
  final String id;
  final String ownerId;
  final int amountMinor;
  final String currency;
  final String status;

  const OwnerWithdrawal({
    required this.id,
    required this.ownerId,
    required this.amountMinor,
    required this.currency,
    required this.status,
  });
}
