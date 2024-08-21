import 'package:flutter/material.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:pennywise/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return HomeScreen();
    } else {
      return AuthSelectionScreen();
    }
  }
}

class AuthSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Iniciar sesión'),
              onPressed: () {
                context.go('/auth/login');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Registrarse'),
              onPressed: () {
                context.go('/auth/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}
