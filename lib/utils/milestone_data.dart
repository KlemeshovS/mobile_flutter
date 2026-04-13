import 'package:wobbly/models/milestone.dart';

class MilestoneData {
  static final MilestoneData _instance = MilestoneData._internal();
  factory MilestoneData() => _instance;
  MilestoneData._internal();

  // Все вехи, отсортированные по дням (значения взяты из Swift-кода)
  static const List<Milestone> _allMilestones = [
    // 48 часов (2 дня)
    Milestone(
      days: 2,
      icon: '🧠',
      titleKey: 'milestone_2d_title',
      shortFactKeys: [
        'fact_48h_1',
        'fact_48h_2',
        'fact_48h_3',
        'fact_48h_4',
        'fact_48h_5',
      ],
      fullFactKeys: [
        'fact_48h_full_1',
        'fact_48h_full_2',
        'fact_48h_full_3',
        'fact_48h_full_4',
        'fact_48h_full_5',
        'fact_48h_full_6',
      ],
    ),
    // 3 дня
    Milestone(
      days: 3,
      icon: '😴',
      titleKey: 'milestone_3d_title',
      shortFactKeys: [
        'fact_3d_1',
        'fact_3d_2',
        'fact_3d_3',
        'fact_3d_4',
        'fact_3d_5',
      ],
      fullFactKeys: [
        'fact_3d_full_1',
        'fact_3d_full_2',
        'fact_3d_full_3',
        'fact_3d_full_4',
        'fact_3d_full_5',
        'fact_3d_full_6',
      ],
    ),
    // 1 неделя (7 дней)
    Milestone(
      days: 7,
      icon: '❤️',
      titleKey: 'milestone_1w_title',
      shortFactKeys: [
        'fact_week_1',
        'fact_week_2',
        'fact_week_3',
        'fact_week_4',
        'fact_week_5',
      ],
      fullFactKeys: [
        'fact_week_full_1',
        'fact_week_full_2',
        'fact_week_full_3',
        'fact_week_full_4',
        'fact_week_full_5',
        'fact_week_full_6',
      ],
    ),
    // 2 недели (14 дней)
    Milestone(
      days: 14,
      icon: '🌿',
      titleKey: 'milestone_2w_title',
      shortFactKeys: [
        'fact_2w_1',
        'fact_2w_2',
        'fact_2w_3',
        'fact_2w_4',
        'fact_2w_5',
      ],
      fullFactKeys: [
        'fact_2w_full_1',
        'fact_2w_full_2',
        'fact_2w_full_3',
        'fact_2w_full_4',
        'fact_2w_full_5',
        'fact_2w_full_6',
      ],
    ),
    // 1 месяц (30 дней)
    Milestone(
      days: 30,
      icon: '🌱',
      titleKey: 'milestone_1m_title',
      shortFactKeys: [
        'fact_month_1',
        'fact_month_2',
        'fact_month_3',
        'fact_month_4',
        'fact_month_5',
      ],
      fullFactKeys: [
        'fact_month_full_1',
        'fact_month_full_2',
        'fact_month_full_3',
        'fact_month_full_4',
        'fact_month_full_5',
        'fact_month_full_6',
      ],
    ),
    // 2 месяца (60 дней)
    Milestone(
      days: 60,
      icon: '🌳',
      titleKey: 'milestone_2m_title',
      shortFactKeys: [
        'fact_2m_1',
        'fact_2m_2',
        'fact_2m_3',
        'fact_2m_4',
        'fact_2m_5'
      ],
      fullFactKeys: [
        'fact_2m_full_1',
        'fact_2m_full_2',
        'fact_2m_full_3',
        'fact_2m_full_4',
        'fact_2m_full_5',
        'fact_2m_full_6',
      ],
    ),
    // 3 месяца (90 дней)
    Milestone(
      days: 90,
      icon: '🏆',
      titleKey: 'milestone_3m_title',
      shortFactKeys: [
        'fact_3m_1',
        'fact_3m_2',
        'fact_3m_3',
        'fact_3m_4',
        'fact_3m_5',
      ],
      fullFactKeys: [
        'fact_3m_full_1',
        'fact_3m_full_2',
        'fact_3m_full_3',
        'fact_3m_full_4',
        'fact_3m_full_5',
        'fact_3m_full_6',
      ],
    ),
    // 6 месяцев (180 дней)
    Milestone(
      days: 180,
      icon: '⭐',
      titleKey: 'milestone_6m_title',
      shortFactKeys: [
        'fact_6m_1',
        'fact_6m_2',
        'fact_6m_3',
        'fact_6m_4',
        'fact_6m_5',
      ],
      fullFactKeys: [
        'fact_6m_full_1',
        'fact_6m_full_2',
        'fact_6m_full_3',
        'fact_6m_full_4',
        'fact_6m_full_5',
        'fact_6m_full_6',
      ],
    ),
    // 1 год (365 дней)
    Milestone(
      days: 365,
      icon: '🎉',
      titleKey: 'milestone_1y_title',
      shortFactKeys: [
        'fact_year_1',
        'fact_year_2',
        'fact_year_3',
        'fact_year_4',
        'fact_year_5',
      ],
      fullFactKeys: [
        'fact_year_full_1',
        'fact_year_full_2',
        'fact_year_full_3',
        'fact_year_full_4',
        'fact_year_full_5',
        'fact_year_full_6',
      ],
    ),
  ];

  // Возвращает текущий достигнутый milestone (самый большой из достигнутых)
  Milestone? getCurrentMilestone(int soberDays) {
    Milestone? result;
    for (final m in _allMilestones) {
      if (m.days <= soberDays) {
        result = m;
      } else {
        break;
      }
    }
    return result;
  }

  // Возвращает следующий milestone (ближайший не достигнутый)
  Milestone? getNextMilestone(int soberDays) {
    for (final m in _allMilestones) {
      if (m.days > soberDays) return m;
    }
    return null;
  }

  // Все вехи
  List<Milestone> getAllMilestones() => _allMilestones;
}
