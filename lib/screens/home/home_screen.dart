import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/screens/home/my_offers.dart';
import 'package:kctrustedcarpool/screens/home/upcoming_rides.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kctrustedcarpool/screens/login/login.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    UpcomingRidesScreen(),
    MyOffersScreen(),
    Center(child: Text("Chat Feature (Coming Soon)")), // Placeholder
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KCTrustedCarpool"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Rides"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Offers"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}
