import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wobbly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/api_models.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/services/score_sync_manager.dart';
import 'package:wobbly/models/api_models.dart';


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
  bool _participate = true; // текущее состояние участия
  String? _myUsername;   // имя текущего пользователя для подсветки


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _loadData(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Вызывается из main.dart при переходе на вкладку
  Future<void> refreshData() async {
    print('🔄 refreshData вызван, _isRefreshing=$_isRefreshing');
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      await _ensureToken();
      final prefs = await SharedPreferences.getInstance();
      final participate = prefs.getBool('userParticipateInRating') ?? true;
      setState(() {
        _participate = participate;
        _myUsername = prefs.getString('userName');
      });
      final userName = prefs.getString('userName');
      print('🔄 refreshData: participate=$participate, userName=$userName');

      if (_participate && (userName == null || userName.isEmpty)) {
        if (!_isModalOpen) {
          _showProfileModal();
        }
        if (mounted) await _loadData(context);
      } else {
        if (mounted) await _loadData(context);
      }
    } finally {
      _isRefreshing = false;
      // Принудительно перерисовываем после загрузки
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  Future<void> _ensureToken() async {
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
      builder: (ctx) => RatingProfileSheet(
        daysData: widget.daysData,
        onSaveSuccess: () {
          _isModalOpen = false;
          refreshData();
        },
        onClose: () => _isModalOpen = false,
      ),
    );
  }

  Future<void> _loadParticipationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final participate = prefs.getBool('userParticipateInRating') ?? true;
    if (mounted) setState(() => _participate = participate);
  }

  Future<void> _loadData(BuildContext ctx) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_tabController.index == 0) {
        _topItems = await UserAPIService().fetchTop100();
        print('✅ Топ-100 загружен, элементов: ${_topItems.length}');
      } else {
        _bottomItems = await UserAPIService().fetchBottom100();
        print('✅ Дно-100 загружено, элементов: ${_bottomItems.length}');
      }
    } catch (e) {
      print('❌ Ошибка загрузки: $e');
      String userMessage;
      if (e is SocketException) {
        // Ошибка сети – показываем понятное сообщение
        userMessage = AppLocalizations.of(ctx).translate('no_internet');
      } else {
        // Другие ошибки – показываем техническое сообщение (или тоже можно общее)
        userMessage = e.toString();
      }
      if (mounted) setState(() => _error = userMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTopThreePopup(int place, bool isTop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: _TopThreePopup(place: place, isTop: isTop),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final items = _tabController.index == 0 ? _topItems : _bottomItems;

    print('🔍 build: _isLoading=$_isLoading, _error=$_error, items.length=${items.length}, _participate=$_participate, tab=${_tabController.index}');

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
              if (!_participate) _buildNotParticipatingWidget(loc),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
              else if (_error != null)
                _buildError(loc)
              else if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        loc.translate('no_leaderboard_data'),
                        style: const TextStyle(color: Colors.white70),
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



  // MARK: - Блок для неучаствующих
  Widget _buildNotParticipatingWidget(AppLocalizations loc) {
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
              loc.ratingNotParticipating,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: _showProfileModal,
            child: Text(
              loc.ratingParticipateButton,
              style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Кастомные табы
  Widget _buildCustomTabBar(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = (screenWidth - 40) / 2; // ширина каждой вкладки
    final bool isTop = _tabController.index == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        children: [
          // Фоновая подложка
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
          // Анимированный индикатор с обводкой
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: _tabController.index == 0 ? 0 : tabWidth,
            child: Container(
              width: tabWidth,
              height: 40, // теперь такой же высоты, как фон
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
          // Текст вкладок
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

  // MARK: - Горизонтальный ряд топ-3
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
              onTap: () => _showTopThreePopup(place, isTop),
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
                    _GlowingImage(
                      imagePath: _cupAsset(place, isTop: isTop),
                      place: place,
                      isTop: isTop,
                      height: 40,
                    ),
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

  // MARK: - Обычная строка для мест 4+
  Widget _buildRow(LeaderboardItem item, int position) {
    final isCurrentUser = (item.username == _myUsername);

    // Определяем цвета в зависимости от знака счёта (только для текущего пользователя)
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
      highlightColor = Colors.white70;      // для номера места (не текущий)
      highlightBgColor = Colors.white.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? highlightBgColor : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: highlightColor, width: 1.5)
            : null,
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
          const SizedBox(width: 16),
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
    );
  }


  // MARK: - Экран ошибки
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
          Shadow(
            color: color.withOpacity(0.6),
            blurRadius: 10,
          ),
          Shadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
          ),
        ],
      ),
    );
  }
}

