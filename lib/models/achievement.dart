// lib/models/achievement.dart
import 'package:flutter/material.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/models/drink_trigger.dart';

enum SportPeriod {
  last30Days,
  last60Days,
  last90Days,
  last180Days,
  last365Days;

  int get daysCount {
    switch (this) {
      case SportPeriod.last30Days:
        return 30;
      case SportPeriod.last60Days:
        return 60;
      case SportPeriod.last90Days:
        return 90;
      case SportPeriod.last180Days:
        return 180;
      case SportPeriod.last365Days:
        return 365;
    }
  }

  String toJson() => name;
  static SportPeriod fromJson(String name) =>
      SportPeriod.values.firstWhere((e) => e.name == name);
}

enum UniqueEvent {
  soberNewYear,
  sportNewYear;

  String toJson() => name;
  static UniqueEvent fromJson(String name) =>
      UniqueEvent.values.firstWhere((e) => e.name == name);
}

enum AchievementType {
  soberStreak,
  drinkingStreak,
  sportCount,
  uniqueEvent,
  milestone,
  soberDaysInYear,
  drinkingDaysInYear,
  drinkingLevelDaysInYear, // дни года с конкретным уровнем алкоголя (little/medium/heavy)
  soberMonth,
  leftReview,
  noHangoverStreak,
  triggerCountInYear, // N повторений тега-триггера за календарный год
}

class Achievement {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final AchievementType type;
  final int requiredValue;       // для soberStreak/drinkingStreak – дни, для sportCount – количество
  final SportPeriod? period;      // для sportCount
  final UniqueEvent? event;       // для uniqueEvent
  final DrinkLevel? drinkLevel;    // для drinkingLevelDaysInYear
  final DrinkTrigger? trigger;     // для triggerCountInYear
  bool isUnlocked;
  DateTime? unlockDate;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.type,
    required this.requiredValue,
    this.period,
    this.event,
    this.drinkLevel,
    this.trigger,
    this.isUnlocked = false,
    this.unlockDate,
  });

  // Сериализация
  Map<String, dynamic> toJson() => {
    'id': id,
    'titleKey': titleKey,
    'descriptionKey': descriptionKey,
    'type': type.name,
    'requiredValue': requiredValue,
    'period': period?.toJson(),
    'event': event?.toJson(),
    'drinkLevel': drinkLevel?.name,
    'trigger': trigger?.rawValue,
    'isUnlocked': isUnlocked,
    'unlockDate': unlockDate?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    titleKey: json['titleKey'],
    descriptionKey: json['descriptionKey'],
    type: AchievementType.values.firstWhere((e) => e.name == json['type']),
    requiredValue: json['requiredValue'],
    period: json['period'] != null ? SportPeriod.fromJson(json['period']) : null,
    event: json['event'] != null ? UniqueEvent.fromJson(json['event']) : null,
    drinkLevel: json['drinkLevel'] != null
        ? DrinkLevel.values.firstWhere((e) => e.name == json['drinkLevel'])
        : null,
    trigger: json['trigger'] != null ? DrinkTrigger.fromRawValue(json['trigger']) : null,
    isUnlocked: json['isUnlocked'] ?? false,
    unlockDate: json['unlockDate'] != null ? DateTime.parse(json['unlockDate']) : null,
  );

  // Вспомогательное название и описание (будут использоваться с AppLocalizations)
  String getLocalizedTitle(AppLocalizations loc) => loc.translate(titleKey);
  String getLocalizedDescription(AppLocalizations loc) => loc.translate(descriptionKey);

  // Имя изображения (ассет) – можно вычислить по id или хранить отдельно
  String get imageAsset => 'assets/achievements/$id.png';
}