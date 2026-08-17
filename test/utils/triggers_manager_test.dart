// test/utils/triggers_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/drink_trigger.dart';
import 'package:wobbly/utils/triggers_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TriggersManager manager;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    manager = TriggersManager();
  });

  test('loadTriggers returns empty map when nothing was saved', () async {
    final data = await manager.loadTriggers();
    expect(data, isEmpty);
  });

  test('setTriggersForDay round-trips multiple triggers for one day', () async {
    await manager.setTriggersForDay('2026-8-17', [DrinkTrigger.stress, DrinkTrigger.conflict]);

    final data = await manager.loadTriggers();
    expect(data['2026-8-17'], containsAll([DrinkTrigger.stress, DrinkTrigger.conflict]));
  });

  test('setTriggersForDay with an empty list removes the day', () async {
    await manager.setTriggersForDay('2026-8-17', [DrinkTrigger.stress]);
    await manager.setTriggersForDay('2026-8-17', []);

    final data = await manager.loadTriggers();
    expect(data.containsKey('2026-8-17'), isFalse);
  });

  test('replaceAll fully overwrites the local store', () async {
    await manager.setTriggersForDay('2026-8-17', [DrinkTrigger.stress]);
    await manager.replaceAll({'2026-8-18': [DrinkTrigger.party]});

    final data = await manager.loadTriggers();
    expect(data.containsKey('2026-8-17'), isFalse);
    expect(data['2026-8-18'], [DrinkTrigger.party]);
  });

  test('mergeFromImport adds new days without touching existing ones not present in the import', () async {
    await manager.setTriggersForDay('2026-8-17', [DrinkTrigger.stress]);
    await manager.mergeFromImport({'2026-8-18': [DrinkTrigger.habit]});

    final data = await manager.loadTriggers();
    expect(data['2026-8-17'], [DrinkTrigger.stress]);
    expect(data['2026-8-18'], [DrinkTrigger.habit]);
  });

  test('mergeFromImport with an empty map (old export file without triggers) is a no-op', () async {
    await manager.setTriggersForDay('2026-8-17', [DrinkTrigger.stress]);
    await manager.mergeFromImport({});

    final data = await manager.loadTriggers();
    expect(data['2026-8-17'], [DrinkTrigger.stress]);
  });

  test('DrinkTrigger.fromRawValue is unaffected by unknown legacy values', () {
    expect(DrinkTrigger.fromRawValue('not_a_real_tag'), isNull);
    expect(DrinkTrigger.fromRawValue('stress'), DrinkTrigger.stress);
  });
}
