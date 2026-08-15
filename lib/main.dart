import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wobbly/screens/splash/splash_screen.dart';
import 'package:wobbly/utils/install_date_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wobbly/app/app.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/utils/data_manager.dart';
import 'package:wobbly/screens/calendar/calendar_screen.dart';
import 'package:wobbly/screens/stats/stats_screen.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/utils/language_manager.dart';
import 'package:wobbly/widgets/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/screens/tutorial/tutorial_screen.dart';
import 'package:wobbly/utils/achievement_manager.dart';
import 'package:wobbly/utils/sobriety_progress_calculator.dart';
import 'package:wobbly/utils/review_manager.dart';
import 'package:wobbly/widgets/review_prompt_view.dart';
import 'package:wobbly/utils/constants.dart';
import 'package:wobbly/screens/ratings/ratings_screen.dart';
import 'package:wobbly/services/score_sync_manager.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/services/session_manager.dart';
import 'package:wobbly/services/api/user_api_service.dart';
import 'package:wobbly/services/auth_service.dart';
import 'package:wobbly/services/calendar_sync_manager.dart';
import 'package:wobbly/services/app_notification_manager.dart';
import 'package:wobbly/widgets/app_notification_view.dart';
import 'package:wobbly/screens/profile/public_user_profile_screen.dart';

void main() {
  final start = DateTime.now().millisecondsSinceEpoch;
  print('🕐 main start: $start');

  WidgetsFlutterBinding.ensureInitialized();
  print('🕐 after ensureInitialized: ${DateTime.now().millisecondsSinceEpoch - start}ms');

  // Запускаем все асинхронные задачи параллельно, НЕ ждём их
  final prefsFuture = SharedPreferences.getInstance();
  final achievementsFuture = AchievementManager().loadAchievements();
  final dataManager = DataManager();
  final dataFuture = dataManager.loadData();

  print('🕐 after creating futures: ${DateTime.now().millisecondsSinceEpoch - start}ms');

  runApp(MyApp(
    prefsFuture: prefsFuture,
    achievementsFuture: achievementsFuture,
    dataFuture: dataFuture,
  ));
  print('🕐 after runApp: ${DateTime.now().millisecondsSinceEpoch - start}ms');

}

class MyApp extends StatefulWidget {
  final Future<Map<String, DayRecord>> dataFuture;
  final Future<SharedPreferences> prefsFuture;
  final Future<void> achievementsFuture;

