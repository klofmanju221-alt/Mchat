import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'payment_screen.dart';

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

          final Map<String, dynamic> data =
              snapshot.data?.data() ?? <String, dynamic>{};

          final String email =
              (data['email'] ??
                      firebaseUser.email ??
                      'No email')
                  .toString();

          final String name =
              (data['name'] ??
                      firebaseUser.displayName ??
                      'Mchat User')
                  .toString();

          final int coins = _toInt(data['coins']);

          final int vipLevel = _toInt(data['vipLevel']);

          final bool isOwner =
              data['isOwner'] == true ||
              data['role']?.toString().toLowerCase() == 'owner' ||
              email.toLowerCase() == 'klofmanju221@gmail.com';

          final String? photoUrl = firebaseUser.photoURL;

         final String mchatId =
         (data['mchatId'] ?? 'Creating...').toString();

         return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),

            children: [
              // =====================================================
              // PROFILE PHOTO
              // =====================================================

              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,

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

              // =====================================================
              // NAME
              // =====================================================

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

              // =====================================================
              // EMAIL
              // =====================================================

              final String mchatId =
    (data['mchatId'] ?? 'Creating...').toString();

Center(
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.deepPurple.shade100,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.badge_rounded,
          color: primaryColor,
          size: 26,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Mchat ID',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            Text(
              mchatId,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
              const SizedBox(height: 25),

              // =====================================================
              // COINS + VIP
              // =====================================================

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

              // =====================================================
              // OWNER DASHBOARD
              // =====================================================

              if (isOwner)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF673AB7),
                        Color(0xFF8E5DE7),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(18),

                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 4),
                        color: Colors.black26,
                      ),
                    ],
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
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
                          builder: (_) =>
                              const OwnerDashboard(),
                        ),
                      );
                    },
                  ),
                ),

              // =====================================================
              // EDIT PROFILE
              // =====================================================

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

              // =====================================================
              // RECHARGE
              // =====================================================

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

              // =====================================================
              // REFER & EARN
              // =====================================================

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

              // =====================================================
              // SETTINGS
              // =====================================================

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

              // =====================================================
              // LOGOUT
              // =====================================================

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
                      borderRadius:
                          BorderRadius.circular(30),
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

              // =====================================================
              // OWNER STATUS
              // =====================================================

              if (isOwner)
                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(14),

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

  // ===============================================================
  // INFO CARD
  // ===============================================================

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

  // ===============================================================
  // MENU ITEM
  // ===============================================================

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
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),

        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
              Colors.deepPurple.shade50,

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

  // ===============================================================
  // MESSAGE
  // ===============================================================

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

  // ===============================================================
  // INTEGER
  // ===============================================================

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

  // ===============================================================
  // NUMBER FORMAT
  // ===============================================================

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

  static const Color primaryColor =
      Color(0xFF673AB7);

  static const Color backgroundColor =
      Color(0xFFFFF9FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

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

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load dashboard.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final users =
              snapshot.data?.docs ?? [];

          int totalCoins = 0;
          int ownerCount = 0;
          int volunteerCount = 0;

          for (final doc in users) {
            final data = doc.data();

            totalCoins +=
                _toInt(data['coins']);

            final String role =
                data['role']
                        ?.toString()
                        .toLowerCase() ??
                    '';

            if (data['isOwner'] == true ||
                role == 'owner') {
              ownerCount++;
            }

            if (data['isVolunteer'] == true ||
                role == 'volunteer') {
              volunteerCount++;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(18),

            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF673AB7),
                      Color(0xFF9575CD),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

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

              // =====================================================
              // USERS + COINS
              // =====================================================

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

              // =====================================================
              // OWNERS + VOLUNTEERS
              // =====================================================

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

              // =====================================================
              // MANAGE USERS
              // =====================================================

              _ownerMenu(
                context,
                Icons.people,
                'Manage Users',
                'View registered users',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const OwnerUsersScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // COIN PACKAGES
              // =====================================================

              _ownerMenu(
                context,
                Icons.monetization_on,
                'Coin Packages',
                'Manage recharge packages',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CoinPackagesScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // VIP LEVELS
              // =====================================================

              _ownerMenu(
                context,
                Icons.star,
                'VIP Levels',
                'Manage VIP levels',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const VipLevelsScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // OWNER SETTINGS
              // =====================================================

              _ownerMenu(
                context,
                Icons.settings,
                'Owner Settings',
                'Application management settings',
                () {
                  _showMessage(
                    context,
                    'Owner Settings will be connected next.',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ===============================================================
  // DASHBOARD CARD
  // ===============================================================

  static Widget _dashboardCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
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

  // ===============================================================
  // OWNER MENU
  // ===============================================================

  static Widget _ownerMenu(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),

        leading: CircleAvatar(
          backgroundColor:
              Colors.deepPurple.shade50,

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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
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
}


// ==================================================================
// OWNER USERS
// ==================================================================

class OwnerUsersScreen extends StatelessWidget {
  const OwnerUsersScreen({super.key});

  static const Color primaryColor =
      Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF9FF),

      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xFFFFF9FF),

        foregroundColor: Colors.black,

        elevation: 0,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load users.\n\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final users =
              snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(
              vertical: 8,
            ),

            itemCount: users.length,

            itemBuilder:
                (context, index) {
              final data =
                  users[index].data();

              final String name =
                  (data['name'] ??
                          'Mchat User')
                      .toString();

              final String email =
                  (data['email'] ??
                          'No email')
                      .toString();

              final int coins =
                  _toInt(data['coins']);

              final int vip =
                  _toInt(data['vipLevel']);

              final String? photoUrl =
                  (data['photoUrl'] ??
                          data['photoURL'])
                      ?.toString();

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                elevation: 2,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.deepPurple.shade50,

                    backgroundImage:
                        photoUrl != null &&
                                photoUrl.isNotEmpty
                            ? NetworkImage(
                                photoUrl,
                              )
                            : null,

                    child:
                        photoUrl == null ||
                                photoUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                color:
                                    primaryColor,
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

                  subtitle: Text(
                    '$email\n'
                    'Coins: ${_formatNumber(coins)}'
                    ' • VIP: $vip',
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
// ==================================================================
// COIN PACKAGES
// ==================================================================

class CoinPackage {
  final String name;
  final int coins;
  final int price;

  const CoinPackage({
    required this.name,
    required this.coins,
    required this.price,
  });
}

class CoinPackagesScreen extends StatefulWidget {
  const CoinPackagesScreen({super.key});

  @override
  State<CoinPackagesScreen> createState() =>
      _CoinPackagesScreenState();
}

class _CoinPackagesScreenState
    extends State<CoinPackagesScreen> {
  static const Color primaryColor =
      Color(0xFF673AB7);

  static const Color backgroundColor =
      Color(0xFFFFF9FF);

  // ================================================================
  // FINAL COIN PRICING
  // ================================================================

  static const List<CoinPackage> packages = [
    CoinPackage(
      name: 'Starter Coins',
      coins: 1000,
      price: 100,
    ),

    CoinPackage(
      name: 'Basic Coins',
      coins: 5000,
      price: 500,
    ),

    CoinPackage(
      name: 'Silver Coins',
      coins: 10000,
      price: 1000,
    ),

    CoinPackage(
      name: 'Gold Coins',
      coins: 25000,
      price: 2500,
    ),

    CoinPackage(
      name: 'Premium Coins',
      coins: 50000,
      price: 5000,
    ),

    CoinPackage(
      name: 'Mega Coins',
      coins: 100000,
      price: 10000,
    ),

    CoinPackage(
      name: 'Ultra Coins',
      coins: 250000,
      price: 25000,
    ),

    CoinPackage(
      name: 'Royal Coins',
      coins: 500000,
      price: 50000,
    ),

    CoinPackage(
      name: 'Diamond Coins',
      coins: 1000000,
      price: 100000,
    ),

    CoinPackage(
      name: 'Royal Diamond Coins',
      coins: 2500000,
      price: 250000,
    ),
  ];

  int selectedIndex = 0;

  // ================================================================
  // NUMBER FORMAT
  // ================================================================

  String formatCoins(int value) {
    if (value >= 1000000) {
      final double result = value / 1000000;

      if (result == result.roundToDouble()) {
        return '${result.toInt()}M';
      }

      return '${result.toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      final double result = value / 1000;

      if (result == result.roundToDouble()) {
        return '${result.toInt()}K';
      }

      return '${result.toStringAsFixed(1)}K';
    }

    return value.toString();
  }

  String formatPrice(int value) {
    if (value >= 100000) {
      final String number =
          value.toString();

      final StringBuffer result =
          StringBuffer();

      int count = 0;

      for (int i = number.length - 1;
          i >= 0;
          i--) {
        result.write(number[i]);
        count++;

        if (count == 3 && i != 0) {
          result.write(',');
          count = 0;
        }
      }

      return result
          .toString()
          .split('')
          .reversed
          .join();
    }

    return value.toString();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final CoinPackage selectedPackage =
        packages[selectedIndex];

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Coin Packages',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          120,
        ),

        itemCount: packages.length,

        itemBuilder: (context, index) {
          final CoinPackage package =
              packages[index];

          final bool selected =
              selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },

            child: Container(
              margin: const EdgeInsets.only(
                bottom: 14,
              ),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color: selected
                      ? primaryColor
                      : Colors.transparent,

                  width: selected ? 2 : 0,
                ),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                children: [
                  // =================================================
                  // COIN ICON
                  // =================================================

                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF0E7FF),

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: const Icon(
                      Icons.monetization_on,
                      color: primaryColor,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // =================================================
                  // PACKAGE DETAILS
                  // =================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          package.name,

                          style:
                              const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${formatCoins(package.coins)} Coins',

                          style:
                              TextStyle(
                            fontSize: 16,
                            color: Colors
                                .grey
                                .shade700,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '₹${formatPrice(package.price)}',

                          style:
                              const TextStyle(
                            fontSize: 18,
                            color:
                                primaryColor,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // SELECTED ICON
                  // =================================================

                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons
                            .radio_button_unchecked,

                    color: selected
                        ? Colors.green
                        : Colors.grey,

                    size: 30,
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // ============================================================
      // CONTINUE BUTTON
      // ============================================================

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          14,
        ),

        child: SizedBox(
          height: 56,

          child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  primaryColor,

              foregroundColor:
                  Colors.white,

              elevation: 3,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
            ),

    onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => PaymentScreen(
        packageName: selectedPackage.name,
        coins: selectedPackage.coins,
        price: selectedPackage.price,
      ),
    ),
  );
},         

            child: Text(
              'Continue • ₹${formatPrice(selectedPackage.price)}',

              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ==================================================================
// VIP LEVELS
// ==================================================================

class VipLevelsScreen extends StatelessWidget {
  const VipLevelsScreen({super.key});

  static const Color primaryColor =
      Color(0xFF673AB7);

  // ===============================================================
  // CORRECT VIP STRUCTURE
  // ===============================================================

  static const Map<int, int> correctVipLevels = {
    1: 1000,
    2: 5000,
    3: 10000,
    4: 20000,
    5: 50000,
    6: 100000,
    7: 200000,
    8: 500000,
    9: 1000000,
    10: 2000000,
  };

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF9FF),

      appBar: AppBar(
        title: const Text(
          'VIP Levels',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xFFFFF9FF),

        foregroundColor: Colors.black,

        elevation: 0,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('vipLevels')
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

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Unable to load VIP levels.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final firestoreLevels =
              snapshot.data?.docs ?? [];

          // =========================================================
          // IMPORTANT:
          //
          // We use requiredCoins to determine the correct VIP level.
          // Firestore "level: 0" will never appear as VIP 0.
          // =========================================================

          final List<Map<String, int>> validLevels = [];

          for (final doc in firestoreLevels) {
            final data = doc.data();

            final int requiredCoins =
                _toInt(
              data['requiredCoins'],
            );

            if (requiredCoins <= 0) {
              continue;
            }

            int? correctLevel;

            for (final entry
                in correctVipLevels.entries) {
              if (entry.value ==
                  requiredCoins) {
                correctLevel =
                    entry.key;
                break;
              }
            }

            if (correctLevel != null) {
              validLevels.add({
                'level': correctLevel,
                'requiredCoins':
                    requiredCoins,
              });
            }
          }

          // =========================================================
          // If Firestore data is incomplete/wrong,
          // show the correct 1–10 structure instead.
          // =========================================================

          final Map<int, int>
              finalLevels = {};

          for (final item in validLevels) {
            finalLevels[
                    item['level']!] =
                item['requiredCoins']!;
          }

          for (final entry
              in correctVipLevels.entries) {
            finalLevels.putIfAbsent(
              entry.key,
              () => entry.value,
            );
          }

          final sortedLevels =
              finalLevels.entries.toList()
                ..sort(
                  (a, b) =>
                      a.key.compareTo(b.key),
                );

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
            ),

            itemCount:
                sortedLevels.length,

            itemBuilder:
                (context, index) {
              final entry =
                  sortedLevels[index];

              final int level =
                  entry.key;

              final int requiredCoins =
                  entry.value;

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),

                elevation: 2,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),

                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(
                      0xFFF0E7FF,
                    ),

                    child: const Icon(
                      Icons.star,
                      color: primaryColor,
                    ),
                  ),

                  title: Text(
                    'VIP $level',

                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Required Coins: '
                    '${_formatNumber(requiredCoins)}',

                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  trailing:
                      level == 10
                          ? const Icon(
                              Icons.workspace_premium,
                              color:
                                  Colors.amber,
                              size: 30,
                            )
                          : null,
                ),
              );
            },
          );
        },
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
