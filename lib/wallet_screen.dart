import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'wallet_service.dart';
import 'payment_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
      ),
      body: StreamBuilder<int>(
        stream: WalletService.instance.coinBalanceStream(),
        initialData: 0,
        builder: (context, snapshot) {
          final coins = snapshot.data ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // WALLET BALANCE
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF42106B),
                      Color(0xFF852CC5),
                      Color(0xFFE52D8A),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'My Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      formatCoins(coins),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Available Coins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECURITY
              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.security,
                    color: Color(0xFF7137B5),
                  ),
                  title: Text(
                    'Secure Wallet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Coin balance is read from your Firebase wallet.',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // VERIFIED BALANCE
              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  title: Text(
                    'Verified Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Coins cannot be added directly from the app.',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // RECHARGE
              FilledButton.icon(
                onPressed: () {
             Navigator.push(
            context,
            MaterialPageRoute(
            builder: (_) => const PaymentScreen(),
           ),
         );      
      },
                icon: const Icon(Icons.add),
                label: const Text(
                  'Recharge Coins',
                ),
              ),

              const SizedBox(height: 30),

              // TRANSACTION HISTORY TITLE
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              const _TransactionHistory(),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Please sign in to view transactions.',
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Transaction history is not available yet.',
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your verified wallet transactions will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final type =
                  data['type']?.toString() ?? 'Transaction';

              final description =
                  data['description']?.toString() ??
                      type;

              final amountValue = data['amount'];

              final amount = amountValue is num
                  ? amountValue.toInt()
                  : 0;

              final isCredit = amount >= 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    isCredit
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: isCredit
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(type),
                trailing: Text(
                  '${isCredit ? '+' : ''}$amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCredit
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
