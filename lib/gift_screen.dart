import 'package:flutter/material.dart';

import 'gift_model.dart';
import 'gift_service.dart';
import 'premium_theme.dart';

class GiftScreen extends StatefulWidget {
  final String? receiverUid;
  final String? receiverName;

  const GiftScreen({
    super.key,
    this.receiverUid,
    this.receiverName,
  });

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  static const Color gold = PremiumTheme.gold;
  static const Color brightGold = PremiumTheme.brightGold;
  static const Color lightGold = PremiumTheme.lightGold;
  static const Color purple = PremiumTheme.purple;
  static const Color deepPurple = PremiumTheme.deepPurple;
  static const Color darkPurple = PremiumTheme.darkPurple;
  static const Color background = PremiumTheme.background;
  static const Color surface = PremiumTheme.surface;
  static const Color surface2 = PremiumTheme.surface2;

  final GiftService _giftService = GiftService.instance;

  late final List<GiftModel> _gifts;

  int _selectedIndex = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _gifts = _giftService.getGifts();
  }

  GiftModel get _selectedGift => _gifts[_selectedIndex];

  String get _receiverName {
    final name = widget.receiverName?.trim();

    if (name == null || name.isEmpty) {
      return 'Select a receiver';
    }

    return name;
  }

  Future<void> _sendGift() async {
    if (_sending) {
      return;
    }

    final receiverUid = widget.receiverUid?.trim();

    if (receiverUid == null || receiverUid.isEmpty) {
      _showMessage(
        'Receiver is not selected yet.',
        isError: true,
      );
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await _giftService.sendGift(
        receiverUid: receiverUid,
        gift: _selectedGift,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Gift sent successfully.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Gift backend is not connected yet. '
        'No coins were deducted.',
        isError: true,
      );

      debugPrint(
        'Gift send error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError
                  ? Colors.red.shade800
                  : const Color(0xFF176B4D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(14),
        ),
      );
  }

  void _showGiftInfo(GiftModel gift) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            28,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surface2,
                surface,
                darkPurple,
              ],
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: gold,
                width: 1.2,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: gold.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),

                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    gradient:
                        PremiumTheme.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      gift.emoji,
                      style: const TextStyle(
                        fontSize: 62,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  gift.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        PremiumTheme.goldGradient,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatCoins(gift.coinCost)} Coins',
                    style: const TextStyle(
                      color: Color(0xFF3B2100),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: gold.withValues(
                        alpha: 0.18,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: gold,
                        size: 23,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This gift uses the secure '
                          'transaction system.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor:
                          Colors.black,
                      elevation: 5,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CLOSE',
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
          ),
        );
      },
    );
  }

  String _formatCoins(int coins) {
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
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.white,
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
          'Gift Treasure',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 12,
              top: 8,
              bottom: 8,
            ),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient:
                  PremiumTheme.purpleGradient,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: gold.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: gold,
              size: 22,
            ),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient:
              PremiumTheme.premiumBackground,
        ),

        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildRoyalHeader(),

                      const SizedBox(height: 16),

                      _receiverCard(),

                      const SizedBox(height: 22),

                      _buildSectionTitle(),

                      const SizedBox(height: 14),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: _gifts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.92,
                        ),
                        itemBuilder:
                            (context, index) {
                          return _giftCard(
                            _gifts[index],
                            index,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildSecurityBanner(),

                      const SizedBox(height: 15),

                      _buildRoyalFooter(),
                    ],
                  ),
                ),
              ),

              _bottomSendBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF120819),
            Color(0xFF32104F),
            Color(0xFF5B1A83),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: gold.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(
              alpha: 0.22,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Icon(
              Icons.diamond_rounded,
              size: 115,
              color: Colors.white.withValues(
                alpha: 0.06,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient:
                      PremiumTheme.goldGradient,
                  borderRadius:
                      BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(
                        alpha: 0.28,
                      ),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF4A2700),
                  size: 32,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Royal Gift Treasure',
                      style: TextStyle(
                        color: gold,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Send premium gifts to your Mchat family',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: gold.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient:
                  PremiumTheme.purpleGradient,
              shape: BoxShape.circle,
              border: Border.all(
                color: gold.withValues(
                  alpha: 0.40,
                ),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: gold,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'SENDING GIFT TO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _receiverName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: gold.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: gold,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 31,
          decoration: BoxDecoration(
            gradient:
                PremiumTheme.goldGradient,
            borderRadius:
                BorderRadius.circular(5),
          ),
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Gift',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Select a premium gift to send',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: purple.withValues(
              alpha: 0.25,
            ),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: gold.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.diamond_rounded,
                color: gold,
                size: 15,
              ),
              SizedBox(width: 4),
              Text(
                'TREASURE',
                style: TextStyle(
                  color: gold,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _giftCard(
    GiftModel gift,
    int index,
  ) {
    final selected =
        _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      onLongPress: () {
        _showGiftInfo(gift);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B1454),
                    Color(0xFF1B0D26),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    surface2,
                    surface,
                  ],
                ),
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? gold
                : gold.withValues(
                    alpha: 0.15,
                  ),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? gold.withValues(
                      alpha: 0.15,
                    )
                  : Colors.black.withValues(
                      alpha: 0.20,
                    ),
              blurRadius:
                  selected ? 16 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -8,
              child: Icon(
                Icons.diamond_rounded,
                size: 47,
                color: gold.withValues(
                  alpha: selected
                      ? 0.08
                      : 0.035,
                ),
              ),
            ),

            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient:
                        selected
                            ? PremiumTheme
                                .goldGradient
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF32104F),
                                  Color(0xFF180B22),
                                ],
                              ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? lightGold
                          : gold.withValues(
                              alpha: 0.20,
                            ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(
                          alpha: selected
                              ? 0.22
                              : 0.06,
                        ),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      gift.emoji,
                      style:
                          const TextStyle(
                        fontSize: 42,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  gift.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? gold
                        : Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: gold.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: gold,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCoins(
                          gift.coinCost,
                        ),
                        style:
                            const TextStyle(
                          color: lightGold,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (selected)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    gradient:
                        PremiumTheme
                            .goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.black,
                    size: 17,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF21102F),
            Color(0xFF160C22),
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient:
                  PremiumTheme.purpleGradient,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: gold,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Gift System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Coins are not deducted until '
                  'the server verifies the transaction.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_rounded,
            color: gold,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalFooter() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 1,
          color: gold.withValues(
            alpha: 0.45,
          ),
        ),

        const SizedBox(width: 9),

        const Icon(
          Icons.star_rounded,
          color: gold,
          size: 15,
        ),

        const SizedBox(width: 6),

        const Text(
          'SEND WITH LOVE',
          style: TextStyle(
            color: gold,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(width: 6),

        const Icon(
          Icons.star_rounded,
          color: gold,
          size: 15,
        ),

        const SizedBox(width: 9),

        Container(
          width: 38,
          height: 1,
          color: gold.withValues(
            alpha: 0.45,
          ),
        ),
      ],
    );
  }

  Widget _bottomSendBar() {
    final gift = _selectedGift;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        11,
        16,
        13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF100719),
        border: Border(
          top: BorderSide(
            color: gold.withValues(
              alpha: 0.20,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.35,
            ),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 51,
              height: 51,
              decoration: BoxDecoration(
                gradient:
                    PremiumTheme
                        .goldGradient,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  gift.emoji,
                  style:
                      const TextStyle(
                    fontSize: 27,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    gift.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: gold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCoins(gift.coinCost)} Coins',
                        style:
                            const TextStyle(
                          color: lightGold,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _sending
                        ? null
                        : _sendGift,
                icon:
                    _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .card_giftcard_rounded,
                            size: 20,
                          ),
                label: Text(
                  _sending
                      ? 'Sending...'
                      : 'SEND',
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      purple,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade700,
                  elevation: 5,
                  shadowColor:
                      purple.withValues(
                    alpha: 0.35,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    side: const BorderSide(
                      color: gold,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
