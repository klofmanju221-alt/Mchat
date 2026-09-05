import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedIndex = 2;

  final InAppPurchase _inAppPurchase =
      InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>?
      _purchaseSubscription;

  bool _storeAvailable = false;

  static const Color purple = Color(0xFF7628C8);
  static const Color deepPurple = Color(0xFF321052);
  static const Color pink = Color(0xFFE72D8D);
  static const Color gold = Color(0xFFFFC928);

  final List<_CoinPackage> packages = const [
    _CoinPackage(
      coins: 1000,
      price: '₹100',
    ),
    _CoinPackage(
      coins: 5000,
      price: '₹500',
    ),
    _CoinPackage(
      coins: 10000,
      price: '₹1,000',
      popular: true,
    ),
    _CoinPackage(
      coins: 25000,
      price: '₹2,500',
    ),
    _CoinPackage(
      coins: 50000,
      price: '₹5,000',
    ),
    _CoinPackage(
      coins: 100000,
      price: '₹10,000',
    ),
    _CoinPackage(
      coins: 250000,
      price: '₹25,000',
    ),
    _CoinPackage(
      coins: 500000,
      price: '₹50,000',
    ),
    _CoinPackage(
      coins: 1000000,
      price: '₹1,00,000',
    ),
    _CoinPackage(
      coins: 2500000,
      price: '₹2,50,000',
      premium: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _purchaseSubscription =
        _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint(
          'Google Play purchase stream error: $error',
        );
      },
    );

    _initializeStore();
  }

  Future<void> _initializeStore() async {
    final available =
        await _inAppPurchase.isAvailable();

    if (!mounted) {
      return;
    }

    setState(() {
      _storeAvailable = available;
    });

    debugPrint(
      'Google Play billing available: $available',
    );
  }

  void _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) {
    for (final purchase in purchases) {
      debugPrint(
        'Purchase update: '
        '${purchase.productID} '
        '${purchase.status}',
      );

      if (purchase.status ==
          PurchaseStatus.error) {
        debugPrint(
          'Purchase error: ${purchase.error}',
        );
      }

      if (purchase.status ==
          PurchaseStatus.purchased) {
        debugPrint(
          'Purchase received. '
          'Server verification is required '
          'before coins are credited.',
        );
      }
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      final value = coins / 1000000;
      return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}M';
    }

    if (coins >= 1000) {
      final value = coins / 1000;
      return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}K';
    }

    return coins.toString();
  }

  void _selectPackage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _showPaymentInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
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
                const Icon(
                  Icons.verified_user_rounded,
                  color: purple,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Secure Recharge',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Coin purchases are processed through '
                  'the supported in-app payment system. '
                  'Coins are added only after successful '
                  'purchase verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 22),
                _infoRow(
                  Icons.lock_outline_rounded,
                  'Secure payment',
                ),
                _infoRow(
                  Icons.receipt_long_rounded,
                  'Purchase verification',
                ),
                _infoRow(
                  Icons.monetization_on_outlined,
                  'Verified coin delivery',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
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

  Widget _infoRow(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  purple.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: purple,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _recharge() {
    final package =
        packages[selectedIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            20,
            22,
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
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration:
                      const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFD83D),
                        Color(0xFFFFA800),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Confirm Recharge',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatCoins(package.coins)} Coins',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: purple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.price,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF7F2FB),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: purple,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment will be processed securely. '
                          'Coins are credited only after '
                          'purchase verification.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      final message =
                          _storeAvailable
                              ? 'Google Play billing is ready. '
                                'Product verification setup is '
                                'required before purchasing coins.'
                              : 'Google Play billing is not '
                                'available on this device yet.';

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                              Text(message),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.lock_rounded,
                      size: 20,
                    ),
                    label: const Text(
                      'CONTINUE SECURE PAYMENT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
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
      backgroundColor:
          const Color(0xFFF8F5FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFFF8F5FC),
        foregroundColor:
            const Color(0xFF202024),
        centerTitle: true,
        title: const Text(
          'Recharge',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showPaymentInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _balanceCard(),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      'Select Amount',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Choose a coin package',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          packages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 13,
                        childAspectRatio: 1.42,
                      ),
                      itemBuilder:
                          (context, index) {
                        return _packageCard(
                          packages[index],
                          index,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    _paymentMethods(),
                    const SizedBox(
                      height: 20,
                    ),
                    _secureBanner(),
                  ],
                ),
              ),
            ),
            _bottomRechargeBar(),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(21),
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
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
                purple.withValues(alpha: 0.22),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: gold,
              size: 37,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'My Coins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  'Available Coins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons
                  .account_balance_wallet_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageCard(
    _CoinPackage package,
    int index,
  ) {
    final selected =
        selectedIndex == index;

    return GestureDetector(
      onTap: () =>
          _selectPackage(index),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? purple
                : Colors.grey
                    .withValues(alpha: 0.16),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.045),
              blurRadius: 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (package.popular)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        purple,
                        pink,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'BEST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            if (package.premium)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color: gold,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration:
                      BoxDecoration(
                    color: gold.withValues(
                        alpha: 0.17),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .monetization_on_rounded,
                    color:
                        Color(0xFFF4AA00),
                    size: 25,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCoins(
                      package.coins),
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
                    color: selected
                        ? purple
                        : const Color(
                            0xFF242228,
                          ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${package.coins.toString().replaceAllMapped(
                        RegExp(
                          r'(\d)(?=(\d{3})+(?!\d))',
                        ),
                        (match) =>
                            '${match.group(1)},',
                      )} Coins',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  package.price,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF333038),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Secure in-app purchase',
          style: TextStyle(
            fontSize: 14,
            color:
                Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: Colors.grey
                  .withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            children: [
              _methodRow(
                Icons.shop_rounded,
                'Google Play',
                'Secure in-app purchase',
                true,
              ),
              const Divider(
                height: 25,
              ),
              _methodRow(
                Icons.lock_rounded,
                'Secure Payment',
                'Purchase verification required',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _methodRow(
    IconData icon,
    String title,
    String subtitle,
    bool selected,
  ) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: purple.withValues(
                alpha: 0.10),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: purple,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (selected)
          const Icon(
            Icons.check_circle_rounded,
            color: purple,
          ),
      ],
    );
  }

  Widget _secureBanner() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0E7F8),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(
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
              'Your payment is protected. '
              'Coins are delivered only after '
              'successful purchase verification.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomRechargeBar() {
    final package =
        packages[selectedIndex];

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.08),
            blurRadius: 14,
            offset:
                const Offset(0, -4),
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
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    '${_formatCoins(package.coins)} Coins',
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    package.price,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child:
                  ElevatedButton.icon(
                onPressed: _recharge,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 22,
                ),
                label: const Text(
                  'Recharge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      purple,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      17,
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

class _CoinPackage {
  final int coins;
  final String price;
  final bool popular;
  final bool premium;

  const _CoinPackage({
    required this.coins,
    required this.price,
    this.popular = false,
    this.premium = false,
  });
}
