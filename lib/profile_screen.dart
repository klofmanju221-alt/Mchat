import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'owner_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login again',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final String name =
              (data['name'] ?? user.displayName ?? 'Mchat User')
                  .toString();

          final String email =
              (data['email'] ?? user.email ?? 'No email').toString();

          final int coins = _toInt(data['coins']);

          final int vipLevel = _toInt(data['vipLevel']);

          final bool isOwner = data['isOwner'] == true;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              // PROFILE PHOTO
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: user.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                            user.photoURL!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.deepPurple,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.deepPurple,
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // NAME
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // EMAIL
              Center(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // COINS + VIP
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.monetization_on,
                      title: 'Coins',
                      value: '$coins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.star,
                      title: 'VIP Level',
                      value: 'VIP $vipLevel',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // OWNER DASHBOARD
              if (isOwner)
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.deepPurple.shade50,
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: const Text(
                      'Owner Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: const Text(
                      'Manage Mchat application',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OwnerDashboard(),
                        ),
                      );
                    },
                  ),
                ),

              // EDIT PROFILE
              _menuItem(
                context,
                Icons.edit,
                'Edit Profile',
                'Update your profile',
                () {
                  _message(
                    context,
                    'Edit Profile will be added next.',
                  );
                },
              ),

              // RECHARGE
              _menuItem(
                context,
                Icons.account_balance_wallet,
                'Recharge Coins',
                'Buy coins',
                () {
                  _message(
                    context,
                    'Recharge system will be added next.',
                  );
                },
              ),

              // REFER
              _menuItem(
                context,
                Icons.card_giftcard,
                'Refer & Earn',
                'Invite friends and earn',
                () {
                  _message(
                    context,
                    'Refer & Earn will be added next.',
                  );
                },
              ),

              // SETTINGS
              _menuItem(
                context,
                Icons.settings,
                'Settings',
                'Application settings',
                () {
                  _message(
                    context,
                    'Settings will be added next.',
                  );
                },
              ),

              const SizedBox(height: 15),

              // LOGOUT
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  static Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(title),
          ],
        ),
      ),
    );
  }

  static Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }

  static void _message(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
