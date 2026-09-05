import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'inbox_screen.dart' as real_inbox;
import 'wallet_screen.dart';
import 'wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MchatApp());
}

class MchatApp extends StatelessWidget {
  const MchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mchat',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7B2CBF),
        scaffoldBackgroundColor: const Color(0xFFF8F5FC),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// FIREBASE AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Authentication service unavailable'),
            ),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const MchatHomePage();
      },
    );
  }
}

// ============================================================
// HOME
// ============================================================

class MchatHomePage extends StatefulWidget {
  const MchatHomePage({super.key});

  @override
  State<MchatHomePage> createState() => _MchatHomePageState();
}

class _MchatHomePageState extends State<MchatHomePage> {
  int index = 0;

  final pages = const [
    HomeContent(),
    real_inbox.InboxScreen(),
    LiveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: const Color(0xFFF8F5FC),
        indicatorColor: const Color(0xFFEDE1FA),
        onDestinationSelected: (v) {
          setState(() {
            index = v;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.live_tv_outlined),
            selectedIcon: Icon(Icons.live_tv),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME CONTENT
// ============================================================

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static const features = [
    [
      'Family Room',
      '30 Seats',
      Icons.groups_rounded,
    ],
    [
      'PK Battle',
      'Challenge',
      Icons.flash_on,
    ],
    [
      'Room Mode',
      'Play Center',
      Icons.sports_esports,
    ],
    [
      'Gifts',
      'Send Gifts',
      Icons.card_giftcard,
    ],
    [
      'Music',
      'Song Library',
      Icons.music_note,
    ],
    [
      'Recording',
      'Record Voice',
      Icons.mic,
    ],
    [
      'Media',
      'Create',
      Icons.camera_alt,
    ],
    [
      'Refer & Earn',
      'Invite Friends',
      Icons.share,
    ],
  ];

  void open(BuildContext context, String title) {
    final page = <String, Widget>{
      'Family Room': const FamilyRoomScreen(),
      'PK Battle': const RoomPKScreen(),
      'Room Mode': const RoomModeGamesScreen(),
      'Gifts': const GiftsScreen(),
      'Music': const FeatureScreen(
        title: 'Music',
        icon: Icons.music_note,
      ),
      'Recording': const FeatureScreen(
        title: 'Recording',
        icon: Icons.mic,
      ),
      'Media': const FeatureScreen(
        title: 'Media',
        icon: Icons.camera_alt,
      ),
      'Refer & Earn': const ReferEarnScreen(),
    }[title];

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF55138A),
                          Color(0xFFE52D8A),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mchat',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'M Karnataka Voice Club',
                          style: TextStyle(
                            color: Color(0xFF7434B5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HB(
                    icon: Icons.notifications_none,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _HB(
                    icon: Icons.person_outline,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // SEARCH
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                16,
              ),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 18),
                    Icon(
                      Icons.search,
                      color: Color(0xFF7B2CBF),
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Search people, rooms or Mchat ID',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.tune,
                      color: Color(0xFF7B2CBF),
                      size: 28,
                    ),
                    SizedBox(width: 18),
                  ],
                ),
              ),
            ),
          ),

