import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = Locale('en');
  String _selectedCurrency = 'USD'; // Default currency

  Locale get currentLocale => _currentLocale;
  String get selectedCurrency => _selectedCurrency;

  LanguageProvider() {
    _loadSavedPreferences();
  }

  void _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code');
    final savedCurrency = prefs.getString('currency_code');

    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    }

    if (savedCurrency != null) {
      _selectedCurrency = savedCurrency;
    }

    notifyListeners();
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (_currentLocale == newLocale) return;

    _currentLocale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    notifyListeners();
  }

  Future<void> changeCurrency(String newCurrency) async {
    if (_selectedCurrency == newCurrency) return;

    _selectedCurrency = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', newCurrency);
    notifyListeners();
  }
}