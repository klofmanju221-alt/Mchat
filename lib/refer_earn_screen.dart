import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  static const Color bg = Color(0xFF0B0713);
  static const Color card = Color(0xFF171022);
  static const Color purple = Color(0xFF8B3DFF);
  static const Color pink = Color(0xFFFF4FA3);
  static const Color gold = Color(0xFFFFD66B);

  // UI-only referral code.
  // Actual referral ownership/rewards must be verified by backend.
  final String referralCode = 'MCHAT2026';

  int successfulReferrals = 0;
  int earnedCoins = 0;

  final List<_ReferralHistoryItem> history = const [
    _ReferralHistoryItem(
      name: 'New User',
      status: 'Pending',
      reward: 0,
    ),
    _ReferralHistoryItem(
      name: 'Friend Joined',
      status: 'Completed',
      reward: 500,
    ),
  ];

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyInvite() {
    final text =
        'Join Mchat and enjoy Live, PK, Rooms, Games and more!\n'
        'Use my referral code: $referralCode';

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite message copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShareInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                const Icon(
                  Icons.share_rounded,
                  color: pink,
                  size: 42,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Share Your Referral',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Copy your invite message and share it with your friends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _copyInvite();
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text(
                      'COPY INVITE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 18),
              _buildReferralCodeCard(),
              const SizedBox(height: 18),
              _buildStats(),
              const SizedBox(height: 22),
              _buildSectionTitle('How It Works'),
              const SizedBox(height: 12),
              _buildSteps(),
              const SizedBox(height: 24),
              _buildSectionTitle('Referral History'),
              const SizedBox(height: 12),
              _buildHistory(),
              const SizedBox(height: 22),
              _buildSecurityNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B146B),
            Color(0xFF7C267F),
            Color(0xFFB52D70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: gold.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: gold,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Invite Friends & Earn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Invite your friends to Mchat and earn rewards '
            'when eligible referrals are verified.',
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
              onPressed: _showShareInfo,
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'SHARE NOW',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                color: gold,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Your Referral Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: gold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copyReferralCode,
                  tooltip: 'Copy',
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Share this code with your friends.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.people_alt_rounded,
            '$successfulReferrals',
            'Referrals',
            purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            Icons.monetization_on_rounded,
            '$earnedCoins',
            'Earned Coins',
            gold,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String title,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSteps() {
    final steps = [
      (
        Icons.share_rounded,
        'Invite',
        'Share your referral code with friends.',
      ),
      (
        Icons.person_add_alt_1_rounded,
        'Join',
        'Your friend creates an Mchat account.',
      ),
      (
        Icons.verified_rounded,
        'Verify',
        'The referral is checked by the system.',
      ),
      (
        Icons.card_giftcard_rounded,
        'Earn',
        'Eligible rewards are credited after verification.',
      ),
    ];

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final item = steps[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: purple.withValues(alpha: 0.16),
                    ),
                    child: Icon(
                      item.$1,
                      color: index == 3 ? gold : pink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${item.$2}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.3,
                          ),
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

  Widget _buildHistory() {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
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
              'No referral history yet',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.map(_historyTile).toList(),
    );
  }

  Widget _historyTile(_ReferralHistoryItem item) {
    final completed = item.status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (completed ? Colors.green : gold)
                  .withValues(alpha: 0.14),
            ),
            child: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_top_rounded,
              color: completed ? Colors.greenAccent : gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.status,
                  style: TextStyle(
                    color: completed
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (item.reward > 0)
            Text(
              '+${item.reward}',
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_rounded,
            color: Colors.orangeAccent,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Referral rewards are not credited by this screen. '
              'Eligible referrals must be verified by the trusted '
              'backend before coins are added.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralHistoryItem {
  final String name;
  final String status;
  final int reward;

  const _ReferralHistoryItem({
    required this.name,
    required this.status,
    required this.reward,
  });
}
