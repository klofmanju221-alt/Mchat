import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'wallet_service.dart';
import 'payment_screen.dart';
import 'premium_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color gold = PremiumTheme.gold;
  static const Color brightGold = PremiumTheme.brightGold;
  static const Color lightGold = PremiumTheme.lightGold;
  static const Color purple = PremiumTheme.purple;
  static const Color deepPurple = PremiumTheme.deepPurple;
  static const Color background = PremiumTheme.background;
  static const Color surface = PremiumTheme.surface;
  static const Color surface2 = PremiumTheme.surface2;

  String formatCoins(int coins) {
    if (coins >= 1000000) {
      final value = coins / 1000000;

      return '${value.toStringAsFixed(
        value % 1 == 0 ? 0 : 1,
      )}M';
    }

    if (coins >= 1000) {
      final value = coins / 1000;

      return '${value.toStringAsFixed(
        value % 1 == 0 ? 0 : 1,
      )}K';
    }

    return coins.toString();
  }

  String formatFullCoins(int coins) {
    return coins.toString();
  }

  void _openPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(),
      ),
    );
  }

  void _showWalletInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: gold,
              ),
              SizedBox(width: 9),
              Text(
                'Wallet',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your coin balance is connected to your Firebase wallet. Verified transactions are displayed in Transaction History.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: gold,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Wallet',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showWalletInfo(context);
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: gold,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.premiumBackground,
        ),
        child: SafeArea(
          child: StreamBuilder<int>(
            stream:
                WalletService.instance.coinBalanceStream(),
            initialData: 0,
            builder: (context, snapshot) {
              final coins = snapshot.data ?? 0;

              return RefreshIndicator(
                color: gold,
                backgroundColor: surface,
                onRefresh: () async {
                  await Future<void>.delayed(
                    const Duration(milliseconds: 500),
                  );
                },
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    35,
                  ),
                  children: [
                    _buildVaultHeader(),
                    const SizedBox(height: 18),
                    _buildBalanceCard(
                      context,
                      coins,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                    const SizedBox(height: 18),
                    _buildSecurityCards(),
                    const SizedBox(height: 22),
                    _buildHistoryHeader(),
                    const SizedBox(height: 12),
                    const _TransactionHistory(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVaultHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        17,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF160A20),
            Color(0xFF32104F),
            Color(0xFF4A148C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: PremiumTheme.goldGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.28),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF5A3000),
              size: 33,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat Royal Wallet',
                  style: TextStyle(
                    color: gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your secure digital coin vault',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: gold,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    int coins,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE082),
            Color(0xFFFFC107),
            Color(0xFFB8860B),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: lightGold,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -20,
            child: Icon(
              Icons.monetization_on_rounded,
              size: 135,
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Icon(
              Icons.diamond_rounded,
              size: 85,
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.30,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFF5A3000),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TOTAL COINS',
                    style: TextStyle(
                      color: Color(0xFF5A3000),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                formatCoins(coins),
                style: const TextStyle(
                  color: Color(0xFF351B00),
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatFullCoins(coins)} Available Coins',
                style: const TextStyle(
                  color: Color(0xFF633700),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openPayment(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF32104F),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: gold,
                  ),
                  label: const Text(
                    'RECHARGE COINS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            icon: Icons.add_circle_rounded,
            title: 'Recharge',
            subtitle: 'Buy Coins',
            onTap: () {
              _openPayment(context);
            },
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _actionCard(
            icon: Icons.receipt_long_rounded,
            title: 'History',
            subtitle: 'Transactions',
            onTap: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Transaction history is shown below.',
                  ),
                  behavior:
                      SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                surface2,
                surface,
              ],
            ),
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: gold.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.purpleGradient,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: gold.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  color: gold,
                  size: 23,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCards() {
    return Column(
      children: [
        _infoCard(
          icon: Icons.shield_rounded,
          title: 'Secure Wallet',
          subtitle:
              'Coin balance is read from your Firebase wallet.',
          iconBackground: purple,
        ),
        const SizedBox(height: 10),
        _infoCard(
          icon: Icons.verified_rounded,
          title: 'Verified Balance',
          subtitle:
              'Coins cannot be added directly from the app.',
          iconBackground: const Color(0xFF176B4D),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground.withValues(
                alpha: 0.28,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: gold.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(
              icon,
              color: gold,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: gold,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            gradient: PremiumTheme.goldGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Verified wallet activity',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: gold.withValues(alpha: 0.20),
            ),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: gold,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: PremiumTheme.gold.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.login_rounded,
              color: PremiumTheme.gold,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'Please sign in to view transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ledger')
          .where(
            'uid',
            isEqualTo: user.uid,
          )
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PremiumTheme.surface,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: PremiumTheme.gold,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: PremiumTheme.surface,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: PremiumTheme.gold.withValues(
                  alpha: 0.15,
                ),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: PremiumTheme.gold,
                  size: 38,
                ),
                SizedBox(height: 10),
                Text(
                  'Transaction history is not available yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  PremiumTheme.surface2,
                  PremiumTheme.surface,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(21),
              border: Border.all(
                color: PremiumTheme.gold.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: PremiumTheme.gold,
                ),
                SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your verified wallet transactions will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: PremiumTheme.surface,
            borderRadius:
                BorderRadius.circular(21),
            border: Border.all(
              color: PremiumTheme.gold.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(21),
            child: ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: PremiumTheme.gold
                      .withValues(alpha: 0.10),
                );
              },
              itemBuilder: (context, index) {
                final data = docs[index].data();

                final type =
                    data['type']?.toString() ??
                        'Transaction';

                final description =
                    data['description']
                            ?.toString() ??
                        type;

                final amountValue =
                    data['amount'];

                final amount =
                    amountValue is num
                        ? amountValue.toInt()
                        : 0;

                final isCredit = amount >= 0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isCredit
                              ? const Color(
                                  0xFF176B4D,
                                ).withValues(
                                  alpha: 0.25,
                                )
                              : const Color(
                                  0xFF7A1F35,
                                ).withValues(
                                  alpha: 0.25,
                                ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCredit
                                ? Colors.green
                                    .withValues(
                                    alpha: 0.35,
                                  )
                                : Colors.red
                                    .withValues(
                                    alpha: 0.35,
                                  ),
                          ),
                        ),
                        child: Icon(
                          isCredit
                              ? Icons
                                  .arrow_downward_rounded
                              : Icons
                                  .arrow_upward_rounded,
                          color: isCredit
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              description,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isCredit ? '+' : ''}$amount',
                        style: TextStyle(
                          color: isCredit
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
