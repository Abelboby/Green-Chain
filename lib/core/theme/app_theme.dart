import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryGreen = Color(0xFF81C784);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryGreen),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGreen,
      background: darkBackgroundColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: primaryGreen),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
} 