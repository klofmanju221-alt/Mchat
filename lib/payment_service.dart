import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const Map<String, int> coinProducts = {
    'coins_1000': 1000,
    'coins_5000': 5000,
    'coins_10000': 10000,
    'coins_25000': 25000,
    'coins_50000': 50000,
    'coins_100000': 100000,
    'coins_250000': 250000,
    'coins_500000': 500000,
    'coins_1000000': 1000000,
    'coins_2500000': 2500000,
  };

  Future<bool> isAvailable() async {
    return _iap.isAvailable();
  }

  Future<List<ProductDetails>> loadProducts() async {
    final available = await _iap.isAvailable();

    if (!available) {
      return [];
    }

    const productIds = <String>{
      'coins_1000',
      'coins_5000',
      'coins_10000',
      'coins_25000',
      'coins_50000',
      'coins_100000',
      'coins_250000',
      'coins_500000',
      'coins_1000000',
      'coins_2500000',
    };

    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      throw Exception(
        response.error!.message,
      );
    }

    return response.productDetails;
  }

  Future<bool> buyCoins(
    ProductDetails product,
  ) async {
    final available = await _iap.isAvailable();

    if (!available) {
      return false;
    }

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    return _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true,
    );
  }

  void listenToPurchases({
    required Future<bool> Function(
      PurchaseDetails purchase,
    ) verifyAndDeliver,
    void Function(
      PurchaseDetails purchase,
    )? onPurchase,
    void Function(
      Object error,
    )? onError,
  }) {
    _subscription ??= _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          onPurchase?.call(purchase);

          switch (purchase.status) {
            case PurchaseStatus.pending:
              break;

            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              try {
                /*
                 * IMPORTANT:
                 *
                 * Coins are NOT credited here directly.
                 *
                 * The purchase must first be verified
                 * by a trusted backend/server.
                 */
                final verified = await verifyAndDeliver(
                  purchase,
                );

                if (verified &&
                    purchase.pendingCompletePurchase) {
                  await _iap.completePurchase(
                    purchase,
                  );
                }
              } catch (e) {
                onError?.call(e);
              }
              break;

            case PurchaseStatus.error:
              onError?.call(
                purchase.error ??
                    Exception(
                      'Purchase failed.',
                    ),
              );
              break;

            case PurchaseStatus.canceled:
              break;
          }
        }
      },
      onError: (Object error) {
        onError?.call(error);
      },
    );
  }

  int coinsForProduct(
    String productId,
  ) {
    return coinProducts[productId] ?? 0;
  }

  bool isCoinProduct(
    String productId,
  ) {
    return coinProducts.containsKey(
      productId,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
