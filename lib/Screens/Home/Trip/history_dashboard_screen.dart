import 'package:flutter/material.dart';
import 'package:fuel_route/Screens/Home/Dashboard/recent_trip_list.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HistoryDashboardScreen extends StatefulWidget {
  const HistoryDashboardScreen({super.key});

  @override
  State<HistoryDashboardScreen> createState() => _HistoryDashboardScreenState();
}

class _HistoryDashboardScreenState extends State<HistoryDashboardScreen> {
  late Future<List<Map<String, String>>> _tripsFuture;
  Future<List<Map<String, String>>>?
  _cachedTripsFuture; // ✅ Cache variable here

  @override
  void initState() {
    super.initState();
    _tripsFuture = _cachedTripsFuture ??= fetchTrips(); // ✅ cache once
  }

  Future<List<Map<String, String>>> fetchTrips() async {
    // This is placeholder logic. Replace with Firestore call later.
    await Future.delayed(const Duration(seconds: 2)); // simulate loading

    // Example dummy data (replace with Firestore snapshot parsing)
    return [
      {"destination": "Denver, CO", "current": "Chicago", "status": "Active"},
      {"destination": "Chicago", "current": "Denver", "status": "Complete"},
      {"destination": "Chicago", "current": "Denver", "status": "Complete"},
      {"destination": "Chicago", "current": "Denver", "status": "Complete"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Dashboard",
              style: TextStyle(
                fontSize: 25,
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FutureBuilder<List<Map<String, String>>>(
                future: _tripsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const Center(child: Text("Failed to load trips")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const Center(child: Text("No trips found")),
                    );
                  }

                  return RecentTripList(trips: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
