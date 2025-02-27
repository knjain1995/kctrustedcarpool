import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';

class UpcomingRidesScreen extends StatefulWidget {
  @override
  _UpcomingRidesScreenState createState() => _UpcomingRidesScreenState();
}

class _UpcomingRidesScreenState extends State<UpcomingRidesScreen> {
  bool isLoading = true;
  List<Map<String, String>> upcomingRides = [];
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchRides();
  }

  Future<void> fetchRides() async {
    print("📢 Fetching rides from Firestore...");
    List<Map<String, String>> rides = await firestoreService.fetchUpcomingRides();
    setState(() {
      upcomingRides = rides;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upcoming Rides"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : upcomingRides.isEmpty
              ? Center(child: Text("No upcoming rides available."))
              : ListView.builder(
                  itemCount: upcomingRides.length,
                  itemBuilder: (context, index) {
                    return RideCard(
                      ride: upcomingRides[index],
                      firestoreService: firestoreService,
                    );
                  },
                ),
    );
  }
}

class RideCard extends StatelessWidget {
  final Map<String, String> ride;
  final FirestoreService firestoreService;

  RideCard({required this.ride, required this.firestoreService});

  void _requestRide(BuildContext context) {
    firestoreService.requestRide(
      ride["rideId"]!,
      ride["from"]!,
      ride["to"]!,
      ride["date"]!,
      ride["time"]!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ride request sent!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("From: ${ride["from"]}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("To: ${ride["to"]}"),
            SizedBox(height: 5),
            Text("Date: ${ride["date"]}", style: TextStyle(color: Colors.grey[700])),
            Text("Time: ${ride["time"]}", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _requestRide(context),
              child: Text("Request Ride"),
            ),
          ],
        ),
      ),
    );
  }
}







// class UpcomingRidesScreen extends StatefulWidget {
//   @override
//   _UpcomingRidesScreenState createState() => _UpcomingRidesScreenState();
// }

// class _UpcomingRidesScreenState extends State<UpcomingRidesScreen> {
//   bool isLoading = true;
//   List<Map<String, String>> upcomingRides = [];
//   FirestoreService firestoreService = FirestoreService();

//   @override
//   void initState() {
//     super.initState();
//     fetchRides();
//   }

//   Future<void> fetchRides() async {
//     print("📢 Fetching rides from Firestore...");
//     List<Map<String, String>> rides = await firestoreService.fetchUpcomingRides();
//     print("📢 Rides received: $rides");

//     setState(() {
//       upcomingRides = rides;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Upcoming Rides"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 isLoading = true;
//               });
//               fetchRides();
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchRides,
//         child: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : upcomingRides.isEmpty
//                 ? Center(child: Text("No upcoming rides available."))
//                 : ListView.builder(
//                     itemCount: upcomingRides.length,
//                     itemBuilder: (context, index) {
//                       return RideCard(
//                         from: upcomingRides[index]["from"]!,
//                         to: upcomingRides[index]["to"]!,
//                         date: upcomingRides[index]["date"]!,
//                         time: upcomingRides[index]["time"]!,
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }

// class RideCard extends StatelessWidget {
//   final String from, to, date, time;

//   const RideCard({
//     required this.from,
//     required this.to,
//     required this.date,
//     required this.time,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("From: $from", style: TextStyle(fontWeight: FontWeight.bold)),
//             Text("To: $to"),
//             SizedBox(height: 5),
//             Text("Date: $date", style: TextStyle(color: Colors.grey[700])),
//             Text("Time: $time", style: TextStyle(color: Colors.grey[700])),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';

// class UpcomingRidesScreen extends StatefulWidget {
//   @override
//   _UpcomingRidesScreenState createState() => _UpcomingRidesScreenState();
// }

// class _UpcomingRidesScreenState extends State<UpcomingRidesScreen> {
//   bool isLoading = true; // Start with loading
//   List<Map<String, String>> upcomingRides = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchRides();
//   }

//   Future<void> fetchRides() async {
//     FirestoreService firestoreService = FirestoreService();
//     List<Map<String, String>> rides = await firestoreService.fetchUpcomingRides();

//     setState(() {
//       upcomingRides = rides;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Center(child: CircularProgressIndicator()) // Show loader if data is loading
//         : upcomingRides.isEmpty
//             ? Center(child: Text("No upcoming rides available."))
//             : ListView.builder(
//                 itemCount: upcomingRides.length,
//                 itemBuilder: (context, index) {
//                   return RideCard(
//                     from: upcomingRides[index]["from"]!,
//                     to: upcomingRides[index]["to"]!,
//                     date: upcomingRides[index]["date"]!,
//                     time: upcomingRides[index]["time"]!,
//                   );
//                 },
//               );
//   }
// }
