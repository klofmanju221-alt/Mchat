import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to use Free Inbox'),
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

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
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
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load users.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          final users = documents.where((doc) {
            return doc.id != currentUser.uid;
          }).toList();

          if (users.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No other users yet',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Registered Mchat users will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data();

              final String name =
                  (data['name'] ?? 'Mchat User').toString();

              final String email =
                  (data['email'] ?? '').toString();

              final String photoUrl =
                  (data['photoUrl'] ?? '').toString();

              final bool isOnline =
                  data['isOnline'] == true;

              return _userCard(
                context: context,
                uid: user.id,
                name: name,
                email: email,
                photoUrl: photoUrl,
                isOnline: isOnline,
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSearchInfo(context);
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _userCard({
    required BuildContext context,
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
    required bool isOnline,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        leading: Stack(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 30,
                    )
                  : null,
            ),

            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),

        subtitle: Text(
          isOnline
              ? 'Online'
              : email.isNotEmpty
                  ? email
                  : 'Mchat User',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                userId: uid,
                userName: name,
                userPhotoUrl: photoUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSearchInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Find Mchat User'),
          content: const Text(
            'User search will be connected to Mchat ID and name search next.',
          ),
          actions: [
            TextButton(
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
}
