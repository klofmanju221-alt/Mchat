import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to use Free Inbox',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Free Inbox',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('mchatIds')
            .orderBy('name')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Unable to load Mchat users.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          final users =
              documents.where((doc) {
            return doc.data()['uid'] !=
                currentUser.uid;
          }).toList();

          if (users.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(30),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No other users yet',
                      style:
                          TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Registered Mchat users will appear here.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              height: 10,
            ),
            itemBuilder:
                (context, index) {
              final data =
                  users[index].data();

              return _userCard(
                context: context,
                uid: (data['uid'] ?? '')
                    .toString(),
                name:
                    (data['name'] ??
                            'Mchat User')
                        .toString(),
                email:
                    (data['email'] ?? '')
                        .toString(),
                photoUrl:
                    (data['photoUrl'] ??
                            '')
                        .toString(),
                isOnline:
                    data['isOnline'] ==
                        true,
                mchatId:
                    (data['mchatId'] ??
                            '')
                        .toString(),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () =>
            _showSearchDialog(
          context,
        ),
        child:
            const Icon(Icons.search),
      ),
    );
  }

  // ===============================================================
  // USER CARD
  // ===============================================================

  Widget _userCard({
    required BuildContext context,
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
    required bool isOnline,
    required String mchatId,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        leading: CircleAvatar(
          radius: 27,
          backgroundImage:
              photoUrl.isNotEmpty
                  ? NetworkImage(
                      photoUrl,
                    )
                  : null,
          child: photoUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 30,
                )
              : null,
        ),

        title: Text(
          name,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),

        subtitle: Text(
          isOnline
              ? 'Online • ID: $mchatId'
              : 'Mchat ID: $mchatId',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          _openChat(
            context,
            uid,
            name,
          );
        },
      ),
    );
  }

  // ===============================================================
  // OPEN CHAT
  // ===============================================================

  void _openChat(
    BuildContext context,
    String uid,
    String name,
  ) {
    final currentUid =
        FirebaseAuth
            .instance
            .currentUser
            ?.uid;

    if (currentUid == null ||
        uid.isEmpty ||
        currentUid == uid) {
      return;
    }

    final ids =
        [currentUid, uid]..sort();

    final chatId =
        '${ids[0]}_${ids[1]}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(
          chatId: chatId,
          title: name,
        ),
      ),
    );
  }

  // ===============================================================
  // SEARCH DIALOG
  // ===============================================================

  Future<void> _showSearchDialog(
    BuildContext context,
  ) async {
    final controller =
        TextEditingController();

    final currentUid =
        FirebaseAuth.instance
            .currentUser
            ?.uid;

    if (currentUid == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Find Mchat User',
          ),

          content: TextField(
            controller:
                controller,
            autofocus: true,
            textInputAction:
                TextInputAction.search,
            decoration:
                const InputDecoration(
              hintText:
                  'Enter name or Mchat ID',
              prefixIcon:
                  Icon(
                Icons.search,
              ),
              border:
                  OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _searchUsers(
                context,
                dialogContext,
                controller.text,
                currentUid,
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                'CANCEL',
              ),
            ),

            FilledButton(
              onPressed: () {
                _searchUsers(
                  context,
                  dialogContext,
                  controller.text,
                  currentUid,
                );
              },
              child:
                  const Text(
                'SEARCH',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  // ===============================================================
  // SEARCH USERS
  // ===============================================================

  Future<void> _searchUsers(
    BuildContext context,
    BuildContext dialogContext,
    String value,
    String currentUid,
  ) async {
    final query =
        value.trim().toLowerCase();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a name or Mchat ID',
          ),
        ),
      );
      return;
    }

    try {
      // -----------------------------------------------------------
      // IMPORTANT:
      // Search mchatIds, NOT users.
      // -----------------------------------------------------------

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection('mchatIds')
              .get();

      final matches =
          snapshot.docs.where((doc) {
        final data =
            doc.data();

        final uid =
            (data['uid'] ?? '')
                .toString();

        if (uid == currentUid) {
          return false;
        }

        final name =
            (data['name'] ?? '')
                .toString()
                .toLowerCase();

        final mchatId =
            (data['mchatId'] ??
                    doc.id)
                .toString()
                .toLowerCase();

        final email =
            (data['email'] ?? '')
                .toString()
                .toLowerCase();

        return name.contains(query) ||
            mchatId.contains(query) ||
            email.contains(query);
      }).toList();

      if (!context.mounted) {
        return;
      }

      if (matches.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'No Mchat user found',
            ),
          ),
        );
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder:
            (sheetContext) {
          return SafeArea(
            child:
                ListView.separated(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                20,
              ),
              itemCount:
                  matches.length,
              separatorBuilder:
                  (_, __) =>
                      const Divider(
                height: 1,
              ),
              itemBuilder:
                  (_, index) {
                final data =
                    matches[index]
                        .data();

                final uid =
                    (data['uid'] ??
                            '')
                        .toString();

                final name =
                    (data['name'] ??
                            'Mchat User')
                        .toString();

                final photoUrl =
                    (data['photoUrl'] ??
                            '')
                        .toString();

                final mchatId =
                    (data['mchatId'] ??
                            matches[index]
                                .id)
                        .toString();

                return ListTile(
                  leading:
                      CircleAvatar(
                    backgroundImage:
                        photoUrl.isNotEmpty
                            ? NetworkImage(
                                photoUrl,
                              )
                            : null,
                    child: photoUrl
                            .isEmpty
                        ? const Icon(
                            Icons.person,
                          )
                        : null,
                  ),

                  title: Text(
                    name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Text(
                    'Mchat ID: $mchatId',
                  ),

                  trailing:
                      const Icon(
                    Icons
                        .chat_outlined,
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _openChat(
                      context,
                      uid,
                      name,
                    );
                  },
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Search failed: $e',
          ),
        ),
      );
    }
  }
}
