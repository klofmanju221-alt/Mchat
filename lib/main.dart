import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'login_screen.dart';

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
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: const AuthGate(),
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
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

        final User? user = snapshot.data;

        if (user == null) {
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
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Mchat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FeatureBanner(
                title: 'Mchat',
                subtitle: 'Connect • Chat • Live • Enjoy',
                icon: Icons.forum_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = services[i];
                  final title = item[0] as String;
                  final icon = item[1] as IconData;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      final pages = <String, Widget>{
                        'Free Inbox': const InboxScreen(),
                        'Private Chat': const PrivateChatScreen(),
                        'Family Room': const FamilyRoomScreen(),
                        'Room Mode & Games':
                            const RoomModeGamesScreen(),
                        'Room PK': const RoomPKScreen(),
                        'Live Ended & Replay':
                            const LiveEndedReplayScreen(),
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

                      final page = pages[title];

                      if (page != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => page),
                        );
                      }
                    },
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              child: Icon(icon, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: services.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON WIDGETS
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
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Icon(icon, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
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
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
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
          ],
        ),
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
    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
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
        child: FeatureBanner(
          title: title,
          subtitle: 'Feature ready',
          icon: icon,
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
      appBar: AppBar(title: const Text('Free Inbox')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Free Inbox',
            subtitle: 'Real-time chat space',
            icon: Icons.chat_bubble,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Mchat User'),
            subtitle: const Text('Hello 👋'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivateChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIVATE CHAT
// ============================================================

class PrivateChatScreen extends StatelessWidget {
  const PrivateChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Chat')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: FeatureBanner(
              title: 'Private Chat',
              subtitle: 'Protected private conversation',
              icon: Icons.lock,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Private chat messages will appear here'),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: null,
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

class PrivateChatRulesScreen extends StatelessWidget {
  const PrivateChatRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Rules')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RuleTile(
            icon: Icons.security,
            title: 'Privacy',
            subtitle: 'Respect private conversations.',
          ),
          RuleTile(
            icon: Icons.report_outlined,
            title: 'Report',
            subtitle: 'Report abusive behaviour.',
          ),
          RuleTile(
            icon: Icons.block,
            title: 'Block',
            subtitle: 'Block unwanted users.',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIVE
// ============================================================

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Room')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('End Live'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LiveEndedScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LiveEndedScreen extends StatelessWidget {
  const LiveEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Ended')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReplayPlayerScreen(),
                  ),
                );
              },
              child: const Text('Watch Replay'),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveEndedReplayScreen extends StatelessWidget {
  const LiveEndedReplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Ended & Replay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Live Ended',
            subtitle: 'Replay history',
            icon: Icons.history,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill, size: 40),
              title: const Text('Live Room Replay'),
              subtitle: const Text('Previous live session'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReplayPlayerScreen(),
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

class ReplayPlayerScreen extends StatelessWidget {
  const ReplayPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Replay Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.play_circle_outline, size: 100),
            SizedBox(height: 16),
            Text(
              'Replay Player',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FAMILY ROOM
// ============================================================

class FamilyRoomScreen extends StatefulWidget {
  const FamilyRoomScreen({super.key});

  @override
  State<FamilyRoomScreen> createState() => _FamilyRoomScreenState();
}

class _FamilyRoomScreenState extends State<FamilyRoomScreen> {
  final List<FamilySeat> seats = List.generate(
    30,
    (index) => FamilySeat(
      index: index,
      occupied: index == 0,
      name: index == 0 ? 'Host' : '',
      micOn: index == 0,
    ),
  );

  bool joined = false;
  bool micOn = true;
  bool roomLocked = false;

  int get occupiedCount =>
      seats.where((seat) => seat.occupied).length;

  void joinRoom() {
    setState(() {
      joined = true;
      final empty = seats.indexWhere((seat) => !seat.occupied);
      if (empty != -1) {
        seats[empty] = FamilySeat(
          index: empty,
          occupied: true,
          name: 'You',
          micOn: micOn,
        );
      }
    });
  }

  void leaveRoom() {
    setState(() {
      final me =
          seats.indexWhere((seat) => seat.name == 'You');
      if (me != -1) {
        seats[me] = FamilySeat(index: me);
      }
      joined = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Room'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => roomLocked = !roomLocked);
            },
            icon: Icon(
              roomLocked ? Icons.lock : Icons.lock_open,
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Room Rules',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Respect all members.\n'
                        'No abuse or spam.\n'
                        'Follow room rules.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Family Voice Room',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text('$occupiedCount/30'),
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
                mainAxisSpacing: 8,
                childAspectRatio: .82,
              ),
              itemBuilder: (context, index) {
                return FamilySeatWidget(
                  seat: seats[index],
                  onTap: () {},
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    onPressed: joined
                        ? () {
                            setState(() => micOn = !micOn);
                          }
                        : null,
                    icon: Icon(
                      micOn ? Icons.mic : Icons.mic_off,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const SizedBox(
                          height: 250,
                          child: Center(
                            child: Text('Room Chat'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const SizedBox(
                          height: 300,
                          child: Center(
                            child: Text('Gift Panel'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.card_giftcard),
                  ),
                  ElevatedButton(
                    onPressed:
                        roomLocked && !joined
                            ? null
                            : (joined
                                ? leaveRoom
                                : joinRoom),
                    child: Text(
                      joined ? 'Leave' : 'Join',
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
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                if (seat.occupied && seat.micOn)
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
              overflow: TextOverflow.ellipsis,
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

class RoomModeGamesScreen extends StatefulWidget {
  const RoomModeGamesScreen({super.key});

  @override
  State<RoomModeGamesScreen> createState() =>
      _RoomModeGamesScreenState();
}

class _RoomModeGamesScreenState
    extends State<RoomModeGamesScreen> {
  String mode = 'Normal';

  final modes = [
    'Normal',
    'Music',
    'Party',
    'Game',
    'Study',
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
            title: 'Room Mode',
            subtitle: 'Choose your room experience',
            icon: Icons.sports_esports,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modes.map((item) {
              return ChoiceChip(
                label: Text(item),
                selected: mode == item,
                onSelected: (_) {
                  setState(() => mode = item);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.casino),
              title: const Text('Lucky Wheel'),
              subtitle: const Text('Play Lucky Wheel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameDetailScreen(
                      title: 'Lucky Wheel',
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.casino_outlined),
              title: const Text('Dice'),
              subtitle: const Text('Play Dice Game'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameDetailScreen(
                      title: 'Dice',
                    ),
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

class GameDetailScreen extends StatelessWidget {
  final String title;

  const GameDetailScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, size: 90),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Game'),
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

class RoomPKScreen extends StatefulWidget {
  const RoomPKScreen({super.key});

  @override
  State<RoomPKScreen> createState() => _RoomPKScreenState();
}

class _RoomPKScreenState extends State<RoomPKScreen> {
  bool active = false;
  int scoreA = 0;
  int scoreB = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room PK')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const FeatureBanner(
              title: 'Room PK Battle',
              subtitle: 'Room A vs Room B',
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
            Text(
              active ? 'PK LIVE' : 'PK READY',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => active = !active);
              },
              icon: Icon(
                active ? Icons.stop : Icons.play_arrow,
              ),
              label: Text(
                active ? 'End PK' : 'Start PK',
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
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Send PK Gift'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VIP / COINS / GIFTS / REFER
// ============================================================

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'VIP Levels',
            subtitle: 'VIP 1 → VIP 10',
            icon: Icons.emoji_events,
          ),
          const SizedBox(height: 16),
          for (int i = 1; i <= 10; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('$i'),
                ),
                title: Text('VIP $i'),
                subtitle: i == 1
                    ? const Text('Starting from 1000')
                    : const Text('VIP benefits'),
              ),
            ),
        ],
      ),
    );
  }
}

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coins')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Coins',
            subtitle: 'Recharge and use coins',
            icon: Icons.monetization_on,
          ),
          const SizedBox(height: 16),
          for (final item in [
            '100 Coins',
            '500 Coins',
            '1000 Coins',
            '5000 Coins',
          ])
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.monetization_on,
                ),
                title: Text(item),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Recharge'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gifts')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          '🌹',
          '❤️',
          '🎁',
          '👑',
          '💎',
          '🚀',
          '🎉',
          '⭐',
          '🔥',
        ].map((gift) {
          return Card(
            child: Center(
              child: Text(
                gift,
                style: const TextStyle(fontSize: 38),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Refer & Earn',
            subtitle: 'Invite friends and earn rewards',
            icon: Icons.people,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Your Referral Code'),
              subtitle: const Text('MCHAT2026'),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Share Referral'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

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
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('Kannada'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Mchat'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.person, size: 48),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Mchat User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Coins'),
              trailing: Text(
                '0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('VIP Level'),
              trailing: Text(
                'VIP 1',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(
              Icons.admin_panel_settings,
            ),
            title: const Text(
              'Owner Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Protected owner access',
            ),
            trailing: const Icon(Icons.lock),
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BUILD #126 - OWNER DASHBOARD SECURITY
// ============================================================

class OwnerSecurityScreen extends StatefulWidget {
  const OwnerSecurityScreen({super.key});

  @override
  State<OwnerSecurityScreen> createState() =>
      _OwnerSecurityScreenState();
}

class _OwnerSecurityScreenState
    extends State<OwnerSecurityScreen> {
  final TextEditingController pinController =
      TextEditingController();

  bool obscurePin = true;
  bool biometricEnabled = false;
  bool autoLockEnabled = true;
  String? error;

  // Demo UI PIN only.
  // Production appನಲ್ಲಿ backend authentication ಬಳಸಬೇಕು.
  static const String demoPin = '1234';

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void verifyOwner() {
    final pin = pinController.text.trim();

    if (pin == demoPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OwnerDashboardScreen(),
        ),
      );
      return;
    }

    setState(() {
      error = 'Invalid Owner PIN';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
              ),
              child: Icon(
                Icons.admin_panel_settings,
                size: 55,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Owner Access Protected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Only authorized owner can access the dashboard.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock),
                      SizedBox(width: 10),
                      Text(
                        'Owner PIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: obscurePin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Enter Owner PIN',
                      hintText: 'PIN',
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          const Icon(Icons.password),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePin = !obscurePin;
                          });
                        },
                        icon: Icon(
                          obscurePin
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => verifyOwner(),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: verifyOwner,
                      icon: const Icon(Icons.lock_open),
                      label: const Text(
                        'Unlock Owner Dashboard',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: Column(
              children: [
                SwitchListTile(
                  value: biometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      biometricEnabled = value;
                    });
                  },
                  secondary: const Icon(
                    Icons.fingerprint,
                  ),
                  title: const Text(
                    'Biometric Unlock',
                  ),
                  subtitle: const Text(
                    'Fingerprint / Face unlock UI',
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: autoLockEnabled,
                  onChanged: (value) {
                    setState(() {
                      autoLockEnabled = value;
                    });
                  },
                  secondary: const Icon(
                    Icons.lock_clock,
                  ),
                  title: const Text(
                    'Auto Lock',
                  ),
                  subtitle: const Text(
                    'Lock dashboard after inactivity',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Security Status\n\n'
                      'Owner Dashboard is protected by an '
                      'access screen. Production deployment '
                      'should use secure backend authorization '
                      'and server-side access rules.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Build #126 • Owner Dashboard Security',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  static const management = [
    ['Users', Icons.people],
    ['Live Rooms', Icons.live_tv],
    ['Room PK', Icons.flash_on],
    ['Live Replays', Icons.history],
    ['Transactions', Icons.receipt_long],
    ['Recharges', Icons.add_card],
    ['Withdraw Requests', Icons.account_balance],
    ['VIP Management', Icons.emoji_events],
    ['Gifts', Icons.card_giftcard],
    ['Reports', Icons.flag],
    ['Content Management', Icons.edit_document],
    ['Settings', Icons.settings],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const OwnerSecurityScreen(),
                ),
              );
            },
            icon: const Icon(Icons.lock),
            tooltip: 'Lock',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FeatureBanner(
            title: 'Owner Dashboard',
            subtitle: 'Protected Management Center',
            icon: Icons.admin_panel_settings,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
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
                  title: 'Live',
                  value: '0',
                  icon: Icons.live_tv,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: SummaryCard(
                  title: 'Coins',
                  value: '0',
                  icon: Icons.monetization_on,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Reports',
                  value: '0',
                  icon: Icons.flag,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...management.map(
            (item) {
              final title = item[0] as String;
              final icon = item[1] as IconData;

              return Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(icon),
                  ),
                  title: Text(title),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OwnerFeatureScreen(
                          title: title,
                          icon: icon,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.verified_user),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Owner access verified for this session.',
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

// ============================================================
// BUILD #127 - LOCKED UI / FEATURES
// ============================================================

class OwnerFeatureScreen extends StatefulWidget {
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

  static const Set<String> lockedFeatures = {
    'Transactions',
    'Recharges',
    'Withdraw Requests',
    'VIP Management',
    'Gifts',
    'Reports',
    'Content Management',
    'Settings',
  };

  bool get isLocked =>
      lockedFeatures.contains(widget.title);

  void unlockFeature() {
    setState(() {
      unlocked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Feature unlocked for this session',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = isLocked && !unlocked;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (locked)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.lock),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Icon(
                      locked
                          ? Icons.lock
                          : widget.icon,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locked
                              ? 'Owner permission required'
                              : 'Owner access enabled',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (locked) ...[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Feature Locked',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This Owner feature is protected.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Additional owner permission is required '
                      'to access this section.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: unlockFeature,
                        icon: const Icon(
                          Icons.lock_open,
                        ),
                        label: const Text(
                          'Unlock Feature',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  Icons.shield_outlined,
                ),
                title: Text(
                  'Protected Feature',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Only authorized Owner access '
                  'should be allowed in production.',
                ),
              ),
            ),
          ] else ...[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 70,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Access Granted',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Owner feature is unlocked for '
                      'this session.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(widget.icon),
                    ),
                    title: Text(widget.title),
                    subtitle: const Text(
                      'Management UI ready',
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(
                      Icons.security,
                    ),
                    title: Text(
                      'Security Status',
                    ),
                    subtitle: Text(
                      'Owner access verified',
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  unlocked = false;
                });
              },
              icon: const Icon(Icons.lock),
              label: const Text(
                'Lock Feature',
              ),
            ),
          ],

          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Build #127 • Locked UI / Features',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
