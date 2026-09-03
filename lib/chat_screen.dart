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
  final TextEditingController controller =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get messages =>
      _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages');

  DocumentReference<Map<String, dynamic>> get chatRef =>
      _firestore
          .collection('chats')
          .doc(widget.chatId);

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> send() async {
    final text = controller.text.trim();
    final user = _auth.currentUser;

    if (text.isEmpty || user == null) {
      return;
    }

    try {
      // ----------------------------------------------------------
      // The chat ID is created by InboxScreen from two UIDs.
      // Store both participants in the chat document.
      // ----------------------------------------------------------

      final ids = widget.chatId.split('_');

      if (ids.length != 2 ||
          !ids.contains(user.uid)) {
        _showMessage(
          'This chat is not available.',
        );
        return;
      }

      final otherUid =
          ids.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );

      if (otherUid.isEmpty) {
        _showMessage(
          'Chat participant unavailable.',
        );
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final userData =
          userDoc.data() ?? {};

      final senderName =
          (userData['name'] ??
                  user.displayName ??
                  'Mchat User')
              .toString();

      // ----------------------------------------------------------
      // Create/update chat metadata first.
      // Firestore rules will only allow the two participants.
      // ----------------------------------------------------------

      await chatRef.set(
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
        },
        SetOptions(merge: true),
      );

      // ----------------------------------------------------------
      // Add message
      // ----------------------------------------------------------

      await messages.add({
        'senderId': user.uid,
        'senderName': senderName,
        'text': text,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      controller.clear();
    } catch (e) {
      _showMessage(
        'Message could not be sent.',
      );
    }
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
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
              stream: messages
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),

              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load messages',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start a conversation',
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.all(12),
                  itemCount: docs.length,

                  itemBuilder:
                      (context, index) {
                    final data =
                        docs[index].data();

                    final mine =
                        data['senderId'] ==
                            user.uid;

                    final text =
                        (data['text'] ??
                                '')
                            .toString();

                    final senderName =
                        (data['senderName'] ??
                                'User')
                            .toString();

                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 8,
                        ),

                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        constraints:
                            const BoxConstraints(
                          maxWidth: 300,
                        ),

                        decoration:
                            BoxDecoration(
                          color: mine
                              ? Colors
                                  .deepPurple
                                  .shade100
                              : Colors
                                  .grey
                                  .shade200,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
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
                                  fontSize: 12,
                                ),
                              ),

                            if (!mine)
                              const SizedBox(
                                height: 3,
                              ),

                            Text(
                              text,
                              style:
                                  const TextStyle(
                                fontSize: 16,
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
            child: Padding(
              padding:
                  const EdgeInsets.all(10),

              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller:
                          controller,

                      maxLines: 3,
                      minLines: 1,

                      textInputAction:
                          TextInputAction.send,

                      decoration:
                          InputDecoration(
                        hintText:
                            'Type a message...',

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                        ),
                      ),

                      onSubmitted:
                          (_) => send(),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  IconButton.filled(
                    onPressed: send,
                    icon: const Icon(
                      Icons.send,
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
    controller.dispose();
    super.dispose();
  }
}
