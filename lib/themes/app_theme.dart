import 'package:flutter/material.dart';

class AppTheme {
  // Colores del logo
  static const Color antiqueWhite = Color(0xFFFCEFE0);
  static const Color richBlack = Color(0xFF02212F);
  static const Color raisinBlack = Color(0xFF3F333E);
  static const Color folly = Color(0xFFF7485E);
  static const Color linen = Color(0xFFFCEFE2);

  // Nuevos colores para mejorar la paleta
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color warningYellow = Color(0xFFF1C40F);

  // Otras configuraciones
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFF7485E,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFF7485E),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.light,
    scaffoldBackgroundColor: linen,
    appBarTheme: AppBarTheme(
      color: folly,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: antiqueWhite,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: folly,
      unselectedLabelColor: Colors.grey[600],
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: folly, width: 2),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: folly,
      secondary: accentBlue,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: raisinBlack,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: IconThemeData(color: raisinBlack),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: richBlack, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: TextStyle(color: richBlack, fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(color: raisinBlack, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: raisinBlack, fontSize: 16),
      bodyMedium: TextStyle(color: raisinBlack, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: folly, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: antiqueWhite.withOpacity(0.5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: folly,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: folly,
        side: BorderSide(color: folly),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentBlue,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: antiqueWhite,
      disabledColor: Colors.grey[300],
      selectedColor: folly,
      secondarySelectedColor: accentBlue,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(color: raisinBlack),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.light,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: richBlack,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: folly,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: primarySwatch,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: richBlack,
    appBarTheme: AppBarTheme(
      color: raisinBlack,
      elevation: 0,
      iconTheme: IconThemeData(color: antiqueWhite),
      titleTextStyle: TextStyle(color: antiqueWhite, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF1A1A1A),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: folly,
      unselectedLabelColor: Colors.grey[400],
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: folly, width: 2),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: folly,
      secondary: accentBlue,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Color(0xFF2C2C2C),
      onSurface: antiqueWhite,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: IconThemeData(color: antiqueWhite),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: antiqueWhite, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: TextStyle(color: antiqueWhite, fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: folly, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Color(0xFF333333),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: folly,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: folly,
        side: BorderSide(color: folly),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentBlue,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF333333),
      disabledColor: Colors.grey[800],
      selectedColor: folly,
      secondarySelectedColor: accentBlue,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(color: antiqueWhite),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF333333),
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: folly,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    ),
  );
}