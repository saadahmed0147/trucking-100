
 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//
// Function to clean up labels by removing special characters and spaces
 String cleanLabel(String label) {
    return label
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(" ", "")
        .toLowerCase();
  }


 
// marker and route update function
Future<void> updateMarkersAndRoute({
  required LatLng origin,
  required LatLng destination,
  required Set<Marker> markers,
  required Set<Polyline> polylines,
  required List<LatLng> polylineCoordinates,
  required Completer<GoogleMapController> controllerCompleter,
  required String apiKey,
  required Function updateUI,
}) async {
  markers.removeWhere(
    (m) => m.markerId.value == "origin" || m.markerId.value == "destination",
  );

  polylines.clear();
  polylineCoordinates.clear();

  markers.add(
    Marker(markerId: const MarkerId("origin"), position: origin),
  );
  markers.add(
    Marker(markerId: const MarkerId("destination"), position: destination),
  );

  // Call directions API
  final url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

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

  // Animate camera to bounds
  LatLngBounds bounds = LatLngBounds(
    southwest: LatLng(
      origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
      origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
    ),
    northeast: LatLng(
      origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
      origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
    ),
  );

  final controller = await controllerCompleter.future;
  controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));

  // Call setState via passed callback
  updateUI();
}


// Function to determine the user's current position and update markers
Future<LatLng?> determinePosition(
  Completer<GoogleMapController> controllerCompleter,
  Set<Marker> markers,
  Function(Set<Marker>) updateMarkers,
) async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    final controller = await controllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation, zoom: 14),
      ),
    );

    markers.add(
      Marker(markerId: const MarkerId("current"), position: currentLocation),
    );
    updateMarkers(markers);

    return currentLocation;
  } catch (e) {
    debugPrint("Location error: $e");
    return null;
  }
}



// Function to build a list of predictions for autocomplete
Widget buildPredictionList({
  required List<dynamic> predictions,
  required bool isPickup,
  required Function(String placeId, String description) onTapPrediction,
}) {
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
            onTapPrediction(placeId, description);
          },
        );
      },
    ),
  );
}
// Function to build a search box for entering pickup or drop-off locations
Widget buildSearchBox({
  required String hint,
  required TextEditingController controller,
  required bool isPickup,
  required Function(String) onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
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



// Directions service to fetch route details and polyline
class DirectionsService {
  static Future<Set<Polyline>> getDirections({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    required List<LatLng> polylineCoordinates,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    Set<Polyline> polylines = {};

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

    return polylines;
  }
}



// Function to fetch nearby places based on category and location
Future<void> fetchNearbyPlaces({
  required Map<String, dynamic> category,
  required LatLng? origin,
  required LatLng? destination,
  required LatLng? currentLocation,
  required String apiKey,
  required Set<Marker> markers,
  required Function(Set<Marker>) onMarkersUpdated,
}) async {
  if (currentLocation == null) return;

  LatLng referenceLocation = origin != null && destination != null
      ? LatLng(
          (origin.latitude + destination.latitude) / 2,
          (origin.longitude + destination.longitude) / 2,
        )
      : currentLocation;

  final locationStr = '${referenceLocation.latitude},${referenceLocation.longitude}';

  final String url = category.containsKey('types')
      ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$locationStr&radius=7000&type=${category['types'].split("|")[0]}&key=$apiKey'
      : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$locationStr&radius=7000&keyword=${category['keyword']}&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);

  if (data['results'] != null && data['results'].isNotEmpty) {
    String cleanLabel(String label) {
      return label.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(" ", "").toLowerCase();
    }

    final catKey = cleanLabel(category['label']);
    Set<String> addedCoords = {};

    Set<Marker> newMarkers = {};

    for (var result in data['results']) {
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      final name = result['name'];
      final id = result['place_id'];
      final coordKey = '$lat,$lng';

      if (addedCoords.contains(coordKey)) continue;
      addedCoords.add(coordKey);

      final markerId = "poi_${catKey}_$id";

      newMarkers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    // Merge with existing markers
    markers.addAll(newMarkers);
    onMarkersUpdated(markers); // call callback to trigger UI update
  }
}

// Function to get latitude and longitude of a place by its ID
Future<void> getPlaceLatLng({
  required String placeId,
  required bool isPickup,
  required String apiKey,
  required TextEditingController pickupController,
  required TextEditingController destinationController,
  required void Function(LatLng) setOrigin,
  required void Function(LatLng) setDestination,
  required void Function(List<dynamic>) clearPickupPredictions,
  required void Function(List<dynamic>) clearDestinationPredictions,
  required void Function() onRouteReady,
}) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);

  final lat = data['result']['geometry']['location']['lat'];
  final lng = data['result']['geometry']['location']['lng'];
  final selectedLocation = LatLng(lat, lng);

  if (isPickup) {
    setOrigin(selectedLocation);
    clearPickupPredictions([]);
  } else {
    setDestination(selectedLocation);
    clearDestinationPredictions([]);
  }

  onRouteReady();
}