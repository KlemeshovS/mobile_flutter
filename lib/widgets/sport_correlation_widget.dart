// lib/widgets/sport_correlation_widget.dart
import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../models/drink_level.dart';
import '../utils/localization.dart';

class SportCorrelationWidget extends StatelessWidget {
  final Map<String, DayRecord> daysData;
  final int selectedYear;

  const SportCorrelationWidget({
    super.key,
    required this.daysData,
    required this.selectedYear,
  });

  _CorrelationData _calculate() {
    final now = DateTime.now();
    final isCurrentYear = selectedYear == now.year;

    final lastMonth = isCurrentYear ? now.month : 12;
    final lastDay = isCurrentYear ? now.day : 31;

    // Count total elapsed days in the year
    int totalDays = 0;
    for (int m = 1; m <= lastMonth; m++) {
      final dim = DateUtils.getDaysInMonth(selectedYear, m);
      totalDays += (m == lastMonth) ? lastDay : dim;
    }

    int sportTotal = 0;
    int sportWithAlcohol = 0;
    int noSportWithAlcohol = 0;

    for (final entry in daysData.entries) {
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]); // 1-based in Flutter
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) continue;
      if (y != selectedYear) continue;
      // Skip future days
      if (m > lastMonth || (m == lastMonth && d > lastDay)) continue;

      final record = entry.value;
      final hasSport = record.hasSport;
      final hasAlcohol = record.drinkLevel != DrinkLevel.none &&
          record.drinkLevel != DrinkLevel.unknown;

      if (hasSport) {
        sportTotal++;
        if (hasAlcohol) sportWithAlcohol++;
      } else {
        if (hasAlcohol) noSportWithAlcohol++;
      }
    }

    final noSportTotal = totalDays - sportTotal;

    return _CorrelationData(
      sportTotal: sportTotal,
      sportWithAlcohol: sportWithAlcohol,
      noSportTotal: noSportTotal < 0 ? 0 : noSportTotal,
      noSportWithAlcohol: noSportWithAlcohol,
    );
  }

  String _conclusionText(AppLocalizations loc, _CorrelationData d) {
    if (d.sportTotal == 0) return '';

    if (d.noSportPct == 0 && d.sportPct == 0) {
      return loc.translate('correlation_conclusion_no_drink');
    }
    if (d.sportPct == 0) {
      return loc.translate('correlation_conclusion_sport_no_drink');
    }
    if (d.noSportPct == 0) {
      return loc.translate('correlation_conclusion_nosport_no_drink');
    }

    final absDiff = (d.sportPct - d.noSportPct).abs();
    final absDaysDiff = (d.sportWithAlcohol - d.noSportWithAlcohol).abs();

    if (absDiff < 7 || absDaysDiff < 3) {
      return loc.translate('correlation_conclusion_no_effect');
    }

    final ratio = d.sportPct < d.noSportPct
        ? d.noSportPct / (d.sportPct < 1 ? 1 : d.sportPct)
        : d.sportPct / (d.noSportPct < 1 ? 1 : d.noSportPct);
    final ratioStr = ratio >= 2 ? ratio.round().toString() : '';

    if (d.sportPct < d.noSportPct) {
      return ratioStr.isEmpty
          ? loc.translate('correlation_conclusion_less')
          : loc.translate('correlation_conclusion_less_ratio', [ratioStr]);
    } else {
      return ratioStr.isEmpty
          ? loc.translate('correlation_conclusion_more')
          : loc.translate('correlation_conclusion_more_ratio', [ratioStr]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final d = _calculate();
    if (!d.hasEnoughData) return const SizedBox.shrink();

    final conclusion = _conclusionText(loc, d);

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
            loc.translate('correlation_title'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 14),
          _buildRow(
            context,
            loc,
            loc.translate('correlation_sport_days'),
            d.sportPct,
            d.sportTotal,
            d.sportWithAlcohol,
            const Color(0xFFC7FF00),
          ),
          const SizedBox(height: 14),
          _buildRow(
            context,
            loc,
            loc.translate('correlation_no_sport_days'),
            d.noSportPct,
            d.noSportTotal,
            d.noSportWithAlcohol,
            const Color(0xFFFF0072),
          ),
          if (conclusion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              conclusion,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    AppLocalizations loc,
    String label,
    double pct,
    int total,
    int withAlcohol,
    Color color,
  ) {
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
              '${pct.round()}%',
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
                width: constraints.maxWidth * (pct / 100).clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _daysText(loc, withAlcohol, total),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ],
    );
  }

  String _daysText(AppLocalizations loc, int withAlcohol, int total) {
    final ofWord = loc.translate('correlation_of');
    final dayWord = _dayWord(loc, total);
    return '$withAlcohol $ofWord $total $dayWord';
  }

  String _dayWord(AppLocalizations loc, int n) {
    // Russian: 1 → день, 2-4 → дня, 5+ / 11-14 → дней
    // English: 1 → day, other → days
    final m100 = n % 100;
    final m10 = n % 10;
    if (m100 >= 11 && m100 <= 14) {
      return loc.translate('correlation_day_other');
    }
    if (m10 == 1) return loc.translate('correlation_day_one');
    if (m10 >= 2 && m10 <= 4) return loc.translate('correlation_day_few');
    return loc.translate('correlation_day_other');
  }
}

class _CorrelationData {
  final int sportTotal;
  final int sportWithAlcohol;
  final int noSportTotal;
  final int noSportWithAlcohol;

  const _CorrelationData({
    required this.sportTotal,
    required this.sportWithAlcohol,
    required this.noSportTotal,
    required this.noSportWithAlcohol,
  });

  double get sportPct =>
      sportTotal > 0 ? (sportWithAlcohol / sportTotal * 100).roundToDouble() : 0;

  double get noSportPct =>
      noSportTotal > 0 ? (noSportWithAlcohol / noSportTotal * 100).roundToDouble() : 0;

  bool get hasEnoughData => sportTotal >= 5 && noSportTotal >= 5;
}
