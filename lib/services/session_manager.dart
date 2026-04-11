import 'package:shared_preferences/shared_preferences.dart';

enum SessionType { guest, authenticated }

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _sessionTypeKey = 'sessionType';

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  SessionType _sessionType = SessionType.guest;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _userId = prefs.getInt(_userIdKey);
    final typeStr = prefs.getString(_sessionTypeKey);
    _sessionType = typeStr == 'authenticated' ? SessionType.authenticated : SessionType.guest;
    _isInitialized = true;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  SessionType get sessionType => _sessionType;

  // Новая полная сессия (для Google-входа)
  Future<void> setAuthenticatedSession({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _sessionType = SessionType.authenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_sessionTypeKey, 'authenticated');
  }

  // Гостевая сессия (очищает всё)
  Future<void> setGuestSession() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _sessionType = SessionType.guest;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.setString(_sessionTypeKey, 'guest');
  }

  // Обновить только accessToken (после refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, newAccessToken);
  }

  // ---- СОВМЕСТИМОСТЬ СО СТАРЫМ КОДОМ (анонимная авторизация) ----
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    _refreshToken = null;
    _userId = null;
    _sessionType = SessionType.guest;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.setString(_sessionTypeKey, 'guest');
  }

  // Новый метод
  Future<void> updateTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> setUserId(int id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  Future<void> clear() async => setGuestSession();
}