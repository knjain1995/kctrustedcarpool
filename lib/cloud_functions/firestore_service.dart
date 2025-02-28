import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



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

    // Store ride request in Firestore
    await _db.collection('ride_requests').add({
      "userId": userId,
      "rideId": rideId,
      "from": from,
      "to": to,
      "date": date,
      "time": time,
      "status": "pending",
      "rideOwnerId": rideOwnerId,
    });

    print("✅ Ride request sent successfully!");

    // Fetch ride owner's FCM token
    DocumentSnapshot userDoc = await _db.collection('users').doc(rideOwnerId).get();
    if (userDoc.exists && userDoc["fcmToken"] != null) {
      String rideOwnerToken = userDoc["fcmToken"];
      sendNotification(rideOwnerToken, "New Ride Request!", "Someone has requested your ride from $from to $to.");
    }
  } catch (e) {
    print("🔥 Firestore Error: $e");
  }
}

  /// Updates the status of a ride request (accept or reject)
Future<void> updateRideRequestStatus(String requestId, String status) async {
  try {
    DocumentSnapshot requestDoc = await _db.collection('ride_requests').doc(requestId).get();
    if (!requestDoc.exists) return;

    String userId = requestDoc["userId"];
    String from = requestDoc["from"];
    String to = requestDoc["to"];

    await _db.collection('ride_requests').doc(requestId).update({
      "status": status,
    });

    print("✅ Ride request updated: $status");

    // Notify the requester
    DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc["fcmToken"] != null) {
      String requesterToken = userDoc["fcmToken"];
      sendNotification(requesterToken, "Ride Request $status", "Your ride request from $from to $to was $status.");
    }
  } catch (e) {
    print("🔥 Firestore Error: $e");
  }
}

  /// Stores FCM token for the logged-in user
  Future<void> saveUserFCMToken() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await _db.collection('users').doc(userId).set({
          "fcmToken": token,
        }, SetOptions(merge: true));

        print("✅ FCM Token saved successfully!");
      }
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }


  Future<void> sendNotification(String token, String title, String body) async {
  const String serverKey = "YOUR_FIREBASE_SERVER_KEY"; // Replace with your Firebase Server Key

  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=$serverKey",
    },
    body: jsonEncode({
      "to": token,
      "notification": {
        "title": title,
        "body": body,
        "sound": "default",
      }
    }),
  );

  print("📢 Notification Sent: ${response.body}");
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



  // /// Allows a user to request a ride
  // Future<void> requestRide(String rideId, String from, String to, String date, String time) async {
  //   try {
  //     String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

  //     // Get the ride details to extract rideOwnerId
  //     DocumentSnapshot rideDoc = await _db.collection('rides').doc(rideId).get();
  //     String rideOwnerId = rideDoc.exists ? rideDoc["userId"] ?? "unknown_owner" : "unknown_owner";

  //     await _db.collection('ride_requests').add({
  //       "userId": userId,
  //       "rideId": rideId,
  //       "from": from,
  //       "to": to,
  //       "date": date,
  //       "time": time,
  //       "status": "pending",
  //       "rideOwnerId": rideOwnerId, // ✅ Now added to Firestore
  //     });

  //     print("✅ Ride request sent successfully!");
  //   } catch (e) {
  //     print("🔥 Firestore Error: $e");
  //   }
  // }


  //   /// Updates the status of a ride request (accept or reject)
  // Future<void> updateRideRequestStatus(String requestId, String status) async {
  //   try {
  //     await _db.collection('ride_requests').doc(requestId).update({
  //       "status": status,
  //     });

  //     print("✅ Ride request updated: $status");
  //   } catch (e) {
  //     print("🔥 Firestore Error: $e");
  //   }
  // }
  