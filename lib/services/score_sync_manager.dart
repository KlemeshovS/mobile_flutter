import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/utils/sobriety_progress_calculator.dart';
import 'package:wobbly/utils/install_date_manager.dart';
import 'package:wobbly/models/day_record.dart';

class ScoreSyncManager {
  static final ScoreSyncManager _instance = ScoreSyncManager._internal();
  factory ScoreSyncManager() => _instance;
  ScoreSyncManager._internal() {
    print('🔄 ScoreSyncManager инициализирован');
  }

  final SessionManager _session = SessionManager();
  final UserAPIService _api = UserAPIService();

  // Вызывать при любом изменении daysData
  Future<void> sendScore(Map<String, DayRecord> daysData) async {
    final prefs = await SharedPreferences.getInstance();
    final participate = prefs.getBool('userParticipateInRating') ?? false;
    if (!participate) {
      print('⏭️ Пропуск отправки счёта: пользователь не участвует');
      return;
    }

    // 🔥 ДОБАВИТЬ ПРОВЕРКУ ИМЕНИ
    final userName = prefs.getString('userName');
    print('📊 [Score] sendScore: participate=$participate, userName=$userName');
    if (userName == null || userName.isEmpty) {
      print('⏭️ Пропуск отправки счёта: имя не задано');
      return;
    }

    final token = _session.accessToken;
    if (token == null) {
      print('⏭️ Пропуск отправки счёта: токен отсутствует');
      return;
    }

    final installDate = await InstallDateManager.getInstallDate();
    final score =
        SobrietyProgressCalculator.calculateProgressDays(daysData, installDate);

    try {
      final response = await _api.updateMyScore(token: token, score: score);
      print('✅ Счёт отправлен: ${response.score} для ${response.username}');
    } catch (e) {
      print('❌ Ошибка отправки счёта: $e');
    }
  }
}
