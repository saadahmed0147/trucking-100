import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isLocationSaved() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasLocation') ?? false;
}