// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashServices {
  void checkAppStartState(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;

    // First time opening app ever
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false); // mark as not first
      Navigator.pushReplacementNamed(context, RouteNames.splashScreen);
    }
    // Opened before but not logged in
    else if (user == null) {
      Navigator.pushReplacementNamed(context, RouteNames.loginScreen);
    }
    // Already logged in
    else {
      Navigator.pushReplacementNamed(context, RouteNames.paymentScreen);
    }
  }
}
