import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Set<String> _productIds = {'monthly_plan', 'semi_annual_plan'};

  final ValueNotifier<bool> loading = ValueNotifier(true);
  final ValueNotifier<List<ProductDetails>> products = ValueNotifier([]);

  void initialize({
    required void Function(List<PurchaseDetails>) onPurchaseUpdated,
  }) async {
    final available = await _iap.isAvailable();
    if (!available) {
      loading.value = false;
      return;
    }

    final response = await _iap.queryProductDetails(_productIds);
    products.value = response.productDetails.toList();
    loading.value = false;

    _iap.purchaseStream.listen(onPurchaseUpdated);
  }

  void buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
