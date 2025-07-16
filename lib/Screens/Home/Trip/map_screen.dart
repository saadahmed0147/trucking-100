import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fuel_route/Screens/Home/Trip/navigation_screen.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/map_helpers.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/poi_categories.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/poi_marker_cache.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String pickup;
  final String destination;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final String tripId;

  const MapScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.tripId,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? loadingCategory;
  bool isLoading = false;

  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? origin;
  LatLng? destination;
  LatLng? currentLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<dynamic> _pickupPredictions = [];
  List<dynamic> _destinationPredictions = [];

  final String apiKey = 'AIzaSyDo8HGqkDwHuSuxcWAkHuK7H_gv1ThasBg';

  Set<String> selectedCategories = {};
  StreamSubscription? locationStream;

  @override
  void initState() {
    // load all markers on the map
    loadCachedMarkers();
    super.initState();
    selectedCategories = {};
    _pickupController.text = widget.pickup;
    _destinationController.text = widget.destination;
    origin = LatLng(widget.pickupLat, widget.pickupLng);
    destination = LatLng(widget.destinationLat, widget.destinationLng);
    // Set markers for pickup and destination
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: origin!,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination!,
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    );
    getDirections();
    startLocationUpdates();
  }

  @override
  void dispose() {
    locationStream?.cancel();
    super.dispose();
  }

  void loadCachedMarkers() {
    final allMarkers = POIMarkerCache().allMarkers;
    Set<Marker> combined = {};
    for (var entry in allMarkers.entries) {
      combined.addAll(entry.value);
    }

    setState(() {
      markers.addAll(combined); // _markers is your local Set<Marker>
    });
  }

  void startLocationUpdates() {
    locationStream = Geolocator.getPositionStream().listen((position) async {
      currentLocation = LatLng(position.latitude, position.longitude);
      // Update pickup marker
      setState(() {
        markers.removeWhere((m) => m.markerId.value == 'pickup');
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: currentLocation!,
            infoWindow: const InfoWindow(title: 'Pickup (Your Location)'),
          ),
        );
      });
      // Update pickup location in Firebase
      final dbRef = FirebaseDatabase.instance.ref('trips/${widget.tripId}');
      await dbRef.update({
        'pickupLat': position.latitude,
        'pickupLng': position.longitude,
        'pickup': await getAddressFromLatLng(currentLocation!),
        'currentLocationUpdatedAt': DateTime.now().toIso8601String(),
      });
      // Update search bar
      _pickupController.text = await getAddressFromLatLng(currentLocation!);
    });
  }

  Future<void> getDirections() async {
    polylines.clear();
    polylineCoordinates.clear();
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin!.longitude}&destination=${destination!.latitude},${destination!.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['status'] == 'ZERO_RESULTS' || data['routes'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No route found between selected locations. Please choose valid locations.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Use detailed polyline decoding for road-accurate route ---
    final PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> fullRoute = [];
    final steps = data['routes'][0]['legs'][0]['steps'];

    for (var step in steps) {
      final encoded = step['polyline']['points'];
      final decodedStep = polylinePoints.decodePolyline(encoded);
      fullRoute.addAll(decodedStep.map((e) => LatLng(e.latitude, e.longitude)));
    }

    setState(() {
      polylineCoordinates = fullRoute;
      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 6,
          points: polylineCoordinates,
        ),
      };
    });
  }

  LatLng getInitialMapTarget() {
    if (origin?.latitude != null && origin?.longitude != null) {
      return LatLng(origin!.latitude, origin!.longitude);
    } else if (currentLocation != null) {
      return currentLocation!;
    } else {
      return const LatLng(37.773972, -122.431297);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: getInitialMapTarget(),
              zoom: 5,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pickupController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Pickup Location",
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.gps_fixed,
                          color: Colors.blueAccent,
                        ),
                        tooltip: "Use current location",
                        onPressed: () async {
                          Position position =
                              await Geolocator.getCurrentPosition();
                          LatLng newLoc = LatLng(
                            position.latitude,
                            position.longitude,
                          );
                          _pickupController.text = await getAddressFromLatLng(
                            newLoc,
                          );
                          setState(() {
                            origin = newLoc;
                            markers.removeWhere(
                              (m) => m.markerId.value == 'pickup',
                            );
                            markers.add(
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: newLoc,
                                infoWindow: const InfoWindow(
                                  title: 'Pickup (GPS)',
                                ),
                              ),
                            );
                          });
                          // Optionally update route
                          getDirections();
                          // Update in Firebase
                          final dbRef = FirebaseDatabase.instance.ref(
                            'trips/${widget.tripId}',
                          );
                          await dbRef.update({
                            'pickupLat': position.latitude,
                            'pickupLng': position.longitude,
                            'pickup': await getAddressFromLatLng(newLoc),
                            'currentLocationUpdatedAt': DateTime.now()
                                .toIso8601String(),
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _destinationController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Destination",
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Find Places on Route",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemCount: poiCategories.length,
                        itemBuilder: (context, index) {
                          final cat = poiCategories[index];
                          final catKey = cleanLabel(cat['label']);
                          final isSelected = selectedCategories.contains(
                            catKey,
                          );

                          return GestureDetector(
                            onTap: () async {
                              final isSelected = selectedCategories.contains(
                                catKey,
                              );

                              // Ignore if it's already loading the same category
                              if (loadingCategory == catKey && isLoading)
                                return;

                              setState(() {
                                selectedCategories.clear();
                                if (!isSelected) selectedCategories.add(catKey);
                                loadingCategory = catKey;
                                isLoading = true;
                              });

                              // Clear existing POI markers
                              markers.removeWhere(
                                (m) => m.markerId.value.startsWith("poi_"),
                              );
                              Set<Marker> newCategoryMarkers = {};

                              try {
                                if (selectedCategories.isNotEmpty) {
                                  final activeCat = poiCategories.firstWhere(
                                    (c) => cleanLabel(c['label']) == catKey,
                                  );
                                  await fetchNearbyPlaces(
                                    category: activeCat,
                                    origin: origin,
                                    destination: destination,
                                    currentLocation: currentLocation,
                                    apiKey: apiKey,
                                    markers: newCategoryMarkers,
                                    onMarkersUpdated: (_) {},
                                    routePolyline:
                                        (origin != null &&
                                            destination != null &&
                                            polylineCoordinates.isNotEmpty)
                                        ? polylineCoordinates
                                        : null,
                                  );
                                }

                                // Apply markers
                                setState(() {
                                  markers.addAll(newCategoryMarkers);
                                });
                              } catch (e) {
                                debugPrint("Error fetching POIs: $e");
                              } finally {
                                // Reset loading state
                                setState(() {
                                  isLoading = false;
                                  loadingCategory = null;
                                });
                              }
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent,
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black),
                                boxShadow: isSelected
                                    ? [
                                        const BoxShadow(
                                          color: Colors.blueAccent,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: isLoading && loadingCategory == catKey
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            cat["icon"],
                                            color: AppColors.splashBgColor,
                                            size: 35,
                                          ),
                                          Text(
                                            cat['label'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions, color: AppColors.whiteColor),
        backgroundColor: AppColors.lightBlueColor,
        onPressed: () {
          // Open navigation screen instantly, pass all required trip data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NavigationScreen(
                tripId: widget.tripId,
                // Pass pickup/destination for instant display
                pickupLat: widget.pickupLat,
                pickupLng: widget.pickupLng,
                destinationLat: widget.destinationLat,
                destinationLng: widget.destinationLng,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 05, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            child: const Text('End trip'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm End Trip'),
                  content: const Text(
                    'Are you sure you want to end the current trip?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('End Trip'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final dbRef = FirebaseDatabase.instance.ref(
                  'trips/${widget.tripId}',
                );
                await dbRef.update({'status': 'completed'});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip ended and marked as completed.'),
                    backgroundColor: AppColors.lightBlueColor,
                  ),
                );

                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['results'] != null && data['results'].isNotEmpty) {
      return data['results'][0]['formatted_address'];
    }
    return "Current Location";
  }
}
