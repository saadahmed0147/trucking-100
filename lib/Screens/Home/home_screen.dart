import 'package:flutter/material.dart';
 import 'package:fuel_route/Screens/Home/Dashboard/dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/Trip/trip_planner_screen.dart';
import 'package:fuel_route/Screens/Home/history_dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/settings.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex; // Trip Planner is initially selected

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // ✅ This line is REQUIRED!
  }

  final List<String> _titles = [
    "Dashboard",
    "Trip",
    "History",
    "AI Tips",
    "Settings",
  ];

  final List<String> _iconPaths = [
    "assets/images/bottom-bar-icon/dashboard-icon.png",
    "assets/images/bottom-bar-icon/trip-icon.png",
    "assets/images/bottom-bar-icon/history-icon.png",
    "assets/images/bottom-bar-icon/ai-icon.png",
    "assets/images/bottom-bar-icon/setting-icon.png",
  ];

  final List<Widget> _screens = [
    DashboardScreen(),
    TripPlannerScreen(),
    HistoryDashboardScreen(),
    Center(
      child: Text(
        "Ai tips",
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
    ),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.splashBgColor,
        title: const Text(
          "TRUCKING 100",
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
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