  const MyApp({
    super.key,
    required this.dataFuture,
    required this.prefsFuture,
    required this.achievementsFuture,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  late LanguageManager _languageManager;
  bool _showSplash = true;
  bool _isFirstLaunch = false; // временное значение, обновится после сплэша
  Map<String, DayRecord>? _loadedData;
  double? _initialScrollOffset;
  int _initialCalendarViewMode = 1;

  @override
  void initState() {
    super.initState();
    _languageManager = LanguageManager();
  }

  void _onSplashComplete(Map<String, DayRecord>? data, bool isFirstLaunch) async {
    if (!mounted) return;

    // Только локальная инициализация сессии — без сети
    await SessionManager().init();

    if (!mounted) return;

    // Читаем режим календаря из кешированных prefs (мгновенно, уже загружено)
    final prefs = await SharedPreferences.getInstance();
    final calendarViewMode = prefs.getInt('calendarViewMode') ?? 1;

    if (!mounted) return;

    // Сразу показываем главный экран с локальными данными
    setState(() {
      _showSplash = false;
      _loadedData = data ?? {};
      _isFirstLaunch = isFirstLaunch;
      _initialScrollOffset = null;
      _initialCalendarViewMode = calendarViewMode;
    });

    // Все сетевые операции — в фоне, не блокируют UI
    _backgroundSync();
  }

  Future<void> _backgroundSync() async {
    // Проверяем/обновляем сессию
    try {
      final session = SessionManager();
      if (session.accessToken != null) {
        try {
          await UserAPIService().getSession(session.accessToken!);
        } catch (e) {
          if (e is UserAPIError && e == UserAPIError.invalidToken) {
            await AuthService().refreshSession();
          }
        }
      }
    } catch (_) {}

    // Синхронизируем календарь
    try {
      await CalendarSyncManager().sync();
      await CalendarSyncManager().pushToServer();
    } catch (_) {}

    // Проверяем уведомления
    try {
      await AppNotificationManager.shared.checkNewFollowers();
      await AppNotificationManager.shared.checkNewAchievements();
    } catch (_) {}
  }

  void _onTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    setState(() => _isFirstLaunch = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageManager>.value(
      value: _languageManager,
      child: Consumer<LanguageManager>(
        builder: (context, languageManager, child) {
          return MaterialApp(
            title: 'Wobbly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en'), const Locale('ru')],
            locale: languageManager.currentLocale,
            home: _showSplash
                ? SplashScreen(
              onAnimationComplete: _onSplashComplete,
              dataFuture: widget.dataFuture,
              prefsFuture: widget.prefsFuture,
              achievementsFuture: widget.achievementsFuture,
            )
                : (_isFirstLaunch
                ? TutorialScreen(onComplete: _onTutorialComplete)
                : MainApp(
              initialData: _loadedData ?? {},
              initialScrollOffset: _initialScrollOffset,
              initialCalendarViewMode: _initialCalendarViewMode,
            )),
          );
        },
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final Map<String, DayRecord> initialData;
  final double? initialScrollOffset;
  final int initialCalendarViewMode;

  const MainApp({
    super.key,
    required this.initialData,
    this.initialScrollOffset,
    this.initialCalendarViewMode = 1,
  });

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int _selectedTab = 0;
  late Map<String, DayRecord> _daysData;
  final DataManager _dataManager = DataManager();
  final GlobalKey<CalendarScreenState> _calendarKey = GlobalKey();
  final GlobalKey<StatsScreenState> _statsKey = GlobalKey();
  final GlobalKey<RatingsScreenState> _ratingsKey = GlobalKey();
  DateTime? _installDate;
  int _progressDays = 0;

  void forceRefreshRatingsTab() {
    print('⚡ forceRefreshRatingsTab вызван, текущая вкладка $_selectedTab');
    setState(() {
      _selectedTab = 1;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        print('⚡ возвращаем на вкладку 2');
        setState(() {
          _selectedTab = 2;
        });
      }
    });
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String activeIconPath,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        _onTabTapped(index, context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  isSelected ? activeIconPath : iconPath,
                  key: ValueKey(isSelected),
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                  const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _daysData = widget.initialData;

    // Загружаем install date только после того, как интерфейс появился
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstallDate();
    });
  }

  Future<void> _resetAchievements() async {
    print('🔄 Сброс ачивок вызван');
    final manager = AchievementManager();
    await manager.resetAndCheckAllAchievements(_progressDays, _daysData);
    print('✅ Ачивки сброшены и пересчитаны');
    setState(() {
      _daysData = Map.from(_daysData);
    });
    _statsKey.currentState?.refreshAchievements();
  }

  Future<void> _loadInstallDate() async {
    final installDate = await InstallDateManager.getInstallDate();
    setState(() {
      _installDate = installDate;
    });
    _updateProgress();
  }

  void _updateProgress() {
    if (_installDate == null) {
      print("⏳ _installDate ещё не загружен");
      return;
    }
    print("📊 Пересчёт прогресса...");
    final newProgress = SobrietyProgressCalculator.calculateProgressDays(
      _daysData,
      _installDate!,
    );
    print("   ➡️ Новый прогресс: $newProgress (был $_progressDays)");
    setState(() {
      _progressDays = newProgress;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AchievementManager().updateAchievements(_progressDays, _daysData).then((
          _) {
        _statsKey.currentState?.refreshAchievements();
      });
    });
  }


  Future<void> _reloadData() async {
    final newData = await _dataManager.loadData();
    setState(() {
      _daysData = newData;
    });
    _updateProgress();
    ScoreSyncManager().sendScore(_daysData);
    _ratingsKey.currentState?.refreshData();
  }

  void _onTabTapped(int index, BuildContext context) async {
    print('📱 Тапнули на вкладку $index');

    setState(() {
      _selectedTab = index;
    });

    if (index == 1) {
      // Отправляем текущий счёт на сервер при открытии статистики
      await ScoreSyncManager().sendScore(_daysData);
      // статистика
      await ReviewManager().incrementStatsOpenCount();
      final shouldShow = await ReviewManager().shouldShowPrompt(_daysData);
      if (shouldShow) {
        ReviewPromptView.show(context);
      }
      // Пересчитываем достижения на основе текущих данных
      await AchievementManager().updateAchievements(_progressDays, _daysData);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _statsKey.currentState?.refreshAchievements();
      });
    } else if (index == 2) {
      // Сначала отправляем текущий счёт на сервер и ждём завершения
      await ScoreSyncManager().sendScore(_daysData);
      // Затем обновляем рейтинги
      _ratingsKey.currentState?.refreshData();
    }
  }

  Future<void> _exportData() async {
    try {
      print('ExportData: Starting export...');

      final Map<String, String> daysDataMap = {};
      _daysData.forEach((key, record) {
        if (record.drinkLevel.toString().contains('unknown')) return;

        String value;

        if (record.hasSport) {
          if (record.drinkLevel == DrinkLevel.little) {
            value = 'little_sport';
          } else if (record.drinkLevel == DrinkLevel.medium) {
            value = 'medium_sport';
          } else if (record.drinkLevel == DrinkLevel.heavy) {
            value = 'heavy_sport';
          } else if (record.drinkLevel == DrinkLevel.none) {
            value = 'sport';
          } else {
            value = 'sport';
          }
        } else {
          value = record.drinkLevel
              .toString()
              .split('.')
              .last;
        }

        daysDataMap[key] = value;
      });

      final exportData = {
        'version': '2.0',
        'exportDate': DateTime.now().toIso8601String(),
        'daysData': daysDataMap,
      };

      print('ExportData: Data prepared, ${daysDataMap.length} days');

      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'wobbly_export_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('ExportData: File created: $fileName');

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Wobbly Data Export',
        text: 'Here is my Wobbly data export file.',
      );


      Future.delayed(const Duration(seconds: 30)).then((_) async {
        if (await file.exists()) {
          await file.delete();
          print('ExportData: Temporary file deleted');
        }
      });
    } catch (e, stackTrace) {
      print('ExportData: Error: $e');
      print('ExportData: Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDayRecord(DayData dayData, DayRecord record) async {
    print("🔄 _updateDayRecord: day=${dayData.key}, record: drinkLevel=${record
        .drinkLevel}, hasSport=${record.hasSport}");
    setState(() {
      if (record.drinkLevel == DrinkLevel.unknown) {
        _daysData.remove(dayData.key);
        print("   ➡️ Удаляем запись");
      } else {
        _daysData = {..._daysData, dayData.key: record};
        print("   ➡️ Обновляем/добавляем запись");
      }
    });
    print("   📦 _daysData теперь содержит ${_daysData.length} записей");

    await _dataManager.updateDayRecord(
      dayData.key,
      record.drinkLevel == DrinkLevel.unknown ? null : record,
    );
    print("   💾 Данные сохранены в хранилище");

    _updateProgress();
    ScoreSyncManager().sendScore(_daysData);
    CalendarSyncManager().markLocalUpdated();
    CalendarSyncManager().pushToServer();

    // Проверяем новые ачивки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNotificationManager.shared.checkNewAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 MainApp build: _selectedTab=$_selectedTab');
    final localizations = AppLocalizations.of(context);
    const horizontalPadding = 16.0;
    const verticalPadding = 8.0;

    return ListenableBuilder(
      listenable: AppNotificationManager.shared,
      builder: (context, _) {
        final notification = AppNotificationManager.shared.currentNotification;
        return Stack(
          children: [
            GradientBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: IndexedStack(
                  index: _selectedTab,
                  children: [
                    CalendarScreen(
                      key: _calendarKey,
                      daysData: _daysData,
                      onDayRecordUpdated: _updateDayRecord,
                      initialScrollOffset: CalendarScreen.computeInitialScrollOffset(
                        widget.initialCalendarViewMode,
                        MediaQuery.of(context).size.width,
                      ),
                      progressDays: _progressDays,
                      initialViewMode: widget.initialCalendarViewMode,
                    ),
                    StatsScreen(
                      key: _statsKey,
                      daysData: _daysData,
                      progressDays: _progressDays,
                      onExport: _exportData,
                      onDataChanged: _reloadData,
                      onAchievementsReset: _resetAchievements,
                      ratingsKey: _ratingsKey,
                    ),
                    RatingsScreen(
                      key: _ratingsKey,
                      daysData: _daysData,
                    ),
                  ],
                ),
                bottomNavigationBar: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          index: 0,
                          iconPath: 'assets/icons/calendar.png',
                          activeIconPath: 'assets/icons/calendar_selected.png',
                          label: localizations.calendarTabTitle,
                        ),
                        _buildNavItem(
                          index: 1,
                          iconPath: 'assets/icons/statistics.png',
                          activeIconPath: 'assets/icons/statistics_selected.png',
                          label: localizations.statTabTitle,
                        ),
                        _buildNavItem(
                          index: 2,
                          iconPath: 'assets/icons/ratings.png',
                          activeIconPath: 'assets/icons/ratings_selected.png',
                          label: localizations.ratingsTabTitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Уведомление поверх всего
            if (notification != null)
              AppNotificationView(
                item: notification,
                onDismiss: AppNotificationManager.shared.dismiss,
                onFollowerTap: (userId, username, avatarUrl) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => PublicUserProfileScreen(
                        userId: userId,
                        username: username,
                        avatarUrl: avatarUrl,
                      ),
                    ),
                  );
                },              ),
          ],
        );
      },
    );
  }
}