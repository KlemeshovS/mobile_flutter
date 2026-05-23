class FollowModel {
  final int userId;
  final String username;
  final String? avatarUrl;
  final bool isMutual;
  final String? createdAt;

  FollowModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.isMutual,
    this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) => FollowModel(
    userId: json['userId'],
    username: json['username'],
    avatarUrl: json['avatarUrl'] as String?,
    isMutual: json['isMutual'] ?? false,
    createdAt: json['createdAt'] as String?,
  );
}

class FollowListResponse {
  final List<FollowModel> items;
  final int total;

  FollowListResponse({required this.items, required this.total});

  factory FollowListResponse.fromJson(Map<String, dynamic> json) => FollowListResponse(
    items: (json['items'] as List).map((e) => FollowModel.fromJson(e)).toList(),
    total: json['total'],
  );
}