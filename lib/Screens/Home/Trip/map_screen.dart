import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/navigation_screen.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/map_helpers.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/poi_categories.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/map_api_key.dart';
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
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? loadingCategory;
  bool isLoading = false;

  LatLng? origin;
  LatLng? destination;
  LatLng? currentLocation;
  LatLng? lastFetchedLocation;
  DateTime lastGeocodeCall = DateTime.now().subtract(Duration(seconds: 30));

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<dynamic> _pickupPredictions = [];
  List<dynamic> _destinationPredictions = [];
  final Map<String, Set<Marker>> poiCache = {};
  DateTime lastTapTime = DateTime.now().subtract(const Duration(seconds: 2));

  final String apiKey = ApiKeys.googleMapsApiKey;

  Set<String> selectedCategories = {};
  StreamSubscription? locationStream;

  @override
  void initState() {
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

  void startLocationUpdates() {
    locationStream = Geolocator.getPositionStream().listen((position) async {
      final newLocation = LatLng(position.latitude, position.longitude);

      // Only fetch address if moved significantly OR enough time has passed
      if (lastFetchedLocation == null ||
          Geolocator.distanceBetween(
                lastFetchedLocation!.latitude,
                lastFetchedLocation!.longitude,
                newLocation.latitude,
                newLocation.longitude,
              ) >
              50 || // Moved more than 50 meters
          DateTime.now().difference(lastGeocodeCall) > Duration(seconds: 30)) {
        lastFetchedLocation = newLocation;
        lastGeocodeCall = DateTime.now();

        currentLocation = newLocation;

        try {
          final address = await getAddressFromLatLng(currentLocation!);
          _pickupController.text = address;

          // Firebase update (optional, if needed)
          if (widget.tripId != null && widget.tripId.isNotEmpty) {
            final dbRef = FirebaseDatabase.instance.ref(
              'trips/${widget.tripId}',
            );
            await dbRef.update({
              'pickupLat': currentLocation!.latitude,
              'pickupLng': currentLocation!.longitude,
              'pickup': address,
            });
          }
        } catch (e) {
          debugPrint("Geocode error: $e");
        }
      } else {
        // Just update current location silently (for dot movement)
        currentLocation = newLocation;
      }

      setState(() {});
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
    final newPolylines = await DirectionsService.getDirections(
      origin: origin!,
      destination: destination!,
      apiKey: apiKey,
      polylineCoordinates: polylineCoordinates,
    );
    setState(() {
      polylines.addAll(newPolylines);
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
                        icon: const Icon(Icons.gps_fixed, color: Colors.black),

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
            initialChildSize: 0.2,
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
                          fontSize: 18,
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
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

                              // Prevent rapid taps
                              if (DateTime.now().difference(lastTapTime) <
                                  const Duration(seconds: 2))
                                return;
                              lastTapTime = DateTime.now();

                              // Skip if already loading same category
                              if (loadingCategory == catKey && isLoading)
                                return;

                              setState(() {
                                selectedCategories.clear();
                                if (!isSelected) selectedCategories.add(catKey);
                                loadingCategory = catKey;
                                isLoading = true;
                              });

                              // Unique key for current route + category
                              final routeKey =
                                  "${catKey}_${origin?.latitude}_${origin?.longitude}_${destination?.latitude}_${destination?.longitude}";

                              try {
                                Set<Marker> newCategoryMarkers = {};

                                // Use cache if exists
                                if (poiCache.containsKey(routeKey)) {
                                  newCategoryMarkers = poiCache[routeKey]!;
                                  debugPrint("Using cached POIs for $catKey");
                                } else if (selectedCategories.isNotEmpty) {
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

                                  poiCache[routeKey] = newCategoryMarkers;
                                }

                                // Remove previous POI markers and add new
                                markers.removeWhere(
                                  (m) => m.markerId.value.startsWith("poi_"),
                                );
                                setState(() {
                                  markers.addAll(newCategoryMarkers);
                                });
                              } catch (e) {
                                debugPrint("Error fetching POIs: $e");
                              } finally {
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
                                border: Border.all(
                                  color: AppColors.lightBlueColor,
                                ),
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
                                          Image.asset(
                                            cat['iconPath'],
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.contain,
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
        padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
        child: RoundButton(
          title: 'End Trip',
          fontSize: 18,
          fontFamily: "",
          borderRadius: 30,
          onPress: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => Dialog(
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
                        'Confirm End Trip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Are you sure you want to end the current trip',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.lightBlueColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.darkBlueColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // ✅ Execute original End Trip functionality
                              final dbRef = FirebaseDatabase.instance.ref(
                                'trips/${widget.tripId}',
                              );
                              await dbRef.update({'status': 'completed'});

                              // Close dialog
                              Navigator.of(context).pop(true);

                              // Show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Trip ended and marked as completed.',
                                  ),
                                  backgroundColor: AppColors.lightBlueColor,
                                ),
                              );

                              // Pop screen
                              Navigator.pop(context);
                            },
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
                                'End Trip',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
