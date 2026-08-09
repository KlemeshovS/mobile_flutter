import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wobbly/models/friend_calendar_model.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/utils/calendar_utils.dart';
import 'package:wobbly/widgets/week_stats_view.dart';
import 'package:wobbly/widgets/percentage_bar_view.dart';

class FriendStatsView extends StatelessWidget {
  final FriendCalendarResponse calendar;

  const FriendStatsView({super.key, required this.calendar});

  // Конвертация raw-данных сервера в DayRecord (ключи остаются 0-based для внутренних расчётов)
  Map<String, DayRecord> get _dayRecords {
    return calendar.days.map(
      (key, value) => MapEntry(key, DayRecord.fromLegacy(value)),
    );
  }

  // Те же записи, но с ключами в формате 1-based месяцев — для WeekStatsView,
  // который строит DateTime(year, month, day) и ожидает 1-based.
  Map<String, DayRecord> get _dayRecordsForWeekView {
    return calendar.days.map((key, value) {
      final parts = key.split('-');
      String convertedKey = key;
      if (parts.length == 3) {
        final month = int.tryParse(parts[1]);
        if (month != null) {
          convertedKey = '${parts[0]}-${month + 1}-${parts[2]}';
        }
      }
      return MapEntry(convertedKey, DayRecord.fromLegacy(value));
    });
  }

  DateTime? get _updatedDate {
    try {
      return DateTime.parse(calendar.updatedAt);
    } catch (_) {
      return null;
    }
  }

  int get _currentYear => (_updatedDate ?? DateTime.now()).year;

  // ── Расчёт статистики за год ──────────────────────────────────────────────

  _YearStats _calculateYearStats() {
    final today = _updatedDate ?? DateTime.now();
    final year = today.year;
    final currentMonth = today.month - 1; // 0-based
    final currentDay = today.day;
    final records = _dayRecords;

    int little = 0, medium = 0, heavy = 0, sport = 0, littleSport = 0;
    int totalDays = 0, drinkingDays = 0;

    for (int month = 0; month <= 11; month++) {
      if (month > currentMonth) continue;
      final daysInMonth = CalendarUtils.daysInMonth(month, year);
      final lastDay = month == currentMonth ? currentDay : daysInMonth;
      totalDays += lastDay;

      for (int day = 1; day <= lastDay; day++) {
        final record = records['$year-$month-$day'] ?? DayRecord();
        final level = record.drinkLevel;

        if (record.hasSport) sport++;
        if (level == DrinkLevel.little) {
          little++;
          drinkingDays++;
        } else if (level == DrinkLevel.medium) {
          medium++;
          drinkingDays++;
        } else if (level == DrinkLevel.heavy) {
          heavy++;
          drinkingDays++;
        }
        if (record.hasSport && level != DrinkLevel.none) littleSport++;
      }
    }

    return _YearStats(
      little: little,
      medium: medium,
      heavy: heavy,
      sport: sport,
      littleSport: littleSport,
      drinkingDays: drinkingDays,
      totalDays: totalDays,
      totalDrinking: little + medium + heavy,
    );
  }

  // Текущий трезвый стрик (от даты обновления назад)
  int _calculateSoberStreak() {
    final today = _updatedDate ?? DateTime.now();
    final records = _dayRecords;
    int streak = 0;
    for (int offset = 0; offset < 2000; offset++) {
      final date = today.subtract(Duration(days: offset));
      final key = '${date.year}-${date.month - 1}-${date.day}';
      final record = records[key] ?? DayRecord();
      if (record.drinkLevel != DrinkLevel.none) return streak;
      streak++;
    }
    return streak;
  }

  // Максимальный стрик с алкоголем в текущем году
  int _calculateDrinkingStreak() {
    final today = _updatedDate ?? DateTime.now();
    final records = _dayRecords;
    int maxStreak = 0, current = 0;
    var date = DateTime(_currentYear, 1, 1);
    while (!date.isAfter(today)) {
      final key = '${date.year}-${date.month - 1}-${date.day}';
      final record = records[key] ?? DayRecord();
      if (record.drinkLevel != DrinkLevel.none) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else {
        current = 0;
      }
      date = date.add(const Duration(days: 1));
    }
    return maxStreak <= 1 ? 0 : maxStreak;
  }

