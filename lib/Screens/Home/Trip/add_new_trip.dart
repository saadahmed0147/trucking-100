import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fuel_route/Screens/Home/Trip/calculator_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewTrip extends StatefulWidget {
  const AddNewTrip({super.key});

  @override
  State<AddNewTrip> createState() => _AddNewTripState();
}

class _AddNewTripState extends State<AddNewTrip> {
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
  final List<Map<String, dynamic>> categories = [
    {'label': 'Fuel', 'icon': '🛢️', 'types': 'gas_station'},
    {
      'label': 'Convenience',
      'icon': '🛒',
      'types': 'convenience_store|store|supermarket',
    },
    {'label': 'Truck Stops', 'icon': '🛑', 'keyword': 'truck stop'},
    {'label': 'Food', 'icon': '🍔', 'types': 'restaurant|food|cafe'},
    {'label': 'Parking', 'icon': '🅿️', 'types': 'parking'},
    {'label': 'Truck Wash', 'icon': '🧽', 'types': 'car_wash'},
    {'label': 'Walmart', 'icon': '🏪', 'keyword': 'Walmart'},
    {'label': 'Gym', 'icon': '🏋️', 'types': 'gym'},
    {'label': 'ATM/Bank', 'icon': '💵', 'types': 'atm|bank|finance'},
    {'label': 'Weigh Station', 'icon': '⚖️', 'keyword': 'weigh station'},
    {'label': 'Mechanics', 'icon': '🔧', 'types': 'car_repair'},
    {'label': 'Medical', 'icon': '🏥', 'types': 'hospital|doctor|pharmacy'},
    {'label': 'Rest/Hotels', 'icon': '🏨', 'types': 'lodging'},
    {
      'label': 'EV Charging',
      'icon': '🔋',
      'types': 'electric_vehicle_charging_station',
    },
    {'label': 'Warehouses', 'icon': '📦', 'types': 'storage|moving_company'},
    {'label': 'Border/Toll', 'icon': '🛃', 'keyword': 'toll'},
  ];

  @override
  void initState() {
    super.initState();
    selectedCategories = {}; // No category selected initially
    determinePosition();
  }

  String cleanLabel(String label) {
    return label
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(" ", "")
        .toLowerCase();
  }

