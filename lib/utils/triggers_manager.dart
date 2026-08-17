// lib/utils/triggers_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/drink_trigger.dart';

class TriggersManager {
  static const String _triggersKey = 'wobbly_triggers_data';

  Future<Map<String, List<DrinkTrigger>>> loadTriggers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_triggersKey);
      if (jsonString == null || jsonString.isEmpty) return {};

      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(json.decode(jsonString));
      final result = <String, List<DrinkTrigger>>{};
      jsonMap.forEach((key, value) {
        if (value is List) {
          final triggers = value
              .whereType<String>()
              .map(DrinkTrigger.fromRawValue)
              .whereType<DrinkTrigger>()
              .toList();
          if (triggers.isNotEmpty) {
            result[key] = triggers;
          }
        }
      });
      return result;
    } catch (e) {
      print('Error loading triggers: $e');
      return {};
    }
  }

  Future<void> saveTriggers(Map<String, List<DrinkTrigger>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = <String, List<String>>{};
      data.forEach((key, triggers) {
        if (triggers.isNotEmpty) {
          raw[key] = triggers.map((t) => t.rawValue).toList();
        }
      });
      await prefs.setString(_triggersKey, json.encode(raw));
    } catch (e) {
      print('Error saving triggers: $e');
    }
  }

  Future<void> setTriggersForDay(String dayKey, List<DrinkTrigger> triggers) async {
    final all = await loadTriggers();
    if (triggers.isEmpty) {
      all.remove(dayKey);
    } else {
      all[dayKey] = triggers;
    }
    await saveTriggers(all);
  }

  /// Полностью заменяет локальное хранилище (используется при применении серверных данных).
  Future<void> replaceAll(Map<String, List<DrinkTrigger>> data) async {
    await saveTriggers(data);
  }

  /// Мержит триггеры из импортированного файла в существующее хранилище
  /// (перезаписывает только дни, присутствующие в импорте — обратная совместимость
  /// со старыми файлами, где поля triggers вообще нет, гарантируется на уровне вызова).
  Future<void> mergeFromImport(Map<String, List<DrinkTrigger>> imported) async {
    if (imported.isEmpty) return;
    final all = await loadTriggers();
    imported.forEach((key, triggers) {
      if (triggers.isEmpty) {
        all.remove(key);
      } else {
        all[key] = triggers;
      }
    });
    await saveTriggers(all);
  }
}
