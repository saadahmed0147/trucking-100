import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.splashBgColor,
        automaticallyImplyLeading: false,
        foregroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, RouteNames.loginScreen);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
