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

  const YearSection({
    super.key,
    required this.year,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final isCurrentYear = now.year == year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              '$year',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isCurrentYear ? Colors.white : Colors.white,
              ),
            ),
          ),
        ),
        ...List.generate(12, (month) {
          final isCurrentMonth = now.year == year && now.month - 1 == month;

          return MonthView(
            month: month,
            year: year,
            monthName: localizations.getMonthName(month),
            isCurrentMonth: isCurrentMonth,
            daysData: daysData,
            onDaySelected: onDaySelected,
            onDayLongPressed: onDayLongPressed,
          );
        }),
        SizedBox(height: 16),
      ],
    );
  }
}
