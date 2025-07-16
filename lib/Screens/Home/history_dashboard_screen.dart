import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_route/Screens/Home/Dashboard/recent_trip_list.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class HistoryDashboardScreen extends StatefulWidget {
  const HistoryDashboardScreen({super.key});

  @override
  State<HistoryDashboardScreen> createState() => _HistoryDashboardScreenState();
}

class _HistoryDashboardScreenState extends State<HistoryDashboardScreen> {
  late Future<List<Map<String, String>>> _tripsFuture;
  Future<List<Map<String, String>>>? _cachedTripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _cachedTripsFuture ??= fetchTripsFromFirebase();
  }

  Future<List<Map<String, String>>> fetchTripsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userEmail = user.email;
    final ref = FirebaseDatabase.instance.ref('trips');
    final snapshot = await ref.get();

    final List<Map<String, String>> trips = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final trip = Map<String, dynamic>.from(value);
        if (trip['userEmail'] == userEmail) {
          trips.add({
            'destination': trip['destination'] ?? '',
            'current': trip['pickup'] ?? '',
            'status': (trip['status'] ?? 'completed').toString().toUpperCase(),
          });
        }
      });
    }

    // Active trips first, then others (latest first)
    trips.sort((a, b) {
      if (a['status'] == 'ACTIVE' && b['status'] != 'ACTIVE') return -1;
      if (a['status'] != 'ACTIVE' && b['status'] == 'ACTIVE') return 1;
      return 0;
    });
    return trips.toList(); // show latest first, but active at top
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
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
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _tripsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("Failed to load trips")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("No trips found")),
                    );
                  }

                  return SingleChildScrollView(
                    child: RecentTripList(trips: snapshot.data!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
