import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import '../../cloud_functions/firebase_function.dart';
import '../../cloud_functions/firestore_service.dart';
import '../../providers/user_state.dart';
import '../home/home_screen.dart';
import '../root.dart';


class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  Duration get loginTime => const Duration(milliseconds: 1000);

  /// Handles login by fetching user details
  Future<String?> _handleLogin(BuildContext context, String email, String password) async {
    try {
      final user = await FirebaseFunctions.loginUser(email, password); // Now checks email & password
      if (user != null) {
        Provider.of<UserState>(context, listen: false).setCurrentUser(user);
        return null; // Login successful
      } else {
        return "Invalid email or password";
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Handles user signup and creates a new user in Firebase
  Future<String?> _handleSignup(BuildContext context, String email, String password) async {
    try {
      final newUser = await FirebaseFunctions.signUpUser(email, password);
      if (newUser != null) {
        Provider.of<UserState>(context, listen: false).setCurrentUser(newUser);
        return null; // Signup successful
      } else {
        return "Signup failed. Try again.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'KCTrustedCarpool',
      savedEmail: "testuser@example.com", // TODO: Remove this line
      savedPassword: "Test@123", // TODO: Remove this line
      onLogin: (loginData) => _handleLogin(context, loginData.name, loginData.password),
      onSignup: (signupData) => _handleSignup(
        context, 
        signupData.name ?? "",  // Ensure a non-null value for email
        signupData.password ?? "" // Ensure a non-null value for password
      ),
      onRecoverPassword: (_) async => "Recover password not implemented",
      onSubmitAnimationCompleted: () {
        FirestoreService().saveUserFCMToken(); // ✅ Store FCM token
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      },
    );
  }
}
