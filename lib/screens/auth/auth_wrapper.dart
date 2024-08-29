import 'package:flutter/material.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:pennywise/screens/auth/login_screen.dart';
import 'package:pennywise/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}

