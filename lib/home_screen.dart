import 'package:flutter/material.dart';

import 'inbox_screen.dart';
import 'live_screen.dart';
import 'profile_screen.dart';
import 'payment_screen.dart';
import 'vip_levels_screen.dart' as vip;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color purple = Color(0xFF7B2CBF);
  static const Color deepPurple = Color(0xFF32104F);
  static const Color pink = Color(0xFFE83E8C);
  static const Color gold = Color(0xFFFFC107);
  static const Color background = Color(0xFFF7F3FA);

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
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  deepPurple,
                  purple,
                  pink,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: purple.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Mchat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'M Karnataka Voice Club',
                  style: TextStyle(
                    color: purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
          const SizedBox(width: 7),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 22,
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
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: TextField(
          controller: _searchController,
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
              color: purple,
            ),
            hintText:
                'Search people, rooms or Mchat ID',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: purple,
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
              vertical: 14,
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
        5,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              deepPurple,
              purple,
              pink,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: purple.withValues(
                alpha: 0.28,
              ),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -25,
              child: Icon(
                Icons.monetization_on_rounded,
                size: 125,
                color: Colors.white.withValues(
                  alpha: 0.07,
                ),
              ),
            ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: gold,
                      size: 25,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Coins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
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
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.14,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 17,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Recharge',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Available Coins',
                  style: TextStyle(
                    color: Colors.white60,
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
      height: 61,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          18,
          12,
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
                color: selected
                    ? purple
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? purple
                      : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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
        'color': pink,
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'title': 'VIP',
        'color': gold,
      },
      {
        'icon': Icons.chat_rounded,
        'title': 'Inbox',
        'color': purple,
      },
      {
        'icon': Icons.sports_esports_rounded,
        'title': 'Games',
        'color': Colors.orange,
      },
      {
        'icon': Icons.people_alt_rounded,
        'title': 'Family',
        'color': Colors.teal,
      },
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
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
                    const vip.VipLevelsScreen()
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
              width: 82,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: (item['color']
                              as Color)
                          .withValues(
                        alpha: 0.12,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color:
                          item['color'] as Color,
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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
        17,
        18,
        11,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
                  color: purple,
                  fontWeight: FontWeight.w800,
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
      height: 190,
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
              width: 165,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: index == 0
                      ? [
                          deepPurple,
                          purple,
                        ]
                      : [
                          const Color(0xFF49245E),
                          pink,
                        ],
                ),
                borderRadius:
                    BorderRadius.circular(21),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      room['icon'] as IconData,
                      size: 95,
                      color: Colors.white
                          .withValues(alpha: 0.10),
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
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w900,
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
                            fontWeight:
                                FontWeight.w900,
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
                              Icons
                                  .visibility_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room['viewers']
                                  as String,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 10,
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
          crossAxisSpacing: 10,
          mainAxisSpacing: 11,
          childAspectRatio: 0.78,
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
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
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
                          const LinearGradient(
                        colors: [
                          Color(0xFFF2E8FA),
                          Color(0xFFFFEAF3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: purple,
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
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feature['subtitle'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
            const VipLevelsScreen(),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF24102F),
                Color(0xFF612A7E),
              ],
            ),
            borderRadius:
                BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: gold.withValues(
                    alpha: 0.16,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .workspace_premium_rounded,
                  color: gold,
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
                        fontWeight:
                            FontWeight.w900,
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 17,
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
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(21),
            border: Border.all(
              color: purple.withValues(
                alpha: 0.15,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E6F9),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: purple,
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
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Invite friends to Mchat',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: purple,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
