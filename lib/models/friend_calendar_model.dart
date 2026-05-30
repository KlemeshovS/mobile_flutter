class FriendCalendarResponse {
  final Map<String, int> days;
  final String updatedAt;

  static const String epoch = '1970-01-01T00:00:00Z';

  bool get isEmpty => updatedAt == epoch || days.isEmpty;

  const FriendCalendarResponse({required this.days, required this.updatedAt});

  factory FriendCalendarResponse.fromJson(Map<String, dynamic> json) {
    return FriendCalendarResponse(
      days: Map<String, int>.from(json['days'] as Map),
      updatedAt: json['updatedAt'] as String,
    );
  }
}