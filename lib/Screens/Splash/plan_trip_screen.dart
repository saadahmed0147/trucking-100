import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "PLAN TRIPS",
                                style: TextStyle(
                                  color: AppColors.lightBlueColor,
                                  fontSize: 40,
                                  fontFamily: "Eurostile",
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                "KNOW YOUR ETAS",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 28,
                                  fontFamily: "Eurostile",
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Image
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: SizedBox(
                              height: mq.height * 0.45,
                              child: Image.asset(
                                "assets/images/plan-trip-image.png",
                              ),
                            ),
                          ),
                        ),

                        // Push button to bottom
                        const Spacer(),

                        // Get Started Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          child: Center(
                            child: RoundButton(
                              title: 'Get Started',
                              onPress: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  RouteNames.paymentScreen,
                                );
                              },
                              fontSize: 17,
                              borderRadius: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
