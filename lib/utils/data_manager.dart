import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_record.dart';
import 'package:wobbly/models/export_data.dart';

class DataManager {
  static const String _dataKey = 'wobbly_days_data';

  Future<Map<String, DayRecord>> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_dataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }

      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
        json.decode(jsonString),
      );

      final Map<String, DayRecord> result = {};

      jsonMap.forEach((key, value) {
        if (value is int) {
          result[key] = DayRecord.fromLegacy(value);
        }
      });

      return result;
    } catch (e) {
      print('Error loading data: $e');
      return {};
    }
  }

  /// Импорт данных из JSON-файла (путь к файлу)
  Future<bool> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Файл не существует: $filePath');
        return false;
      }

      final jsonString = await file.readAsString();
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final exportData = ExportData.fromJson(jsonMap);

      // Конвертируем в DayRecord и сохраняем
      final newRecords = exportData.toDayRecords();
      await saveData(newRecords);

      print('Импорт успешен: ${newRecords.length} записей');
      return true;
    } catch (e, stack) {
      print('Ошибка импорта: $e');
      print(stack);
      return false;
    }
  }

  Future<void> saveData(Map<String, DayRecord> daysData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> legacyData = {};

      daysData.forEach((key, record) {
        legacyData[key] = record.toLegacy;
      });

      final jsonString = json.encode(legacyData);
      await prefs.setString(_dataKey, jsonString);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> updateDayRecord(String key, DayRecord? record) async {
    print("📝 updateDayRecord: key=$key, record=${record != null ? '${record.drinkLevel},${record.hasSport}' : 'null'}");
    final data = await loadData();
    if (record == null) {
      data.remove(key);
      print("   ➡️ удаляем ключ");
    } else {
      data[key] = record;
      print("   ➡️ устанавливаем запись");
    }
    await saveData(data);
    print("   ✅ сохранено");
  }
}