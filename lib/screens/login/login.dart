import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../../cloud_functions/firebase_function.dart';
import '../../providers/user_state.dart';
import '../root.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _handleLogin(BuildContext context, String email, String password) async {
    try {
      final user = await FirebaseFunctions.fetchUserByEmail(email);
      if (user != null) {
        Provider.of<UserState>(context, listen: false).setCurrentUser(user);
        return null; // Success
      } else {
        return "User not found";
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'KCTrustedCarpool',
      onLogin: (loginData) => _handleLogin(context, loginData.name, loginData.password),
      onSignup: (_) async => "Signup not implemented",
      onRecoverPassword: (_) async => "Recover password not implemented",
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
      },
    );
  }
}
