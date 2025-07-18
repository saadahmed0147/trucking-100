import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
import 'package:fuel_route/Screens/Home/Trip/map_screen.dart';
import 'package:fuel_route/Utils/app_colors.dart';

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

    // Only return trips with status 'active' for this user
    return tripsMap.entries
        .map((e) {
          final data = Map<String, dynamic>.from(e.value as Map);
          data['id'] = e.key;
          return data;
        })
        .where(
          (trip) =>
              trip['userEmail'] == user.email && trip['status'] == 'active',
        )
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
            return Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Current Trip",
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.lightBlueColor,
                      onRefresh: () async {
                        setState(() {
                          _tripFuture = fetchTrips();
                        });
                        await _tripFuture;
                      },
                      child: ListView.builder(
                        itemCount: trips.length,
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                    pickup: trip['pickup'],
                                    destination: trip['destination'],
                                    pickupLat: trip['pickupLat'],
                                    pickupLng: trip['pickupLng'],
                                    destinationLat: trip['destinationLat'],
                                    destinationLng: trip['destinationLng'],
                                    tripId: trip['id'],
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.blueAccent,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  width: 2,
                                  color: AppColors.lightBlueColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.blueAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            trip['pickup'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.darkBlueColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.flag,
                                          color: Colors.deepOrange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            trip['destination'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.darkBlueColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 18),
                                    // Row(
                                    //   children: [
                                    //     const Icon(
                                    //       Icons.access_time,
                                    //       color: Colors.black,
                                    //       size: 18,
                                    //     ),
                                    //     const SizedBox(width: 15),
                                    //     Expanded(
                                    //       child: Text(
                                    //         trip['duration'] ?? 'Unknown',
                                    //         style: const TextStyle(
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 14,
                                    //           color: AppColors.darkBlueColor,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 30),
                                    Divider(color: AppColors.darkBlueColor),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 0,
                                      children: [
                                        if (trip['date'] != null)
                                          Chip(
                                            avatar: const Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              'Starting Date: ${trip['date'].toString().substring(0, 10)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                        if (trip['duration'] != null)
                                          Chip(
                                            avatar: const Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              trip['duration'] ?? 'Unknown',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.deepPurple,
                                          ),
                                        // if (trip['mpg'] != null)
                                        //   Chip(
                                        //     avatar: const Icon(
                                        //       Icons.local_gas_station,
                                        //       size: 18,
                                        //       color: Colors.white,
                                        //     ),
                                        //     label: Text(
                                        //       'MPG: ${trip['mpg']}',
                                        //       style: const TextStyle(
                                        //         color: Colors.white,
                                        //       ),
                                        //     ),
                                        //     backgroundColor: Colors.green,
                                        //   ),
                                        if (trip['status'] != null)
                                          Chip(
                                            avatar: Icon(
                                              trip['status'] == 'active'
                                                  ? Icons.check_circle
                                                  : Icons.history,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              trip['status']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor:
                                                trip['status'] == 'active'
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
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
                          'Active Trip',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.darkBlueColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You already have an active trip. Please complete your current trip before creating a new one.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
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
