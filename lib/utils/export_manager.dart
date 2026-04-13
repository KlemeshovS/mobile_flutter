// lib/utils/export_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';

class ExportManager {
  static Future<void> exportData(
    BuildContext context,
    Map<String, DayRecord> daysData,
  ) async {
    print('ExportManager: Starting export process...');

    try {
      // Создаем структуру данных для экспорта
      final Map<String, String> daysDataMap = {};
      daysData.forEach((key, record) {
        // Пропускаем unknown (неотмеченные дни)
        if (record.drinkLevel == DrinkLevel.unknown) {
          return;
        }

        String value;

        if (record.hasSport) {
          if (record.drinkLevel == DrinkLevel.little) {
            value = 'little_sport';
          } else if (record.drinkLevel == DrinkLevel.medium) {
            value = 'medium_sport';
          } else if (record.drinkLevel == DrinkLevel.heavy) {
            value = 'heavy_sport';
          } else if (record.drinkLevel == DrinkLevel.none) {
            value = 'sport';
          } else {
            value = 'sport';
          }
        } else {
          value = record.drinkLevel.toString().split('.').last;
        }

        daysDataMap[key] = value;
      });

      final exportData = {
        'version': '2.0',
        'exportDate': DateTime.now().toIso8601String(),
        'daysData': daysDataMap,
      };

      print('ExportManager: Data prepared, ${daysDataMap.length} days');

      // Конвертируем в JSON с отступами
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      print('ExportManager: JSON created (${jsonString.length} chars)');

      // Тест 1: Простой шаринг текста
      print('ExportManager: Test 1 - Simple text share');
      try {
        await Share.share(
          'Test export from Wobbly\nDays: ${daysDataMap.length}',
          subject: 'Wobbly Export Test',
        );
        print('ExportManager: Simple share successful');
        return; // Если простой шаринг работает, выходим
      } catch (e) {
        print('ExportManager: Simple share failed: $e');
      }

      // Тест 2: Шаринг JSON как текста
      print('ExportManager: Test 2 - JSON text share');
      try {
        await Share.share(
          jsonString,
          subject: 'Wobbly Data Export',
        );
        print('ExportManager: JSON text share successful');
        return;
      } catch (e) {
        print('ExportManager: JSON text share failed: $e');
      }

      // Тест 3: Создание файла и шаринг
      print('ExportManager: Test 3 - File share');
      try {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now()
            .toString()
            .replaceAll(' ', '_')
            .replaceAll(':', '-')
            .split('.')[0];
        final fileName = 'wobbly_export_$timestamp.json';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsString(jsonString);

        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Wobbly Data Export',
          text: 'Here is my Wobbly data export file.',
        );

        print('ExportManager: File share successful');

        // Удаляем временный файл
        Future.delayed(const Duration(seconds: 30)).then((_) async {
          if (await file.exists()) {
            await file.delete();
          }
        });
      } catch (e) {
        print('ExportManager: File share failed: $e');
        rethrow;
      }
    } catch (e, stackTrace) {
      print('ExportManager: Error occurred: $e');
      print('ExportManager: Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
