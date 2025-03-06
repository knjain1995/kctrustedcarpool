import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(request["userId"]).get(),
      builder: (context, userSnapshot) {
        String profileUrl = "";
        String userName = "User ${request["userId"]!}";

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          profileUrl = userSnapshot.data!["profileUrl"] ?? "";
          userName = userSnapshot.data!["name"] ?? userName;
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                      child: profileUrl.isEmpty ? Icon(Icons.person, size: 30) : null,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(request["email"] ?? "No Email", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
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
                  ],
                ),
                _buildChatButton(request),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatButton(Map<String, String> request) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (!chatSnapshot.hasData) return IconButton(icon: Icon(Icons.chat), onPressed: () {});

        String? chatId;
        for (var chat in chatSnapshot.data!.docs) {
          List<dynamic> users = chat['users'];
          if (users.contains(request["userId"])) {
            chatId = chat.id;
            break;
          }
        }

        if (chatId == null) return IconButton(icon: Icon(Icons.chat), onPressed: () {});

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .where('isRead', isEqualTo: false)
              .snapshots(),
          builder: (context, messageSnapshot) {
            int unreadCount = messageSnapshot.hasData ? messageSnapshot.data!.docs.length : 0;

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.chat),
                  tooltip: "Chat with Requester",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: request["userId"]!,
                          receiverName: request["userName"] ?? "User ${request["userId"]!}",
                          receiverProfileUrl: request["userProfileUrl"] ?? "",
                        ),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 10,
                      child: Text(
                        "$unreadCount",
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}


// class RideRequestCard extends StatelessWidget {
//   final Map<String, String> request;
//   final Function(String, String) onUpdateStatus;

//   RideRequestCard({required this.request, required this.onUpdateStatus});

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
//             Text("From: ${request["from"]}", style: TextStyle(fontWeight: FontWeight.bold)),
//             Text("To: ${request["to"]}"),
//             SizedBox(height: 5),
//             Text("Date: ${request["date"]}", style: TextStyle(color: Colors.grey[700])),
//             Text("Time: ${request["time"]}", style: TextStyle(color: Colors.grey[700])),
//             SizedBox(height: 10),
//             Text("Status: ${request["status"]}", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => onUpdateStatus(request["requestId"]!, "accepted"),
//                   child: Text("Accept"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => onUpdateStatus(request["requestId"]!, "rejected"),
//                   child: Text("Reject"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//                 StreamBuilder<QuerySnapshot>(
//   stream: FirebaseFirestore.instance
//       .collection('chats')
//       .where('users', arrayContains: FirebaseAuth.instance.currentUser?.uid)
//       .snapshots(),
//   builder: (context, chatSnapshot) {
//     if (!chatSnapshot.hasData) return IconButton(icon: Icon(Icons.chat), onPressed: () {});

//     String? chatId;
//     for (var chat in chatSnapshot.data!.docs) {
//       List<dynamic> users = chat['users'];
//       if (users.contains(request["userId"])) {
//         chatId = chat.id; // Found chat between these two users
//         break;
//       }
//     }

//     if (chatId == null) return IconButton(icon: Icon(Icons.chat), onPressed: () {});

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//           .where('isRead', isEqualTo: false)
//           .snapshots(),
//       builder: (context, messageSnapshot) {
//         int unreadCount = messageSnapshot.hasData ? messageSnapshot.data!.docs.length : 0;

//         return Stack(
//           children: [
//             IconButton(
//               icon: Icon(Icons.chat),
//               tooltip: "Chat with Requester",
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatScreen(
//                       receiverId: request["userId"]!,
//                       receiverName: request["userName"] ?? "User ${request["userId"]!}", // ✅ Pass actual name if available
//                       receiverProfileUrl: request["userProfileUrl"] ?? "", // ✅ Pass profile URL or empty string
//                     ),
//                   ),
//                 );
//               },
//             ),
//             if (unreadCount > 0)
//               Positioned(
//                 right: 0,
//                 child: CircleAvatar(
//                   backgroundColor: Colors.red,
//                   radius: 10,
//                   child: Text(
//                     "$unreadCount",
//                     style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   },
// ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }