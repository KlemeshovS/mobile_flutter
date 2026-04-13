import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';

class ExportData {
  final String version;
  final DateTime exportDate;
  final Map<String, String> daysData; // старый формат
  final Map<String, DayRecord>? dayRecords; // новый формат (опционально)

  ExportData({
    required this.version,
    required this.exportDate,
    required this.daysData,
    this.dayRecords,
  });

  factory ExportData.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String? ?? '1.0';

    // Парсим дату (ISO8601 или текущая)
    late DateTime exportDate;
    try {
      if (json['exportDate'] is String) {
        exportDate = DateTime.parse(json['exportDate'] as String);
      } else {
        exportDate = DateTime.now();
      }
    } catch (_) {
      exportDate = DateTime.now();
    }

    // Старый формат daysData (ключ -> строка)
    final daysData = <String, String>{};
    if (json['daysData'] != null) {
      (json['daysData'] as Map<String, dynamic>).forEach((key, value) {
        daysData[key] = value.toString();
      });
    }

    // Новый формат dayRecords (ключ -> объект DayRecord)
    Map<String, DayRecord>? dayRecords;
    if (json['dayRecords'] != null) {
      dayRecords = {};
      final recordsMap = json['dayRecords'] as Map<String, dynamic>;
      recordsMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final drinkLevelStr = value['drinkLevel'] as String? ?? 'none';
          final hasSport = value['hasSport'] as bool? ?? false;

          // Преобразуем строку в DrinkLevel
          final drinkLevel = DrinkLevel.values.firstWhere(
            (e) => e.toString().split('.').last == drinkLevelStr,
            orElse: () => DrinkLevel.none,
          );

          dayRecords![key] = DayRecord(
            drinkLevel: drinkLevel,
            hasSport: hasSport,
          );
        }
      });
    }

    return ExportData(
      version: version,
      exportDate: exportDate,
      daysData: daysData,
      dayRecords: dayRecords,
    );
  }

  /// Конвертирует данные в единый формат Map<String, DayRecord>
  Map<String, DayRecord> toDayRecords() {
    if (dayRecords != null) {
      return dayRecords!;
    }

    // Конвертируем старый формат
    final records = <String, DayRecord>{};
    daysData.forEach((key, value) {
      DrinkLevel drinkLevel;
      bool hasSport = false;

      switch (value) {
        case 'none':
          drinkLevel = DrinkLevel.none;
          break;
        case 'little':
          drinkLevel = DrinkLevel.little;
          break;
        case 'medium':
          drinkLevel = DrinkLevel.medium;
          break;
        case 'heavy':
          drinkLevel = DrinkLevel.heavy;
          break;
        case 'sport':
          drinkLevel = DrinkLevel.none;
          hasSport = true;
          break;
        case 'little_sport':
          drinkLevel = DrinkLevel.little;
          hasSport = true;
          break;
        case 'medium_sport':
          drinkLevel = DrinkLevel.medium;
          hasSport = true;
          break;
        case 'heavy_sport':
          drinkLevel = DrinkLevel.heavy;
          hasSport = true;
          break;
        default:
          drinkLevel = DrinkLevel.none;
      }

      records[key] = DayRecord(drinkLevel: drinkLevel, hasSport: hasSport);
    });

    return records;
  }
}