  Future<void> determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    currentLocation = LatLng(position.latitude, position.longitude);

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation!, zoom: 14),
      ),
    );

    setState(() {
      markers.add(
        Marker(markerId: const MarkerId("current"), position: currentLocation!),
      );
    });
  }

  void updateMarkersAndRoute() async {
    if (origin != null && destination != null) {
      markers.removeWhere(
        (m) =>
            m.markerId.value == "origin" || m.markerId.value == "destination",
      );

      polylines.clear();
      polylineCoordinates.clear();

      markers.add(
        Marker(markerId: const MarkerId("origin"), position: origin!),
      );
      markers.add(
        Marker(markerId: const MarkerId("destination"), position: destination!),
      );

      await getDirections();

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          origin!.latitude < destination!.latitude
              ? origin!.latitude
              : destination!.latitude,
          origin!.longitude < destination!.longitude
              ? origin!.longitude
              : destination!.longitude,
        ),
        northeast: LatLng(
          origin!.latitude > destination!.latitude
              ? origin!.latitude
              : destination!.latitude,
          origin!.longitude > destination!.longitude
              ? origin!.longitude
              : destination!.longitude,
        ),
      );

      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));

      setState(() {});
    }
  }

  Future<void> getDirections() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin!.longitude}&destination=${destination!.latitude},${destination!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['routes'].isNotEmpty) {
      final points = PolylinePoints().decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      for (var point in points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ),
      );
    }
  }

  Future<void> fetchNearbyPlaces(Map<String, dynamic> category) async {
    if (currentLocation == null) return;

    LatLng referenceLocation = origin != null && destination != null
        ? LatLng(
            (origin!.latitude + destination!.latitude) / 2,
            (origin!.longitude + destination!.longitude) / 2,
          )
        : currentLocation!;

    final locationStr =
        '${referenceLocation.latitude},${referenceLocation.longitude}';
    final String url = category.containsKey('types')
        ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$locationStr&radius=7000&type=${category['types'].split("|")[0]}&key=$apiKey'
        : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$locationStr&radius=7000&keyword=${category['keyword']}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['results'] != null && data['results'].isNotEmpty) {
      final catKey = cleanLabel(category['label']);

      Set<String> addedCoords = {};

      for (var result in data['results']) {
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final name = result['name'];
        final id = result['place_id'];
        final coordKey = '$lat,$lng';

        // Avoid duplicates
        if (addedCoords.contains(coordKey)) continue;

        addedCoords.add(coordKey);
        final markerId = "poi_${catKey}_$id";

        markers.add(
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      }

      setState(() {});
    }
  }

  Future<void> _getPlacePredictions(String input, bool isPickup) async {
    if (input.isEmpty) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:us|country:ca';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    setState(() {
      if (isPickup) {
        _pickupPredictions = data['predictions'];
      } else {
        _destinationPredictions = data['predictions'];
      }
    });
  }

  Future<void> _getPlaceLatLng(String placeId, bool isPickup) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final lat = data['result']['geometry']['location']['lat'];
    final lng = data['result']['geometry']['location']['lng'];
    final selectedLocation = LatLng(lat, lng);

    setState(() {
      if (isPickup) {
        origin = selectedLocation;
        _pickupPredictions = [];
      } else {
        destination = selectedLocation;
        _destinationPredictions = [];
      }

      if (origin != null && destination != null) {
        updateMarkersAndRoute();
      }
    });
  }

  Widget buildSearchBox(
    String hint,
    TextEditingController controller,
    bool isPickup,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        onChanged: (val) => _getPlacePredictions(val, isPickup),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget buildPredictionList(List<dynamic> predictions, bool isPickup) {
    if (predictions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: predictions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final prediction = predictions[index];
          return ListTile(
            title: Text(
              prediction['description'],
              style: const TextStyle(fontSize: 15),
            ),
            leading: const Icon(
              Icons.location_on_rounded,
              color: Colors.deepOrange,
            ),
            onTap: () {
              final placeId = prediction['place_id'];
              final description = prediction['description'];

              if (isPickup) {
                _pickupController.text = description;
              } else {
                _destinationController.text = description;
              }

              _getPlaceLatLng(placeId, isPickup);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.773972, -122.431297),
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
                  buildSearchBox(
                    "Enter Pickup Location",
                    _pickupController,
                    true,
                  ),
                  buildPredictionList(_pickupPredictions, true),
                  const SizedBox(height: 10),
                  buildSearchBox(
                    "Enter Destination",
                    _destinationController,
                    false,
                  ),
                  buildPredictionList(_destinationPredictions, false),
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final catKey = cleanLabel(cat['label']);
                      final isSelected = selectedCategories.contains(catKey);

                      return GestureDetector(
                        onTap: () async {
                          final isSelected = selectedCategories.contains(
                            catKey,
                          );
                          setState(() {
                            if (isSelected) {
                              selectedCategories.remove(catKey);
                              markers.removeWhere(
                                (m) => m.markerId.value.startsWith(
                                  "poi_${catKey}_",
                                ),
                              );
                            } else {
                              selectedCategories.add(catKey);
                            }
                          });

                          if (!isSelected) {
                            fetchNearbyPlaces(
                              cat,
                            ); // only fetch if newly selected
                          }
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),

                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Colors.blue, Colors.blueAccent],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent),
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
                                Text(
                                  cat['icon'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 35,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blue,
                                  ),
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
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
            child: const Text('Next'),
            onPressed: () async {
              if (origin != null && destination != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in!')),
                  );
                  return;
                }

                // ❌ REMOVE OR COMMENT THIS BLOCK TO SKIP FIREBASE SAVE
                // final tripData = {
                //   'pickup': {
                //     'lat': origin!.latitude,
                //     'lng': origin!.longitude,
                //     'name': _pickupController.text,
                //   },
                //   'destination': {
                //     'lat': destination!.latitude,
                //     'lng': destination!.longitude,
                //     'name': _destinationController.text,
                //   },
                //   'timestamp': DateTime.now().toIso8601String(),
                //   'user': {
                //     'uid': user.uid,
                //     'email': user.email,
                //     'displayName': user.displayName,
                //   },
                // };
                // final dbRef = FirebaseDatabase.instance
                //     .ref()
                //     .child('selected_routes')
                //     .child(user.uid);
                // await dbRef.push().set(tripData);

                // ✅ Proceed to next screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      print('''
🚛 Trip Details:
-------------------------
📍 Pickup Location: ${_pickupController.text}
📍 Destination: ${_destinationController.text}

👤 User Name: ${user.displayName ?? 'N/A'}
📧 User Email: ${user.email ?? 'N/A'}

🌍 Pickup Coordinates:
   - Latitude: ${origin!.latitude}
   - Longitude: ${origin!.longitude}

🌍 Destination Coordinates:
   - Latitude: ${destination!.latitude}
   - Longitude: ${destination!.longitude}
-------------------------
''');
                      return CalculatorScreen(
                        pickup: _pickupController.text,
                        destination: _destinationController.text,
                        userName: user.displayName ?? 'N/A',
                        userEmail: user.email ?? 'N/A',
                        pickupLat: origin!.latitude,
                        pickupLng: origin!.longitude,
                        destinationLat: destination!.latitude,
                        destinationLng: destination!.longitude,
                      );
                    },
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select both pickup and destination.'),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
