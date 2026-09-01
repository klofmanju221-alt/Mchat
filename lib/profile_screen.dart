import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFFFF9FF);

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Please login again',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final String uid = firebaseUser.uid;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load profile.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final String email =
              (data['email'] ?? firebaseUser.email ?? 'No email').toString();

          final String name =
              (data['name'] ?? firebaseUser.displayName ?? 'Mchat User')
                  .toString();

          final int coins = _toInt(data['coins']);

          final int vipLevel = _toInt(data['vipLevel']);

          final bool isOwner =
              data['isOwner'] == true ||
              data['role']?.toString().toLowerCase() == 'owner' ||
              email.toLowerCase() == 'klofmanju221@gmail.com';

          final String? photoUrl = firebaseUser.photoURL;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [

              // PROFILE PHOTO
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 65,
                          color: primaryColor,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // NAME
              Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // EMAIL
              Center(
                child: Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
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
                      value: _formatNumber(coins),
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
              if (isOwner) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF673AB7),
                        Color(0xFF8E5DE7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 4),
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),

                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: primaryColor,
                      ),
                    ),

                    title: const Text(
                      'Owner Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: const Text(
                      'Manage Mchat application',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerDashboard(),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // EDIT PROFILE
              _menuItem(
                context,
                Icons.edit,
                'Edit Profile',
                'Update your profile',
                () {
                  _showMessage(
                    context,
                    'Edit Profile screen will be connected next.',
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
                  _showMessage(
                    context,
                    'Recharge system will be connected next.',
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
                  _showMessage(
                    context,
                    'Refer & Earn system will be connected next.',
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
                  _showMessage(
                    context,
                    'Settings will be connected next.',
                  );
                },
              ),

              const SizedBox(height: 20),

              // LOGOUT
              SizedBox(
                height: 58,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.logout,
                    color: primaryColor,
                  ),

                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // DEBUG / OWNER STATUS
              if (isOwner)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 30,
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'OWNER ACCOUNT',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'VIP Level: $vipLevel\n'
                        'Coins: ${_formatNumber(coins)}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // INFO CARD
  // ----------------------------------------------------------

  static Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      color: const Color(0xFFFFF8FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 34,
              color: primaryColor,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // MENU ITEM
  // ----------------------------------------------------------

  static Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: const Color(0xFFFFF8FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),

        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          size: 30,
        ),

        onTap: onTap,
      ),
    );
  }

  // ----------------------------------------------------------
  // MESSAGE
  // ----------------------------------------------------------

  static void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ----------------------------------------------------------
  // INTEGER CONVERTER
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // NUMBER FORMAT
  // ----------------------------------------------------------

  static String _formatNumber(int value) {
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
}

// ==================================================================
// OWNER DASHBOARD
// ==================================================================

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  static const Color primaryColor = Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FF),

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Owner Dashboard',
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
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          final users = snapshot.data?.docs ?? [];

          int totalCoins = 0;
          int ownerCount = 0;
          int volunteerCount = 0;

          for (final doc in users) {
            final data = doc.data();

            final dynamic coinValue = data['coins'];

            if (coinValue is num) {
              totalCoins += coinValue.toInt();
            }

            if (data['isOwner'] == true ||
                data['role']?.toString().toLowerCase() ==
                    'owner') {
              ownerCount++;
            }

            if (data['isVolunteer'] == true ||
                data['role']?.toString().toLowerCase() ==
                    'volunteer') {
              volunteerCount++;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [

              // OWNER HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF673AB7),
                      Color(0xFF9575CD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 45,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Mchat Owner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Application Management',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STATISTICS
              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      Icons.people,
                      'Users',
                      users.length.toString(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _dashboardCard(
                      Icons.monetization_on,
                      'Coins',
                      _formatNumber(totalCoins),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      Icons.verified_user,
                      'Owners',
                      ownerCount.toString(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _dashboardCard(
                      Icons.support_agent,
                      'Volunteers',
                      volunteerCount.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // USERS
              _ownerMenu(
                context,
                Icons.people,
                'Manage Users',
                'View registered users',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerUsersScreen(),
                    ),
                  );
                },
              ),

              // COIN PACKAGES
              _ownerMenu(
                context,
                Icons.monetization_on,
                'Coin Packages',
                'Manage recharge packages',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CoinPackagesScreen(),
                    ),
                  );
                },
              ),

              // VIP LEVELS
              _ownerMenu(
                context,
                Icons.star,
                'VIP Levels',
                'Manage VIP levels',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VipLevelsScreen(),
                    ),
                  );
                },
              ),

              // SETTINGS
              _ownerMenu(
                context,
                Icons.settings,
                'Owner Settings',
                'Application management settings',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Owner settings will be connected next.',
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _dashboardCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 30,
            ),

            const SizedBox(height: 7),

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  static Widget _ownerMenu(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
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

  static String _formatNumber(int value) {
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
}

// ==================================================================
// OWNER USERS
// ==================================================================

class OwnerUsersScreen extends StatelessWidget {
  const OwnerUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data();

              final String name =
                  (data['name'] ?? 'Mchat User').toString();

              final String email =
                  (data['email'] ?? 'No email').toString();

              final int coins =
                  _toInt(data['coins']);

              final int vip =
                  _toInt(data['vipLevel']);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '$email\nCoins: $coins • VIP: $vip',
                  ),

                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ==================================================================
// COIN PACKAGES
// ==================================================================

class CoinPackagesScreen extends StatelessWidget {
  const CoinPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Packages'),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('coinPackages')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final packages = snapshot.data!.docs;

          if (packages.isEmpty) {
            return const Center(
              child: Text(
                'No coin packages found.',
              ),
            );
          }

          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final data = packages[index].data();

              final String name =
                  (data['name'] ?? 'Coin Package').toString();

              final int coins =
                  _toInt(data['coins']);

              final dynamic price =
                  data['price'] ?? 0;

              final bool enabled =
                  data['enabled'] == true;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.monetization_on,
                    color: Colors.deepPurple,
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '$coins Coins • ₹$price',
                  ),

                  trailing: Icon(
                    enabled
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: enabled
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ==================================================================
// VIP LEVELS
// ==================================================================

class VipLevelsScreen extends StatelessWidget {
  const VipLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Levels'),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('vipLevels')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final levels = snapshot.data!.docs;

          if (levels.isEmpty) {
            return const Center(
              child: Text(
                'No VIP levels found.',
              ),
            );
          }

          return ListView.builder(
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final data = levels[index].data();

              final int level =
                  _toInt(data['level']);

              final int requiredCoins =
                  _toInt(data['requiredCoins']);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: Colors.deepPurple,
                  ),

                  title: Text(
                    'VIP $level',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Required Coins: $requiredCoins',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
