// lib/widgets/monthly_average_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/utils/localization.dart';

class MonthlyAverageWidget extends StatefulWidget {
  /// Данные пользователя. Ключи в формате "год-месяц0-день" (месяц 0-based).
  final Map<String, DayRecord> daysData;
  final int selectedYear;

  /// null = собственный профиль ("вы"), иначе имя друга
  final String? username;

  const MonthlyAverageWidget({
    super.key,
    required this.daysData,
    required this.selectedYear,
    this.username,
  });

  @override
  State<MonthlyAverageWidget> createState() => _MonthlyAverageWidgetState();
}

class _MonthlyAverageWidgetState extends State<MonthlyAverageWidget> {
  // 0 = алкоголь, 1 = спорт, 2 = общее
  int _modeIndex = 0;

  static const _prefKey = 'monthlyAverageModeIndex';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _modeIndex = p.getInt(_prefKey) ?? 0);
    });
  }

  Future<void> _setMode(int idx) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefKey, idx);
    if (mounted) setState(() => _modeIndex = idx);
  }

  bool get _isAlcohol  => _modeIndex == 0;
  bool get _isSport    => _modeIndex == 1;
  bool get _isCombined => _modeIndex == 2;

  // ── Data ──────────────────────────────────────────────────────────────────

  List<_MonthData> _monthDataFor({required bool alcohol}) {
    final now = DateTime.now();
    final currentYear  = now.year;
    final currentMonth = now.month; // 1-based

    return List.generate(12, (i) {
      final month1 = i + 1; // 1-based
      final isFuture = widget.selectedYear > currentYear ||
          (widget.selectedYear == currentYear && month1 > currentMonth);

      int count = 0;
      if (!isFuture) {
        for (final entry in widget.daysData.entries) {
          final parts = entry.key.split('-');
          if (parts.length != 3) continue;
          final y  = int.tryParse(parts[0]);
          final m1 = int.tryParse(parts[1]); // 1-based (DayData.key uses month+1)
          if (y == null || m1 == null) continue;
          if (y != widget.selectedYear) continue;
          if (m1 != month1) continue;

          final record = entry.value;
          if (alcohol) {
            final isDrink = record.drinkLevel != DrinkLevel.none &&
                record.drinkLevel != DrinkLevel.unknown;
            if (isDrink) count++;
          } else {
            if (record.hasSport) count++;
          }
        }
      }
      return _MonthData(index: i, count: count, isFuture: isFuture);
    });
  }

  List<_MonthData> get _alcoholData => _monthDataFor(alcohol: true);
  List<_MonthData> get _sportData   => _monthDataFor(alcohol: false);
  List<_MonthData> get _monthData   => _isAlcohol ? _alcoholData : _sportData;

  double _averageFor(List<_MonthData> data) {
    final past = data.where((d) => !d.isFuture).toList();
    if (past.isEmpty) return 0;
    return past.fold(0, (s, d) => s + d.count) / past.length;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
          // Заголовок
          Text(
            loc.translate('monthly_average_title'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Тоггл
          _buildToggle(loc),
          const SizedBox(height: 14),

          // График
          SizedBox(
            height: 140,
            child: _isCombined ? _buildCombinedChart(loc) : _buildSingleChart(loc),
          ),

          // Легенда (только для "Общее")
          if (_isCombined) ...[
            const SizedBox(height: 12),
            _legendRow(const Color(0xFFFF0072), loc.translate('monthly_legend_alcohol')),
            const SizedBox(height: 4),
            _legendRow(const Color(0xFFC7FF00), loc.translate('monthly_legend_sport')),
          ],

          // Аналитическая фраза (только в одиночных режимах)
          if (!_isCombined) ...[
            Builder(builder: (_) {
              final phrase = _analyticsPhrase(loc);
              if (phrase == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  phrase,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _toggleButton(
            label: loc.translate('monthly_mode_alcohol'),
            active: _isAlcohol,
            activeColor: const Color(0xFFFF0072),
            onTap: () => _setMode(0),
          ),
          _toggleButton(
            label: loc.translate('monthly_mode_sport'),
            active: _isSport,
            activeColor: const Color(0xFFC7FF00),
            onTap: () => _setMode(1),
          ),
          _toggleButton(
            label: loc.translate('monthly_mode_combined'),
            active: _isCombined,
            activeColor: const Color(0xFFA78BFA),
            onTap: () => _setMode(2),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? Colors.white : Colors.white.withOpacity(0.45),
            ),
          ),
        ),
      ),
    );
  }

  // ── Single chart ──────────────────────────────────────────────────────────

  Widget _buildSingleChart(AppLocalizations loc) {
    final data    = _monthData;
    final avgRaw  = _averageFor(data);
    final avgInt  = avgRaw.round();
    final maxCount = max(data.map((d) => d.count).fold(0, max), 1);
    final accentColor = _isAlcohol ? const Color(0xFFFF0072) : const Color(0xFFC7FF00);
    final avgPrefix = loc.translate('monthly_avg_prefix');

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      const labelH = 16.0;
      final chartH = constraints.maxHeight - labelH;

      return CustomPaint(
        painter: _MonthlyBarPainter(
          data: data,
          maxCount: maxCount,
          avgRaw: avgRaw,
          avgInt: avgInt,
          barColor: accentColor,
          avgPrefix: avgPrefix,
          labelH: labelH,
          chartH: chartH,
          width: w,
          locale: Localizations.localeOf(context).languageCode,
        ),
        size: Size(w, constraints.maxHeight),
      );
    });
  }

  // ── Combined chart ────────────────────────────────────────────────────────

  Widget _buildCombinedChart(AppLocalizations loc) {
    final aData = _alcoholData;
    final sData = _sportData;
    final aAvgInt = _averageFor(aData).round();
    final sAvgInt = _averageFor(sData).round();
    final maxCount = max(
      max(aData.map((d) => d.count).fold(0, max), sData.map((d) => d.count).fold(0, max)),
      1,
    );
    final avgPrefix = loc.translate('monthly_avg_prefix');

    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      const labelH = 16.0;
      final chartH = constraints.maxHeight - labelH;

      return CustomPaint(
        painter: _MonthlyCombinedPainter(
          aData: aData,
          sData: sData,
          maxCount: maxCount,
          aAvgInt: aAvgInt,
          sAvgInt: sAvgInt,
          avgPrefix: avgPrefix,
          labelH: labelH,
          chartH: chartH,
          width: w,
          locale: Localizations.localeOf(context).languageCode,
        ),
        size: Size(w, constraints.maxHeight),
      );
    });
  }

  // ── Legend row ────────────────────────────────────────────────────────────

  Widget _legendRow(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // ── Analytics phrase ──────────────────────────────────────────────────────

  String? _analyticsPhrase(AppLocalizations loc) {
    final now = DateTime.now();
    if (widget.selectedYear != now.year) return null;
    final avgRaw = _averageFor(_monthData);
    if (avgRaw <= 0) return null;

    final currentMonthIdx = now.month - 1; // 0-based index
    final current = _monthData[currentMonthIdx];
    if (current.isFuture) return null;

    final diff   = current.count - avgRaw.round();
    final isRu   = Localizations.localeOf(context).languageCode == 'ru';
    final user   = widget.username;

    if (isRu) {
      final subject = user ?? 'вы';
      final drinkV  = user != null ? 'пьёт' : 'пьёте';
      final sportV  = user != null ? 'занимается спортом' : 'занимаетесь спортом';
      if (diff == 0) {
        return _isAlcohol
            ? 'В этом месяце $subject $drinkV как обычно'
            : 'В этом месяце $subject $sportV как обычно';
      }
      final n    = diff.abs();
      final dir  = diff > 0 ? 'чаще' : 'реже';
      final word = _daysWord(n, isRu: true);
      return _isAlcohol
          ? 'В этом месяце $subject $drinkV на $n $word $dir, чем обычно'
          : 'В этом месяце $subject $sportV на $n $word $dir, чем обычно';
    } else {
      final subject = user ?? 'you';
      final drinkV  = user != null ? 'drinks' : 'drink';
      final sportV  = user != null ? 'works out' : 'work out';
      if (diff == 0) {
        return _isAlcohol
            ? 'This month $subject $drinkV as usual'
            : 'This month $subject $sportV as usual';
      }
      final n    = diff.abs();
      final dir  = diff > 0 ? 'more' : 'less';
      final word = n == 1 ? 'day' : 'days';
      return _isAlcohol
          ? 'This month $subject $drinkV $n $word $dir than usual'
          : 'This month $subject $sportV $n $word $dir than usual';
    }
  }

  String _daysWord(int n, {required bool isRu}) {
    if (!isRu) return n == 1 ? 'day' : 'days';
    final m100 = n % 100;
    final m10  = n % 10;
    if (m100 >= 11 && m100 <= 14) return 'дней';
    if (m10 == 1)                  return 'день';
    if (m10 >= 2 && m10 <= 4)     return 'дня';
    return 'дней';
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _MonthData {
  final int index;
  final int count;
  final bool isFuture;
  const _MonthData({required this.index, required this.count, required this.isFuture});
}

// ── Single-mode painter ────────────────────────────────────────────────────────

class _MonthlyBarPainter extends CustomPainter {
  final List<_MonthData> data;
  final int maxCount;
  final double avgRaw;
  final int avgInt;
  final Color barColor;
  final String avgPrefix;
  final double labelH;
  final double chartH;
  final double width;
  final String locale;

  _MonthlyBarPainter({
    required this.data,
    required this.maxCount,
    required this.avgRaw,
    required this.avgInt,
    required this.barColor,
    required this.avgPrefix,
    required this.labelH,
    required this.chartH,
    required this.width,
    required this.locale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 6.0;
    final barW = (width - 11 * spacing) / 12;
    final now  = DateTime.now();
    final monthLetters = _monthLetters(locale);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (final f in [0.25, 0.5, 0.75, 1.0]) {
      final y = chartH - f * chartH;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Bars
    for (int i = 0; i < 12; i++) {
      final d    = data[i];
      final x    = i * (barW + spacing);
      final barH = _barHeight(d.count, d.isFuture);

      Color fill;
      if (d.isFuture) {
        fill = Colors.white.withOpacity(0.10);
      } else if (d.count == 0) {
        fill = Colors.white.withOpacity(0.06);
      } else {
        fill = barColor.withOpacity(0.75);
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartH - barH, barW, barH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = fill);

      // Month letter
      final isCurrentMonth = now.year == DateTime.now().year &&
          now.month == i + 1;
      _drawText(
        canvas,
        monthLetters[i],
        Offset(x + barW / 2, chartH + 3),
        fontSize: 9,
        color: isCurrentMonth
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        align: TextAlign.center,
      );
    }

    // Average line + label
    if (avgRaw > 0) {
      final avgFrac = avgInt / maxCount;
      final avgY    = chartH - avgFrac * chartH;
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(0, avgY), Offset(width, avgY), linePaint);

      // Label
      final labelText = '$avgPrefix $avgInt ${_daysWord(avgInt, locale: locale)}';
      final tp = _textPainter(labelText, fontSize: 9, fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.85));
      tp.layout();
      final lw = tp.width + 10;
      final lx = width - lw - 4;
      final ly = avgY - 16;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(lx, ly, lw, 14), const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.45),
      );
      tp.paint(canvas, Offset(lx + 5, ly + 1));
    }
  }

  double _barHeight(int count, bool isFuture) {
    if (isFuture) return chartH * 0.10;
    if (count == 0) return 3;
    return max(count / maxCount * chartH, 3);
  }

  @override
  bool shouldRepaint(_MonthlyBarPainter old) => true;
}

