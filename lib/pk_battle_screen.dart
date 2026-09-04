import 'dart:async';

import 'package:flutter/material.dart';

class PkBattleScreen extends StatefulWidget {
  const PkBattleScreen({
    super.key,
    this.playerAName = 'Player A',
    this.playerBName = 'Player B',
    this.playerAId = '10000001',
    this.playerBId = '10000002',
  });

  final String playerAName;
  final String playerBName;
  final String playerAId;
  final String playerBId;

  @override
  State<PkBattleScreen> createState() => _PkBattleScreenState();
}

class _PkBattleScreenState extends State<PkBattleScreen> {
  static const Color background = Color(0xFF12091D);
  static const Color card = Color(0xFF21112F);
  static const Color purple = Color(0xFF8B35E8);
  static const Color pink = Color(0xFFE83E9E);
  static const Color gold = Color(0xFFFFC83D);

  Timer? _timer;

  int seconds = 60;
  int playerACoins = 1250;
  int playerBCoins = 980;

  double playerAProgress = 0.56;
  double playerBProgress = 0.44;

  bool muted = false;
  bool liked = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get timeText {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title UI ready'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendGift() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        final gifts = [
          ('🌹', 'Rose', '10'),
          ('❤️', 'Heart', '49'),
          ('🍭', 'Lollipop', '99'),
          ('☕', 'Coffee', '199'),
          ('🧸', 'Teddy', '299'),
          ('💎', 'Diamond', '499'),
          ('🚗', 'Car', '999'),
          ('🏰', 'Castle', '1999'),
          ('🦁', 'Lion', '2999'),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Send Gift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gifts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final gift = gifts[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pop(context);
                        _showComingSoon(
                          '${gift.$2} gift',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.07),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(.08),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              gift.$1,
                              style: const TextStyle(
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gift.$2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${gift.$3} coins',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _playerAvatar({
    required String name,
    required bool first,
  }) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: first
                  ? [
                      purple,
                      pink,
                    ]
                  : [
                      pink,
                      gold,
                    ],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3A2347),
            ),
            child: const Icon(
              Icons.person,
              size: 52,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _scorePanel({
    required bool first,
    required int coins,
    required double progress,
  }) {
    return Column(
      children: [
        Text(
          '$coins',
          style: const TextStyle(
            color: gold,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            alignment: first
                ? Alignment.centerLeft
                : Alignment.centerRight,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: first
                      ? [
                          purple,
                          pink,
                        ]
                      : [
                          pink,
                          gold,
                        ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _battleTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PK Battle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mchat PK Arena',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _roundIcon(
            icon: Icons.more_vert,
            onTap: () => _showComingSoon('More options'),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _vsBadge() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            purple,
            pink,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(.35),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _battleArea() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        22,
        16,
        20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            purple.withOpacity(.28),
            pink.withOpacity(.16),
            card,
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _playerAvatar(
                  name: widget.playerAName,
                  first: true,
                ),
              ),
              _vsBadge(),
              Expanded(
                child: _playerAvatar(
                  name: widget.playerBName,
                  first: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'ID: ${widget.playerAId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 64),
              Expanded(
                child: Text(
                  'ID: ${widget.playerBId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _scorePanel(
                  first: true,
                  coins: playerACoins,
                  progress: playerAProgress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _scorePanel(
                  first: false,
                  coins: playerBCoins,
                  progress: playerBProgress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.30),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  timeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: active
                ? purple.withOpacity(.22)
                : Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? purple.withOpacity(.55)
                  : Colors.white.withOpacity(.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? pink : Colors.white,
                size: 25,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Row(
        children: [
          _actionButton(
            icon: muted
                ? Icons.volume_off
                : Icons.volume_up,
            label: 'Sound',
            active: muted,
            onTap: () {
              setState(() {
                muted = !muted;
              });
            },
          ),
          const SizedBox(width: 8),
          _actionButton(
            icon: liked
                ? Icons.favorite
                : Icons.favorite_border,
            label: 'Like',
            active: liked,
            onTap: () {
              setState(() {
                liked = !liked;
              });
            },
          ),
          const SizedBox(width: 8),
          _actionButton(
            icon: Icons.card_giftcard,
            label: 'Gift',
            onTap: _sendGift,
          ),
          const SizedBox(width: 8),
          _actionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            onTap: () => _showComingSoon('PK Chat'),
          ),
        ],
      ),
    );
  }

  Widget _giftAndChatPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: gold,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PK Battle Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${playerACoins + playerBCoins} coins',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Support your favourite player with gifts and likes!',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sendGift,
                  icon: const Icon(
                    Icons.card_giftcard,
                  ),
                  label: const Text('Send Gift'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: purple.withOpacity(.7),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showComingSoon('Recharge'),
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text('Recharge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.35),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(.06),
          ),
        ),
      ),
      child: Row(
        children: [
          _roundIcon(
            icon: Icons.emoji_emotions_outlined,
            onTap: () =>
                _showComingSoon('Emoji'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Text(
                'Say something...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _roundIcon(
            icon: Icons.send_rounded,
            onTap: () =>
                _showComingSoon('Send message'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _battleTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: gold.withOpacity(.20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            color: gold,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'PK Battle',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _battleArea(),
                    const SizedBox(height: 12),
                    _quickActions(),
                    _giftAndChatPanel(),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }
}
