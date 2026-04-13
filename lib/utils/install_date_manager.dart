// lib/utils/install_date_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class InstallDateManager {
  static const String _installDateKey = 'install_date';

  static Future<DateTime> getInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    final installDateString = prefs.getString(_installDateKey);

    if (installDateString == null) {
      // Первая установка - сохраняем текущую дату
      final now = DateTime.now();
      await prefs.setString(_installDateKey, now.toIso8601String());
      return now;
    }

    return DateTime.parse(installDateString);
  }
}
