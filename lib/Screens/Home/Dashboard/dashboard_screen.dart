import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Dashboard/dashboard_card.dart';
import 'package:fuel_route/Screens/Home/Dashboard/recent_trip_list.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
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

  @override
  void initState() {
    super.initState();
    _tripsFuture = _cachedTripsFuture ??= TripService.fetchTripsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: IconButton(
        //       onPressed: () {},
        //       icon: const Icon(
        //         Icons.menu,
        //         color: AppColors.whiteColor,
        //         size: 30,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
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
                "Welcome Back, john! Here’s your trucking overview",
                style: TextStyle(
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
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddNewTrip()),
                  );
                },
              ),
            ),
            GridView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              children: const [
                DashboardCard(
                  title: 'EST. Fuel',
                  number: '\$24,580',
                  icon: Icons.local_gas_station,
                ),
                DashboardCard(
                  title: 'Avg. MPG',
                  number: '7.2',
                  icon: Icons.speed,
                ),
                DashboardCard(
                  title: 'Total Trip',
                  number: '12',
                  icon: Icons.route,
                ),
                DashboardCard(
                  title: 'Travel Distance',
                  number: '850 mi',
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
                onPress: () {},
              ),
            ),
            Text(
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

                final limitedTrips = snapshot.data!.take(3).toList();
                return RecentTripList(trips: limitedTrips);
              },
            ),
          ],
        ),
      ),
    );
  }
}
