import 'package:flutter/material.dart';
import 'package:fuel_route/Screens/Home/Dashboard/dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/Trip/tabbar.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Trip Planner is initially selected

  final List<String> _titles = [
    "Dashboard",
    "Trip",
    "Accounts",
    "History",
    "AI Tips",
  ];

  final List<String> _iconPaths = [
    "assets/images/bottom-bar-icon/dashboard-icon.png", // Dashboard
    "assets/images/bottom-bar-icon/trip-icon.png", // Trip
    "assets/images/bottom-bar-icon/account-icon.png", // CRM
    "assets/images/bottom-bar-icon/history-icon.png", // Expenses
    "assets/images/bottom-bar-icon/ai-icon.png", // AI Tips
  ];

  final List<Widget> _screens = [
    DashboardScreen(),
    Tabbar(),
    Center(
      child: Text("CRM", style: TextStyle(color: Colors.white, fontSize: 20)),
    ),
    Center(
      child: Text(
        "Expenses",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
    Center(
      child: Text(
        "AI Tips",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.whiteColor,
      //   automaticallyImplyLeading: false,
      //   foregroundColor: AppColors.blackColor,
      //   actions: [
      //     IconButton(
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //         Navigator.pushReplacementNamed(context, RouteNames.loginScreen);
      //       },
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      backgroundColor: AppColors.whiteColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.whiteColor),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_titles.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    _iconPaths[index],
                    height: 30,
                    width: 30,
                    color: isSelected
                        ? AppColors.lightBlueColor
                        : AppColors.blackColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _titles[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.lightBlueColor
                          : AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
