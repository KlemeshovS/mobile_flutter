// lib/models/drink_level.dart
import 'package:flutter/material.dart';

enum DrinkLevel {
  unknown(-1),
  none(0),
  little(1),
  medium(2),
  heavy(3),
  sport(4),
  little_sport(5),
  medium_sport(6),
  heavy_sport(7);

  final int value;
  const DrinkLevel(this.value);

  @override
  String toString() => name;

  static DrinkLevel fromValue(int value) {
    return DrinkLevel.values.firstWhere(
          (e) => e.value == value,
      orElse: () => DrinkLevel.unknown,
    );
  }

  String get localizedTitle {
    switch (this) {
      case DrinkLevel.unknown:
        return 'unknown'; // ДОБАВИЛИ эту строку
      case DrinkLevel.none:
        return 'none';
      case DrinkLevel.little:
        return 'little';
      case DrinkLevel.medium:
        return 'medium';
      case DrinkLevel.heavy:
        return 'heavy';
      case DrinkLevel.sport:
        return 'sport';
      case DrinkLevel.little_sport:
        return 'little_sport';
      case DrinkLevel.medium_sport:
        return 'medium_sport';
      case DrinkLevel.heavy_sport:
        return 'heavy_sport';
    }
  }

  Color get color {
    switch (this) {
      case DrinkLevel.unknown:
        return Colors.transparent;
      case DrinkLevel.none:
        return Colors.transparent;
      case DrinkLevel.little:
        return Color(0xFFFF0072).withOpacity(0.3);
      case DrinkLevel.medium:
        return Color(0xFF9126EF).withOpacity(0.4);
      case DrinkLevel.heavy:
        return Color(0xFF482FED).withOpacity(0.6);
      case DrinkLevel.sport:
        return Color(0xFFC7FF00).withOpacity(0.4);
      case DrinkLevel.little_sport:
        return Color(0xFFFF0072).withOpacity(0.3);
      case DrinkLevel.medium_sport:
        return Color(0xFF9126EF).withOpacity(0.4);
      case DrinkLevel.heavy_sport:
        return Color(0xFF482FED).withOpacity(0.6);
    }
  }

  static DrinkLevel fromLegacy(int legacyValue) {
    switch (legacyValue) {
      case -1:
        return DrinkLevel.unknown;
      case 0:
        return DrinkLevel.none;
      case 1:
        return DrinkLevel.little;
      case 2:
        return DrinkLevel.medium;
      case 3:
        return DrinkLevel.heavy;
      case 4:
        return DrinkLevel.sport;
      case 5:
        return DrinkLevel.little_sport;
      case 6:
        return DrinkLevel.medium_sport;
      case 7:
        return DrinkLevel.heavy_sport;
      default:
        return DrinkLevel.unknown;
    }
  }

  int get toLegacy {
    return value;
  }
}