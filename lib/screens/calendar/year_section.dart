import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/utils/localization.dart';
import 'month_view.dart';

class YearSection extends StatelessWidget {
  final int year;
  final Map<String, DayRecord> daysData;
  final Function(DayData) onDaySelected;
  final Function(DayData) onDayLongPressed;
  final int calendarViewMode;

  const YearSection({
    super.key,
    required this.year,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
    this.calendarViewMode = 1,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();

    final months = List.generate(12, (month) {
      final isCurrentMonth = now.year == year && now.month - 1 == month;
      return MonthView(
        month: month,
        year: year,
        monthName: localizations.getMonthName(month),
        isCurrentMonth: isCurrentMonth,
        daysData: daysData,
        onDaySelected: onDaySelected,
        onDayLongPressed: onDayLongPressed,
        calendarViewMode: calendarViewMode,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок года
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              '$year',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Месяцы в зависимости от режима
        if (calendarViewMode == 1)
          Column(children: months)
        else
          ..._buildGrid(months, calendarViewMode == 2 ? 2 : 3),

        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildGrid(List<Widget> months, int columns) {
    final rows = <Widget>[];
    for (int i = 0; i < months.length; i += columns) {
      final end = (i + columns).clamp(0, months.length);
      final rowItems = <Widget>[];
      for (int j = i; j < end; j++) {
        rowItems.add(Expanded(child: months[j]));
      }
      // Дополняем пустыми ячейками если строка неполная
      while (rowItems.length < columns) {
        rowItems.add(const Expanded(child: SizedBox.shrink()));
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowItems,
      ));
    }
    return rows;
  }
}
