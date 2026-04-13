// lib/screens/achievements/all_achievements_sheet.dart
import 'package:flutter/material.dart';
import 'package:wobbly/models/achievement.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AllAchievementsSheet extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement) onAchievementTap;

  const AllAchievementsSheet({
    super.key,
    required this.achievements,
    required this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2B55),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Ручка для закрытия
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Заголовок
          Text(
            localizations.translate('all_achievements'),
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Сетка ачивок
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 0,
                childAspectRatio: 1.0,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return _AchievementGridItem(
                  key: ValueKey('${ach.id}_${ach.isUnlocked}'),
                  achievement: ach,
                  onTap: () => onAchievementTap(ach),
                  localizations: localizations,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementGridItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;
  final AppLocalizations localizations;

  const _AchievementGridItem({
    required this.achievement,
    required this.onTap,
    required this.localizations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDrinking =
        achievement.type == AchievementType.drinkingStreak ||
            (achievement.type == AchievementType.milestone &&
                achievement.id.contains('negative'));
    final bool isMarianaTrench = achievement.id == 'milestone_11022_negative';
    final isUnlocked = achievement.isUnlocked;

    Color fillColor;
    Color strokeColor;

    if (isMarianaTrench && isUnlocked) {
      fillColor = const Color(0xFF8B0000).withOpacity(0.2);
      strokeColor = const Color(0xFF8B0000);
    } else if (isUnlocked) {
      if (isDrinking) {
        fillColor = Colors.red.withOpacity(0.2);
        strokeColor = Colors.red;
      } else {
        fillColor = Colors.green.withOpacity(0.2);
        strokeColor = Colors.green;
      }
    } else {
      fillColor = Colors.grey.withOpacity(0.1);
      strokeColor = Colors.grey.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(color: strokeColor, width: 2),
            ),
            child: Center(
              child: Image.asset(
                achievement.imageAsset,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.emoji_events,
                  color: isUnlocked ? Colors.white : Colors.white54,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.getLocalizedTitle(localizations),
            style: TextStyle(
              fontSize: 12,
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
