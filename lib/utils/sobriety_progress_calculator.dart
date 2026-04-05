// lib/utils/sobriety_progress_calculator.dart
import '../models/day_record.dart';
import '../models/day_data.dart';
import '../models/drink_level.dart';

class SobrietyProgressCalculator {
  static const int maxDays = 443;

  static const List<Milestone> milestones = [
    Milestone(days: 50, titleKey: "milestone_50_label"),
    Milestone(days: 100, titleKey: "milestone_100_label"),
    Milestone(days: 146, titleKey: "milestone_146_label"),
    Milestone(days: 319, titleKey: "milestone_319_label"),
    Milestone(days: 443, titleKey: "milestone_443_label"),
  ];

  static const int maxNegativeDays = 500;
  static const List<int> postYearMilestones = [1234, 4810, 5642, 7010, 8848];
  static const List<int> negativeMilestones = [50, 100, 202, 300, 500];
  static const List<int> postNegativeMilestones = [1642, 3800, 6066, 10047, 11022];
  //1642 - байкал, 3800 - титаник, 202 - голубая дыра, 6066 - Атакамский желоб, 10047 - Жёлоб Кермадек

  /// Основной метод расчёта прогресса.
  /// Возвращает количество "очков трезвости" с учётом штрафов за употребление и бонусов за непрерывные недели.
  static int calculateProgressDays(Map<String, DayRecord> daysData, DateTime installDate) {
    print("🧮 calculateProgressDays: daysData count = ${daysData.length}");

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Находим первый день с любой отметкой (не unknown)
    final firstMarkedDate = _findFirstMarkedDate(daysData);

    // Если нет отмеченных дней, прогресс = 0 (даже с учётом даты установки)
    if (firstMarkedDate == null) {
      return 0;
    }

    // Ограничиваем глубину расчёта 10 годами для оптимизации
    var startDate = firstMarkedDate;
    if (today.difference(startDate).inDays > 3650) {
      startDate = today.subtract(const Duration(days: 3650));
    }

    var progressDays = 0;
    var consecutiveDrinkDays = 0;
    var consecutiveSoberDays = 0;      // количество трезвых дней подряд до текущего дня
    var currentDate = startDate;

    while (currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)) {
      final dayData = DayData(
        day: currentDate.day,
        month: currentDate.month - 1,
        year: currentDate.year,
      );

      final record = daysData[dayData.key];

      // Обработка дня в зависимости от наличия записи и уровня
      if (record == null) {
        // Неотмеченный день – считаем трезвым (+5 с бонусом)
        final weeks = consecutiveSoberDays ~/ 7;
        final bonus = _bonusCoefficient(weeks);
        progressDays += (5.0 * bonus).ceil();
        consecutiveDrinkDays = 0;
        consecutiveSoberDays += 1;
      } else if (record.drinkLevel != DrinkLevel.unknown) {
        // Проверка на особый случай
        if (record.hasSport && record.drinkLevel != DrinkLevel.none) {
          // Комбинация алкоголя и спорта
          consecutiveDrinkDays += 1;
          int basePenalty;
          int sportBonus;
          if (record.drinkLevel == DrinkLevel.little) {
            basePenalty = 5;
            sportBonus = 20;    // бонус 20 для little+sport
          } else if (record.drinkLevel == DrinkLevel.medium) {
            basePenalty = 20;
            sportBonus = 5;     // бонус 5 для medium+sport
          } else if (record.drinkLevel == DrinkLevel.heavy) {
            basePenalty = 35;
            sportBonus = 0;     // бонус 0 для heavy+sport
          } else {
            basePenalty = 5;
            sportBonus = 20;
          }
          final penalty = _calculatePenalty(base: basePenalty, consecutiveDays: consecutiveDrinkDays);
          progressDays = progressDays - penalty + sportBonus;
          consecutiveSoberDays = 0;
        } else {
          // Обычный день (без комбинации)
          switch (record.drinkLevel) {
            case DrinkLevel.none:
              final weeks = consecutiveSoberDays ~/ 7;
              final bonus = _bonusCoefficient(weeks);
              final basePoints = record.hasSport ? 20 : 5;
              progressDays += (basePoints * bonus).ceil();
              consecutiveDrinkDays = 0;
              consecutiveSoberDays += 1;
              break;

            case DrinkLevel.sport:
              final weeks = consecutiveSoberDays ~/ 7;
              final bonus = _bonusCoefficient(weeks);
              progressDays += (20.0 * bonus).ceil();
              consecutiveDrinkDays = 0;
              consecutiveSoberDays += 1;
              break;

            case DrinkLevel.little:
              consecutiveDrinkDays += 1;
              consecutiveSoberDays = 0;
              final penalty = _calculatePenalty(base: 5, consecutiveDays: consecutiveDrinkDays);
              progressDays -= penalty;
              break;

            case DrinkLevel.medium:
              consecutiveDrinkDays += 1;
              consecutiveSoberDays = 0;
              final penalty = _calculatePenalty(base: 20, consecutiveDays: consecutiveDrinkDays);
              progressDays -= penalty;
              break;

            case DrinkLevel.heavy:
              consecutiveDrinkDays += 1;
              consecutiveSoberDays = 0;
              final penalty = _calculatePenalty(base: 35, consecutiveDays: consecutiveDrinkDays);
              progressDays -= penalty;
              break;

            case DrinkLevel.little_sport:
              consecutiveDrinkDays += 1;
              consecutiveSoberDays = 0;
              final penalty = _calculatePenalty(base: 5, consecutiveDays: consecutiveDrinkDays);
              progressDays = progressDays - penalty + 20;
              break;

            case DrinkLevel.medium_sport:
            case DrinkLevel.heavy_sport:
              break;

            case DrinkLevel.unknown:
              break;
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return progressDays;
  }

  /// Коэффициент бонуса за непрерывные трезвые недели.
  /// weeks – количество полных недель, уже пройденных до текущего дня.
  static double _bonusCoefficient(int weeks) {
    switch (weeks) {
      case 0:
        return 1.0;   // дни 1–7
      case 1:
        return 1.2;   // дни 8–14
      case 2:
        return 1.5;   // дни 15–21
      case 3:
        return 1.75;  // дни 22–28
      default:
        return 2.0;   // дни 29+
    }
  }

  // Штрафной коэффициент в зависимости от количества дней подряд с выпивкой
  static int _calculatePenalty({required int base, required int consecutiveDays}) {
    final coefficient = switch (consecutiveDays) {
      1 => 1.0,
      2 => 1.5,
      3 => 2.5,
      4 => 3.5,
      _ => 3.5,
    };
    return (base * coefficient).ceil();
  }

  // Поиск самого раннего отмеченного дня (исключая unknown)
  static DateTime? _findFirstMarkedDate(Map<String, DayRecord> daysData) {
    DateTime? earliestDate;

    for (final entry in daysData.entries) {
      final key = entry.key;
      final record = entry.value;

      if (record.drinkLevel == DrinkLevel.unknown) {
        continue;
      }

      final parts = key.split('-');
      if (parts.length != 3) continue;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);

      if (year == null || month == null || day == null) continue;

      final date = DateTime(year, month, day);

      if (earliestDate == null || date.isBefore(earliestDate)) {
        earliestDate = date;
      }
    }

    return earliestDate;
  }

  /// Публичный метод для получения первой отмеченной даты (используется в stats_screen)
  static DateTime? getFirstMarkedDate(Map<String, DayRecord> daysData) {
    return _findFirstMarkedDate(daysData);
  }

  // Методы для получения следующих вех
  static Milestone? nextMilestone(int progressDays) {
    for (final milestone in milestones) {
      if (milestone.days > progressDays) {
        return milestone;
      }
    }
    return null;
  }

  static int? nextPostYearMilestone(int progressDays) {
    for (final milestone in postYearMilestones) {
      if (milestone > progressDays) {
        return milestone;
      }
    }
    return null;
  }

  static int? nextNegativeMilestone(int progressDays) {
    final absoluteValue = progressDays.abs();
    // Сначала ищем в обычных (до 500)
    for (final milestone in negativeMilestones) {
      if (milestone > absoluteValue) return milestone;
    }
    // Затем в больших
    for (final milestone in postNegativeMilestones) {
      if (milestone > absoluteValue) return milestone;
    }
    return null;
  }
}

class Milestone {
  final int days;
  final String titleKey;

  const Milestone({required this.days, required this.titleKey});
}