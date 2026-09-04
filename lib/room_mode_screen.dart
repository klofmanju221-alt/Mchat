import 'package:flutter/material.dart';

class RoomModeScreen extends StatefulWidget {
  const RoomModeScreen({super.key});

  @override
  State<RoomModeScreen> createState() => _RoomModeScreenState();
}

class _RoomModeScreenState extends State<RoomModeScreen> {
  static const Color bg = Color(0xFF15131A);
  static const Color card = Color(0xFF211E27);
  static const Color purple = Color(0xFF8A35E8);
  static const Color pink = Color(0xFFE83B91);
  static const Color gold = Color(0xFFFFC83D);

  final List<_GameItem> roomGames = const [
    _GameItem('Truth & Dare', Icons.local_drink, Color(0xFF9C4DFF)),
    _GameItem('Undercover', Icons.visibility, Color(0xFFFFA62B)),
    _GameItem('Dominoes', Icons.grid_4x4, Color(0xFF16B979)),
    _GameItem('Draw & Guess', Icons.brush, Color(0xFF16C7B7)),
    _GameItem('Ludo', Icons.casino, Color(0xFF3478F6)),
    _GameItem('Blind Date', Icons.mail, Color(0xFFE84B91)),
    _GameItem('Talent', Icons.mic, Color(0xFFFF8A21)),
    _GameItem('Video', Icons.play_circle_fill, Color(0xFFE43B3B)),
    _GameItem('Snakes & Ladders', Icons.extension, Color(0xFF25A7D9)),
    _GameItem('Carrom', Icons.sports_esports, Color(0xFF9E275C)),
    _GameItem('No Bomb', Icons.warning_amber_rounded, Color(0xFF315CF5)),
    _GameItem('Yummy Crush', Icons.favorite, Color(0xFFFF8C24)),
  ];

  final List<_GameItem> playCenterGames = const [
    _GameItem('Music', Icons.music_note, Color(0xFF8A35E8)),
    _GameItem('Lucky Wheel', Icons.casino, Color(0xFFFFA62B)),
    _GameItem('Calculator', Icons.calculate, Color(0xFF6B74FF)),
    _GameItem('PK', Icons.flash_on, Color(0xFFE83B91)),
    _GameItem('Room PK', Icons.compare_arrows, Color(0xFFFFC83D)),
    _GameItem('Turntable', Icons.album, Color(0xFFFF8A21)),
    _GameItem('Intimacy Bond', Icons.card_giftcard, Color(0xFFB77AFF)),
  ];

  final List<_GameItem> moreGames = const [
    _GameItem('Fruit Party', Icons.local_bar, Color(0xFFFFB52E)),
    _GameItem('Lucky77', Icons.star, Color(0xFFE93A74)),
    _GameItem('Olympus', Icons.auto_awesome, Color(0xFFFFB52E)),
    _GameItem('Teen Patti', Icons.style, Color(0xFFDE3C4F)),
    _GameItem('Crash', Icons.rocket_launch, Color(0xFFED5A31)),
    _GameItem('Deep-sea Fish', Icons.water, Color(0xFF27A8E0)),
    _GameItem('Lucky Fruit', Icons.local_florist, Color(0xFF7FC34B)),
    _GameItem('Peacock & Tiger', Icons.pets, Color(0xFF6A50E8)),
    _GameItem('Bounty Racing', Icons.directions_car, Color(0xFFE34D45)),
    _GameItem('CrazyGems-2', Icons.diamond, Color(0xFFE4A22C)),
    _GameItem('Original777', Icons.filter_7, Color(0xFFD94A31)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Room Mode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showInfo(
                context,
                'Room Mode',
                'Choose a game or activity for your room.',
              );
            },
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roomHeader(),
              const SizedBox(height: 24),

              _sectionTitle(
                'Room Games',
                'Play together with everyone in the room',
              ),
              const SizedBox(height: 14),

              _gameGrid(roomGames),

              const SizedBox(height: 28),

              _sectionTitle(
                'Play center',
                'Fun activities inside your room',
              ),
              const SizedBox(height: 14),

              _gameGrid(playCenterGames),

              const SizedBox(height: 28),

              _sectionTitle(
                'More games',
                'Discover more entertainment',
              ),
              const SizedBox(height: 14),

              _gameGrid(moreGames),

              const SizedBox(height: 30),

              _premiumBanner(),

              const SizedBox(height: 24),

              _quickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF32134D),
            Color(0xFF7524A8),
            Color(0xFFB52C76),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.14),
              border: Border.all(
                color: Colors.white.withOpacity(.35),
              ),
            ),
            child: const Icon(
              Icons.sports_esports,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat Game Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Play • Chat • Have Fun',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 5),
                Text(
                  '30',
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _gameGrid(List<_GameItem> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 18,
        childAspectRatio: .76,
      ),
      itemBuilder: (context, index) {
        return _gameTile(games[index]);
      },
    );
  }

  Widget _gameTile(_GameItem game) {
    return GestureDetector(
      onTap: () {
        _openGame(game.name);
      },
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  game.color,
                  game.color.withOpacity(.62),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: game.color.withOpacity(.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              game.icon,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 34,
            child: Text(
              game.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B1557),
            Color(0xFF7628A5),
          ],
        ),
        border: Border.all(
          color: gold.withOpacity(.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withOpacity(.16),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat Premium Games',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'More games and room activities',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.music_note,
            'Music',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            Icons.card_giftcard,
            'Gifts',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            Icons.share,
            'Share',
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        _showInfo(
          context,
          title,
          '$title feature is ready for connection.',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withOpacity(.07),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: purple,
              size: 25,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGame(String gameName) {
    _showInfo(
      context,
      gameName,
      '$gameName UI is ready for connection.',
    );
  }

  void _showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF211E27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                const Icon(
                  Icons.sports_esports,
                  color: purple,
                  size: 46,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'OK',
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
}

class _GameItem {
  final String name;
  final IconData icon;
  final Color color;

  const _GameItem(
    this.name,
    this.icon,
    this.color,
  );
}
