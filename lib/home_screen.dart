import 'package:flutter/material.dart';

import 'inbox_screen.dart';
import 'live_screen.dart';
import 'profile_screen.dart';
import 'payment_screen.dart';
import 'vip_levels_screen.dart' as vip;
import 'premium_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color gold = PremiumTheme.gold;
  static const Color brightGold = PremiumTheme.brightGold;
  static const Color lightGold = PremiumTheme.lightGold;
  static const Color purple = PremiumTheme.purple;
  static const Color deepPurple = PremiumTheme.deepPurple;
  static const Color darkPurple = PremiumTheme.darkPurple;
  static const Color background = PremiumTheme.background;
  static const Color surface = PremiumTheme.surface;

  final TextEditingController _searchController =
      TextEditingController();

  int selectedCategory = 0;

  final List<String> categories = [
    'For You',
    'Live',
    'Rooms',
    'PK',
    'Games',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title UI is ready for connection.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: gold.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.premiumBackground,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildTopHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              SliverToBoxAdapter(
                child: _buildCoinsCard(),
              ),
              SliverToBoxAdapter(
                child: _buildCategories(),
              ),
              SliverToBoxAdapter(
                child: _buildQuickActions(),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Live Rooms',
                  'See who is live now',
                  () => _openScreen(
                    const LiveScreen(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildLivePreview(),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Mchat Features',
                  'Explore everything in Mchat',
                  null,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildFeatureGrid(),
              ),
              SliverToBoxAdapter(
                child: _buildVipBanner(),
              ),
              SliverToBoxAdapter(
                child: _buildReferBanner(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: PremiumTheme.goldGradient,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: lightGold.withValues(alpha: 0.75),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'M Karnataka Voice Club',
                  style: TextStyle(
                    color: lightGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _headerButton(
            Icons.notifications_none_rounded,
            () => _showComingSoon(
              'Notifications',
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            Icons.person_outline_rounded,
            () => _openScreen(
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkPurple,
                purple,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: gold.withValues(alpha: 0.45),
            ),
          ),
          child: Icon(
            icon,
            color: gold,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: gold.withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _showComingSoon(
                'Search: ${value.trim()}',
              );
            }
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: gold,
            ),
            hintText:
                'Search people, rooms or Mchat ID',
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: lightGold,
              ),
              onPressed: () {
                _showComingSoon(
                  'Search filters',
                );
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        6,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF21002F),
              Color(0xFF4A148C),
              Color(0xFF7B1FA2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gold.withValues(alpha: 0.50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: purple.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -24,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 130,
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            Positioned(
              right: 35,
              bottom: -20,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 70,
                color: gold.withValues(
                  alpha: 0.08,
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient:
                            PremiumTheme.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.black,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Premium Wallet',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _openScreen(
                          const PaymentScreen(),
                        );
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              PremiumTheme.goldGradient,
                          borderRadius:
                              BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(
                                alpha: 0.20,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.black,
                              size: 17,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Recharge',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Available Coins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final selected =
              selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                gradient: selected
                    ? PremiumTheme.goldGradient
                    : null,
                color: selected
                    ? null
                    : surface,
                borderRadius:
                    BorderRadius.circular(21),
                border: Border.all(
                  color: selected
                      ? gold
                      : gold.withValues(alpha: 0.25),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: gold.withValues(
                            alpha: 0.20,
                          ),
                          blurRadius: 9,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selected
                        ? Colors.black
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.video_call_rounded,
        'title': 'Go Live',
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'title': 'VIP',
      },
      {
        'icon': Icons.chat_rounded,
        'title': 'Inbox',
      },
      {
        'icon': Icons.sports_esports_rounded,
        'title': 'Games',
      },
      {
        'icon': Icons.people_alt_rounded,
        'title': 'Family',
      },
    ];

    return SizedBox(
      height: 116,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final item = actions[index];

          return GestureDetector(
            onTap: () {
              switch (index) {
                case 0:
                  _openScreen(
                    const LiveScreen(),
                  );
                  break;
                case 1:
                  _openScreen(
                    const vip.VipLevelsScreen(),
                  );
                  break;
                case 2:
                  _openScreen(
                    const InboxScreen(),
                  );
                  break;
                default:
                  _showComingSoon(
                    item['title'] as String,
                  );
              }
            },
            child: Container(
              width: 84,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 11,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF21102F),
                    Color(0xFF160C22),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: gold.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.20,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      gradient:
                          PremiumTheme.purpleGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            gold.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        11,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              gradient: PremiumTheme.goldGradient,
              borderRadius:
                  BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
    final rooms = [
      {
        'title': 'Mchat Live Room',
        'name': 'Live Host',
        'viewers': '0',
        'icon': Icons.mic_external_on_rounded,
      },
      {
        'title': 'Music Room',
        'name': 'Singer Live',
        'viewers': '0',
        'icon': Icons.music_note_rounded,
      },
      {
        'title': 'Talk Room',
        'name': 'Mchat Family',
        'viewers': '0',
        'icon': Icons.people_rounded,
      },
    ];

    return SizedBox(
      height: 195,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final room = rooms[index];

          return GestureDetector(
            onTap: () {
              _openScreen(
                const LiveScreen(),
              );
            },
            child: Container(
              width: 168,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: index == 0
                      ? const [
                          Color(0xFF21002F),
                          Color(0xFF7B1FA2),
                        ]
                      : const [
                          Color(0xFF32104F),
                          Color(0xFF6A1B9A),
                        ],
                ),
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: gold.withValues(alpha: 0.38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: gold.withValues(
                            alpha: 0.30,
                          ),
                        ),
                      ),
                      child: Icon(
                        room['icon'] as IconData,
                        color: gold,
                        size: 21,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -12,
                    child: Icon(
                      room['icon'] as IconData,
                      size: 105,
                      color: Colors.white
                          .withValues(alpha: 0.06),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                PremiumTheme.goldGradient,
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          room['title'] as String,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          room['name'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              color: lightGold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room['viewers'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: gold,
                              size: 17,
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFeatureGrid() {
    final features = [
      {
        'icon': Icons.home_work_rounded,
        'title': 'Family Room',
        'subtitle': '30 Seats',
      },
      {
        'icon': Icons.flash_on_rounded,
        'title': 'PK Battle',
        'subtitle': 'Challenge',
      },
      {
        'icon': Icons.sports_esports_rounded,
        'title': 'Room Mode',
        'subtitle': 'Play Center',
      },
      {
        'icon': Icons.card_giftcard_rounded,
        'title': 'Gifts',
        'subtitle': 'Send Gifts',
      },
      {
        'icon': Icons.music_note_rounded,
        'title': 'Music',
        'subtitle': 'Song Library',
      },
      {
        'icon': Icons.mic_rounded,
        'title': 'Recording',
        'subtitle': 'Record Voice',
      },
      {
        'icon': Icons.photo_camera_rounded,
        'title': 'Media',
        'subtitle': 'Create',
      },
      {
        'icon': Icons.share_rounded,
        'title': 'Refer & Earn',
        'subtitle': 'Invite Friends',
      },
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 9,
          mainAxisSpacing: 11,
          childAspectRatio: 0.76,
        ),
        itemBuilder: (context, index) {
          final feature = features[index];

          return GestureDetector(
            onTap: () {
              _showComingSoon(
                feature['title'] as String,
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient:
                    PremiumTheme.purpleGradient,
                borderRadius:
                    BorderRadius.circular(17),
                border: Border.all(
                  color: gold.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 7,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient:
                          PremiumTheme.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gold.withValues(
                            alpha: 0.15,
                          ),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feature['subtitle'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8.5,
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

  Widget _buildVipBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        22,
        18,
        10,
      ),
      child: GestureDetector(
        onTap: () {
          _openScreen(
            const vip.VipLevelsScreen(),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient:
                PremiumTheme.purpleGradient,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: gold.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: purple.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.goldGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.black,
                  size: 31,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIP Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'VIP 1 → VIP 10 • Exclusive Benefits',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: gold.withValues(
                    alpha: 0.14,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: gold,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        0,
      ),
      child: GestureDetector(
        onTap: () {
          _showComingSoon(
            'Refer & Earn',
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF21102F),
                Color(0xFF160C22),
              ],
            ),
            borderRadius:
                BorderRadius.circular(21),
            border: Border.all(
              color: gold.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.goldGradient,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.black,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refer & Earn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Invite friends to Mchat',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: purple.withValues(
                    alpha: 0.50,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: gold,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
