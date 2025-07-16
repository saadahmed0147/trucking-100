// lib/helpers/poi_marker_cache.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class POIMarkerCache {
  static final POIMarkerCache _instance = POIMarkerCache._internal();
  factory POIMarkerCache() => _instance;
  POIMarkerCache._internal();

  final Map<String, Set<Marker>> _categoryMarkers = {};

  void setMarkers(String categoryKey, Set<Marker> markers) {
    _categoryMarkers[categoryKey] = markers;
  }

  Set<Marker> getMarkers(String categoryKey) {
    return _categoryMarkers[categoryKey] ?? {};
  }

  Map<String, Set<Marker>> get allMarkers => _categoryMarkers;

  void clear() {
    _categoryMarkers.clear();
  }

  bool get isEmpty => _categoryMarkers.isEmpty;
}
