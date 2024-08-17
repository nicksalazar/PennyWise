import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _authRepository.getCurrentUser().then((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  //Fetch Userdata
  Future<void> fetchUser() async {
    _user = await _authRepository.getCurrentUser();
    notifyListeners();
  }
}
