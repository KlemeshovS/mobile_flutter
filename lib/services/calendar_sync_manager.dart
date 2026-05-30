import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/data_manager.dart';

class CalendarSyncManager {
  static final CalendarSyncManager _instance = CalendarSyncManager._internal();
  factory CalendarSyncManager() => _instance;
  CalendarSyncManager._internal();

  static const String _localUpdatedAtKey = 'calendarLocalUpdatedAt';

  // MARK: - Конвертация DrinkLevel <-> Int
  int _drinkLevelToInt(DayRecord record) {
    if (record.drinkLevel == DrinkLevel.little && record.hasSport) return 5;
    if (record.drinkLevel == DrinkLevel.medium && record.hasSport) return 6;
    if (record.drinkLevel == DrinkLevel.heavy && record.hasSport) return 7;
    if (record.hasSport) return 4;
    return record.drinkLevel.value;
  }

  DayRecord _intToDayRecord(int value) {
    return DayRecord.fromLegacy(value);
  }

  // MARK: - Отметить локальное изменение
  Future<void> markLocalUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUpdatedAtKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<DateTime?> _getLocalUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_localUpdatedAtKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  DateTime? _parseServerDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  // MARK: - Основная синхронизация
  Future<void> sync() async {
    final session = SessionManager();
    await session.init();
    if (session.sessionType != SessionType.authenticated) {
      print('⏭️ CalendarSync: пропуск, не аутентифицирован');
      return;
    }
    final token = session.accessToken;
    if (token == null) return;

    try {
      print('🔄 CalendarSync: запрос данных с сервера...');
      final serverData = await UserAPIService().getCalendar(token);
      final serverUpdatedAt = _parseServerDate(serverData.updatedAt);
      final localUpdatedAt = await _getLocalUpdatedAt();
      print('🔄 CalendarSync: localUpdatedAt=$localUpdatedAt');

      if (localUpdatedAt == null) {
        if (serverData.days.isNotEmpty) {
          print('📥 CalendarSync: первый запуск, берём ${serverData.days.length} записей с сервера');
          await _applyServerData(serverData.days);
        } else {
          print('📤 CalendarSync: первый запуск, сервер пустой — отправляем локальные');
          await pushToServer();
        }
        return;
      }

      if (serverUpdatedAt == null) {
        print('📤 CalendarSync: нет серверной даты — отправляем локальные');
        await pushToServer();
        return;
      }

      if (localUpdatedAt.isAfter(serverUpdatedAt)) {
        print('📤 CalendarSync: локальные новее — отправляем');
        await pushToServer();
      } else if (serverUpdatedAt.isAfter(localUpdatedAt)) {
        print('📥 CalendarSync: серверные новее — берём');
        await _applyServerData(serverData.days);
      } else {
        print('✅ CalendarSync: данные синхронизированы');
      }
    } catch (e) {
      print('❌ CalendarSync error: $e');
    }
  }

  // MARK: - Отправка локальных данных на сервер
  Future<void> pushToServer() async {
    final session = SessionManager();
    await session.init();
    final token = session.accessToken;
    if (token == null) return;

    final dataManager = DataManager();
    final localData = await dataManager.loadData();

    print('📤 CalendarSync pushToServer: локальных записей = ${localData.length}');
    print('📤 CalendarSync pushToServer: ключи = ${localData.keys.take(5).toList()}');

    final serverDays = <String, int>{};
    localData.forEach((key, record) {
      final intValue = _drinkLevelToInt(record);
      if (intValue != 0) {
        // Конвертируем из Flutter 1-based в server 0-based
        final parts = key.split('-');
        if (parts.length == 3) {
          final month = int.tryParse(parts[1]);
          if (month != null) {
            final serverKey = '${parts[0]}-${month - 1}-${parts[2]}';
            serverDays[serverKey] = intValue;
          }
        } else {
          serverDays[key] = intValue;
        }
      }
    });

    print('📤 CalendarSync: отправляем ${serverDays.length} записей, примеры: ${serverDays.entries.take(3).map((e) => "${e.key}=${e.value}").toList()}');


    try {
      final response = await UserAPIService().putCalendar(token, serverDays);
      print('✅ CalendarSync: отправлено ${serverDays.length} записей');
      if (response.updatedAt != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localUpdatedAtKey, response.updatedAt!);
        print('✅ CalendarSync: localUpdatedAt обновлён серверным значением');
      }
    } catch (e) {
      print('❌ CalendarSync push error: $e');
    }
  }

  // MARK: - Применение серверных данных локально
  Future<void> _applyServerData(Map<String, int> days) async {
    final newData = <String, DayRecord>{};
    days.forEach((key, value) {
      final record = _intToDayRecord(value);
      if (record.drinkLevel != DrinkLevel.none || record.hasSport) {
        // Конвертируем из server 0-based в Flutter 1-based
        final parts = key.split('-');
        if (parts.length == 3) {
          final month = int.tryParse(parts[1]);
          if (month != null) {
            final localKey = '${parts[0]}-${month + 1}-${parts[2]}';
            newData[localKey] = record;
          }
        } else {
          newData[key] = record;
        }
      }
    });

    final dataManager = DataManager();
    await dataManager.saveData(newData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUpdatedAtKey, DateTime.now().toUtc().toIso8601String());

    print('✅ CalendarSync: применено ${newData.length} записей с сервера');
  }
}