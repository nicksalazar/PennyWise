import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pennywise/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  User? _user;
  Map<String, String> _userInfo = {'name': 'Usuario', 'email': 'No email'};
  bool _isLoading = true;

  User? get user => _user;
  Map<String, String> get userInfo => _userInfo;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await _authRepository.getCurrentUser();
    if (_user != null) {
      await fetchUserInfo();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
      await _initializeUser();
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _user = null;
      _userInfo = {'name': 'Usuario', 'email': 'No email'};
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> fetchUserInfo() async {
    if (_user != null) {
      _userInfo = await _authRepository.getUserInfo();
      notifyListeners();
    }
  }
}