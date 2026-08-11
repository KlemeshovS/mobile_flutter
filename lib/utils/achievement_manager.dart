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
      id: 'milestone_1917',
      titleKey: 'ach_milestone_1917_title',
      descriptionKey: 'ach_milestone_1917_desc',
      type: AchievementType.milestone,
      requiredValue: 1917,
    ),
    Achievement(
      id: 'milestone_3491',
      titleKey: 'ach_milestone_3491_title',
      descriptionKey: 'ach_milestone_3491_desc',
      type: AchievementType.milestone,
      requiredValue: 3491,
    ),
    Achievement(
      id: 'milestone_4478',
      titleKey: 'ach_milestone_4478_title',
      descriptionKey: 'ach_milestone_4478_desc',
      type: AchievementType.milestone,
      requiredValue: 4478,
    ),
    Achievement(
      id: 'milestone_4810',
      titleKey: 'ach_milestone_4810_title',
      descriptionKey: 'ach_milestone_4810_desc',
      type: AchievementType.milestone,
      requiredValue: 4810,
    ),
    Achievement(
      id: 'milestone_4506',
      titleKey: 'ach_milestone_4506_title',
      descriptionKey: 'ach_milestone_4506_desc',
      type: AchievementType.milestone,
      requiredValue: 4506,
    ),
    Achievement(
      id: 'milestone_5054',
      titleKey: 'ach_milestone_5054_title',
      descriptionKey: 'ach_milestone_5054_desc',
      type: AchievementType.milestone,
      requiredValue: 5054,
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
    // Трезвые дни в году
    Achievement(
      id: 'sober_days_year_100',
      titleKey: 'ach_sober_year_100_title',
      descriptionKey: 'ach_sober_year_100_desc',
      type: AchievementType.soberDaysInYear,
      requiredValue: 100,
    ),
    Achievement(
      id: 'sober_days_year_200',
      titleKey: 'ach_sober_year_200_title',
      descriptionKey: 'ach_sober_year_200_desc',
      type: AchievementType.soberDaysInYear,
      requiredValue: 200,
    ),
    Achievement(
      id: 'sober_days_year_300',
      titleKey: 'ach_sober_year_300_title',
      descriptionKey: 'ach_sober_year_300_desc',
      type: AchievementType.soberDaysInYear,
      requiredValue: 300,
    ),
    // Алкогольные дни в году
    Achievement(
      id: 'drink_days_year_100',
      titleKey: 'ach_drink_year_100_title',
      descriptionKey: 'ach_drink_year_100_desc',
      type: AchievementType.drinkingDaysInYear,
      requiredValue: 100,
    ),
    Achievement(
      id: 'drink_days_year_200',
      titleKey: 'ach_drink_year_200_title',
      descriptionKey: 'ach_drink_year_200_desc',
      type: AchievementType.drinkingDaysInYear,
      requiredValue: 200,
    ),
    Achievement(
      id: 'drink_days_year_300',
      titleKey: 'ach_drink_year_300_title',
      descriptionKey: 'ach_drink_year_300_desc',
      type: AchievementType.drinkingDaysInYear,
      requiredValue: 300,
    ),

    // Трезвые месяцы
    Achievement(id: 'sober_month_1', titleKey: 'ach_sober_month_1_title', descriptionKey: 'ach_sober_month_1_desc', type: AchievementType.soberMonth, requiredValue: 1),
    Achievement(id: 'sober_month_2', titleKey: 'ach_sober_month_2_title', descriptionKey: 'ach_sober_month_2_desc', type: AchievementType.soberMonth, requiredValue: 2),
    Achievement(id: 'sober_month_3', titleKey: 'ach_sober_month_3_title', descriptionKey: 'ach_sober_month_3_desc', type: AchievementType.soberMonth, requiredValue: 3),
    Achievement(id: 'sober_month_4', titleKey: 'ach_sober_month_4_title', descriptionKey: 'ach_sober_month_4_desc', type: AchievementType.soberMonth, requiredValue: 4),
    Achievement(id: 'sober_month_5', titleKey: 'ach_sober_month_5_title', descriptionKey: 'ach_sober_month_5_desc', type: AchievementType.soberMonth, requiredValue: 5),
    Achievement(id: 'sober_month_6', titleKey: 'ach_sober_month_6_title', descriptionKey: 'ach_sober_month_6_desc', type: AchievementType.soberMonth, requiredValue: 6),
    Achievement(id: 'sober_month_7', titleKey: 'ach_sober_month_7_title', descriptionKey: 'ach_sober_month_7_desc', type: AchievementType.soberMonth, requiredValue: 7),
    Achievement(id: 'sober_month_8', titleKey: 'ach_sober_month_8_title', descriptionKey: 'ach_sober_month_8_desc', type: AchievementType.soberMonth, requiredValue: 8),
    Achievement(id: 'sober_month_9', titleKey: 'ach_sober_month_9_title', descriptionKey: 'ach_sober_month_9_desc', type: AchievementType.soberMonth, requiredValue: 9),
    Achievement(id: 'sober_month_10', titleKey: 'ach_sober_month_10_title', descriptionKey: 'ach_sober_month_10_desc', type: AchievementType.soberMonth, requiredValue: 10),
    Achievement(id: 'sober_month_11', titleKey: 'ach_sober_month_11_title', descriptionKey: 'ach_sober_month_11_desc', type: AchievementType.soberMonth, requiredValue: 11),
    Achievement(id: 'sober_month_12', titleKey: 'ach_sober_month_12_title', descriptionKey: 'ach_sober_month_12_desc', type: AchievementType.soberMonth, requiredValue: 12),

    // Ачивки "без похмелья" (без medium/heavy N дней подряд)
    Achievement(
      id: 'no_hangover_90',
      titleKey: 'ach_no_hangover_90_title',
      descriptionKey: 'ach_no_hangover_90_desc',
      type: AchievementType.noHangoverStreak,
      requiredValue: 90,
    ),
    Achievement(
      id: 'no_hangover_180',
      titleKey: 'ach_no_hangover_180_title',
      descriptionKey: 'ach_no_hangover_180_desc',
      type: AchievementType.noHangoverStreak,
      requiredValue: 180,
    ),
    Achievement(
      id: 'no_hangover_365',
      titleKey: 'ach_no_hangover_365_title',
      descriptionKey: 'ach_no_hangover_365_desc',
      type: AchievementType.noHangoverStreak,
      requiredValue: 365,
    ),

    // Уникальные ачивки
    Achievement(
      id: 'sober_new_year',
      titleKey: 'ach_unique_sober_ny_title',
      descriptionKey: 'ach_unique_sober_ny_desc',
      type: AchievementType.uniqueEvent,
      requiredValue: 0,
      event: UniqueEvent.soberNewYear,
    ),
    Achievement(
      id: 'sport_new_year',
      titleKey: 'ach_unique_sport_ny_title',
      descriptionKey: 'ach_unique_sport_ny_desc',
      type: AchievementType.uniqueEvent,
      requiredValue: 0,
      event: UniqueEvent.sportNewYear,
    ),

    // Milestone — впадина Романш (пропущена)
    Achievement(
      id: 'milestone_7729_negative',
      titleKey: 'ach_milestone_7729_negative_title',
      descriptionKey: 'ach_milestone_7729_negative_desc',
      type: AchievementType.milestone,
      requiredValue: 7729,
    ),

    // Ачивка за отзыв в Google Play (ручная разблокировка)
    Achievement(id: 'left_review', titleKey: 'ach_review_title', descriptionKey: 'ach_review_desc', type: AchievementType.leftReview, requiredValue: 0),
  ];
  List<Achievement> get achievements => _currentAchievements;

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
        return _checkUniqueEvent(ach.event!, daysData);
      case AchievementType.milestone:
        return false;
      case AchievementType.soberDaysInYear:
        return _countSoberDaysInYear(daysData) >= ach.requiredValue;
      case AchievementType.drinkingDaysInYear:
        return _countDrinkingDaysInYear(daysData) >= ach.requiredValue;
      case AchievementType.soberMonth:
        return _checkSoberMonth(ach.requiredValue, daysData);
      case AchievementType.leftReview:
        return false; // разблокируется только вручную через unlockReviewAchievement()
      case AchievementType.noHangoverStreak:
        return _checkNoHangoverStreak(ach.requiredValue, daysData);
    }
  }

  /// Вызвать после того как пользователь нажал «Оценить» и перешёл в Google Play.
  Future<Achievement?> unlockReviewAchievement() async {
    final index = _currentAchievements.indexWhere((a) => a.id == 'left_review');
    if (index == -1 || _currentAchievements[index].isUnlocked) return null;
    _currentAchievements[index].isUnlocked = true;
    _currentAchievements[index].unlockDate = DateTime.now();
    await _saveAchievements();
    return _currentAchievements[index];
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
      } else if (ach.type == AchievementType.leftReview) {
        // Ручная ачивка — никогда не перезаблокировывать автоматически
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
      AchievementType.noHangoverStreak: 4,
      AchievementType.soberDaysInYear: 5,
      AchievementType.drinkingDaysInYear: 6,
      AchievementType.soberMonth: 7,
      AchievementType.uniqueEvent: 8,
      AchievementType.milestone: 9,
      AchievementType.leftReview: 10,
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

  int _countSoberDaysInYear(Map<String, DayRecord> daysData) {
    final year = DateTime.now().year;
    int count = 0;
    daysData.forEach((key, record) {
      final date = _parseDate(key);
      if (date != null && date.year == year && !_isDrinkingDay(record)) {
        count++;
      }
    });
    return count;
  }

  int _countDrinkingDaysInYear(Map<String, DayRecord> daysData) {
    final year = DateTime.now().year;
    int count = 0;
    daysData.forEach((key, record) {
      final date = _parseDate(key);
      if (date != null && date.year == year && _isDrinkingDay(record)) {
        count++;
      }
    });
    return count;
  }

  bool _isDrinkingDay(DayRecord record) {
    return record.drinkLevel == DrinkLevel.little ||
        record.drinkLevel == DrinkLevel.medium ||
        record.drinkLevel == DrinkLevel.heavy ||
        record.drinkLevel == DrinkLevel.little_sport ||
        record.drinkLevel == DrinkLevel.medium_sport ||
        record.drinkLevel == DrinkLevel.heavy_sport;
  }

  // Стрик без "тяжёлых" дней (medium/heavy) — как в Swift noHangoverStreak
  bool _checkNoHangoverStreak(int requiredDays, Map<String, DayRecord> daysData) {
    if (daysData.isEmpty) return false;
    final dates = daysData.keys.map(_parseDate).where((d) => d != null).cast<DateTime>().toList();
    if (dates.isEmpty) return false;
    dates.sort();
    final firstDate = dates.first;
    final today = DateTime.now();
    final lastDate = DateTime(today.year, today.month, today.day);

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime current = firstDate;
    while (!current.isAfter(lastDate)) {
      final key = _dateToKey(current);
      final record = daysData[key] ?? DayRecord();
      final isHangover = record.drinkLevel == DrinkLevel.medium || record.drinkLevel == DrinkLevel.heavy;
      if (isHangover) {
        currentStreak = 0;
      } else {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      }
      current = current.add(const Duration(days: 1));
    }
    return maxStreak >= requiredDays;
  }

  // Уникальные события — трезвый/спортивный Новый год
  bool _checkUniqueEvent(UniqueEvent event, Map<String, DayRecord> daysData) {
    if (daysData.isEmpty) return false;
    final now = DateTime.now();
    final currentYear = now.year;

    // Дата начала использования приложения — самая ранняя запись в данных
    final startDate = _getStartDate(daysData);
    if (startDate == null) return false;

    for (int year = currentYear - 3; year <= currentYear; year++) {
      final dec31 = DateTime(year, 12, 31);
      // Не проверяем будущие даты
      if (dec31.isAfter(now)) continue;
      // Не проверяем даты раньше начала использования приложения
      if (dec31.isBefore(startDate)) continue;

      final key = '$year-12-31';
      // Если записи нет — день не зафиксирован, пропускаем
      // (пользователь мог не открывать приложение в этот день)
      if (!daysData.containsKey(key)) continue;

      final record = daysData[key]!;
      switch (event) {
        case UniqueEvent.soberNewYear:
          if (!_isDrinkingDay(record)) return true;
          break;
        case UniqueEvent.sportNewYear:
          if (record.hasSport) return true;
          break;
      }
    }
    return false;
  }

  // Самая ранняя дата в данных пользователя
  DateTime? _getStartDate(Map<String, DayRecord> daysData) {
    DateTime? earliest;
    for (final key in daysData.keys) {
      final date = _parseDate(key);
      if (date != null && (earliest == null || date.isBefore(earliest))) {
        earliest = date;
      }
    }
    return earliest;
  }

  bool _checkSoberMonth(int month, Map<String, DayRecord> daysData) {
    // Проверяем все годы — если хоть в одном году этот месяц был полностью трезвым
    final years = <int>{};
    daysData.keys.forEach((key) {
      final date = _parseDate(key);
      if (date != null) years.add(date.year);
    });
    // Также добавляем текущий год
    years.add(DateTime.now().year);

    for (final year in years) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final now = DateTime.now();
      // Не проверяем текущий незавершённый месяц
      if (year == now.year && month == now.month) continue;
      // Не проверяем будущие месяцы
      if (year > now.year) continue;
      if (year == now.year && month > now.month) continue;

      bool allSober = true;
      for (int day = 1; day <= daysInMonth; day++) {
        final key = '$year-$month-$day';
        final record = daysData[key] ?? DayRecord();
        if (_isDrinkingDay(record)) {
          allSober = false;
          break;
        }
      }
      if (allSober) return true;
    }
    return false;
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