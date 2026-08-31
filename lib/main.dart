// =====================================================
// PART 4
// PROFILE + OWNER DASHBOARD + CHAT ROOMS
// =====================================================

// =====================================================
// USER / OWNER ROLE
// =====================================================

// IMPORTANT:
// Real authentication/Firebase connect ಮಾಡಿದ ನಂತರ
// ಇದನ್ನು database role ಮೂಲಕ control ಮಾಡಬೇಕು.
//
// ಈಗ default ಆಗಿ normal USER.
// ಆದ್ದರಿಂದ ಸಾಮಾನ್ಯ users ಗೆ Owner Dashboard ಕಾಣಿಸುವುದಿಲ್ಲ.

const bool currentUserIsOwner = false;


// =====================================================
// PROFILE SCREEN
// =====================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 65,
              child: Icon(
                Icons.person,
                size: 70,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Mchat User',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Mchat ID: 10000001',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                    ),
                    title: const Text(
                      'My Profile',
                    ),
                    subtitle: const Text(
                      'Edit profile information',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile editing will be connected next.',
                          ),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.monetization_on_outlined,
                    ),
                    title: const Text(
                      'My Coins',
                    ),
                    subtitle: const Text(
                      '0 Coins',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CoinsScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.card_giftcard,
                    ),
                    title: const Text(
                      'My Gifts',
                    ),
                    subtitle: const Text(
                      'Received and sent gifts',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const GiftsScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.people_outline,
                    ),
                    title: const Text(
                      'Refer & Earn',
                    ),
                    subtitle: const Text(
                      'Invite friends and earn',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ReferScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // OWNER ONLY
            if (currentUserIsOwner)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                  ),
                  title: const Text(
                    'Owner Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Manage Mchat application',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const OwnerDashboardScreen(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                ),
                title: const Text(
                  'Settings',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// OWNER DASHBOARD
// =====================================================

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Owner Dashboard',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Mchat Owner Panel',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ownerMenu(
            context,
            Icons.people,
            'Users',
            'Manage registered users',
          ),

          ownerMenu(
            context,
            Icons.monetization_on,
            'Coins & Recharge',
            'View coin transactions',
          ),

          ownerMenu(
            context,
            Icons.card_giftcard,
            'Gifts',
            'Manage gifts',
          ),

          ownerMenu(
            context,
            Icons.emoji_events,
            'VIP Management',
            'Manage VIP levels',
          ),

          ownerMenu(
            context,
            Icons.live_tv,
            'Live Rooms',
            'Manage live rooms',
          ),

          ownerMenu(
            context,
            Icons.account_balance_wallet,
            'Revenue',
            'View application revenue',
          ),

          ownerMenu(
            context,
            Icons.settings,
            'App Settings',
            'Application settings',
          ),
        ],
      ),
    );
  }

  Widget ownerMenu(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          size: 35,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                '$title management will be connected to the real backend.',
              ),
            ),
          );
        },
      ),
    );
  }
}


// =====================================================
// CHAT ROOM
// =====================================================

class ChatRoomScreen extends StatefulWidget {
  final String roomName;
  final String roomType;

  const ChatRoomScreen({
    super.key,
    required this.roomName,
    required this.roomType,
  });

  @override
  State<ChatRoomScreen> createState() =>
      _ChatRoomScreenState();
}

