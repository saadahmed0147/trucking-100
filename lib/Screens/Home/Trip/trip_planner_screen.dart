import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  late Future<List<String>> _tripFuture;

  @override
  void initState() {
    super.initState();
    _tripFuture = fetchTrips(); // Replace with your Firestore call
  }

  Future<List<String>> fetchTrips() async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate no data from Firebase:
    return []; // ← 👈 Replace with your Firebase fetching logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,

      /// 👇 Main body
      body: FutureBuilder<List<String>>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.lightBlueColor),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading trips"));
          }

          final trips = snapshot.data ?? [];

          if (trips.isEmpty) {
            // 👇 Show placeholder UI when no trips
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: mq.height * 0.3,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/trip-image.png"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: const [
                        Text(
                          "FIND PLACES",
                          style: TextStyle(
                            color: AppColors.lightBlueColor,
                            fontSize: 40,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          "OVER THE ROAD",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 28,
                            fontFamily: "Eurostile",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 7,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            textAlign: TextAlign.center,
                            "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or.",
                            style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // 👇 Replace with your trip list view when trips exist
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.trip_origin),
                title: Text("Trip to ${trips[index]}"),
              ),
            );
          }
        },
      ),

      /// 👇 Fixed bottom button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30),
        child: RoundButton(
          leadingIcon: Icons.add,
          leadingIconColor: AppColors.whiteColor,
          title: "Create New Trip",
          fontSize: 17,
          borderRadius: 30,
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewTrip()),
            );
          },
        ),
      ),
    );
  }
}
