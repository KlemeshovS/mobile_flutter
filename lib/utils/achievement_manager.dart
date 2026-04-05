// lib/utils/achievement_manager.dart
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';

class AchievementManager {
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  static const String _storageKey = 'achievements';

  // Все доступные ачивки
  List<Achievement> _allAchievements = [
    Achievement(
      id: 'drink_3',
      titleKey: 'ach_drink_3_title',
      descriptionKey: 'ach_drink_3_desc',
      type: AchievementType.drinkingStreak,
      requiredValue: 3,
    ),
    Achievement(
      id: 'drink_7',
      titleKey: 'ach_drink_7_title',
      descriptionKey: 'ach_drink_7_desc',
      type: AchievementType.drinkingStreak,
      requiredValue: 7,
    ),
    Achievement(
      id: 'drink_14',
      titleKey: 'ach_drink_14_title',
      descriptionKey: 'ach_drink_14_desc',
      type: AchievementType.drinkingStreak,
      requiredValue: 14,
    ),
    Achievement(
      id: 'drink_30',
      titleKey: 'ach_drink_30_title',
      descriptionKey: 'ach_drink_30_desc',
      type: AchievementType.drinkingStreak,
      requiredValue: 30,
    ),
    Achievement(
      id: 'sober_7',
      titleKey: 'ach_sober_7_title',
      descriptionKey: 'ach_sober_7_desc',
      type: AchievementType.soberStreak,
      requiredValue: 7,
    ),
    Achievement(
      id: 'sober_14',
      titleKey: 'ach_sober_14_title',
      descriptionKey: 'ach_sober_14_desc',
      type: AchievementType.soberStreak,
      requiredValue: 14,
    ),
    Achievement(
      id: 'sober_21',
      titleKey: 'ach_sober_21_title',
      descriptionKey: 'ach_sober_21_desc',
      type: AchievementType.soberStreak,
      requiredValue: 21,
    ),
    Achievement(
      id: 'sober_30',
      titleKey: 'ach_sober_30_title',
      descriptionKey: 'ach_sober_30_desc',
      type: AchievementType.soberStreak,
      requiredValue: 30,
    ),
    Achievement(
      id: 'sober_60',
      titleKey: 'ach_sober_60_title',
      descriptionKey: 'ach_sober_60_desc',
      type: AchievementType.soberStreak,
      requiredValue: 60,
    ),
    Achievement(
      id: 'sober_90',
      titleKey: 'ach_sober_90_title',
      descriptionKey: 'ach_sober_90_desc',
      type: AchievementType.soberStreak,
      requiredValue: 90,
    ),
    Achievement(
      id: 'sober_180',
      titleKey: 'ach_sober_180_title',
      descriptionKey: 'ach_sober_180_desc',
      type: AchievementType.soberStreak,
      requiredValue: 180,
    ),
    Achievement(
      id: 'sober_365',
      titleKey: 'ach_sober_365_title',
      descriptionKey: 'ach_sober_365_desc',
      type: AchievementType.soberStreak,
      requiredValue: 365,
    ),
    // Спортивные ачивки
    Achievement(
      id: 'sport_8_month',
      titleKey: 'ach_sport_8_title',
      descriptionKey: 'ach_sport_8_desc',
      type: AchievementType.sportCount,
      requiredValue: 8,
      period: SportPeriod.last30Days,
    ),
    Achievement(
      id: 'sport_12_month',
      titleKey: 'ach_sport_12_title',
      descriptionKey: 'ach_sport_12_desc',
      type: AchievementType.sportCount,
      requiredValue: 12,
      period: SportPeriod.last30Days,
    ),
    Achievement(
      id: 'sport_50_half_year',
      titleKey: 'ach_sport_50_title',
      descriptionKey: 'ach_sport_50_desc',
      type: AchievementType.sportCount,
      requiredValue: 50,
      period: SportPeriod.last180Days,
    ),
    Achievement(
      id: 'sport_100_year',
      titleKey: 'ach_sport_100_title',
      descriptionKey: 'ach_sport_100_desc',
      type: AchievementType.sportCount,
      requiredValue: 100,
      period: SportPeriod.last365Days,
    ),
    // Milestone ачивки (высоты)
    Achievement(
      id: 'milestone_146',
      titleKey: 'ach_milestone_146_title',
      descriptionKey: 'ach_milestone_146_desc',
      type: AchievementType.milestone,
      requiredValue: 146,
    ),
    Achievement(
      id: 'milestone_319',
      titleKey: 'ach_milestone_319_title',
      descriptionKey: 'ach_milestone_319_desc',
      type: AchievementType.milestone,
      requiredValue: 319,
    ),
    Achievement(
      id: 'milestone_443',
      titleKey: 'ach_milestone_443_title',
      descriptionKey: 'ach_milestone_443_desc',
      type: AchievementType.milestone,
      requiredValue: 443,
    ),
    Achievement(
      id: 'milestone_1234',
      titleKey: 'ach_milestone_1234_title',
      descriptionKey: 'ach_milestone_1234_desc',
      type: AchievementType.milestone,
      requiredValue: 1234,
    ),
    Achievement(
      id: 'milestone_4810',
      titleKey: 'ach_milestone_4810_title',
      descriptionKey: 'ach_milestone_4810_desc',
      type: AchievementType.milestone,
      requiredValue: 4810,
    ),
    Achievement(
      id: 'milestone_5642',
      titleKey: 'ach_milestone_5642_title',
      descriptionKey: 'ach_milestone_5642_desc',
      type: AchievementType.milestone,
      requiredValue: 5642,
    ),
    Achievement(
      id: 'milestone_7010',
      titleKey: 'ach_milestone_7010_title',
      descriptionKey: 'ach_milestone_7010_desc',
      type: AchievementType.milestone,
      requiredValue: 7010,
    ),
    Achievement(
      id: 'milestone_8848',
      titleKey: 'ach_milestone_8848_title',
      descriptionKey: 'ach_milestone_8848_desc',
      type: AchievementType.milestone,
      requiredValue: 8848,
    ),
    Achievement(
      id: 'milestone_202_negative',
      titleKey: 'ach_milestone_202_negative_title',
      descriptionKey: 'ach_milestone_202_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 202,
    ),
    Achievement(
      id: 'milestone_1642_negative',
      titleKey: 'ach_milestone_1642_negative_title',
      descriptionKey: 'ach_milestone_1642_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 1642,
    ),
    Achievement(
      id: 'milestone_3800_negative',
      titleKey: 'ach_milestone_3800_negative_title',
      descriptionKey: 'ach_milestone_3800_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 3800,
    ),
    Achievement(
      id: 'milestone_6066_negative',
      titleKey: 'ach_milestone_6066_negative_title',
      descriptionKey: 'ach_milestone_6066_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 6066,
    ),
    Achievement(
      id: 'milestone_10047_negative',
      titleKey: 'ach_milestone_10047_negative_title',
      descriptionKey: 'ach_milestone_10047_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 10047,
    ),
    Achievement(
      id: 'milestone_11022_negative',
      titleKey: 'ach_milestone_11022_negative_title',
      descriptionKey: 'ach_milestone_11022_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 11022,
    ),
  ];

