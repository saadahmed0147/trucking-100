import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Screens/Payment/payment_controller.dart';
import 'package:fuel_route/Screens/Payment/plan_card.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final controller = PaymentController();
  int? selectedPlanIndex;

  @override
  void initState() {
    super.initState();
    controller.initialize(onPurchaseUpdated: _onPurchaseUpdated);
  }

  void _onPurchaseUpdated(purchases) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.loading,
        builder: (_, loading, __) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // 🔒 Fixed Top Header
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 100),
                    const Text(
                      'TOP CHOICE OF',
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Eurostile",
                      ),
                    ),
                    const Text(
                      '1,000,000+',
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColors.lightBlueColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Eurostile",
                      ),
                    ),
                    const Text(
                      'TRUCK DRIVERS',
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Eurostile",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff444446),
                        border: Border.all(
                          color: AppColors.greyColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Routed Miles for Truckers",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Eurostile",
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "5.49B",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Miles",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: AppColors.greyColor,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "5-Star Navigation Rating",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Eurostile",
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "96.43%",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🧭 Scrollable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          const Text(
                            'Premium Plans',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 5,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: PlanCardBox(
                                    title: 'Monthly Plan',
                                    price: '\$29.99',
                                    subtitle: '7 Days Free Trial',
                                    priceSuffix: '/MO',
                                    isHighlighted: true,
                                    isSelected: selectedPlanIndex == 0,
                                    onTap: () {
                                      setState(() => selectedPlanIndex = 0);
                                      controller.buy(
                                        controller.products.value[0],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: PlanCardBox(
                                    title: 'Semi-Annual Plan',
                                    price: '\$24.99',
                                    subtitle: '\$149.99/6 months',
                                    priceSuffix: '/MO',
                                    badgeText: 'Limited Offer',
                                    isHighlighted: false,
                                    isSelected: selectedPlanIndex == 1,
                                    onTap: () {
                                      setState(() => selectedPlanIndex = 1);
                                      controller.buy(
                                        controller.products.value.length > 1
                                            ? controller.products.value[1]
                                            : controller.products.value[0],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Start with 7 days free trial, then \$29.99 per month",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: controller.products.value.isNotEmpty
                                ? () => controller.buy(
                                    controller.products.value[0],
                                  )
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RouteNames.loginScreen,
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "Already a member? ",
                                style: TextStyle(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: "Login to enjoy",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Features',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 5,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
