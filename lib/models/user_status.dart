// lib/models/user_status.dart
import '../models/drink_level.dart';
import '../models/day_data.dart';
import '../models/day_record.dart';

/// Доступные статусы пользователя
enum UserStatus {
  sporty,
  alcoholic,
  boring,
  balanced,
  moderateDrinker,
  activeLifestyle,
  weekendWarrior,
  soberEnthusiast,
  sportsFanatic,
  partyAnimal,
  alcoCyborg;

  /// Имя иконки для assets (без расширения)
  String get iconName {
    switch (this) {
      case UserStatus.sporty:
        return 'icon_sporty';
      case UserStatus.alcoholic:
        return 'icon_alcoholic';
      case UserStatus.boring:
        return 'icon_boring';
      case UserStatus.balanced:
        return 'icon_balanced';
      case UserStatus.moderateDrinker:
        return 'icon_moderate';
      case UserStatus.activeLifestyle:
        return 'icon_active';
      case UserStatus.weekendWarrior:
        return 'icon_weekend';
      case UserStatus.soberEnthusiast:
        return 'icon_sober';
      case UserStatus.sportsFanatic:
        return 'icon_fanatic';
      case UserStatus.partyAnimal:
        return 'icon_party';
      case UserStatus.alcoCyborg:
        return 'icon_alco_cyborg';
    }
  }

  /// Цвет статуса (hex)
  String get hexColor {
    switch (this) {
      case UserStatus.sporty:
        return '#4CAF50';
      case UserStatus.alcoholic:
        return '#F44336';
      case UserStatus.boring:
        return '#9E9E9E';
      case UserStatus.balanced:
        return '#2196F3';
      case UserStatus.moderateDrinker:
        return '#FF9800';
      case UserStatus.activeLifestyle:
        return '#00BCD4';
      case UserStatus.weekendWarrior:
        return '#673AB7';
      case UserStatus.soberEnthusiast:
        return '#8BC34A';
      case UserStatus.sportsFanatic:
        return '#E91E63';
      case UserStatus.partyAnimal:
        return '#FF5722';
      case UserStatus.alcoCyborg:
        return '#9C27B0';
    }
  }

  /// Ключ локализации для названия
  String get titleKey => 'status_${name}_title';

  /// Ключ локализации для описания
  String get descriptionKey => 'status_${name}_description';
}

/// Статистика за период для расчёта статуса
class UserStatusStats {
  final int drinkingDays;
  final int sportDays;
  final int soberDays;
  final int totalDays;
  final double drinkingPercentage;
  final double sportPercentage;
  final double soberPercentage;
  final int mediumHeavyDays;
  final double mediumHeavyPercentage;

  UserStatusStats({
    required this.drinkingDays,
    required this.sportDays,
    required this.soberDays,
    required this.totalDays,
    required this.drinkingPercentage,
    required this.sportPercentage,
    required this.soberPercentage,
    required this.mediumHeavyDays,
    required this.mediumHeavyPercentage,
  });
}

/// Менеджер для расчёта статуса
class UserStatusManager {
  // Настройки (можно вынести в отдельный класс, как в Swift)
  static int lookBackDays = 30;
  static int boringThreshold = 4;
  static int extremeDaysThreshold = 7;
  static double sportFanaticThreshold = 30.0;
  static double alcoholicThreshold = 30.0;
  static double alcoCyborgThreshold = 55.0; // Процент дней medium/heavy для статуса Алкокиборг

  /// Основной метод расчёта статуса
  static UserStatus calculateStatus(Map<String, DayRecord> daysData) {
    final stats = _calculateRecentStats(daysData);
    return _determineStatus(stats);
  }

  /// Расчёт статистики за последние N дней
  static UserStatusStats _calculateRecentStats(Map<String, DayRecord> daysData) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int drinkingDays = 0;
    int sportDays = 0;
    int totalDays = 0;
    int mediumHeavyDays = 0;

