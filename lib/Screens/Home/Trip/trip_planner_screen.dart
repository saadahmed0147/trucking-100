import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/add_new_trip.dart';
import 'package:fuel_route/Screens/Home/Trip/map_screen.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
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
                          return GestureDetector(
                            onTap: () {
                              navigateWithAnimation(
                                context,
                                MapScreen(
                                  pickup: trip['pickup'] ?? "Unknown Pickup",
                                  destination:
                                      trip['destination'] ??
                                      "Unknown Destination",
                                  pickupLat:
                                      double.tryParse(
                                        trip['pickupLat'].toString(),
                                      ) ??
                                      0.0,
                                  pickupLng:
                                      double.tryParse(
                                        trip['pickupLng'].toString(),
                                      ) ??
                                      0.0,
                                  destinationLat:
                                      double.tryParse(
                                        trip['destinationLat'].toString(),
                                      ) ??
                                      0.0,
                                  destinationLng:
                                      double.tryParse(
                                        trip['destinationLng'].toString(),
                                      ) ??
                                      0.0,
                                  tripId: trip['id'] ?? '',
                                ),
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => MapScreen(
                              //       pickup: trip['pickup'] ?? "Unknown Pickup",
                              //       destination:
                              //           trip['destination'] ??
                              //           "Unknown Destination",
                              //       pickupLat:
                              //           double.tryParse(
                              //             trip['pickupLat'].toString(),
                              //           ) ??
                              //           0.0,
                              //       pickupLng:
                              //           double.tryParse(
                              //             trip['pickupLng'].toString(),
                              //           ) ??
                              //           0.0,
                              //       destinationLat:
                              //           double.tryParse(
                              //             trip['destinationLat'].toString(),
                              //           ) ??
                              //           0.0,
                              //       destinationLng:
                              //           double.tryParse(
                              //             trip['destinationLng'].toString(),
                              //           ) ??
                              //           0.0,
                              //       tripId: trip['id'] ?? '',
                              //     ),
                              //   ),
                              // );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white, Colors.blue.shade50],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lightBlueColor.withOpacity(
                                      0.15,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.7),
                                    blurRadius: 10,
                                    offset: const Offset(-5, -5),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.lightBlueColor.withOpacity(
                                    1,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Header with trip status badge
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: trip['status'] == 'active'
                                                ? [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600,
                                                  ]
                                                : [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600,
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  (trip['status'] == 'active'
                                                          ? Colors.green
                                                          : Colors.orange)
                                                      .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              (trip['status'] ?? '')
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightBlueColor
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColors.lightBlueColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Enhanced Pickup - Destination Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Enhanced route indicator
                                        Column(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade400,
                                                    Colors.blue.shade600,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.my_location,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              width: 3,
                                              height: 40,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.blue.shade300,
                                                    Colors.orange.shade300,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.flag,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Pickup location
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "FROM",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .blue
                                                            .shade600,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      trip['pickup'] ??
                                                          "Unknown Pickup",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Container(
                                                height: 1,
                                                color: Colors.grey.shade200,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),

                                              // Destination location
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "TO",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .orange
                                                            .shade600,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      trip['destination'] ??
                                                          "Unknown Destination",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Enhanced info section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date Row
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.calendar_today,
                                                size: 20,
                                                color: Colors.blue.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Date",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    trip['date']?.substring(
                                                          0,
                                                          10,
                                                        ) ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Divider(height: 24),

                                        // Duration Row
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.access_time,
                                                size: 20,
                                                color: Colors.purple.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Duration",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    trip['duration'] ?? 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Divider(height: 24),

                                        // Distance Row
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.route,
                                                size: 20,
                                                color: Colors.green.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Distance",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    trip['distanceMiles'] !=
                                                            null
                                                        ? "${double.tryParse(trip['distanceMiles'].toString())?.toStringAsFixed(2)} mi"
                                                        : 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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

            navigateWithAnimation(context, const AddNewTrip());
          },
        ),
      ),
    );
  }
}
