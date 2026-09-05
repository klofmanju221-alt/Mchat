import 'package:flutter/material.dart';

import 'wallet_service.dart';

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
        builder: (context, snapshot) {
          final coins = snapshot.data ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                          backgroundColor:
                              Colors.amber,
                          child: Icon(
                            Icons.monetization_on,
                            color:
                                Colors.deepPurple,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'My Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w600,
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
                        fontWeight:
                            FontWeight.w900,
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

              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.security,
                    color: Color(0xFF7137B5),
                  ),
                  title: Text(
                    'Secure Wallet',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Coin balance is read from your secure Firebase wallet.',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  title: Text(
                    'Verified Balance',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Coins cannot be added directly from the app.',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Secure recharge will be connected in Build #134.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Recharge Coins',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
