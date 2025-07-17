import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Screens/Home/Trip/calculator_screen.dart';
import 'package:fuel_route/Utils/Add%20New%20Trip%20utils/map_helpers.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/main.dart';
import 'package:fuel_route/map_api_key.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';

class AddNewTrip extends StatefulWidget {
  const AddNewTrip({super.key});

  @override
  State<AddNewTrip> createState() => _AddNewTripState();
}

class _AddNewTripState extends State<AddNewTrip> {
  Timer? _debounce;

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

  final String apiKey = ApiKeys.googleMapsApiKey;

  Set<String> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    selectedCategories = {}; // No category selected initially
    getCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();  
  }

  void getCurrentLocation() async {
    final location = await determinePosition(
      _controller,
      markers,
      (updatedMarkers) {
        // Always filter out current_location marker if both origin and destination are set
        Set<Marker> filteredMarkers = Set.from(updatedMarkers);
        if (origin != null && destination != null) {
          filteredMarkers.removeWhere(
            (m) => m.markerId.value == 'current_location',
          );
        }
        setState(() {
          markers = filteredMarkers;
        });
      },
      shouldShowMarker:
          _pickupController == false || destination == null, // ✅ ONLY IF needed
    );

    if (location != null) {
      setState(() {
        currentLocation = location;
        // Remove current location marker if both locations are set
        if (origin != null && destination != null) {
          markers.removeWhere((m) => m.markerId.value == 'current_location');
        }
      });
    }
  }

  Future<void> getDirections() async {
    polylines.clear();
    polylineCoordinates.clear();

    // Always remove current location marker before drawing route
    setState(() {
      markers.removeWhere((m) => m.markerId.value == 'current_location');
    });

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

  Future<void> _getPlacePredictions(String input, bool isPickup) async {
    if (input.isEmpty) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:us';

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
    });

    // After both are set, update the route polyline, remove current location marker, add pickup/destination markers, and animate camera
    if (origin != null && destination != null) {
      // Remove current location marker before and after getDirections
      setState(() {
        markers.removeWhere((m) => m.markerId.value == 'current_location');
      });
      await getDirections();
      setState(() {
        markers.removeWhere((m) => m.markerId.value == 'current_location');
        // Remove any previous pickup/destination markers
        markers.removeWhere((m) => m.markerId.value == 'pickup');
        markers.removeWhere((m) => m.markerId.value == 'destination');
        // Add pickup marker
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: origin!,
            infoWindow: const InfoWindow(title: 'Pickup'),
          ),
        );
        // Add destination marker
        markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination!,
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      });
      // Remove current location marker one more time for safety
      setState(() {
        markers.removeWhere((m) => m.markerId.value == 'current_location');
      });
      // Animate camera to pickup location
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(origin!, 15.5));
    }
  }

  LatLng getInitialMapTarget() {
    if (origin?.latitude != null && origin?.longitude != null) {
      return LatLng(origin!.latitude, origin!.longitude);
    } else if (currentLocation != null) {
      return currentLocation!;
    } else {
      return const LatLng(37.773972, -122.431297); // Default: San Francisco
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
                  buildSearchBox(
                    hint: "Enter Pickup Location",
                    controller: _pickupController,
                    isPickup: true,
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _getPlacePredictions(val, true);
                      });
                    },
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.gps_fixed, color: Colors.black),
                      onPressed: () async {
                        if (currentLocation != null) {
                          // Get address from lat/lng
                          String locationName = await getAddressFromLatLng(
                            currentLocation!,
                          );
                          _pickupController.text = locationName;
                          setState(() {
                            origin = currentLocation;
                            _pickupPredictions = [];
                          });
                          // Update route if destination is set
                          if (destination != null) {
                            await getDirections();
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ),

                  buildPredictionList(
                    predictions: _pickupPredictions,
                    isPickup: true,
                    onTapPrediction: (placeId, description) {
                      _pickupController.text = description;
                      _getPlaceLatLng(placeId, true);
                    },
                  ),

                  buildSearchBox(
                    hint: "Enter Destination",
                    controller: _destinationController,
                    isPickup: false,
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _getPlacePredictions(val, false);
                      });
                    },
                  ),

                  buildPredictionList(
                    predictions: _destinationPredictions,
                    isPickup: false,
                    onTapPrediction: (placeId, description) {
                      _destinationController.text = description;
                      _getPlaceLatLng(placeId, false);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: mq.width * 0.3,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions, color: Colors.white),
                        label: const Text('Direction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // Only trigger if both fields have values
                          if (_pickupController.text.isNotEmpty &&
                              _destinationController.text.isNotEmpty) {
                            // Try to get placeId for pickup
                            String? pickupPlaceId;
                            String? destinationPlaceId;
                            // Find placeId from predictions if available
                            if (_pickupPredictions.isNotEmpty) {
                              final match = _pickupPredictions.firstWhere(
                                (p) =>
                                    p['description'] == _pickupController.text,
                                orElse: () => null,
                              );
                              if (match != null)
                                pickupPlaceId = match['place_id'];
                            }
                            if (_destinationPredictions.isNotEmpty) {
                              final match = _destinationPredictions.firstWhere(
                                (p) =>
                                    p['description'] ==
                                    _destinationController.text,
                                orElse: () => null,
                              );
                              if (match != null)
                                destinationPlaceId = match['place_id'];
                            }
                            // If not found, fallback to current values
                            if (pickupPlaceId != null) {
                              await _getPlaceLatLng(pickupPlaceId, true);
                            }
                            if (destinationPlaceId != null) {
                              await _getPlaceLatLng(destinationPlaceId, false);
                            }
                            // If both lat/lng are already set, just update route and markers
                            if (origin != null && destination != null) {
                              // Remove current location marker before and after getDirections
                              setState(() {
                                markers.removeWhere(
                                  (m) => m.markerId.value == 'current_location',
                                );
                              });
                              await getDirections();
                              setState(() {
                                markers.removeWhere(
                                  (m) => m.markerId.value == 'current_location',
                                );
                                markers.removeWhere(
                                  (m) => m.markerId.value == 'pickup',
                                );
                                markers.removeWhere(
                                  (m) => m.markerId.value == 'destination',
                                );
                                markers.add(
                                  Marker(
                                    markerId: const MarkerId('pickup'),
                                    position: origin!,
                                    infoWindow: const InfoWindow(
                                      title: 'Pickup',
                                    ),
                                  ),
                                );
                                markers.add(
                                  Marker(
                                    markerId: const MarkerId('destination'),
                                    position: destination!,
                                    infoWindow: const InfoWindow(
                                      title: 'Destination',
                                    ),
                                  ),
                                );
                              });
                              setState(() {
                                markers.removeWhere(
                                  (m) => m.markerId.value == 'current_location',
                                );
                              });
                              final GoogleMapController controller =
                                  await _controller.future;
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(origin!, 15.5),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select both pickup and destination.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // DraggableScrollableSheet(
          //   initialChildSize: 0.25,
          //   minChildSize: 0.25,
          //   maxChildSize: 0.7,
          //   builder: (context, scrollController) {
          //     return Container(
          //       decoration: const BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          //       ),
          //       child: SingleChildScrollView(
          //         controller: scrollController,
          //         padding: const EdgeInsets.all(16),
          //         child: Column(
          //           children: [
          //             Text(
          //               "Find Places on Route",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 16,
          //               ),
          //             ),
          //             GridView.builder(
          //               shrinkWrap: true,
          //               physics: const NeverScrollableScrollPhysics(),
          //               gridDelegate:
          //                   const SliverGridDelegateWithFixedCrossAxisCount(
          //                     crossAxisCount: 4,
          //                     mainAxisSpacing: 12,
          //                     crossAxisSpacing: 12,
          //                     childAspectRatio: 1,
          //                   ),
          //               itemCount: poiCategories.length,
          //               itemBuilder: (context, index) {
          //                 final cat = poiCategories[index];
          //                 final catKey = cleanLabel(cat['label']);
          //                 final isSelected = selectedCategories.contains(
          //                   catKey,
          //                 );

          //                 return GestureDetector(
          //                   onTap: () async {
          //                     final isSelected = selectedCategories.contains(
          //                       catKey,
          //                     );
          //                     setState(() {
          //                       // Only allow one active category at a time
          //                       selectedCategories.clear();
          //                       if (!isSelected) {
          //                         selectedCategories.add(catKey);
          //                       }
          //                     });

          //                     // Always clear all POI markers before showing new ones
          //                     Set<Marker> newCategoryMarkers = {};
          //                     if (selectedCategories.isNotEmpty) {
          //                       final activeCatKey = selectedCategories.first;
          //                       final activeCat = poiCategories.firstWhere(
          //                         (c) => cleanLabel(c['label']) == activeCatKey,
          //                       );
          //                       await fetchNearbyPlaces(
          //                         category: activeCat,
          //                         origin: origin,
          //                         destination: destination,
          //                         currentLocation: currentLocation,
          //                         apiKey: apiKey,
          //                         markers: newCategoryMarkers,
          //                         onMarkersUpdated: (_) {},
          //                         routePolyline:
          //                             (origin != null &&
          //                                 destination != null &&
          //                                 polylineCoordinates.isNotEmpty)
          //                             ? polylineCoordinates
          //                             : null,
          //                       );
          //                     }
          //                     // Remove all previous POI markers
          //                     markers.removeWhere(
          //                       (m) => m.markerId.value.startsWith("poi_"),
          //                     );
          //                     // Add only the new markers for the active category
          //                     setState(() {
          //                       markers.addAll(newCategoryMarkers);
          //                     });
          //                   },

          //                   child: AnimatedContainer(
          //                     duration: const Duration(milliseconds: 200),

          //                     decoration: BoxDecoration(
          //                       gradient: isSelected
          //                           ? const LinearGradient(
          //                               colors: [
          //                                 Colors.blue,
          //                                 Colors.blueAccent,
          //                               ],
          //                             )
          //                           : null,
          //                       color: isSelected ? null : Colors.white,
          //                       borderRadius: BorderRadius.circular(20),
          //                       border: Border.all(color: Colors.blueAccent),
          //                       boxShadow: isSelected
          //                           ? [
          //                               const BoxShadow(
          //                                 color: Colors.blueAccent,
          //                                 blurRadius: 5,
          //                                 offset: Offset(0, 2),
          //                               ),
          //                             ]
          //                           : [],
          //                     ),
          //                     child: Center(
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.center,
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: [
          //                           Icon(
          //                             cat["icon"],
          //                             color: AppColors.splashBgColor,
          //                             size: 35,
          //                           ),
          //                           Text(
          //                             cat['label'],
          //                             textAlign: TextAlign.center,
          //                             style: TextStyle(
          //                               fontWeight: FontWeight.w600,
          //                               fontSize: 14,
          //                               color: isSelected
          //                                   ? Colors.white
          //                                   : Colors.blue,
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: RoundButton(
            title: 'Next',
            fontFamily: "",
            fontSize: 18,
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(vertical: 14),
            bgColor: AppColors.lightBlueColor,
            titleColor: Colors.white,
            onPress: () async {
              if (origin != null && destination != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in!')),
                  );
                  return;
                }

                final url =
                    'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin!.longitude}&destination=${destination!.latitude},${destination!.longitude}&key=$apiKey';
                final response = await http.get(Uri.parse(url));
                final data = jsonDecode(response.body);

                if (data['status'] == 'ZERO_RESULTS' ||
                    data['routes'].isEmpty) {
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalculatorScreen(
                      pickup: _pickupController.text,
                      destination: _destinationController.text,
                      userName: user.displayName ?? 'N/A',
                      userEmail: user.email ?? 'N/A',
                      pickupLat: origin!.latitude,
                      pickupLng: origin!.longitude,
                      destinationLat: destination!.latitude,
                      destinationLng: destination!.longitude,
                    ),
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

  // Add this helper function to your class:
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
