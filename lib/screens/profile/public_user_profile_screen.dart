import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wobbly/models/follow_models.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/friend_calendar_model.dart';
import 'package:wobbly/widgets/friend_calendar_grid.dart';
import 'package:intl/intl.dart';
import 'package:wobbly/models/api_models.dart';

class PublicUserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String? avatarUrl;
  final VoidCallback? onClose;
  final int? score;

  const PublicUserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.onClose,
    this.score,
  });

  factory PublicUserProfileScreen.fromFollowModel(FollowModel model) {
    return PublicUserProfileScreen(
      userId: model.userId,
      username: model.username,
      avatarUrl: model.avatarUrl,
    );
  }

  @override
  State<PublicUserProfileScreen> createState() => _PublicUserProfileScreenState();
}

enum _FollowStatus { loading, notFollowing, following, mutual }

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {

  int? _loadedScore;

  _FollowStatus _status = _FollowStatus.loading;
  bool _isActionLoading = false;

  FriendCalendarResponse? _friendCalendar;
  bool _isLoadingCalendar = false;
  bool _calendarNotFriends = false;

  Future<void> _loadActualScore() async {
    try {
      final top = await UserAPIService().fetchTop100();
      final found = top.firstWhere(
            (i) => i.userId == widget.userId,
        orElse: () => LeaderboardItem(userId: -1, username: '', score: 0, avatarUrl: null),
      );
      if (found.userId != -1) {
        if (mounted) setState(() => _loadedScore = found.score);
        return;
      }

      final bottom = await UserAPIService().fetchBottom100();
      final foundBottom = bottom.firstWhere(
            (i) => i.userId == widget.userId,
        orElse: () => LeaderboardItem(userId: -1, username: '', score: 0, avatarUrl: null),
      );
      if (foundBottom.userId != -1) {
        if (mounted) setState(() => _loadedScore = foundBottom.score);
      }
    } catch (e) {
      print('❌ Ошибка загрузки очков: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
    _loadFriendCalendar();
    _loadActualScore();
  }

  Future<void> _loadFollowStatus() async {
    final token = SessionManager().accessToken;
    if (token == null) {
      setState(() => _status = _FollowStatus.notFollowing);
      return;
    }
    try {
      final follows = await UserAPIService().getMyFollows(token);
      final followers = await UserAPIService().getMyFollowers(token);

      final iFollowThem = follows.items.any((f) => f.userId == widget.userId);
      final theyFollowMe = followers.items.any((f) => f.userId == widget.userId);

      setState(() {
        if (iFollowThem && theyFollowMe) {
          _status = _FollowStatus.mutual;
        } else if (iFollowThem) {
          _status = _FollowStatus.following;
        } else {
          _status = _FollowStatus.notFollowing;
        }
      });
    } catch (e) {
      setState(() => _status = _FollowStatus.notFollowing);
    }
  }

  Future<void> _loadFriendCalendar() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isLoadingCalendar = true);
    try {
      final cal = await UserAPIService().getFriendCalendar(token, widget.userId);
      setState(() {
        _friendCalendar = cal;
        _calendarNotFriends = false;
      });
    } catch (e) {
      if (e == UserAPIError.notFriends) {
        setState(() => _calendarNotFriends = true);
      }
    } finally {
      setState(() => _isLoadingCalendar = false);
    }
  }

  Future<void> _follow() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isActionLoading = true);
    try {
      await UserAPIService().follow(token, widget.username);
      await _loadFollowStatus();
      await _loadFriendCalendar();
    } catch (e) {
      _showError('Ошибка при подписке');
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  Future<void> _unfollow() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isActionLoading = true);
    try {
      await UserAPIService().unfollow(token, widget.userId);
      await _loadFollowStatus();
      setState(() {
        _friendCalendar = null;
        _calendarNotFriends = true;
      });
      await _loadFriendCalendar();
    } catch (e) {
      _showError('Ошибка при отписке');
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final fullUrl = UserAPIService.fullAvatarUrl(widget.avatarUrl);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Полоска
              Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Крестик справа
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: widget.onClose ?? () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
            // Аватар
            fullUrl != null
                ? CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(
                fullUrl,
                headers: UserAPIService.stagingHeaders,
              ),
              onBackgroundImageError: (_, __) {},
            )
                : _defaultAvatar(),

            const SizedBox(height: 16),

            // Очки и юзернейм
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC7FF00),
                    ),
                  ),
                  const Spacer(),
                  if (_loadedScore != null || widget.score != null)
                    Text(
                      '${(_loadedScore ?? widget.score ?? 0).abs()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (_loadedScore ?? widget.score ?? 0) >= 0
                            ? Colors.greenAccent
                            : Colors.pinkAccent,
                      ),
                    ),      ],
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка подписки
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFollowButton(loc),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarSection(loc),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCalendarSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('friend_calendar_title'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingCalendar)
          const Center(
            child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
          )
        else if (_calendarNotFriends)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline,
                    color: Colors.white.withOpacity(0.35), size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.translate('friend_calendar_mutual_only'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_friendCalendar != null && !_friendCalendar!.isEmpty)
            FriendCalendarGrid(calendar: _friendCalendar!)
          else if (_friendCalendar != null && _friendCalendar!.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    loc.translate('friend_calendar_empty'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildFollowButton(AppLocalizations loc) {
    if (_status == _FollowStatus.loading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_status == _FollowStatus.notFollowing) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isActionLoading ? null : _follow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF4B3A91)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isActionLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(
                loc.translate('follow_button'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final statusText = _status == _FollowStatus.mutual
        ? loc.translate('follow_status_mutual')
        : loc.translate('follow_status_following');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          PopupMenuButton<String>(
            color: const Color(0xFF1E1C3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            elevation: 8,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white70, size: 18),
            ),
            onSelected: (value) {
              if (value == 'unfollow') _unfollow();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'unfollow',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_remove, color: Colors.redAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loc.translate('unfollow_button'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return CircleAvatar(
      radius: 48,
      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.3),
      child: const Icon(Icons.person, size: 48, color: Colors.white),
    );
  }
}