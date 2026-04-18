// Ответ авторизации (anonymous, Google, Yandex, refresh)
class AnonymousAuthResponse {
  final int userId;
  final String accessToken;
  final String? refreshToken; // null для anonymous-сессий
  final String tokenType;

  AnonymousAuthResponse({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
  });

  factory AnonymousAuthResponse.fromJson(Map<String, dynamic> json) => AnonymousAuthResponse(
    userId: json['userId'],
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'] as String?,
    tokenType: json['tokenType'],
  );
}

// Профиль пользователя (ответ /me)
class MeResponse {
  final int id;
  final String? username;
  final bool participateInRating;
  final String? avatarUrl;

  MeResponse({required this.id, this.username, required this.participateInRating, this.avatarUrl});

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
    id: json['id'],
    username: json['username'],
    participateInRating: json['participateInRating'],
    avatarUrl: json['avatarUrl'] as String?,
  );
}

// Ответ /auth/session (отдельная модель)
class SessionResponse {
  final int userId;
  final String? username;
  final bool participateInRating;
  final String sessionType;   // "guest" или "authenticated"
  final String? provider;     // например "google", "yandex" или null
  final String? avatarUrl;

  SessionResponse({
    required this.userId,
    this.username,
    required this.participateInRating,
    required this.sessionType,
    this.provider,
    this.avatarUrl,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) => SessionResponse(
    userId: json['userId'],
    username: json['username'],
    participateInRating: json['participateInRating'] ?? false,
    sessionType: json['sessionType'] ?? 'guest',
    provider: json['provider'],
    avatarUrl: json['avatarUrl'] as String?,
  );
}

// Ответ на отправку счёта
class ScoreResponse {
  final String username;
  final int score;

  ScoreResponse({required this.username, required this.score});

  factory ScoreResponse.fromJson(Map<String, dynamic> json) => ScoreResponse(
    username: json['username'],
    score: json['score'],
  );
}

// Элемент лидерборда
class LeaderboardItem {
  final String username;
  final int score;

  LeaderboardItem({required this.username, required this.score});

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) => LeaderboardItem(
    username: json['username'],
    score: json['score'],
  );
}

// Привязанный identity provider
class LinkedIdentityItem {
  final String provider;
  final String? providerEmail;
  final bool providerEmailVerified;

  LinkedIdentityItem({
    required this.provider,
    this.providerEmail,
    required this.providerEmailVerified,
  });

  factory LinkedIdentityItem.fromJson(Map<String, dynamic> json) => LinkedIdentityItem(
    provider: json['provider'],
    providerEmail: json['providerEmail'],
    providerEmailVerified: json['providerEmailVerified'] ?? false,
  );
}

class LinkedIdentityListResponse {
  final List<LinkedIdentityItem> items;

  LinkedIdentityListResponse({required this.items});

  factory LinkedIdentityListResponse.fromJson(Map<String, dynamic> json) => LinkedIdentityListResponse(
    items: (json['items'] as List).map((e) => LinkedIdentityItem.fromJson(e)).toList(),
  );
}

// Ответ лидерборда
class LeaderboardResponse {
  final List<LeaderboardItem> items;
  final int total;

  LeaderboardResponse({required this.items, required this.total});

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) => LeaderboardResponse(
    items: (json['items'] as List).map((e) => LeaderboardItem.fromJson(e)).toList(),
    total: json['total'],
  );
}