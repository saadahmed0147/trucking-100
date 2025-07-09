import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TripService {
  static Future<List<Map<String, String>>> fetchTripsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userEmail = user.email;
    final ref = FirebaseDatabase.instance.ref('trips');
    final snapshot = await ref.get();

    final List<Map<String, String>> trips = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final trip = Map<String, dynamic>.from(value);
        if (trip['userEmail'] == userEmail) {
          trips.add({
            'destination': trip['destination'] ?? '',
            'current': trip['pickup'] ?? '',
            'status': (trip['status'] ?? 'completed').toString().toUpperCase(),
          });
        }
      });
    }

    return trips.reversed.toList(); // latest first
  }
}
