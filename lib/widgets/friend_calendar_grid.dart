import 'package:flutter/material.dart';
import 'package:wobbly/models/friend_calendar_model.dart';
import 'package:intl/intl.dart';

class FriendCalendarGrid extends StatefulWidget {
  final FriendCalendarResponse calendar;

  const FriendCalendarGrid({super.key, required this.calendar});

  @override
  State<FriendCalendarGrid> createState() => _FriendCalendarGridState();
}

class _FriendCalendarGridState extends State<FriendCalendarGrid> {
  bool _isExpanded = false;
  ScrollController _scrollController = ScrollController();

  DateTime? get _lastUpdatedDate {
    try {
      return DateTime.parse(widget.calendar.updatedAt).toLocal();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Последние 4 месяца (0-based month как на сервере)
  List<({int year, int month})> get _last4Months {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final date = DateTime(now.year, now.month - 3 + i);
      return (year: date.year, month: date.month - 1); // 0-based
    });
  }

  // Все месяцы из данных + последние 12
  List<({int year, int month})> get _allMonths {
    final now = DateTime.now();
    final last12 = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - 11 + i);
      return (year: date.year, month: date.month - 1);
    });

    final fromData = <String, ({int year, int month})>{};
    for (final key in widget.calendar.days.keys) {
      final parts = key.split('-');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (year != null && month != null && month >= 0 && month <= 11) {
          final id = '$year-$month';
          fromData[id] = (year: year, month: month);
        }
      }
    }

    for (final ym in last12) {
      final id = '${ym.year}-${ym.month}';
      fromData.putIfAbsent(id, () => ym);
    }

    final result = fromData.values.toList();
    result.sort((a, b) => a.year != b.year ? a.year - b.year : a.month - b.month);
    return result;
  }

  String _monthName(int month0based) {
    // month здесь 0-based, DateFormat нужен 1-based
    final date = DateTime(2000, month0based + 1);
    return DateFormat('MMMM', Localizations.localeOf(context).toString())
        .format(date)
        .capitalize();
  }

  bool _isCurrentMonth(int year, int month0based) {
    final now = DateTime.now();
    return now.year == year && (now.month - 1) == month0based;
  }

  void _expand(String targetId) {
    double offset = 0;
    if (targetId.isNotEmpty) {
      final parts = targetId.split('-');
      if (parts.length == 2) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (year != null && month != null) {
          final months = _allMonths;
          final index = months.indexWhere((m) => m.year == year && m.month == month);
          if (index > 0) {
            final screenWidth = MediaQuery.of(context).size.width - 32;
            final cellSize = screenWidth / 7;
            for (int i = 0; i < index; i++) {
              final ym = months[i];
              final daysInMonth = DateTime(ym.year, ym.month + 2, 0).day;
              final firstWeekday = DateTime(ym.year, ym.month + 1, 1).weekday - 1;
              final rows = ((firstWeekday + daysInMonth) / 7).ceil();
              offset += 16 + 24 + 8 + 20 + 4 + (rows * cellSize) + 16 + 12;
            }
          }
        }
      }
    }
