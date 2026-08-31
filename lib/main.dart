import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B3FE4),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF9FF),
      ),
      home: const MchatHomePage(),
    );
  }
}

class MchatHomePage extends StatefulWidget {
  const MchatHomePage({super.key});

  @override
  State<MchatHomePage> createState() => _MchatHomePageState();
}

class _MchatHomePageState extends State<MchatHomePage> {
  int selectedIndex = 0;

  // Testing account
  // true = Owner
  // false = Normal User
  final bool currentUserIsOwner = true;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const InboxScreen(),
      const LiveScreen(),
      ProfileScreen(isOwner: currentUserIsOwner),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
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

// =====================================================
// HOME SCREEN
// =====================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mchat',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    openPage(
                      context,
                      const ProfileScreen(isOwner: false),
                    );
                  },
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8E35FF),
                    Color(0xFF5146E5),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Mchat 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Connect • Chat • Share • Enjoy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Chat Rooms',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: roomTypeCard(
                    context,
                    Icons.public,
                    'Broad Room',
                    'Public rooms',
                    const BroadRoomScreen(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: roomTypeCard(
                    context,
                    Icons.family_restroom,
                    'Family Room',
                    'Family groups',
                    const FamilyRoomScreen(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Mchat Services',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                serviceCard(
                  context,
                  Icons.chat_bubble_outline,
                  'Free Inbox',
                  const InboxScreen(),
                ),
                serviceCard(
                  context,
                  Icons.mic_none,
                  'Voice',
                  const VoiceScreen(),
                ),
                serviceCard(
                  context,
                  Icons.live_tv,
                  'Live Room',
                  const LiveScreen(),
                ),
                serviceCard(
                  context,
                  Icons.emoji_events_outlined,
                  'VIP',
                  const VipScreen(),
                ),
                serviceCard(
                  context,
                  Icons.monetization_on_outlined,
                  'Coins',
                  const CoinsScreen(),
                ),
                serviceCard(
                  context,
                  Icons.card_giftcard,
                  'Gifts',
                  const GiftsScreen(),
                ),
                serviceCard(
                  context,
                  Icons.people_outline,
                  'Refer & Earn',
                  const ReferScreen(),
                ),
                serviceCard(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  const SettingsScreen(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 45,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Coins',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0 Coins',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      openPage(
                        context,
                        const CoinsScreen(),
                      );
                    },
                    child: const Text('Recharge'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roomTypeCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openPage(context, page),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 45,
                color:
                    Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget serviceCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openPage(context, page),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color:
                    Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PART 1 END
// =====================================================
