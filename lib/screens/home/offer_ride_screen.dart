import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';

class OfferRideScreen extends StatefulWidget {
  @override
  _OfferRideScreenState createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  FirestoreService firestoreService = FirestoreService();

  void _submitOffer() {
    if (_formKey.currentState!.validate()) {
      firestoreService.offerRide(
        _fromController.text,
        _toController.text,
        _dateController.text,
        _timeController.text,
        _seatsController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ride offer added!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offer a Ride")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fromController,
                decoration: InputDecoration(labelText: "From"),
                validator: (value) => value!.isEmpty ? "Enter departure location" : null,
              ),
              TextFormField(
                controller: _toController,
                decoration: InputDecoration(labelText: "To"),
                validator: (value) => value!.isEmpty ? "Enter destination" : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: "Date"),
                validator: (value) => value!.isEmpty ? "Enter date" : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: "Time"),
                validator: (value) => value!.isEmpty ? "Enter time" : null,
              ),
              TextFormField(
                controller: _seatsController,
                decoration: InputDecoration(labelText: "Seats Available"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter available seats" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOffer,
                child: Text("Submit Offer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
