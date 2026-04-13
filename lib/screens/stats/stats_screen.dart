// lib/screens/stats/stats_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/widgets/gradient_background.dart';
import 'package:wobbly/widgets/percentage_bar_view.dart';
import 'package:wobbly/widgets/sobriety_progress_view.dart';
import 'package:wobbly/utils/sobriety_progress_calculator.dart';
import 'package:wobbly/screens/settings/settings_bottom_sheet.dart';
import 'package:wobbly/utils/install_date_manager.dart';
import 'package:wobbly/models/user_status.dart';
import 'package:wobbly/widgets/user_status_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wobbly/utils/data_manager.dart';
import 'package:wobbly/widgets/adaptive_sobriety_facts_view.dart';
import 'package:wobbly/models/milestone.dart';
import 'package:wobbly/utils/achievement_manager.dart';
import 'package:wobbly/widgets/achievements_section.dart';
import 'package:wobbly/screens/achievements/all_achievements_sheet.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/services/score_sync_manager.dart';
import 'package:wobbly/screens/ratings/ratings_screen.dart';

// Класс для хранения статистики за год (оставлен как был)
class YearStats {
  final int little;
  final int medium;
  final int heavy;
  final int sport;
  final int comboDays;
  final int drinkingDays;
  final int totalDays;
  final int totalDrinking;

  YearStats({
    required this.little,
    required this.medium,
    required this.heavy,
    required this.sport,
    required this.comboDays,
    required this.drinkingDays,
    required this.totalDays,
    required this.totalDrinking,
  });
}

// Класс для хранения процентов алкоголя vs спорт
class _DrinkingVsSportStats {
  final double drinkingPercentage;
  final double sportPercentage;

  _DrinkingVsSportStats({
    required this.drinkingPercentage,
    required this.sportPercentage,
  });
}

