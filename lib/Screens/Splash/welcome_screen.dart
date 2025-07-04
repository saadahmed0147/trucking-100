import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30, top: 30),
                          child: Image(
                            image: const AssetImage("assets/images/logo.png"),
                            height: mq.height * 0.15,
                          ),
                        ),

                        // Welcome Texts
                        Text(
                          "WELCOME",
                          style: TextStyle(
                            color: AppColors.lightBlueColor,
                            fontSize: 50,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "TO TRUCKING 100",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 25,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 7,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Info Rows
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Icon(
                                Icons.groups_outlined,
                                size: 40,
                                color: AppColors.whiteColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Join the community of 1,000,000+ truckers",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 20,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Icon(
                                Icons.favorite,
                                size: 40,
                                color: AppColors.whiteColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Enjoy your best companion over the road",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 20,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        Spacer(), // ✅ NOW it works because height is bounded
                        // Get Started Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          child: RoundButton(
                            title: 'Get Started',
                            onPress: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.findPlacesScreen,
                              );
                            },
                            fontSize: 17,
                            borderRadius: 30,
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