          // COINS
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 215,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF42106B),
                      Color(0xFF852CC5),
                      Color(0xFFE52D8A),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -30,
                      child: Icon(
                        Icons.monetization_on,
                        size: 185,
                        color: Colors.white.withOpacity(.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor:
                                    Colors.amber,
                                child: Icon(
                                  Icons.attach_money,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'My Coins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WalletScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Recharge'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          StreamBuilder<int>(
  stream: WalletService.instance.coinBalanceStream(),
  initialData: 0,
  builder: (context, snapshot) {
    final coins = snapshot.data ?? 0;

    return Text(
      coins.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 52,
        fontWeight: FontWeight.w800,
      ),
    );
  },
),
                         
                          const Text(
                            'Available Coins',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CATEGORIES
          SliverToBoxAdapter(
            child: SizedBox(
              height: 76,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                scrollDirection: Axis.horizontal,
                children: [
                  _Chip(
                    'For You',
                    true,
                    () {},
                  ),
                  _Chip(
                    'Live',
                    false,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LiveScreen(),
                        ),
                      );
                    },
                  ),
                  _Chip(
                    'Rooms',
                    false,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FamilyRoomScreen(),
                        ),
                      );
                    },
                  ),
                  _Chip(
                    'PK',
                    false,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoomPKScreen(),
                        ),
                      );
                    },
                  ),
                  _Chip(
                    'Games',
                    false,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoomModeGamesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // QUICK ACTIONS
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  16,
                ),
                scrollDirection: Axis.horizontal,
                children: [
                  _QA(
                    'Go Live',
                    Icons.videocam,
                    Colors.pink,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LiveScreen(),
                        ),
                      );
                    },
                  ),
                  _QA(
                    'VIP',
                    Icons.emoji_events,
                    Colors.amber,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const VipScreen(),
                        ),
                      );
                    },
                  ),
                  _QA(
                    'Inbox',
                    Icons.chat,
                    Colors.deepPurple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const InboxScreen(),
                        ),
                      );
                    },
                  ),
                  _QA(
                    'Games',
                    Icons.sports_esports,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoomModeGamesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // LIVE TITLE
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Rooms',
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'See who is live now',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      color: Color(0xFF7B2CBF),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LIVE ROOMS
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                scrollDirection: Axis.horizontal,
                children: const [
                  _RoomCard(
                    'Mchat Live Room',
                    'Live Host',
                    Icons.mic,
                  ),
                  _RoomCard(
                    'Music Room',
                    'Singer Live',
                    Icons.music_note,
                    true,
                  ),
                  _RoomCard(
                    'Talk Room',
                    'Mchat Host',
                    Icons.forum,
                  ),
                ],
              ),
            ),
          ),

          // FEATURES TITLE
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                4,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mchat Features',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Explore everything in Mchat',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FEATURE GRID
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20,
            ),
            sliver: SliverGrid(
              delegate:
                  SliverChildBuilderDelegate(
                (context, i) {
                  final x = features[i];

                  return _FT(
                    x[0] as String,
                    x[1] as String,
                    x[2] as IconData,
                    () => open(
                      context,
                      x[0] as String,
                    ),
                  );
                },
                childCount: features.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: .78,
              ),
            ),
          ),

          // VIP BANNER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                4,
                20,
                24,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const VipScreen(),
                    ),
                  );
                },
                borderRadius:
                    BorderRadius.circular(30),
                child: Container(
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF321047),
                        Color(0xFF7434A5),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor:
                              Color(0x35FFB300),
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VIP Center',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                'VIP 1 → VIP 10 • Exclusive Benefits',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME WIDGETS
// ============================================================

class _HB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HB({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, size: 27),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
    this.title,
    this.selected,
    this.onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 10),
      child: Material(
        color: selected
            ? const Color(0xFF7B2CBF)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(28),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 14,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QA extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QA(
    this.title,
    this.icon,
    this.color,
    this.onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin:
          const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor:
                    color.withOpacity(.10),
                child: Icon(
                  icon,
                  color: color,
                  size: 31,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String title;
  final String host;
  final IconData icon;
  final bool pink;

  const _RoomCard(
    this.title,
    this.host,
    this.icon, [
    this.pink = false,
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin:
          const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: pink
              ? const [
                  Color(0xFFC02778),
                  Color(0xFFE43C91),
                ]
              : const [
                  Color(0xFF36115B),
                  Color(0xFF8129C7),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 15,
            bottom: 5,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withOpacity(.10),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  host,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FT extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FT(
    this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(22),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor:
                  const Color(0xFF9B4DCA)
                      .withOpacity(.10),
              child: Icon(
                icon,
                color: const Color(0xFF792CB5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMMON
// ============================================================

class FeatureBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const FeatureBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E35FF),
            Color(0xFF4F46E5),
          ],
        ),
        borderRadius:
            BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Colors.white24,
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INBOX
// ============================================================

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Free Inbox')),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Free Inbox',
            subtitle:
                'Real-time chat space',
            icon: Icons.chat_bubble,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading:
                  const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title:
                  const Text('Mchat User'),
              subtitle:
                  const Text('Hello 👋'),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PrivateChatScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIVATE CHAT
// ============================================================

class PrivateChatScreen
    extends StatefulWidget {
  const PrivateChatScreen({super.key});

  @override
  State<PrivateChatScreen> createState() =>
      _PrivateChatScreenState();
}

class _PrivateChatScreenState
    extends State<PrivateChatScreen> {
  final controller =
      TextEditingController();

  final messages = <String>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(text);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Private Chat'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivateChatRulesScreen(),
                ),
              );
            },
            icon:
                const Icon(Icons.security),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Private chat messages will appear here',
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        messages.length,
                    itemBuilder:
                        (_, i) {
                      return Align(
                        alignment:
                            Alignment.centerRight,
                        child: Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFE9D8FA,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),
                          child:
                              Text(messages[i]),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Type message...',
                        border:
                            OutlineInputBorder(),
                      ),
                      onSubmitted:
                          (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: send,
                    icon:
                        const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHAT RULES
// ============================================================

class PrivateChatRulesScreen
    extends StatelessWidget {
  const PrivateChatRulesScreen(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Chat Rules')),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: const [
          RuleTile(
            icon: Icons.security,
            title: 'Privacy',
            subtitle:
                'Respect private conversations.',
          ),
          RuleTile(
            icon: Icons.report_outlined,
            title: 'Report',
            subtitle:
                'Report abusive behaviour.',
          ),
          RuleTile(
            icon: Icons.block,
            title: 'Block',
            subtitle:
                'Block unwanted users.',
          ),
        ],
      ),
    );
  }
}

class RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const RuleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading:
            CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle:
            Text(subtitle),
      ),
    );
  }
}

