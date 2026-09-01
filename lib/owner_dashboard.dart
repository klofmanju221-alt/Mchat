import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Owner Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text(
                  'Please login again',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load owner profile',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final data =
                      snapshot.data?.data() ?? <String, dynamic>{};

                  final bool isOwner = data['isOwner'] == true;

                  if (!isOwner) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Access Denied\n\n'
                          'This account is not an Owner account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  return _ownerContent(
                    context,
                    user,
                    data,
                  );
                },
              ),
      ),
    );
  }

  Widget _ownerContent(
    BuildContext context,
    User user,
    Map<String, dynamic> data,
  ) {
    final String ownerName =
        (data['name'] ?? user.displayName ?? 'Owner').toString();

    final String email =
        (data['email'] ?? user.email ?? '').toString();

    final int coins = _toInt(data['coins']);

    final int vipLevel = _toInt(data['vipLevel']);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    ownerName.isNotEmpty
                        ? ownerName.substring(0, 1).toUpperCase()
                        : 'O',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'OWNER ACCOUNT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.monetization_on,
                title: 'Coins',
                value: '$coins',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.star,
                title: 'VIP Level',
                value: 'VIP $vipLevel',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .snapshots(),
          builder: (context, snapshot) {
            final totalUsers =
                snapshot.data?.docs.length ?? 0;

            return _statCard(
              icon: Icons.people_alt,
              title: 'Total Users',
              value: '$totalUsers',
              fullWidth: true,
            );
          },
        ),

        const SizedBox(height: 20),

        const Text(
          'Owner Controls',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _menuItem(
          context,
          Icons.account_balance_wallet,
          'Coins & Recharge',
          'Manage recharge and coins',
        ),

        _menuItem(
          context,
          Icons.card_giftcard,
          'Refer & Earn',
          'Manage referral system',
        ),

        _menuItem(
          context,
          Icons.people,
          'User Management',
          'Manage users and volunteers',
        ),

        _menuItem(
          context,
          Icons.live_tv,
          'Live & PK',
          'Manage live streaming and PK',
        ),

        _menuItem(
          context,
          Icons.bar_chart,
          'Reports',
          'View app reports',
        ),

        _menuItem(
          context,
          Icons.settings,
          'App Settings',
          'Owner application settings',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.deepPurple,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title module will be connected next.',
              ),
            ),
          );
        },
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
