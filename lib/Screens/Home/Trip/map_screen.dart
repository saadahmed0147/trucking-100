import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/map_helpers.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/poi_categories.dart';
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
  // Google polyline decoder
  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

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
      currentLocation = LatLng(position.latitude, position.longitude);
      // Update pickup marker
      setState(() {
        markers.removeWhere((m) => m.markerId.value == 'pickup');
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: currentLocation!,
            infoWindow: const InfoWindow(title: 'Pickup (Live)'),
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
    // Decode all step polylines for accurate route
    final route = data['routes'][0];
    for (var leg in route['legs']) {
      for (var step in leg['steps']) {
        String encodedPolyline = step['polyline']['points'];
        List<LatLng> stepPoints = decodePolyline(encodedPolyline);
        polylineCoordinates.addAll(stepPoints);
      }
    }
    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blueAccent,
          width: 5,
          points: polylineCoordinates,
        ),
      );
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

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final isSelected = selectedCategories.contains(
                                catKey,
                              );
                              // Instantly update selection for fast UI feedback
                              setState(() {
                                selectedCategories.clear();
                                if (!isSelected) {
                                  selectedCategories.add(catKey);
                                }
                              });
                              // Remove all previous POI markers instantly
                              setState(() {
                                markers.removeWhere(
                                  (m) => m.markerId.value.startsWith("poi_"),
                                );
                              });
                              // Fetch and add new markers only if selected
                              if (!isSelected) {
                                Set<Marker> newCategoryMarkers = {};
                                final activeCat = poiCategories.firstWhere(
                                  (c) => cleanLabel(c['label']) == catKey,
                                );
                                // Always use routePolyline for POI search between both locations
                                await fetchNearbyPlaces(
                                  category: activeCat,
                                  origin: origin,
                                  destination: destination,
                                  currentLocation: currentLocation,
                                  apiKey: apiKey,
                                  markers: newCategoryMarkers,
                                  onMarkersUpdated: (_) {},
                                  routePolyline: polylineCoordinates.isNotEmpty
                                      ? polylineCoordinates
                                      : null,
                                );
                                setState(() {
                                  markers.addAll(newCategoryMarkers);
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