// ============================================================
// LIVE
// ============================================================

class LiveScreen
    extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Live Room')),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Mchat Live Room',
            subtitle:
                'Go live and connect with people',
            icon: Icons.live_tv,
          ),
          const SizedBox(height: 25),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LiveEndedScreen(),
                ),
              );
            },
            icon:
                const Icon(Icons.stop_circle),
            label:
                const Text('End Live'),
          ),
        ],
      ),
    );
  }
}

class LiveEndedScreen
    extends StatelessWidget {
  const LiveEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Live Ended')),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Live session ended',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ReplayPlayerScreen(),
                  ),
                );
              },
              child:
                  const Text('Watch Replay'),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveEndedReplayScreen
    extends StatelessWidget {
  const LiveEndedReplayScreen(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Live Ended & Replay',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Live Ended',
            subtitle:
                'Replay history',
            icon: Icons.history,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.play_circle_fill,
                size: 40,
              ),
              title: const Text(
                'Live Room Replay',
              ),
              subtitle: const Text(
                'Previous live session',
              ),
              trailing:
                  const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ReplayPlayerScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReplayPlayerScreen
    extends StatelessWidget {
  const ReplayPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Replay Player',
      )),
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Replay Player',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FAMILY ROOM - 30 SEATS
// ============================================================

class FamilySeat {
  final int index;
  final bool occupied;
  final String name;
  final bool micOn;

  const FamilySeat({
    required this.index,
    this.occupied = false,
    this.name = '',
    this.micOn = false,
  });
}

class FamilyRoomScreen
    extends StatefulWidget {
  const FamilyRoomScreen({super.key});

  @override
  State<FamilyRoomScreen> createState() =>
      _FamilyRoomScreenState();
}

