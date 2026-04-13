// lib/utils/language_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager with ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('ru'); // По умолчанию русский

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  String get currentLanguageName =>
      _currentLocale.languageCode == 'en' ? 'English' : 'Русский';

  String get oppositeLanguageName =>
      _currentLocale.languageCode == 'en' ? 'Русский' : 'English';

  String get oppositeLanguageCode =>
      _currentLocale.languageCode == 'en' ? 'ru' : 'en';

  LanguageManager() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    } else {
      // Если язык не сохранен, используем системный
      final systemLocale = WidgetsBinding.instance.window.locale;
      final systemLanguage = systemLocale.languageCode;

      if (systemLanguage == 'ru' || systemLanguage == 'en') {
        _currentLocale = Locale(systemLanguage);
      } else {
        _currentLocale = const Locale('ru'); // По умолчанию русский
      }
      notifyListeners();
    }
  }

  Future<void> switchLanguage(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'ru') {
      _currentLocale = Locale(languageCode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguage = _currentLocale.languageCode == 'en' ? 'ru' : 'en';
    await switchLanguage(newLanguage);
  }
}
