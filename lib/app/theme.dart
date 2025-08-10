import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const black = Colors.black;
  const white = Colors.white;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: black,
    brightness: Brightness.light,
    primary: black,
    onPrimary: white,
    surface: white,
    onSurface: black,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme().apply(
      bodyColor: black,
      displayColor: black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        disabledBackgroundColor: Colors.black38,
        disabledForegroundColor: Colors.white70,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
