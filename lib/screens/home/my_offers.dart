import 'package:flutter/material.dart';

class MyOffersScreen extends StatefulWidget {
  @override
  _MyOffersScreenState createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  bool isLoading = false; // Simulating data fetching
  List<Map<String, String>> myOffers = [
    {
      "from": "Suburbs",
      "to": "Downtown",
      "date": "March 10, 2025",
      "time": "7:30 AM",
      "seats": "2"
    },
    {
      "from": "Train Station",
      "to": "Mall",
      "date": "March 12, 2025",
      "time": "9:00 AM",
      "seats": "3"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loader if data is loading
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
