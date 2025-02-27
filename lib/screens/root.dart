import 'package:flutter/material.dart';

class RootScreen extends StatelessWidget {
  static const routeName = '/root';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome to KCTrustedCarpool")),
      body: Center(child: Text("This is the main app screen after login!")),
    );
  }
}
