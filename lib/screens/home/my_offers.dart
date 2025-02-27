import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';
import 'package:kctrustedcarpool/screens/home/offer_ride_screen.dart';
import 'package:kctrustedcarpool/screens/home/ride_management_screen.dart';

class MyOffersScreen extends StatefulWidget {
  @override
  _MyOffersScreenState createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  bool isLoading = true;
  List<Map<String, String>> myOffers = [];
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    print("📢 Fetching ride offers from Firestore...");

    List<Map<String, String>> offers = await firestoreService.fetchRideOffers();

    print("📢 Offers received: $offers");

    setState(() {
      myOffers = offers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Offers")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : myOffers.isEmpty
              ? Center(child: Text("You haven't offered any rides yet."))
              : ListView.builder(
                  itemCount: myOffers.length,
                  itemBuilder: (context, index) {
                    return OfferCard(
                      from: myOffers[index]["from"]!,
                      to: myOffers[index]["to"]!,
                      date: myOffers[index]["date"]!,
                      time: myOffers[index]["time"]!,
                      seats: myOffers[index]["seats"]!,
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfferRideScreen()),
              ).then((_) => fetchOffers()); // Refresh after adding an offer
            },
            label: Text("Offer Ride"),
            icon: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RideManagementScreen()),
              );
            },
            label: Text("Manage Requests"),
            icon: Icon(Icons.manage_accounts),
            backgroundColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}



class OfferCard extends StatelessWidget {
  final String from, to, date, time, seats;

  const OfferCard({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.seats,
  });

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
            Text("From: $from", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("To: $to"),
            SizedBox(height: 5),
            Text("Date: $date", style: TextStyle(color: Colors.grey[700])),
            Text("Time: $time", style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 5),
            Text("Seats Available: $seats", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
