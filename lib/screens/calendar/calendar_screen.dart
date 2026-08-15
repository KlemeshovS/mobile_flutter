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
  final int progressDays;
  final int initialViewMode;

  const CalendarScreen({
    super.key,
    required this.daysData,
    required this.onDayRecordUpdated,
    this.initialScrollOffset,
    this.progressDays = 0,
    this.initialViewMode = 1,
  });

  @override
  State<CalendarScreen> createState() => CalendarScreenState();

  /// Вычисляет начальное смещение скролла до создания State.
  /// Вызывается из MainApp.build() где доступен MediaQuery.
  static double computeInitialScrollOffset(int mode, double screenWidth) {
    final now = DateTime.now();
    final yearIndex = calendarYears.indexOf(now.year);
    if (yearIndex == -1) return 0;

    const double yearLabelHeight = 48.0;
    const double yearBottomPadding = 16.0;
    const double listTopPadding = 8.0;

    final listWidth = screenWidth - 32.0;
    final double monthHeight;
    switch (mode) {
      case 2:
        final gridW = listWidth / 2.0 - 14.0;
        final cellW = gridW / 7.0;
        monthHeight = 42.6 + 6.0 * cellW;
        break;
      case 3:
        final gridW = listWidth / 3.0 - 14.0;
        final cellW = gridW / 7.0;
        monthHeight = 37.8 + 6.0 * cellW;
        break;
      default:
        final gridW = listWidth - 32.0;
        final cellW = gridW / 7.0;
        monthHeight = 80.0 + 6.0 * cellW;
    }

    final int monthsPerRow = mode == 2 ? 2 : (mode == 3 ? 3 : 1);
    final rowsPerYear = (12 / monthsPerRow).ceil();
    final yearTotalHeight = yearLabelHeight + rowsPerYear * monthHeight + yearBottomPadding;
    final yearStart = listTopPadding + yearIndex * yearTotalHeight;

    if (mode == 3) {
      return yearStart;
    } else if (mode == 2) {
      final currentRowIndex = ((now.month - 1) / monthsPerRow).floor();
      final targetRowIndex = (currentRowIndex - 1).clamp(0, rowsPerYear - 1);
      return yearStart + yearLabelHeight + targetRowIndex * monthHeight;
    } else {
      final rowIndex = ((now.month - 1) / monthsPerRow).floor();
      return yearStart + yearLabelHeight + rowIndex * monthHeight;
    }
  }
}

class CalendarScreenState extends State<CalendarScreen> {
  final List<int> _years = calendarYears;
  late final ScrollController _scrollController;
  late int _calendarViewMode;

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
    // Используем режим, переданный из main (уже известен до первого кадра)
    _calendarViewMode = widget.initialViewMode;
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset ?? 0,
    );

    _loadViewMode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      maybeShowMotivation();
    });
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final mode = prefs.getInt('calendarViewMode') ?? 1;
    // Если режим совпадает с уже установленным (передан из main), setState не нужен
    if (mode != _calendarViewMode) {
      setState(() {
        _calendarViewMode = mode;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentMonth();
      });
    }
  }

  Future<void> _setViewMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calendarViewMode', mode);
    // Прыгаем сначала с новым режимом ДО rebuild, чтобы список не мелькал на старой позиции
    _scrollToCurrentMonth(forMode: mode);
    setState(() => _calendarViewMode = mode);
    // После rebuild — корректируем точно (maxScrollExtent обновился)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  IconData get _viewModeIcon {
    switch (_calendarViewMode) {
      case 1: return Icons.view_stream;
      case 2: return Icons.grid_view;
      case 3: return Icons.apps;
      default: return Icons.view_stream;
    }
  }

  // Вычисляет реальную высоту одного месяца с учётом ширины экрана.
  // CalendarGrid использует AspectRatio(1:1) для ячеек, поэтому высота
  // зависит от screenWidth.
  double _monthHeight(int mode, double screenWidth) {
    // Ширина ListView-контента (padding 16 с каждой стороны)
    final listWidth = screenWidth - 32.0;
    switch (mode) {
      case 2:
        // 2 месяца в ряд; margin horiz 2, padding horiz 5 с каждой стороны
        final gridW = listWidth / 2.0 - 14.0;
        final cellW = gridW / 7.0;
        // 16 (margin+pad) + 15 (имя) + 11.6 (строка дней нед.) + 6*cell
        return 42.6 + 6.0 * cellW;
      case 3:
        // 3 месяца в ряд
        final gridW = listWidth / 3.0 - 14.0;
        final cellW = gridW / 7.0;
        // 16 + 12.6 + 9.2 + 6*cell
        return 37.8 + 6.0 * cellW;
      default:
        // 1 месяц в ряд; margin horiz 4, padding horiz 12 с каждой стороны
        final gridW = listWidth - 32.0;
        final cellW = gridW / 7.0;
        // 36 (margin+pad) + 28.8 (имя) + 15.2 (строка дней нед.) + 6*cell
        return 80.0 + 6.0 * cellW;
    }
  }

  // Вычисляет целевое смещение для заданного режима
  double _calculateOffset(int mode) {
    final now = DateTime.now();
    final yearIndex = calendarYears.indexOf(now.year);
    if (yearIndex == -1) return 0;

    const double yearLabelHeight = 48.0;
    const double yearBottomPadding = 16.0;
    const double listTopPadding = 8.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final monthHeight = _monthHeight(mode, screenWidth);

    final int monthsPerRow = mode == 2 ? 2 : (mode == 3 ? 3 : 1);

    final rowsPerYear = (12 / monthsPerRow).ceil();
    final yearTotalHeight = yearLabelHeight + rowsPerYear * monthHeight + yearBottomPadding;
    final yearStart = listTopPadding + yearIndex * yearTotalHeight;

    if (mode == 3) {
      return yearStart;
    } else if (mode == 2) {
      final currentRowIndex = ((now.month - 1) / monthsPerRow).floor();
      final targetRowIndex = (currentRowIndex - 1).clamp(0, rowsPerYear - 1);
      return yearStart + yearLabelHeight + targetRowIndex * monthHeight;
    } else {
      final rowIndex = ((now.month - 1) / monthsPerRow).floor();
      return yearStart + yearLabelHeight + rowIndex * monthHeight;
    }
  }

  void _scrollToCurrentMonth({int? forMode}) {
    if (!_scrollController.hasClients) return;
    final offset = _calculateOffset(forMode ?? _calendarViewMode);
    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
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

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isPositive = widget.progressDays >= 0;
    final color = isPositive ? Colors.greenAccent : Colors.pinkAccent;
    final absValue = widget.progressDays.abs();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Очки слева
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$absValue',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    loc.translate('progress_unit'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                isPositive
                    ? loc.translate('progress_label_positive')
                    : loc.translate('progress_label_negative'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Кнопка переключения режима
          GestureDetector(
            onTap: () {
              final newMode = _calendarViewMode == 3 ? 1 : _calendarViewMode + 1;
              _setViewMode(newMode);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                _viewModeIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GradientBackground(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _years.length,
                    itemBuilder: (context, index) {
                      return YearSection(
                        year: _years[index],
                        daysData: widget.daysData,
                        onDaySelected: _onDaySelected,
                        onDayLongPressed: _onDayLongPressed,
                        calendarViewMode: _calendarViewMode,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}