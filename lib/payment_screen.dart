import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final String packageName;
  final int coins;
  final int price;

  const PaymentScreen({
    super.key,
    required this.packageName,
    required this.coins,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color purple = Color(0xFF7B2CBF);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color gold = Color(0xFFFFC107);
  static const Color background = Color(0xFFF8F5FC);

  final PaymentService _paymentService = PaymentService.instance;

  ProductDetails? _product;
  bool _loading = true;
  bool _purchasing = false;
  String? _errorMessage;

  static const List<Map<String, dynamic>> packages = [
    {'coins': 1000, 'price': 100, 'label': '1K', 'popular': false},
    {'coins': 5000, 'price': 500, 'label': '5K', 'popular': false},
    {'coins': 10000, 'price': 1000, 'label': '10K', 'popular': true},
    {'coins': 25000, 'price': 2500, 'label': '25K', 'popular': false},
    {'coins': 50000, 'price': 5000, 'label': '50K', 'popular': false},
    {'coins': 100000, 'price': 10000, 'label': '100K', 'popular': false},
    {'coins': 250000, 'price': 25000, 'label': '250K', 'popular': false},
    {'coins': 500000, 'price': 50000, 'label': '500K', 'popular': false},
    {'coins': 1000000, 'price': 100000, 'label': '1M', 'popular': false},
    {'coins': 2500000, 'price': 250000, 'label': '2.5M', 'popular': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _paymentService.listenToPurchases(_handlePurchase);
  }

  String _productIdForCoins(int coins) {
    switch (coins) {
      case 1000:
        return 'coins_1000';
      case 5000:
        return 'coins_5000';
      case 10000:
        return 'coins_10000';
      case 25000:
        return 'coins_25000';
      case 50000:
        return 'coins_50000';
      case 100000:
        return 'coins_100000';
      case 250000:
        return 'coins_250000';
      case 500000:
        return 'coins_500000';
      case 1000000:
        return 'coins_1000000';
      case 2500000:
        return 'coins_2500000';
      default:
        return '';
    }
  }

  Future<void> _loadProduct() async {
    try {
      final products = await _paymentService.loadProducts();
      final id = _productIdForCoins(widget.coins);

      ProductDetails? found;

      for (final product in products) {
        if (product.id == id) {
          found = product;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _product = found;
        _loading = false;

        if (found == null) {
          _errorMessage =
              'This package is not available for purchase yet.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Unable to load payment details.';
      });
    }
  }

  Future<void> _startPurchase() async {
    if (_product == null || _purchasing) return;

    setState(() {
      _purchasing = true;
    });

    try {
      final started = await _paymentService.buyCoins(_product!);

      if (!started && mounted) {
        setState(() {
          _purchasing = false;
        });

        _showMessage('Unable to start the purchase.');
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _purchasing = false;
      });

      _showMessage('Payment could not be started.');
    }
  }

  void _handlePurchase(PurchaseDetails purchase) {
    if (!mounted) return;

    if (purchase.status == PurchaseStatus.pending) {
      setState(() {
        _purchasing = true;
      });
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      setState(() {
        _purchasing = false;
      });

      _showMessage(
        purchase.error?.message ?? 'Payment failed.',
      );
      return;
    }

    if (purchase.status == PurchaseStatus.canceled) {
      setState(() {
        _purchasing = false;
      });

      _showMessage('Payment was cancelled.');
      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      setState(() {
        _purchasing = false;
      });

      _showMessage(
        'Purchase received. Verification is required before coins are credited.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _selectPackage(Map<String, dynamic> item) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          packageName: '${item['label']} Coins',
          coins: item['coins'] as int,
          price: item['price'] as int,
        ),
      ),
    );
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      final value = coins / 1000000;
      return '${value % 1 == 0 ? value.toInt() : value}M';
    }

    if (coins >= 1000) {
      final value = coins / 1000;
      return '${value % 1 == 0 ? value.toInt() : value}K';
    }

    return coins.toString();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Recharge',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Recharge History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              _showMessage('Recharge history UI will be connected later.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 22),

            const Text(
              'Select Coin Package',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Choose a package that suits you',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            _buildPackageGrid(),

            const SizedBox(height: 26),

            _buildSecurePaymentCard(),

            const SizedBox(height: 16),

            _buildVerificationCard(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPayButton(),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            deepPurple,
            purple,
            Color(0xFF9C4DCC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: gold,
              size: 35,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Coins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '0 Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 5),
                Text(
                  'Recharge',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        childAspectRatio: 1.17,
      ),
      itemBuilder: (context, index) {
        final item = packages[index];

        final bool selected =
            item['coins'] == widget.coins;

        return GestureDetector(
          onTap: () => _selectPackage(item),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? purple
                        : Colors.grey.shade200,
                    width: selected ? 2.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E6FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: gold,
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item['label']} Coins',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${item['price']}',
                      style: const TextStyle(
                        color: purple,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (item['popular'] == true)
                Positioned(
                  top: -8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurePaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: purple,
              ),
              SizedBox(width: 10),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  color: purple,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Play Billing',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Secure checkout through Google Play',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Payment options shown at checkout are controlled by Google Play.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(alpha: 0.45),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_rounded,
            color: Color(0xFFE09B00),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Secure & Verified\nCoins will be credited only after the purchase is verified.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPayButton() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 15),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed:
                _loading ||
                        _product == null ||
                        _purchasing
                    ? null
                    : _startPurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  Colors.grey.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _loading || _purchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 23,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Recharge ${_formatCoins(widget.coins)} • ₹${widget.price}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
