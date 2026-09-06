import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mchat_id_service.dart';
import 'payment_screen.dart';
import 'premium_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Scaffold(
        backgroundColor: PremiumTheme.background,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text(
            'Please login again',
            style: PremiumTheme.bodyText,
          ),
        ),
      );
    }

    final String uid = firebaseUser.uid;

    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
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
                color: PremiumTheme.gold,
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
                  style: PremiumTheme.bodyText,
                ),
              ),
            );
          }

          final Map<String, dynamic> data =
              snapshot.data?.data() ?? <String, dynamic>{};

          final String email =
              (data['email'] ?? firebaseUser.email ?? 'No email').toString();

          final String name =
              (data['name'] ??
                      firebaseUser.displayName ??
                      'Mchat User')
                  .toString();

          final String mchatId =
              (data['mchatId'] ?? 'Creating...').toString();

          final int coins = _toInt(data['coins']);
          final int vipLevel = _toInt(data['vipLevel']);

          final bool isOwner =
              data['isOwner'] == true ||
              data['role']?.toString().toLowerCase() == 'owner';

          final String? photoUrl = firebaseUser.photoURL;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              // =====================================================
              // PREMIUM PROFILE HEADER
              // =====================================================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: PremiumTheme.purpleGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: PremiumTheme.gold.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.purple.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          PremiumTheme.gold.withValues(alpha: 0.18),
                      backgroundImage:
                          photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: PremiumTheme.gold,
                              size: 58,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // MCHAT ID
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: PremiumTheme.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.badge_rounded,
                            color: PremiumTheme.gold,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mchat ID',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                mchatId,
                                style: const TextStyle(
                                  color: PremiumTheme.gold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =====================================================
              // COINS + VIP
              // =====================================================

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.monetization_on_rounded,
                      title: 'Coins',
                      value: _formatNumber(coins),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.workspace_premium_rounded,
                      title: 'VIP Level',
                      value: 'VIP $vipLevel',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =====================================================
              // SEARCH MCHAT ID
              // =====================================================

              _menuItem(
                context,
                Icons.search_rounded,
                'Search Mchat ID',
                'Find another Mchat user',
                () {
                  _showMchatSearch(context);
                },
              ),

              // =====================================================
              // OWNER DASHBOARD
              // =====================================================

              if (isOwner) ...[
                const SizedBox(height: 2),
                _ownerDashboardButton(context),
              ],

              const SizedBox(height: 2),

              // =====================================================
              // EDIT PROFILE
              // =====================================================

              _menuItem(
                context,
                Icons.edit_rounded,
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
                Icons.account_balance_wallet_rounded,
                'Recharge Coins',
                'Buy coins',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CoinPackagesScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // REFER & EARN
              // =====================================================

              _menuItem(
                context,
                Icons.card_giftcard_rounded,
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
                Icons.settings_rounded,
                'Settings',
                'Application settings',
                () {
                  _showMessage(
                    context,
                    'Settings will be connected next.',
                  );
                },
              ),

              const SizedBox(height: 14),

              // =====================================================
              // LOGOUT
              // =====================================================

              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: PremiumTheme.gold,
                  ),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: PremiumTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: PremiumTheme.outlinedButton(),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // OWNER STATUS
              // =====================================================

              if (isOwner)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.purpleGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PremiumTheme.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: PremiumTheme.gold,
                        size: 35,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'OWNER ACCOUNT',
                        style: TextStyle(
                          color: PremiumTheme.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mchat ID: $mchatId\n'
                        'VIP Level: $vipLevel\n'
                        'Coins: ${_formatNumber(coins)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
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
  // OWNER DASHBOARD BUTTON
  // ===============================================================

  static Widget _ownerDashboardButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: PremiumTheme.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.gold.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
        title: const Text(
          'Owner Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Manage Mchat application',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black,
          size: 30,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: PremiumTheme.premiumCard(
        radius: 18,
      ),
      child: Column(
        children: [
          PremiumTheme.iconBox(
            icon,
            size: 48,
          ),
          const SizedBox(height: 9),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PremiumTheme.gold,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PremiumTheme.premiumCard(
        radius: 18,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        leading: PremiumTheme.iconBox(
          icon,
          size: 50,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: PremiumTheme.gold,
          size: 29,
        ),
        onTap: onTap,
      ),
    );
  }

  // ===============================================================
  // MCHAT ID SEARCH
  // ===============================================================

  static void _showMchatSearch(BuildContext context) {
    final TextEditingController controller =
        TextEditingController();

    bool loading = false;
    Map<String, dynamic>? result;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PremiumTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> search() async {
              final String id = controller.text.trim();

              if (!RegExp(r'^[0-9]{8}$').hasMatch(id)) {
                setState(() {
                  result = null;
                  error = 'Enter a valid 8-digit Mchat ID.';
                });
                return;
              }

              setState(() {
                loading = true;
                result = null;
                error = null;
              });

              try {
                final found =
                    await MchatIdService.findByMchatId(id);

                if (!context.mounted) return;

                setState(() {
                  loading = false;
                  result = found;

                  if (found == null) {
                    error = 'Mchat ID not found.';
                  }
                });
              } catch (e) {
                if (!context.mounted) return;

                setState(() {
                  loading = false;
                  error = 'Search failed. Please try again.';
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          PremiumTheme.iconBox(
                            Icons.search_rounded,
                            size: 50,
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Text(
                              'Search Mchat ID',
                              style: TextStyle(
                                color: PremiumTheme.gold,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Mchat ID',
                          hintText: 'Enter 8-digit Mchat ID',
                          prefixIcon: Icon(
                            Icons.badge_rounded,
                          ),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: PremiumTheme.premiumButton(),
                          icon: const Icon(
                            Icons.search_rounded,
                          ),
                          label: Text(
                            loading ? 'Searching...' : 'Search User',
                          ),
                          onPressed: loading ? null : search,
                        ),
                      ),

                      if (loading) ...[
                        const SizedBox(height: 18),
                        const CircularProgressIndicator(
                          color: PremiumTheme.gold,
                        ),
                      ],

                      if (error != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],

                      if (result != null) ...[
                        const SizedBox(height: 18),
                        _searchResultCard(result!),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===============================================================
  // SEARCH RESULT
  // ===============================================================

  static Widget _searchResultCard(
    Map<String, dynamic> data,
  ) {
    final String name =
        (data['name'] ?? 'Mchat User').toString();

    final String email =
        (data['email'] ?? 'No email').toString();

    final String mchatId =
        (data['mchatId'] ?? '').toString();

    final String? photoUrl =
        data['photoUrl']?.toString().isNotEmpty == true
            ? data['photoUrl'].toString()
            : data['photoURL']?.toString();

    final bool isOwner =
        data['isOwner'] == true ||
        data['role']?.toString().toLowerCase() == 'owner';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: PremiumTheme.premiumCard(
        radius: 20,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor:
                PremiumTheme.gold.withValues(alpha: 0.16),
            backgroundImage:
                photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? const Icon(
                    Icons.person,
                    color: PremiumTheme.gold,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              gradient: PremiumTheme.purpleGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PremiumTheme.gold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Mchat ID: $mchatId',
              style: const TextStyle(
                color: PremiumTheme.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: PremiumTheme.gold,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  'OWNER',
                  style: TextStyle(
                    color: PremiumTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
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
    if (value is int) return value;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
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
                color: PremiumTheme.gold,
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
                  style: PremiumTheme.bodyText,
                ),
              ),
            );
          }

          final users = snapshot.data?.docs ?? [];

          int totalCoins = 0;
          int ownerCount = 0;
          int volunteerCount = 0;

          for (final doc in users) {
            final data = doc.data();

            totalCoins += _toInt(data['coins']);

            final String role =
                data['role']?.toString().toLowerCase() ?? '';

            if (data['isOwner'] == true || role == 'owner') {
              ownerCount++;
            }

            if (data['isVolunteer'] == true ||
                role == 'volunteer') {
              volunteerCount++;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: PremiumTheme.purpleGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: PremiumTheme.gold.withValues(alpha: 0.55),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: PremiumTheme.gold,
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
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // STATISTICS
              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      Icons.people_alt_rounded,
                      'Users',
                      users.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dashboardCard(
                      Icons.monetization_on_rounded,
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
                      Icons.verified_user_rounded,
                      'Owners',
                      ownerCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dashboardCard(
                      Icons.support_agent_rounded,
                      'Volunteers',
                      volunteerCount.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // MANAGE USERS
              _ownerMenu(
                context,
                Icons.people_alt_rounded,
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
                Icons.monetization_on_rounded,
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
                Icons.workspace_premium_rounded,
                'VIP Levels',
                'View VIP levels',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VipLevelsScreen(),
                    ),
                  );
                },
              ),

              // OWNER SETTINGS
              _ownerMenu(
                context,
                Icons.settings_rounded,
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

  static Widget _dashboardCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
      ),
      decoration: PremiumTheme.premiumCard(
        radius: 18,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: PremiumTheme.gold,
            size: 30,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PremiumTheme.premiumCard(
        radius: 18,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: PremiumTheme.iconBox(
          icon,
          size: 50,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: PremiumTheme.gold,
        ),
        onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Manage Users'),
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
                color: PremiumTheme.gold,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load users.\n\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: PremiumTheme.bodyText,
              ),
            );
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: PremiumTheme.bodyText,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data();

              final String name =
                  (data['name'] ?? 'Mchat User').toString();

              final String email =
                  (data['email'] ?? 'No email').toString();

              final String mchatId =
                  (data['mchatId'] ?? 'Not assigned').toString();

              final int coins = _toInt(data['coins']);
              final int vip = _toInt(data['vipLevel']);

              final String? photoUrl =
                  (data['photoUrl'] ?? data['photoURL'])?.toString();

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: PremiumTheme.premiumCard(
                  radius: 18,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        PremiumTheme.purple.withValues(alpha: 0.35),
                    backgroundImage:
                        photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: PremiumTheme.gold,
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Mchat ID: $mchatId\n'
                    '$email\n'
                    'Coins: ${_formatNumber(coins)} • VIP: $vip',
                    style: const TextStyle(
                      color: Colors.white60,
                      height: 1.45,
                    ),
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

    if (value is num) {
      return value.toInt();
    }

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
// COIN PACKAGE MODEL
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


// ==================================================================
// COIN PACKAGES
// ==================================================================

class CoinPackagesScreen extends StatefulWidget {
  const CoinPackagesScreen({super.key});

  @override
  State<CoinPackagesScreen> createState() =>
      _CoinPackagesScreenState();
}

class _CoinPackagesScreenState
    extends State<CoinPackagesScreen> {
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
    if (value < 1000) {
      return value.toString();
    }

    final String number = value.toString();
    final StringBuffer result = StringBuffer();
    int count = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      result.write(number[i]);
      count++;

      if (count == 3 && i != 0) {
        result.write(',');
        count = 0;
      }
    }

    return result.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final CoinPackage selectedPackage =
        packages[selectedIndex];

    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Coin Packages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          110,
        ),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final CoinPackage package = packages[index];
          final bool selected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: selected
                    ? PremiumTheme.purpleGradient
                    : null,
                color: selected
                    ? null
                    : PremiumTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PremiumTheme.gold.withValues(
                    alpha: selected ? 0.85 : 0.35,
                  ),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: PremiumTheme.goldGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.black,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${formatCoins(package.coins)} Coins',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${formatPrice(package.price)}',
                          style: const TextStyle(
                            color: PremiumTheme.gold,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected
                        ? PremiumTheme.gold
                        : Colors.white38,
                    size: 29,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          14,
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: PremiumTheme.premiumButton(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentScreen(),
                ),
              );
            },
            child: Text(
              'Continue • ₹${formatPrice(selectedPackage.price)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('VIP Levels'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('vipLevels')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: PremiumTheme.gold,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load VIP levels.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: PremiumTheme.bodyText,
                ),
              ),
            );
          }

          final firestoreLevels =
              snapshot.data?.docs ?? [];

          final Map<int, int> finalLevels = {};

          for (final doc in firestoreLevels) {
            final data = doc.data();

            final int requiredCoins =
                _toInt(data['requiredCoins']);

            if (requiredCoins <= 0) {
              continue;
            }

            for (final entry
                in correctVipLevels.entries) {
              if (entry.value == requiredCoins) {
                finalLevels[entry.key] =
                    requiredCoins;
                break;
              }
            }
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
                  (a, b) => a.key.compareTo(b.key),
                );

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              25,
            ),
            itemCount: sortedLevels.length,
            itemBuilder: (context, index) {
              final entry = sortedLevels[index];

              final int level = entry.key;
              final int requiredCoins = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: PremiumTheme.premiumCard(
                  radius: 18,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: PremiumTheme.purpleGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumTheme.gold.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: const TextStyle(
                          color: PremiumTheme.gold,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'VIP $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Required Coins: '
                    '${_formatNumber(requiredCoins)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  trailing: level == 10
                      ? const Icon(
                          Icons.workspace_premium_rounded,
                          color: PremiumTheme.gold,
                          size: 31,
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: PremiumTheme.gold,
                          size: 28,
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

    if (value is num) {
      return value.toInt();
    }

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
