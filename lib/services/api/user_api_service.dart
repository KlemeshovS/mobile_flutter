import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wobbly/models/api_models.dart';
import 'package:wobbly/services/session_manager.dart';

enum UserAPIError {
  usernameAlreadyExists,
  usernameTooShort,
  usernameTooLong,
  invalidParticipateInRating,
  userNotFound,
  registerFailed,
  updateScoreFailed,
  networkError,
  invalidResponse,
  serverError,
  tooManyRequests,
  invalidPayload,
  unauthorized,
  missingToken,
  missingAuthorizationHeader,
  invalidToken,
  rateLimitExceeded,
  scoreTooLow,
  usernameInvalidCharacters,
  validationError,
  invalidRefreshToken,
  googleAuthInvalid,
  appleAuthInvalid,
  yandexAuthInvalid,
  authRequiredForRating,
  authRequiredForUsername,
  guestCannotEnableRating,
  usernameRequiredForRating,
  ratingDisabledForScore,
  identityAlreadyLinked,
  providerAlreadyLinked,
  providerNotLinked,
  lastIdentityRequired,
  authRequiredForProviderManagement,
}

class UserAPIService {
  // Флаг переключения окружения: true = staging, false = production
  static const bool _isStaging = false;

  static String get _baseUrl => _isStaging
      ? 'https://staging-api.wobbly.site/api/v1'
      : 'https://api.wobbly.site/api/v1';

  static final UserAPIService _instance = UserAPIService._internal();
  factory UserAPIService() => _instance;
  UserAPIService._internal();
//привет
  final SessionManager _session = SessionManager();

