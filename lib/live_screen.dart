import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'agora_live_room_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CREATE LIVE ROOM
  // ============================================================

  Future<void> _createRoom() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showMessage('Please login first.');
      return;
    }

    final controller = TextEditingController();

    final roomName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Live Room'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Room Name',
              hintText: 'Enter room name',
              prefixIcon: Icon(Icons.meeting_room),
              border: OutlineInputBorder(),
            ),
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
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(context, name);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (roomName == null || roomName.trim().isEmpty) {
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      final hostName =
          (userData['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString();

      final mchatId =
          (userData['mchatId'] ?? '').toString();

      final roomRef =
          _firestore.collection('rooms').doc();

      await roomRef.set({
        'roomId': roomRef.id,
        'roomName': roomName.trim(),
        'hostUid': user.uid,
        'hostName': hostName,
        'hostMchatId': mchatId,
        'status': 'live',
        'viewerCount': 0,
        'roomType': 'public',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // IMPORTANT:
      // Room information is now passed to Agora screen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgoraLiveRoomScreen(
            roomName: roomName.trim(),
            isHost: true,
            roomId: roomRef.id,
            hostUid: user.uid,
            hostName: hostName,
          ),
        ),
      );
    } catch (e) {
      _showMessage(
        'Could not create live room.',
      );
    }
  }

  // ============================================================
  // JOIN LIVE ROOM
  // ============================================================

  Future<void> _joinRoom({
    required String roomId,
    required String roomName,
    required String hostUid,
    required String hostName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      _showMessage('Please login first.');
      return;
    }

    final isHost = user.uid == hostUid;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgoraLiveRoomScreen(
          roomName: roomName,
          isHost: isHost,
          roomId: roomId,
          hostUid: hostUid,
          hostName: hostName,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Rooms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _createRoom,
            icon: const Icon(
              Icons.add_circle,
            ),
            tooltip: 'Create Room',
          ),
        ],
      ),

      // ========================================================
      // LIVE ROOM LIST
      // ========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('rooms')
            .where(
              'status',
              isEqualTo: 'live',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load live rooms.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final rooms =
              snapshot.data?.docs ?? [];

          if (rooms.isEmpty) {
            return _EmptyLiveRooms(
              onCreateRoom: _createRoom,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final doc = rooms[index];

                final data = doc.data();

                final roomId =
                    (data['roomId'] ??
                            doc.id)
                        .toString();

                final roomName =
                    (data['roomName'] ??
                            'Live Room')
                        .toString();

                final hostName =
                    (data['hostName'] ??
                            'Mchat User')
                        .toString();

                final hostUid =
                    (data['hostUid'] ??
                            '')
                        .toString();

                final viewerCount =
                    _toInt(
                  data['viewerCount'],
                );

                return _LiveRoomCard(
                  roomName: roomName,
                  hostName: hostName,
                  viewerCount: viewerCount,
                  onTap: () {
                    _joinRoom(
                      roomId: roomId,
                      roomName: roomName,
                      hostUid: hostUid,
                      hostName: hostName,
                    );
                  },
                );
              },
            ),
          );
        },
      ),

      // ========================================================
      // GO LIVE BUTTON
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _createRoom,
        icon: const Icon(
          Icons.videocam,
        ),
        label: const Text(
          'Go Live',
        ),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ================================================================
// LIVE ROOM CARD
// ================================================================

class _LiveRoomCard extends StatelessWidget {
  final String roomName;
  final String hostName;
  final int viewerCount;
  final VoidCallback onTap;

  const _LiveRoomCard({
    required this.roomName,
    required this.hostName,
    required this.viewerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 70,
                    ),
                  ),

                  // LIVE
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // VIEWERS
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 17,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            viewerCount.toString(),
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ROOM INFORMATION
            Padding(
              padding:
                  const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: Text(
                      hostName.isNotEmpty
                          ? hostName[0]
                              .toUpperCase()
                          : 'M',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Host: $hostName',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
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

// ================================================================
// EMPTY LIVE ROOMS
// ================================================================

class _EmptyLiveRooms extends StatelessWidget {
  final VoidCallback onCreateRoom;

  const _EmptyLiveRooms({
    required this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.live_tv_outlined,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Live Rooms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Be the first person to start a live room.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onCreateRoom,
              icon: const Icon(
                Icons.videocam,
              ),
              label: const Text(
                'Create Live Room',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
