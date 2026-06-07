import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:flutter/foundation.dart';

class WeekStatsView extends StatefulWidget {
  final Map<String, DayRecord> daysData;
  final int selectedYear;

  const WeekStatsView({
    super.key,
    required this.daysData,
    required this.selectedYear,
  });

  @override
  State<WeekStatsView> createState() => _WeekStatsViewState();
}

class _WeekStatsViewState extends State<WeekStatsView> {
  List<_DayStats> _stats = List.generate(7, (_) => _DayStats(sportCount: 0, drinkCount: 0));
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void didUpdateWidget(WeekStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysData != widget.daysData || oldWidget.selectedYear != widget.selectedYear) {
      _calculate();
    }
  }

  void _calculate() {
    final sportCounts = List<int>.filled(7, 0);
    final drinkCounts = List<int>.filled(7, 0);

    for (final entry in widget.daysData.entries) {
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) continue;
      if (year != widget.selectedYear) continue;

      final date = DateTime(year, month, day);
      final weekday = date.weekday - 1;

      final record = entry.value;
      if (record.hasSport) sportCounts[weekday]++;
      if (record.drinkLevel != DrinkLevel.none) drinkCounts[weekday]++;
    }

    if (mounted) {
      setState(() {
        _stats = List.generate(7, (i) => _DayStats(
          sportCount: sportCounts[i],
          drinkCount: drinkCounts[i],
        ));
        _loaded = true;
      });
    }
  }

  List<String> _weekdayNames(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      loc.mondayShort, loc.tuesdayShort, loc.wednesdayShort,
      loc.thursdayShort, loc.fridayShort, loc.saturdayShort, loc.sundayShort,
    ];
  }

  LinearGradient _barGradient(int sport, int drink) {
    if (sport == 0) {
      return const LinearGradient(
        colors: [Color(0xFFF87171), Color(0xFFDC2626)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    }
    if (drink == 0) {
      return const LinearGradient(
        colors: [Color(0xFFC7FF00), Color(0xFF86EFAC)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      );
    }
    final ratio = sport / (sport + drink);
    return LinearGradient(
      stops: [0, ratio * 0.7, ratio, ratio + (1 - ratio) * 0.3, 1.0],
      colors: const [
        Color(0xFFC7FF00), Color(0xFF86EFAC), Color(0xFFFCD34D),
        Color(0xFFF87171), Color(0xFFDC2626),
      ],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final names = _weekdayNames(context);
    final maxTotal = _stats.map((s) => s.total).reduce((a, b) => a > b ? a : b);
    const maxH = 120.0;
    const barWidth = 28.0;

    if (!_loaded) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 80, height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heights = [60.0, 90.0, 45.0, 110.0, 70.0, 100.0, 55.0];
                return Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: heights[i],
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 20, height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            loc.translate('your_week_title'),
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 16,
              fontWeight: FontWeight.w600, color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final stat = _stats[i];
              final totalH = maxTotal > 0 ? (stat.total / maxTotal) * maxH : 0.0;

              return Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: stat.total > 0
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${stat.sportCount}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFC7FF00))),
                          const Text('/', style: TextStyle(fontSize: 9, color: Colors.white38)),
                          Text('${stat.drinkCount}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
                        ],
                      )
                          : const Text('—', style: TextStyle(fontSize: 9, color: Colors.white30), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: maxH,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: barWidth, height: maxH,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          if (stat.total > 0)
                            Container(
                              width: barWidth, height: totalH,
                              decoration: BoxDecoration(
                                gradient: _barGradient(stat.sportCount, stat.drinkCount),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(names[i],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white60)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 8,
                  decoration: BoxDecoration(color: const Color(0xFFC7FF00), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(loc.translate('your_week_sport'),
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 8),
              const Text('/', style: TextStyle(fontSize: 12, color: Colors.white38)),
              const SizedBox(width: 8),
              Container(width: 12, height: 8,
                  decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(loc.translate('your_week_drink'),
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayStats {
  final int sportCount;
  final int drinkCount;
  int get total => sportCount + drinkCount;
  _DayStats({required this.sportCount, required this.drinkCount});
}