// ── Combined-mode painter ──────────────────────────────────────────────────────

class _MonthlyCombinedPainter extends CustomPainter {
  final List<_MonthData> aData;
  final List<_MonthData> sData;
  final int maxCount;
  final int aAvgInt;
  final int sAvgInt;
  final String avgPrefix;
  final double labelH;
  final double chartH;
  final double width;
  final String locale;

  _MonthlyCombinedPainter({
    required this.aData,
    required this.sData,
    required this.maxCount,
    required this.aAvgInt,
    required this.sAvgInt,
    required this.avgPrefix,
    required this.labelH,
    required this.chartH,
    required this.width,
    required this.locale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const pairSpacing  = 4.0;
    const innerSpacing = 2.0;
    final pairW = (width - 11 * pairSpacing) / 12;
    final barW  = (pairW - innerSpacing) / 2;
    final now   = DateTime.now();
    final monthLetters = _monthLetters(locale);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (final f in [0.25, 0.5, 0.75, 1.0]) {
      final y = chartH - f * chartH;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Bars
    for (int i = 0; i < 12; i++) {
      final pairX = i * (pairW + pairSpacing);
      final a = aData[i];
      final s = sData[i];

      // Alcohol bar (left)
      final aH = _barHeight(a.count, a.isFuture);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pairX, chartH - aH, barW, aH),
          const Radius.circular(2),
        ),
        Paint()..color = _fill(a.isFuture, a.count, const Color(0xFFFF0072)),
      );

      // Sport bar (right)
      final sH = _barHeight(s.count, s.isFuture);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pairX + barW + innerSpacing, chartH - sH, barW, sH),
          const Radius.circular(2),
        ),
        Paint()..color = _fill(s.isFuture, s.count, const Color(0xFFC7FF00)),
      );

      // Month letter
      final isCurrentMonth = now.month == i + 1;
      _drawText(
        canvas,
        monthLetters[i],
        Offset(pairX + pairW / 2, chartH + 3),
        fontSize: 9,
        color: isCurrentMonth
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        align: TextAlign.center,
      );
    }

    // Sport avg line (left label)
    if (sAvgInt > 0) {
      final y = chartH - (sAvgInt / maxCount) * chartH;
      canvas.drawLine(
        Offset(0, y), Offset(width, y),
        Paint()..color = const Color(0xFFC7FF00).withOpacity(0.6)..strokeWidth = 1.5,
      );
      final lbl = '$avgPrefix $sAvgInt';
      final tp  = _textPainter(lbl, fontSize: 9, fontWeight: FontWeight.w600,
          color: const Color(0xFFC7FF00).withOpacity(0.9));
      tp.layout();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(4, y - 16, tp.width + 10, 14), const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.45),
      );
      tp.paint(canvas, Offset(9, y - 15));
    }

    // Alcohol avg line (right label)
    if (aAvgInt > 0) {
      final y   = chartH - (aAvgInt / maxCount) * chartH;
      final lbl = '$avgPrefix $aAvgInt';
      final tp  = _textPainter(lbl, fontSize: 9, fontWeight: FontWeight.w600,
          color: const Color(0xFFFF0072).withOpacity(0.9));
      tp.layout();
      final lw  = tp.width + 10;
      final lx  = width - lw - 4;
      canvas.drawLine(
        Offset(0, y), Offset(width, y),
        Paint()..color = const Color(0xFFFF0072).withOpacity(0.6)..strokeWidth = 1.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(lx, y - 16, lw, 14), const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.45),
      );
      tp.paint(canvas, Offset(lx + 5, y - 15));
    }
  }

  Color _fill(bool isFuture, int count, Color color) {
    if (isFuture) return Colors.white.withOpacity(0.10);
    if (count == 0) return Colors.white.withOpacity(0.06);
    return color.withOpacity(0.75);
  }

  double _barHeight(int count, bool isFuture) {
    if (isFuture) return chartH * 0.10;
    if (count == 0) return 3;
    return max(count / maxCount * chartH, 3);
  }

  @override
  bool shouldRepaint(_MonthlyCombinedPainter old) => true;
}

