import 'dart:convert';
import 'package:flutter/services.dart';

class L10n {
  static Map<String, String> _localizedStrings = {};
  static String _currentLocale = 'en';
  static String _currentCurrency = 'USD';

  static Future<void> load(String locale) async {
    _currentLocale = locale;
    String jsonString = await rootBundle.loadString('assets/lang/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static String get currentLocale => _currentLocale;
  
  static String get currentCurrency => _currentCurrency;

  static void setCurrency(String currencyCode) {
    _currentCurrency = currencyCode;
  }

  static String formatCurrency(double amount) {
    // This is a basic implementation. You might want to use a more robust
    // solution like the intl package for proper currency formatting.
    return '$_currentCurrency ${amount.toStringAsFixed(2)}';
  }
}