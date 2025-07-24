// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Screens/Auth/login_screen.dart';
import 'package:fuel_route/Screens/Home/home_screen.dart';
import 'package:fuel_route/Screens/Splash/welcome_screen.dart';
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        ), // Replace with your HomeScreen widget
        (route) => false, // This removes all previous routes
      );
    }
    // Opened before but not logged in
    else if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ), // Replace with your HomeScreen widget
        (route) => false, // This removes all previous routes
      );
    }
    // Already logged in
    else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ), // Replace with your HomeScreen widget
        (route) => false, // This removes all previous routes
      );
    }
  }
}
