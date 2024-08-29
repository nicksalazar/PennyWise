import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Espera a que se complete la autenticación
    await Future.delayed(Duration(seconds: 2));

    // Verifica el estado del usuario
    final user = authProvider.user;
    if (user == null) {
      context.go('/auth/login');
    } else {
      context.go('/home'); // Ajusta según la ruta de tu pantalla principal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_icon',
              child: ClipOval(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  height: 120,
                ),
              ),
            ),
            Text(
              'PennyWise',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
