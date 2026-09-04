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
            onPressed: () => setState(() => index = 3),
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
    ['Room PK', Icons.flash_on],
    ['Live Ended & Replay', Icons.history],
    ['Voice', Icons.mic_none],
    ['Live Room', Icons.live_tv_outlined],
    ['VIP', Icons.emoji_events_outlined],
    ['Coins', Icons.monetization_on_outlined],
    ['Gifts', Icons.card_giftcard_outlined],
    ['Refer & Earn', Icons.people_outline],
    ['Settings', Icons.settings_outlined],
  ];

  void open(BuildContext context, String name) {
    final pages = <String, Widget>{
      'Free Inbox': const InboxScreen(),
      'Private Chat': const PrivateChatScreen(),
      'Family Room': const FamilyRoomScreen(),
      'Room Mode & Games': const RoomModeGamesScreen(),
      'Room PK': const RoomPKScreen(),
      'Live Ended & Replay': const LiveEndedReplayScreen(),
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
      MaterialPageRoute(builder: (_) => pages[name]!),
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
                          fontSize: 16,
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
                onPressed: () => open(context, 'Coins'),
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
      appBar: AppBar(title: const Text('Free Inbox')),
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
                    itemBuilder: (_, i) => Align(
                      alignment: Alignment.centerRight,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(messages[i]),
                        ),
                      ),
                    ),
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

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final controller = TextEditingController();
  final messages = <String>[];

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
    setState(() => blocked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User blocked for this chat.')),
    );
  }

  void unblockUser() {
    setState(() => blocked = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User unblocked.')),
    );
  }

  void reportUser() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report User'),
        content: const Text(
          'Choose a reason to report this user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted for review.'),
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                setState(() => muted = !muted);
              }

              if (value == 'block') {
                blocked ? unblockUser() : blockUser();
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
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 70),
                        SizedBox(height: 15),
                        Text(
                          'This user is blocked.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                            Icon(Icons.lock_outline, size: 65),
                            SizedBox(height: 15),
                            Text(
                              'Private Conversation',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Send a message to start.'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Text(messages[i]),
                          ),
                        ),
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
                      icon: const Icon(Icons.shield_outlined),
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
                        onSubmitted: (_) => sendMessage(),
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
          const FeatureBanner(
            icon: Icons.security,
            title: 'Stay Safe in Private Chat',
            subtitle:
                'Protect your privacy and follow Mchat community rules.',
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
              onChanged: (v) =>
                  setState(() => allowMessages = v),
              secondary: const Icon(Icons.chat_outlined),
              title: const Text('Allow Private Messages'),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: allowRequests,
              onChanged: (v) =>
                  setState(() => allowRequests = v),
              secondary:
                  const Icon(Icons.person_add_outlined),
              title: const Text('Message Requests'),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: readReceipts,
              onChanged: (v) =>
                  setState(() => readReceipts = v),
              secondary: const Icon(Icons.done_all),
              title: const Text('Read Receipts'),
            ),
          ),
          Card(
            child: SwitchListTile(
              value: onlineStatus,
              onChanged: (v) =>
                  setState(() => onlineStatus = v),
              secondary:
                  const Icon(Icons.visibility_outlined),
              title: const Text('Online Status'),
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
          const RuleTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Respect Privacy',
            text:
                'Do not share another person’s private information without permission.',
          ),
          const RuleTile(
            icon: Icons.no_adult_content,
            title: 'No Harassment',
            text:
                'Do not threaten, bully, harass or repeatedly disturb other users.',
          ),
          const RuleTile(
            icon: Icons.link_off,
            title: 'Avoid Suspicious Links',
            text:
                'Do not send harmful, suspicious or misleading links.',
          ),
          const RuleTile(
            icon: Icons.password_outlined,
            title: 'Never Share Passwords',
            text:
                'Mchat support will never ask for your password or verification code.',
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   LIVE + LIVE ENDED
   ========================================================= */

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Room'),
        actions: [
          IconButton(
            tooltip: 'Replay',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LiveEndedReplayScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(25),
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
            child: const Column(
              children: [
                Icon(
                  Icons.live_tv,
                  size: 75,
                  color: Colors.white,
                ),
                SizedBox(height: 15),
                Text(
                  'Mchat Live Room',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Voice • Video • Gifts • Chat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
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
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('End Live & View Summary'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LiveEndedReplayScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('View Replays'),
          ),
        ],
      ),
    );
  }
}

class LiveEndedScreen extends StatelessWidget {
  const LiveEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Ended'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const FeatureBanner(
            icon: Icons.check_circle_outline,
            title: 'Your Live Has Ended',
            subtitle:
                'Your live session summary is ready.',
          ),
          const SizedBox(height: 20),
          const SummaryCard(
            icon: Icons.people_outline,
            title: 'Viewers',
            value: '128',
          ),
          const SummaryCard(
            icon: Icons.timer_outlined,
            title: 'Duration',
            value: '01:24:36',
          ),
          const SummaryCard(
            icon: Icons.favorite_outline,
            title: 'Likes',
            value: '2,450',
          ),
          const SummaryCard(
            icon: Icons.card_giftcard,
            title: 'Gifts',
            value: '86',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ReplayPlayerScreen(
                    title: 'My Live Replay',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_circle),
            label: const Text('Watch Replay'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Replay share UI is ready.'),
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Replay'),
          ),
        ],
      ),
    );
  }
}

