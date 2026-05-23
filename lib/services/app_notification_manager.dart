import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/achievement_manager.dart';

// MARK: - Типы уведомлений
abstract class AppNotificationType {}

class AchievementNotification extends AppNotificationType {
  final String title;
  final String description;
  final String imageAsset;
  final bool isDrinking;

  AchievementNotification({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.isDrinking,
  });
}

class NewFollowerNotification extends AppNotificationType {
  final String username;
  final int userId;
  final String? avatarUrl;

  NewFollowerNotification({
    required this.username,
    required this.userId,
    this.avatarUrl,
  });
}

// MARK: - Элемент очереди
class AppNotificationItem {
  final String id;
  final AppNotificationType type;

  AppNotificationItem({required this.type})
      : id = DateTime.now().microsecondsSinceEpoch.toString();
}

// MARK: - Менеджер уведомлений
class AppNotificationManager extends ChangeNotifier {
  static final AppNotificationManager shared = AppNotificationManager._internal();
  AppNotificationManager._internal();

  final List<AppNotificationItem> _queue = [];
  AppNotificationItem? _currentNotification;

  AppNotificationItem? get currentNotification => _currentNotification;

  void enqueue(AppNotificationItem item) {
    _queue.add(item);
    if (_currentNotification == null) {
      _showNext();
    }
  }

  void dismiss() {
    _currentNotification = null;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 400), _showNext);
  }

  void _showNext() {
    if (_queue.isEmpty) return;
    _currentNotification = _queue.removeAt(0);
    notifyListeners();
  }

  // MARK: - Проверка новых подписчиков
  Future<void> checkNewFollowers() async {
    final session = SessionManager();
    await session.init();
    if (session.sessionType != SessionType.authenticated) return;
    final token = session.accessToken;
    if (token == null) return;

    const knownKey = 'knownFollowerIds';
    final prefs = await SharedPreferences.getInstance();
    final rawIds = prefs.getStringList(knownKey) ?? [];
    final knownIds = rawIds.map((e) => int.tryParse(e) ?? -1).toSet();

    try {
      final response = await UserAPIService().getMyFollowers(token);
      final currentIds = response.items.map((f) => f.userId).toSet();

      await prefs.setStringList(knownKey, currentIds.map((e) => e.toString()).toList());

      // Первый запуск — просто запоминаем
      if (knownIds.isEmpty) return;

      final newFollowers = response.items.where((f) => !knownIds.contains(f.userId)).toList();

      for (final follower in newFollowers) {
        enqueue(AppNotificationItem(
          type: NewFollowerNotification(
            username: follower.username,
            userId: follower.userId,
            avatarUrl: follower.avatarUrl,
          ),
        ));
      }
    } catch (e) {
      print('❌ checkNewFollowers error: $e');
    }
  }

  // MARK: - Проверка новых ачивок
  Future<void> checkNewAchievements() async {
    const notifiedKey = 'notifiedAchievementIds';
    final prefs = await SharedPreferences.getInstance();
    final notifiedIds = prefs.getStringList(notifiedKey)?.toSet() ?? {};

    final manager = AchievementManager();
    await manager.loadAchievements();
    final allAchievements = manager.achievements;
    final unlocked = allAchievements.where((a) => a.isUnlocked).toList();

    // Первый запуск — запоминаем без уведомлений
    if (notifiedIds.isEmpty) {
      final ids = unlocked.map((a) => a.id).toList();
      await prefs.setStringList(notifiedKey, ids.isEmpty ? ['__init__'] : ids);
      return;
    }

    final newlyUnlocked = unlocked.where((a) => !notifiedIds.contains(a.id)).toList();

    for (final achievement in newlyUnlocked) {
      notifiedIds.add(achievement.id);
      final isDrinking = achievement.type == AchievementType.drinkingStreak ||
          (achievement.type == AchievementType.milestone &&
              achievement.id.contains('negative'));

      enqueue(AppNotificationItem(
        type: AchievementNotification(
          title: achievement.titleKey,
          description: achievement.descriptionKey,
          imageAsset: achievement.imageAsset,
          isDrinking: isDrinking,
        ),
      ));
    }

    await prefs.setStringList(notifiedKey, notifiedIds.toList());
  }
}