// ── Shared helpers ────────────────────────────────────────────────────────────

List<String> _monthLetters(String locale) {
  // Первые буквы месяцев на нужном языке
  if (locale == 'ru') {
    return ['Я','Ф','М','А','М','И','И','А','С','О','Н','Д'];
  }
  return ['J','F','M','A','M','J','J','A','S','O','N','D'];
}

String _daysWord(int n, {required String locale}) {
  if (locale != 'ru') return n == 1 ? 'day' : 'days';
  final m100 = n % 100;
  final m10  = n % 10;
  if (m100 >= 11 && m100 <= 14) return 'дней';
  if (m10 == 1)                  return 'день';
  if (m10 >= 2 && m10 <= 4)     return 'дня';
  return 'дней';
}

TextPainter _textPainter(String text, {
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
  required Color color,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
    ),
    textDirection: TextDirection.ltr,
  );
  return tp;
}

void _drawText(
  Canvas canvas,
  String text,
  Offset position, {
  required double fontSize,
  required Color color,
  TextAlign align = TextAlign.left,
}) {
  final tp = _textPainter(text, fontSize: fontSize, color: color);
  tp.layout();
  final dx = align == TextAlign.center ? position.dx - tp.width / 2 : position.dx;
  tp.paint(canvas, Offset(dx, position.dy));
}