class LiveEndedReplayScreen extends StatelessWidget {
  const LiveEndedReplayScreen({super.key});

  static const replays = [
    {
      'title': 'Evening Family Live',
      'date': 'Today • 7:30 PM',
      'duration': '01:24:36',
      'viewers': '128',
      'likes': '2.4K',
    },
    {
      'title': 'Music & Friends',
      'date': 'Yesterday • 9:10 PM',
      'duration': '00:58:21',
      'viewers': '94',
      'likes': '1.8K',
    },
    {
      'title': 'Mchat Party Room',
      'date': '28 Aug • 8:00 PM',
      'duration': '01:12:45',
      'viewers': '156',
      'likes': '3.1K',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Ended & Replay'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            icon: Icons.history,
            title: 'Live Replays',
            subtitle:
                'Watch, share and manage your completed live sessions.',
          ),
          const SizedBox(height: 22),
          const Text(
            'Your Replays',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...replays.map(
            (replay) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.all(14),
                leading: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 38,
                  ),
                ),
                title: Text(
                  replay['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Padding(
                  padding:
                      const EdgeInsets.only(top: 6),
                  child: Text(
                    '${replay['date']}\n'
                    'Duration: ${replay['duration']} • '
                    'Viewers: ${replay['viewers']} • '
                    'Likes: ${replay['likes']}',
                  ),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text('Delete UI is ready.'),
                        ),
                      );
                    }

                    if (value == 'share') {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text('Share UI is ready.'),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'share',
                      child: Text('Share'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReplayPlayerScreen(
                        title: replay['title']!,
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

class ReplayPlayerScreen extends StatelessWidget {
  final String title;

  const ReplayPlayerScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Replay shared.'),
                ),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6D28D9),
                    Color(0xFF4F46E5),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 85,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Expanded(
                child: SummaryCard(
                  icon: Icons.people_outline,
                  title: 'Viewers',
                  value: '128',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  icon: Icons.favorite_outline,
                  title: 'Likes',
                  value: '2.4K',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Replay player UI is ready. Real video storage and streaming playback will be connected in the backend phase.',
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
   FAMILY ROOM
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
    (i) => FamilySeat(
      number: i + 1,
      name: i == 0 ? 'Host' : '',
      occupied: i == 0,
      isHost: i == 0,
      micOn: i == 0,
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
          content: Text('This family room is locked.'),
        ),
      );
      return;
    }

    final seat =
        seats.indexWhere((s) => !s.occupied);

    if (seat == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All 30 seats are occupied.'),
        ),
      );
      return;
    }

