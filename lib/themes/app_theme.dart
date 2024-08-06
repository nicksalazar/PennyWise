import 'package:flutter/material.dart';

class AppTheme {
  static const int _greenPrimaryValue = 0xFF4CAF50;
  static const MaterialColor primarySwatch = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(_greenPrimaryValue),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      color: primarySwatch,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      toolbarTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
    ),
    colorScheme: ColorScheme.light(
      primary: primarySwatch,
      secondary: Colors.amberAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primarySwatch),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      toolbarTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
    ),
    colorScheme: ColorScheme.dark(
      primary: primarySwatch[300]!,
      secondary: Colors.amberAccent[200]!,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    iconTheme: IconThemeData(color: Colors.grey[400]),
    textTheme: TextTheme(
      headlineMedium:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primarySwatch[300]!),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
    ),
  );
}
