import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches upcoming rides from Firestore
  Future<List<Map<String, String>>> fetchUpcomingRides() async {
    try {
      QuerySnapshot snapshot = await _db.collection('rides').get();

      print("🔥 Firestore Fetch: Found ${snapshot.docs.length} documents"); // Debugging print

      List<Map<String, String>> rides = snapshot.docs.map((doc) {
        Map<String, String> ride = {
          "from": doc["from"]?.toString() ?? "Unknown",
          "to": doc["to"]?.toString() ?? "Unknown",
          "date": doc["date"]?.toString() ?? "Unknown",
          "time": doc["time"]?.toString() ?? "Unknown",
        };

        print("✅ Ride: $ride"); // Debugging print for each ride
        return ride;
      }).toList();

      return rides;
    } catch (e) {
      print("🔥 Firestore Error: $e");
      return [];
    }
  }

    /// Fetches ride offers from Firestore
  Future<List<Map<String, String>>> fetchRideOffers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('offers').get();
      print("🔥 Firestore Fetch: Found ${snapshot.docs.length} ride offers");

      return snapshot.docs.map((doc) {
        return {
          "from": doc["from"]?.toString() ?? "Unknown",
          "to": doc["to"]?.toString() ?? "Unknown",
          "date": doc["date"]?.toString() ?? "Unknown",
          "time": doc["time"]?.toString() ?? "Unknown",
          "seats": doc["seats"]?.toString() ?? "Unknown",
        };
      }).toList();
    } catch (e) {
      print("🔥 Firestore Error: $e");
      return [];
    }
  }
}
