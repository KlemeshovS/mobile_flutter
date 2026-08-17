// lib/widgets/top_triggers_widget.dart
import 'package:flutter/material.dart';
import '../models/drink_trigger.dart';
import '../utils/localization.dart';

class TopTriggersWidget extends StatelessWidget {
  final Map<String, List<DrinkTrigger>> triggersData;
  final int selectedYear;

  const TopTriggersWidget({
    super.key,
    required this.triggersData,
    required this.selectedYear,
  });

  List<MapEntry<DrinkTrigger, int>> _calculate() {
    final counts = <DrinkTrigger, int>{};
    triggersData.forEach((key, triggers) {
      final parts = key.split('-');
      if (parts.length != 3) return;
      final y = int.tryParse(parts[0]);
      if (y != selectedYear) return;
      for (final trigger in triggers) {
        counts[trigger] = (counts[trigger] ?? 0) + 1;
      }
    });

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final top = _calculate();
    if (top.isEmpty) return const SizedBox.shrink();

    final maxCount = top.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('top_triggers_title'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < top.length; i++) ...[
            _buildRow(context, loc, top[i].key, top[i].value, maxCount),
            if (i != top.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    AppLocalizations loc,
    DrinkTrigger trigger,
    int count,
    int maxCount,
  ) {
    final label = loc.translate(trigger.localizationKey);
    final fraction = maxCount > 0 ? count / maxCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: 8,
                width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
