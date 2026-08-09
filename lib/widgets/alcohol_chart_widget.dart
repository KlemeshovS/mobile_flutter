// lib/widgets/alcohol_chart_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/utils/localization.dart';

class AlcoholChartWidget extends StatefulWidget {
  /// Основные данные (красная линия). Ключи: "год-месяц0-день" (месяц 0-based).
  final Map<String, DayRecord> daysData;

  /// Выбранный год. По умолчанию — текущий.
  final int selectedYear;

  /// Данные для сравнения (синяя линия). null = показывать серое среднее.
  final Map<String, DayRecord>? comparisonData;

  /// Подписи линий (только в режиме сравнения)
  final String? primaryLabel;      // красная
  final String? comparisonLabel;   // синяя

  const AlcoholChartWidget({
    super.key,
    required this.daysData,
    this.selectedYear = 0, // 0 = текущий год
    this.comparisonData,
    this.primaryLabel,
    this.comparisonLabel,
  });

  @override
  State<AlcoholChartWidget> createState() => _AlcoholChartWidgetState();
}

class _AlcoholChartWidgetState extends State<AlcoholChartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  static const _accentColor = Color(0xFFFF0072);
  static const _blueColor   = Color(0xFF60A5FA);
  static const _yAxisW      = 24.0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale   = Tween(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween(begin: 0.5, end: 0.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ───────────────────────────────────────────────────────────

  int get _selectedYear =>
      widget.selectedYear == 0 ? DateTime.now().year : widget.selectedYear;

  DateTime get _now => DateTime.now();
  int get _currentYear  => _now.year;
  int get _currentMonth => _now.month; // 1-based
  int get _today        => _now.day;

  int get _daysInMonth {
    final d = DateTime(_currentYear, _currentMonth + 1, 0);
    return d.day;
  }

  int get _lastDay =>
      _selectedYear == _currentYear ? _today : _daysInMonth;

  int _alcoholScore(DayRecord record) {
    switch (record.drinkLevel) {
      case DrinkLevel.little: return 1;
      case DrinkLevel.medium: return 3;
      case DrinkLevel.heavy:  return 5;
      default:                return 0;
    }
  }

  // Накопительный массив (day, cumulative)
  List<_DayPoint> _buildChartData(Map<String, DayRecord> data) {
    final last = _lastDay;
    if (last < 1) return [];
    int cum = 0;
    return List.generate(last, (i) {
      final day = i + 1;
      final key = '$_selectedYear-$_currentMonth-$day'; // 1-based month (DayData.key format)
      cum += _alcoholScore(data[key] ?? DayRecord());
      return _DayPoint(day: day, cumulative: cum);
    });
  }

  // Средний траектория по прошлым месяцам (только для своего профиля)
  List<_DayPoint> _buildAverageTrajectory(Map<String, DayRecord> data) {
    // Группируем по месяцам (год-месяц), исключая текущий
    final byMonth = <String, Map<int, int>>{};
    for (final entry in data.entries) {
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final y  = int.tryParse(parts[0]);
      final m1 = int.tryParse(parts[1]); // 1-based (DayData.key format)
      final d  = int.tryParse(parts[2]);
      if (y == null || m1 == null || d == null) continue;
      // Пропускаем текущий месяц
      if (y == _currentYear && m1 == _currentMonth) continue;
      final key = '$y-$m1';
      byMonth.putIfAbsent(key, () => {})[d] = _alcoholScore(entry.value);
    }
    if (byMonth.isEmpty) return [];

    // Для каждого месяца строим накопленный по дням и растягиваем до _daysInMonth
    final cumByDay = <int, List<double>>{};
    for (final entry in byMonth.entries) {
      final parts = entry.key.split('-');
      final y = int.tryParse(parts[0])!;
      final m = int.tryParse(parts[1])!;
      final dim = DateTime(y, m + 1, 0).day; // кол-во дней в месяце (m = 1-based, DateTime(y,m+1,0) = последний день месяца m)

      final scores = entry.value;
      int cum = 0;
      final cumPerDay = <int, int>{};
      for (int d = 1; d <= dim; d++) {
        cum += scores[d] ?? 0;
        cumPerDay[d] = cum;
      }
      final totalCum = cum;

      for (int d = 1; d <= _daysInMonth; d++) {
        final val = d <= dim ? (cumPerDay[d] ?? 0).toDouble() : totalCum.toDouble();
        cumByDay.putIfAbsent(d, () => []).add(val);
      }
    }

    return List.generate(_daysInMonth, (i) {
      final day  = i + 1;
      final vals = cumByDay[day] ?? [];
      final avg  = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;
      return _DayPoint(day: day, cumulative: avg.round());
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc     = AppLocalizations.of(context);
    final isRu    = Localizations.localeOf(context).languageCode == 'ru';

    final chartData      = _buildChartData(widget.daysData);
    final compData       = widget.comparisonData != null
        ? _buildChartData(widget.comparisonData!)
        : <_DayPoint>[];
    final avgTraj        = widget.comparisonData == null
        ? _buildAverageTrajectory(widget.daysData)
        : <_DayPoint>[];

    final totalScore     = chartData.isEmpty ? 0 : chartData.last.cumulative;
    final compScore      = compData.isEmpty  ? 0 : compData.last.cumulative;
    final avgAtToday     = avgTraj.isEmpty   ? 0.0
        : avgTraj.firstWhere((p) => p.day == _today,
            orElse: () => _DayPoint(day: 0, cumulative: 0)).cumulative.toDouble();
    final isClean        = totalScore == 0;

    final maxY = _computeMaxY(chartData, compData, avgTraj);

    final titleText = _buildTitle(isRu);

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
              // Заголовок + кнопка (i)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showInfoSheet(context),
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Тело: всегда показываем график (как в Swift)
              _chartArea(
                chartData: chartData,
                compData: compData,
                avgTraj: avgTraj,
                maxY: maxY,
              ),
              const SizedBox(height: 12),
              _legendView(loc, isRu, totalScore, compScore, avgAtToday, avgTraj, isClean),
            ],
          ),
    );
  }

  // ── Clean month ────────────────────────────────────────────────────────────

  Widget _cleanMonthView(AppLocalizations loc) {
    return Row(
      children: [
        const Icon(Icons.verified, color: Color(0xFFC7FF00), size: 22),
        const SizedBox(width: 10),
        Text(
          loc.translate('alcohol_chart_clean_month'),
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  // ── Chart area ─────────────────────────────────────────────────────────────

  Widget _chartArea({
    required List<_DayPoint> chartData,
    required List<_DayPoint> compData,
    required List<_DayPoint> avgTraj,
    required int maxY,
  }) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        return SizedBox(
          height: 110,
          child: LayoutBuilder(builder: (_, constraints) {
            final w      = constraints.maxWidth;
            const labelH = 14.0;
            final chartH = 110.0 - labelH;
            final chartW = w - _yAxisW;

            // Y-ticks
            final yTicks = _computeYTicks(maxY);

            // Points
            final actualPts = _cgPoints(
              data: chartData.map((p) => p.cumulative.toDouble()).toList(),
              days: chartData.map((p) => p.day).toList(),
              chartW: chartW, chartH: chartH, maxY: maxY,
            );
            final avgPts = _cgPoints(
              data: avgTraj.map((p) => p.cumulative.toDouble()).toList(),
              days: avgTraj.map((p) => p.day).toList(),
              chartW: chartW, chartH: chartH, maxY: maxY,
            );
            // Синяя смещена на 1.5px вверх
            final rawCompPts = _cgPoints(
              data: compData.map((p) => p.cumulative.toDouble()).toList(),
              days: compData.map((p) => p.day).toList(),
              chartW: chartW, chartH: chartH, maxY: maxY,
            );
            final compPts = rawCompPts
                .map((p) => Offset(p.dx, p.dy - 1.5))
                .toList();

            return CustomPaint(
              painter: _AlcoholChartPainter(
                actualPts:    actualPts,
                avgPts:       widget.comparisonData == null ? avgPts : [],
                compPts:      widget.comparisonData != null ? compPts : [],
                yTicks:       yTicks,
                maxY:         maxY,
                daysInMonth:  _daysInMonth,
                yAxisW:       _yAxisW,
                chartH:       chartH,
                chartW:       chartW,
                totalH:       110,
                labelH:       labelH,
                pulseScale:   _pulseScale.value,
                pulseOpacity: _pulseOpacity.value,
                hasComp:      widget.comparisonData != null,
              ),
              size: Size(w, 110),
            );
          }),
        );
      },
    );
  }

  // ── Legend ─────────────────────────────────────────────────────────────────

  Widget _legendView(
    AppLocalizations loc,
    bool isRu,
    int totalScore,
    int compScore,
    double avgAtToday,
    List<_DayPoint> avgTraj,
    bool isClean,
  ) {
    final isComparison = widget.comparisonData != null;

    if (isComparison) {
      // Режим сравнения двух пользователей
      final diff   = totalScore - compScore;
      final adverb = diff.abs() >= 5 ? (isRu ? 'сильно ' : 'a lot ') : '';
      String? compText;
      if (diff != 0) {
        final prim = widget.primaryLabel ?? '';
        final comp = widget.comparisonLabel ?? '';
        compText = isRu
            ? diff > 0
                ? '$prim пьёт ${adverb}больше, чем $comp'
                : '$prim пьёт ${adverb}меньше, чем $comp'
            : diff > 0
                ? '$prim drinks ${adverb}more than $comp'
                : '$prim drinks ${adverb}less than $comp';
      } else if (totalScore == 0) {
        // Оба не пили в этом месяце
        compText = loc.translate('alcohol_chart_both_clean');
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(_accentColor, widget.primaryLabel ?? ''),
              const SizedBox(width: 14),
              _legendDot(_blueColor,   widget.comparisonLabel ?? ''),
            ],
          ),
          if (compText != null) ...[
            const SizedBox(height: 4),
            Text(
              compText,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    } else {
      // Свой профиль: месяц + среднее
      final hasAvg = avgTraj.isNotEmpty;
      final diff   = totalScore - avgAtToday.round();
      final diffAbs = diff.abs();
      String phraseKey;
      if (diff == 0)           phraseKey = 'alcohol_drink_as_usual';
      else if (diff > 0 && diffAbs >= 5) phraseKey = 'alcohol_drink_lot_more';
      else if (diff > 0)       phraseKey = 'alcohol_drink_more';
      else if (diffAbs >= 5)   phraseKey = 'alcohol_drink_lot_less';
      else                     phraseKey = 'alcohol_drink_less';

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(_accentColor, _currentMonthName(isRu)),
              if (hasAvg) ...[
                const SizedBox(width: 14),
                _legendDot(Colors.white.withOpacity(0.4),
                    loc.translate('alcohol_chart_legend_avg')),
              ],
            ],
          ),
          if (isClean) ...[
            const SizedBox(height: 4),
            Text(
              loc.translate('alcohol_chart_not_drunk_yet'),
              style: const TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ] else if (hasAvg) ...[
            const SizedBox(height: 4),
            Text(
              loc.translate(phraseKey),
              style: const TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ],
    );
  }

  // ── Info bottom sheet ─────────────────────────────────────────────────────

  void _showInfoSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2B55),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                loc.translate('alcohol_chart_info_title'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.translate('alcohol_chart_info_body'),
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _buildTitle(bool isRu) {
    if (isRu) {
      const prep = ['январе','феврале','марте','апреле','мае','июне',
          'июле','августе','сентябре','октябре','ноябре','декабре'];
      return 'Алкоголь в ${prep[_currentMonth - 1]}';
    } else {
      final months = ['January','February','March','April','May','June',
          'July','August','September','October','November','December'];
      return 'Alcohol in ${months[_currentMonth - 1]}';
    }
  }

  String _currentMonthName(bool isRu) {
    if (isRu) {
      const names = ['Январь','Февраль','Март','Апрель','Май','Июнь',
          'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'];
      return names[_currentMonth - 1];
    } else {
      const names = ['January','February','March','April','May','June',
          'July','August','September','October','November','December'];
      return names[_currentMonth - 1];
    }
  }

  int _computeMaxY(List<_DayPoint> chartData, List<_DayPoint> compData, List<_DayPoint> avgTraj) {
    final actual = chartData.isEmpty ? 0 : chartData.map((p) => p.cumulative).reduce(max);
    if (widget.comparisonData != null) {
      final comp = compData.isEmpty ? 0 : compData.map((p) => p.cumulative).reduce(max);
      return max(max(actual, comp), 1);
    }
    final avg = avgTraj.isEmpty ? 0 : avgTraj.map((p) => p.cumulative).reduce(max);
    return max(max(actual, avg), 1);
  }

  List<({double fraction, int value})> _computeYTicks(int maxY) {
    final seen = <int>{};
    final result = <({double fraction, int value})>[];
    for (final f in [0.25, 0.5, 0.75, 1.0]) {
      final v = max((maxY * f).round(), 1);
      if (seen.contains(v)) continue;
      seen.add(v);
      result.add((fraction: v / maxY, value: v));
    }
    return result;
  }

  List<Offset> _cgPoints({
    required List<double> data,
    required List<int> days,
    required double chartW,
    required double chartH,
    required int maxY,
  }) {
    if (data.isEmpty) return [];
    final totalDays = (_daysInMonth - 1).toDouble();
    return List.generate(data.length, (i) {
      final day   = days[i];
      final value = data[i];
      final x = _yAxisW + (totalDays == 0 ? 0 : (day - 1) / totalDays * chartW);
      final y = chartH - (maxY == 0 ? 0 : value / maxY * chartH);
      return Offset(x, y);
    });
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _DayPoint {
  final int day;
  final int cumulative;
  const _DayPoint({required this.day, required this.cumulative});
}

// ── Chart painter ──────────────────────────────────────────────────────────────

class _AlcoholChartPainter extends CustomPainter {
  final List<Offset> actualPts;
  final List<Offset> avgPts;
  final List<Offset> compPts;
  final List<({double fraction, int value})> yTicks;
  final int maxY;
  final int daysInMonth;
  final double yAxisW;
  final double chartH;
  final double chartW;
  final double totalH;
  final double labelH;
  final double pulseScale;
  final double pulseOpacity;
  final bool hasComp;

  static const _accentColor = Color(0xFFFF0072);
  static const _blueColor   = Color(0xFF60A5FA);

  _AlcoholChartPainter({
    required this.actualPts,
    required this.avgPts,
    required this.compPts,
    required this.yTicks,
    required this.maxY,
    required this.daysInMonth,
    required this.yAxisW,
    required this.chartH,
    required this.chartW,
    required this.totalH,
    required this.labelH,
    required this.pulseScale,
    required this.pulseOpacity,
    required this.hasComp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid + Y labels
    for (final tick in yTicks) {
      final y = chartH - tick.fraction * chartH;
      canvas.drawLine(
        Offset(yAxisW, y), Offset(size.width, y),
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..strokeWidth = 0.5,
      );
      _drawLabel(canvas, '${tick.value}',
          Offset(0, y - 5), yAxisW - 2, TextAlign.right,
          fontSize: 8, color: Colors.white.withOpacity(0.35));
    }

    // Fill under actual line
    if (actualPts.length >= 2) {
      final fillPath = _buildFillPath(actualPts);
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _accentColor.withOpacity(0.35),
              _accentColor.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
      );
    }

    // Gray average line (only without comparison)
    if (!hasComp && avgPts.length >= 2) {
      canvas.drawPath(
        _smoothPath(avgPts),
        Paint()
          ..color = Colors.white.withOpacity(0.35)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Blue line (comparison)
    if (hasComp && compPts.length >= 2) {
      canvas.drawPath(
        _smoothPath(compPts),
        Paint()
          ..color = _blueColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Red actual line
    if (actualPts.length >= 2) {
      canvas.drawPath(
        _smoothPath(actualPts),
        Paint()
          ..color = _accentColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Pulsing dot — red
    if (actualPts.isNotEmpty) {
      _drawPulsingDot(canvas, actualPts.last, _accentColor);
    }

    // Pulsing dot — blue
    if (hasComp && compPts.isNotEmpty) {
      _drawPulsingDot(canvas, compPts.last, _blueColor);
    }

    // Day labels on X axis
    _drawDayLabels(canvas, size.width);
  }

  void _drawPulsingDot(Canvas canvas, Offset center, Color color) {
    final r = 7.0 * pulseScale;
    canvas.drawCircle(
      center,
      r,
      Paint()..color = color.withOpacity(pulseOpacity * 0.6),
    );
    canvas.drawCircle(
      center,
      3.5,
      Paint()..color = color,
    );
  }

  void _drawDayLabels(Canvas canvas, double width) {
    final totalDays = (daysInMonth - 1).toDouble();
    final labelDays = [1, 5, 10, 15, 20, 25, daysInMonth];
    for (final day in labelDays) {
      final x = yAxisW + (totalDays == 0 ? 0 : (day - 1) / totalDays * chartW);
      _drawLabel(canvas, '$day',
          Offset(x - 10, totalH - labelH + 1), 20, TextAlign.center,
          fontSize: 8, color: Colors.white.withOpacity(0.35));
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double width,
      TextAlign align, {required double fontSize, required Color color}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width);
    final dx = align == TextAlign.right ? pos.dx + width - tp.width : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.length < 2) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = pts[max(i - 1, 0)];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[min(i + 2, pts.length - 1)];
      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  Path _buildFillPath(List<Offset> pts) {
    final path = _smoothPath(pts);
    path.lineTo(pts.last.dx, chartH);
    path.lineTo(pts.first.dx, chartH);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_AlcoholChartPainter old) => true;
}
