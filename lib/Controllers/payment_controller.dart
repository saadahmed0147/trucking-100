import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PaymentController {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Product IDs (to be configured in Google Play Console)
  static const String freeTrialId = 'free_trial';
  static const String plan20TripsId = 'plan_20_trips';
  static const String plan30TripsId = 'plan_30_trips';

  // Fetch available products
  Future<List<ProductDetails>> fetchProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('In-app purchases are not available');
    }

    const Set<String> productIds = {freeTrialId, plan20TripsId, plan30TripsId};

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(productIds);

    if (response.error != null) {
      throw Exception('Error fetching products: ${response.error}');
    }

    return response.productDetails;
  }

  // Purchase a product
  void purchaseProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Listen to purchase updates
  void listenToPurchaseUpdates() {
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _handlePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchase.error}');
        }
      }
    });
  }

  // Handle successful purchase
  void _handlePurchase(PurchaseDetails purchase) async {
    String plan;
    int trips;

    if (purchase.productID == freeTrialId) {
      plan = 'free_trial';
      trips = 2;
    } else if (purchase.productID == plan20TripsId) {
      plan = '20_trips';
      trips = 20;
    } else if (purchase.productID == plan30TripsId) {
      plan = '30_trips';
      trips = 30;
    } else {
      return;
    }

    // Update subscription in Firebase
    final userId = 'userId'; // Replace with actual user ID
    await _dbRef.child('users/$userId/subscription').set({
      'plan': plan,
      'remainingTrips': trips,
      'expiryDate': null, // Add expiry logic if needed
    });

    debugPrint('Purchase successful: $plan');
  }
}
