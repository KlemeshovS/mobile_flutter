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

  const DayCell({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.daysData,
    required this.onTap,
    required this.onLongPress,
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

  @override
  Widget build(BuildContext context) {
    final record = dayRecord;

    // Определяем параметры отображения
    Color? backgroundColor;
    Color? borderColor;
    double borderWidth = 0;

    if (record != null) {
      if (record.drinkLevel == DrinkLevel.little && record.hasSport) {
        backgroundColor = Color(0xFFC7FF00).withOpacity(0.4);
        borderColor = Color(0xFFF7B0BB);
        borderWidth = 2.0;
      } else if (record.drinkLevel == DrinkLevel.medium && record.hasSport) {
        backgroundColor = Color(0xFFC7FF00).withOpacity(0.4);
        borderColor = Color(0xFFEA0505);
        borderWidth = 2.0;
      } else if (record.drinkLevel == DrinkLevel.heavy && record.hasSport) {
        backgroundColor = Color(0xFFC7FF00).withOpacity(0.4);
        borderColor = Color(0xFF9C27B0);
        borderWidth = 2.0;
      } else if (record.hasSport) {
        backgroundColor = Color(0xFFC7FF00).withOpacity(0.4);
      } else if (record.drinkLevel != DrinkLevel.none) {
        // Алкоголь (без спорта)
        backgroundColor = record.drinkLevel.color.withOpacity(0.7);
      }
    }

    // Для сегодняшнего дня добавляем или изменяем обводку
    if (isToday) {
      borderColor = Color(0xFF8B5CF6); // Фиолетовый для сегодня
      borderWidth = 2.0;
    }

    // Если нет записи, но сегодняшний день
    if (record == null && isToday) {
      backgroundColor = Color(0xFF8B5CF6).withOpacity(0.1);
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      onLongPress: isFuture ? null : onLongPress,
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.transparent,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Inter',
              color: _getTextColor(record),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(DayRecord? record) {
    // Будущие даты - серый
    if (isFuture) {
      return Colors.grey[500]!;
    }

    // Для дней с записью - черный текст (хорошая читаемость)
    if (record != null) {
      if ((record.drinkLevel == DrinkLevel.little ||
              record.drinkLevel == DrinkLevel.medium ||
              record.drinkLevel == DrinkLevel.heavy) &&
          record.hasSport) {
        return Colors.black;
      } else if (record.hasSport) {
        return Colors.black;
      } else if (record.drinkLevel != DrinkLevel.none) {
        return Colors.black;
      }
    }

    // Обычные дни и сегодняшний день без записи - черный
    return Colors.black;
  }
}
