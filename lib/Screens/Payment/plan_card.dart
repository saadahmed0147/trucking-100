import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PlanCard extends StatelessWidget {
  final ProductDetails product;
  final Function(ProductDetails) onBuy;

  const PlanCard({required this.product, required this.onBuy, super.key});

  @override
  Widget build(BuildContext context) {
    final isLimitedOffer = product.id == 'semi_annual_plan';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (isLimitedOffer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Limited Offer',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            if (isLimitedOffer) const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(product.price, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onBuy(product),
              child: const Text(
                "Choose",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
