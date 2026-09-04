import 'package:flutter/material.dart';

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
  static const Color bg = Color(0xFF100819);
  static const Color card = Color(0xFF21132F);
  static const Color purple = Color(0xFF8B3DFF);
  static const Color pink = Color(0xFFFF3FA4);
  static const Color gold = Color(0xFFFFD76A);

  int selectedVip = 0;

  final List<_VipLevel> levels = const [
    _VipLevel(
      level: 1,
      requiredCoins: 1000,
      icon: Icons.star,
      benefits: [
        'VIP badge',
        'Special profile frame',
        'VIP entrance effect',
      ],
    ),
    _VipLevel(
      level: 2,
      requiredCoins: 5000,
      icon: Icons.star,
      benefits: [
        'VIP 2 badge',
        'Premium profile frame',
        'Special entrance effect',
      ],
    ),
    _VipLevel(
      level: 3,
      requiredCoins: 10000,
      icon: Icons.auto_awesome,
      benefits: [
        'VIP 3 badge',
        'Premium room effects',
        'Exclusive VIP styling',
      ],
    ),
    _VipLevel(
      level: 4,
      requiredCoins: 20000,
      icon: Icons.auto_awesome,
      benefits: [
        'VIP 4 badge',
        'Special room entrance',
        'Premium effects',
      ],
    ),
    _VipLevel(
      level: 5,
      requiredCoins: 50000,
      icon: Icons.workspace_premium,
      benefits: [
        'VIP 5 badge',
        'Premium profile decoration',
        'Special VIP effects',
      ],
    ),
    _VipLevel(
      level: 6,
      requiredCoins: 100000,
      icon: Icons.workspace_premium,
      benefits: [
        'VIP 6 badge',
        'Advanced VIP styling',
        'Exclusive entrance effect',
      ],
    ),
    _VipLevel(
      level: 7,
      requiredCoins: 200000,
      icon: Icons.diamond,
      benefits: [
        'VIP 7 badge',
        'Luxury profile frame',
        'Premium room effects',
      ],
    ),
    _VipLevel(
      level: 8,
      requiredCoins: 500000,
      icon: Icons.diamond,
      benefits: [
        'VIP 8 badge',
        'Luxury entrance effect',
        'Exclusive VIP design',
      ],
    ),
    _VipLevel(
      level: 9,
      requiredCoins: 1000000,
      icon: Icons.diamond,
      benefits: [
        'VIP 9 badge',
        'Elite profile frame',
        'Elite room effects',
      ],
    ),
    _VipLevel(
      level: 10,
      requiredCoins: 2000000,
      icon: Icons.emoji_events,
      benefits: [
        'VIP 10 badge',
        'Ultimate VIP frame',
        'Ultimate entrance effect',
      ],
    ),
  ];

  int get currentVip {
    int result = 0;

    for (final vip in levels) {
      if (widget.currentCoins >= vip.requiredCoins) {
        result = vip.level;
      }
    }

    return result;
  }

  _VipLevel get selectedLevel => levels[selectedVip];

  String formatCoins(int value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return '${millions.toStringAsFixed(millions == millions.roundToDouble() ? 0 : 1)}M';
    }

    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(thousands == thousands.roundToDouble() ? 0 : 1)}K';
    }

    return value.toString();
  }

  String formatFullCoins(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }

    return value.toString();
  }

  double progressFor(_VipLevel vip) {
    if (widget.currentCoins >= vip.requiredCoins) {
      return 1;
    }

    final previousRequirement =
        vip.level == 1 ? 0 : levels[vip.level - 2].requiredCoins;

    final range = vip.requiredCoins - previousRequirement;

    if (range <= 0) {
      return 0;
    }

    final value = widget.currentCoins - previousRequirement;

    return (value / range).clamp(0.0, 1.0);
  }

  bool isUnlocked(_VipLevel vip) {
    return widget.currentCoins >= vip.requiredCoins;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'VIP Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white70,
            ),
            onPressed: () {
              _showVipInfo();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 18),
              _buildCoinCard(),
              const SizedBox(height: 20),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildVipList(),
              const SizedBox(height: 20),
              _buildSelectedBenefits(),
            ],
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
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D155C),
            Color(0xFF7B238F),
            Color(0xFF30104A),
          ],
        ),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF0A8),
                  Color(0xFFFFC83D),
                  Color(0xFFFF8A00),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFF5A2C00),
              size: 46,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'VIP',
            style: TextStyle(
              color: gold,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'More Benefits, More Respect!',
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD85C),
                  Color(0xFFFF9D00),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.25),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Color(0xFF6A3900),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 24,
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
              color: purple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: purple.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              currentVip == 0 ? 'VIP 0' : 'VIP $currentVip',
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    purple,
                    pink,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'VIP Levels',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                _showVipInfo();
              },
              child: const Center(
                child: Text(
                  'Benefits',
                  style: TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
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
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'VIP Levels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          levels.length,
          (index) => _buildVipTile(levels[index], index),
        ),
      ],
    );
  }

  Widget _buildVipTile(_VipLevel vip, int index) {
    final unlocked = isUnlocked(vip);
    final selected = selectedVip == index;

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
          color: selected
              ? const Color(0xFF2C173E)
              : card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? gold.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.07),
            width: selected ? 1.3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.18),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: unlocked
                          ? const [
                              Color(0xFFFFE78A),
                              Color(0xFFFFA600),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                    ),
                  ),
                  child: Icon(
                    vip.icon,
                    color: unlocked
                        ? const Color(0xFF633700)
                        : Colors.white38,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'VIP ${vip.level}',
                            style: TextStyle(
                              color: unlocked ? gold : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (unlocked) ...[
                            const SizedBox(width: 7),
                            const Icon(
                              Icons.verified,
                              color: gold,
                              size: 17,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFFC83D),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${formatFullCoins(vip.requiredCoins)} Coins',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? const Color(0xFF4D2E08)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unlocked ? 'UNLOCKED' : 'LOCKED',
                    style: TextStyle(
                      color: unlocked ? gold : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: progressFor(vip),
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.08),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          pink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progressFor(vip) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
    final vip = selectedLevel;
    final unlocked = isUnlocked(vip);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gold.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFE58A),
                      Color(0xFFFFA500),
                    ],
                  ),
                ),
                child: Icon(
                  vip.icon,
                  color: const Color(0xFF633700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP ${vip.level} Benefits',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatFullCoins(vip.requiredCoins)} Coins required',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...vip.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: gold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                _showVipAction(vip);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: unlocked ? Colors.white10 : purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Text(
                unlocked
                    ? 'VIP ${vip.level} Active'
                    : 'View VIP ${vip.level}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVipAction(_VipLevel vip) {
    final unlocked = isUnlocked(vip);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0D24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Icon(
                  vip.icon,
                  color: gold,
                  size: 55,
                ),
                const SizedBox(height: 12),
                Text(
                  'VIP ${vip.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  unlocked
                      ? 'Your VIP level is active.'
                      : '${formatFullCoins(vip.requiredCoins)} Coins required',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                if (!unlocked)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Recharge through the Coins screen to increase your VIP level.',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Recharge Coins',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVipInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF21132F),
          title: const Text(
            'VIP Center',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'VIP level is based on your eligible coin requirement. '
            'Higher VIP levels unlock more premium status and UI benefits.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: gold),
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
