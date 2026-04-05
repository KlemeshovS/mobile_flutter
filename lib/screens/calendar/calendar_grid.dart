import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/utils/localization.dart';
import 'day_cell.dart';


class CalendarGrid extends StatelessWidget {
  final int month;
  final int year;
  final Map<String, DayRecord> daysData;
  final Function(DayData) onDaySelected;
  final Function(DayData) onDayLongPressed;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.year,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(month, year);
    final firstWeekday = _getFirstWeekday(month, year);
    final dayCells = _generateDayCells(daysInMonth, firstWeekday);

    return Column(
      children: [
        // Дни недели
        _buildWeekdaysRow(context),
        SizedBox(height: 8),
        // Сетка дней
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 1.0,
          ),
          itemCount: dayCells.length,
          itemBuilder: (context, index) => dayCells[index],
        ),
      ],
    );
  }

  Widget _buildWeekdaysRow(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: localizations.weekdaysShort.map((day) {
        return Text(
          day,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _generateDayCells(int daysInMonth, int firstWeekday) {
    final List<Widget> cells = [];

    // Пустые ячейки в начале месяца
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(Container());
    }

    // Ячейки с днями месяца
    for (int day = 1; day <= daysInMonth; day++) {
      final dayData = DayData(day: day, month: month, year: year);
      final record = daysData[dayData.key] ?? DayRecord();

      cells.add(
        DayCell(
          day: day,
          month: month,
          year: year,
          daysData: daysData,
          onTap: () => onDaySelected(dayData),
          onLongPress: () => onDayLongPressed(dayData),
        ),
      );
    }

    return cells;
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 2, 0).day;
  }

  int _getFirstWeekday(int month, int year) {
    final firstDay = DateTime(year, month + 1, 1);
    // 1 = Monday, ..., 7 = Sunday
    int weekday = firstDay.weekday;
    // Convert to 0-6 where 0 = Monday
    return weekday - 1;
  }
}