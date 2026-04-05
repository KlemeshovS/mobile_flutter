import 'package:flutter/material.dart';
import 'package:wobbly/utils/milestone_data.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:wobbly/models/milestone.dart';
import 'package:wobbly/screens/stats/all_milestones_sheet.dart';


class AdaptiveSobrietyFactsView extends StatelessWidget {
  final int soberDays;

  const AdaptiveSobrietyFactsView({super.key, required this.soberDays});

  // Набор "похмельных" сообщений (аналог messageSets из Swift)
  static const List<_HangoverMessage> _hangoverMessages = [
    _HangoverMessage(
      titleKey: 'hangover_title_1',
      points: [
        _MessagePoint(icon: Icons.person_off, color: Color(0xFFFF6B6B), textKey: 'hangover_1_point_1'),
        _MessagePoint(icon: Icons.auto_awesome, color: Color(0xFF8B5CF6), textKey: 'hangover_1_point_2'),
        _MessagePoint(icon: Icons.attach_money, color: Color(0xFF4ECDC4), textKey: 'hangover_1_point_3'),
      ],
    ),
    _HangoverMessage(
      titleKey: 'hangover_title_2',
      points: [
        _MessagePoint(icon: Icons.whatshot, color: Color(0xFFFF6B6B), textKey: 'hangover_2_point_1'),
        _MessagePoint(icon: Icons.psychology, color: Color(0xFF8B5CF6), textKey: 'hangover_2_point_2'),
        _MessagePoint(icon: Icons.favorite, color: Color(0xFF4ECDC4), textKey: 'hangover_2_point_3'),
      ],
    ),
    // ... добавьте остальные сообщения из Swift (всего 10)
    // Для краткости здесь приведены два, остальные добавьте аналогично.
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final milestone = MilestoneData().getCurrentMilestone(soberDays);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
// Заголовок в одну строку
          Row(
            children: [
              Expanded(
                child: Text(
                  '${localizations.translate('your_progress')} $soberDays ${_getDayString(soberDays, locale)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (soberDays > 0 && milestone != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7FF00).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      milestone.icon,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Содержимое в зависимости от состояния
          if (milestone != null && soberDays >= 2)
            _buildMilestoneContent(context, milestone)
          else
            _buildHangoverContent(context),

          const SizedBox(height: 16),

          // Кнопка "Эволюция трезвого человека"
          _buildEvolutionButton(context),
        ],
      ),
    );
  }

  Widget _buildMilestoneContent(BuildContext context, Milestone milestone) {
    final localizations = AppLocalizations.of(context);
    final facts = milestone.shortFactKeys
        .map((key) => localizations.translate(key))
        .where((text) => text.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2D2B55),
            Color(0xFF3E3B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          ...facts.map((fact) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Color(0xFF4ECDC4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fact,
                    style: TextStyle(
                      fontFamily: 'Inter',
                    fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHangoverContent(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Выбираем случайное сообщение
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _hangoverMessages.length;
    final message = _hangoverMessages[randomIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2D2B55),
            Color(0xFF3E3B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate(message.titleKey),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...message.points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  point.icon,
                  size: 12,
                  color: point.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.translate(point.textKey),
                    style: TextStyle(
                      fontFamily: 'Inter',
                    fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEvolutionButton(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        // Показать bottom sheet со всеми вехами
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AllMilestonesSheet(soberDays: soberDays),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2D2B55),
              Color(0xFF3E3B6B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                localizations.translate('evolution_of_sober_person_title'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8B5CF6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

String _getDayString(int days, String locale) {
  // Если язык русский – используем правила склонения
  if (locale.startsWith('ru')) {
    int lastDigit = days % 10;
    int lastTwoDigits = days % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return 'дней';
    }
    switch (lastDigit) {
      case 1:
        return 'день';
      case 2:
      case 3:
      case 4:
        return 'дня';
      default:
        return 'дней';
    }
  } else {
    // Для английского и всех остальных языков
    return days == 1 ? 'day' : 'days';
  }
}

// Вспомогательные классы для похмельных сообщений
class _HangoverMessage {
  final String titleKey;
  final List<_MessagePoint> points;

  const _HangoverMessage({required this.titleKey, required this.points});
}

class _MessagePoint {
  final IconData icon;
  final Color color;
  final String textKey;

  const _MessagePoint({required this.icon, required this.color, required this.textKey});
}