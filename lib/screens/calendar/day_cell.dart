// lib/screens/calendar/day_cell.dart
import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/models/drink_level.dart';


class DayCell extends StatelessWidget {
  final int day;
  final int month;
  final int year;
  final Map<String, DayRecord> daysData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double fontSize;
  final double cellPadding;

  const DayCell({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.daysData,
    required this.onTap,
    required this.onLongPress,
    this.fontSize = 14,
    this.cellPadding = 3.0,
  });

  DayData get dayData => DayData(day: day, month: month, year: year);

  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month + 1 && now.day == day;
  }

  bool get isFuture {
    final now = DateTime.now();
    return dayData.date.isAfter(now);
  }

  DayRecord? get dayRecord {
    return daysData[dayData.key];
  }

  // Цвет края градиента для алкоголя (совпадает со Swift)
  Color _alcoholEdgeColor(DrinkLevel level) {
    switch (level) {
      case DrinkLevel.little: return const Color(0xFFFF0072);
      case DrinkLevel.medium: return const Color(0xFF9126EF);
      case DrinkLevel.heavy:  return const Color(0xFF482FED);
      default: return Colors.transparent;
    }
  }

  RadialGradient _sportAlcoholGradient(DrinkLevel level) {
    final edge = _alcoholEdgeColor(level);
    // mode 3 (3 колонки, весь год) — усиленный контраст, как в Swift CompactDayCell
    if (fontSize <= 7) {
      return RadialGradient(
        colors: [
          const Color(0xFFC7FF00),
          Color(0xFFC7FF00).withOpacity(0.7),
          Color(0xFFC7FF00).withOpacity(0.3),
          edge.withOpacity(0.75),
        ],
        stops: const [0.0, 0.33, 0.65, 1.0],
      );
    }
    return RadialGradient(
      colors: [
        const Color(0xFFC7FF00),              // центр — зелёный
        const Color(0xFFC7FF00),
        Color(0xFFC7FF00).withOpacity(0.7),   // переход
        edge.withOpacity(0.5),                // край — цвет алкоголя
      ],
      stops: const [0.0, 0.4, 0.65, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = dayRecord;

    Color? backgroundColor;
    RadialGradient? gradient;

    if (record != null) {
      final hasSport = record.hasSport;
      final level = record.drinkLevel;

      if (hasSport && level != DrinkLevel.none && level != DrinkLevel.unknown) {
        // Спорт + алкоголь: радиальный градиент
        gradient = _sportAlcoholGradient(level);
      } else if (hasSport) {
        backgroundColor = const Color(0xFFC7FF00).withOpacity(0.4);
      } else if (level != DrinkLevel.none && level != DrinkLevel.unknown) {
        backgroundColor = level.color; // opacity уже вшит в drink_level.dart
      }
    }

    // Сегодняшний день без записи — только голубой кружок
    if (isToday && record == null) {
      backgroundColor = Colors.blue.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      onLongPress: isFuture ? null : onLongPress,
      child: Container(
        margin: EdgeInsets.all(cellPadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gradient != null ? null : (backgroundColor ?? Colors.transparent),
          gradient: gradient,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Inter',
              color: _getTextColor(record),
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(DayRecord? record) {
    if (isFuture) return Colors.grey[500]!;
    if (record != null) return Colors.black;
    return Colors.black;
  }
}
