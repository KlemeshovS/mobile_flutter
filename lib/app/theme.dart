import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color secondaryColor = Color(0xFF6366F1);
  static const Color sportColor = Color(0xFFC7FF00);
  static const Color littleColor = Color(0xFFFF0072);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color cardColor = Color(0xFF1F2937);
  static const Color darkRed = Color(0xFF800000);
  static const Color gradientDarkPurple = Color(0xFF2A1E5C);
  static const Color gradientLightPurple = Color(0xFF4B3A91);

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Inter',
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Inter',
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        color: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static LinearGradient get mainGradient => LinearGradient(
    colors: [
      Color(0xFF000000),
      Color(0xFF4B3A91),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: [
      Color(0xFF2D2B55).withOpacity(0.9),
      Color(0xFF3E3B6B).withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}