import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login/login.dart';
import 'screens/root.dart';
import 'screens/onboarding_screen.dart';
import 'providers/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
        title: 'KCTrustedCarpool',
        initialRoute: OnboardingScreen.routeName, // Start with Onboarding
        routes: {
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
          RootScreen.routeName: (context) => RootScreen(),
        },
      ),
    );
  }
}
