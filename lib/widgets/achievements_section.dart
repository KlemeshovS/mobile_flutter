import 'package:flutter/material.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/utils/localization.dart';


class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback onSeeAllTap;
  final Function(Achievement) onAchievementTap;

  const AchievementsSection({
    super.key,
    required this.achievements,
    required this.onSeeAllTap,
    required this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с уменьшенными отступами
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Заголовок без дополнительных отступов
                Text(
                  localizations.translate('achievements'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Кнопка с минимальными отступами
                TextButton(
                  onPressed: onSeeAllTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    localizations.translate('all_achievements'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (achievements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  localizations.translate('no_achievements_yet'),
                  style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white70),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // кол-во колонок
                crossAxisSpacing: 16, // Расстояние между колонками
                mainAxisSpacing: 0,
                childAspectRatio: 0.95, // Немного вытянутые ячейки для текста под иконкой
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return _AchievementIcon(
                  key: ValueKey('${ach.id}_${ach.isUnlocked}'),
                  achievement: ach,
                  isUnlocked: ach.isUnlocked,
                  onTap: () => onAchievementTap(ach),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AchievementIcon extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked; // новый параметр
  final VoidCallback onTap;

  const _AchievementIcon({
    required this.achievement,
    required this.isUnlocked, // обязательно
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Определяем, относится ли ачивка к питейным (включая отрицательные milestone, кроме специальной)
    final isDrinking = achievement.type == AchievementType.drinkingStreak ||
        (achievement.type == AchievementType.milestone && achievement.id.contains('negative'));
    final isMarianaTrench = achievement.id == 'milestone_11022_negative';
    Color? fillColor;
    Color? strokeColor;

    if (isMarianaTrench) {
      fillColor = const Color(0xFF8B0000).withOpacity(0.3);
      strokeColor = const Color(0xFF8B0000);
    } else if (isUnlocked) {
      if (isDrinking) {
        fillColor = Colors.red.withOpacity(0.3);
        strokeColor = Colors.red;
      } else {
        fillColor = Colors.green.withOpacity(0.3);
        strokeColor = Colors.green;
      }
    } else {
      fillColor = Colors.grey.withOpacity(0.2);
      strokeColor = Colors.grey.withOpacity(0.5);
    }

    // Остальной код без изменений (Container, Image и т.д.)
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(color: strokeColor!, width: 2),
            ),
            child: Center(
              child: Image.asset(
                achievement.imageAsset,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.emoji_events,
                  color: isUnlocked ? Colors.white : Colors.white54,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.getLocalizedTitle(AppLocalizations.of(context)),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(isUnlocked ? 1.0 : 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}