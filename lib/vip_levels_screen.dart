import 'package:flutter/material.dart';

import 'premium_theme.dart';

class VipLevelsScreen extends StatefulWidget {
  final int currentCoins;

  const VipLevelsScreen({
    super.key,
    this.currentCoins = 0,
  });

  @override
  State<VipLevelsScreen> createState() => _VipLevelsScreenState();
}

class _VipLevelsScreenState extends State<VipLevelsScreen> {
  static const Color gold = PremiumTheme.gold;
  static const Color brightGold = PremiumTheme.brightGold;
  static const Color lightGold = PremiumTheme.lightGold;
  static const Color purple = PremiumTheme.purple;
  static const Color deepPurple = PremiumTheme.deepPurple;
  static const Color darkPurple = PremiumTheme.darkPurple;
  static const Color background = PremiumTheme.background;
  static const Color surface = PremiumTheme.surface;
  static const Color surface2 = PremiumTheme.surface2;

  int selectedVip = 0;

  final List<_VipLevel> levels = const [
    _VipLevel(
      level: 1,
      requiredCoins: 1000,
      icon: Icons.star_rounded,
      benefits: [
        'VIP badge',
        'Special profile frame',
        'VIP entrance effect',
      ],
    ),
    _VipLevel(
      level: 2,
      requiredCoins: 5000,
      icon: Icons.star_rounded,
      benefits: [
        'VIP 2 badge',
        'Premium profile frame',
        'Special entrance effect',
      ],
    ),
    _VipLevel(
      level: 3,
      requiredCoins: 10000,
      icon: Icons.auto_awesome_rounded,
      benefits: [
        'VIP 3 badge',
        'Premium room effects',
        'Exclusive VIP styling',
      ],
    ),
    _VipLevel(
      level: 4,
      requiredCoins: 20000,
      icon: Icons.auto_awesome_rounded,
      benefits: [
        'VIP 4 badge',
        'Special room entrance',
        'Premium effects',
      ],
    ),
    _VipLevel(
      level: 5,
      requiredCoins: 50000,
      icon: Icons.workspace_premium_rounded,
      benefits: [
        'VIP 5 badge',
        'Premium profile decoration',
        'Special VIP effects',
      ],
    ),
    _VipLevel(
      level: 6,
      requiredCoins: 100000,
      icon: Icons.workspace_premium_rounded,
      benefits: [
        'VIP 6 badge',
        'Advanced VIP styling',
        'Exclusive entrance effect',
      ],
    ),
    _VipLevel(
      level: 7,
      requiredCoins: 200000,
      icon: Icons.diamond_rounded,
      benefits: [
        'VIP 7 badge',
        'Luxury profile frame',
        'Premium room effects',
      ],
    ),
    _VipLevel(
      level: 8,
      requiredCoins: 500000,
      icon: Icons.diamond_rounded,
      benefits: [
        'VIP 8 badge',
        'Luxury entrance effect',
        'Exclusive VIP design',
      ],
    ),
    _VipLevel(
      level: 9,
      requiredCoins: 1000000,
      icon: Icons.diamond_rounded,
      benefits: [
        'VIP 9 badge',
        'Elite profile frame',
        'Elite room effects',
      ],
    ),
    _VipLevel(
      level: 10,
      requiredCoins: 2000000,
      icon: Icons.emoji_events_rounded,
      benefits: [
        'VIP 10 badge',
        'Ultimate VIP frame',
        'Ultimate entrance effect',
      ],
    ),
  ];

  int get currentVip {
    int result = 0;

    for (final level in levels) {
      if (widget.currentCoins >= level.requiredCoins) {
        result = level.level;
      }
    }

    return result;
  }

  _VipLevel get selectedLevel => levels[selectedVip];

  bool isUnlocked(_VipLevel level) {
    return widget.currentCoins >= level.requiredCoins;
  }

