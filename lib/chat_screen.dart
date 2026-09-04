import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  bool _sending = false;

  CollectionReference<Map<String, dynamic>>
      get _messages =>
          _firestore
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages');

  DocumentReference<Map<String, dynamic>>
      get _chatRef =>
          _firestore
              .collection('chats')
              .doc(widget.chatId);

  // ============================================================
  // GET PARTICIPANT IDS
  // ============================================================

  List<String> get _participantIds {
    final ids = widget.chatId.split('_');

    return ids
        .where((id) => id.trim().isNotEmpty)
        .toList();
  }

  // ============================================================
  // GET OTHER USER ID
  // ============================================================

  String get _otherUserId {
    final currentUid = _auth.currentUser?.uid;

    if (currentUid == null) {
      return '';
    }

    for (final id in _participantIds) {
      if (id != currentUid) {
        return id;
      }
    }

    return '';
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (text.length > 500) {
      _showError(
        'Message cannot exceed 500 characters.',
      );
      return;
    }

    final ids = _participantIds;

    if (ids.length != 2 ||
        !ids.contains(user.uid)) {
      _showError(
        'This private chat is not available.',
      );
      return;
    }

    final otherUid = _otherUserId;

    if (otherUid.isEmpty) {
      _showError(
        'Chat participant unavailable.',
      );
      return;
    }

    if (_sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      // --------------------------------------------------------
      // LOAD SENDER PROFILE
      // --------------------------------------------------------

      final userSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

      final userData =
          userSnapshot.data() ?? {};

      final senderName =
          (userData['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString()
              .trim();

      final senderMchatId =
          (userData['mchatId'] ?? '')
              .toString();

      // --------------------------------------------------------
      // CREATE CHAT METADATA
      // --------------------------------------------------------

      await _chatRef.set(
        {
          'participants': [
            ids[0],
            ids[1],
          ],
          'lastMessage': text,
          'lastMessageAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
          'lastSenderId': user.uid,
          'lastSenderName':
              senderName.isEmpty
                  ? 'Mchat User'
                  : senderName,
        },
        SetOptions(merge: true),
      );

      // --------------------------------------------------------
      // ADD MESSAGE
      // --------------------------------------------------------

      await _messages.add(
        {
          'senderId': user.uid,
          'senderName':
              senderName.isEmpty
                  ? 'Mchat User'
                  : senderName,
          'senderMchatId':
              senderMchatId,
          'text': text,
          'createdAt':
              FieldValue.serverTimestamp(),
        },
      );

      _controller.clear();

      if (mounted) {
        setState(() {
          _sending = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }

      _showError(
        'Message could not be sent.',
      );
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          0,
          duration:
              const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return '';
    }

    final date = timestamp.toDate();

    final hour =
        date.hour % 12 == 0
            ? 12
            : date.hour % 12;

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to use Free Inbox.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F4FB),

      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,

        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(
                widget.title.isNotEmpty
                    ? widget.title[0]
                        .toUpperCase()
                    : 'M',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: StreamBuilder<
                  DocumentSnapshot<
                      Map<String, dynamic>>>(
                stream: _firestore
                    .collection('users')
                    .doc(_otherUserId)
                    .snapshots(),

                builder:
                    (context, snapshot) {
                  final data =
                      snapshot.data?.data();

                  final online =
                      data?['isOnline'] ==
                          true;

                  final name =
                      (data?['name'] ??
                              widget.title)
                          .toString();

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              color: online
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Text(
                            online
                                ? 'Online'
                                : 'Offline',
                            style:
                                TextStyle(
                              fontSize: 11,
                              color: online
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ======================================================
          // MESSAGES
          // ======================================================

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: _messages
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),

              builder:
                  (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(25),
                      child: Text(
                        'Unable to load messages.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .deepPurple
                                .withValues(
                              alpha: 0.10,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .chat_bubble_outline,
                            size: 38,
                            color: Colors
                                .deepPurple,
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          'Start a conversation',
                          style:
                              const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Send a message to ${widget.title}',
                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller:
                      _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    16,
                    12,
                    12,
                  ),
                  itemCount:
                      docs.length,

                  itemBuilder:
                      (context, index) {
                    final data =
                        docs[index].data();

                    final senderId =
                        (data['senderId'] ??
                                '')
                            .toString();

                    final text =
                        (data['text'] ?? '')
                            .toString();

                    final senderName =
                        (data['senderName'] ??
                                'Mchat User')
                            .toString();

                    final timestamp =
                        data['createdAt']
                            as Timestamp?;

                    final mine =
                        senderId ==
                            user.uid;

                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 310,
                        ),

                        margin:
                            const EdgeInsets.only(
                          bottom: 8,
                        ),

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        decoration:
                            BoxDecoration(
                          color: mine
                              ? Colors
                                  .deepPurple
                              : Colors.white,

                          borderRadius:
                              BorderRadius
                                  .only(
                            topLeft:
                                const Radius
                                    .circular(
                              18,
                            ),
                            topRight:
                                const Radius
                                    .circular(
                              18,
                            ),
                            bottomLeft:
                                Radius.circular(
                              mine ? 18 : 4,
                            ),
                            bottomRight:
                                Radius.circular(
                              mine ? 4 : 18,
                            ),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 5,
                              offset:
                                  const Offset(
                                0,
                                2,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              mine
                                  ? CrossAxisAlignment
                                      .end
                                  : CrossAxisAlignment
                                      .start,

                          children: [
                            if (!mine)
                              Text(
                                senderName,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors
                                      .deepPurple,
                                ),
                              ),

                            if (!mine)
                              const SizedBox(
                                height: 3,
                              ),

                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                color: mine
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              _formatTime(
                                timestamp,
                              ),
                              style: TextStyle(
                                fontSize: 9,
                                color: mine
                                    ? Colors.white
                                        .withValues(
                                        alpha: 0.75,
                                      )
                                    : Colors.grey,
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

          // ======================================================
          // MESSAGE INPUT
          // ======================================================

          SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                8,
                10,
                8,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.white,
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _controller,

                      minLines: 1,
                      maxLines: 4,

                      textCapitalization:
                          TextCapitalization
                              .sentences,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Type a message...',

                        filled: true,

                        fillColor:
                            const Color(
                          0xFFF2EEF7,
                        ),

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            25,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),

                        counterText: '',
                      ),

                      maxLength: 500,

                      onSubmitted:
                          (_) =>
                              _sendMessage(),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  SizedBox(
                    width: 50,
                    height: 50,
                    child: _sending
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : IconButton(
                            onPressed:
                                _sendMessage,
                            style:
                                IconButton.styleFrom(
                              backgroundColor:
                                  Colors
                                      .deepPurple,
                              foregroundColor:
                                  Colors.white,
                            ),
                            icon:
                                const Icon(
                              Icons.send_rounded,
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