class _ChatRoomScreenState
    extends State<ChatRoomScreen> {

  final List<String> messages = [
    'Welcome to Mchat Room!',
    'Please respect everyone.',
    'Let’s chat and have fun together!',
  ];

  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(
        'You: $text',
      );
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomName,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              widget.roomType,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Room shared.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.share,
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.power_settings_new,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF33205C),
                  Color(0xFF11101E),
                ],
              ),
            ),
          ),

          Column(
            children: [

              // ROOM HEADER
              Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            widget.roomName,
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          const Text(
                            'Online users: 1',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        showRoomMode(context);
                      },
                      icon: const Icon(
                        Icons.grid_view,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // MIC SEATS
              SizedBox(
                height: 115,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: 10,
                  itemBuilder:
                      (context, index) {

                    final isFirst =
                        index == 0;

                    return Container(
                      width: 82,
                      margin:
                          const EdgeInsets.only(
                        right: 10,
                      ),
                      child: Column(
                        children: [

                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Colors.white24,
                            child: Icon(
                              isFirst
                                  ? Icons.person
                                  : Icons.lock,
                              color:
                                  Colors.white,
                              size: 30,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            isFirst
                                ? 'You'
                                : '${index + 1}',
                            style:
                                const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // MESSAGES
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount:
                      messages.length,
                  itemBuilder:
                      (context, index) {

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      padding:
                          const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.black45,
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: Text(
                        messages[index],
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // CHAT INPUT
              SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.all(10),
                  child: Row(
                    children: [

                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Emoji panel coming next.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.emoji_emotions,
                          color: Colors.white,
                        ),
                      ),

                      Expanded(
                        child: TextField(
                          controller:
                              controller,
                          style:
                              const TextStyle(
                            color: Colors.white,
                          ),
                          decoration:
                              InputDecoration(
                            hintText:
                                'Type message...',
                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors.white54,
                            ),
                            filled: true,
                            fillColor:
                                Colors.white12,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                25,
                              ),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                          onSubmitted:
                              (_) => sendMessage(),
                        ),
                      ),

                      IconButton(
                        onPressed:
                            sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================
  // ROOM MODE
  // ===================================================

  void showRoomMode(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          const Color(0xFF181818),
      isScrollControlled: true,
      builder: (context) {

        final modes = [
          ['Truth & Dare', Icons.sports],
          ['Undercover', Icons.visibility],
          ['Dominoes', Icons.casino],
          ['Draw & Guess', Icons.brush],
          ['Ludo', Icons.games],
          ['Blind Date', Icons.favorite],
          ['Talent', Icons.mic],
          ['Video', Icons.play_circle],
          ['Snakes & Ladders', Icons.casino],
          ['Carrom', Icons.sports_esports],
          ['No Bomb', Icons.warning],
          ['Yummy Crush', Icons.favorite],
          ['Music', Icons.music_note],
          ['Lucky Wheel', Icons.album],
          ['Calculator', Icons.calculate],
          ['Sound Effect', Icons.music_video],
          ['PK', Icons.flash_on],
          ['Room PK', Icons.compare_arrows],
          ['Turntable', Icons.album],
          ['Intimacy Bond', Icons.favorite_border],
        ];

        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  'Room Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount:
                        modes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 18,
                      childAspectRatio: .85,
                    ),
                    itemBuilder:
                        (context, index) {

                      return InkWell(
                        onTap: () {
                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger
                              .of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                '${modes[index][0]} selected.',
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [

                            CircleAvatar(
                              radius: 27,
                              child: Icon(
                                modes[index][1]
                                    as IconData,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              modes[index][0]
                                  as String,
                              maxLines: 2,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 11,
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
}


// =====================================================
// BROAD ROOM
// =====================================================

class BroadRoomScreen extends StatelessWidget {
  const BroadRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Broad Rooms',
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          roomTypeCard(
            context,
            'Public Broad Room',
            'Open room for everyone',
            Icons.public,
          ),

          roomTypeCard(
            context,
            'Popular Broad Room',
            'Discover popular rooms',
            Icons.trending_up,
          ),

          roomTypeCard(
            context,
            'Music Broad Room',
            'Music and entertainment',
            Icons.music_note,
          ),

          roomTypeCard(
            context,
            'Game Broad Room',
            'Play games together',
            Icons.games,
          ),
        ],
      ),
    );
  }

  Widget roomTypeCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatRoomScreen(
                roomName: title,
                roomType: 'Broad Room',
              ),
            ),
          );
        },
      ),
    );
  }
}


// =====================================================
// FAMILY ROOM
// =====================================================

class FamilyRoomScreen extends StatelessWidget {
  const FamilyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Family Rooms',
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [

          roomCard(
            context,
            'Mchat Family',
            'Family members and friends',
          ),

          roomCard(
            context,
            'Friends Family',
            'Private family room',
          ),

          roomCard(
            context,
            'Music Family',
            'Music and voice chat',
          ),

          const SizedBox(
            height: 20,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ChatRoomScreen(
                      roomName:
                          'My Family Room',
                      roomType:
                          'Family Room',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Create Family Room',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget roomCard(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(
            Icons.family_restroom,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatRoomScreen(
                roomName: title,
                roomType:
                    'Family Room',
              ),
            ),
          );
        },
      ),
    );
  }
}


// =====================================================
// PART 4 END
// =====================================================
