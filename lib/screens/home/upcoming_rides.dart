import 'package:flutter/material.dart';

class UpcomingRidesScreen extends StatefulWidget {
  @override
  _UpcomingRidesScreenState createState() => _UpcomingRidesScreenState();
}

class _UpcomingRidesScreenState extends State<UpcomingRidesScreen> {
  bool isLoading = false; // Simulating data fetching
  List<Map<String, String>> upcomingRides = [
    {
      "from": "Downtown",
      "to": "Airport",
      "date": "March 5, 2025",
      "time": "10:30 AM"
    },
    {
      "from": "City Center",
      "to": "University",
      "date": "March 7, 2025",
      "time": "8:00 AM"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loader if data is loading
        : upcomingRides.isEmpty
            ? Center(child: Text("No upcoming rides available."))
            : ListView.builder(
                itemCount: upcomingRides.length,
                itemBuilder: (context, index) {
                  return RideCard(
                    from: upcomingRides[index]["from"]!,
                    to: upcomingRides[index]["to"]!,
                    date: upcomingRides[index]["date"]!,
                    time: upcomingRides[index]["time"]!,
                  );
                },
              );
  }
}

class RideCard extends StatelessWidget {
  final String from, to, date, time;

  const RideCard({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
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
          ],
        ),
      ),
    );
  }
}
