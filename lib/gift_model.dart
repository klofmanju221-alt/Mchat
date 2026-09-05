class GiftModel {
  final String id;
  final String name;
  final String emoji;
  final int coinCost;
  final bool enabled;

  const GiftModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.coinCost,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'coinCost': coinCost,
      'enabled': enabled,
    };
  }

  factory GiftModel.fromMap(Map<String, dynamic> map) {
    return GiftModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '🎁',
      coinCost: (map['coinCost'] as num?)?.toInt() ?? 0,
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
