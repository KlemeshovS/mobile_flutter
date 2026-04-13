// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/utils/achievement_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wobbly/widgets/gradient_background.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final Function()? onExport;
  final Function()? onRestoreFromBackup;
  final Function()? onImportFromFile;
  final Function()? onAchievementsReset;

  const SettingsScreen({
    super.key,
    required this.daysData,
    this.onExport,
    this.onRestoreFromBackup,
    this.onImportFromFile,
    this.onAchievementsReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showAboutApp = false;
  String _backupStatus = 'Проверка...';
  int _unlockedAchievementsCount = 0;
  int _totalAchievementsCount = 0;
  String _appVersion = '1.0.0'; // значение по умолчанию

  @override
  void initState() {
    super.initState();
    _updateBackupStatus();
//    _loadAchievementsCount();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  void _updateBackupStatus() {
    // TODO: Реализовать проверку бэкапа
    setState(() {
      _backupStatus = 'Backup not found';
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
          const SnackBar(
              content: Text(
                  'Не удалось открыть Telegram. Проверьте интернет-соединение.')),
        );
      }
    } catch (e) {
      print('Error opening Telegram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ошибка при открытии ссылки. Попробуйте позже.')),
        );
      }
    }
  }

  void _resetAllAchievements() {
    // TODO: Реализовать вибрацию
    // HapticManager.shared.impact(.heavy)

    // TODO: Сбросить ачивки
    if (widget.onAchievementsReset != null) {
      widget.onAchievementsReset!();
    }

    // Показать уведомление
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalizations.of(context).achievementsResetNotificationTitle),
        content: Text(
            AppLocalizations.of(context).achievementsResetNotificationMessage),
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок с кнопкой назад/закрытия
              _buildHeader(context, localizations),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showAboutApp
                      ? AboutAppView(
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
                        )
                      : MainMenuContent(
                          localizations: localizations,
                          backupStatus: _backupStatus,
                          onExport: widget.onExport ?? () {},
                          onRestoreFromBackup:
                              widget.onRestoreFromBackup ?? () {},
                          onImportFromFile: widget.onImportFromFile ?? () {},
                          onShowAbout: () {
                            setState(() {
                              _showAboutApp = true;
                            });
                          },
                          onResetAchievements: _resetAllAchievements,
                          appVersion: _appVersion,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E).withOpacity(0.98),
            const Color(0xFF2A2A3A).withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              child: Row(
                children: [
                  const Icon(Icons.chevron_left, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    localizations.back,
                    style:
                        TextStyle(fontFamily: 'Inter', color: Colors.white70),
                  ),
                ],
              ),
            )
          else
            Container(), // Пустое место для выравнивания

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
              icon: const Icon(Icons.close, color: Colors.white70),
            )
          else
            const SizedBox(width: 48), // Заглушка для выравнивания
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
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Информация о бэкапе (пока скрыта)
          // Text(
          //   backupStatus,
          //  style: TextStyle(
          //   fontFamily: 'Inter',color: Colors.white70),
          // ),
          // const SizedBox(height: 12),

          // Пункты меню
          MenuItem(
            icon: Icons.upload,
            title: localizations.menuExportTitle,
            subtitle: localizations.menuExportSubtitle,
            gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            onTap: onExport,
          ),
          const SizedBox(height: 12),

          // Восстановление (пока скрыто)
          // MenuItem(
          //   icon: Icons.restore,
          //   title: localizations.menuRestoreTitle,
          //   subtitle: localizations.menuRestoreSubtitle,
          //   gradient: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          //   onTap: onRestoreFromBackup,
          // ),
          // const SizedBox(height: 12),

          MenuItem(
            icon: Icons.download,
            title: localizations.menuImportTitle,
            subtitle: localizations.menuImportSubtitle,
            gradient: const [Color(0xFFA8E6CF), Color(0xFF7BCFAB)],
            onTap: onImportFromFile,
          ),
          const SizedBox(height: 12),

          MenuItem(
            icon: Icons.delete,
            title: localizations.menuResetTitle,
            subtitle: localizations.menuResetSubtitle,
            gradient: const [Color(0xFFFF6B6B), Color(0xFFFF4757)],
            onTap: onResetAchievements,
          ),
          const SizedBox(height: 12),

          // Кнопка "О приложении"
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              onTap: onShowAbout,
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFB8B5FF), Color(0xFF7868E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.info, color: Colors.white),
              ),
              title: Text(
                localizations.about,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                appVersion,
                style: TextStyle(fontFamily: 'Inter', color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
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
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontFamily: 'Inter', color: Colors.white70),
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

class _AboutAppViewState extends State<AboutAppView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;
  final AchievementManager _achievementManager = AchievementManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    _translateAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
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
    final achievementManager = AchievementManager();
    final trackedDaysCount = widget.daysData.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Логотип и название
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnimation.value),
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
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white, size: 40),
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
              );
            },
          ),
          const SizedBox(height: 24),

          // Статистика
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnimation.value),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      StatRow(
                        icon: Icons.send,
                        title: localizations.menuTgTitle,
                        value: '@wobbly',
                        onTap: widget.onTelegramTap,
                      ),
                      const SizedBox(height: 8),
                      StatRow(
                        icon: Icons.emoji_events,
                        title: localizations.menuAchievementsTitle,
                        value:
                            '${achievementManager.unlockedAchievementsCount}/${achievementManager.totalAchievementsCount}',
                      ),
                      const SizedBox(height: 8),
                      StatRow(
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

          // Описание
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
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.appOriginStoryPart2,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.aboutCreatorDescription,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
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

          // Фичи
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
                      FeatureRow(
                        icon: Icons.bar_chart,
                        title: localizations.featureStatsTitle,
                        description: localizations.featureStatsDesc,
                      ),
                      const SizedBox(height: 12),
                      FeatureRow(
                        icon: Icons.emoji_events,
                        title: localizations.featureAchievementsTitle,
                        description: localizations.featureAchievementsDesc,
                      ),
                      const SizedBox(height: 12),
                      FeatureRow(
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const StatRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, color: const Color(0xFFC7FF00), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: const Color(0xFF8B5CF6)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
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
