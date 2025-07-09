import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // Default to SF

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FuelRoute Dashboard")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: originController,
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _drawRoute,
                  child: const Text("Draw Route"),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10,
              ),
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _drawRoute() async {
    final origin = originController.text;
    final destination = destinationController.text;

    if (origin.isEmpty || destination.isEmpty) return;

    try {
      final originLatLng = await _getLatLngFromAddress(origin);
      final destinationLatLng = await _getLatLngFromAddress(destination);

      final directions = await _getDirections(originLatLng, destinationLatLng);

      if (directions != null) {
        final List<LatLng> points = _decodePolyline(
          directions['overview_polyline']['points'],
        );

        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          };
        });

        // Move camera to start
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(_getLatLngBounds(points), 50),
        );
      }
    } catch (e) {
      print('Error drawing route: $e');
    }
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    final loc = locations.first;
    return LatLng(loc.latitude, loc.longitude);
  }

  Future<Map<String, dynamic>?> _getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    const apiKey = String.fromEnvironment(
      "AIzaSyDo8HGqkDwHuSuxcWAkHuK7H_gv1ThasBg",
    ); // ✅ or just paste it here temporarily

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if ((data['routes'] as List).isNotEmpty) {
        return data['routes'][0];
      }
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    final swLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final swLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    final neLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final neLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }
}
