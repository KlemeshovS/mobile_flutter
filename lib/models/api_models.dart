// Анонимная авторизация
class AnonymousAuthResponse {
  final int userId;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AnonymousAuthResponse({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AnonymousAuthResponse.fromJson(Map<String, dynamic> json) => AnonymousAuthResponse(
    userId: json['userId'],
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'] ?? '',  // если бэкенд пока не отдаёт – пустая строка
    tokenType: json['tokenType'],
  );
}

// Профиль пользователя (ответ /me)
class MeResponse {
  final int id;
  final String? username;
  final bool participateInRating;

  MeResponse({required this.id, this.username, required this.participateInRating});

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
    id: json['id'],
    username: json['username'],
    participateInRating: json['participateInRating'],
  );
}

// Ответ /auth/session (отдельная модель)
class SessionResponse {
  final int userId;
  final String? username;
  final bool participateInRating;
  final String sessionType;   // "guest" или "authenticated"
  final String? provider;     // например "google", "apple", "yandex" или null

  SessionResponse({
    required this.userId,
    this.username,
    required this.participateInRating,
    required this.sessionType,
    this.provider,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) => SessionResponse(
    userId: json['userId'],
    username: json['username'],
    participateInRating: json['participateInRating'] ?? false,
    sessionType: json['sessionType'] ?? 'guest',
    provider: json['provider'],
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