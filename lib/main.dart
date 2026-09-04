import 'package:flutter/material.dart';

void main() {
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

/* =========================================================
   MAIN HOME
   ========================================================= */

class MchatHomePage extends StatefulWidget {
  const MchatHomePage({super.key});

  @override
  State<MchatHomePage> createState() => _MchatHomePageState();
}

class _MchatHomePageState extends State<MchatHomePage> {
  int index = 0;

  final pages = const [
    HomeContent(),
    InboxScreen(),
    LiveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mchat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications UI ready.'),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              setState(() => index = 3);
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
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

/* =========================================================
   HOME
   ========================================================= */

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static const services = [
    ['Free Inbox', Icons.chat_bubble_outline],
    ['Private Chat', Icons.lock_outline],
    ['Family Room', Icons.groups_rounded],
    ['Room Mode & Games', Icons.sports_esports_outlined],
    ['Room PK', Icons.flash_on_rounded],
    ['Voice', Icons.mic_none],
    ['Live Room', Icons.live_tv_outlined],
    ['VIP', Icons.emoji_events_outlined],
    ['Coins', Icons.monetization_on_outlined],
    ['Gifts', Icons.card_giftcard_outlined],
    ['Refer & Earn', Icons.people_outline],
    ['Settings', Icons.settings_outlined],
  ];

  void open(BuildContext context, String name) {
    final Map<String, Widget> pages = {
      'Free Inbox': const InboxScreen(),
      'Private Chat': const PrivateChatScreen(),
      'Family Room': const FamilyRoomScreen(),
      'Room Mode & Games': const RoomModeGamesScreen(),
      'Room PK': const RoomPkScreen(),
      'Voice': const FeatureScreen(
        title: 'Voice',
        icon: Icons.mic,
      ),
      'Live Room': const LiveScreen(),
      'VIP': const VipScreen(),
      'Coins': const CoinsScreen(),
      'Gifts': const GiftsScreen(),
      'Refer & Earn': const ReferEarnScreen(),
      'Settings': const SettingsScreen(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => pages[name]!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(28),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Mchat 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
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
          const SizedBox(height: 28),
          const Text(
            'Mchat Services',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, i) {
              final service = services[i];

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    open(context, service[0] as String);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        service[1] as IconData,
                        size: 48,
                        color: const Color(0xFF6D4C8F),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service[0] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.monetization_on),
              ),
              title: const Text(
                'My Coins',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                '0 Coins',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: FilledButton(
                onPressed: () {
                  open(context, 'Coins');
                },
                child: const Text('Recharge'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   FREE INBOX
   ========================================================= */

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxState();
}

class _InboxState extends State<InboxScreen> {
  final controller = TextEditingController();
  final messages = <String>[];

  void send() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(text);
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Inbox'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nType a message below.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(messages[i]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: send,
                    icon: const Icon(Icons.send),
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

/* =========================================================
   PRIVATE CHAT
   ========================================================= */

class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({super.key});

  @override
  State<PrivateChatScreen> createState() =>
      _PrivateChatScreenState();
}

class _PrivateChatScreenState
    extends State<PrivateChatScreen> {
  final controller = TextEditingController();
  final List<String> messages = [];

  bool muted = false;
  bool blocked = false;

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty || blocked) return;

    setState(() {
      messages.add(text);
      controller.clear();
    });
  }

  void showRules() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivateChatRulesScreen(),
      ),
    );
  }

  void blockUser() {
    setState(() {
      blocked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User blocked for this chat.'),
      ),
    );
  }

  void unblockUser() {
    setState(() {
      blocked = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User unblocked.'),
      ),
    );
  }

  void reportUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report User'),
          content: const Text(
            'Choose a reason to report this user.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Report submitted for review.',
                    ),
                  ),
                );
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              child: Icon(Icons.person),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat User',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Private Chat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rules') showRules();

              if (value == 'mute') {
                setState(() {
                  muted = !muted;
                });
              }

              if (value == 'block') {
                if (blocked) {
                  unblockUser();
                } else {
                  blockUser();
                }
              }

              if (value == 'report') reportUser();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'rules',
                child: Row(
                  children: [
                    Icon(Icons.security),
                    SizedBox(width: 10),
                    Text('Security & Rules'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(
                      muted
                          ? Icons.notifications
                          : Icons.notifications_off,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      muted
                          ? 'Unmute Notifications'
                          : 'Mute Notifications',
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      blocked
                          ? Icons.lock_open
                          : Icons.block,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      blocked
                          ? 'Unblock User'
                          : 'Block User',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined),
                    SizedBox(width: 10),
                    Text('Report User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              4,
            ),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Private chat • Respect privacy and community rules.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: blocked
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'This user is blocked.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Unblock the user to continue chatting.',
                        ),
                      ],
                    ),
                  )
                : messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 65,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Private Conversation',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Send a message to start.',
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, index) {
                          return Align(
                            alignment:
                                Alignment.centerRight,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 10,
                              ),
                              padding:
                                  const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                              child: Text(
                                messages[index],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (!blocked)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: showRules,
                      icon: const Icon(
                        Icons.shield_outlined,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Private message...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                          ),
                        ),
                        onSubmitted: (_) =>
                            sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
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

/* =========================================================
   PRIVATE CHAT RULES
   ========================================================= */

class PrivateChatRulesScreen extends StatefulWidget {
  const PrivateChatRulesScreen({super.key});

  @override
  State<PrivateChatRulesScreen> createState() =>
      _PrivateChatRulesScreenState();
}

class _PrivateChatRulesScreenState
    extends State<PrivateChatRulesScreen> {
  bool allowMessages = true;
  bool allowRequests = true;
  bool readReceipts = true;
  bool onlineStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Chat Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 52,
                ),
                SizedBox(height: 12),
                Text(
                  'Stay Safe in Private Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Protect your privacy and follow Mchat community rules.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Privacy Controls',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Card(
            child: SwitchListTile(
              value: allowMessages,
              onChanged: (v) {
                setState(() => allowMessages = v);
              },
              secondary:
                  const Icon(Icons.chat_outlined),
              title: const Text('Allow Private Messages'),
              subtitle: const Text(
                'Allow other users to send you private messages.',
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: allowRequests,
              onChanged: (v) {
                setState(() => allowRequests = v);
              },
              secondary:
                  const Icon(Icons.person_add_outlined),
              title: const Text('Message Requests'),
              subtitle: const Text(
                'Allow private chat requests from other users.',
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: readReceipts,
              onChanged: (v) {
                setState(() => readReceipts = v);
              },
              secondary: const Icon(Icons.done_all),
              title: const Text('Read Receipts'),
              subtitle: const Text(
                'Show when messages have been read.',
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: onlineStatus,
              onChanged: (v) {
                setState(() => onlineStatus = v);
              },
              secondary:
                  const Icon(Icons.visibility_outlined),
              title: const Text('Online Status'),
              subtitle: const Text(
                'Show your online status to other users.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chat Safety Rules',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const _RuleTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Respect Privacy',
            text:
                'Do not share another person’s private information without permission.',
          ),
          const _RuleTile(
            icon: Icons.no_adult_content,
            title: 'No Harassment',
            text:
                'Do not threaten, bully, harass or repeatedly disturb other users.',
          ),
          const _RuleTile(
            icon: Icons.link_off,
            title: 'Avoid Suspicious Links',
            text:
                'Do not send harmful, suspicious or misleading links.',
          ),
          const _RuleTile(
            icon: Icons.password_outlined,
            title: 'Never Share Passwords',
            text:
                'Mchat support will never ask for your password or verification code.',
          ),
          const _RuleTile(
            icon: Icons.report_outlined,
            title: 'Report Problems',
            text:
                'Use Report User when you see abuse, scams or rule violations.',
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _RuleTile({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(text),
      ),
    );
  }
}

/* =========================================================
   LIVE
   ========================================================= */

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScreen(
      title: 'Live Room',
      icon: Icons.live_tv,
    );
  }
}

/* =========================================================
   GENERIC FEATURE
   ========================================================= */

class FeatureScreen extends StatelessWidget {
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
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color: const Color(0xFF6D4C8F),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('$title screen is ready.'),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
   VIP
   ========================================================= */

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const coins = [
      1000,
      3000,
      6000,
      10000,
      20000,
      30000,
      50000,
      80000,
      120000,
      200000,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('VIP Center')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, i) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text('VIP ${i + 1}'),
              subtitle: Text('${coins[i]} Coins'),
              trailing:
                  const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

/* =========================================================
   COINS
   ========================================================= */

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coins')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 70,
                ),
                const Text(
                  'My Coins',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Recharge backend will be connected next.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Recharge'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================================================
   GIFTS
   ========================================================= */

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gifts = [
      'Rose',
      'Heart',
      'Lollipop',
      'Coffee',
      'Teddy',
      'Diamond',
      'Car',
      'Castle',
      'Lion',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gifts')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${gifts[i]} selected',
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 38,
                  ),
                  const SizedBox(height: 8),
                  Text(gifts[i]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* =========================================================
   REFER & EARN
   ========================================================= */

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(26)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 70,
                  color: Colors.white,
                ),
                SizedBox(height: 14),
                Text(
                  'Invite Your Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Earn 100 Coins for each friend',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'MCHAT123',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Referral code copied.'),
                            ),
                          );
                        },
                        child: const Text('Copy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Share feature UI is ready.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'How it works?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const _StepTile(
            number: '1',
            text: 'Share your code',
            icon: Icons.share,
          ),
          const _StepTile(
            number: '2',
            text: 'Friend joins Mchat',
            icon: Icons.person_add,
          ),
          const _StepTile(
            number: '3',
            text: 'You both earn coins',
            icon: Icons.monetization_on,
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String text;
  final IconData icon;

  const _StepTile({
    required this.number,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(number),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(icon),
      ),
    );
  }
}

/* =========================================================
   SETTINGS
   ========================================================= */

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Notifications'),
            secondary:
                const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing:
                const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading:
                const Icon(Icons.lock_outline),
            title:
                const Text('Private Chat Security'),
            subtitle: const Text(
              'Privacy controls and chat rules',
            ),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivateChatRulesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.groups_rounded),
            title: const Text('Family Room'),
            subtitle: const Text(
              '30 seats • Voice • Chat • Gifts',
            ),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FamilyRoomScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.sports_esports_outlined,
            ),
            title:
                const Text('Room Mode & Games'),
            subtitle: const Text(
              'Room modes and mini games',
            ),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomModeGamesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.flash_on_rounded,
            ),
            title: const Text('Room PK'),
            subtitle: const Text(
              'PK battle between room hosts',
            ),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPkScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.info_outline),
            title: const Text('About Mchat'),
            trailing:
                const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   PROFILE
   ========================================================= */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(28)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 62,
                    color: Color(0xFF6D4C8F),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mchat User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'ID: MCHAT001',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    showMessage(
                      context,
                      'Edit Profile UI is ready.',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 8,
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                      value: '120',
                      label: 'Following',
                    ),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      value: '2.5K',
                      label: 'Followers',
                    ),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      value: '15.6K',
                      label: 'Likes',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'My Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _ProfileMenuTile(
            icon:
                Icons.account_balance_wallet_outlined,
            title: 'My Wallet',
            subtitle: 'Coins & balance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CoinsScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.emoji_events_outlined,
            title: 'My Level',
            subtitle: 'VIP 2',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VipScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.meeting_room_outlined,
            title: 'My Rooms',
            subtitle: 'Your live rooms',
            onTap: () {
              showMessage(
                context,
                'My Rooms UI is ready.',
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.lock_outline,
            title: 'Private Chat Security',
            subtitle: 'Privacy & chat rules',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivateChatRulesScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.groups_rounded,
            title: 'Family Room',
            subtitle:
                '30 seats • Voice • Chat • Gifts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FamilyRoomScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon:
                Icons.sports_esports_outlined,
            title: 'Room Mode & Games',
            subtitle:
                'Modes and mini games',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomModeGamesScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.flash_on_rounded,
            title: 'Room PK',
            subtitle: 'PK battle',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPkScreen(),
                ),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle:
                'Account & app settings',
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
          const SizedBox(height: 20),
          const Text(
            'Owner',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.admin_panel_settings,
                ),
              ),
              title: const Text(
                'Owner Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text('Development access'),
              trailing:
                  const Icon(Icons.chevron_right),
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
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/* =========================================================
   OWNER DASHBOARD
   ========================================================= */

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ['Users', Icons.people],
      ['Live Rooms', Icons.live_tv],
      ['Room PK', Icons.flash_on],
      ['Transactions', Icons.receipt_long],
      ['Recharges', Icons.account_balance_wallet],
      ['Withdraw Requests', Icons.payments],
      ['VIP Management', Icons.emoji_events],
      ['Gifts', Icons.card_giftcard],
      ['Reports', Icons.bar_chart],
      ['Content Management', Icons.article],
      ['Settings', Icons.settings],
    ];

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Owner Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(22)),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Owner 👑',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mchat Administration',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  'Users',
                  '0',
                  Icons.people,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  'Recharges',
                  '₹0',
                  Icons.currency_rupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  'Income',
                  '₹0',
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  'Withdrawn',
                  '₹0',
                  Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...items.map(
            (item) => Card(
              child: ListTile(
                leading:
                    Icon(item[1] as IconData),
                title:
                    Text(item[0] as String),
                trailing:
                    const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item[0]} section selected',
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

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard(
    this.title,
    this.value,
    this.icon, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 6),
            Text(title),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
   FAMILY ROOM - 30 SEATS
   ========================================================= */

class FamilyRoomScreen extends StatefulWidget {
  const FamilyRoomScreen({super.key});

  @override
  State<FamilyRoomScreen> createState() =>
      _FamilyRoomScreenState();
}

class _FamilyRoomScreenState
    extends State<FamilyRoomScreen> {
  late final List<FamilySeat> seats =
      List.generate(
    30,
    (index) => FamilySeat(
      number: index + 1,
      name: index == 0 ? 'Host' : '',
      occupied: index == 0,
      isHost: index == 0,
      micOn: index == 0,
    ),
  );

  bool joined = false;
  bool micOn = true;
  bool roomLocked = false;

  int get occupiedCount =>
      seats.where((s) => s.occupied).length;

  void joinRoom() {
    if (roomLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This family room is locked.',
          ),
        ),
      );
      return;
    }

    final emptySeat =
        seats.indexWhere((s) => !s.occupied);

    if (emptySeat == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All 30 seats are occupied.',
          ),
        ),
      );
      return;
    }

    setState(() {
      seats[emptySeat].occupied = true;
      seats[emptySeat].name = 'You';
      seats[emptySeat].micOn = micOn;
      joined = true;
    });
  }

  void leaveRoom() {
    final mySeat =
        seats.indexWhere((s) => s.name == 'You');

    if (mySeat != -1) {
      setState(() {
        seats[mySeat].occupied = false;
        seats[mySeat].name = '';
        seats[mySeat].micOn = false;
        joined = false;
      });
    }
  }

  void toggleMic() {
    setState(() {
      micOn = !micOn;
    });

    final mySeat =
        seats.indexWhere((s) => s.name == 'You');

    if (mySeat != -1) {
      seats[mySeat].micOn = micOn;
    }
  }

  void toggleRoomLock() {
    setState(() {
      roomLocked = !roomLocked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          roomLocked
              ? 'Family Room locked.'
              : 'Family Room unlocked.',
        ),
      ),
    );
  }

  void showRules() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Family Room Rules',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              FamilyRule(
                icon: Icons.favorite_outline,
                text:
                    'Respect every family member.',
              ),
              FamilyRule(
                icon: Icons.block,
                text:
                    'No harassment, abuse or spam.',
              ),
              FamilyRule(
                icon: Icons.security,
                text:
                    'Do not share private information.',
              ),
              FamilyRule(
                icon: Icons.mic_off_outlined,
                text:
                    'Use the microphone responsibly.',
              ),
            ],
          ),
        );
      },
    );
  }

  void showGifts() {
    const gifts = [
      '🌹 Rose',
      '❤️ Heart',
      '🎁 Gift',
      '☕ Coffee',
      '🧸 Teddy',
      '💎 Diamond',
      '🦁 Lion',
      '🏰 Castle',
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Room Gifts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                itemCount: gifts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              '${gifts[i]} sent to the room.',
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          gifts[i],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSeatOptions(FamilySeat seat) {
    if (!seat.occupied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Seat ${seat.number} is available.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  seat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text('Seat ${seat.number}'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.card_giftcard),
                title: const Text('Send Gift'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showGifts();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.flag_outlined),
                title:
                    const Text('Report User'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text('Report submitted for review.'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showRoomChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom:
                MediaQuery.of(sheetContext)
                        .viewInsets
                        .bottom +
                    16,
          ),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                const Text(
                  'Room Chat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Welcome to the Family Room 👋\n\n'
                      'Room chat UI is ready.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type in room...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Room message sent.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Family Room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomModeGamesScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.sports_esports_outlined,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPkScreen(),
                ),
              );
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: showRules,
            icon:
                const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: toggleRoomLock,
            icon: Icon(
              roomLocked
                  ? Icons.lock
                  : Icons.lock_open,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              8,
            ),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(24)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.groups_rounded,
                    size: 34,
                    color: Color(0xFF6D4C8F),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mchat Family Room',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '30 Seats • Voice • Chat • Gifts',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$occupiedCount/30',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline),
                const SizedBox(width: 8),
                Text(
                  '$occupiedCount members in room',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (roomLocked)
                  const Chip(
                    avatar: Icon(
                      Icons.lock,
                      size: 16,
                    ),
                    label: Text('Locked'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              itemCount: 30,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, index) {
                return FamilySeatWidget(
                  seat: seats[index],
                  onTap: () {
                    showSeatOptions(seats[index]);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                6,
                10,
                10,
              ),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: toggleMic,
                    icon: Icon(
                      micOn
                          ? Icons.mic
                          : Icons.mic_off,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton.filledTonal(
                    onPressed: showRoomChat,
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton.filledTonal(
                    onPressed: showGifts,
                    icon: const Icon(
                      Icons.card_giftcard,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: joined
                          ? leaveRoom
                          : joinRoom,
                      icon: Icon(
                        joined
                            ? Icons.logout
                            : Icons.login,
                      ),
                      label: Text(
                        joined
                            ? 'Leave Room'
                            : 'Join Room',
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
}

class FamilySeat {
  final int number;
  String name;
  bool occupied;
  bool isHost;
  bool micOn;

  FamilySeat({
    required this.number,
    required this.name,
    required this.occupied,
    required this.isHost,
    required this.micOn,
  });
}

class FamilySeatWidget extends StatelessWidget {
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 25,
                      child: Icon(
                        seat.occupied
                            ? Icons.person
                            : Icons.add,
                        size: 27,
                      ),
                    ),
                  ),
                ),
                if (seat.isHost)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HOST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (seat.occupied)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Icon(
                      seat.micOn
                          ? Icons.mic
                          : Icons.mic_off,
                      size: 15,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            seat.occupied
                ? seat.name
                : 'Seat ${seat.number}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyRule extends StatelessWidget {
  final IconData icon;
  final String text;

  const FamilyRule({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Icon(icon, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   ROOM MODE + GAMES
   ========================================================= */

class RoomModeGamesScreen extends StatefulWidget {
  const RoomModeGamesScreen({super.key});

  @override
  State<RoomModeGamesScreen> createState() =>
      _RoomModeGamesScreenState();
}

class _RoomModeGamesScreenState
    extends State<RoomModeGamesScreen> {
  String selectedMode = 'Normal';

  final modes = const [
    ['Normal', Icons.groups_rounded],
    ['Music', Icons.music_note],
    ['Party', Icons.celebration],
    ['Game', Icons.sports_esports],
    ['Study', Icons.menu_book],
  ];

  final games = const [
    [
      'Lucky Wheel',
      'Spin and win a random reward',
      Icons.casino,
    ],
    [
      'Dice',
      'Roll the dice with room members',
      Icons.casino_outlined,
    ],
    [
      'Quick Quiz',
      'Answer questions with friends',
      Icons.quiz_outlined,
    ],
    [
      'Truth or Dare',
      'Fun group challenge',
      Icons.question_mark,
    ],
  ];

  void selectMode(String mode) {
    setState(() {
      selectedMode = mode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$mode Room Mode selected.',
        ),
      ),
    );
  }

  void openGame(
    BuildContext context,
    String game,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(
          gameName: game,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Room Mode & Games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPkScreen(),
                ),
              );
            },
            icon: const Icon(Icons.flash_on),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(24)),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sports_esports,
                  color: Colors.white,
                  size: 52,
                ),
                SizedBox(height: 12),
                Text(
                  'Room Mode + Games',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Choose a room style and enjoy games with your family.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Room Mode',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...modes.map(
            (mode) {
              final name = mode[0] as String;
              final icon = mode[1] as IconData;
              final selected =
                  selectedMode == name;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(icon),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '$name room mode',
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_circle,
                        )
                      : const Icon(
                          Icons.chevron_right,
                        ),
                  onTap: () {
                    selectMode(name);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.check_circle,
              ),
              title: const Text(
                'Selected Room Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                selectedMode,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mini Games',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...games.map(
            (game) {
              final name = game[0] as String;
              final description =
                  game[1] as String;
              final icon = game[2] as IconData;

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 27,
                    child: Icon(icon, size: 28),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 5),
                    child: Text(description),
                  ),
                  trailing: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  onTap: () {
                    openGame(context, name);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Room modes and games are currently UI-ready. '
                      'Real-time multiplayer game logic, room synchronization '
                      'and server validation will be connected in the backend phase.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
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
}

/* =========================================================
   GAME DETAIL
   ========================================================= */

class GameDetailScreen extends StatefulWidget {
  final String gameName;

  const GameDetailScreen({
    super.key,
    required this.gameName,
  });

  @override
  State<GameDetailScreen> createState() =>
      _GameDetailScreenState();
}

class _GameDetailScreenState
    extends State<GameDetailScreen> {
  int result = 0;

  void playGame() {
    setState(() {
      result =
          DateTime.now().millisecond % 6 + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.gameName} played.',
        ),
      ),
    );
  }

  IconData get gameIcon {
    switch (widget.gameName) {
      case 'Lucky Wheel':
        return Icons.casino;
      case 'Dice':
        return Icons.casino_outlined;
      case 'Quick Quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.question_mark;
    }
  }

  String get description {
    switch (widget.gameName) {
      case 'Lucky Wheel':
        return 'Spin the wheel and see your lucky result.';
      case 'Dice':
        return 'Roll a virtual dice with your room members.';
      case 'Quick Quiz':
        return 'Answer quick questions and challenge your friends.';
      default:
        return 'Choose truth or dare and have fun with the room.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(28)),
            ),
            child: Column(
              children: [
                Icon(
                  gameIcon,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.gameName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Game Result',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  CircleAvatar(
                    radius: 45,
                    child: Text(
                      result == 0
                          ? '?'
                          : '$result',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: playGame,
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'Play Game',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(Icons.groups_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Multiplayer room synchronization will be connected during the real-time backend phase.',
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

/* =========================================================
   BUILD #124
   ROOM PK
   ========================================================= */

class RoomPkScreen extends StatelessWidget {
  const RoomPkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Room PK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E35FF),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius:
                  BorderRadius.all(
                Radius.circular(26),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 65,
                ),
                SizedBox(height: 12),
                Text(
                  'ROOM PK BATTLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Challenge another room and compete together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Choose PK Mode',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PkModeTile(
            icon: Icons.person,
            title: '1 vs 1 PK',
            subtitle:
                'Two hosts compete in a direct PK battle.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PkBattleScreen(
                    mode: '1 vs 1 PK',
                  ),
                ),
              );
            },
          ),
          _PkModeTile(
            icon: Icons.groups,
            title: 'Team PK',
            subtitle:
                'Family members support their room host.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PkBattleScreen(
                    mode: 'Team PK',
                  ),
                ),
              );
            },
          ),
          _PkModeTile(
            icon: Icons.flash_on,
            title: 'Quick PK',
            subtitle:
                'Start a short competitive room battle.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PkBattleScreen(
                    mode: 'Quick PK',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PK UI is ready. Real-time room matching, '
                      'live scores, gifts, timers and server-side '
                      'validation will be connected in the backend phase.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
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
}

class _PkModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PkModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 27,
          child: Icon(icon, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing:
            const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/* =========================================================
   PK BATTLE
   ========================================================= */

class PkBattleScreen extends StatefulWidget {
  final String mode;

  const PkBattleScreen({
    super.key,
    required this.mode,
  });

  @override
  State<PkBattleScreen> createState() =>
      _PkBattleScreenState();
}

class _PkBattleScreenState
    extends State<PkBattleScreen> {
  int leftScore = 0;
  int rightScore = 0;
  int seconds = 60;
  bool started = false;

  void startPk() {
    setState(() {
      started = true;
      seconds = 60;
      leftScore = 0;
      rightScore = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'PK Battle started.',
        ),
      ),
    );
  }

  void sendGiftToLeft() {
    if (!started) return;

    setState(() {
      leftScore += 100;
    });
  }

  void sendGiftToRight() {
    if (!started) return;

    setState(() {
      rightScore += 100;
    });
  }

  void endPk() {
    setState(() {
      started = false;
    });

    final winner = leftScore == rightScore
        ? 'Draw'
        : leftScore > rightScore
            ? 'Room A Wins'
            : 'Room B Wins';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'PK Result',
          ),
          content: Text(
            '$winner\n\n'
            'Room A: $leftScore points\n'
            'Room B: $rightScore points',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (started)
            IconButton(
              onPressed: endPk,
              icon: const Icon(
                Icons.stop_circle_outlined,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Text(
                  'PK BATTLE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  started
                      ? 'Battle in progress'
                      : 'Ready to start',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _PkScoreCard(
                        roomName: 'ROOM A',
                        score: leftScore,
                        icon: Icons.groups,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _PkScoreCard(
                        roomName: 'ROOM B',
                        score: rightScore,
                        icon: Icons.groups,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: (leftScore +
                              rightScore) ==
                          0
                      ? 0
                      : leftScore /
                          (leftScore +
                              rightScore),
                ),
                const SizedBox(height: 18),
                Text(
                  started
                      ? 'Time: $seconds sec'
                      : 'Time: 60 sec',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'PK Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      started
                          ? sendGiftToLeft
                          : null,
                  icon: const Icon(
                    Icons.card_giftcard,
                  ),
                  label: const Text(
                    'Gift Room A',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      started
                          ? sendGiftToRight
                          : null,
                  icon: const Icon(
                    Icons.card_giftcard,
                  ),
                  label: const Text(
                    'Gift Room B',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  started ? endPk : startPk,
              icon: Icon(
                started
                    ? Icons.stop
                    : Icons.play_arrow,
              ),
              label: Text(
                started
                    ? 'End PK Battle'
                    : 'Start PK Battle',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is the PK UI foundation. '
                      'Live multiplayer synchronization, '
                      'real gifts, coin deduction, timers '
                      'and anti-cheat validation require backend integration.',
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

class _PkScoreCard extends StatelessWidget {
  final String roomName;
  final int score;
  final IconData icon;

  const _PkScoreCard({
    required this.roomName,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              roomName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Points',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