// Вычитаем одну строку — корректировка
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final cellSize = screenWidth / 7;
    offset += cellSize * 3;
    _scrollController.dispose();
    _scrollController = ScrollController(initialScrollOffset: offset);

    setState(() {
      _isExpanded = true;
    });
  }

  void _collapse() {
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return _buildCompact();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: const ValueKey('expanded'),
        child: _buildExpanded(),
      ),
    );
  }

  Widget _buildCompact() {
    final months = _last4Months;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: months.map((ym) {
        return GestureDetector(
          onTap: () => _expand('${ym.year}-${ym.month}'),
          child: _MiniMonthView(
            year: ym.year,
            month: ym.month,
            days: widget.calendar.days,
            lastUpdatedDate: _lastUpdatedDate,
            monthName: _monthName(ym.month),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpanded() {
    final months = _allMonths;

    return SizedBox(
      height: 500,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 34),
              itemCount: months.length,
              itemBuilder: (context, index) {
                final ym = months[index];
                // Считаем точную высоту этого месяца
                final daysInMonth = DateTime(ym.year, ym.month + 2, 0).day;
                final firstWeekday = DateTime(ym.year, ym.month + 1, 1).weekday - 1;
                final rows = ((firstWeekday + daysInMonth) / 7).ceil();
                final screenWidth = MediaQuery.of(context).size.width - 32;
                final cellSize = screenWidth / 7;
                final itemHeight = 16 + 24 + 8 + 20 + 4 + (rows * cellSize) + 16 + 12;

                return GestureDetector(
                  onTap: _collapse,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _FullMonthView(
                      year: ym.year,
                      month: ym.month,
                      days: widget.calendar.days,
                      lastUpdatedDate: _lastUpdatedDate,
                      monthName: _monthName(ym.month),
                      isCurrentMonth: _isCurrentMonth(ym.year, ym.month),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text(
              'Нажмите на месяц чтобы свернуть',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Компактный месяц ────────────────────────────────────────────────────────

class _MiniMonthView extends StatelessWidget {
  final int year;
  final int month; // 0-based
  final Map<String, int> days;
  final DateTime? lastUpdatedDate;
  final String monthName;

  const _MiniMonthView({
    required this.year,
    required this.month,
    required this.days,
    required this.lastUpdatedDate,
    required this.monthName,
  });

  int get _daysInMonth {
    return DateTime(year, month + 2, 0).day;
  }

  int get _firstWeekday {
    final wd = DateTime(year, month + 1, 1).weekday; // 1=Mon..7=Sun
    return wd - 1; // 0=Mon..6=Sun
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 2),
          Text(
            monthName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B3A91),
            ),
          ),
          const SizedBox(height: 2),
          // Дни недели
          Row(
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.grey.shade500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 1),
          // 6 строк дней
          ...List.generate(6, (row) {
            return Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final day = index - _firstWeekday + 1;
                if (day < 1 || day > _daysInMonth) {
                  return const Expanded(child: AspectRatio(aspectRatio: 1, child: SizedBox()));
                }
                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _SmallDayCell(
                      day: day,
                      month: month,
                      year: year,
                      days: days,
                      lastUpdatedDate: lastUpdatedDate,
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
        ),
    );
  }
}

// ─── Полный месяц (expanded) ──────────────────────────────────────────────────

class _FullMonthView extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, int> days;
  final DateTime? lastUpdatedDate;
  final String monthName;
  final bool isCurrentMonth;

  const _FullMonthView({
    required this.year,
    required this.month,
    required this.days,
    required this.lastUpdatedDate,
    required this.monthName,
    required this.isCurrentMonth,
  });

  int get _daysInMonth => DateTime(year, month + 2, 0).day;
  int get _firstWeekday => DateTime(year, month + 1, 1).weekday - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              monthName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCurrentMonth
                    ? const Color(0xFF4B3A91)
                    : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate(6, (row) {
            return Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final day = index - _firstWeekday + 1;
                if (day < 1 || day > _daysInMonth) {
                  return const Expanded(child: AspectRatio(aspectRatio: 1, child: SizedBox()));
                }
                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _LargeDayCell(
                      day: day,
                      month: month,
                      year: year,
                      days: days,
                      lastUpdatedDate: lastUpdatedDate,
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Маленькая ячейка ────────────────────────────────────────────────────────

class _SmallDayCell extends StatelessWidget {
  final int day;
  final int month; // 0-based
  final int year;
  final Map<String, int> days;
  final DateTime? lastUpdatedDate;

  const _SmallDayCell({
    required this.day,
    required this.month,
    required this.year,
    required this.days,
    required this.lastUpdatedDate,
  });

  String get _key => '$year-$month-$day';
  int? get _level => days[_key];

  DateTime get _thisDate => DateTime(year, month + 1, day);

  bool get _isFuture {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _thisDate.isAfter(startOfToday);
  }

  bool get _isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month + 1 && now.day == day;
  }

  bool get _isUnknown {
    final updated = lastUpdatedDate;
    if (updated == null) return false;
    final startOfCell = DateTime(_thisDate.year, _thisDate.month, _thisDate.day);
    final startOfUpdated = DateTime(updated.year, updated.month, updated.day);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return startOfCell.isAfter(startOfUpdated) && !startOfCell.isAfter(startOfToday);
  }

  Color get _cellColor {
    if (_isFuture || _isUnknown) return Colors.transparent;
    final lvl = _level;
    if (lvl == null) return Colors.transparent;
    return _colorForLevel(lvl);
  }

  bool get _hasSport {
    final lvl = _level;
    if (lvl == null) return false;
    return lvl == 4 || lvl == 5 || lvl == 6 || lvl == 7;
  }

  bool get _hasAlcohol {
    final lvl = _level;
    if (lvl == null) return false;
    return lvl == 1 || lvl == 2 || lvl == 3 || lvl == 5 || lvl == 6 || lvl == 7;
  }

  Color _alcoholColor(int lvl) {
    switch (lvl) {
      case 1:
      case 5:
        return const Color(0xFFF7B0BB); // little border
      case 2:
      case 6:
        return const Color(0xFFEA0505); // medium border
      case 3:
      case 7:
        return const Color(0xFF9C27B0); // heavy border
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: CustomPaint(
          painter: _DayCellPainter(
            isFuture: _isFuture,
            isUnknown: _isUnknown,
            isToday: _isToday,
            hasSport: _hasSport,
            hasAlcohol: _hasAlcohol,
            cellColor: _cellColor,
            alcoholColor: _level != null ? _alcoholColor(_level!) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 9,
                color: _isFuture
                    ? Colors.grey.withOpacity(0.4)
                    : _isUnknown
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Большая ячейка (expanded) ────────────────────────────────────────────────

class _LargeDayCell extends StatelessWidget {
  final int day;
  final int month;
  final int year;
  final Map<String, int> days;
  final DateTime? lastUpdatedDate;

  const _LargeDayCell({
    required this.day,
    required this.month,
    required this.year,
    required this.days,
    required this.lastUpdatedDate,
  });

  String get _key => '$year-$month-$day';
  int? get _level => days[_key];

  DateTime get _thisDate => DateTime(year, month + 1, day);

  bool get _isFuture {
    final today = DateTime.now();
    return _thisDate.isAfter(DateTime(today.year, today.month, today.day));
  }

  bool get _isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month + 1 && now.day == day;
  }

  bool get _isUnknown {
    final updated = lastUpdatedDate;
    if (updated == null) return false;
    final startOfCell = DateTime(_thisDate.year, _thisDate.month, _thisDate.day);
    final startOfUpdated = DateTime(updated.year, updated.month, updated.day);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return startOfCell.isAfter(startOfUpdated) && !startOfCell.isAfter(startOfToday);
  }

  bool get _hasSport {
    final lvl = _level;
    return lvl == 4 || lvl == 5 || lvl == 6 || lvl == 7;
  }

  bool get _hasAlcohol {
    final lvl = _level;
    return lvl == 1 || lvl == 2 || lvl == 3 || lvl == 5 || lvl == 6 || lvl == 7;
  }

  Color _alcoholColor(int lvl) {
    switch (lvl) {
      case 1:
      case 5:
        return const Color(0xFFFF0072);
      case 2:
      case 6:
        return const Color(0xFF9126EF);
      case 3:
      case 7:
        return const Color(0xFF482FED);
      default:
        return Colors.transparent;
    }
  }

  Color get _cellColor {
    if (_isFuture || _isUnknown) return Colors.transparent;
    final lvl = _level;
    if (lvl == null) return Colors.transparent;
    return _colorForLevel(lvl);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: CustomPaint(
        painter: _DayCellPainter(
          isFuture: _isFuture,
          isUnknown: _isUnknown,
          isToday: _isToday,
          hasSport: _hasSport,
          hasAlcohol: _hasAlcohol,
          cellColor: _cellColor,
          alcoholColor: _level != null ? _alcoholColor(_level!) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: _isToday ? FontWeight.w500 : FontWeight.normal,
              color: _isFuture
                  ? Colors.grey
                  : _isUnknown
                  ? Colors.grey.withOpacity(0.5)
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CustomPainter для ячейки ─────────────────────────────────────────────────

class _DayCellPainter extends CustomPainter {
  final bool isFuture;
  final bool isUnknown;
  final bool isToday;
  final bool hasSport;
  final bool hasAlcohol;
  final Color cellColor;
  final Color alcoholColor;

  const _DayCellPainter({
    required this.isFuture,
    required this.isUnknown,
    required this.isToday,
    required this.hasSport,
    required this.hasAlcohol,
    required this.cellColor,
    required this.alcoholColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    if (!isFuture && !isUnknown) {
      if (hasSport && hasAlcohol) {
        // Зелёный фон + цветная обводка
        paint.color = const Color(0xFFC7FF00).withOpacity(0.4);
        canvas.drawCircle(center, radius, paint);

        // Обводка цвета алкоголя
        paint.color = alcoholColor;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(center, radius - 1, paint);
        paint.style = PaintingStyle.fill;
      } else if (cellColor != Colors.transparent) {
        paint.color = cellColor;
        canvas.drawCircle(center, radius, paint);
      }
    }

    if (isToday) {
      paint.color = const Color(0xFF8B5CF6);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(center, radius - 1, paint);
    }
  }


  @override
  bool shouldRepaint(_DayCellPainter old) => false;
}

// ─── Цвета по уровню ──────────────────────────────────────────────────────────

Color _colorForLevel(int level) {
  switch (level) {
    case 1: // little
      return const Color(0xFFF7B0BB).withOpacity(0.7);
    case 2: // medium
      return const Color(0xFFEA0505).withOpacity(0.7);
    case 3: // heavy
      return const Color(0xFF9C27B0).withOpacity(0.7);
    case 4: // sport
      return const Color(0xFFC7FF00).withOpacity(0.4);
    case 5: // little+sport
    case 6: // medium+sport
    case 7: // heavy+sport
      return const Color(0xFFC7FF00).withOpacity(0.4);
    default:
      return Colors.transparent;
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}