  // Текущее состояние (загружается из SharedPreferences)
  List<Achievement> _currentAchievements = [];

  // Инициализация – загружаем сохранённые статусы
  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _currentAchievements = jsonList.map((e) => Achievement.fromJson(e)).toList();
      } catch (e) {
        print('Error loading achievements: $e');
        _currentAchievements = [];
      }
    } else {
      _currentAchievements = [];
    }
    print('📊 Загружено ачивок: ${_currentAchievements.length}, из них разблокировано: ${_currentAchievements.where((a) => a.isUnlocked).length}');
    // Обновляем список _allAchievements, сохраняя unlocked статус из загруженных
    _mergeWithSaved();
  }

  void _mergeWithSaved() {
    for (var i = 0; i < _allAchievements.length; i++) {
      final saved = _currentAchievements.firstWhere(
            (a) => a.id == _allAchievements[i].id,
        orElse: () => _allAchievements[i],
      );
      _allAchievements[i].isUnlocked = saved.isUnlocked;
      _allAchievements[i].unlockDate = saved.unlockDate;
    }
    _currentAchievements = List.from(_allAchievements);
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_currentAchievements.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Проверить все ачивки на основе данных
  Future<List<Achievement>> checkAllAchievements(Map<String, DayRecord> daysData) async {
    print('🔍 checkAllAchievements: начало проверки');
    bool changed = false;

    for (int i = 0; i < _currentAchievements.length; i++) {
      final ach = _currentAchievements[i];
      if (!ach.isUnlocked) {
        final shouldUnlock = await _checkAchievement(ach, daysData);
        if (shouldUnlock) {
          print('🎉 Должна разблокироваться: ${ach.id}');
          _currentAchievements[i].isUnlocked = true;
          _currentAchievements[i].unlockDate = DateTime.now();
          changed = true;
          print('🎉 Ачивка разблокирована: ${ach.id}');
        } else {
          print('❌ Не разблокируется: ${ach.id}');
        }
      }
    }

    if (changed) {
      await _saveAchievements();
    }
    return List.unmodifiable(_currentAchievements);
  }

  // Проверка одной ачивки
  Future<bool> _checkAchievement(Achievement ach, Map<String, DayRecord> daysData) async {
    switch (ach.type) {
      case AchievementType.drinkingStreak:
        return _checkDrinkingStreak(ach.requiredValue, daysData);
      case AchievementType.soberStreak:
        return _checkSoberStreak(ach.requiredValue, daysData);
      case AchievementType.sportCount:
        return _checkSportAchievement(ach.period!, ach.requiredValue, daysData);
      case AchievementType.uniqueEvent:
      // TODO: реализовать позже
        return false;
      case AchievementType.milestone:
      // Milestone ачивки проверяются отдельно через checkMilestones
        return false;
    }
  }

  bool _checkMilestoneCondition(Achievement ach, int progressDays) {
    // negative milestone (id содержит 'negative')
    if (ach.id.contains('negative')) {
      // Требуется, чтобы прогресс был <= -requiredValue (достиг глубины)
      return progressDays <= -ach.requiredValue;
    } else {
      // Положительные вершины
      return progressDays >= ach.requiredValue;
    }
  }

  Future<List<Achievement>> updateAchievements(int progressDays, Map<String, DayRecord> daysData) async {
    print('🔄 updateAchievements: проверка всех ачивок');
    bool changed = false;
    for (int i = 0; i < _currentAchievements.length; i++) {
      final ach = _currentAchievements[i];
      if (ach.type == AchievementType.milestone) {
        // Для milestone: открываем, если достигнут порог, но никогда не закрываем
        final shouldUnlock = _checkMilestoneCondition(ach, progressDays);
        if (!ach.isUnlocked && shouldUnlock) {
          _currentAchievements[i].isUnlocked = true;
          _currentAchievements[i].unlockDate = DateTime.now();
          changed = true;
          print('🎉 Milestone разблокирована: ${ach.id}');
        }
      } else {
        // Для остальных типов: полная синхронизация
        final shouldUnlock = await _checkAchievement(ach, daysData);
        if (ach.isUnlocked != shouldUnlock) {
          _currentAchievements[i].isUnlocked = shouldUnlock;
          if (shouldUnlock) {
            _currentAchievements[i].unlockDate = DateTime.now();
            print('🎉 Ачивка разблокирована: ${ach.id}');
          } else {
            _currentAchievements[i].unlockDate = null;
            print('🔒 Ачивка заблокирована: ${ach.id}');
          }
          changed = true;
        }
      }
    }
    if (changed) {
      await _saveAchievements();
    }
    return List.unmodifiable(_currentAchievements);
  }

  /// Проверяет milestone-ачивки на основе текущего прогресса (progressDays)
  /// Возвращает true, если хотя бы одна ачивка была разблокирована
  Future<bool> checkMilestones(int progressDays) async {
    bool changed = false;
    for (int i = 0; i < _currentAchievements.length; i++) {
      final ach = _currentAchievements[i];
      if (ach.type == AchievementType.milestone && !ach.isUnlocked) {
        bool shouldUnlock = false;
        // Определяем по id: если содержит "negative", то это отрицательная веха
        if (ach.id.contains('negative')) {
          // Достигнута глубина: progressDays должен быть меньше или равен -requiredValue
          if (progressDays <= -ach.requiredValue) {
            shouldUnlock = true;
          }
        } else {
          // Положительная веха: progressDays должен быть больше или равен requiredValue
          if (progressDays >= ach.requiredValue) {
            shouldUnlock = true;
          }
        }
        if (shouldUnlock) {
          _currentAchievements[i].isUnlocked = true;
          _currentAchievements[i].unlockDate = DateTime.now();
          changed = true;
          print('🎉 Milestone ачивка разблокирована: ${ach.id}');
        }
      }
    }
    if (changed) {
      await _saveAchievements();
    }
    return changed;
  }

  Future<List<Achievement>> resetAndCheckAllAchievements(int progressDays, Map<String, DayRecord> daysData) async {
    print('🔄 Сброс всех ачивок и повторная проверка');
    for (var i = 0; i < _currentAchievements.length; i++) {
      _currentAchievements[i].isUnlocked = false;
      _currentAchievements[i].unlockDate = null;
    }
    await _saveAchievements();
    await loadAchievements();
    return await updateAchievements(progressDays, daysData);
  }

  //Проверка спортивных ачивок
  bool _checkSportAchievement(SportPeriod period, int requiredCount, Map<String, DayRecord> daysData) {
    final maxCount = _findMaxSportDaysInAnyPeriod(period, daysData);
    return maxCount >= requiredCount;
  }

  int _findMaxSportDaysInAnyPeriod(SportPeriod period, Map<String, DayRecord> daysData) {
    final sportDays = _getSportDays(daysData);
    if (sportDays.isEmpty) return 0;

    int maxCount = 0;
    for (var sportDay in sportDays) {
      final endDate = sportDay;
      final startDate = endDate.subtract(Duration(days: period.daysCount - 1));
      final count = _countSportDaysInRange(startDate, endDate, daysData);
      if (count > maxCount) maxCount = count;
    }
    return maxCount;
  }

  List<DateTime> _getSportDays(Map<String, DayRecord> daysData) {
    List<DateTime> result = [];
    daysData.forEach((key, record) {
      if (record.hasSport) {
        final date = _parseDate(key);
        if (date != null) result.add(date);
      }
    });
    return result;
  }

  int _countSportDaysInRange(DateTime start, DateTime end, Map<String, DayRecord> daysData) {
    int count = 0;
    DateTime current = start;
    while (!current.isAfter(end)) {
      final key = _dateToKey(current);
      final record = daysData[key];
      if (record != null && record.hasSport) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  // Расчет максимального алкогольного стрика за всю историю
  bool _checkDrinkingStreak(int requiredDays, Map<String, DayRecord> daysData) {
    final maxStreak = _calculateMaxDrinkingStreak(daysData);
    print('📊 Максимальный алкогольный стрик: $maxStreak, требуется: $requiredDays');
    return maxStreak >= requiredDays;
  }

  bool _checkSoberStreak(int requiredDays, Map<String, DayRecord> daysData) {
    final maxStreak = _calculateMaxSoberStreak(daysData);
    print('📊 Максимальный трезвый стрик: $maxStreak, требуется: $requiredDays');
    return maxStreak >= requiredDays;
  }

  int _compareAchievements(Achievement a, Achievement b) {
    // Порядок типов
    const order = {
      AchievementType.soberStreak: 1,
      AchievementType.drinkingStreak: 2,
      AchievementType.sportCount: 3,
      AchievementType.uniqueEvent: 4,
      AchievementType.milestone: 5,
    };

    final typeCompare = order[a.type]!.compareTo(order[b.type]!);
    if (typeCompare != 0) return typeCompare;

    // Внутри одного типа сортируем по requiredValue (меньшие раньше)
    return a.requiredValue.compareTo(b.requiredValue);
  }

  List<Achievement> getAllAchievements() {
    final sorted = List<Achievement>.from(_currentAchievements);
    sorted.sort(_compareAchievements);
    return sorted;
  }

  List<Achievement> getUnlockedAchievements() {
    final unlocked = _currentAchievements.where((a) => a.isUnlocked).toList();
    unlocked.sort(_compareAchievements);
    return unlocked;
  }

  int _calculateMaxSoberStreak(Map<String, DayRecord> daysData) {
    final dates = daysData.keys.map(_parseDate).where((d) => d != null).cast<DateTime>().toList();
    if (dates.isEmpty) return 0;
    dates.sort();
    final firstDate = dates.first;
    final lastDate = DateTime.now();
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime current = firstDate;
    while (!current.isAfter(lastDate)) {
      final key = _dateToKey(current);
      final record = daysData[key] ?? DayRecord();
      final isDrinking = _isDrinkingDay(record);
      if (!isDrinking) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      current = current.add(const Duration(days: 1));
    }
    return maxStreak;
  }

  int _calculateMaxDrinkingStreak(Map<String, DayRecord> daysData) {
    final dates = daysData.keys.map(_parseDate).where((d) => d != null).cast<DateTime>().toList();
    if (dates.isEmpty) return 0;
    dates.sort();
    final firstDate = dates.first;
    final lastDate = DateTime.now();
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime current = firstDate;
    while (!current.isAfter(lastDate)) {
      final key = _dateToKey(current);
      final record = daysData[key] ?? DayRecord();
      final isDrinking = _isDrinkingDay(record);
      if (isDrinking) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      current = current.add(const Duration(days: 1));
    }
    return maxStreak;
  }

  bool _isDrinkingDay(DayRecord record) {
    return record.drinkLevel == DrinkLevel.little ||
        record.drinkLevel == DrinkLevel.medium ||
        record.drinkLevel == DrinkLevel.heavy ||
        record.drinkLevel == DrinkLevel.little_sport ||
        record.drinkLevel == DrinkLevel.medium_sport ||
        record.drinkLevel == DrinkLevel.heavy_sport;
  }

  DateTime? _parseDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    try {
      // Месяц в ключе уже 1-based, поэтому просто передаём его как есть
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }

  String _dateToKey(DateTime date) {
    // Месяц должен быть 1-based
    return '${date.year}-${date.month}-${date.day}';
  }

  /// Общее количество всех достижений
  int get totalAchievementsCount => _allAchievements.length;

  /// Количество разблокированных достижений
  int get unlockedAchievementsCount => _currentAchievements.where((a) => a.isUnlocked).length;
}