class StatsScreen extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final int progressDays;
  final VoidCallback? onExport;
  final VoidCallback? onDataChanged;
  final VoidCallback? onAchievementsReset;
  final GlobalKey<RatingsScreenState> ratingsKey;

  const StatsScreen({
    super.key,
    required this.daysData,
    required this.progressDays,
    this.onExport,
    this.onDataChanged,
    this.onAchievementsReset,
    required this.ratingsKey,
  });

  @override
  State<StatsScreen> createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> with WidgetsBindingObserver {
  int _selectedYear = DateTime.now().year;
  DateTime? _installDate;
  UserStatus? _userStatus;
  int _achievementsVersion = 0;

  List<Achievement> _unlockedAchievements = [];
  final AchievementManager _achievementManager = AchievementManager();

  bool _isAlcoholic(DayRecord record) {
    return record.drinkLevel == DrinkLevel.little ||
        record.drinkLevel == DrinkLevel.medium ||
        record.drinkLevel == DrinkLevel.heavy ||
        record.drinkLevel == DrinkLevel.little_sport;
  }

  DateTime _getFirstActivityDate() {
    DateTime? earliest;
    widget.daysData.forEach((key, record) {
      if (record.drinkLevel != DrinkLevel.none || record.hasSport) {
        final parts = key.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]); // месяц 1-based в ключе
          final day = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          if (earliest == null) {
            earliest = date;
          } else if (date.isBefore(earliest!)) {
            earliest = date;
          }
        }
      }
    });
    // Если нет активности, возвращаем дату в будущем (завтра), чтобы стрики были 0
    return earliest ?? DateTime.now().add(const Duration(days: 1));
  }

  void refreshAchievements() {
    print("🔄 refreshAchievements called");
    final newList = _achievementManager.getUnlockedAchievements();
    print("   unlocked count: ${newList.length}");
    setState(() {
      _unlockedAchievements = newList;
      _achievementsVersion++;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInstallDate();
    WidgetsBinding.instance.addObserver(this);
    _initAchievements();
    // Добавляем вызов обновления статуса после сборки виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserStatus();
    });
  }

  Future<void> _loadInstallDate() async {
    final installDate = await InstallDateManager.getInstallDate();
    if (mounted) {
      setState(() {
        _installDate = installDate;
      });
    }
  }

  Future<void> _initAchievements() async {
    await _achievementManager.loadAchievements();
    if (mounted) {
      setState(() {
        _unlockedAchievements = _achievementManager.getUnlockedAchievements();
      });
    }
  }

  Future<void> _recalculateAchievements() async {
    print('🔄 Проверка ачивок');
    await _achievementManager.updateAchievements(
        widget.progressDays, widget.daysData);
    if (mounted) {
      setState(() {
        _unlockedAchievements = _achievementManager.getUnlockedAchievements();
      });
    }
  }

  @override
  void didUpdateWidget(covariant StatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysData != widget.daysData) {
      _updateUserStatus(); // обновляем статус при изменении данных
      setState(() {
        _unlockedAchievements = _achievementManager.getUnlockedAchievements();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // при возвращении в приложение можно обновить статус
      _updateUserStatus();
    }
  }

  void _showStatInfo(String title, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2B55),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserStatus() {
    final status = UserStatusManager.calculateStatus(widget.daysData);
    if (_userStatus != status) {
      setState(() {
        _userStatus = status;
      });
    }
  }

  void _showStatusDescription(BuildContext context, UserStatus status) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2B55),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.getUserStatusTitle(status),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.getUserStatusDescription(status),
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllAchievements() {
    final allAchievements = _achievementManager.getAllAchievements();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllAchievementsSheet(
        achievements: allAchievements,
        onAchievementTap: _showAchievementDetail,
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    final localizations = AppLocalizations.of(context);
    final bool isDrinking =
        achievement.type == AchievementType.drinkingStreak ||
            (achievement.type == AchievementType.milestone &&
                achievement.id.contains('negative'));
    final bool isMarianaTrench = achievement.id == 'milestone_11022_negative';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2B55),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMarianaTrench
                        ? [const Color(0xFF8B0000), const Color(0xFFB22222)]
                        : isDrinking
                            ? [
                                const Color(0xFFDC143C),
                                const Color(0xFFFF4500)
                              ] // красный → оранжево-красный
                            : [
                                const Color(0xFF4ECDC4),
                                const Color(0xFF44A08D)
                              ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    achievement.imageAsset,
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.getLocalizedTitle(localizations),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.getLocalizedDescription(localizations),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getConditionText(achievement, localizations),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? const Color(0xFFC7FF00)
                      : const Color(0xFF8B5CF6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getConditionText(
      Achievement achievement, AppLocalizations localizations) {
    switch (achievement.type) {
      case AchievementType.drinkingStreak:
        return localizations
            .translate('condition_drinking_days', [achievement.requiredValue]);
      case AchievementType.soberStreak:
        return localizations
            .translate('condition_sober_days', [achievement.requiredValue]);
      case AchievementType.sportCount:
        return localizations.translate(
          'condition_sport_count',
          [achievement.requiredValue, achievement.period?.daysCount ?? 0],
        );
      case AchievementType.uniqueEvent:
        if (achievement.id == 'sober_new_year')
          return localizations.translate('condition_sober_new_year');
        if (achievement.id == 'sport_new_year')
          return localizations.translate('condition_sport_new_year');
        return '';
      case AchievementType.milestone:
        if (achievement.id.contains('negative')) {
          return localizations.translate(
              'condition_milestone_negative', [achievement.requiredValue]);
        } else {
          return localizations.translate(
              'condition_milestone_positive', [achievement.requiredValue]);
        }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yearStats = _calculateYearStats(_selectedYear);
    final currentSoberStreak = _calculateCurrentSoberStreak(_selectedYear);
    final longestSoberStreak = _calculateLongestSoberStreak(_selectedYear);
    final longestDrinkingStreak =
        _calculateLongestDrinkingStreak(_selectedYear);
    final sportDays = _calculateSportDays(_selectedYear);
    final drinkingVsSportStats = _calculateDrinkingVsSportStats(yearStats);

    return Scaffold(
      body: SafeArea(
        child: GradientBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, left: 16, right: 16, bottom: 16),
                    child: Column(
                      children: [
                        if (_userStatus != null) ...[
                          UserStatusWidget(
                            status: _userStatus!,
                            onTap: () =>
                                _showStatusDescription(context, _userStatus!),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                        SobrietyProgressView(progressDays: widget.progressDays),
                        const SizedBox(height: 16),
                        _buildStatsGlassCard(
                          yearStats: yearStats,
                          currentSoberStreak: currentSoberStreak,
                          longestSoberStreak: longestSoberStreak,
                          longestDrinkingStreak: longestDrinkingStreak,
                          sportDays: sportDays,
                        ),
                        const SizedBox(height: 12),
                        _buildDrinkingVsSportGlassCard(drinkingVsSportStats),
                        const SizedBox(height: 16),
                        AdaptiveSobrietyFactsView(
                            soberDays: currentSoberStreak),
                        const SizedBox(height: 16),
                        AchievementsSection(
                          key: ValueKey('achievements_$_achievementsVersion'),
                          achievements: _unlockedAchievements,
                          onSeeAllTap: _showAllAchievements,
                          onAchievementTap: _showAchievementDetail,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ВСЕ МЕТОДЫ СТАТИСТИКИ ВОЗВРАЩЕНЫ В ИСХОДНОЕ СОСТОЯНИЕ ----------

  YearStats _calculateYearStats(int year) {
    final firstActivity = _getFirstActivityDate();
    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final currentMonth = now.month - 1;
    final currentDay = now.day;

    // Если год меньше года первой активности – данных за этот год нет
    if (year < firstActivity.year) {
      return YearStats(
        little: 0,
        medium: 0,
        heavy: 0,
        sport: 0,
        comboDays: 0,
        drinkingDays: 0,
        totalDays: 0,
        totalDrinking: 0,
      );
    }

    var little = 0;
    var medium = 0;
    var heavy = 0;
    var sport = 0;
    var comboDays = 0;
    var totalDrinking = 0;
    var totalDays = 0;

    for (int month = 0; month < 12; month++) {
      // Не заглядываем в будущие месяцы текущего года
      if (isCurrentYear && month > currentMonth) continue;

      // Проверяем, доступен ли этот месяц для учёта
      bool monthAvailable = true;
      int startDay = 1;

      if (year == firstActivity.year) {
        if (month < firstActivity.month - 1) {
          // Месяц полностью до первой активности – пропускаем
          monthAvailable = false;
        } else if (month == firstActivity.month - 1) {
          // Месяц первой активности – начинаем с дня первой активности
          startDay = firstActivity.day;
        }
        // Если месяц больше месяца первой активности – startDay остаётся 1
      }
      // Если year > firstActivity.year – месяц полностью доступен

      if (!monthAvailable) continue;

      final daysInMonth = _getDaysInMonth(month, year);
      final endDay =
          (isCurrentYear && month == currentMonth) ? currentDay : daysInMonth;

      if (startDay > endDay) continue;

      totalDays += (endDay - startDay + 1);

      for (int day = startDay; day <= endDay; day++) {
        final dayData = DayData(day: day, month: month, year: year);
        final record = widget.daysData[dayData.key] ?? DayRecord();

        // Подсчёт комбинаций (алкоголь + спорт)
        if (record.hasSport && record.drinkLevel != DrinkLevel.none) {
          comboDays++;
          sport++;
          totalDrinking++;
          if (record.drinkLevel == DrinkLevel.little) {
            little++;
          } else if (record.drinkLevel == DrinkLevel.medium) {
            medium++;
          } else if (record.drinkLevel == DrinkLevel.heavy) {
            heavy++;
          }
        } else {
          // Обычные дни (только алкоголь или только спорт)
          switch (record.drinkLevel) {
            case DrinkLevel.little:
              little++;
              totalDrinking++;
              break;
            case DrinkLevel.medium:
              medium++;
              totalDrinking++;
              break;
            case DrinkLevel.heavy:
              heavy++;
              totalDrinking++;
              break;
            default:
              break;
          }
          if (record.hasSport && record.drinkLevel == DrinkLevel.none) {
            sport++;
          }
        }
      }
    }

    return YearStats(
      little: little,
      medium: medium,
      heavy: heavy,
      sport: sport,
      comboDays: comboDays,
      drinkingDays: little + medium + heavy,
      totalDays: totalDays,
      totalDrinking: totalDrinking,
    );
  }

  int _calculateCurrentSoberStreak(int year) {
    final firstActivity = _getFirstActivityDate();
    final now = DateTime.now();
    final isCurrentYear = year == now.year;

    if (isCurrentYear) {
      var streak = 0;
      for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
        final date = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: dayOffset));
        if (date.isBefore(firstActivity)) break;
        final dayData =
            DayData(day: date.day, month: date.month - 1, year: date.year);
        final record = widget.daysData[dayData.key] ?? DayRecord();
        if (_isAlcoholic(record)) break;
        streak++;
      }
      return streak;
    } else {
      var streak = 0;
      final lastDayOfYear = DateTime(year, 12, 31);
      for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
        final date = lastDayOfYear.subtract(Duration(days: dayOffset));
        if (date.isBefore(firstActivity)) break;
        if (date.year < year) break;
        final dayData =
            DayData(day: date.day, month: date.month - 1, year: date.year);
        final record = widget.daysData[dayData.key] ?? DayRecord();
        if (_isAlcoholic(record)) break;
        streak++;
      }
      return streak;
    }
  }

  int _calculateLongestSoberStreak(int year) {
    final firstActivity = _getFirstActivityDate();
    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final startDate = DateTime(year, 1, 1);
    final endDate = isCurrentYear ? now : DateTime(year, 12, 31);

    final effectiveStartDate =
        firstActivity.isAfter(startDate) ? firstActivity : startDate;
    if (effectiveStartDate.isAfter(endDate)) return 0;

    var maxStreak = 0;
    var currentStreak = 0;
    var date = effectiveStartDate;

    while (!date.isAfter(endDate)) {
      final dayData =
          DayData(day: date.day, month: date.month - 1, year: date.year);
      final record = widget.daysData[dayData.key] ?? DayRecord();
      if (!_isAlcoholic(record)) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      date = date.add(const Duration(days: 1));
    }
    return maxStreak;
  }

  int _calculateLongestDrinkingStreak(int year) {
    final earliestDate = DateTime(year, 1, 1);
    final streak = _calculateDrinkingStreakFromDate(earliestDate, year);
    return streak == 1 ? 0 : streak;
  }

  int _calculateSportDays(int year) {
    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final currentMonth = isCurrentYear ? now.month - 1 : 11;
    final currentDay = isCurrentYear ? now.day : 31;

    var sportDays = 0;
    for (int month = 0; month <= (isCurrentYear ? currentMonth : 11); month++) {
      final daysInMonth = _getDaysInMonth(month, year);
      final daysToCheck =
          (isCurrentYear && month == currentMonth) ? currentDay : daysInMonth;
      for (int day = 1; day <= daysToCheck; day++) {
        final dayData = DayData(day: day, month: month, year: year);
        final record = widget.daysData[dayData.key] ?? DayRecord();
        if (record.hasSport) sportDays++;
      }
    }
    return sportDays;
  }

  int _calculateDrinkingStreakFromDate(DateTime startDate, int year) {
    final endDate = DateTime(year, 12, 31);
    var maxStreak = 0;
    var currentStreak = 0;
    var date = startDate;

    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      final dayData =
          DayData(day: date.day, month: date.month - 1, year: date.year);
      final record = widget.daysData[dayData.key] ?? DayRecord();
      if (record.drinkLevel != DrinkLevel.none) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      date = date.add(const Duration(days: 1));
      if (date.year > year) break;
    }
    return maxStreak == 1 ? 0 : maxStreak;
  }

  _DrinkingVsSportStats _calculateDrinkingVsSportStats(YearStats yearStats) {
    final totalTrackedDays =
        yearStats.drinkingDays + yearStats.sport - yearStats.comboDays;
    if (totalTrackedDays > 0) {
      var drinkingPercentage =
          (yearStats.drinkingDays / totalTrackedDays * 100);
      var sportPercentage = (yearStats.sport / totalTrackedDays * 100);
      final total = drinkingPercentage + sportPercentage;
      if (total > 100) {
        drinkingPercentage = (drinkingPercentage / total * 100);
        sportPercentage = (sportPercentage / total * 100);
      }
      return _DrinkingVsSportStats(
        drinkingPercentage: drinkingPercentage,
        sportPercentage: sportPercentage,
      );
    }
    return _DrinkingVsSportStats(drinkingPercentage: 0, sportPercentage: 0);
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 2, 0).day;
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context);
    final availableYears = _getAvailableYears();
    final showSelector = availableYears.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF000000), const Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: showSelector ? _showYearSelector : null,
            child: Row(
              children: [
                Text(
                  '$_selectedYear ${localizations.yearSuffix}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (showSelector) const SizedBox(width: 8),
                if (showSelector)
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withOpacity(0.6),
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                builder: (context) => SettingsBottomSheet(
                  daysData: widget.daysData,
                  onExport: () async {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (widget.onExport != null) {
                      widget.onExport!();
                    } else {
                      try {
                        await Share.share(
                          'Test export from Wobbly Stats',
                          subject: 'Wobbly Test Export',
                        );
                      } catch (e) {
                        print('Test export error: $e');
                      }
                    }
                  },
                  onImportFromFile: () async {
                    // Закрываем bottom sheet
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    // Небольшая задержка, чтобы анимация закрытия завершилась
                    await Future.delayed(const Duration(milliseconds: 300));

                    try {
                      // Выбор файла с помощью file_picker
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        final filePath = result.files.single.path!;
                        final dataManager = DataManager();
                        final success =
                            await dataManager.importFromFile(filePath);

                        if (success) {
                          if (widget.onDataChanged != null) {
                            widget.onDataChanged!();
                          }
                          ScoreSyncManager().sendScore(widget
                              .daysData); // используйте актуальные daysData
                          // Ждём, пока экран перестроится, потом показываем SnackBar
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizations
                                      .translate('import_success')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)
                                  .translate('import_error')),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${AppLocalizations.of(context).translate('import_error')}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onAchievementsReset: () {
                    print('Achievements reset tapped');
                    if (widget.onAchievementsReset != null) {
                      widget
                          .onAchievementsReset!(); // вызываем метод из main.dart
                    }
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  ratingsKey: widget.ratingsKey,
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  List<int> _getAvailableYears() {
    final years = <int>{};
    final currentYear = DateTime.now().year;
    years.add(currentYear);
    final previousYear = currentYear - 1;
    if (_hasAnyDataForYear(previousYear)) {
      years.add(previousYear);
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  bool _hasAnyDataForYear(int year) {
    for (var entry in widget.daysData.entries) {
      final key = entry.key;
      final record = entry.value;
      if (key.startsWith('$year-')) {
        if (record.drinkLevel != DrinkLevel.none || record.hasSport) {
          return true;
        }
      }
    }
    return false;
  }

  void _showYearSelector() {
    final localizations = AppLocalizations.of(context);
    final availableYears = _getAvailableYears();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2B55),
          borderRadius: const BorderRadius.only(
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
              localizations.selectYear,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...availableYears.map((year) {
              return ListTile(
                title: Text(
                  '$year ${localizations.yearSuffix}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: year == _selectedYear
                        ? const Color(0xFF8B5CF6)
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: year == _selectedYear
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: year == _selectedYear
                    ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGlassCard({
    required YearStats yearStats,
    required int currentSoberStreak,
    required int longestSoberStreak,
    required int longestDrinkingStreak,
    required int sportDays,
  }) {
    final localizations = AppLocalizations.of(context);

    return _buildGlassCard(
      child: Column(
        children: [
          _buildSoberStreakCard(
            currentSoberStreak,
            onTap: () => _showStatInfo(
              localizations.translate('stat_sober_streak_title'),
              localizations.translate('stat_sober_streak_description'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  count: longestDrinkingStreak,
                  title: localizations.drinkingStreakDays,
                  backgroundColor: const Color(0xFFBBA0F2),
                  imageAsset: 'assets/icons/drunk_icon.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_drinking_streak_title'),
                    localizations.translate('stat_drinking_streak_description'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  count: longestSoberStreak,
                  title: localizations.maxSoberStreak,
                  backgroundColor: const Color(0xFFA8E6A8),
                  imageAsset: 'assets/icons/max_sober_icon.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_max_sober_streak_title'),
                    localizations
                        .translate('stat_max_sober_streak_description'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  count: yearStats.totalDrinking,
                  title: localizations.totalDrinkingDays,
                  backgroundColor: const Color(0xFFBBA0F2),
                  imageAsset: 'assets/icons/total_drunk_icon.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_total_drinking_days_title'),
                    localizations
                        .translate('stat_total_drinking_days_description'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  count: yearStats.totalDays - yearStats.totalDrinking,
                  title: localizations.totalSoberDays,
                  backgroundColor: const Color(0xFFA8E6A8),
                  imageAsset: 'assets/icons/total_sober_icon.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_total_sober_days_title'),
                    localizations
                        .translate('stat_total_sober_days_description'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  count: yearStats.little,
                  title: localizations.littleLabel,
                  backgroundColor: const Color(0xFFBDC7FA),
                  imageAsset: 'assets/icons/little_normal.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_drink_level_little_title'),
                    localizations
                        .translate('stat_drink_level_little_description'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  count: yearStats.medium,
                  title: localizations.mediumLabel,
                  backgroundColor: const Color(0xFFBDC7FA),
                  imageAsset: 'assets/icons/medium_normal.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_drink_level_medium_title'),
                    localizations
                        .translate('stat_drink_level_medium_description'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  count: yearStats.heavy,
                  title: localizations.heavyLabel,
                  backgroundColor: const Color(0xFFBDC7FA),
                  imageAsset: 'assets/icons/heavy_normal.png',
                  onTap: () => _showStatInfo(
                    localizations.translate('stat_drink_level_heavy_title'),
                    localizations
                        .translate('stat_drink_level_heavy_description'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSportCard(
            sportDays,
            onTap: () => _showStatInfo(
              localizations.translate('stat_sport_days_title'),
              localizations.translate('stat_sport_days_description'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkingVsSportGlassCard(_DrinkingVsSportStats stats) {
    return _buildGlassCard(
      child: PercentageBarView(
        drinkingPercentage: stats.drinkingPercentage,
        sportPercentage: stats.sportPercentage,
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSoberStreakCard(int count, {VoidCallback? onTap}) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF6C7DC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildImage('assets/icons/sober_icon.png', size: 32),
            ),
            Text(
              localizations.currentSoberStreak,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Colors.black),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportCard(int count, {VoidCallback? onTap}) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFEFFFB6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildImage('assets/icons/sport_icon.png', size: 32),
            ),
            Text(
              localizations.sportDaysLabel,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Colors.black),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required int count,
    required String title,
    required Color backgroundColor,
    required String imageAsset,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImage(imageAsset, size: 24),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath, {double size = 32}) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        print('Ошибка загрузки изображения: $assetPath');
        return Icon(Icons.error_outline, size: size, color: Colors.black);
      },
    );
  }

  bool _hasDrinkingDays(int year) {
    for (var entry in widget.daysData.entries) {
      final key = entry.key;
      final record = entry.value;
      if (key.startsWith('$year-') && record.drinkLevel != DrinkLevel.none) {
        return true;
      }
    }
    return false;
  }

  DateTime _getEarliestDateInYear(int year) {
    DateTime earliest = DateTime(year, 12, 31);
    for (var key in widget.daysData.keys) {
      final parts = key.split('-');
      if (parts.length == 3) {
        final dataYear = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        if (dataYear == year) {
          final date = DateTime(dataYear, month, day);
          if (date.isBefore(earliest)) earliest = date;
        }
      }
    }
    return earliest;
  }

  int _calculateSoberStreakFromMonthStart(int year) {
    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final currentMonth = isCurrentYear ? now.month - 1 : 0;
    final currentDay = isCurrentYear ? now.day : 1;

    var maxStreak = 0;
    var currentStreak = 0;

    for (int month = currentMonth; month <= currentMonth; month++) {
      final yearForMonth = year;
      final daysInMonth = _getDaysInMonth(month, yearForMonth);
      final daysToCheck = (month == currentMonth) ? currentDay : daysInMonth;

      for (int day = 1; day <= daysToCheck; day++) {
        final dayData = DayData(day: day, month: month, year: yearForMonth);
        final record = widget.daysData[dayData.key] ?? DayRecord();
        if (record.drinkLevel == DrinkLevel.none) {
          currentStreak++;
          if (currentStreak > maxStreak) maxStreak = currentStreak;
        } else {
          currentStreak = 0;
        }
      }
    }
    return maxStreak;
  }

  int _calculateSoberStreakFromDate(DateTime startDate, int year) {
    final endDate = DateTime(year, 12, 31);
    var maxStreak = 0;
    var currentStreak = 0;
    var date = startDate;

    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      final dayData =
          DayData(day: date.day, month: date.month - 1, year: date.year);
      final record = widget.daysData[dayData.key] ?? DayRecord();
      if (record.drinkLevel == DrinkLevel.none) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      date = date.add(const Duration(days: 1));
      if (date.year > year) break;
    }
    return maxStreak;
  }
}

// Класс для превью
class StatsScreen_Previews extends StatelessWidget {
  const StatsScreen_Previews({super.key});

  @override
  Widget build(BuildContext context) {
    return StatsScreen(
      daysData: {},
      progressDays: 0,
      onExport: () {},
      ratingsKey: GlobalKey<RatingsScreenState>(),
    );
  }
}
