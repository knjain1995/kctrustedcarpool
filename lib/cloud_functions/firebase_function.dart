import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
}
