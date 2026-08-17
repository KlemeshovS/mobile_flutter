// lib/models/drink_trigger.dart
// Дневник триггеров — причины, почему выпил в конкретный день.
// rawValue соответствует значениям на бэкенде (см. /me/calendar/triggers).
enum DrinkTrigger {
  stress('stress'),
  boredom('boredom'),
  party('party'),
  company('company'),
  loneliness('loneliness'),
  conflict('conflict'),
  habit('habit'),
  other('other');

  final String rawValue;
  const DrinkTrigger(this.rawValue);

  static DrinkTrigger? fromRawValue(String value) {
    for (final trigger in DrinkTrigger.values) {
      if (trigger.rawValue == value) return trigger;
    }
    return null;
  }

  /// Ключ локализации для названия тега (см. lib/utils/localization.dart).
  String get localizationKey => 'trigger_${rawValue}_label';
}
