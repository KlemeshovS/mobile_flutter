// test/models/export_data_triggers_test.dart
//
// Обратная совместимость: старые файлы экспорта без поля triggers
// должны парситься без ошибок, новые — сохранять теги при round-trip.
import 'package:flutter_test/flutter_test.dart';
import 'package:wobbly/models/drink_trigger.dart';
import 'package:wobbly/models/export_data.dart';

void main() {
  test('decodes an old export file that has no triggers field at all', () {
    final json = {
      'version': '2.0',
      'exportDate': '2026-01-01T00:00:00.000Z',
      'daysData': {'2026-1-1': 'little'},
    };

    final data = ExportData.fromJson(json);

    expect(data.triggers, isNull);
    expect(data.daysData['2026-1-1'], 'little');
  });

  test('decodes triggers when present', () {
    final json = {
      'version': '2.0',
      'exportDate': '2026-01-01T00:00:00.000Z',
      'daysData': {'2026-8-17': 'medium'},
      'triggers': {
        '2026-8-17': ['stress', 'conflict'],
      },
    };

    final data = ExportData.fromJson(json);

    expect(data.triggers, isNotNull);
    expect(data.triggers!['2026-8-17'], containsAll([DrinkTrigger.stress, DrinkTrigger.conflict]));
  });

  test('ignores unknown trigger raw values instead of crashing', () {
    final json = {
      'version': '2.0',
      'exportDate': '2026-01-01T00:00:00.000Z',
      'daysData': <String, dynamic>{},
      'triggers': {
        '2026-8-17': ['stress', 'not_a_real_tag'],
      },
    };

    final data = ExportData.fromJson(json);

    expect(data.triggers!['2026-8-17'], [DrinkTrigger.stress]);
  });

  test('a day whose triggers are all unknown is dropped, not left empty', () {
    final json = {
      'version': '2.0',
      'exportDate': '2026-01-01T00:00:00.000Z',
      'daysData': <String, dynamic>{},
      'triggers': {
        '2026-8-17': ['not_a_real_tag'],
      },
    };

    final data = ExportData.fromJson(json);

    expect(data.triggers!.containsKey('2026-8-17'), isFalse);
  });
}
