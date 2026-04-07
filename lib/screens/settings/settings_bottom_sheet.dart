// lib/screens/settings/settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:provider/provider.dart';
import 'package:wobbly/utils/language_manager.dart';
import 'package:wobbly/utils/achievement_manager.dart';
import 'package:wobbly/screens/profile/user_profile_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wobbly/services/score_sync_manager.dart';
import 'package:wobbly/screens/ratings/ratings_screen.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/auth_service.dart';


class SettingsBottomSheet extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final Function()? onExport;
  final Function()? onRestoreFromBackup;
  final Function()? onImportFromFile;
  final Function()? onAchievementsReset;
  final GlobalKey<RatingsScreenState> ratingsKey;


  const SettingsBottomSheet({
    super.key,
    required this.daysData,
    this.onExport,
    this.onRestoreFromBackup,
    this.onImportFromFile,
    this.onAchievementsReset,
    required this.ratingsKey,
  });

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  bool _showAboutApp = false;
  String _backupStatus = 'Проверка...';
  int _unlockedAchievementsCount = 0;
  int _totalAchievementsCount = 20;
  String _appVersion = '';

  SessionType _sessionType = SessionType.guest;

  Future<void> _loadSessionType() async {
    await SessionManager().init();
    setState(() {
      _sessionType = SessionManager().sessionType;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateBackupStatus();
    _loadAchievementsCount();
    _loadAppVersion();
    _loadSessionType();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  void _updateBackupStatus() {
    setState(() {
      _backupStatus = 'Backup not found';
    });
  }

  void _loadAchievementsCount() async {
    final manager = AchievementManager();
    await manager.loadAchievements(); // загружаем сохранённые данные
    setState(() {
      _unlockedAchievementsCount = manager.unlockedAchievementsCount;
      _totalAchievementsCount = manager.totalAchievementsCount;
    });
  }

  Future<void> _openTelegram() async {
    const telegramUsername = 'wobbly_app';
    final telegramUrl = Uri.parse('tg://resolve?domain=$telegramUsername');
    final webUrl = Uri.parse('https://t.me/$telegramUsername');

    try {
      // Сначала пробуем открыть в приложении Telegram
      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // Если не получилось, открываем в браузере
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // Если ни то, ни другое не сработало – показываем ошибку
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть Telegram. Проверьте интернет-соединение.')),
        );
      }
    } catch (e) {
      print('Error opening Telegram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при открытии ссылки. Попробуйте позже.')),
        );
      }
    }
  }

  void _resetAllAchievements() {
    if (widget.onAchievementsReset != null) {
      widget.onAchievementsReset!();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).achievementsResetNotificationTitle),
        content: Text(AppLocalizations.of(context).achievementsResetNotificationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final bool isAuthenticated = _sessionType == SessionType.authenticated;
    final double menuHeight = _showAboutApp
        ? screenHeight - padding.top
        : isAuthenticated
        ? screenHeight * 0.70   // достаточно для всех пунктов + выход
        : screenHeight * 0.60;  // меньше для гостя

    return Container(
      height: menuHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E2E).withOpacity(0.98),
            const Color(0xFF2A2A3A).withOpacity(0.98),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_showAboutApp ? 0 : 32),
          topRight: Radius.circular(_showAboutApp ? 0 : 32),
        ),
        border: _showAboutApp
            ? null
            : Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(localizations),
          Expanded(
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: _showAboutApp ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: MainMenuContent(
                    localizations: localizations,
                    backupStatus: _backupStatus,
                    onExport: widget.onExport ?? () {},
                    onRestoreFromBackup: widget.onRestoreFromBackup ?? () {},
                    onImportFromFile: widget.onImportFromFile ?? () {},
                    onShowAbout: () {
                      setState(() {
                        _showAboutApp = true;
                      });
                    },
                    onResetAchievements: _resetAllAchievements,
                    appVersion: _appVersion,
                    ratingsKey: widget.ratingsKey,
                    daysData: widget.daysData,
                    sessionType: _sessionType,
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _showAboutApp ? 0 : MediaQuery.of(context).size.width,
                  right: _showAboutApp ? 0 : -MediaQuery.of(context).size.width,
                  top: 0,
                  bottom: 0,
                  child: AboutAppView(
                    daysData: widget.daysData,
                    unlockedAchievementsCount: _unlockedAchievementsCount,
                    totalAchievementsCount: _totalAchievementsCount,
                    onBack: () {
                      setState(() {
                        _showAboutApp = false;
                      });
                    },
                    onTelegramTap: _openTelegram,
                    appVersion: _appVersion,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: _showAboutApp ? 24 : 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          if (_showAboutApp)
            TextButton(
              onPressed: () {
                setState(() {
                  _showAboutApp = false;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chevron_left,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.back,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Center(
              child: Text(
                _showAboutApp ? '' : localizations.settingsMenu,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          if (!_showAboutApp)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class MainMenuContent extends StatelessWidget {
  final AppLocalizations localizations;
  final String backupStatus;
  final VoidCallback onExport;
  final VoidCallback onRestoreFromBackup;
  final VoidCallback onImportFromFile;
  final VoidCallback onShowAbout;
  final VoidCallback onResetAchievements;
  final String appVersion;
  final GlobalKey<RatingsScreenState> ratingsKey;
  final Map<String, DayRecord> daysData;
  final SessionType sessionType;

  const MainMenuContent({
    super.key,
    required this.localizations,
    required this.backupStatus,
    required this.onExport,
    required this.onRestoreFromBackup,
    required this.onImportFromFile,
    required this.onShowAbout,
    required this.onResetAchievements,
    required this.appVersion,
    required this.ratingsKey,
    required this.daysData,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    final languageManager = Provider.of<LanguageManager>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Кнопка переключения языка
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              final currentLanguage = languageManager.currentLanguageCode == 'en'
                  ? localizations.languageEnglish
                  : localizations.languageRussian;

              final oppositeLanguage = languageManager.currentLanguageCode == 'en'
                  ? localizations.languageRussian
                  : localizations.languageEnglish;

              final switchToText = languageManager.currentLanguageCode == 'en'
                  ? localizations.switchToRussian
                  : localizations.switchToEnglish;

              return _buildLanguageMenuItem(
                icon: Icons.language,
                title: localizations.menuLanguage,
                currentLanguage: currentLanguage,
                onTap: () => _showLanguageSelector(context, languageManager),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.person,
            title: localizations.translate('menu_user_profile'),
            subtitle: localizations.translate('menu_user_profile_subtitle'),
            gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
            onTap: () {
              // Закрываем текущее меню
              Navigator.pop(context);
              // Открываем экран профиля
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => UserProfileScreen(
                  onClose: () => Navigator.pop(ctx),
                  onRegisterSuccess: (username, userId, participate) {
                    ScoreSyncManager().sendScore(daysData);
                    ratingsKey.currentState?.refreshData();
                    print('Профиль сохранён: $username, participate: $participate');
                  },
                  onDisappear: null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Экспорт
          _buildMenuItem(
            icon: Icons.upload,
            title: localizations.menuExportTitle,
            subtitle: localizations.menuExportSubtitle,
            gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            onTap: () {
              print('Export tapped, onExport is ${onExport != null ? 'not null' : 'null'}');
              if (onExport == null) {
                print('onExport is null, cannot export');
                return;
              }
              // Закрываем bottom sheet
              Navigator.of(context).pop();
              // Используем микротаск для вызова после завершения анимации закрытия
              Future.microtask(() {
                onExport();
              });
            },
          ),

          const SizedBox(height: 12),

          // Импорт
          _buildMenuItem(
            icon: Icons.download,
            title: localizations.menuImportTitle,
            subtitle: localizations.menuImportSubtitle,
            gradient: const [Color(0xFFA8E6CF), Color(0xFF7BCFAB)],
            onTap: onImportFromFile,
          ),
          const SizedBox(height: 12),

          // О приложении
          _buildMenuItem(
            icon: Icons.info,
            title: localizations.about,
            subtitle: '${localizations.menuVersionTitle} $appVersion',
            gradient: const [Color(0xFFB8B5FF), Color(0xFF7868E6)],
            onTap: onShowAbout,
            showChevron: true,
          ),
          const SizedBox(height: 12),
          // Выйти
          if (SessionManager().sessionType == SessionType.authenticated)
            _buildMenuItem(
              icon: Icons.logout,
              title: localizations.translate('logout_button'),
              subtitle: '', // пустой подзаголовок
              gradient: const [Color(0xFFF44336), Color(0xFFD32F2F)],
              onTap: () async {
                // Закрываем bottom sheet
                Navigator.pop(context);
                // Выполняем выход
                await AuthService().signOut();
                // Обновляем состояние приложения (например, перезагружаем рейтинги)
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageMenuItem({
    required IconData icon,
    required String title,
    required String currentLanguage,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                // Круглая иконка слева
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),

                // Основная часть: заголовок и метка языка
                Expanded(
                  child: Row(
                    children: [
                      // Заголовок
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15, // уменьшенный шрифт
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // толкает метку вправо
                      // Метка текущего языка
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentLanguage,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13, // уменьшенный шрифт
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC7FF00),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                // Стрелка
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, LanguageManager languageManager) {
    final localizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2B55),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.menuLanguage,
              style: TextStyle(
                fontFamily: 'Inter',
              color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Текущий язык
            _buildLanguageOption(
              context: context,
              languageCode: languageManager.currentLanguageCode,
              languageName: languageManager.currentLanguageCode == 'en'
                  ? localizations.languageEnglish
                  : localizations.languageRussian,
              isCurrent: true,
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 8),

            // Второй язык
            _buildLanguageOption(
              context: context,
              languageCode: languageManager.oppositeLanguageCode,
              languageName: languageManager.currentLanguageCode == 'en'
                  ? localizations.languageRussian
                  : localizations.languageEnglish,
              isCurrent: false,
              onTap: () {
                languageManager.switchLanguage(languageManager.oppositeLanguageCode);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isCurrent
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : Colors.transparent,
          radius: 20,
          child: Text(
            languageCode.toUpperCase(),
            style: TextStyle(
              color: isCurrent
                  ? const Color(0xFF6366F1)
                  : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          languageName,
          style: TextStyle(
            color: isCurrent ? Colors.white : Colors.white70,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: isCurrent
            ? Text(
          AppLocalizations.of(context).languageCurrent,
          style: TextStyle(
            fontFamily: 'Inter',
          color: Color(0xFFC7FF00),
            fontSize: 12,
          ),
        )
            : null,
        trailing: isCurrent
            ? const Icon(Icons.check, color: Color(0xFF6366F1))
            : null,
      ),
    );
  }


  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool showChevron = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Показываем подзаголовок, только если он не пустой
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }

class AboutAppView extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final int unlockedAchievementsCount;
  final int totalAchievementsCount;
  final VoidCallback onBack;
  final VoidCallback onTelegramTap;
  final String appVersion;

  const AboutAppView({
    super.key,
    required this.daysData,
    required this.unlockedAchievementsCount,
    required this.totalAchievementsCount,
    required this.onBack,
    required this.onTelegramTap,
    required this.appVersion,
  });

  @override
  State<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends State<AboutAppView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    _translateAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF4B3A91)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.appTitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                          fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.appSubtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                          fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  children: [
                    _buildStatRow(
                      icon: Icons.send,
                      title: localizations.menuTgTitle,
                      value: '@wobbly',
                      onTap: widget.onTelegramTap,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.emoji_events,
                      title: localizations.menuAchievementsTitle,
                      value: '${widget.unlockedAchievementsCount}/${widget.totalAchievementsCount}',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.info,
                      title: localizations.menuVersionTitle,
                      value: widget.appVersion,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.about,
                        style: TextStyle(
                          fontFamily: 'Inter',
                        fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.appOriginStoryPart1,
                        style: TextStyle(
                          fontFamily: 'Inter',
                        fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.appOriginStoryPart2,
                        style: TextStyle(
                          fontFamily: 'Inter',
                        fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.aboutCreatorDescription,
                        style: TextStyle(
                          fontFamily: 'Inter',
                        fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7FF00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.aboutCapabilitiesTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                      fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      icon: Icons.bar_chart,
                      title: localizations.featureStatsTitle,
                      description: localizations.featureStatsDesc,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      icon: Icons.emoji_events,
                      title: localizations.featureAchievementsTitle,
                      description: localizations.featureAchievementsDesc,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      icon: Icons.lock,
                      title: localizations.featurePrivacyTitle,
                      description: localizations.featurePrivacyDesc,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC7FF00), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
              fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                  fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                  fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}