// test/utils/achievement_manager_trigger_test.dart
//
// Юнит-тесты разблокировки ачивок дневника триггеров (triggerCountInYear).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/models/drink_trigger.dart';
import 'package:wobbly/utils/achievement_manager.dart';

String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

Achievement findAch(AchievementManager m, String id) =>
    m.achievements.firstWhere((a) => a.id == id);

/// [count] дней текущего года с алкоголем и списком тегов [triggers] на каждый день.
Map<String, List<DrinkTrigger>> yearTriggers(int count, DrinkTrigger trigger) {
  final year = DateTime.now().year;
  final start = DateTime(year, 1, 1);
  return {
    for (var i = 0; i < count; i++) _key(start.add(Duration(days: i))): [trigger],
  };
}

Map<String, DayRecord> yearDrinkingDays(int count) {
  final year = DateTime.now().year;
  final start = DateTime(year, 1, 1);
  return {
    for (var i = 0; i < count; i++)
      _key(start.add(Duration(days: i))): DayRecord(drinkLevel: DrinkLevel.medium),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AchievementManager manager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    manager = AchievementManager();
    await manager.loadAchievements();
    for (final a in manager.achievements) {
      a.isUnlocked = false;
      a.unlockDate = null;
    }
  });

  group('triggerCountInYear', () {
    test('unlocks trigger_stress_year_10 after 10 stress days in the current year',
        () async {
      final days = yearDrinkingDays(10);
      final triggers = yearTriggers(10, DrinkTrigger.stress);

      await manager.checkAllAchievements(days, triggersData: triggers);

      expect(findAch(manager, 'trigger_stress_year_10').isUnlocked, isTrue);
    });

    test('does not unlock below the threshold', () async {
      final days = yearDrinkingDays(9);
      final triggers = yearTriggers(9, DrinkTrigger.stress);

      await manager.checkAllAchievements(days, triggersData: triggers);

      expect(findAch(manager, 'trigger_stress_year_10').isUnlocked, isFalse);
    });

    test('one tag does not count toward a different tag\'s achievement', () async {
      final days = yearDrinkingDays(10);
      final triggers = yearTriggers(10, DrinkTrigger.conflict);

      await manager.checkAllAchievements(days, triggersData: triggers);

      expect(findAch(manager, 'trigger_conflict_year_10').isUnlocked, isTrue);
      expect(findAch(manager, 'trigger_stress_year_10').isUnlocked, isFalse);
    });

    test('a day with multiple tags counts toward each tag independently', () async {
      final year = DateTime.now().year;
      final start = DateTime(year, 1, 1);
      final days = <String, DayRecord>{
        for (var i = 0; i < 10; i++)
          _key(start.add(Duration(days: i))): DayRecord(drinkLevel: DrinkLevel.medium),
      };
      final triggers = <String, List<DrinkTrigger>>{
        for (var i = 0; i < 10; i++)
          _key(start.add(Duration(days: i))): [DrinkTrigger.stress, DrinkTrigger.habit],
      };

      await manager.checkAllAchievements(days, triggersData: triggers);

      expect(findAch(manager, 'trigger_stress_year_10').isUnlocked, isTrue);
      expect(findAch(manager, 'trigger_habit_year_10').isUnlocked, isTrue);
    });

    test('missing triggersData does not unlock and does not throw', () async {
      final days = yearDrinkingDays(10);

      await manager.checkAllAchievements(days);

      expect(findAch(manager, 'trigger_stress_year_10').isUnlocked, isFalse);
    });
  });
}
