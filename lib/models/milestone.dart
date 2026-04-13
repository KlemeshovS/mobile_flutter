class Milestone {
  final int days; // количество дней для достижения вехи
  final String icon; // эмодзи (например, "🧠")
  final String titleKey; // ключ локализации заголовка (например, 'week_label')
  final List<String> shortFactKeys; // ключи для 3 кратких фактов
  final List<String> fullFactKeys; // ключи для 6 полных фактов

  const Milestone({
    required this.days,
    required this.icon,
    required this.titleKey,
    required this.shortFactKeys,
    required this.fullFactKeys,
  });

  bool isReached(int soberDays) => soberDays >= days;
}
