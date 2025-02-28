import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kctrustedcarpool/cloud_functions/firestore_service.dart';
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
  
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Notifications Permission Granted');
  } else {
    print('❌ Notifications Permission Denied');
  }


  // // MANUALLY TEST NOTIFICATIONS
  // // Replace this token with your actual FCM token from Firestore
  // String testFCMToken = "ferwpvQoRguL2_r6aqFXtE:APA91bH0u_fBtBe-13Gi_RJa73SSHrV2Vo-meHO5vZH2cKQEROOeykKwvelwId7qqNGe9rvBzGgZkcyelJvLRWXNG_x7dtjU6oRwcwLfuMaJ7qnZ0POOQKA";
  // // Call sendNotification() manually to test FCM
  // FirestoreService().sendNotification(testFCMToken, "Test Notification", "This is a test message from FCM v1 API.");

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
