import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';

import '../chat/chat_screen.dart';

class RideManagementScreen extends StatefulWidget {
  @override
  _RideManagementScreenState createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  bool isLoading = true;
  List<Map<String, String>> rideRequests = [];
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchRideRequests();
  }

  Future<void> fetchRideRequests() async {
    print("📢 Fetching ride requests from Firestore...");
    List<Map<String, String>> requests = await firestoreService.fetchRideRequests();
    setState(() {
      rideRequests = requests;
      isLoading = false;
    });
  }

  void _updateRequestStatus(String requestId, String status) {
    firestoreService.updateRideRequestStatus(requestId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request marked as $status")),
    );
    fetchRideRequests(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Ride Requests")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : rideRequests.isEmpty
              ? Center(child: Text("No ride requests received."))
              : ListView.builder(
                  itemCount: rideRequests.length,
                  itemBuilder: (context, index) {
                    return RideRequestCard(
                      request: rideRequests[index],
                      onUpdateStatus: _updateRequestStatus,
                    );
                  },
                ),
    );
  }
}

class RideRequestCard extends StatelessWidget {
  final Map<String, String> request;
  final Function(String, String) onUpdateStatus;

  RideRequestCard({required this.request, required this.onUpdateStatus});

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
            Text("From: ${request["from"]}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("To: ${request["to"]}"),
            SizedBox(height: 5),
            Text("Date: ${request["date"]}", style: TextStyle(color: Colors.grey[700])),
            Text("Time: ${request["time"]}", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("Status: ${request["status"]}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => onUpdateStatus(request["requestId"]!, "accepted"),
                  child: Text("Accept"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () => onUpdateStatus(request["requestId"]!, "rejected"),
                  child: Text("Reject"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: request["userId"]!,
                          receiverName: "User ${request["userId"]!}", // Replace with actual name from Firestore
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
