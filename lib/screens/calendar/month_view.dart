// lib/screens/calendar/month_view.dart
import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/screens/calendar/calendar_grid.dart';

class MonthView extends StatelessWidget {
  final int month;
  final int year;
  final String monthName;
  final bool isCurrentMonth;
  final Map<String, DayRecord> daysData;
  final Function(DayData) onDaySelected;
  final Function(DayData) onDayLongPressed;
  final int calendarViewMode;

  const MonthView({
    super.key,
    required this.month,
    required this.year,
    required this.monthName,
    required this.isCurrentMonth,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
    this.calendarViewMode = 1,
  });

  bool get _isCompact => calendarViewMode > 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _isCompact ? 2 : 4,
        vertical: _isCompact ? 3 : 6,
      ),
      padding: EdgeInsets.all(_isCompact ? 5 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isCompact ? 10 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: _isCompact ? 3 : 12,
              left: _isCompact ? 2 : 4,
            ),
            child: Text(
              monthName,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isCurrentMonth ? const Color(0xFF8B5CF6) : Colors.black,
                fontSize: calendarViewMode == 3 ? 8 : (_isCompact ? 10 : 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CalendarGrid(
            month: month,
            year: year,
            daysData: daysData,
            onDaySelected: onDaySelected,
            onDayLongPressed: onDayLongPressed,
            calendarViewMode: calendarViewMode,
          ),
        ],
      ),
    );
  }
}