class _FamilyRoomScreenState
    extends State<FamilyRoomScreen> {
  late List<FamilySeat> seats;

  bool joined = false;
  bool micOn = true;
  bool roomLocked = false;

  @override
  void initState() {
    super.initState();

    seats = List.generate(
      30,
      (index) => FamilySeat(
        index: index,
        occupied: index == 0,
        name: index == 0
            ? 'Host'
            : '',
        micOn: index == 0,
      ),
    );
  }

  int get occupiedCount =>
      seats.where(
        (s) => s.occupied,
      ).length;

  void joinRoom() {
    if (roomLocked) return;

    final empty =
        seats.indexWhere(
      (s) => !s.occupied,
    );

    if (empty == -1) return;

    setState(() {
      joined = true;

      seats[empty] = FamilySeat(
        index: empty,
        occupied: true,
        name: 'You',
        micOn: micOn,
      );
    });
  }

  void leaveRoom() {
    final me =
        seats.indexWhere(
      (s) => s.name == 'You',
    );

    if (me == -1) return;

    setState(() {
      seats[me] =
          FamilySeat(index: me);
      joined = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Family Room'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                roomLocked =
                    !roomLocked;
              });
            },
            icon: Icon(
              roomLocked
                  ? Icons.lock
                  : Icons.lock_open,
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    const Padding(
                  padding:
                      EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Room Rules',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Respect all members.\n'
                        'No abuse or spam.\n'
                        'Follow room rules.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
            icon:
                const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Family Voice Room',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label:
                      Text('$occupiedCount/30'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.all(12),
              itemCount: 30,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: .82,
              ),
              itemBuilder: (_, index) {
                return FamilySeatWidget(
                  seat: seats[index],
                  onTap: () {},
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    onPressed: joined
                        ? () {
                            setState(() {
                              micOn =
                                  !micOn;
                            });
                          }
                        : null,
                    icon: Icon(
                      micOn
                          ? Icons.mic
                          : Icons.mic_off,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) =>
                            const SizedBox(
                          height: 250,
                          child: Center(
                            child:
                                Text('Room Chat'),
                          ),
                        ),
                      );
                    },
                    icon:
                        const Icon(Icons.chat),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) =>
                            const SizedBox(
                          height: 300,
                          child: Center(
                            child:
                                Text('Gift Panel'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.card_giftcard,
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        roomLocked && !joined
                            ? null
                            : joined
                                ? leaveRoom
                                : joinRoom,
                    child: Text(
                      joined
                          ? 'Leave'
                          : 'Join',
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
}

class FamilySeatWidget
    extends StatelessWidget {
  final FamilySeat seat;
  final VoidCallback onTap;

  const FamilySeatWidget({
    super.key,
    required this.seat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Card(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Icon(
                    seat.occupied
                        ? Icons.person
                        : Icons.add,
                  ),
                ),
                if (seat.occupied &&
                    seat.micOn)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 9,
                      child: Icon(
                        Icons.mic,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              seat.occupied
                  ? seat.name
                  : 'Seat ${seat.index + 1}',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROOM MODE & GAMES
// ============================================================

class RoomModeGamesScreen
    extends StatefulWidget {
  const RoomModeGamesScreen({super.key});

  @override
  State<RoomModeGamesScreen> createState() =>
      _RoomModeGamesScreenState();
}

class _RoomModeGamesScreenState
    extends State<RoomModeGamesScreen> {
  String mode = 'Normal';

  final modes = const [
    'Normal',
    'Music',
    'Party',
    'Game',
    'Study',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Room Mode & Games',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Room Mode',
            subtitle:
                'Choose your room experience',
            icon: Icons.sports_esports,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                modes.map((item) {
              return ChoiceChip(
                label: Text(item),
                selected:
                    mode == item,
                onSelected: (_) {
                  setState(() {
                    mode = item;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _GameTile(
            title: 'Lucky Wheel',
            icon: Icons.casino,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const GameDetailScreen(
                    title: 'Lucky Wheel',
                  ),
                ),
              );
            },
          ),
          _GameTile(
            title: 'Dice',
            icon: Icons.casino_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const GameDetailScreen(
                    title: 'Dice',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _GameTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading:
            Icon(icon, size: 35),
        title: Text(title),
        subtitle:
            const Text('Play game'),
        trailing:
            const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class GameDetailScreen
    extends StatelessWidget {
  final String title;

  const GameDetailScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_esports,
              size: 90,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Game UI is ready for connection.',
                    ),
                  ),
                );
              },
              child:
                  const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROOM PK
// ============================================================

class RoomPKScreen
    extends StatefulWidget {
  const RoomPKScreen({super.key});

  @override
  State<RoomPKScreen> createState() =>
      _RoomPKScreenState();
}

class _RoomPKScreenState
    extends State<RoomPKScreen> {
  bool active = false;
  int scoreA = 0;
  int scoreB = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Room PK',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Room PK Battle',
            subtitle:
                'Room A vs Room B',
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Room A',
                  value: '$scoreA',
                  icon: Icons.groups,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Room B',
                  value: '$scoreB',
                  icon: Icons.groups,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              active
                  ? 'PK LIVE'
                  : 'PK READY',
              style: const TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                active = !active;
              });
            },
            icon: Icon(
              active
                  ? Icons.stop
                  : Icons.play_arrow,
            ),
            label: Text(
              active
                  ? 'End PK'
                  : 'Start PK',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: active
                ? () {
                    setState(() {
                      scoreA += 10;
                    });
                  }
                : null,
            icon: const Icon(
              Icons.card_giftcard,
            ),
            label:
                const Text('Send PK Gift'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VIP
// ============================================================

class VipScreen
    extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const requirements = [
      '1,000 Coins',
      '3,000 Coins',
      '6,000 Coins',
      '10,000 Coins',
      '20,000 Coins',
      '30,000 Coins',
      '50,000 Coins',
      '80,000 Coins',
      '1,20,000 Coins',
      '2,00,000 Coins',
    ];

    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'VIP Center',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'VIP Makes You Special',
            subtitle:
                'VIP 1 → VIP 10',
            icon: Icons.emoji_events,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 10; i++)
            Card(
              margin:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              child: ListTile(
                leading:
                    CircleAvatar(
                  child:
                      Text('${i + 1}'),
                ),
                title:
                    Text('VIP ${i + 1}'),
                subtitle:
                    Text(requirements[i]),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// COINS
// ============================================================

class CoinsScreen
    extends StatelessWidget {
  const CoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const packages = [
      '100 Coins',
      '300 Coins',
      '500 Coins',
      '1,000 Coins',
      '3,000 Coins',
      '5,000 Coins',
      '10,000 Coins',
      '20,000 Coins',
      '50,000 Coins',
    ];

    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Recharge',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Recharge Coins',
            subtitle:
                'Secure recharge options',
            icon:
                Icons.monetization_on,
          ),
          const SizedBox(height: 18),
          const Text(
            'Select Amount',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final x in packages)
            Card(
              child: ListTile(
                leading:
                    const Icon(
                  Icons.monetization_on,
                ),
                title: Text(x),
                trailing:
                    ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment integration will be connected in the backend phase.',
                        ),
                      ),
                    );
                  },
                  child:
                      const Text('Recharge'),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.account_balance),
                  title:
                      Text('UPI'),
                  subtitle: Text(
                    'Google Pay / PhonePe / Paytm',
                  ),
                ),
                ListTile(
                  leading:
                      Icon(Icons.credit_card),
                  title: Text(
                    'Debit / Credit Card',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                  ),
                  title:
                      Text('Net Banking'),
                ),
                ListTile(
                  leading:
                      Icon(Icons.payment),
                  title:
                      Text('PayPal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Secure payment connection is pending backend integration.',
                  ),
                ),
              );
            },
            icon:
                const Icon(Icons.lock),
            label:
                const Text('Pay Securely'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GIFTS
// ============================================================

class GiftsScreen
    extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gifts = [
      '🌹 Rose 10',
      '❤️ Heart 49',
      '🍭 Lollipop 99',
      '☕ Coffee 199',
      '🧸 Teddy 299',
      '💎 Diamond 499',
      '🚗 Car 999',
      '🏰 Castle 1,999',
      '🦁 Lion 2,999',
    ];

    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Gifts',
      )),
      body: GridView.builder(
        padding:
            const EdgeInsets.all(16),
        itemCount: gifts.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, i) {
          return Card(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(
                  SnackBar(
                    content:
                        Text('${gifts[i]} selected'),
                  ),
                );
              },
              child: Center(
                child: Text(
                  gifts[i],
                  textAlign:
                      TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// REFER & EARN
// ============================================================

class ReferEarnScreen
    extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Refer & Earn',
      )),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title:
                'Invite Friends • Earn Rewards',
            subtitle:
                'Share your link and earn rewards',
            icon: Icons.people,
          ),
          const SizedBox(height: 20),
          const Card(
            child: ListTile(
              leading:
                  Icon(Icons.link),
              title: Text(
                'Your Referral Code',
              ),
              subtitle:
                  Text('MCHAT2026'),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Share connection ready.',
                  ),
                ),
              );
            },
            icon:
                const Icon(Icons.share),
            label:
                const Text('Share Now'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEATURE SCREEN
// ============================================================

class FeatureScreen
    extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeatureScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title)),
      body: Center(
        child: FeatureBanner(
          title: title,
          subtitle:
              'Feature ready for connection',
          icon: icon,
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen
    extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(
        'Settings',
      )),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title:
                const Text('Notifications'),
            secondary:
                const Icon(Icons.notifications),
          ),
          ListTile(
            leading:
                const Icon(Icons.language),
            title:
                const Text('Language'),
            subtitle:
                const Text('Kannada'),
          ),
          ListTile(
            leading:
                const Icon(Icons.security),
            title: const Text(
              'Privacy & Security',
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
            ),
            title:
                const Text('About Mchat'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen
    extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final name =
        user?.displayName?.isNotEmpty ==
                true
            ? user!.displayName!
            : 'Mchat User';

    final email =
        user?.email ?? 'No email';

    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        children: [
          const Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Container(
              width: 145,
              height: 145,
              padding:
                  const EdgeInsets.all(5),
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    LinearGradient(
                  colors: [
                    Color(0xFF6A1B9A),
                    Color(0xFFE52D8A),
                  ],
                ),
              ),
              child:
                  const CircleAvatar(
                backgroundColor:
                    Color(0xFFD9CCEF),
                child: Icon(
                  Icons.person,
                  size: 75,
                  color:
                      Color(0xFF673AB7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF0E9FA),
              borderRadius:
                  BorderRadius.circular(24),
              border: Border.all(
                color:
                    const Color(0xFFD4C2EC),
                width: 2,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.badge,
                  color:
                      Color(0xFF7137B5),
                  size: 38,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mchat ID',
                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                      Text(
                        '11111111',
                        style: TextStyle(
                          color:
                              Color(0xFF6E35B4),
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.copy,
                  color:
                      Color(0xFF7137B5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
  children: [
    Expanded(
      child: StreamBuilder<int>(
        stream: WalletService.instance.coinBalanceStream(),
        initialData: 0,
        builder: (context, snapshot) {
          final coins = snapshot.data ?? 0;

          return _PStat(
            'Coins',
            coins.toString(),
            Icons.monetization_on,
          );
        },
      ),
    ),
    const SizedBox(width: 14),
    const Expanded(
      child: _PStat(
        'VIP Level',
        'VIP 1',
        Icons.star,
      ),
    ),
  ],
),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(25),
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF673AB7),
                  Color(0xFF9652E8),
                ],
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(15),
              leading:
                  const CircleAvatar(
                backgroundColor:
                    Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color:
                      Color(0xFF673AB7),
                ),
              ),
              title:
                  const Text(
                'Owner Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text(
                'Manage Mchat application',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const OwnerSecurityScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          _PM(
            'Edit Profile',
            Icons.edit,
            () {},
          ),
          _PM(
            'Settings',
            Icons.settings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
          ),
          _PM(
            'Privacy & Security',
            Icons.security,
            () {},
          ),
          _PM(
            'Logout',
            Icons.logout,
            () async {
              await FirebaseAuth.instance
                  .signOut();
            },
            Colors.red,
          ),
        ],
      ),
    );
  }
}

class _PStat
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _PStat(
    this.title,
    this.value,
    this.icon,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 42,
            color:
                const Color(0xFF7137B5),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _PM
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _PM(
    this.title,
    this.icon,
    this.onTap, [
    this.color,
  ]);

  @override
  Widget build(BuildContext context) {
    final c =
        color ??
        const Color(0xFF7137B5);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              c.withOpacity(.1),
          child: Icon(
            icon,
            color: c,
          ),
        ),
        title: Text(title),
        trailing:
            const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// OWNER SECURITY
// ============================================================

class OwnerSecurityScreen
    extends StatefulWidget {
  const OwnerSecurityScreen({
    super.key,
  });

  @override
  State<OwnerSecurityScreen> createState() =>
      _OwnerSecurityScreenState();
}

class _OwnerSecurityScreenState
    extends State<OwnerSecurityScreen> {
  final pin =
      TextEditingController();

  bool obscure = true;
  bool biometric = false;
  bool autoLock = true;

  String? error;

  // UI demo only.
  // Production owner authorization must be server-side.
  static const demoPin = '1234';

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  void verify() {
    if (pin.text.trim() == demoPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const OwnerDashboardScreen(),
        ),
      );
    } else {
      setState(() {
        error = 'Invalid Owner PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Owner Dashboard Security',
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const FeatureBanner(
            title:
                'Owner Access Protected',
            subtitle:
                'Authorized owner access only',
            icon:
                Icons.admin_panel_settings,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: pin,
                    obscureText: obscure,
                    keyboardType:
                        TextInputType.number,
                    maxLength: 6,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Enter Owner PIN',
                      border:
                          const OutlineInputBorder(),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            obscure =
                                !obscure;
                          });
                        },
                        icon: Icon(
                          obscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    onSubmitted:
                        (_) => verify(),
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style:
                          const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      onPressed: verify,
                      icon: const Icon(
                        Icons.lock_open,
                      ),
                      label: const Text(
                        'Unlock Owner Dashboard',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: biometric,
                  onChanged: (v) {
                    setState(() {
                      biometric = v;
                    });
                  },
                  secondary:
                      const Icon(
                    Icons.fingerprint,
                  ),
                  title: const Text(
                    'Biometric Unlock',
                  ),
                ),
                SwitchListTile(
                  value: autoLock,
                  onChanged: (v) {
                    setState(() {
                      autoLock = v;
                    });
                  },
                  secondary:
                      const Icon(
                    Icons.lock_clock,
                  ),
                  title: const Text(
                    'Auto Lock',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OWNER DASHBOARD
// ============================================================

class OwnerDashboardScreen
    extends StatelessWidget {
  const OwnerDashboardScreen({
    super.key,
  });

  static const items = [
    ['Users', Icons.people],
    ['Live Rooms', Icons.live_tv],
    ['Room PK', Icons.flash_on],
    ['Live Replays', Icons.history],
    ['Transactions', Icons.receipt_long],
    [
      'Recharges',
      Icons.account_balance_wallet,
    ],
    [
      'Withdraw Requests',
      Icons.payments,
    ],
    [
      'VIP Management',
      Icons.emoji_events,
    ],
    ['Gifts', Icons.card_giftcard],
    ['Reports', Icons.bar_chart],
    [
      'Content Management',
      Icons.article,
    ],
    ['Settings', Icons.settings],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Owner Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const OwnerSecurityScreen(),
                ),
              );
            },
            icon:
                const Icon(Icons.security),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title:
                'Welcome, Owner 👑',
            subtitle:
                'Secure Mchat Administration',
            icon:
                Icons.admin_panel_settings,
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Users',
                  value: '0',
                  icon: Icons.people,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Recharges',
                  value: '₹0',
                  icon:
                      Icons.currency_rupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Income',
                  value: '₹0',
                  icon:
                      Icons.trending_up,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Withdrawn',
                  value: '₹0',
                  icon: Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (x) => Card(
              child: ListTile(
                leading:
                    CircleAvatar(
                  child: Icon(
                    x[1] as IconData,
                  ),
                ),
                title:
                    Text(x[0] as String),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OwnerFeatureScreen(
                        title:
                            x[0] as String,
                        icon:
                            x[1] as IconData,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OWNER FEATURE
// ============================================================

class OwnerFeatureScreen
    extends StatefulWidget {
  final String title;
  final IconData icon;

  const OwnerFeatureScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  State<OwnerFeatureScreen> createState() =>
      _OwnerFeatureScreenState();
}

class _OwnerFeatureScreenState
    extends State<OwnerFeatureScreen> {
  bool unlocked = false;

  static const locked = {
    'Transactions',
    'Recharges',
    'Withdraw Requests',
    'VIP Management',
    'Gifts',
    'Reports',
    'Content Management',
    'Settings',
  };

  @override
  Widget build(BuildContext context) {
    final isLocked =
        locked.contains(widget.title) &&
            !unlocked;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.title),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          FeatureBanner(
            title:
                widget.title,
            subtitle: isLocked
                ? 'Owner permission required'
                : 'Owner access enabled',
            icon: isLocked
                ? Icons.lock
                : widget.icon,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isLocked
                        ? Icons.lock
                        : Icons.verified_user,
                    size: 70,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isLocked
                        ? 'Feature Locked'
                        : 'Access Granted',
                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLocked
                        ? 'This Owner feature is protected.'
                        : 'Management UI ready for backend connection.',
                    textAlign:
                        TextAlign.center,
                  ),
                  if (isLocked) ...[
                    const SizedBox(
                        height: 20),
                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            unlocked = true;
                          });
                        },
                        icon: const Icon(
                          Icons.lock_open,
                        ),
                        label: const Text(
                          'Unlock Feature',
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(
                        height: 15),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          unlocked =
                              false;
                        });
                      },
                      icon: const Icon(
                        Icons.lock,
                      ),
                      label: const Text(
                        'Lock Feature',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
