import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class NavigationScreen extends StatefulWidget {
  final String tripId;
  final double? pickupLat;
  final double? pickupLng;
  final double? destinationLat;
  final double? destinationLng;

  const NavigationScreen({
    super.key,
    required this.tripId,
    this.pickupLat,
    this.pickupLng,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late GoogleMapController mapController;

  LatLng? origin;
  LatLng? destination;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  String durationText = '';
  String distanceText = '';
  String arrivalTime = '';
  String currentInstruction = '';
  bool routeError = false;

  final String apiKey = 'AIzaSyDo8HGqkDwHuSuxcWAkHuK7H_gv1ThasBg';
  final PolylinePoints polylinePoints = PolylinePoints();
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    loadTripData();
    trackUserLocation();
  }

  Future<void> loadTripData() async {
    if (widget.pickupLat != null &&
        widget.pickupLng != null &&
        widget.destinationLat != null &&
        widget.destinationLng != null) {
      origin = LatLng(widget.pickupLat!, widget.pickupLng!);
      destination = LatLng(widget.destinationLat!, widget.destinationLng!);
      await fetchPolyline();
      await fetchRouteInfo();
      setState(() {});
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref('trips/${widget.tripId}');
    final snapshot = await dbRef.get();
    final trip = snapshot.value as Map?;

    if (trip != null &&
        trip['pickupLat'] != null &&
        trip['pickupLng'] != null &&
        trip['destinationLat'] != null &&
        trip['destinationLng'] != null) {
      origin = LatLng(
        double.parse(trip['pickupLat'].toString()),
        double.parse(trip['pickupLng'].toString()),
      );
      destination = LatLng(
        double.parse(trip['destinationLat'].toString()),
        double.parse(trip['destinationLng'].toString()),
      );
      await fetchPolyline();
      await fetchRouteInfo();
    }
  }

  void trackUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20,
          ),
        ).listen((Position position) async {
          LatLng currentLocation = LatLng(
            position.latitude,
            position.longitude,
          );

          setState(() {
            origin = currentLocation;
            markers.removeWhere((m) => m.markerId.value == 'start');
            markers.add(
              Marker(
                markerId: const MarkerId('start'),
                position: origin!,
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            );
          });

          mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
          await fetchPolyline();
          await fetchRouteInfo();
        });
  }

  Future<void> fetchPolyline() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin!.longitude}&destination=${destination!.latitude},${destination!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['routes'] != null &&
        data['routes'].isNotEmpty &&
        data['routes'][0]['legs'] != null) {
      List<LatLng> fullRoute = [];
      final steps = data['routes'][0]['legs'][0]['steps'];

      for (var step in steps) {
        final encoded = step['polyline']['points'];
        final decodedStep = polylinePoints.decodePolyline(encoded);
        fullRoute.addAll(
          decodedStep.map((e) => LatLng(e.latitude, e.longitude)),
        );
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
    } else {
      print('❌ No polyline data found');
      setState(() {
        routeError = true;
      });
    }
  }

  Future<void> fetchRouteInfo() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin!.longitude}&destination=${destination!.latitude},${destination!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'REQUEST_DENIED') {
      print('❌ REQUEST_DENIED: ${data['error_message']}');
      setState(() {
        routeError = true;
      });
      return;
    }

    if (data['routes'] != null &&
        data['routes'].isNotEmpty &&
        data['routes'][0]['legs'] != null) {
      final leg = data['routes'][0]['legs'][0];

      distanceText = leg['distance']['text'];
      durationText = leg['duration']['text'];

      final arrivalTimestamp = DateTime.now().add(
        Duration(seconds: leg['duration']['value']),
      );
      arrivalTime = DateFormat('hh:mm a').format(arrivalTimestamp);

      final steps = leg['steps'] as List;
      if (steps.isNotEmpty) {
        final firstStep = steps[0];
        final htmlInstruction = firstStep['html_instructions'] ?? '';
        currentInstruction = _parseHtmlInstructions(htmlInstruction);
      }

      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      setState(() {});
    }
  }

  String _parseHtmlInstructions(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: origin == null || destination == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: origin!,
                    zoom: 15.5,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false, // Hide default compass
                ),

                // ✅ Top Instruction
                if (!routeError && currentInstruction.isNotEmpty)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.straight,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentInstruction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ❌ Route Error
                if (routeError)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.error, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Unable to fetch route. Please check API key configuration.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ✅ Floating Buttons
                Positioned(
                  right: 16,
                  bottom: 140,
                  child: Column(
                    children: [
                      _roundedIconButton(
                        Icons.my_location,
                        onPressed: () {
                          if (origin != null) {
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(origin!),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _roundedIconButton(
                        Icons.explore, // Compass icon
                        onPressed: () {
                          if (origin != null) {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: origin!,
                                  zoom: 15.5,
                                  bearing: 0,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ✅ Bottom Info Card
                Positioned(
                  bottom: 10,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          durationText,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$distanceText ',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _roundedIconButton(IconData icon, {required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}
