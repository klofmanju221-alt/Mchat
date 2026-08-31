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
          seedColor: const Color(0xFF8E35FF),
        ),
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

  final List<Widget> pages = const [
    HomeScreen(),
    InboxScreen(),
    LiveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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

// ================= HOME =================

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
        padding: const EdgeInsets.all(16),
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
                  icon: const Icon(Icons.notifications_outlined),
                ),
                IconButton(
                  onPressed: () {
                    openPage(context, const ProfileScreen());
                  },
                  icon: const Icon(Icons.account_circle_outlined),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
                  SizedBox(height: 12),
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

            const SizedBox(height: 24),

            const Text(
              'Mchat Services',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      openPage(context, const CoinsScreen());
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
        onTap: () {
          openPage(context, page);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
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

// ================= INBOX =================

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Free Inbox')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          inboxItem(context, 'Mchat Support', 'Welcome to Mchat'),
          inboxItem(context, 'New User', 'Start a conversation'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat screen coming next')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget inboxItem(
    BuildContext context,
    String name,
    String message,
  ) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(message),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening chat with $name')),
          );
        },
      ),
    );
  }
}

// ================= VOICE =================

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic,
              size: 90,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Voice Room',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Real voice service will be connected with backend.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Start Voice'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= LIVE =================

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Rooms')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          liveCard(context, 'Live Room 1'),
          liveCard(context, 'Live Room 2'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live streaming backend will be connected next.'),
            ),
          );
        },
        icon: const Icon(Icons.videocam),
        label: const Text('Go Live'),
      ),
    );
  }

  Widget liveCard(BuildContext context, String title) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.live_tv,
          size: 40,
          color: Colors.red,
        ),
        title: Text(title),
        subtitle: const Text('Live room'),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Join'),
        ),
      ),
    );
  }
}

// ================= VIP =================

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP Levels')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final level = index + 1;

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 35,
              ),
              title: Text('VIP $level'),
              subtitle: Text('VIP Level $level'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

// ================= COINS =================

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coins')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 90,
              color: Colors.amber,
            ),
            const SizedBox(height: 15),
            const Text(
              '0 Coins',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...[
              '100 Coins',
              '500 Coins',
              '1000 Coins',
              '5000 Coins',
            ].map(
              (amount) => Card(
                child: ListTile(
                  title: Text(amount),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Payment gateway will be connected next.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Recharge'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= GIFTS =================

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gifts')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          gift('Rose', Icons.local_florist),
          gift('Heart', Icons.favorite),
          gift('Star', Icons.star),
          gift('Crown', Icons.workspace_premium),
          gift('Gift Box', Icons.card_giftcard),
          gift('Diamond', Icons.diamond),
        ],
      ),
    );
  }

  Widget gift(String name, IconData icon) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= REFER =================

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people,
                size: 90,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Invite friends to
