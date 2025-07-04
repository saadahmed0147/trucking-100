import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class FindPlacesScreen extends StatefulWidget {
  const FindPlacesScreen({super.key});

  @override
  State<FindPlacesScreen> createState() => _FindPlacesScreenState();
}

class _FindPlacesScreenState extends State<FindPlacesScreen> {
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
                        // Welcome Texts
                        Text(
                          "FIND PLACES",
                          style: TextStyle(
                            color: AppColors.lightBlueColor,
                            fontSize: 40,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          "OVER THE ROAD",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 28,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 7,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            "assets/images/find-places-image.png",
                            height: mq.height * 0.5,
                          ),
                        ),

                        const Spacer(),

                        // Next Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          child: RoundButton(
                            title: 'Next',
                            onPress: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.getUpdatedScreen,
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
