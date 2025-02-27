import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Handles user login by verifying both email & password
  static Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserModel(
          uid: userCredential.user!.uid,
          name: userCredential.user!.email!.split('@')[0], // Temporary name
          email: email,
        );
      }
    } catch (e) {
      print("🔥 Login Error: $e");
      return null; // Login failed (wrong password or user doesn't exist)
    }
    return null;
  }

  /// Handles user signup
  static Future<UserModel?> signUpUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserModel(
          uid: userCredential.user!.uid,
          name: email.split('@')[0], // Extract name from email
          email: email,
        );
      }
    } catch (e) {
      print("🔥 Signup Error: $e");
    }
    return null;
  }
}
