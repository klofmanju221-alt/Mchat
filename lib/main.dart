// =====================================================
// PART 3
// VIP + COINS + GIFTS + REFER & EARN + SETTINGS
// =====================================================

// ================= VIP =================

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  final List<int> vipCoins = const [
    1000,
    5000,
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Levels'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final level = index + 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 28,
                child: Text(
                  '$level',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                'VIP $level',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Required coins: ${vipCoins[index]}',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('VIP $level'),
                      content: Text(
                        'VIP $level requires '
                        '${vipCoins[index]} coins.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ================= COINS =================

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});

  final List<Map<String, dynamic>> packages = const [
    {
      'coins': 100,
      'price': '₹10',
    },
    {
      'coins': 500,
      'price': '₹50',
    },
    {
      'coins': 1000,
      'price': '₹100',
    },
    {
      'coins': 5000,
      'price': '₹500',
    },
    {
      'coins': 10000,
      'price': '₹1,000',
    },
    {
      'coins': 50000,
      'price': '₹5,000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coins & Recharge'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFB300),
                  Color(0xFFFF8F00),
                ],
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 65,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'My Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '0 Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Recharge Packages',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...packages.map(
            (package) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.monetization_on),
                ),
                title: Text(
                  '${package['coins']} Coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  package['price'],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Recharge',
                          ),
                          content: Text(
                            '${package['coins']} Coins\n'
                            'Price: ${package['price']}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Payment gateway will be connected with the real backend.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Continue',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Recharge'),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.green,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payments will be processed securely '
                      'when the real payment gateway is connected.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= GIFTS =================

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  final List<Map<String, dynamic>> gifts = const [
    {
      'name': 'Rose',
      'coins': 10,
      'icon': Icons.local_florist,
    },
    {
      'name': 'Heart',
      'coins': 50,
      'icon': Icons.favorite,
    },
    {
      'name': 'Star',
      'coins': 100,
      'icon': Icons.star,
    },
    {
      'name': 'Crown',
      'coins': 500,
      'icon': Icons.workspace_premium,
    },
    {
      'name': 'Gift Box',
      'coins': 1000,
      'icon': Icons.card_giftcard,
    },
    {
      'name': 'Diamond',
      'coins': 5000,
      'icon': Icons.diamond,
    },
    {
      'name': 'Super Gift',
      'coins': 10000,
      'icon': Icons.auto_awesome,
    },
    {
      'name': 'Royal Gift',
      'coins': 50000,
      'icon': Icons.emoji_events,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gifts'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gifts.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final gift = gifts[index];

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        gift['name'] as String,
                      ),
                      content: Text(
                        'Gift cost: '
                        '${gift['coins']} Coins',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gift sending will be connected to the real coin system.',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Send Gift',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    gift['icon'] as IconData,
                    size: 52,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    gift['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${gift['coins']} Coins',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= REFER & EARN =================

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 60,
              child: Icon(
                Icons.people,
                size: 65,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Invite Friends & Earn',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Invite your friends to join Mchat '
              'and earn rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.deepPurple.withOpacity(.08),
              ),
              child: const Column(
                children: [
                  Text(
                    'Your Referral Code',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'MCHAT0000',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Share referral link will be connected next.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text(
                  'Share Referral',
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Referral history will appear here.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text(
                  'Referral History',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SETTINGS =================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool notifications = true;
  bool sound = true;
  bool vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'General',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Notifications',
                  ),
                  subtitle: const Text(
                    'Receive Mchat notifications',
                  ),
                  value: notifications,
                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Sound',
                  ),
                  subtitle: const Text(
                    'Chat and room sounds',
                  ),
                  value: sound,
                  onChanged: (value) {
                    setState(() {
                      sound = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Vibration',
                  ),
                  subtitle: const Text(
                    'Vibrate for notifications',
                  ),
                  value: vibration,
                  onChanged: (value) {
                    setState(() {
                      vibration = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person,
                  ),
                  title: const Text(
                    'My Profile',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.lock,
                  ),
                  title: const Text(
                    'Privacy & Security',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.block,
                  ),
                  title: const Text(
                    'Blocked Users',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.info_outline,
                  ),
                  title: Text(
                    'About Mchat',
                  ),
                  subtitle: Text(
                    'Version 1.0.0',
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                  ),
                  title: const Text(
                    'Terms & Conditions',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                  ),
                  title: const Text(
                   Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Logout will be connected to authentication.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
            label: const Text(
              'Logout',
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PART 3 END
// =====================================================
