import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _user;

  UserModel? get user => _user;

  /// Sets the current user after login
  void setCurrentUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = UserModel(uid: userCredential.user!.uid, name: "Test User", email: email);
      notifyListeners();
    } catch (e) {
      print("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
