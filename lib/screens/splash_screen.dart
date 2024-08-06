import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Simulate a delay for the splash screen (you can remove this in production)
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return; // Check if the widget is still in the tree

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return; // Check again before using context

      if (user == null) {
        context.go('/login'); // Use go_router to navigate to the login screen
      } else {
        context.go('/home'); // Use go_router to navigate to the home screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
