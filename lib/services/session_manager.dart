import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _tokenKey = 'accessToken';
  static const String _userIdKey = 'userId';

  String? _accessToken;
  int? _userId;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    _userId = prefs.getInt(_userIdKey);
    _isInitialized = true;
  }

  String? get accessToken => _accessToken;
  int? get userId => _userId;

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> setUserId(int id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  Future<void> clear() async {
    _accessToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }
}