import 'package:flutter/material.dart';
import 'package:fuel_route/Screens/Home/Trip/history_dashboard_screen.dart';
import 'package:fuel_route/Screens/Home/Trip/trip_planner_screen.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class Tabbar extends StatelessWidget {
  const Tabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Trip & History
      child: Scaffold(
        backgroundColor: AppColors.tabsBgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: AppColors.splashBgColor,
          title: const TabBar(
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 20),
            labelColor: AppColors.lightBlueColor,
            unselectedLabelColor: Colors.white,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 5, color: AppColors.lightBlueColor),
            ),
            labelStyle: TextStyle(
              fontFamily: "Eurostile",
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontSize: 16,
            ),
            tabs: [
              Tab(text: 'Trip'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TripPlannerScreen(), HistoryDashboardScreen()],
        ),
      ),
    );
  }
}
