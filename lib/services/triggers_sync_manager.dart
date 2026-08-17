import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/drink_trigger.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/triggers_manager.dart';

class TriggersSyncManager {
  static final TriggersSyncManager _instance = TriggersSyncManager._internal();
  factory TriggersSyncManager() => _instance;
  TriggersSyncManager._internal();

  static const String _localUpdatedAtKey = 'triggersLocalUpdatedAt';

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
      print('⏭️ TriggersSync: пропуск, не аутентифицирован');
      return;
    }
    final token = session.accessToken;
    if (token == null) return;

    try {
      print('🔄 TriggersSync: запрос данных с сервера...');
      final serverData = await UserAPIService().getTriggers(token);
      final serverUpdatedAt = _parseServerDate(serverData.updatedAt);
      final localUpdatedAt = await _getLocalUpdatedAt();
      print('🔄 TriggersSync: localUpdatedAt=$localUpdatedAt');

      if (localUpdatedAt == null) {
        if (serverData.triggers.isNotEmpty) {
          print('📥 TriggersSync: первый запуск, берём ${serverData.triggers.length} записей с сервера');
          await _applyServerData(serverData.triggers);
        } else {
          print('📤 TriggersSync: первый запуск, сервер пустой — отправляем локальные');
          await pushToServer();
        }
        return;
      }

      if (serverUpdatedAt == null) {
        print('📤 TriggersSync: нет серверной даты — отправляем локальные');
        await pushToServer();
        return;
      }

      if (localUpdatedAt.isAfter(serverUpdatedAt)) {
        print('📤 TriggersSync: локальные новее — отправляем');
        await pushToServer();
      } else if (serverUpdatedAt.isAfter(localUpdatedAt)) {
        print('📥 TriggersSync: серверные новее — берём');
        await _applyServerData(serverData.triggers);
      } else {
        print('✅ TriggersSync: данные синхронизированы');
      }
    } catch (e) {
      print('❌ TriggersSync error: $e');
    }
  }

  // MARK: - Отправка локальных данных на сервер
  Future<void> pushToServer() async {
    final session = SessionManager();
    await session.init();
    final token = session.accessToken;
    if (token == null) return;

    final triggersManager = TriggersManager();
    final localData = await triggersManager.loadTriggers();

    // Ключ дня в Flutter — month 1-based, на сервере (и в Swift-клиенте) — 0-based.
    final serverTriggers = <String, List<String>>{};
    localData.forEach((key, triggers) {
      if (triggers.isEmpty) return;
      final parts = key.split('-');
      if (parts.length != 3) return;
      final month = int.tryParse(parts[1]);
      if (month == null) return;
      final serverKey = '${parts[0]}-${month - 1}-${parts[2]}';
      serverTriggers[serverKey] = triggers.map((t) => t.rawValue).toList();
    });

    final localUpdatedAt = await _getLocalUpdatedAt();

    try {
      final response = await UserAPIService().putTriggers(
        token,
        serverTriggers,
        clientUpdatedAt: localUpdatedAt?.toUtc().toIso8601String(),
      );
      print('✅ TriggersSync: отправлено ${serverTriggers.length} записей');
      if (response.updatedAt != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localUpdatedAtKey, response.updatedAt!);
        print('✅ TriggersSync: localUpdatedAt обновлён серверным значением');
      }
    } on UserAPIError catch (e) {
      if (e == UserAPIError.triggersConflict) {
        // Сервер уже содержит более новую версию — не перезаписываем её,
        // а подтягиваем актуальные данные оттуда.
        print('⚠️ TriggersSync: конфликт — сервер новее, подтягиваем серверные данные');
        try {
          final serverData = await UserAPIService().getTriggers(token);
          await _applyServerData(serverData.triggers);
        } catch (e2) {
          print('❌ TriggersSync: не удалось получить серверные данные после конфликта: $e2');
        }
      } else {
        print('❌ TriggersSync push error: $e');
      }
    } catch (e) {
      print('❌ TriggersSync push error: $e');
    }
  }

  // MARK: - Применение серверных данных локально
  Future<void> _applyServerData(Map<String, List<String>> triggers) async {
    final newData = <String, List<DrinkTrigger>>{};
    triggers.forEach((key, rawTriggers) {
      final parsed = rawTriggers
          .map(DrinkTrigger.fromRawValue)
          .whereType<DrinkTrigger>()
          .toList();
      if (parsed.isEmpty) return;

      // Сервер (и Swift-клиент) хранят month 0-based, во Flutter — 1-based.
      final parts = key.split('-');
      if (parts.length != 3) {
        newData[key] = parsed;
        return;
      }
      final month = int.tryParse(parts[1]);
      if (month == null) {
        newData[key] = parsed;
        return;
      }
      final localKey = '${parts[0]}-${month + 1}-${parts[2]}';
      newData[localKey] = parsed;
    });

    final triggersManager = TriggersManager();
    await triggersManager.replaceAll(newData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUpdatedAtKey, DateTime.now().toUtc().toIso8601String());

    print('✅ TriggersSync: применено ${newData.length} записей с сервера');
  }
}