  Map<String, String> _buildHeaders(Map<String, String>? extra) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Client-Platform': Platform.isIOS ? 'ios' : 'android',
      if (_isStaging) 'X-Staging-Key': '39rDOkCgTc5TfeyTsRebbSzvWycSRluR',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // Анонимная авторизация
  Future<AnonymousAuthResponse> anonymousAuth() async {
    print('🔑 [API] anonymousAuth запрос...');

    final url = Uri.parse('$_baseUrl/auth/anonymous');
    final response = await http.post(
      url,
      headers: _buildHeaders(null),
      body: json.encode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AnonymousAuthResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Получение профиля
  Future<MeResponse> getMyProfile(String token) async {
    final url = Uri.parse('$_baseUrl/me');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return MeResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UserAPIError.unauthorized;
    } else {
      throw await _handleError(response);
    }
  }

  /// Обновляет только флаг участия в рейтинге (не трогает имя).
  Future<MeResponse> updateMyRating({
    required String token,
    required bool participateInRating,
  }) async {
    print('📤 [API] updateMyRating: participate=$participateInRating');

    final url = Uri.parse('$_baseUrl/me/rating');
    final body = {'participateInRating': participateInRating};
    final headers = _buildHeaders({
      'Authorization': 'Bearer $token',
    });
    final response = await http.patch(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return MeResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Обновление профиля
  Future<MeResponse> updateMyProfile({

    required String token,
    String? username,
    required bool participateInRating,
  }) async {
    print('📤 [API] updateMyProfile: username=$username, participate=$participateInRating');

    final url = Uri.parse('$_baseUrl/me/profile');
    final body = {
      if (username != null) 'username': username,
      'participateInRating': participateInRating,
    };
    final headers = _buildHeaders({
      'Authorization': 'Bearer $token',
    });
    final response = await http.patch(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return MeResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Отправка счёта
  Future<ScoreResponse> updateMyScore({required String token, required int score}) async {
    final url = Uri.parse('$_baseUrl/me/score');
    final body = {'score': score};
    final headers = _buildHeaders({
      'Authorization': 'Bearer $token',
    });
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return ScoreResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UserAPIError.unauthorized;
    } else if (response.statusCode == 422) {
      throw UserAPIError.invalidPayload;
    } else if (response.statusCode == 429) {
      throw UserAPIError.tooManyRequests;
    } else {
      throw await _handleError(response);
    }
  }

  // Топ-100
  Future<List<LeaderboardItem>> fetchTop100() async {
    final url = Uri.parse('$_baseUrl/leaderboard/top?limit=100');
    final response = await http.get(url, headers: _buildHeaders(null));

    if (response.statusCode == 200) {
      final data = LeaderboardResponse.fromJson(json.decode(response.body));
      return data.items;
    } else {
      throw await _handleError(response);
    }
  }

  // Дно-100
  Future<List<LeaderboardItem>> fetchBottom100() async {
    final url = Uri.parse('$_baseUrl/leaderboard/bottom?limit=100');
    final response = await http.get(url, headers: _buildHeaders(null));

    if (response.statusCode == 200) {
      final data = LeaderboardResponse.fromJson(json.decode(response.body));
      return data.items;
    } else {
      throw await _handleError(response);
    }
  }

  // Аутентификация через Google
  Future<AnonymousAuthResponse> authWithGoogle(String idToken, {String? guestAccessToken}) async {
    final url = Uri.parse('$_baseUrl/auth/google');
    final body = {'idToken': idToken};
    // Формируем заголовки: если передан guestAccessToken, добавляем Authorization
    final headers = _buildHeaders(
      guestAccessToken != null ? {'Authorization': 'Bearer $guestAccessToken'} : null,
    );
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AnonymousAuthResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Получение текущей сессии (проверка валидности токена)
  Future<SessionResponse> getSession(String token) async {
    final url = Uri.parse('$_baseUrl/auth/session');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return SessionResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UserAPIError.invalidToken;
    } else {
      throw await _handleError(response);
    }
  }

  // Обновление токенов
  Future<AnonymousAuthResponse> refreshTokens(String refreshToken) async {
    final url = Uri.parse('$_baseUrl/auth/refresh');
    final body = {'refreshToken': refreshToken};
    final response = await http.post(
      url,
      headers: _buildHeaders(null),
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return AnonymousAuthResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UserAPIError.invalidRefreshToken;
    } else {
      throw await _handleError(response);
    }
  }

  // Список привязанных providers
  Future<LinkedIdentityListResponse> getProviders(String token) async {
    final url = Uri.parse('$_baseUrl/auth/providers');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return LinkedIdentityListResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Привязка Google к текущему аккаунту
  Future<LinkedIdentityListResponse> linkGoogle(String token, String idToken) async {
    final url = Uri.parse('$_baseUrl/auth/providers/google/link');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({'idToken': idToken}),
    );
    if (response.statusCode == 200) {
      return LinkedIdentityListResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Отвязка provider
  Future<LinkedIdentityListResponse> unlinkProvider(String token, String provider) async {
    final url = Uri.parse('$_baseUrl/auth/providers/$provider');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      return LinkedIdentityListResponse.fromJson(json.decode(response.body));
    } else {
      throw await _handleError(response);
    }
  }

  // Выход
  Future<void> logout(String token) async {
    final url = Uri.parse('$_baseUrl/auth/logout');
    final headers = _buildHeaders({'Authorization': 'Bearer $token'});
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      throw await _handleError(response);
    }
  }

  Future<UserAPIError> _handleError(http.Response response) async {
    print('📥 _handleError: статус ${response.statusCode}, тело: ${response.body}');
    // Пытаемся распарсить тело ответа
    try {
      final body = json.decode(response.body);
      final code = body['code'] as String?;
      if (code != null) {
        switch (code) {
          case 'MISSING_AUTHORIZATION_HEADER':
            return UserAPIError.missingAuthorizationHeader;
          case 'INVALID_TOKEN':
            return UserAPIError.invalidToken;
          case 'USERNAME_ALREADY_EXISTS':
            return UserAPIError.usernameAlreadyExists;
          case 'USERNAME_TOO_SHORT':
            return UserAPIError.usernameTooShort;
          case 'USERNAME_TOO_LONG':
            return UserAPIError.usernameTooLong;
          case 'INVALID_PARTICIPATE_IN_RATING':
            return UserAPIError.invalidParticipateInRating;
          case 'RATE_LIMIT_EXCEEDED':
            return UserAPIError.rateLimitExceeded;
          case 'SCORE_TOO_LOW':
            return UserAPIError.scoreTooLow;
          case 'INVALID_USERNAME':
          case 'USERNAME_INVALID_CHARACTERS':
            return UserAPIError.usernameInvalidCharacters;
          case 'VALIDATION_ERROR':
            return UserAPIError.validationError;
          case 'INVALID_REFRESH_TOKEN':
            return UserAPIError.invalidRefreshToken;
          case 'GOOGLE_AUTH_INVALID':
            return UserAPIError.googleAuthInvalid;
          case 'APPLE_AUTH_INVALID':
            return UserAPIError.appleAuthInvalid;
          case 'YANDEX_AUTH_INVALID':
            return UserAPIError.yandexAuthInvalid;
          case 'AUTH_REQUIRED_FOR_RATING':
            return UserAPIError.authRequiredForRating;
          case 'AUTH_REQUIRED_FOR_USERNAME':
            return UserAPIError.authRequiredForUsername;
          case 'GUEST_CANNOT_ENABLE_RATING':
            return UserAPIError.guestCannotEnableRating;
          case 'USERNAME_REQUIRED_FOR_RATING':
            return UserAPIError.usernameRequiredForRating;
          case 'RATING_DISABLED_FOR_SCORE':
            return UserAPIError.ratingDisabledForScore;
          case 'IDENTITY_ALREADY_LINKED':
            return UserAPIError.identityAlreadyLinked;
          case 'PROVIDER_ALREADY_LINKED':
            return UserAPIError.providerAlreadyLinked;
          case 'PROVIDER_NOT_LINKED':
            return UserAPIError.providerNotLinked;
          case 'LAST_IDENTITY_REQUIRED':
            return UserAPIError.lastIdentityRequired;
          case 'AUTH_REQUIRED_FOR_PROVIDER_MANAGEMENT':
            return UserAPIError.authRequiredForProviderManagement;
          default:
            return UserAPIError.serverError;
        }
      }
    } catch (_) {
      // Если не удалось распарсить, используем старую логику по кодам
    }

    switch (response.statusCode) {
      case 400:
      case 422:
        return UserAPIError.invalidPayload;
      case 401:
        return UserAPIError.unauthorized;
      case 404:
        return UserAPIError.userNotFound;
      case 409:
        return UserAPIError.usernameAlreadyExists;
      case 429:
        return UserAPIError.tooManyRequests;
      default:
        print('❌ Неизвестная ошибка API: статус ${response.statusCode}');
        print('📦 Тело ответа: ${response.body}');
        return UserAPIError.serverError;
    }
  }
}