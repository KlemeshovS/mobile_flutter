class DayData {
  final int day;
  final int month; // 0-11
  final int year;

  DayData({
    required this.day,
    required this.month,
    required this.year,
  });

  String get key => '$year-${month + 1}-$day';

  DateTime get date => DateTime(year, month + 1, day);

  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month + 1 && now.day == day;
  }

  bool get isFuture {
    final now = DateTime.now();
    return date.isAfter(now);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DayData &&
              runtimeType == other.runtimeType &&
              day == other.day &&
              month == other.month &&
              year == other.year;

  @override
  int get hashCode => day.hashCode ^ month.hashCode ^ year.hashCode;
}