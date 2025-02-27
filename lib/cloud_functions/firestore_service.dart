import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Allows a user to offer a ride
  Future<void> offerRide(String from, String to, String date, String time, String seats) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

      await _db.collection('offers').add({
        "userId": userId,
        "from": from,
        "to": to,
        "date": date,
        "time": time,
        "seats": seats,
      });

      print("✅ Ride offer saved successfully!");
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  /// Fetches upcoming rides from Firestore
  Future<List<Map<String, String>>> fetchUpcomingRides() async {
    try {
      QuerySnapshot snapshot = await _db.collection('rides').get();
      print("🔥 Firestore Fetch: Found ${snapshot.docs.length} upcoming rides");

      return snapshot.docs.map((doc) {
        return {
          "rideId": doc.id,
          "from": doc["from"]?.toString() ?? "Unknown",
          "to": doc["to"]?.toString() ?? "Unknown",
          "date": doc["date"]?.toString() ?? "Unknown",
          "time": doc["time"]?.toString() ?? "Unknown",
        };
      }).toList();
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

  /// Fetches ride requests for rides offered by the current user
  Future<List<Map<String, String>>> fetchRideRequests() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

      QuerySnapshot snapshot = await _db
          .collection('ride_requests')
          .where("rideOwnerId", isEqualTo: userId)
          .get();

      print("🔥 Firestore Fetch: Found ${snapshot.docs.length} ride requests");

      return snapshot.docs.map((doc) {
        return {
          "requestId": doc.id,
          "userId": doc["userId"]?.toString() ?? "Unknown",
          "rideId": doc["rideId"]?.toString() ?? "Unknown",
          "from": doc["from"]?.toString() ?? "Unknown",
          "to": doc["to"]?.toString() ?? "Unknown",
          "date": doc["date"]?.toString() ?? "Unknown",
          "time": doc["time"]?.toString() ?? "Unknown",
          "status": doc["status"]?.toString() ?? "pending",
        };
      }).toList();
    } catch (e) {
      print("🔥 Firestore Error: $e");
      return [];
    }
  }

  /// Allows a user to request a ride
  Future<void> requestRide(String rideId, String from, String to, String date, String time) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

      // Get the ride details to extract rideOwnerId
      DocumentSnapshot rideDoc = await _db.collection('rides').doc(rideId).get();
      String rideOwnerId = rideDoc.exists ? rideDoc["userId"] ?? "unknown_owner" : "unknown_owner";

      await _db.collection('ride_requests').add({
        "userId": userId,
        "rideId": rideId,
        "from": from,
        "to": to,
        "date": date,
        "time": time,
        "status": "pending",
        "rideOwnerId": rideOwnerId, // ✅ Now added to Firestore
      });

      print("✅ Ride request sent successfully!");
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  /// Updates the status of a ride request (accept or reject)
  Future<void> updateRideRequestStatus(String requestId, String status) async {
    try {
      await _db.collection('ride_requests').doc(requestId).update({
        "status": status,
      });

      print("✅ Ride request updated: $status");
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }
}









// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   /// Fetches upcoming rides from Firestore
//   Future<List<Map<String, String>>> fetchUpcomingRides() async {
//     try {
//       QuerySnapshot snapshot = await _db.collection('rides').get();

//       print("🔥 Firestore Fetch: Found ${snapshot.docs.length} documents"); // Debugging print

//       List<Map<String, String>> rides = snapshot.docs.map((doc) {
//         Map<String, String> ride = {
//           "from": doc["from"]?.toString() ?? "Unknown",
//           "to": doc["to"]?.toString() ?? "Unknown",
//           "date": doc["date"]?.toString() ?? "Unknown",
//           "time": doc["time"]?.toString() ?? "Unknown",
//         };

//         print("✅ Ride: $ride"); // Debugging print for each ride
//         return ride;
//       }).toList();

//       return rides;
//     } catch (e) {
//       print("🔥 Firestore Error: $e");
//       return [];
//     }
//   }

//     /// Fetches ride offers from Firestore
//   Future<List<Map<String, String>>> fetchRideOffers() async {
//     try {
//       QuerySnapshot snapshot = await _db.collection('offers').get();
//       print("🔥 Firestore Fetch: Found ${snapshot.docs.length} ride offers");

//       return snapshot.docs.map((doc) {
//         return {
//           "from": doc["from"]?.toString() ?? "Unknown",
//           "to": doc["to"]?.toString() ?? "Unknown",
//           "date": doc["date"]?.toString() ?? "Unknown",
//           "time": doc["time"]?.toString() ?? "Unknown",
//           "seats": doc["seats"]?.toString() ?? "Unknown",
//         };
//       }).toList();
//     } catch (e) {
//       print("🔥 Firestore Error: $e");
//       return [];
//     }
//   } 
// }
