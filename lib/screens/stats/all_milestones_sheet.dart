import 'package:flutter/material.dart';
import 'package:wobbly/models/milestone.dart';
import 'package:wobbly/utils/milestone_data.dart';
import 'package:wobbly/utils/localization.dart';


class AllMilestonesSheet extends StatelessWidget {
  final int soberDays;

  const AllMilestonesSheet({super.key, required this.soberDays});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final milestones = MilestoneData().getAllMilestones();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
            localizations.translate('all_milestones_screen_title'),
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Список вех
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                final isCompleted = soberDays >= milestone.days;
                return _MilestoneCard(
                  milestone: milestone,
                  isCompleted: isCompleted,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final bool isCompleted;

  const _MilestoneCard({
    required this.milestone,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Используем полные факты (6 штук)
    final facts = milestone.fullFactKeys
        .map((key) => localizations.translate(key))
        .where((text) => text.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? const LinearGradient(
          colors: [
            Color(0xFF2D2B55),
            Color(0xFF3E3B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с иконкой и галочкой
          Row(
            children: [
              Text(
                milestone.icon,
                style: TextStyle(
                    fontFamily: 'Inter',fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.translate(milestone.titleKey),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4ECDC4),
                  size: 18,
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Факты (6 штук)
          ...facts.map((fact) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Контейнер для точечки с фиксированным размером
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: isCompleted
                          ? const Color(0xFF4ECDC4)
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fact,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isCompleted
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],            ),
          )),
        ],
      ),
    );
  }
}