  // Максимальный трезвый стрик в текущем году
  int _calculateMaxSoberStreak() {
    final today = _updatedDate ?? DateTime.now();
    final records = _dayRecords;
    int maxStreak = 0, current = 0;
    var date = DateTime(_currentYear, 1, 1);
    while (!date.isAfter(today)) {
      final key = '${date.year}-${date.month - 1}-${date.day}';
      final record = records[key] ?? DayRecord();
      if (record.drinkLevel != DrinkLevel.none) {
        current = 0;
      } else {
        current++;
        if (current > maxStreak) maxStreak = current;
      }
      date = date.add(const Duration(days: 1));
    }
    return maxStreak;
  }

  String _formattedDate(AppLocalizations loc) {
    final d = _updatedDate;
    if (d == null) return '';
    final formatted = DateFormat('dd.MM.yyyy').format(d);
    return loc.translate('friend_stats_as_of').replaceFirst('%s', formatted);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final yearStats = _calculateYearStats();
    final soberStreak = _calculateSoberStreak();
    final drinkingStreak = _calculateDrinkingStreak();
    final maxSoberStreak = _calculateMaxSoberStreak();
    final records = _dayRecords;

    final totalTracked = yearStats.drinkingDays + yearStats.sport - yearStats.littleSport;
    final hasBothActivities = totalTracked > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.translate('friend_stats_title'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            Text(
              _formattedDate(loc),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.38),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Основной блок карточек
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              // Трезвый стрик — широкая строка
              _buildBigStatRow(
                imageAsset: 'assets/icons/sober_icon.png',
                label: loc.currentSoberStreak,
                value: soberStreak,
                color: const Color(0xFFF6C7DC),
              ),
              const SizedBox(height: 8),

              // Стрик алко | макс трезвый
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/drunk_icon.png',
                      label: loc.drinkingStreakDays,
                      value: drinkingStreak,
                      color: const Color(0xFFBBA0F2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/max_sober_icon.png',
                      label: loc.maxSoberStreak,
                      value: maxSoberStreak,
                      color: const Color(0xFFA8E6A8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Всего пьяных | всего трезвых
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/total_drunk_icon.png',
                      label: loc.totalDrinkingDays,
                      value: yearStats.totalDrinking,
                      color: const Color(0xFFBBA0F2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/total_sober_icon.png',
                      label: loc.totalSoberDays,
                      value: yearStats.totalDays - yearStats.totalDrinking,
                      color: const Color(0xFFA8E6A8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Уровни: немного / средне / тяжело
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/little_normal.png',
                      label: loc.littleLabel,
                      value: yearStats.little,
                      color: const Color(0xFFBDC7FA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/medium_normal.png',
                      label: loc.mediumLabel,
                      value: yearStats.medium,
                      color: const Color(0xFFBDC7FA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      imageAsset: 'assets/icons/heavy_normal.png',
                      label: loc.heavyLabel,
                      value: yearStats.heavy,
                      color: const Color(0xFFBDC7FA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Спорт — широкая строка
              _buildBigStatRow(
                imageAsset: 'assets/icons/sport_icon.png',
                label: loc.sportDaysLabel,
                value: yearStats.sport,
                color: const Color(0xFFEFFFB6),
              ),
            ],
          ),
        ),

        // Алко vs Спорт бар (только если есть данные)
        if (hasBothActivities) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: PercentageBarView(
              drinkingPercentage: (yearStats.drinkingDays /
                      (yearStats.drinkingDays + yearStats.sport) *
                      100)
                  .roundToDouble(),
              sportPercentage: (yearStats.sport /
                      (yearStats.drinkingDays + yearStats.sport) *
                      100)
                  .roundToDouble(),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Статистика по дням недели
        WeekStatsView(daysData: _dayRecordsForWeekView, selectedYear: _currentYear),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── Вспомогательные виджеты ───────────────────────────────────────────────

  Widget _buildBigStatRow({
    required String imageAsset,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            imageAsset,
            width: 32,
            height: 32,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.circle_outlined, size: 32, color: Colors.black38),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String imageAsset,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAsset,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.circle_outlined, size: 24, color: Colors.black38),
              ),
              const SizedBox(width: 6),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Внутренняя модель статистики ──────────────────────────────────────────────

class _YearStats {
  final int little, medium, heavy, sport, littleSport;
  final int drinkingDays, totalDays, totalDrinking;

  const _YearStats({
    required this.little,
    required this.medium,
    required this.heavy,
    required this.sport,
    required this.littleSport,
    required this.drinkingDays,
    required this.totalDays,
    required this.totalDrinking,
  });
}
