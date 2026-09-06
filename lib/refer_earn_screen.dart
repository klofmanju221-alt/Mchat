import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'premium_theme.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() =>
      _ReferEarnScreenState();
}

class _ReferEarnScreenState
    extends State<ReferEarnScreen> {
  User? get _user =>
      FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>?
      get _userRef {
    final user = _user;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
  }

  Future<void> _copyReferralCode(
    String code,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: code),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Referral code copied',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _copyInvite(
    String code,
  ) async {
    final String message =
        'Join Mchat and enjoy Live, Rooms, PK and more!\n'
        'Use my Mchat referral code: $code';

    await Clipboard.setData(
      ClipboardData(text: message),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Invite message copied',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _createReferralCode(
    Map<String, dynamic> data,
  ) {
    final String existing =
        (data['referralCode'] ?? '').toString().trim();

    if (existing.isNotEmpty) {
      return existing;
    }

    final String mchatId =
        (data['mchatId'] ?? '').toString().trim();

    if (RegExp(r'^[0-9]{8}$').hasMatch(mchatId)) {
      return 'MCHAT-$mchatId';
    }

    return 'MCHAT-USER';
  }

  Future<void> _ensureReferralCode(
    Map<String, dynamic> data,
  ) async {
    final ref = _userRef;
    if (ref == null) return;

    final String existing =
        (data['referralCode'] ?? '').toString().trim();

    if (existing.isNotEmpty) return;

    final String mchatId =
        (data['mchatId'] ?? '').toString().trim();

    if (!RegExp(r'^[0-9]{8}$').hasMatch(mchatId)) {
      return;
    }

    await ref.set(
      {
        'referralCode': 'MCHAT-$mchatId',
        'successfulReferrals': 0,
        'referralCoins': 0,
        'referralUpdatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatNumber(int value) {
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

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user == null) {
      return Scaffold(
        backgroundColor: PremiumTheme.background,
        appBar: AppBar(
          title: const Text('Refer & Earn'),
        ),
        body: const Center(
          child: Text(
            'Please login again.',
            style: PremiumTheme.bodyText,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PremiumTheme.background,
      appBar: AppBar(
        title: const Text('Refer & Earn'),
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
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
                  'Unable to load referral data.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: PremiumTheme.bodyText,
                ),
              ),
            );
          }

          final data =
              snapshot.data?.data() ??
                  <String, dynamic>{};

          // Create referral code once when Mchat ID exists.
          _ensureReferralCode(data);

          final String referralCode =
              _createReferralCode(data);

          final int successfulReferrals =
              _toInt(
            data['successfulReferrals'],
          );

          final int referralCoins =
              _toInt(
            data['referralCoins'],
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              30,
            ),
            children: [
              // ==================================================
              // HERO
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.purpleGradient,
                  borderRadius:
                      BorderRadius.circular(25),
                  border: Border.all(
                    color: PremiumTheme.gold
                        .withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.purple
                          .withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    PremiumTheme.iconBox(
                      Icons.card_giftcard_rounded,
                      size: 70,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Invite Friends & Earn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Invite your friends to Mchat. '
                      'Eligible referrals will be verified '
                      'before rewards are credited.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style:
                            PremiumTheme.premiumButton(),
                        icon: const Icon(
                          Icons.copy_rounded,
                        ),
                        label: const Text(
                          'COPY INVITE',
                        ),
                        onPressed: () {
                          _copyInvite(
                            referralCode,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // REFERRAL CODE
              // ==================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration:
                    PremiumTheme.premiumCard(
                  radius: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          color: PremiumTheme.gold,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Your Referral Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(alpha: 0.25),
                        borderRadius:
                            BorderRadius.circular(15),
                        border: Border.all(
                          color: PremiumTheme.gold
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              referralCode,
                              style: const TextStyle(
                                color:
                                    PremiumTheme.gold,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _copyReferralCode(
                                referralCode,
                              );
                            },
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Your referral code is linked to your Mchat ID.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // STATISTICS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.people_alt_rounded,
                      _formatNumber(
                        successfulReferrals,
                      ),
                      'Successful Referrals',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      Icons.monetization_on_rounded,
                      _formatNumber(
                        referralCoins,
                      ),
                      'Referral Coins',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==================================================
              // HOW IT WORKS
              // ==================================================

              const Text(
                'How It Works',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _step(
                1,
                Icons.share_rounded,
                'Share',
                'Share your referral code with friends.',
              ),

              _step(
                2,
                Icons.person_add_alt_1_rounded,
                'Join',
                'Your friend registers for Mchat.',
              ),

              _step(
                3,
                Icons.verified_rounded,
                'Verify',
                'The referral is verified by the system.',
              ),

              _step(
                4,
                Icons.card_giftcard_rounded,
                'Earn',
                'Eligible referral rewards are credited.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // REFERRAL HISTORY
              // ==================================================

              const Text(
                'Referral History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _historySection(user.uid),

              const SizedBox(height: 22),

              // ==================================================
              // SECURITY NOTICE
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PremiumTheme.surface,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: PremiumTheme.gold
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: PremiumTheme.gold,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Referral rewards must be verified '
                        'by the backend. This screen does not '
                        'create or fake referral rewards.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
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

  Widget _statCard(
    IconData icon,
    String value,
    String title,
  ) {
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
          Icon(
            icon,
            color: PremiumTheme.gold,
            size: 31,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(
    int number,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: PremiumTheme.premiumCard(
        radius: 17,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient:
                  PremiumTheme.purpleGradient,
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumTheme.gold
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: PremiumTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: PremiumTheme.gold,
            size: 25,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historySection(String uid) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('referrals')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration:
                PremiumTheme.premiumCard(
              radius: 18,
            ),
            child: const Text(
              'No referral history available yet.',
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                color: PremiumTheme.gold,
              ),
            ),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration:
                PremiumTheme.premiumCard(
              radius: 18,
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: Colors.white38,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'No referrals yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your verified referrals will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();

            final String name =
                (data['name'] ??
                        data['referredName'] ??
                        'Mchat User')
                    .toString();

            final String status =
                (data['status'] ?? 'Pending')
                    .toString();

            final int reward =
                _toInt(
              data['rewardCoins'],
            );

            final bool completed =
                status.toLowerCase() ==
                    'completed';

            return Container(
              margin:
                  const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration:
                  PremiumTheme.premiumCard(
                radius: 17,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (completed
                              ? Colors.green
                              : PremiumTheme.gold)
                          .withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      completed
                          ? Icons.check_rounded
                          : Icons.schedule_rounded,
                      color: completed
                          ? Colors.greenAccent
                          : PremiumTheme.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: completed
                                ? Colors.greenAccent
                                : Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${_formatNumber(reward)}',
                    style: const TextStyle(
                      color: PremiumTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
