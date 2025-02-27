import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kctrustedcarpool/firebase_options.dart';
import 'package:provider/provider.dart';
import 'screens/login/login.dart';
import 'screens/root.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
        title: 'KCTrustedCarpool',
        initialRoute: OnboardingScreen.routeName, // Start with onboarding
        routes: {
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
          HomeScreen.routeName: (context) => HomeScreen(), // Register HomeScreen
          RootScreen.routeName: (context) => RootScreen(),
        },
      ),
    );
  }
}
