import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF212121),
  accentColor: Colors.white,
  bottomAppBarColor: Colors.grey,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.white54,
);

final lightTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFE5E5E5),
  accentColor: Colors.black,
  bottomAppBarColor: Colors.grey,
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.black12,
  // Bottom Navigation Bar
  canvasColor: Color(0xFFb9bfbe),
);
