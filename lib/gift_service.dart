import 'gift_model.dart';

class GiftService {
  GiftService._();

  static final GiftService instance = GiftService._();

  /// Default gift catalog.
  ///
  /// This catalog is only UI/data configuration.
  /// Coins must NOT be deducted on the client.
  static const List<GiftModel> defaultGifts = [
    GiftModel(
      id: 'rose',
      name: 'Rose',
      emoji: '🌹',
      coinCost: 10,
    ),
    GiftModel(
      id: 'heart',
      name: 'Heart',
      emoji: '❤️',
      coinCost: 50,
    ),
    GiftModel(
      id: 'love',
      name: 'Love',
      emoji: '💖',
      coinCost: 100,
    ),
    GiftModel(
      id: 'star',
      name: 'Star',
      emoji: '⭐',
      coinCost: 500,
    ),
    GiftModel(
      id: 'crown',
      name: 'Crown',
      emoji: '👑',
      coinCost: 1000,
    ),
    GiftModel(
      id: 'diamond',
      name: 'Diamond',
      emoji: '💎',
      coinCost: 5000,
    ),
    GiftModel(
      id: 'car',
      name: 'Luxury Car',
      emoji: '🚗',
      coinCost: 10000,
    ),
    GiftModel(
      id: 'rocket',
      name: 'Rocket',
      emoji: '🚀',
      coinCost: 25000,
    ),
  ];

  List<GiftModel> getGifts() {
    return List<GiftModel>.unmodifiable(defaultGifts);
  }

  GiftModel? getGiftById(String id) {
    for (final gift in defaultGifts) {
      if (gift.id == id) {
        return gift;
      }
    }

    return null;
  }

  /// IMPORTANT:
  /// Do not deduct coins or write financial ledger data here.
  ///
  /// The actual gift transaction must later be performed by
  /// a trusted backend using an atomic transaction.
  Future<void> sendGift({
    required String receiverUid,
    required GiftModel gift,
  }) async {
    if (receiverUid.trim().isEmpty) {
      throw ArgumentError('Receiver UID is required.');
    }

    if (!gift.enabled) {
      throw StateError('This gift is currently unavailable.');
    }

    throw StateError(
      'Secure gift transaction backend is not connected yet.',
    );
  }
}
