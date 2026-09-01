import 'package:flutter/material.dart';

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

  String selectedMethod = '';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================================================
            // ORDER SUMMARY
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

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
            // PAYMENT METHODS
            // =====================================================

            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _paymentMethod(
              id: 'UPI',
              title: 'UPI',
              subtitle: 'Google Pay • PhonePe • Paytm',
              icon: Icons.account_balance_wallet,
            ),

            _paymentMethod(
              id: 'CARD',
              title: 'Debit / Credit Card',
              subtitle: 'Visa • Mastercard • RuPay',
              icon: Icons.credit_card,
            ),

            _paymentMethod(
              id: 'NETBANKING',
              title: 'Net Banking',
              subtitle: 'Pay using your bank account',
              icon: Icons.account_balance,
            ),

            const SizedBox(height: 20),

            // =====================================================
            // SECURITY MESSAGE
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFFF0E7FF),
                borderRadius: BorderRadius.circular(15),
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
                      'Your payment will be processed securely.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30),
              ),
            ),

            onPressed: selectedMethod.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Payment method selected: '
                          '$selectedMethod',
                        ),
                      ),
                    );
                  },

            child: Text(
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

  // ===============================================================
  // PAYMENT METHOD CARD
  // ===============================================================

  Widget _paymentMethod({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected =
        selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = id;
        });
      },

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? primaryColor
                : Colors.transparent,

            width: selected ? 2 : 0,
          ),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: const Color(0xFFF0E7FF),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: const Icon(
                Icons.payment,
                color: primaryColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,

              color: selected
                  ? Colors.green
                  : Colors.grey,

              size: 29,
            ),
          ],
        ),
      ),
    );
  }
}
