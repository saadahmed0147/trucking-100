import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/navigation_screen.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/map_helpers.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/poi_categories.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/api_keys.dart';
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
  // List<dynamic> _pickupPredictions = [];
  // List<dynamic> _destinationPredictions = [];
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
        markerId: MarkerId("destination"),
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
          // ignore: unnecessary_null_comparison
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
    // final newPolylines = await DirectionsService.getDirections(
    //   origin: origin!,
    //   destination: destination!,
    //   apiKey: apiKey,
    //   polylineCoordinates: polylineCoordinates,
    // );

    // --- Use the same detailed polyline logic as navigation_screen.dart ---
    final PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> fullRoute = [];
    final steps = data['routes'][0]['legs'][0]['steps'];

    for (var step in steps) {
      final encoded = step['polyline']['points'];
      final decodedStep = polylinePoints.decodePolyline(encoded);
      fullRoute.addAll(decodedStep.map((e) => LatLng(e.latitude, e.longitude)));
    }
    setState(() {
      // polylines.addAll(newPolylines);
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
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.7,
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
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // ✅ prevents scroll conflict
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
                              final alreadySelected = selectedCategories
                                  .contains(catKey);
                              setState(() {
                                selectedCategories.clear();
                                if (!alreadySelected) {
                                  selectedCategories.add(catKey);
                                  isLoading = true;
                                  loadingCategory = catKey;
                                }
                              });

                              Set<Marker> newCategoryMarkers = {};
                              if (!alreadySelected) {
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

                                // Zoom to fit all markers
                                if (newCategoryMarkers.isNotEmpty) {
                                  LatLngBounds bounds = _calculateBounds(
                                    newCategoryMarkers,
                                  );
                                  final controller = await _controller.future;
                                  controller.animateCamera(
                                    CameraUpdate.newLatLngBounds(bounds, 50),
                                  );
                                }
                              }

                              markers.removeWhere(
                                (m) => m.markerId.value.startsWith("poi_"),
                              );

                              setState(() {
                                markers.addAll(newCategoryMarkers);
                                isLoading = false;
                                loadingCategory = "";
                              });
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,

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
        child: Icon(Icons.directions, color: AppColors.whiteColor),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
        child: RoundButton(
          title: 'End Trip',
          fontSize: 18,
          fontFamily: "",
          borderRadius: 30,
          onPress: () async {
            // ignore: unused_local_variable
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

  Future<void> fetchNearbyPlaces({
    required Map<String, dynamic> category,
    required LatLng? origin,
    required LatLng? destination,
    required LatLng? currentLocation,
    required String apiKey,
    required Set<Marker> markers,
    required Function(Set<Marker>) onMarkersUpdated,
    List<LatLng>? routePolyline,
  }) async {
    try {
      if (origin == null || destination == null) {
        debugPrint("Origin or destination is null. Cannot fetch places.");
        return;
      }

      final queryParam = category.containsKey('types')
          ? 'type=${category['types']}'
          : 'keyword=${category['keyword']}';

      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${origin.latitude},${origin.longitude}&radius=8000&$queryParam&key=$apiKey';
      debugPrint("Fetching places from URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint(
          "Failed to fetch places. Status code: ${response.statusCode}",
        );
        return;
      }

      final data = jsonDecode(response.body);
      if (data['results'] == null || data['results'].isEmpty) {
        debugPrint("No places found for the selected category.");
        return;
      }

      // Remove previous POI markers
      markers.removeWhere((m) => m.markerId.value.startsWith("poi_"));

      // Use high-resolution marker icon (e.g., 96px)
      final BitmapDescriptor customIcon = await getResizedMarker(
        category['iconPath'],
        96, // You can increase this to 120, 150, etc.
      );

      for (var place in data['results']) {
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        final name = place['name'];

        markers.add(
          Marker(
            markerId: MarkerId("poi_${place['place_id']}"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: customIcon,
          ),
        );
      }

      debugPrint("Markers added: ${markers.length}");
      onMarkersUpdated(markers);
    } catch (e) {
      debugPrint("Error fetching nearby places: $e");
    }
  }
}

Future<BitmapDescriptor> getResizedMarker(String assetPath, int width) async {
  final ByteData data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: width,
  );
  final frame = await codec.getNextFrame();
  final image = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(image!.buffer.asUint8List());
}

LatLngBounds _calculateBounds(Set<Marker> markers) {
  double? minLat, maxLat, minLng, maxLng;

  for (var marker in markers) {
    if (minLat == null || marker.position.latitude < minLat) {
      minLat = marker.position.latitude;
    }
    if (maxLat == null || marker.position.latitude > maxLat) {
      maxLat = marker.position.latitude;
    }
    if (minLng == null || marker.position.longitude < minLng) {
      minLng = marker.position.longitude;
    }
    if (maxLng == null || marker.position.longitude > maxLng) {
      maxLng = marker.position.longitude;
    }
  }

  return LatLngBounds(
    southwest: LatLng(minLat!, minLng!),
    northeast: LatLng(maxLat!, maxLng!),
  );
}
