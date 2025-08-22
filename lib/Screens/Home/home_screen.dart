import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuel_route/Screens/Home/Dashboard/dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/Trip/trip_planner_screen.dart';
import 'package:fuel_route/Screens/Home/ai_tips_screen.dart';
import 'package:fuel_route/Screens/Home/history_dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/Settings/settings.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<String> _titles = [
    "Dashboard",
    "Trip",
    "History",
    "AI Tips",
    "Settings",
  ];

  final List<String> _iconPaths = [
    "assets/images/bottom-bar-icon/dashboard-icon.svg",
    "assets/images/bottom-bar-icon/trip-icon.svg",
    "assets/images/bottom-bar-icon/history-icon.svg",
    "assets/images/bottom-bar-icon/ai-icon.svg",
    "assets/images/bottom-bar-icon/setting-icon.png",
  ];

  final List<Widget> _screens = [
    DashboardScreen(),
    TripPlannerScreen(),
    HistoryDashboardScreen(),
    AiTipsScreen(),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashBgColor,
                AppColors.splashBgColor.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "TRUCKING 100",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
        ),
      ),

      /// ✅ AnimatedSwitcher added here
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          // Slide + Fade animation
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0), // from right
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_titles.length, (index) {
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.lightBlueColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: _iconPaths[index].endsWith('.svg')
                            ? SvgPicture.asset(
                                _iconPaths[index],
                                height: 26,
                                width: 26,
                                color: isSelected
                                    ? AppColors.lightBlueColor
                                    : AppColors.blackColor,
                              )
                            : Image.asset(
                                _iconPaths[index],
                                height: 26,
                                width: 26,
                                color: isSelected
                                    ? AppColors.lightBlueColor
                                    : AppColors.blackColor,
                              ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 1,
                          child: Text(
                            _titles[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightBlueColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