    setState(() {
      seats[seat].occupied = true;
      seats[seat].name = 'You';
      seats[seat].micOn = micOn;
      joined = true;
    });
  }

  void leaveRoom() {
    final seat =
        seats.indexWhere((s) => s.name == 'You');

    if (seat != -1) {
      setState(() {
        seats[seat].occupied = false;
        seats[seat].name = '';
        seats[seat].micOn = false;
        joined = false;
      });
    }
  }

  void toggleMic() {
    setState(() => micOn = !micOn);

    final seat =
        seats.indexWhere((s) => s.name == 'You');

    if (seat != -1) {
      setState(() {
        seats[seat].micOn = micOn;
      });
    }
  }

  void showRules() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
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
            RuleTile(
              icon: Icons.favorite_outline,
              title: 'Respect',
              text: 'Respect every family member.',
            ),
            RuleTile(
              icon: Icons.block,
              title: 'No Abuse',
              text: 'No harassment, abuse or spam.',
            ),
            RuleTile(
              icon: Icons.security,
              title: 'Privacy',
              text: 'Do not share private information.',
            ),
          ],
        ),
      ),
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
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Room Gifts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              itemCount: gifts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) => Card(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content:
                            Text('${gifts[i]} sent to room.'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          MediaQuery.of(sheetContext)
                  .viewInsets
                  .bottom +
              16,
        ),
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              const Text(
                'Room Chat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Welcome to Family Room 👋\n\n'
                    'Room chat UI is ready.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type in room...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Room'),
        actions: [
          IconButton(
            onPressed: showRules,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() => roomLocked = !roomLocked);
            },
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
            margin:
                const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
                  radius: 29,
                  child: Icon(
                    Icons.groups_rounded,
                    size: 32,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '30 Seats • Voice • Chat • Gifts',
                        style: TextStyle(
                          color: Colors.white70,
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
                const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '$occupiedCount members',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (roomLocked)
                  const Chip(
                    label: Text('Locked'),
                    avatar: Icon(Icons.lock, size: 16),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 30,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: .78,
              ),
              itemBuilder: (_, i) {
                return FamilySeatWidget(
                  seat: seats[i],
                  onTap: () {},
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: toggleMic,
                    icon: Icon(
                      micOn ? Icons.mic : Icons.mic_off,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: showChat,
                    icon:
                        const Icon(Icons.chat_bubble_outline),
                  ),
                  IconButton.filledTonal(
                    onPressed: showGifts,
                    icon:
                        const Icon(Icons.card_giftcard),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          joined ? leaveRoom : joinRoom,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 24,
                  child: Icon(
                    seat.occupied
                        ? Icons.person
                        : Icons.add,
                  ),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Mode & Games'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            icon: Icons.sports_esports,
            title: 'Room Mode + Games',
            subtitle:
                'Choose a room style and enjoy games with your family.',
          ),
          const SizedBox(height: 22),
          const Text(
            'Room Mode',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...modes.map(
            (mode) {
              final name = mode[0] as String;
              final selected = selectedMode == name;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(mode[1] as IconData),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    setState(() => selectedMode = name);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Mini Games',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...games.map(
            (game) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(game[2] as IconData),
                ),
                title: Text(
                  game[0] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(game[1] as String),
                trailing:
                    const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameDetailScreen(
                        gameName: game[0] as String,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_esports,
                  size: 80,
                ),
                const SizedBox(height: 15),
                Text(
                  widget.gameName,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    result == 0 ? '?' : '$result',
                    style:
                        const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      result =
                          DateTime.now().millisecond % 6 + 1;
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Game'),
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
   ROOM PK
   ========================================================= */

class RoomPKScreen extends StatefulWidget {
  const RoomPKScreen({super.key});

  @override
  State<RoomPKScreen> createState() => _RoomPKScreenState();
}

class _RoomPKScreenState extends State<RoomPKScreen> {
  int leftScore = 72;
  int rightScore = 64;
  bool pkStarted = false;

  void startPK() {
    setState(() {
      pkStarted = !pkStarted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pkStarted
              ? 'Room PK started.'
              : 'Room PK ended.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room PK'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            icon: Icons.flash_on,
            title: 'Room PK Battle',
            subtitle:
                'Two rooms compete with points, gifts and support.',
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: PKTeamCard(
                  title: 'Room A',
                  score: leftScore,
                  icon: Icons.groups,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: PKTeamCard(
                  title: 'Room B',
                  score: rightScore,
                  icon: Icons.groups_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          LinearProgressIndicator(
            value:
                leftScore / (leftScore + rightScore),
            minHeight: 14,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: startPK,
            icon: Icon(
              pkStarted
                  ? Icons.stop
                  : Icons.play_arrow,
            ),
            label: Text(
              pkStarted
                  ? 'End PK'
                  : 'Start PK',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PK gift panel is ready.'),
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Send PK Gift'),
          ),
        ],
      ),
    );
  }
}

class PKTeamCard extends StatelessWidget {
  final String title;
  final int score;
  final IconData icon;

  const PKTeamCard({
    super.key,
    required this.title,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              child: Icon(icon, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Points'),
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
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events),
            title: Text('VIP ${i + 1}'),
            subtitle: Text('${coins[i]} Coins'),
            trailing:
                const Icon(Icons.chevron_right),
          ),
        ),
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
        itemBuilder: (_, i) => Card(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content:
                      Text('${gifts[i]} selected'),
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
        ),
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
          const FeatureBanner(
            icon: Icons.card_giftcard,
            title: 'Invite Your Friends',
            subtitle:
                'Earn 100 Coins for each friend',
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
          const SizedBox(height: 20),
          const StepTile(
            number: '1',
            text: 'Share your code',
            icon: Icons.share,
          ),
          const StepTile(
            number: '2',
            text: 'Friend joins Mchat',
            icon: Icons.person_add,
          ),
          const StepTile(
            number: '3',
            text: 'You both earn coins',
            icon: Icons.monetization_on,
          ),
        ],
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
            leading: const Icon(Icons.lock_outline),
            title:
                const Text('Private Chat Security'),
            subtitle:
                const Text('Privacy controls and chat rules'),
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
            subtitle:
                const Text('30 seats • Voice • Chat • Gifts'),
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
            leading:
                const Icon(Icons.sports_esports_outlined),
            title:
                const Text('Room Mode & Games'),
            subtitle:
                const Text('Room modes and mini games'),
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
            leading: const Icon(Icons.flash_on),
            title: const Text('Room PK'),
            subtitle:
                const Text('PK battle between rooms'),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPKScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title:
                const Text('Live Ended & Replay'),
            subtitle:
                const Text('Watch and manage live replays'),
            trailing:
                const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LiveEndedReplayScreen(),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Mchat'),
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
            icon:
                const Icon(Icons.settings_outlined),
          ),
        ],
      ),
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
                  BorderRadius.all(Radius.circular(28)),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 62,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Mchat User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ID: MCHAT001',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  ProfileStat(
                    value: '120',
                    label: 'Following',
                  ),
                  ProfileStat(
                    value: '2.5K',
                    label: 'Followers',
                  ),
                  ProfileStat(
                    value: '15.6K',
                    label: 'Likes',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ProfileMenu(
            icon: Icons.account_balance_wallet_outlined,
            title: 'My Wallet',
            subtitle: 'Coins & balance',
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
          ProfileMenu(
            icon: Icons.emoji_events_outlined,
            title: 'My Level',
            subtitle: 'VIP 2',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const VipScreen(),
                ),
              );
            },
          ),
          ProfileMenu(
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
          ProfileMenu(
            icon: Icons.flash_on,
            title: 'Room PK',
            subtitle: 'PK battle',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const RoomPKScreen(),
                ),
              );
            },
          ),
          ProfileMenu(
            icon: Icons.history,
            title: 'Live Replays',
            subtitle: 'Watch completed lives',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LiveEndedReplayScreen(),
                ),
              );
            },
          ),
          ProfileMenu(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Account & app settings',
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
      ['Live Replays', Icons.history],
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
        title: const Text('Owner Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            icon: Icons.admin_panel_settings,
            title: 'Welcome, Owner 👑',
            subtitle: 'Mchat Administration',
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Users',
                  value: '0',
                  icon: Icons.people,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: 'Recharges',
                  value: '₹0',
                  icon: Icons.currency_rupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Income',
                  value: '₹0',
                  icon: Icons.trending_up,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
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
              fontWeight: FontWeight.bold,
            ),
          ),
          ...items.map(
            (item) => Card(
              child: ListTile(
                leading:
                    Icon(item[1] as IconData),
                title: Text(item[0] as String),
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

/* =========================================================
   SHARED WIDGETS
   ========================================================= */

class FeatureBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8E35FF),
            Color(0xFF4F46E5),
          ],
        ),
        borderRadius:
            BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
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
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
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

class RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const RuleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(text),
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  final String number;
  final String text;
  final IconData icon;

  const StepTile({
    super.key,
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
        title: Text(text),
        trailing: Icon(icon),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStat({
    super.key,
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
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenu({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(icon, size: 90),
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
