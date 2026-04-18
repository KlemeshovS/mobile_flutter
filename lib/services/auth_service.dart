import 'package:google_sign_in/google_sign_in.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wobbly/services/yandex_native_auth.dart';


class AuthService {
  //WEB CLIENT ID
  static const String _webClientId = "293241377764-4ipsi5achpqcsku9o6ug7vrh0shv60v8.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );
  final UserAPIService _api = UserAPIService();
  final SessionManager _session = SessionManager();

  Future<bool> signInWithGoogle() async {
    try {
      // Инициализируем SessionManager, чтобы получить текущий токен (возможно guest)
      await _session.init();
      final currentToken = _session.accessToken; // может быть null, если нет сессии

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('No idToken from Google');

      // Передаём текущий токен как guestAccessToken (если есть)
      final authResponse = await _api.authWithGoogle(idToken, guestAccessToken: currentToken);
      await _session.setAuthenticatedSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken!,
        userId: authResponse.userId,
      );

      // Загружаем профиль пользователя
      final session = await _api.getSession(authResponse.accessToken);
      final prefs = await SharedPreferences.getInstance();
      if (session.username != null && session.username!.isNotEmpty) {
        await prefs.setString('userName', session.username!);
      } else {
        await prefs.remove('userName');
      }
      await prefs.setBool('userParticipateInRating', session.participateInRating);

      // Если пользователь участвует в рейтингах, нужно отправить его текущий счёт
      if (session.participateInRating) {
        print('User participates in ratings, score will be sent later');
      }

      return true;
    } catch (e) {
      print('Google Sign-In error: $e');
      return false;
    }
  }

  Future<bool> signInWithYandex() async {
    try {
      await _session.init();
      final currentToken = _session.accessToken;

      final yandexToken = await YandexNativeAuth.signIn();
      if (yandexToken == null) return false;

      final authResponse = await _api.authWithYandex(yandexToken, guestAccessToken: currentToken);

      await _session.setAuthenticatedSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken!,
        userId: authResponse.userId,
      );

      final session = await _api.getSession(authResponse.accessToken);
      final prefs = await SharedPreferences.getInstance();
      if (session.username != null && session.username!.isNotEmpty) {
        await prefs.setString('userName', session.username!);
      } else {
        await prefs.remove('userName');
      }
      await prefs.setBool('userParticipateInRating', session.participateInRating);

      return true;
    } catch (e) {
      print('signInWithYandex error: $e');
      return false;
    }
  }

  Future<bool> refreshSession() async {
    final refreshToken = _session.refreshToken;
    if (refreshToken == null) return false;
    try {
      final newTokens = await _api.refreshTokens(refreshToken);
      // Обновляем оба токена
      await _session.updateTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken!,
      );
      return true;
    } catch (e) {
      print('Refresh failed: $e');
      await _session.setGuestSession();
      return false;
    }
  }

// auth_service.dart
  Future<void> signOut() async {
    // 1. Если пользователь авторизован и участвует в рейтингах,
    // сначала отключаем участие на сервере
    if (_session.sessionType == SessionType.authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final participate = prefs.getBool('userParticipateInRating') ?? false;
      if (participate) {
        try {
          await _api.updateMyRating(
            token: _session.accessToken!,
            participateInRating: false,
          );
          print('✅ Участие в рейтингах отключено перед выходом');
        } catch (e) {
          print('⚠️ Не удалось отключить рейтинг перед выходом: $e');
        }
      }
    }

    // 2. Стандартный логаут на сервере
    final token = _session.accessToken;
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (e) {
        print('Logout API error: $e');
      }
    }

    // 3. Локальный выход
    await _googleSignIn.signOut();
    await YandexNativeAuth.signOut();
    await _session.setGuestSession();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.setBool('userParticipateInRating', false);
  }
}