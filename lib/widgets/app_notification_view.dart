import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wobbly/services/app_notification_manager.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/utils/localization.dart';

class AppNotificationView extends StatefulWidget {
  final AppNotificationItem item;
  final VoidCallback onDismiss;
  final Function(int userId, String username, String? avatarUrl)? onFollowerTap;

  const AppNotificationView({
    super.key,
    required this.item,
    required this.onDismiss,
    this.onFollowerTap,
  });

  @override
  State<AppNotificationView> createState() => _AppNotificationViewState();
}

class _AppNotificationViewState extends State<AppNotificationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 100) _dismiss();
            },
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final type = widget.item.type;
    if (type is AchievementNotification) {
      return _buildAchievementCard(context, type);
    } else if (type is NewFollowerNotification) {
      return _buildFollowerCard(context, type);
    }
    return const SizedBox.shrink();
  }

  Widget _buildAchievementCard(BuildContext context, AchievementNotification n) {
    final loc = AppLocalizations.of(context);
    final descColor = n.isDrinking ? const Color(0xFFFF6B6B) : const Color(0xFFC7FF00);

    return Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B55), Color(0xFF3E3B6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7FF00).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              n.imageAsset,
              width: 44,
              height: 44,
              errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.white, size: 44),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('notification_achievement_title'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate(n.title),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate(n.description),
                    style: TextStyle(fontSize: 13, color: descColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
    );
  }

  Widget _buildFollowerCard(BuildContext context, NewFollowerNotification n) {
    final loc = AppLocalizations.of(context);
    final fullUrl = UserAPIService.fullAvatarUrl(n.avatarUrl);

    return Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
        widget.onFollowerTap?.call(n.userId, n.username, n.avatarUrl);
        _dismiss();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B55), Color(0xFF3E3B6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            fullUrl != null
                ? CachedNetworkImage(
              imageUrl: fullUrl,
              imageBuilder: (_, imageProvider) => CircleAvatar(
                radius: 22,
                backgroundImage: imageProvider,
              ),
              placeholder: (_, __) => _defaultAvatar(),
              errorWidget: (_, __, ___) => _defaultAvatar(),
            )
                : _defaultAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('notification_new_follower_title'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    n.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC7FF00),
                    ),
                  ),
                  Text(
                    loc.translate('notification_new_follower_subtitle'),
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
        ),
    );
  }

  Widget _defaultAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.4),
      child: const Icon(Icons.person, color: Colors.white, size: 22),
    );
  }
}