  String formatCoins(int value) {
    if (value >= 1000000) {
      final millions = value / 1000000;

      return '${millions.toStringAsFixed(
        millions == millions.roundToDouble() ? 0 : 1,
      )}M';
    }

    if (value >= 1000) {
      final thousands = value / 1000;

      return '${thousands.toStringAsFixed(
        thousands == thousands.roundToDouble() ? 0 : 1,
      )}K';
    }

    return value.toString();
  }

  String formatFullCoins(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(
        value % 1000000 == 0 ? 0 : 1,
      )}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(
        value % 1000 == 0 ? 0 : 1,
      )}K';
    }

    return value.toString();
  }

  double progressFor(_VipLevel level) {
    if (widget.currentCoins >= level.requiredCoins) {
      return 1;
    }

    final previousRequirement =
        level.level == 1
            ? 0
            : levels[level.level - 2].requiredCoins;

    final range =
        level.requiredCoins - previousRequirement;

    if (range <= 0) {
      return 0;
    }

    final value =
        widget.currentCoins - previousRequirement;

    return (value / range).clamp(0.0, 1.0);
  }

  int coinsRemaining(_VipLevel level) {
    final remaining =
        level.requiredCoins - widget.currentCoins;

    return remaining > 0 ? remaining : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'VIP Center',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: gold,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: gold,
            ),
            onPressed: _showVipInfo,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.premiumBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              35,
            ),
            child: Column(
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 18),
                _buildCoinCard(),
                const SizedBox(height: 18),
                _buildCurrentVipCard(),
                const SizedBox(height: 20),
                _buildTabs(),
                const SizedBox(height: 18),
                _buildVipList(),
                const SizedBox(height: 20),
                _buildSelectedBenefits(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF21002F),
            Color(0xFF4A148C),
            Color(0xFF7B1FA2),
            Color(0xFF21002F),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: gold.withValues(alpha: 0.50),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: PremiumTheme.goldGradient,
              border: Border.all(
                color: lightGold,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF5A2C00),
              size: 49,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'VIP',
            style: TextStyle(
              color: gold,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'More Benefits, More Respect!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentVip == 0
                ? 'Start your VIP journey'
                : 'Current VIP Level $currentVip',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surface2,
            surface,
          ],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: PremiumTheme.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.25),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFF633700),
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Coins',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCoins(widget.currentCoins),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              gradient: PremiumTheme.purpleGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: gold.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              currentVip == 0
                  ? 'VIP 0'
                  : 'VIP $currentVip',
              style: const TextStyle(
                color: gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentVipCard() {
    final nextIndex = currentVip;

    final nextLevel =
        nextIndex < levels.length
            ? levels[nextIndex]
            : null;

    if (nextLevel == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: PremiumTheme.goldGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.25),
              blurRadius: 14,
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFF5A2C00),
              size: 35,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Congratulations! VIP 10 achieved.',
                style: TextStyle(
                  color: Color(0xFF3E2200),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final progress = progressFor(nextLevel);
    final remaining = coinsRemaining(nextLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: purple.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.purpleGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.40),
                  ),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentVip == 0
                          ? 'Next: VIP ${nextLevel.level}'
                          : 'Next Level: VIP ${nextLevel.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$remaining coins remaining',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                gold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatFullCoins(widget.currentCoins)} / ${formatFullCoins(nextLevel.requiredCoins)} coins',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: PremiumTheme.purpleGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: gold.withValues(alpha: 0.30),
                ),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'VIP Levels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _showVipInfo,
              child: const Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: gold,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Benefits',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipList() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                gradient: PremiumTheme.goldGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'VIP Levels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '10 Levels',
              style: TextStyle(
                color: gold.withValues(alpha: 0.80),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...List.generate(
          levels.length,
          (index) => _buildVipTile(
            levels[index],
            index,
          ),
        ),
      ],
    );
  }

  Widget _buildVipTile(
    _VipLevel level,
    int index,
  ) {
    final unlocked = isUnlocked(level);
    final selected = selectedVip == index;
    final progress = progressFor(level);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVip = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF32104F),
                    Color(0xFF21102F),
                  ],
                )
              : const LinearGradient(
                  colors: [
                    surface2,
                    surface,
                  ],
                ),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected
                ? gold.withValues(alpha: 0.70)
                : gold.withValues(alpha: 0.16),
            width: selected ? 1.3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: purple.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: unlocked
                        ? PremiumTheme.goldGradient
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha: 0.12,
                              ),
                              Colors.white.withValues(
                                alpha: 0.04,
                              ),
                            ],
                          ),
                    border: Border.all(
                      color: unlocked
                          ? lightGold.withValues(
                              alpha: 0.70,
                            )
                          : Colors.white12,
                    ),
                  ),
                  child: Icon(
                    level.icon,
                    color: unlocked
                        ? const Color(0xFF633700)
                        : Colors.white38,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'VIP ${level.level}',
                            style: TextStyle(
                              color: unlocked
                                  ? gold
                                  : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 7),
                          if (unlocked)
                            const Icon(
                              Icons.verified_rounded,
                              color: gold,
                              size: 17,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: gold,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${formatFullCoins(level.requiredCoins)} coins',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? gold.withValues(alpha: 0.14)
                        : Colors.white.withValues(
                            alpha: 0.06,
                          ),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: unlocked
                          ? gold.withValues(alpha: 0.35)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        unlocked
                            ? Icons.lock_open_rounded
                            : Icons.lock_rounded,
                        color: unlocked
                            ? gold
                            : Colors.white38,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unlocked
                            ? 'Unlocked'
                            : 'Locked',
                        style: TextStyle(
                          color: unlocked
                              ? gold
                              : Colors.white54,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          Colors.white10,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        unlocked ? gold : purple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 12),
              PremiumTheme.divider(),
              const SizedBox(height: 11),
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: gold,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Tap to view VIP benefits',
                    style: TextStyle(
                      color: lightGold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: gold,
                    size: 20,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBenefits() {
    final level = selectedLevel;
    final unlocked = isUnlocked(level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF32104F),
            Color(0xFF160C22),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: gold.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.goldGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  level.icon,
                  color: const Color(0xFF633700),
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP ${level.level} Benefits',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unlocked
                          ? 'Benefits unlocked'
                          : 'Benefits available after unlocking',
                      style: TextStyle(
                        color: unlocked
                            ? gold
                            : Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                unlocked
                    ? Icons.check_circle_rounded
                    : Icons.lock_outline_rounded,
                color: unlocked
                    ? gold
                    : Colors.white38,
                size: 23,
              ),
            ],
          ),
          const SizedBox(height: 17),
          ...List.generate(
            level.benefits.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: purple.withValues(
                          alpha: 0.30,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: gold,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        level.benefits[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.16,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: gold,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    unlocked
                        ? 'VIP ${level.level} requirement completed'
                        : '${formatFullCoins(coinsRemaining(level))} more coins needed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVipInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: gold,
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'VIP Information',
                style: TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'VIP Levels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mchat VIP has 10 levels. Each level requires the specified number of coins.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'VIP benefits may include badges, profile frames, entrance effects and other premium styling.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'VIP status is based on the available coin value supplied to this screen.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VipLevel {
  final int level;
  final int requiredCoins;
  final IconData icon;
  final List<String> benefits;

  const _VipLevel({
    required this.level,
    required this.requiredCoins,
    required this.icon,
    required this.benefits,
  });
}