// MARK: - Окно для участия в рейтинге
class RatingProfileSheet extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final VoidCallback onSaveSuccess;
  final VoidCallback? onClose;


  const RatingProfileSheet({
    super.key,
    required this.daysData,
    required this.onSaveSuccess,
    this.onClose,
  });

  @override
  State<RatingProfileSheet> createState() => _RatingProfileSheetState();
}

class _RatingProfileSheetState extends State<RatingProfileSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _participate = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _participate = prefs.getBool('userParticipateInRating') ?? true;
    });
  }

  @override
  void dispose() {
    widget.onClose?.call();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final trimmed = _nameController.text.trim();

    if (!_participate && trimmed.isEmpty) {
      // ничего не отправляем, просто сохраняем локально и закрываем
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userParticipateInRating', false);
      if (mounted) Navigator.pop(context);
      return;
    }

    if (_participate) {
      if (trimmed.isEmpty) {
        setState(() => _errorMessage = loc.translate('error_username_empty'));
        return;
      }
      if (trimmed.contains(' ')) {
        setState(() => _errorMessage = loc.translate('error_username_contains_space'));
        return;
      }
      if (trimmed.length < 3) {
        setState(() => _errorMessage = loc.translate('error_username_too_short'));
        return;
      }
      if (trimmed.length > 20) {
        setState(() => _errorMessage = loc.translate('error_username_too_long'));
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final token = SessionManager().accessToken;
      if (token == null) {
        throw Exception(loc.translate('error_missing_token'));
      }

      if (_participate) {
        // Включаем участие – отправляем имя
        await UserAPIService().updateMyProfile(
          token: token,
          username: trimmed,
          participateInRating: true,
        );
      } else {
        // Выключаем участие – отправляем только флаг
        await UserAPIService().updateMyRating(
          token: token,
          participateInRating: false,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      if (_participate && trimmed.isNotEmpty) {
        await prefs.setString('userName', trimmed);
      }
      await prefs.setBool('userParticipateInRating', _participate);

      if (mounted) {
        widget.onSaveSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Ошибка сохранения профиля в рейтингах: $e');
      String msg;
      if (e is UserAPIError) {
        switch (e) {
          case UserAPIError.usernameAlreadyExists:
            msg = loc.translate('error_username_already_exists');
            break;
          case UserAPIError.usernameTooShort:
            msg = loc.translate('error_username_too_short');
            break;
          case UserAPIError.usernameTooLong:
            msg = loc.translate('error_username_too_long');
            break;
          case UserAPIError.usernameInvalidCharacters:
            msg = loc.translate('error_username_invalid_characters');
            break;
          default:
            msg = e.toString();
        }
      } else {
        msg = e.toString();
      }
      setState(() {
        _errorMessage = msg;
        _isSaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2B55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок с крестиком
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('tutorial_title_profile'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Основное содержимое с прокруткой
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                children: [
                  // Поле ввода
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('user_name_label'),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabled: !_isSaving,
                        ),
                        onChanged: (v) {
                          if (v.length > 20) _nameController.text = v.substring(0, 20);
                        },
                      ),
                    ],
                  ),
                  // Место для ошибки
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 8),
                    child: _errorMessage != null
                        ? Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    )
                        : null,
                  ),
                  // Switch
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.translate('user_ranking_toggle'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Switch(
                        value: _participate,
                        onChanged: _isSaving ? null : (val) => setState(() => _participate = val),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Кнопка сохранения
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        loc.translate('save_button'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Попап для топ-3
class _TopThreePopup extends StatelessWidget {
  final int place;
  final bool isTop;

  const _TopThreePopup({required this.place, required this.isTop});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titleKey = isTop ? 'top_${place}_place_title' : 'bottom_${place}_place_title';
    final descKey = isTop ? 'top_${place}_place_description' : 'bottom_${place}_place_description';

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