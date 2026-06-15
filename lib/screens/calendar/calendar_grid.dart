import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/utils/localization.dart';
import 'day_cell.dart';


class CalendarGrid extends StatelessWidget {
  final int month;
  final int year;
  final Map<String, DayRecord> daysData;
  final Function(DayData) onDaySelected;
  final Function(DayData) onDayLongPressed;
  final int calendarViewMode;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.year,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
    this.calendarViewMode = 1,
  });

  double get _fontSize {
    switch (calendarViewMode) {
      case 3: return 7;
      case 2: return 10;
      default: return 14;
    }
  }

  double get _cellPadding {
    switch (calendarViewMode) {
      case 3: return 1.0;
      case 2: return 2.0;
      default: return 3.0;
    }
  }

  double get _weekdayFontSize {
    switch (calendarViewMode) {
      case 3: return 6;
      case 2: return 8;
      default: return 11;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 2, 0).day;
    final firstWeekday = DateTime(year, month + 1, 1).weekday - 1; // 0=Mon

    return Column(
      children: [
        // Заголовки дней недели — через Expanded, как в friend_calendar_grid
        _buildWeekdaysRow(context),
        const SizedBox(height: 2),
        // 6 строк дней
        ...List.generate(6, (row) {
          return Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final day = index - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(
                  child: AspectRatio(aspectRatio: 1, child: SizedBox()),
                );
              }
              final dayData = DayData(day: day, month: month, year: year);
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DayCell(
                    day: day,
                    month: month,
                    year: year,
                    daysData: daysData,
                    onTap: () => onDaySelected(dayData),
                    onLongPress: () => onDayLongPressed(dayData),
                    fontSize: _fontSize,
                    cellPadding: _cellPadding,
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildWeekdaysRow(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: localizations.weekdaysShort.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[400],
              fontSize: _weekdayFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
