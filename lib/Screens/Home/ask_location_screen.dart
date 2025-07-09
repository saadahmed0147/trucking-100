import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Services/location_services.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskLocationScreen extends StatefulWidget {
  const AskLocationScreen({super.key});

  @override
  State<AskLocationScreen> createState() => _AskLocationScreenState();
}

class _AskLocationScreenState extends State<AskLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,

      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, size: 70, color: AppColors.whiteColor),
            Text(
              "HELLO, NICE TO MEET YOU!",
              style: TextStyle(
                fontSize: 50,
                fontFamily: "Eurostile",
                color: AppColors.lightBlueColor,
              ),
            ),
            Text(
              "Set your location to make it easier to pick up and deliver your packages",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Eurostile",
                color: AppColors.whiteColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: RoundButton(
                leadingIcon: Icons.location_on,
                title: "Use current location",
                leadingIconColor: AppColors.whiteColor,
                fontSize: 18,
                borderRadius: 30,
                onPress: () async {
                  final position = await requestAndFetchLocation(context);

                  if (position != null) {
                    print(
                      "Lat: ${position.latitude}, Lng: ${position.longitude}",
                    );

                    // ✅ Save location flag
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasLocation', true);

                    // ✅ Navigate to Home Screen
                    if (mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteNames.homeScreen,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
