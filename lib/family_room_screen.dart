import 'package:flutter/material.dart';

enum MchatRoomType { family, broad }

class MchatRoomScreen extends StatefulWidget {
  final MchatRoomType roomType;
  final String roomName;
  final String hostName;
  final String hostMchatId;

  const MchatRoomScreen({
    super.key,
    this.roomType = MchatRoomType.family,
    this.roomName = 'Mchat Family Room',
    this.hostName = 'Mchat Host',
    this.hostMchatId = '11111111',
  });

  @override
  State<MchatRoomScreen> createState() => _MchatRoomScreenState();
}

class _MchatRoomScreenState extends State<MchatRoomScreen> {
  bool roomLocked = false;
  bool soundOn = true;
  bool showChat = true;
  int selectedSeat = 0;

  final TextEditingController chat = TextEditingController();

  final List<String> messages = [
    'Welcome to Mchat! Please respect each other and chat in a decent manner.',
    'Welcome everyone! Let’s chat and have fun together!',
  ];

  final List<List<String>> games = const [
    ['Truth & Dare', '🧪'],
    ['Undercover', '🎩'],
    ['Dominoes', '🀄'],
    ['Draw & Guess', '🎨'],
    ['Ludo', '🎲'],
    ['Blind Date', '💌'],
    ['Talent', '🎤'],
    ['Video', '▶️'],
    ['Snakes & Ladders', '🐍'],
    ['Carrom', '🏸'],
    ['No Bomb', '💣'],
    ['Yummy Crush', '🍊'],
  ];

  final List<List<String>> play = const [
    ['Music', '🎵'],
    ['Lucky Wheel', '🎡'],
    ['Calculator', '777'],
    ['PK', 'PK'],
    ['Room PK', 'VS'],
    ['Turntable', 'GO'],
    ['Intimacy Bond', '💎'],
  ];

  final List<List<String>> more = const [
    ['Fruit Party', '🎰'],
    ['Lucky77', '777'],
    ['Olympus', '⚡'],
    ['Teen Patti', '🃏'],
    ['Crash', '🚀'],
    ['Deep-sea Fish', '🦈'],
    ['Lucky Fruit', '🍉'],
    ['Peacock & Tiger', '🦚'],
    ['Bounty Racing', '🏎️'],
    ['CrazyGems-2', '💎'],
    ['Original777', '777'],
  ];

  @override
  void dispose() {
    chat.dispose();
    super.dispose();
  }

