import 'package:flutter/material.dart';

class VipLevelsScreen extends StatefulWidget {
  const VipLevelsScreen({super.key});

  @override
  State<VipLevelsScreen> createState() => _VipLevelsScreenState();
}

class _VipLevelsScreenState extends State<VipLevelsScreen> {
  static const Color purple = Color(0xFF7B2CBF);
  static const Color deepPurple = Color(0xFF3A176B);
  static const Color pink = Color(0xFFE83E8C);
  static const Color gold = Color(0xFFFFC107);
  static const Color background = Color(0xFFF8F5FC);

  int selectedVip = 5;

  final List<Map<String, dynamic>> vipLevels = [
    {
      'level': 1,
      'coins': 1000,
      'benefits': [
        'VIP badge',
        'VIP profile frame',
        'Special entrance effect',
      ],
    },
    {
      'level': 2,
      'coins': 5000,
      'benefits': [
        'VIP 2 badge',
        'Premium profile frame',
        'Special chat badge',
      ],
    },
    {
      'level': 3,
      'coins': 10000,
      'benefits': [
        'VIP 3 badge',
        'Premium room effects',
        'Exclusive emojis',
      ],
    },
    {
      'level': 4,
      'coins': 20000,
      'benefits': [
        'VIP 4 badge',
        'Advanced profile frame',
        'Special entrance effect',
      ],
    },
    {
      'level': 5,
      'coins': 50000,
      'benefits': [
        'VIP 5 badge',
        'Premium entrance effect',
        'Exclusive VIP gifts',
      ],
    },
    {
      'level': 6,
      'coins': 100000,
      'benefits': [
        'VIP 6 badge',
        'Luxury profile frame',
        'Premium room effects',
      ],
    },
    {
      'level': 7,
      'coins': 200000,
      'benefits': [
        'VIP 7 badge',
        'Luxury entrance effect',
        'Exclusive VIP privileges',
      ],
    },
    {
      'level': 8,
      'coins': 500000,
      'benefits': [
        'VIP 8 badge',
        'Royal profile frame',
        'Premium room privileges',
      ],
    },
    {
      'level': 9,
      'coins': 1000000,
      'benefits': [
        'VIP 9 badge',
        'Royal entrance effect',
        'Luxury VIP privileges',
      ],
    },
    {
      'level': 10,
      'coins': 2000000,
      'benefits': [
        'VIP 10 badge',
        'Ultimate royal frame',
        'Exclusive VIP privileges',
      ],
    },
  ];

  int get currentVip {
    return 1;
  }

  String formatCoins(int coins) {
    if (coins >= 1000000) {
      final value = coins / 1000000;
      return value % 1 == 0
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1)}M';
    }

    if (coins >= 1000) {
      final value = coins / 1000;
      return value % 1 == 0
          ? '${value.toInt()}K'
          : '${value.toStringAsFixed(1)}K';
    }

    return coins.toString();
  }

  String fullCoins(int coins) {
    return coins.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final selected = vipLevels[selectedVip - 1];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'VIP Center',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showVipHelp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 18),
            _buildCurrentVipCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'VIP Levels',
              'Choose a level to view benefits',
            ),
            const SizedBox(height: 14),
            _buildVipSelector(),
            const SizedBox(height: 22),
            _buildSelectedVipCard(selected),
            const SizedBox(height: 22),
            _buildBenefits(selected),
            const SizedBox(height: 22),
            _buildVipRules(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(selected),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            deepPurple,
            purple,
            pink,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 105,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gold.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'VIP Makes You Special',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Unlock exclusive badges, frames,\neffects and VIP privileges.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentVipCard() {
    final level = currentVip;
    final current = vipLevels[level - 1];

    final next = level < 10
        ? vipLevels[level]
        : null;

    final currentCoins = current['coins'] as int;
    final nextCoins = next?['coins'] as int?;

    double progress = 1;

    if (nextCoins != null) {
      progress = currentCoins / nextCoins;

      if (progress > 1) {
        progress = 1;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withValues(alpha: 0.12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _vipCircle(
                level,
                size: 62,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Current Level',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'VIP $level',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: purple,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: gold,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatCoins(currentCoins)} Coins',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (nextCoins != null)
                Text(
                  'Next: ${formatCoins(nextCoins)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildVipSelector() {
    return SizedBox(
      height: 91,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vipLevels.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final level = index + 1;
          final selected = selectedVip == level;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedVip = level;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              width: 75,
              padding:
                  const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? purple
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? purple
                      : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: purple.withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: selected
                        ? gold
                        : Colors.grey.shade500,
                    size: 28,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'VIP $level',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedVipCard(
    Map<String, dynamic> selected,
  ) {
    final level = selected['level'] as int;
    final coins = selected['coins'] as int;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E164E),
            Color(0xFF6D28A8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _vipCircle(
            level,
            size: 78,
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'VIP $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Required Coins',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fullCoins(coins),
                  style: const TextStyle(
                    color: gold,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
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
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              level <= currentVip
                  ? 'UNLOCKED'
                  : 'LOCKED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(
    Map<String, dynamic> selected,
  ) {
    final level = selected['level'] as int;
    final benefits =
        selected['benefits'] as List<String>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                color: purple,
              ),
              const SizedBox(width: 9),
              Text(
                'VIP $level Benefits',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...benefits.map(
            (benefit) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 13),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6FA),
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipRules() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: purple,
              ),
              SizedBox(width: 9),
              Text(
                'VIP Information',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'VIP levels are based on the required coin threshold. '
            'VIP benefits will be connected to the real account '
            'and backend system later.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    Map<String, dynamic> selected,
  ) {
    final level = selected['level'] as int;
    final coins = selected['coins'] as int;

    return SafeArea(
      minimum:
          const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (level <= currentVip) {
                _showMessage(
                  'VIP $level is already unlocked.',
                );
              } else {
                _showMessage(
                  'VIP $level requires ${fullCoins(coins)} coins.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: gold,
                ),
                const SizedBox(width: 8),
                Text(
                  level <= currentVip
                      ? 'VIP $level Unlocked'
                      : 'Unlock VIP $level',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vipCircle(
    int level, {
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD54F),
            Color(0xFFFFA000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.28),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 25,
          ),
          Text(
            '$level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showVipHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'About VIP',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mchat VIP has 10 levels. Each level has a '
                'different required coin threshold and '
                'exclusive benefits.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 50),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
