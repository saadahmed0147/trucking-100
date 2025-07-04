import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Screens/Payment/payment_controller.dart';
import 'package:fuel_route/Screens/Payment/plan_card.dart';
import 'package:fuel_route/Screens/Payment/stat_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final controller = PaymentController();

  @override
  void initState() {
    super.initState();
    controller.initialize(onPurchaseUpdated: _onPurchaseUpdated);
  }

  void _onPurchaseUpdated(purchases) {
    // Optionally update UI or navigate user
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.loading,
        builder: (_, loading, __) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'TOP CHOICE OF\n1,000,000+ TRUCK DRIVERS',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatCard(
                      title: 'Routed Miles For Truckers',
                      value: '5.94B Miles',
                    ),
                    StatCard(
                      title: '5-Star Navigation Rating',
                      value: '96.43%',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Premium Plans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.blueAccent,
                  endIndent: 130,
                  indent: 130,
                ),
                const SizedBox(height: 20),

                ...controller.products.value.map(
                  (product) =>
                      PlanCard(product: product, onBuy: controller.buy),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Start with 7 days free trial, then \$29.99 per month",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.products.value.isNotEmpty
                      ? () => controller.buy(controller.products.value[0])
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Start Free Trial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.loginScreen);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Already a member? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Login to enjoy",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
