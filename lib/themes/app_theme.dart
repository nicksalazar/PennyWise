import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.deepPurple,
    backgroundColor: AppColors.primaryVariant,
    accentColor: AppColors.secondary,
    errorColor: AppColors.error,
  ),
  textTheme: TextTheme(
    bodySmall: TextStyle(fontSize: 12.0, color: AppColors.onBackground),
    bodyLarge: TextStyle(fontSize: 22.0, color: AppColors.onBackground),
    bodyMedium: TextStyle(fontSize: 16.0, color: AppColors.onBackground),
  ),
);
// final ThemeData appTheme = ThemeData(
//   primarySwatch: Colors.deepPurple,
//   primaryColor: AppColors.primary,
//   accentColor: AppColors.secondary,
//   backgroundColor: AppColors.background,
//   errorColor: AppColors.error,
//   textTheme: TextTheme(
// 	bodyText1: TextStyle(color: AppColors.onBackground),
// 	bodyText2: TextStyle(color: AppColors.onBackground),
//   ),
// );