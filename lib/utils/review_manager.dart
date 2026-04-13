import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/day_record.dart';
import '../models/drink_level.dart';

class ReviewManager {
  static final ReviewManager _instance = ReviewManager._internal();
  factory ReviewManager() => _instance;
  ReviewManager._internal();

  static const String _hasRatedKey = 'review_has_rated';
  static const String _statsOpenCountKey = 'review_stats_open_count';
  static const String _lastPromptDateKey = 'review_last_prompt_date';

  final int _minOpensBeforePrompt = 1;
  final int _minDaysBetweenPrompts = 10;
  final int _minMarkedDaysBeforePrompt = 5;

  bool _testModeOverride = false;
  bool get _effectiveTestMode =>
      _testModeOverride || (kDebugMode && false); // по умолчанию выключен

  void enableTestMode() => _testModeOverride = true;
  void disableTestMode() => _testModeOverride = false;

  // Подсчёт отмеченных дней (алкоголь или спорт)
  int countUserMarkedDays(Map<String, DayRecord> daysData) {
    return daysData.values.where((record) {
      return (record.drinkLevel != DrinkLevel.none) || record.hasSport;
    }).length;
  }

  Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasRatedKey) ?? false;
  }

  Future<void> setHasRated(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, value);
  }

  Future<int> getStatsOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_statsOpenCountKey) ?? 0;
  }

  Future<void> setStatsOpenCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_statsOpenCountKey, value);
  }

  Future<DateTime?> getLastPromptDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastPromptDateKey);
    if (timestamp != null)
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    return null;
  }

  Future<void> setLastPromptDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPromptDateKey, date.millisecondsSinceEpoch);
  }

  Future<void> incrementStatsOpenCount() async {
    final current = await getStatsOpenCount();
    await setStatsOpenCount(current + 1);
  }

  Future<bool> shouldShowPrompt(Map<String, DayRecord> daysData) async {
    if (_effectiveTestMode) return true;
    if (await hasRated()) return false;
    if (countUserMarkedDays(daysData) < _minMarkedDaysBeforePrompt)
      return false;
    if (await getStatsOpenCount() < _minOpensBeforePrompt) return false;

    final lastDate = await getLastPromptDate();
    if (lastDate != null) {
      final daysSince = DateTime.now().difference(lastDate).inDays;
      if (daysSince < _minDaysBetweenPrompts) return false;
    }
    return true;
  }

  Future<void> didShowPrompt() async {
    await setLastPromptDate(DateTime.now());
    await setStatsOpenCount(0);
  }

  Future<void> didRate() async {
    await setHasRated(true);
    await setStatsOpenCount(0);
    await setLastPromptDate(DateTime.now());
  }
}
