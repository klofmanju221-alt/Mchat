import 'package:flutter/material.dart';

import 'gift_model.dart';
import 'gift_service.dart';

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
  static const Color purple = Color(0xFF7628C8);
  static const Color deepPurple = Color(0xFF321052);
  static const Color pink = Color(0xFFE72D8D);
  static const Color gold = Color(0xFFFFC928);

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

      debugPrint('Gift send error: $error');
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
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
        ),
      );
  }

  void _showGiftInfo(GiftModel gift) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  gift.emoji,
                  style: const TextStyle(
                    fontSize: 60,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  gift.name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatCoins(gift.coinCost)} Coins',
                  style: const TextStyle(
                    fontSize: 18,
                    color: purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'This gift will be processed through '
                  'the secure gift transaction system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
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
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F5FC),
        foregroundColor: const Color(0xFF202024),
        centerTitle: true,
        title: const Text(
          'Send Gift',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _receiverCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose a Gift',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Select a gift to send',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _gifts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 13,
                        childAspectRatio: 1.15,
                      ),
                      itemBuilder: (context, index) {
                        return _giftCard(
                          _gifts[index],
                          index,
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    _securityBanner(),
                  ],
                ),
              ),
            ),
            _bottomSendBar(),
          ],
        ),
      ),
    );
  }

  Widget _receiverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sending Gift To',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _receiverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.card_giftcard_rounded,
            color: gold,
            size: 31,
          ),
        ],
      ),
    );
  }

  Widget _giftCard(
    GiftModel gift,
    int index,
  ) {
    final selected = _selectedIndex == index;

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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected
                ? purple
                : Colors.grey.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  gift.emoji,
                  style: const TextStyle(
                    fontSize: 47,
                  ),
                ),
              ),
            ),
            Text(
              gift.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected
                    ? purple
                    : const Color(0xFF242228),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_formatCoins(gift.coinCost)} Coins',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9A6800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _securityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: purple,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Gift payments are secure. Coins are '
              'not deducted until the server verifies '
              'the gift transaction.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSendBar() {
    final gift = _selectedGift;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${gift.emoji} ${gift.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_formatCoins(gift.coinCost)} Coins',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _sending ? null : _sendGift,
                icon: _sending
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.card_giftcard_rounded,
                        size: 21,
                      ),
                label: Text(
                  _sending ? 'Sending...' : 'Send Gift',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
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
