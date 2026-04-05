import 'drink_level.dart';

class DayRecord {
  final DrinkLevel drinkLevel;
  final bool hasSport;

  DayRecord({
    this.drinkLevel = DrinkLevel.none,
    this.hasSport = false,
  });

  factory DayRecord.fromLegacy(int legacyValue) {
    if (legacyValue == 5) {
      return DayRecord(drinkLevel: DrinkLevel.little, hasSport: true);
    } else if (legacyValue == 6) {
      return DayRecord(drinkLevel: DrinkLevel.medium, hasSport: true);
    } else if (legacyValue == 7) {
      return DayRecord(drinkLevel: DrinkLevel.heavy, hasSport: true);
    } else if (legacyValue == 4) {
      return DayRecord(drinkLevel: DrinkLevel.none, hasSport: true);
    } else {
      return DayRecord(drinkLevel: DrinkLevel.fromLegacy(legacyValue));
    }
  }

  int get toLegacy {
    if (drinkLevel == DrinkLevel.little && hasSport) {
      return 5; // little_sport
    } else if (drinkLevel == DrinkLevel.medium && hasSport) {
      return 6;
    } else if (drinkLevel == DrinkLevel.heavy && hasSport) {
      return 7;
    } else if (hasSport) {
      return 4; // sport
    } else {
      return drinkLevel.toLegacy;
    }
  }

  DayRecord copyWith({
    DrinkLevel? drinkLevel,
    bool? hasSport,
  }) {
    return DayRecord(
      drinkLevel: drinkLevel ?? this.drinkLevel,
      hasSport: hasSport ?? this.hasSport,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DayRecord &&
              runtimeType == other.runtimeType &&
              drinkLevel == other.drinkLevel &&
              hasSport == other.hasSport;

  @override
  int get hashCode => drinkLevel.hashCode ^ hasSport.hashCode;
}