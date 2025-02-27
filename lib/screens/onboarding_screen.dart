import 'package:flutter/material.dart';
import 'package:kctrustedcarpool/screens/login/login.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Welcome to KCTrustedCarpool",
      "description": "Find trusted carpool rides with ease!"
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Safe & Verified Rides",
      "description": "We ensure security by verifying every user."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Let's Get Started!",
      "description": "Sign up or log in to start your journey."
    }
  ];

  void nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(onboardingData[currentIndex]["image"]!, fit: BoxFit.cover),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    onboardingData[currentIndex]["title"]!,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    onboardingData[currentIndex]["description"]!,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: nextPage,
            child: Text(currentIndex < onboardingData.length - 1 ? "Next" : "Get Started"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
