import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Splash/navigate_screen.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class GetUpdatedScreen extends StatefulWidget {
  const GetUpdatedScreen({super.key});

  @override
  State<GetUpdatedScreen> createState() => _GetUpdatedScreenState();
}

class _GetUpdatedScreenState extends State<GetUpdatedScreen> {
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GET UPDATED",
                                style: TextStyle(
                                  color: AppColors.lightBlueColor,
                                  fontSize: 40,
                                  fontFamily: "Eurostile",
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                "FROM FELLOW DRIVERS",
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

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Image.asset(
                              "assets/images/get-updated-image.png",
                              height: mq.height * 0.45,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Next Button
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
                                  const NavigateScreen(),
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
