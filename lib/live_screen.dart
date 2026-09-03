import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) return;

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
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      final userData = userDoc.data() ?? {};

      final hostName =
          (userData['name'] ?? user.displayName ?? 'Mchat User').toString();

      final mchatId =
          (userData['mchatId'] ?? '').toString();

      final roomRef = _firestore.collection('rooms').doc();

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveRoomScreen(
            roomId: roomRef.id,
            roomName: roomName.trim(),
            hostName: hostName,
            hostUid: user.uid,
            isHost: true,
          ),
        ),
      );
    } catch (e) {
      _showMessage('Could not create room.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

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
            icon: const Icon(Icons.add_circle),
            tooltip: 'Create Room',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('rooms')
            .where('status', isEqualTo: 'live')
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

          final rooms = snapshot.data?.docs ?? [];

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

                final hostUid =
                    (data['hostUid'] ?? '').toString();

                return _LiveRoomCard(
                  roomId: doc.id,
                  roomName:
                      (data['roomName'] ?? 'Live Room')
                          .toString(),
                  hostName:
                      (data['hostName'] ?? 'Mchat User')
                          .toString(),
                  viewerCount:
                      (data['viewerCount'] ?? 0) as num,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveRoomScreen(
                          roomId: doc.id,
                          roomName:
                              (data['roomName'] ??
                                      'Live Room')
                                  .toString(),
                          hostName:
                              (data['hostName'] ??
                                      'Mchat User')
                                  .toString(),
                          hostUid: hostUid,
                          isHost: hostUid ==
                              _auth.currentUser?.uid,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _createRoom,
        icon: const Icon(Icons.videocam),
        label: const Text('Go Live'),
      ),
    );
  }
}

class _LiveRoomCard extends StatelessWidget {
  final String roomId;
  final String roomName;
  final String hostName;
  final num viewerCount;
  final VoidCallback onTap;

  const _LiveRoomCard({
    required this.roomId,
    required this.roomName,
    required this.hostName,
    required this.viewerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 150,
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
                      Icons.live_tv,
                      size: 64,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),
                        color: Colors.red,
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
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),
                        color: Colors.black54,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            viewerCount
                                .toInt()
                                .toString(),
                            style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      hostName.isNotEmpty
                          ? hostName[0].toUpperCase()
                          : 'M',
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
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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

class _EmptyLiveRooms extends StatelessWidget {
  final VoidCallback onCreateRoom;

  const _EmptyLiveRooms({
    required this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
              icon: const Icon(Icons.videocam),
              label:
                  const Text('Create Live Room'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LIVE ROOM + GIFTING
// ============================================================================

class LiveRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String hostName;
  final String hostUid;
  final bool isHost;

  const LiveRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.hostName,
    required this.hostUid,
    required this.isHost,
  });

  @override
  State<LiveRoomScreen> createState() =>
      _LiveRoomScreenState();
}

class _LiveRoomScreenState
    extends State<LiveRoomScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController
      _messageController =
      TextEditingController();

  bool _sendingGift = false;

