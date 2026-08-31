// =====================================================
// PART 2
// CHAT ROOMS
// =====================================================

class BroadRoomScreen extends StatelessWidget {
  const BroadRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broad Rooms'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          roomCard(
            context,
            'Music Lovers',
            '1,258 online',
            Icons.music_note,
          ),
          roomCard(
            context,
            'Friends Chat',
            '876 online',
            Icons.people,
          ),
          roomCard(
            context,
            'Kannada Family',
            '542 online',
            Icons.language,
          ),
          roomCard(
            context,
            'Entertainment',
            '324 online',
            Icons.movie,
          ),
          roomCard(
            context,
            'Game Room',
            '218 online',
            Icons.sports_esports,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatRoomScreen(
                roomName: 'My Broad Room',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Room'),
      ),
    );
  }

  Widget roomCard(
    BuildContext context,
    String name,
    String users,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon, size: 28),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.circle,
              size: 10,
              color: Colors.green,
            ),
            const SizedBox(width: 5),
            Text(users),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  roomName: name,
                ),
              ),
            );
          },
          child: const Text('Join'),
        ),
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
        title: const Text('Family Rooms'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          familyCard(
            context,
            'Happy Family',
            'Family members only',
            Icons.home,
          ),
          familyCard(
            context,
            'Mchat Friends Family',
            'Private family room',
            Icons.family_restroom,
          ),
          familyCard(
            context,
            'Kannada Family',
            'Safe family chat',
            Icons.groups,
          ),
          familyCard(
            context,
            'VIP Family',
            'VIP family room',
            Icons.workspace_premium,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatRoomScreen(
                roomName: 'My Family Room',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Family'),
      ),
    );
  }

  Widget familyCard(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon, size: 28),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  roomName: name,
                ),
              ),
            );
          },
          child: const Text('Enter'),
        ),
      ),
    );
  }
}

// =====================================================
// CHAT ROOM
// =====================================================

class ChatRoomScreen extends StatefulWidget {
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomName,
  });

  @override
  State<ChatRoomScreen> createState() =>
      _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController =
      TextEditingController();

  bool micOn = false;

  final List<String> messages = [
    'Welcome to Mchat Room!',
    'Please respect each other.',
    'Have fun and enjoy the room!',
  ];

  final List<IconData> seatIcons = [
    Icons.person,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
    Icons.lock,
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(text);
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.power_settings_new),
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
                  Color(0xFF251638),
                  Color(0xFF120D1E),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Room owner
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mchat Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: 207022467',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),

                // Seats
                SizedBox(
                  height: 250,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 10,
                      childAspectRatio: .85,
                    ),
                    itemBuilder: (context, index) {
                      final occupied = index == 0;

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 29,
                            backgroundColor:
                                occupied
                                    ? Colors.deepPurple
                                    : Colors.white24,
                            child: Icon(
                              seatIcons[index],
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Text(
                          messages[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    8,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            micOn = !micOn;
                          });
                        },
                        icon: Icon(
                          micOn
                              ? Icons.mic
                              : Icons.mic_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.emoji_emotions,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.card_giftcard,
                          color: Colors.amber,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type message...',
                            hintStyle:
                                const TextStyle(
                              color: Colors.white60,
                            ),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(25),
                              borderSide:
                                  BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          onSubmitted: (_) =>
                              sendMessage(),
                        ),
                      ),
                      IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

// =====================================================
// VOICE SCREEN
// =====================================================

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Party'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 65,
              child: Icon(
                Icons.mic,
                size: 65,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voice Party',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Talk • Meet • Make Friends',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatRoomScreen(
                      roomName: 'Voice Party',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Enter Voice Room'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// LIVE SCREEN
// =====================================================

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Rooms'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          liveCard(
            context,
            'Live Room 1',
            '1.2K viewers',
          ),
          liveCard(
            context,
            'Music Live',
            '856 viewers',
          ),
          liveCard(
            context,
            'Friends Live',
            '428 viewers',
          ),
          liveCard(
            context,
            'Mchat Live',
            '216 viewers',
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Live streaming will connect to the real backend.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.videocam),
        label: const Text('Go Live'),
      ),
    );
  }

  Widget liveCard(
    BuildContext context,
    String title,
    String viewers,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(Icons.live_tv),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.circle,
              size: 9,
              color: Colors.red,
            ),
            const SizedBox(width: 5),
            Text(viewers),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  roomName: title,
                ),
              ),
            );
          },
          child: const Text('Join'),
        ),
      ),
    );
  }
}

// =====================================================
// PART 2 END
// =====================================================
