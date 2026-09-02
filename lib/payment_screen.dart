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
  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFFFF9FF);

  final PaymentService _paymentService = PaymentService.instance;

  ProductDetails? _product;
  bool _loading = true;
  bool _purchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadProduct();

    _paymentService.listenToPurchases(_handlePurchase);
  }

  Future<void> _loadProduct() async {
    try {
      final products = await _paymentService.loadProducts();

      final productId = _productIdForCoins(widget.coins);

      ProductDetails? found;

      for (final product in products) {
        if (product.id == productId) {
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
              'This coin package is not available yet.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Unable to load payment details.';
      });
    }
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

  Future<void> _startPurchase() async {
    if (_product == null || _purchasing) {
      return;
    }

    setState(() {
      _purchasing = true;
    });

    try {
      final started = await _paymentService.buyCoins(_product!);

      if (!started && mounted) {
        setState(() {
          _purchasing = false;
        });

        _showMessage(
          'Unable to start the purchase.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _purchasing = false;
      });

      _showMessage(
        'Payment could not be started.',
      );
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
        purchase.error?.message ??
            'Payment failed.',
      );

      return;
    }

    if (purchase.status == PurchaseStatus.canceled) {
      setState(() {
        _purchasing = false;
      });

      _showMessage(
        'Payment was cancelled.',
      );

      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      setState(() {
        _purchasing = false;
      });

      // IMPORTANT:
      // Do NOT add coins here yet.
      //
      // The purchase must be verified on a trusted
      // backend/server before coins are credited.
      _showMessage(
        'Purchase received. Verification is required before coins are credited.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          110,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =====================================================
            // ORDER SUMMARY
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Package',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      Flexible(
                        child: Text(
                          widget.packageName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Coins',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      Text(
                        '${widget.coins} Coins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '₹${widget.price}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =====================================================
            // GOOGLE PLAY BILLING
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: primaryColor,
                        size: 30,
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Google Play Billing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Payment will be securely handled through Google Play. Available payment methods are shown by Google Play during checkout.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // SECURITY
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFFF0E7FF),
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: primaryColor,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your payment is processed securely. Coins are credited only after purchase verification.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // ===========================================================
      // PAY BUTTON
      // ===========================================================

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          14,
        ),

        child: SizedBox(
          height: 56,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  Colors.grey.shade400,

              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30),
              ),
            ),

            onPressed:
                _loading ||
                        _product == null ||
                        _purchasing
                    ? null
                    : _startPurchase,

            child: _loading || _purchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    'Pay ₹${widget.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
