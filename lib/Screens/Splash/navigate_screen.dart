import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Splash/plan_trip_screen.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

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
                        // Heading Texts
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NAVIGATE TO",
                                style: TextStyle(
                                  color: AppColors.lightBlueColor,
                                  fontSize: 40,
                                  fontFamily: "Eurostile",
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                "TRUCK ENTRANCE",
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

                        const SizedBox(height: 50),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: SizedBox(
                              height: mq.height * 0.45,
                              child: Image.asset(
                                "assets/images/navigate-image.png",
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          child: Center(
                            child: RoundButton(
                              title: 'Next',
                              onPress: () {
                                navigateWithAnimation(
                                  context,
                                  const PlanTripScreen(),
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
