// lib/screens/calendar/calendar_screen.dart
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/widgets/gradient_background.dart';
import 'package:wobbly/screens/day_selection/day_selection_sheet.dart';
import 'year_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final Function(DayData, DayRecord) onDayRecordUpdated;
  final double? initialScrollOffset;

  const CalendarScreen({
    super.key,
    required this.daysData,
    required this.onDayRecordUpdated,
    this.initialScrollOffset,
  });

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  final List<int> _years = calendarYears;
  late final ScrollController _scrollController;

  void maybeShowMotivation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowMotivation();
    });
  }

  static const String _prefLastMotivationDate = 'last_motivation_date';
// Для тестов можно выставить в true, чтобы показывать при каждом открытии
  final bool _debugShowEveryTime = false; // включение маотивационных сообщений на постоянку

  Future<void> _maybeShowMotivation() async {
    // Не показываем, если нет данных (после туториала)
    if (widget.daysData.isEmpty) return;

    // Определяем вчерашний день
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayData = DayData(
      day: yesterday.day,
      month: yesterday.month - 1,
      year: yesterday.year,
    );
    final record = widget.daysData[yesterdayData.key] ?? DayRecord();

    // Определяем категорию
    String category;
    bool isDrinking;
    if (record.drinkLevel == DrinkLevel.none) {
      if (record.hasSport) {
        category = 'sport';
        isDrinking = false;
      } else {
        category = 'none';
        isDrinking = false;
      }
    } else if (record.drinkLevel == DrinkLevel.little) {
      if (record.hasSport) {
        category = 'little_sport';
        isDrinking = true;
      } else {
        category = 'little';
        isDrinking = true;
      }
    } else if (record.drinkLevel == DrinkLevel.medium) {
      if (record.hasSport) {
        category = 'medium_sport';
        isDrinking = true;
      } else {
        category = 'medium';
        isDrinking = true;
      }
    } else if (record.drinkLevel == DrinkLevel.heavy) {
      if (record.hasSport) {
        category = 'heavy_sport';
        isDrinking = true;
      } else {
        category = 'heavy';
        isDrinking = true;
      }
    } else if (record.drinkLevel == DrinkLevel.medium) {
      category = 'medium';
      isDrinking = true;
    } else if (record.drinkLevel == DrinkLevel.heavy) {
      category = 'heavy';
      isDrinking = true;
    } else {
      // unknown – не должно быть, но на всякий случай пропускаем
      return;
    }

    // Проверяем, нужно ли показывать сегодня
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();

    if (!_debugShowEveryTime) {
      final lastShown = prefs.getString(_prefLastMotivationDate);
      if (lastShown == todayStr) {
        return; // уже показывали сегодня
      }
    }

    // Запоминаем дату показа
    await prefs.setString(_prefLastMotivationDate, todayStr);

    // Получаем заголовок по категории
    String title;
    switch (category) {
      case 'none':
        title = AppLocalizations.of(context).motivationTitleNone;
        break;
      case 'sport':
        title = AppLocalizations.of(context).motivationTitleSport;
        break;
      case 'little':
        title = AppLocalizations.of(context).motivationTitleLittle;
        break;
      case 'little_sport':
        title = AppLocalizations.of(context).motivationTitleLittleSport;
        break;
      case 'medium_sport':
        title = AppLocalizations.of(context).motivationTitleMedium;
        break;
      case 'heavy_sport':
        title = AppLocalizations.of(context).motivationTitleHeavy;
        break;
      case 'medium':
        title = AppLocalizations.of(context).motivationTitleMedium;
        break;
      case 'heavy':
        title = AppLocalizations.of(context).motivationTitleHeavy;
        break;
      default:
        title = '';
    }

    // Получаем случайный текст
    final message = AppLocalizations.of(context).getRandomMotivationText(isDrinking);

    _showMotivationSheet(title, message);
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void _showMotivationSheet(String title, String message) {
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
                message,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _targetOffset; // новое поле

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset ?? 0,
    );

    // Если смещение не было передано (старый запуск), прокручиваем после сборки
    if (widget.initialScrollOffset == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentMonth();
      });
    }
    // Добавляем вызов мотивационного сообщения после сборки виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      maybeShowMotivation();
    });
  }

  void _scrollToCurrentMonth() {
    final now = DateTime.now();
    final yearIndex = calendarYears.indexOf(now.year);
    if (yearIndex == -1) return;
    const double monthHeight = 300.0;
    const double yearHeaderHeight = 70.0;
    final offset = yearIndex * (12 * monthHeight + yearHeaderHeight) +
        (now.month - 1) * monthHeight;
    _scrollController.jumpTo(offset);
  }

  void _onDaySelected(DayData dayData) {
    if (dayData.isFuture) return;

    final currentRecord = widget.daysData[dayData.key] ?? DayRecord();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DaySelectionSheet(
        dayData: dayData,
        currentRecord: currentRecord,
        onRecordSelected: (newRecord) {
          widget.onDayRecordUpdated(dayData, newRecord);
        },
      ),
    );
  }

  void _onDayLongPressed(DayData dayData) {
    if (dayData.isFuture) return;

    // Вибрация при долгом нажатии
    Vibration.vibrate(duration: 50);   // 50 миллисекунд – короткий тактильный отклик

    final currentRecord = widget.daysData[dayData.key] ?? DayRecord();
    var newRecord = currentRecord.copyWith(
      hasSport: !currentRecord.hasSport,
    );

    // Если после переключения не осталось ни алкоголя, ни спорта – удаляем запись
    if (newRecord.drinkLevel == DrinkLevel.none && !newRecord.hasSport) {
      newRecord = DayRecord(drinkLevel: DrinkLevel.unknown);
    }

    widget.onDayRecordUpdated(dayData, newRecord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // Не добавляем отступ снизу
        child: GradientBackground(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _years.length,
              itemBuilder: (context, index) {
                return YearSection(
                  year: _years[index],
                  daysData: widget.daysData,
                  onDaySelected: _onDaySelected,
                  onDayLongPressed: _onDayLongPressed,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}