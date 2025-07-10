import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
import 'package:fuel_route/Screens/Home/Trip/calculator_screen.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  late Future<List<Map<String, dynamic>>> _tripFuture;

  @override
  void initState() {
    super.initState();
    _tripFuture = fetchTrips();
  }

  Future<List<Map<String, dynamic>>> fetchTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final dbRef = FirebaseDatabase.instance.ref('trips');
    final snapshot = await dbRef.get();
    if (!snapshot.exists) return [];

    final tripsMap = snapshot.value as Map<dynamic, dynamic>?;
    if (tripsMap == null) return [];

    return tripsMap.entries
        .map((e) {
          final data = Map<String, dynamic>.from(e.value as Map);
          data['id'] = e.key;
          return data;
        })
        .where((trip) => trip['userEmail'] == user.email)
        .toList();
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
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
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.route,
                      color: AppColors.lightBlueColor,
                    ),
                    title: Text(
                      '${trip['pickup'] ?? 'Unknown'} → ${trip['destination'] ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trip['date'] != null) Text('Date: ${trip['date']}'),
                        if (trip['category'] != null)
                          Text('Category: ${trip['category']}'),
                        if (trip['mpg'] != null) Text('MPG: ${trip['mpg']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.calculate,
                        color: AppColors.lightBlueColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalculatorScreen(
                              pickup: trip['pickup'] ?? '',
                              destination: trip['destination'] ?? '',
                              userName: trip['userName'] ?? '',
                              userEmail: trip['userEmail'] ?? '',
                              pickupLat: (trip['pickupLat'] is double)
                                  ? trip['pickupLat']
                                  : double.tryParse(
                                          (trip['pickupLat'] ?? '0.0')
                                              .toString(),
                                        ) ??
                                        0.0,
                              pickupLng: (trip['pickupLng'] is double)
                                  ? trip['pickupLng']
                                  : double.tryParse(
                                          (trip['pickupLng'] ?? '0.0')
                                              .toString(),
                                        ) ??
                                        0.0,
                              destinationLat: (trip['destinationLat'] is double)
                                  ? trip['destinationLat']
                                  : double.tryParse(
                                          (trip['destinationLat'] ?? '0.0')
                                              .toString(),
                                        ) ??
                                        0.0,
                              destinationLng: (trip['destinationLng'] is double)
                                  ? trip['destinationLng']
                                  : double.tryParse(
                                          (trip['destinationLng'] ?? '0.0')
                                              .toString(),
                                        ) ??
                                        0.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30),
        child: RoundButton(
          leadingIcon: Icons.add,
          leadingIconColor: AppColors.whiteColor,
          title: "Create New Trip",
          fontSize: 17,
          borderRadius: 30,
          onPress: () async {
            final activeTrip = await hasActiveTrip();
            if (activeTrip) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Active Trip"),
                  content: const Text(
                    "You already have an active trip. Please complete your current trip before creating a new one.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNewTrip()),
            );
          },
        ),
      ),
    );
  }
}
