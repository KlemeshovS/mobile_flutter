// lib/utils/calendar_utils.dart
class CalendarUtils {
  static int daysInMonth(int month, int year) {
    // Месяц в формате 0-11
    return DateTime(year, month + 2, 0).day;
  }

  static int getFirstWeekday(int month, int year) {
    final firstDay = DateTime(year, month + 1, 1);
    int weekday = firstDay.weekday;
    return weekday - 1;
  }
}