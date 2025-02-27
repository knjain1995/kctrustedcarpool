import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches user by email
  static Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email == email) {
        return UserModel(uid: user.uid, name: "Test User", email: email);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  /// Signs up a new user
  static Future<UserModel?> signUpUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserModel(
          uid: userCredential.user!.uid,
          name: email.split('@')[0], // Use part of email as name
          email: email,
        );
      }
    } catch (e) {
      print("🔥 Firebase Signup Error: $e"); // Prints detailed error
    }
    return null;
  }
}
