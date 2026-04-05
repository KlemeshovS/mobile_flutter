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

  const MonthView({
    super.key,
    required this.month,
    required this.year,
    required this.monthName,
    required this.isCurrentMonth,
    required this.daysData,
    required this.onDaySelected,
    required this.onDayLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              monthName,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isCurrentMonth ? Color(0xFF8B5CF6) : Colors.black,
                fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}