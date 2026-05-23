import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/api_models.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/services/score_sync_manager.dart';
import 'package:wobbly/screens/profile/user_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wobbly/screens/profile/public_user_profile_screen.dart';

class RatingsScreen extends StatefulWidget {
  final Map<String, DayRecord> daysData;

  const RatingsScreen({super.key, required this.daysData});

  @override
  State<RatingsScreen> createState() => RatingsScreenState();
}

class RatingsScreenState extends State<RatingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LeaderboardItem> _topItems = [];
  List<LeaderboardItem> _bottomItems = [];
  bool _isLoading = false;
  String? _error;
  bool _isEnsuringToken = false;
  bool _isModalOpen = false;
  bool _isRefreshing = false;
  bool _participate = true;
  bool _hasShownNotParticipatingPopup = false;
  String? _myUsername;
  bool _showFriendsOnly = false;
  Set<String> _myFollowUsernames = {};
  bool _isLoadingFollows = false;
  SessionType _sessionType = SessionType.guest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _loadData(context);
    });
    _loadSessionType();
    _loadFriendsOnlyPref();
  }

  Future<void> _loadSessionType() async {
    await SessionManager().init();
    setState(() {
      _sessionType = SessionManager().sessionType;
    });
  }

  Future<void> _loadFriendsOnlyPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showFriendsOnly = prefs.getBool('ratingsShowFriendsOnly') ?? false;
    });
  }

  Future<void> _loadMyFollows() async {
    final token = SessionManager().accessToken;
    if (token == null) return;
    setState(() => _isLoadingFollows = true);
    try {
      final response = await UserAPIService().getMyFollows(token);
      setState(() {
        _myFollowUsernames = response.items.map((f) => f.username).toSet();
      });
    } catch (e) {
      print('❌ loadMyFollows error: $e');
    } finally {
      setState(() => _isLoadingFollows = false);
    }
  }

  List<LeaderboardItem> _filteredItems(List<LeaderboardItem> items) {
    if (!_showFriendsOnly) return items;
    if (_myFollowUsernames.isEmpty) return [];
    return items
        .where((i) => _myFollowUsernames.contains(i.username) || i.username == _myUsername)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    print('🔄 [RatingsScreen] refreshData started');
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      await _loadSessionType();
      await _ensureToken();
      final prefs = await SharedPreferences.getInstance();
      final participate = prefs.getBool('userParticipateInRating') ?? true;
      setState(() {
        _participate = participate;
        _myUsername = prefs.getString('userName');
      });
      if (mounted) await _loadData(context);

      if (mounted && (_sessionType == SessionType.guest || !_participate)) {
        if (!_hasShownNotParticipatingPopup) {
          _hasShownNotParticipatingPopup = true;
          // Показываем с небольшой задержкой, чтобы успел отрисоваться основной экран
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showNotParticipatingPopup();
          });
        }
      } else {
        // Если пользователь участвует, сбрасываем флаг для будущих открытий
        _hasShownNotParticipatingPopup = false;
      }

    } finally {
      _isRefreshing = false;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
    if (mounted && _sessionType == SessionType.authenticated) {
      await _loadMyFollows();
    }
  }

  Future<void> _ensureToken() async {
    print('🔑 [RatingsScreen] _ensureToken called');
    await SessionManager().init();
    if (SessionManager().accessToken == null && !_isEnsuringToken) {
      _isEnsuringToken = true;
      try {
        final auth = await UserAPIService().anonymousAuth();
        await SessionManager().setAccessToken(auth.accessToken);
        await SessionManager().setUserId(auth.userId);
      } catch (e) {
        if (mounted) setState(() => _error = e.toString());
      } finally {
        _isEnsuringToken = false;
      }
    }
  }

  void _showProfileModal() {
    if (_isModalOpen) return;
    _isModalOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileScreen(
        onClose: () {
          _isModalOpen = false;
          Navigator.pop(ctx);
        },
        onRegisterSuccess: (username, userId, participate) {
          _isModalOpen = false;
          refreshData();
        },
        onDisappear: () => _isModalOpen = false,
      ),
    );
  }

  Future<void> _loadData(BuildContext ctx) async {
    print('📊 [RatingsScreen] _loadData started, tabIndex=${_tabController.index}');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_tabController.index == 0) {
        print('🌐 [RatingsScreen] fetchTop100...');
        _topItems = await UserAPIService().fetchTop100();
        print('✅ [RatingsScreen] fetchTop100 done, count=${_topItems.length}');
        for (var item in _topItems.take(3)) {
          print('👤 ${item.username} avatarUrl: ${item.avatarUrl}');
        }
      } else {
        _bottomItems = await UserAPIService().fetchBottom100();
        print('✅ [RatingsScreen] fetchBottom100 done, count=${_bottomItems.length}');
      }
    } catch (e) {
      print('❌ [RatingsScreen] _loadData error: $e');
      String userMessage;
      if (e is SocketException) {
        userMessage = AppLocalizations.of(ctx).translate('no_internet');
      } else {
        userMessage = e.toString();
      }
      if (mounted) setState(() => _error = userMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTopThreePopup(int place, bool isTop, String? avatarUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: _TopThreePopup(place: place, isTop: isTop, avatarUrl: avatarUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final rawItems = _tabController.index == 0 ? _topItems : _bottomItems;
    final items = _filteredItems(rawItems);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Color(0xFF000000), Color(0xFF4B3A91)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomTabBar(loc),
              // Баннер-приглашение, если гость или не участвует
              if (_sessionType == SessionType.guest || !_participate)
                _buildParticipationBanner(loc),
              if (_sessionType == SessionType.authenticated)
                _buildFriendsOnlyToggle(loc),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
              else if (_error != null)
                _buildError(loc)
              else if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, color: Colors.white30, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _showFriendsOnly
                                ? loc.translate('ratings_friends_empty')
                                : loc.translate('no_leaderboard_data'),
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        if (items.length < 3) {
                          return _buildRow(items[index], index + 1);
                        }
                        if (index == 0) {
                          return _buildTopThreeRow(items.sublist(0, 3));
                        } else if (index < 3) {
                          return const SizedBox.shrink();
                        } else {
                          return _buildRow(items[index], index + 1);
                        }
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsOnlyToggle(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Text(
            loc.translate('ratings_friends_only_toggle'),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          if (_isLoadingFollows)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Switch(
              value: _showFriendsOnly,
              onChanged: (value) async {
                setState(() => _showFriendsOnly = value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('ratingsShowFriendsOnly', value);
                if (value && _myFollowUsernames.isEmpty) {
                  await _loadMyFollows();
                }
              },
              activeColor: const Color(0xFF8B5CF6),
            ),
        ],
      ),
    );
  }

  // Баннер с предложением участвовать (показывается над списком)
  Widget _buildParticipationBanner(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loc.translate('rating_not_participating'),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: _showProfileModal,
            child: Text(
              loc.translate('rating_participate_button'),
              style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = (screenWidth - 40) / 2;
    final bool isTop = _tabController.index == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2B55).withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: _tabController.index == 0 ? 0 : tabWidth,
            child: Container(
              width: tabWidth,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2B55).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTop ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isTop ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(0),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      loc.translate('top_100'),
                      style: TextStyle(
                        color: _tabController.index == 0 ? Colors.white : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(1),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      loc.translate('bottom_100'),
                      style: TextStyle(
                        color: _tabController.index == 1 ? Colors.white : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeRow(List<LeaderboardItem> topThree) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(3, (index) {
          final place = index + 1;
          final item = topThree[index];
          final isTop = _tabController.index == 0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (item.username == _myUsername) {
                  _showProfileModal();
                } else {
                  _showPublicProfile(item);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Заменяем _GlowingImage на аватар/кубок
                    _buildTopThreeAvatar(item, place, isTop),
                    const SizedBox(height: 8),
                    Text(
                      item.username,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _GlowingText(
                      text: '${item.score.abs()}',
                      color: item.score >= 0 ? Colors.greenAccent : Colors.pinkAccent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopThreeAvatar(LeaderboardItem item, int place, bool isTop) {
    final fullUrl = UserAPIService.fullAvatarUrl(item.avatarUrl);
    if (fullUrl != null) {
      return CachedNetworkImage(
        imageUrl: fullUrl,
        httpHeaders: UserAPIService.stagingHeaders,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 25,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _GlowingImage(
          imagePath: _cupAsset(place, isTop: isTop),
          place: place,
          isTop: isTop,
          height: 40,
        ),
        errorWidget: (context, url, error) => _GlowingImage(
          imagePath: _cupAsset(place, isTop: isTop),
          place: place,
          isTop: isTop,
          height: 40,
        ),
      );
    } else {
      return _GlowingImage(
        imagePath: _cupAsset(place, isTop: isTop),
        place: place,
        isTop: isTop,
        height: 40,
      );
    }
  }

  String _cupAsset(int place, {required bool isTop}) {
    final prefix = isTop ? 'cup' : 'anti_cup';
    switch (place) {
      case 1:
        return 'assets/ratings/${prefix}_gold.png';
      case 2:
        return 'assets/ratings/${prefix}_silver.png';
      case 3:
        return 'assets/ratings/${prefix}_bronze.png';
      default:
        return '';
    }
  }

  Widget _buildRow(LeaderboardItem item, int position) {
    final isCurrentUser = (item.username == _myUsername);

    final Color highlightColor;
    final Color highlightBgColor;
    if (isCurrentUser) {
      if (item.score >= 0) {
        highlightColor = Colors.green;
        highlightBgColor = Colors.green.withOpacity(0.1);
      } else {
        highlightColor = Colors.red.withOpacity(0.8);
        highlightBgColor = Colors.red.withOpacity(0.01);
      }
    } else {
      highlightColor = Colors.white70;
      highlightBgColor = Colors.white.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: isCurrentUser
          ? _showProfileModal
          : () => _showPublicProfile(item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? highlightBgColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isCurrentUser ? Border.all(color: highlightColor, width: 1.5) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                '$position.',
                style: TextStyle(
                  color: isCurrentUser ? highlightColor : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey.withOpacity(0.2),
                child: item.avatarUrl != null
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: UserAPIService.fullAvatarUrl(item.avatarUrl) ?? '',
                    httpHeaders: UserAPIService.stagingHeaders,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                    errorWidget: (context, url, error) {
                      print('❌ Аватар не загружен: $url ошибка: $error');
                      return const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white,
                      );
                    },
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Text(
                item.username,
                style: TextStyle(
                  color: isCurrentUser ? highlightColor : Colors.white,
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${item.score.abs()}',
              style: TextStyle(
                color: item.score >= 0 ? Colors.greenAccent : Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations loc) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7FF00),
                foregroundColor: Colors.black,
              ),
              child: Text(loc.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublicProfile(LeaderboardItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PublicUserProfileScreen(
        userId: item.userId,
        username: item.username,
        avatarUrl: item.avatarUrl,
        score: item.score,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showNotParticipatingPopup() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D2B55), Color(0xFF3E3B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Полоска для свайпа (как в других bottom sheets)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  loc.translate('rating_not_participating'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);          // закрываем всплывашку
                      _showProfileModal();         // открываем профиль
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      loc.translate('rating_participate_button'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - Статичное свечение для изображения кубка
class _GlowingImage extends StatelessWidget {
  final String imagePath;
  final int place;
  final bool isTop;
  final double height;

  const _GlowingImage({
    required this.imagePath,
    required this.place,
    required this.isTop,
    required this.height,
  });

  Color _glowColor() {
    if (isTop) {
      switch (place) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey;
        case 3:
          return Colors.brown;
        default:
          return Colors.white;
      }
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _glowColor().withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(imagePath, height: height),
    );
  }
}

// MARK: - Статичное свечение для текста счёта
class _GlowingText extends StatelessWidget {
  final String text;
  final Color color;

  const _GlowingText({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: color.withOpacity(0.6), blurRadius: 10),
          Shadow(color: color.withOpacity(0.4), blurRadius: 20),
        ],
      ),
    );
  }
}

// MARK: - Попап для топ-3
class _TopThreePopup extends StatelessWidget {
  final int place;
  final bool isTop;
  final String? avatarUrl;

  const _TopThreePopup({
    required this.place,
    required this.isTop,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titleKey = isTop ? 'top_${place}_place_title' : 'bottom_${place}_place_title';
    final descKey = isTop ? 'top_${place}_place_description' : 'bottom_${place}_place_description';
    final fullUrl = UserAPIService.fullAvatarUrl(avatarUrl);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2D2B55), Color(0xFF3E3B6B)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fullUrl != null)
            CachedNetworkImage(
              imageUrl: fullUrl,
              httpHeaders: UserAPIService.stagingHeaders,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 35,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 35, color: Colors.white70),
              ),
              errorWidget: (context, url, error) {
                print('❌ Аватар не загружен: $url ошибка: $error');
                return const Icon(Icons.person, size: 18, color: Colors.white54);
              },
            ),
          const SizedBox(height: 12),
          Text(
            loc.translate(titleKey),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate(descKey),
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}