    for (int offset = 0; offset < lookBackDays; offset++) {
      final date = today.subtract(Duration(days: offset));
      final dayData = DayData(
        day: date.day,
        month: date.month - 1,
        year: date.year,
      );
      final record = daysData[dayData.key];

      if (record != null) {
        if (record.drinkLevel == DrinkLevel.little ||
            record.drinkLevel == DrinkLevel.medium ||
            record.drinkLevel == DrinkLevel.heavy ||
            record.drinkLevel == DrinkLevel.little_sport) {
          drinkingDays++;
          if (record.drinkLevel == DrinkLevel.medium || record.drinkLevel == DrinkLevel.heavy ||
              record.drinkLevel == DrinkLevel.medium_sport || record.drinkLevel == DrinkLevel.heavy_sport) {
            mediumHeavyDays++;
          }
        }
        if (record.hasSport && record.drinkLevel == DrinkLevel.none) {
          sportDays++;
        }
      }
      totalDays++;
    }

    final soberDays = totalDays - drinkingDays - sportDays;
    final drinkingPercentage = totalDays > 0 ? (drinkingDays / totalDays * 100) : 0.0;
    final sportPercentage = totalDays > 0 ? (sportDays / totalDays * 100) : 0.0;
    final soberPercentage = totalDays > 0 ? (soberDays / totalDays * 100) : 0.0;
    final mediumHeavyPercentage = totalDays > 0 ? (mediumHeavyDays / totalDays * 100) : 0.0;

    return UserStatusStats(
      drinkingDays: drinkingDays,
      sportDays: sportDays,
      soberDays: soberDays,
      totalDays: totalDays,
      drinkingPercentage: drinkingPercentage,
      sportPercentage: sportPercentage,
      soberPercentage: soberPercentage,
      mediumHeavyDays: mediumHeavyDays,
      mediumHeavyPercentage: mediumHeavyPercentage,
    );
  }

  /// Определение статуса на основе статистики
  static UserStatus _determineStatus(UserStatusStats stats) {
    final sport = stats.sportDays;
    final drink = stats.drinkingDays;
    final totalActive = sport + drink;
    final mediumHeavyDays = stats.mediumHeavyDays;
    final mediumHeavyPct = stats.mediumHeavyPercentage;

    // ========== САМЫЕ ЖЁСТКИЕ ==========
    // 1. Алкокиборг – очень много алкоголя или много тяжёлых дней
    if (drink >= 20 || (mediumHeavyPct > 55 && mediumHeavyDays >= 7)) {
      return UserStatus.alcoCyborg;
    }

    // 2. Раб железного храма – только спорт, очень много
    if (sport >= 15 && drink < 5) {
      return UserStatus.sportsFanatic;
    }

    // 3. КМС по алкоспорту – много алкоголя, мало спорта
    if (drink >= 15 && drink < 20 && sport < 5) {
      return UserStatus.alcoholic;
    }

    // 4. Фитнес-мученик – много спорта, мало алкоголя
    if (sport >= 11 && sport < 15 && drink < 3) {
      return UserStatus.activeLifestyle;
    }

    // 5. Тусовщик-легенда – прилично алкоголя
    if (drink >= 10 && drink < 15 && sport < 5) {
      return UserStatus.partyAnimal;
    }

    // 6. Трезвый садист – прилично спорта
    if (sport >= 8 && sport < 11 && drink < 5) {
      return UserStatus.soberEnthusiast;
    }

    // 7. Грешник выходного дня – умеренно алкоголя
    if (drink >= 5 && drink < 10 && sport < 5) {
      return UserStatus.moderateDrinker;
    }

    // 8. Любитель зарядки – умеренно спорта
    if (sport >= 5 && sport < 8 && drink < 3) {
      return UserStatus.sporty;
    }

    // 9. Субботний герой – немного алкоголя
    if (drink >= 2 && drink < 5 && sport < 3) {
      return UserStatus.weekendWarrior;
    }

    // 10. Скучный как пробка – почти ничего не делает
    if (totalActive < 4) {
      return UserStatus.boring;
    }

    // 11. Баланс – и спорт и алкоголь в сопоставимых количествах
    if (sport >= 5 && sport <= 15 && drink >= 5 && drink <= 15 && (sport - drink).abs() <= 5) {
      return UserStatus.balanced;
    }

    // ========== ДЕФОЛТ ПО ПРЕОБЛАДАНИЮ ==========
    if (sport > drink) {
      // Если спорта больше, но не хватило до спорт-статусов
      return sport >= 3 ? UserStatus.sporty : UserStatus.boring;
    } else if (drink > sport) {
      // Если алкоголя больше
      return drink >= 2 ? UserStatus.moderateDrinker : UserStatus.weekendWarrior;
    } else {
      // Равное количество
      return UserStatus.balanced;
    }
  }
}