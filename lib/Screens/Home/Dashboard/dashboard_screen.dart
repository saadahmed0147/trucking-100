import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Dashboard/dashboard_card.dart';
import 'package:fuel_route/Screens/Home/Dashboard/recent_trip_list.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
import 'package:fuel_route/Screens/Home/home_screen.dart';
import 'package:fuel_route/Services/trip_service.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, String>>> _tripsFuture;
  Future<List<Map<String, String>>>? _cachedTripsFuture;

  double totalEstimatedFuel = 0;
  int totalTrips = 0;
  double totalDistance = 0;
  String firstName = 'Driver'; // Default fallback

  @override
  void initState() {
    super.initState();
    _tripsFuture = _cachedTripsFuture ??= TripService.fetchTripsFromFirebase();
    fetchDashboardStats();
    fetchFirstName(); // 🧠 Get user name
  }

  /// 🔍 Fetch user first name from FirebaseAuth
  Future<void> fetchFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final displayName = user.displayName ?? 'Driver';
      setState(() {
        firstName = displayName.split(' ').first;
      });
    }
  }

  /// 📊 Dashboard Stats
  Future<void> fetchDashboardStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("trips");
    final snapshot = await ref.get();

    if (!snapshot.exists) return;

    double fuel = 0;
    double distance = 0;
    int tripCount = 0;

    final data = snapshot.value as Map;
    data.forEach((key, value) {
      final trip = Map<String, dynamic>.from(value);
      if (trip['userEmail'] == user.email) {
        tripCount++;
        fuel += (trip['estimatedFuel'] as num?)?.toDouble() ?? 0;
        distance += (trip['distanceMiles'] as num?)?.toDouble() ?? 0;
      }
    });

    setState(() {
      totalTrips = tripCount;
      totalEstimatedFuel = fuel;
      totalDistance = distance;
    });
  }

  /// 🟢 Active trip check
  Future<bool> hasActiveTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final dbRef = FirebaseDatabase.instance.ref('trips');
    final snapshot = await dbRef.get();
    if (!snapshot.exists) return false;

    final tripsMap = snapshot.value as Map<dynamic, dynamic>?;
    if (tripsMap == null) return false;

    for (final entry in tripsMap.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      if (data['userEmail'] == user.email && data['status'] == 'active') {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 25,
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                "Welcome, $firstName! Here’s your trucking overview",
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: RoundButton(
                leadingIcon: Icons.add,
                leadingIconColor: AppColors.whiteColor,
                title: "New Trip",
                fontSize: 17,
                borderRadius: 30,
                onPress: () async {
                  final activeTrip = await hasActiveTrip();
                  if (activeTrip) {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.lightBlueColor,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Trip Exists',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.darkBlueColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You already have an active trip. Please complete it before starting a new one.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNewTrip(),
                      ),
                    );
                  }
                },
              ),
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              children: [
                DashboardCard(
                  title: 'Fuel Used',
                  number: '${totalEstimatedFuel.toStringAsFixed(2)} gallons',
                  icon: Icons.local_gas_station,
                ),
                DashboardCard(
                  title: 'Avg. MPG',
                  number: totalEstimatedFuel == 0 || totalDistance == 0
                      ? '0.0'
                      : (totalDistance / totalEstimatedFuel).toStringAsFixed(1),
                  icon: Icons.speed,
                ),
                DashboardCard(
                  title: 'Total Trips',
                  number: totalTrips.toString(),
                  icon: Icons.route,
                ),
                DashboardCard(
                  title: 'Travel Distance',
                  number: '${totalDistance.toStringAsFixed(0)} miles',
                  icon: Icons.map,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: RoundButton(
                title: "Ai Trip Narration",
                fontSize: 17,
                borderRadius: 30,
                onPress: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 3),
                    ),
                  );
                },
              ),
            ),
            const Text(
              "Recent Trips",
              style: TextStyle(
                fontSize: 22,
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, String>>>(
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

                final trips = snapshot.data!;
                trips.sort((a, b) {
                  if (a['status'] == 'ACTIVE' && b['status'] != 'ACTIVE') {
                    return -1;
                  }
                  if (a['status'] != 'ACTIVE' && b['status'] == 'ACTIVE') {
                    return 1;
                  }
                  return 0;
                });

                final limitedTrips = trips.take(3).toList();
                return RecentTripList(trips: limitedTrips);
              },
            ),
          ],
        ),
      ),
    );
  }
}