  void toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF160D20),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BackdropPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(),
                _progress(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 170),
                    child: Column(
                      children: [
                        _seats(),

                        _announcement(
                          'Welcome to Mchat! Please respect each other and chat in a decent manner.',
                          false,
                        ),

                        _announcement(
                          'Welcome everyone! Let’s chat and have fun together!',
                          true,
                        ),

                        _share(),
                        _level(),

                        if (showChat) _chatBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          _floatingTools(),
          _bottomBar(),

          if (selectedSeat > 0) _seatActions(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 8, 3),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2B0B45),
                  Color(0xFFB52D93),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.roomName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _badge(
                      widget.roomType == MchatRoomType.family
                          ? 'FAMILY'
                          : 'BROAD',
                    ),
                  ],
                ),

                Text(
                  'ID: ${widget.hostMchatId}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _icon(
            Icons.workspace_premium_outlined,
            () => toast('Room premium'),
          ),

          _icon(
            Icons.card_giftcard,
            () => toast('Room rewards'),
          ),

          _icon(
            Icons.share_outlined,
            () => toast('Share room'),
          ),

          _icon(
            Icons.more_vert,
            _roomMenu,
          ),

          _icon(
            Icons.power_settings_new,
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF8C3CC2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _icon(
    IconData icon,
    VoidCallback tap,
  ) {
    return IconButton(
      onPressed: tap,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  // ============================================================
  // ROOM PROGRESS
  // ============================================================

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(width: 7),
                Text(
                  '0/5,250',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            '🛡️',
            style: TextStyle(fontSize: 24),
          ),

          const Spacer(),

          Container(
            width: 47,
            height: 47,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 30 SEATS
  // ============================================================

  Widget _seats() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 30,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 9,
          crossAxisSpacing: 6,
          childAspectRatio: .82,
        ),
        itemBuilder: (_, i) {
          final occupied = i == 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSeat = i + 1;
              });

              toast(
                occupied
                    ? 'Host profile'
                    : 'Seat ${i + 1} is available',
              );
            },
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: occupied
                        ? const Color(0xFF704A77)
                        : Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedSeat == i + 1
                          ? Colors.amber
                          : Colors.white12,
                      width: selectedSeat == i + 1
                          ? 2
                          : 1,
                    ),
                  ),
                  child: Center(
                    child: occupied
                        ? const Text(
                            '👑',
                            style: TextStyle(fontSize: 28),
                          )
                        : const Icon(
                            Icons.lock,
                            color: Colors.white70,
                            size: 24,
                          ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),

                if (occupied)
                  const Icon(
                    Icons.mic,
                    color: Colors.greenAccent,
                    size: 12,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ANNOUNCEMENT
  // ============================================================

  Widget _announcement(
    String text,
    bool edit,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        18,
        5,
        18,
        4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF60F1FF),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),

          if (edit)
            TextButton(
              onPressed: () {
                toast('Announcement editor');
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARE
  // ============================================================

  Widget _share() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        18,
        7,
        18,
        5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Share your room to others!',
              style: TextStyle(
                color: Color(0xFFFFD85A),
                fontSize: 13,
              ),
            ),
          ),

          FilledButton(
            onPressed: () {
              toast('Room share opened');
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF258DE8),
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROOM LEVEL
  // ============================================================

  Widget _level() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        7,
        18,
        3,
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFC49540),
                  Color(0xFF673319),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                '🐉',
                style: TextStyle(fontSize: 38),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Lv1',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              Container(
                width: 135,
                height: 21,
                alignment: Alignment.center,
                color: const Color(0xFFD52F3B),
                child: const Text(
                  '1500/1500',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHAT
  // ============================================================

  Widget _chatBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        18,
        9,
        18,
        8,
      ),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ...messages.take(4).map(
            (m) => Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 3,
                ),
                child: Text(
                  m,
                  style: const TextStyle(
                    color: Color(0xFF6DF2FF),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chat,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                    ),
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              CircleAvatar(
                backgroundColor:
                    const Color(0xFF7B35D0),
                child: IconButton(
                  onPressed: _send,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _send() {
    final t = chat.text.trim();

    if (t.isEmpty) return;

    setState(() {
      messages.add('You: $t');
      chat.clear();
    });
  }

  // ============================================================
  // FLOATING TOOLS
  // ============================================================

  Widget _floatingTools() {
    return Positioned(
      right: 8,
      bottom: 148,
      child: Column(
        children: [
          _float(
            '🎁',
            'Treasure',
            () => toast('Treasure opened'),
          ),

          _float(
            '🎰',
            'Games',
            _moreGames,
          ),

          _float(
            '💎',
            'Gifts',
            _gifts,
          ),

          _float(
            '💬',
            'Chat',
            () {
              setState(() {
                showChat = !showChat;
              });
            },
          ),

          _float(
            '💜',
            'Bonus',
            () => toast('Recharge Bonus'),
          ),
        ],
      ),
    );
  }

  Widget _float(
    String emoji,
    String label,
    VoidCallback tap,
  ) {
    return GestureDetector(
      onTap: tap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    const Color(0xFF6B39D5).withOpacity(.9),
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          13,
          14,
          13,
          18,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _bottom(
                soundOn
                    ? Icons.volume_up
                    : Icons.volume_off,
                () {
                  setState(() {
                    soundOn = !soundOn;
                  });
                },
              ),

              _bottom(
                Icons.emoji_emotions_outlined,
                () => toast('Emoji panel'),
              ),

              _bottom(
                Icons.chat_bubble_outline,
                () {
                  setState(() {
                    showChat = true;
                  });
                },
              ),

              const Spacer(),

              _bottom(
                Icons.music_note,
                _playCenter,
              ),

              _bottom(
                Icons.card_giftcard,
                _gifts,
              ),

              _bottom(
                Icons.card_membership,
                () => toast('Recharge Bonus'),
              ),

              _bottom(
                Icons.grid_view_rounded,
                _roomMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottom(
    IconData icon,
    VoidCallback tap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white12,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEAT ACTIONS
  // ============================================================

  Widget _seatActions() {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 86,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF252126),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Text(
              'Seat $selectedSeat',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            TextButton(
              onPressed: () {
                toast('Member profile');
              },
              child: const Text('Profile'),
            ),

            TextButton(
              onPressed: () {
                toast('Mic control');
              },
              child: const Text('Mic'),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  selectedSeat = 0;
                });
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ROOM SETTINGS
  // ============================================================

  void _roomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181719),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(18),
            children: [
              const Center(
                child: Text(
                  'Room Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ...[
                ['Room skin', Icons.chair_outlined],
                ['Theme', Icons.checkroom_outlined],
                ['Announcement', Icons.event_note_outlined],
                ['Feedback', Icons.feedback_outlined],
                ['Clean chat', Icons.cleaning_services_outlined],
                ['Lock', Icons.lock_outline],
                [
                  'Room premium',
                  Icons.workspace_premium_outlined
                ],
                [
                  'Room backpack',
                  Icons.backpack_outlined
                ],
                [
                  'Effect settings',
                  Icons.auto_awesome_outlined
                ],
              ].map(
                (x) {
                  final title = x[0] as String;

                  return ListTile(
                    leading: Icon(
                      x[1] as IconData,
                      color: Colors.white,
                    ),

                    title: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    trailing: title == 'Lock'
                        ? Switch(
                            value: roomLocked,
                            onChanged: (v) {
                              setState(() {
                                roomLocked = v;
                              });

                              Navigator.pop(context);
                            },
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),

                    onTap: title == 'Lock'
                        ? null
                        : () {
                            Navigator.pop(context);
                            toast('$title UI opened');
                          },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ROOM MODE
  // ============================================================

  void _roomMode() {
    _gamesSheet(
      'Room Mode',
      'Play together',
      games,
    );
  }

  // ============================================================
  // PLAY CENTER
  // ============================================================

  void _playCenter() {
    _gamesSheet(
      'Play center',
      'Music and room activities',
      play,
    );
  }

  // ============================================================
  // MORE GAMES
  // ============================================================

  void _moreGames() {
    _gamesSheet(
      'More games',
      'More room activities',
      more,
    );
  }

  // ============================================================
  // GAMES SHEET
  // ============================================================

  void _gamesSheet(
    String title,
    String subtitle,
    List<List<String>> items,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171717),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              15,
              18,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.close,
                      color: Colors.white54,
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 15,
                      childAspectRatio: .78,
                    ),
                    itemBuilder: (_, i) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          toast(
                            '${items[i][0]} UI opened',
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF7136A8),
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                              child: Text(
                                items[i][1],
                                style:
                                    const TextStyle(
                                  fontSize: 29,
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              items[i][0],
                              textAlign:
                                  TextAlign.center,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GIFTS
  // ============================================================

  void _gifts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181719),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Gifts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 15),

                const Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    Text('🌹 10'),
                    Text('❤️ 49'),
                    Text('🍭 99'),
                    Text('☕ 199'),
                    Text('🧸 299'),
                    Text('💎 499'),
                    Text('🚗 999'),
                    Text('🏰 1999'),
                    Text('🦁 2999'),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Verified coin delivery will be connected in the backend stage.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
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

// ============================================================
// BACKGROUND
// ============================================================

class _BackdropPainter extends CustomPainter {
  @override
  void paint(
    Canvas c,
    Size s,
  ) {
    final p = Paint();

    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF5A246D),
        Color(0xFF8D5570),
        Color(0xFF17111B),
      ],
    ).createShader(
      Offset.zero & s,
    );

    c.drawRect(
      Offset.zero & s,
      p,
    );

    p.shader = null;
    p.color = Colors.white.withOpacity(.045);

    for (int i = 0; i < 45; i++) {
      c.drawCircle(
        Offset(
          (i * 71.0) % s.width,
          (i * 127.0) % s.height,
        ),
        1 + i % 3,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