  static const List<_GiftItem> _gifts = [
    _GiftItem('🌹', 'Rose', 10),
    _GiftItem('❤️', 'Heart', 49),
    _GiftItem('🍭', 'Lollipop', 99),
    _GiftItem('☕', 'Coffee', 199),
    _GiftItem('🧸', 'Teddy', 299),
    _GiftItem('💎', 'Diamond', 499),
    _GiftItem('🚗', 'Car', 999),
    _GiftItem('🏰', 'Castle', 1999),
    _GiftItem('🦁', 'Lion', 2999),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // SEND CHAT MESSAGE
  // --------------------------------------------------------------------------

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final text =
        _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    final userDoc =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

    final data =
        userDoc.data() ?? {};

    final name =
        (data['name'] ??
                user.displayName ??
                'Mchat User')
            .toString();

    await _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': name,
      'text': text,
      'type': 'text',
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  // --------------------------------------------------------------------------
  // SEND GIFT
  // --------------------------------------------------------------------------

  Future<void> _sendGift(
      _GiftItem gift) async {
    if (_sendingGift) return;

    final sender =
        _auth.currentUser;

    if (sender == null) return;

    if (widget.hostUid.isEmpty) {
      _showMessage(
        'Host account is unavailable.',
      );
      return;
    }

    if (sender.uid ==
        widget.hostUid) {
      _showMessage(
        'You cannot send a gift to yourself.',
      );
      return;
    }

    setState(() {
      _sendingGift = true;
    });

    try {
      final senderRef =
          _firestore
              .collection('users')
              .doc(sender.uid);

      final hostRef =
          _firestore
              .collection('users')
              .doc(widget.hostUid);

      final roomRef =
          _firestore
              .collection('rooms')
              .doc(widget.roomId);

      final giftRef =
          roomRef
              .collection('gifts')
              .doc();

      String senderName =
          sender.displayName ??
              'Mchat User';

      String receiverName =
          widget.hostName;

      // IMPORTANT:
      // Sender coin deduction + host coin credit +
      // gift record happen inside ONE Firestore transaction.
      await _firestore
          .runTransaction(
        (transaction) async {
          final senderSnap =
              await transaction
                  .get(senderRef);

          final hostSnap =
              await transaction
                  .get(hostRef);

          if (!senderSnap.exists) {
            throw Exception(
              'SENDER_NOT_FOUND',
            );
          }

          if (!hostSnap.exists) {
            throw Exception(
              'HOST_NOT_FOUND',
            );
          }

          final senderData =
              senderSnap.data() ?? {};

          final hostData =
              hostSnap.data() ?? {};

          senderName =
              (senderData['name'] ??
                      sender.displayName ??
                      'Mchat User')
                  .toString();

          receiverName =
              (hostData['name'] ??
                      widget.hostName)
                  .toString();

          final senderCoins =
              _toInt(
            senderData['coins'],
          );

          final hostCoins =
              _toInt(
            hostData['coins'],
          );

          if (senderCoins <
              gift.coins) {
            throw Exception(
              'INSUFFICIENT_COINS',
            );
          }

          // Deduct sender coins.
          transaction.update(
            senderRef,
            {
              'coins':
                  senderCoins -
                      gift.coins,
              'updatedAt':
                  FieldValue
                      .serverTimestamp(),
            },
          );

          // Credit host coins.
          transaction.update(
            hostRef,
            {
              'coins':
                  hostCoins +
                      gift.coins,
              'updatedAt':
                  FieldValue
                      .serverTimestamp(),
            },
          );

          // Save gift history.
          transaction.set(
            giftRef,
            {
              'giftId':
                  giftRef.id,
              'roomId':
                  widget.roomId,
              'senderId':
                  sender.uid,
              'senderName':
                  senderName,
              'receiverId':
                  widget.hostUid,
              'receiverName':
                  receiverName,
              'giftName':
                  gift.name,
              'giftEmoji':
                  gift.emoji,
              'coins':
                  gift.coins,
              'createdAt':
                  FieldValue
                      .serverTimestamp(),
            },
          );
        },
      );

      // Add gift to live room chat/feed.
      await roomRef
          .collection('messages')
          .add({
        'senderId':
            sender.uid,
        'senderName':
            senderName,
        'text':
            '$senderName sent ${gift.name} ${gift.emoji} x1',
        'type':
            'gift',
        'giftName':
            gift.name,
        'giftEmoji':
            gift.emoji,
        'giftCoins':
            gift.coins,
        'createdAt':
            FieldValue
                .serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _sendingGift = false;
      });

      _showGiftSuccess(gift);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sendingGift = false;
      });

      if (e.toString().contains(
          'INSUFFICIENT_COINS')) {
        _showInsufficientCoins();
      } else if (e.toString().contains(
          'SENDER_NOT_FOUND')) {
        _showMessage(
          'Your user account was not found.',
        );
      } else if (e.toString().contains(
          'HOST_NOT_FOUND')) {
        _showMessage(
          'Host account was not found.',
        );
      } else {
        _showMessage(
          'Gift could not be sent. Please try again.',
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // GIFT BOTTOM SHEET
  // --------------------------------------------------------------------------

  void _showGiftSheet() {
    if (_sendingGift) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          const Color(0xFF17111F),
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white24,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color:
                          Colors.pinkAccent,
                      size: 28,
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Send Gift',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    StreamBuilder<
                        DocumentSnapshot<
                            Map<String,
                                dynamic>>>(
                      stream: _firestore
                          .collection('users')
                          .doc(
                            _auth.currentUser
                                ?.uid,
                          )
                          .snapshots(),
                      builder:
                          (context, snapshot) {
                        final coins =
                            _toInt(
                          snapshot.data
                              ?.data()?['coins'],
                        );

                        return Row(
                          children: [
                            const Icon(
                              Icons
                                  .monetization_on,
                              color:
                                  Colors.amber,
                              size: 20,
                            ),

                            const SizedBox(
                                width: 4),

                            Text(
                              _formatNumber(
                                coins,
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _gifts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        .95,
                  ),
                  itemBuilder:
                      (context, index) {
                    final gift =
                        _gifts[index];

                    return InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(18),
                      onTap: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _confirmGift(
                          gift,
                        );
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white10,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          border:
                              Border.all(
                            color:
                                Colors.white12,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              gift.emoji,
                              style:
                                  const TextStyle(
                                fontSize: 38,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              gift.name,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),

                            const SizedBox(
                                height: 3),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                const Icon(
                                  Icons
                                      .monetization_on,
                                  color:
                                      Colors.amber,
                                  size: 15,
                                ),

                                const SizedBox(
                                    width: 3),

                                Text(
                                  _formatNumber(
                                    gift.coins,
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.amber,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  'Gifts use your Mchat Coins.',
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

  // --------------------------------------------------------------------------
  // CONFIRM GIFT
  // --------------------------------------------------------------------------

  Future<void> _confirmGift(
      _GiftItem gift) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Send Gift?'),

          content: Text(
            '${gift.emoji} ${gift.name}\n\n'
            'Cost: ${_formatNumber(gift.coins)} Coins\n'
            'To: ${widget.hostName}',
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child:
                  const Text('Cancel'),
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _sendGift(gift);
              },
              icon: const Icon(
                Icons.card_giftcard,
              ),
              label:
                  const Text('Send Gift'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // SUCCESS MESSAGE
  // --------------------------------------------------------------------------

  void _showGiftSuccess(
      _GiftItem gift) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        duration:
            const Duration(seconds: 3),
        content: Text(
          '${gift.emoji} ${gift.name} sent to ${widget.hostName}!',
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // INSUFFICIENT COINS
  // --------------------------------------------------------------------------

  void _showInsufficientCoins() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Not Enough Coins',
          ),

          content: const Text(
            'You do not have enough Mchat Coins '
            'for this gift.\n\n'
            'Please recharge your Coins and try again.',
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child:
                  const Text('Close'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                // Recharge screen can be connected
                // here after verifying its constructor.
                _showMessage(
                  'Please open Recharge to buy Coins.',
                );
              },
              child:
                  const Text('Recharge'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // LEAVE ROOM
  // --------------------------------------------------------------------------

  Future<void> _leaveRoom() async {
    if (widget.isHost) {
      await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .update({
        'status': 'ended',
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // --------------------------------------------------------------------------
  // LIVE ROOM UI
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomName,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              'Host: ${widget.hostName}',
              style:
                  const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _leaveRoom,
            icon:
                const Icon(Icons.close),
          ),
        ],
      ),

      body: Column(
        children: [
          // ------------------------------------------------------------------
          // LIVE VIDEO AREA
          // ------------------------------------------------------------------

          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFF24103D),
                    Color(0xFF10091C),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.videocam_off,
                      color:
                          Colors.white70,
                      size: 70,
                    ),
                  ),

                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        'LIVE ROOM',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Text(
                      widget.isHost
                          ? 'You are the host'
                          : 'You joined this live room',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // LIVE CHAT
          // ------------------------------------------------------------------

          Expanded(
            flex: 4,
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: _firestore
                  .collection('rooms')
                  .doc(widget.roomId)
                  .collection(
                      'messages')
                  .orderBy(
                    'createdAt',
                    descending: false,
                  )
                  .snapshots(),

              builder:
                  (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Chat unavailable',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                  );
                }

                final messages =
                    snapshot.data
                            ?.docs ??
                        [];

                return ListView.builder(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                  ),
                  itemCount:
                      messages.length,
                  itemBuilder:
                      (context, index) {
                    final data =
                        messages[index]
                            .data();

                    final type =
                        (data['type'] ??
                                'text')
                            .toString();

                    // GIFT MESSAGE
                    if (type ==
                        'gift') {
                      return Container(
                        margin:
                            const EdgeInsets
                                .symmetric(
                          vertical: 5,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .pinkAccent
                              .withOpacity(
                            .12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              (data[
                                          'giftEmoji'] ??
                                      '🎁')
                                  .toString(),
                              style:
                                  const TextStyle(
                                fontSize: 28,
                              ),
                            ),

                            const SizedBox(
                                width: 8),

                            Expanded(
                              child: Text(
                                (data[
                                            'text'] ??
                                        '')
                                    .toString(),
                                style:
                                    const TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // NORMAL MESSAGE
                    return Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 5,
                      ),
                      child:
                          RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${data['senderName'] ?? 'User'}: ',

                              style:
                                  const TextStyle(
                                color:
                                    Colors
                                        .white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            TextSpan(
                              text:
                                  '${data['text'] ?? ''}',

                              style:
                                  const TextStyle(
                                color:
                                    Colors
                                        .white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ------------------------------------------------------------------
          // MESSAGE + GIFT + SEND
          // ------------------------------------------------------------------

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                12,
                6,
                12,
                12,
              ),

              child: Row(
                children: [
                  // 🎁 GIFT BUTTON
                  Material(
                    color: Colors
                        .pinkAccent
                        .withOpacity(
                      .18,
                    ),
                    shape:
                        const CircleBorder(),

                    child: IconButton(
                      tooltip:
                          'Send Gift',

                      onPressed:
                          _sendingGift
                              ? null
                              : _showGiftSheet,

                      icon:
                          _sendingGift
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors
                                            .pinkAccent,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .card_giftcard,
                                  color:
                                      Colors
                                          .pinkAccent,
                                  size: 28,
                                ),
                    ),
                  ),

                  const SizedBox(
                      width: 8),

                  // MESSAGE FIELD
                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      decoration:
                          InputDecoration(
                        hintText:
                            'Write a message...',

                        hintStyle:
                            const TextStyle(
                          color:
                              Colors
                                  .white54,
                        ),

                        filled: true,

                        fillColor:
                            Colors
                                .white12,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            30,
                          ),
                          borderSide:
                              BorderSide
                                  .none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 8),

                  // SEND BUTTON
                  IconButton(
                    onPressed:
                        _sendMessage,

                    icon:
                        const Icon(
                      Icons.send,
                      color:
                          Colors.white,
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

  // --------------------------------------------------------------------------
  // HELPERS
  // --------------------------------------------------------------------------

  static int _toInt(
      dynamic value) {
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

  static String _formatNumber(
      int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }

  void _showMessage(
      String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }
}

// ============================================================================
// GIFT MODEL
// ============================================================================

class _GiftItem {
  final String emoji;
  final String name;
  final int coins;

  const _GiftItem(
    this.emoji,
    this.name,
    this.coins,
  );
}
