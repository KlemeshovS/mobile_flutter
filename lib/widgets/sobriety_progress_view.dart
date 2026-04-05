// lib/widgets/sobriety_progress_view.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/sobriety_progress_calculator.dart';
import '../utils/localization.dart';


class SobrietyProgressView extends StatefulWidget {
  final int progressDays;

  const SobrietyProgressView({
    super.key,
    required this.progressDays,
  });

  @override
  State<SobrietyProgressView> createState() => _SobrietyProgressViewState();
}

class _SobrietyProgressViewState extends State<SobrietyProgressView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _glowAnimation = false;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Начальное значение для анимации - 0
    _progressAnimation = Tween<double>(
      begin: 0,
      end: _calculateAnimatedProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();

      if (widget.progressDays > 365 ||
          (widget.progressDays < 0 && widget.progressDays.abs() > SobrietyProgressCalculator.maxNegativeDays)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _glowAnimation = true;
            });
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Сбрасываем анимацию при каждом открытии экрана
    if (!_isFirstBuild) {
      _resetAndStartAnimation();
    }
    _isFirstBuild = false;
  }

  @override
  void didUpdateWidget(covariant SobrietyProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressDays != widget.progressDays) {
      _resetAndStartAnimation();

      // Включение свечения для больших отрицательных
      if (widget.progressDays < 0 && widget.progressDays.abs() > SobrietyProgressCalculator.maxNegativeDays) {
        setState(() {
          _glowAnimation = true;
        });
      } else {
        setState(() {
          _glowAnimation = false;
        });
      }

      if (widget.progressDays > 365) {
        setState(() {
          _glowAnimation = true;
        });
      }
    }
  }

  void _resetAndStartAnimation() {
    _progressAnimation = Tween<double>(
      begin: 0, // Всегда начинаем с 0
      end: _calculateAnimatedProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.reset();
    _animationController.forward();
  }

  double _calculateAnimatedProgress() {
    if (widget.progressDays < 0) {
      const maxNegativeDays = 500.0;
      return (widget.progressDays.abs() / maxNegativeDays).clamp(0.0, 1.0);
    } else if (widget.progressDays <= SobrietyProgressCalculator.maxDays) {
      return (widget.progressDays / SobrietyProgressCalculator.maxDays).clamp(0.0, 1.0);
    } else {
      return 1.0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          _buildHeader(),
          const SizedBox(height: 16),

          // Основной контент в зависимости от типа прогресса
          if (widget.progressDays < 0)
            widget.progressDays.abs() > SobrietyProgressCalculator.maxNegativeDays
                ? _buildLargeNegativeProgress()
                : _buildNegativeProgress()
          else if (widget.progressDays <= SobrietyProgressCalculator.maxDays)
            _buildPositiveProgress()
          else
            _buildPostYearProgress(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.progressDays < 0
        ? _localize('your_negative_progress_title')
        : _localize('your_progress_title');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (widget.progressDays <= SobrietyProgressCalculator.maxDays &&
            widget.progressDays >= -SobrietyProgressCalculator.maxNegativeDays)          Text(
            _getFormattedValue(widget.progressDays),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.progressDays < 0
                  ? Colors.red.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildNegativeProgress() {
    final nextMilestone = SobrietyProgressCalculator.nextNegativeMilestone(widget.progressDays);
    final daysToNext = nextMilestone != null
        ? nextMilestone - widget.progressDays.abs()
        : 0;

    return Column(
      children: [
        // Прогресс-бар для отрицательных значений
        SizedBox(
          height: 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Фоновая полоса
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Анимированный отрицательный прогресс (справа налево)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final width = constraints.maxWidth * min(_progressAnimation.value, 1.0);
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF800000), Colors.red],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Индикатор следующей вехи - на одной строке
        if (nextMilestone != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _localize('next_negative_step_title'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$daysToNext${_localize('days')}",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

        // Вехи для отрицательного прогресса
        const SizedBox(height: 12),
        Row(
          children: SobrietyProgressCalculator.negativeMilestones.map((milestone) {
            final isNext = nextMilestone == milestone;
            final isCompleted = widget.progressDays.abs() >= milestone;

            return Expanded(
              child: NegativeMilestoneIndicator(
                milestone: milestone,
                isCompleted: isCompleted,
                isNext: isNext,
                title: '$milestone${_localize('negative_days_suffix')}',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLargeNegativeProgress() {
    final nextMilestone = SobrietyProgressCalculator.nextNegativeMilestone(widget.progressDays);
    final daysToNext = nextMilestone != null
        ? nextMilestone - widget.progressDays.abs()
        : 0;

    return Column(
      children: [
        // Большая красная цифра с анимацией свечения
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          child: _buildGlowingText(
            number: "${widget.progressDays.abs()}",
            suffix: _localize('negative_days_suffix'),
            textColor: Colors.red,
            glow: _glowAnimation,
          ),
        ),
        const SizedBox(height: 2),

        // Следующий рубеж
        if (nextMilestone != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _localize('next_negative_step_title'),
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(width: 4),
              Text(
                "$daysToNext ${_localize('days')}",
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),

        // Вехи после 500
        const SizedBox(height: 12),
        Row(
          children: SobrietyProgressCalculator.postNegativeMilestones.map((milestone) {
            final isNext = nextMilestone == milestone;
            final isCompleted = widget.progressDays.abs() >= milestone;

            return Expanded(
              child: PostNegativeMilestoneIndicator(
                milestone: milestone,
                isCompleted: isCompleted,
                isNext: isNext,
                title: '$milestone${_localize('negative_days_suffix')}',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositiveProgress() {
    final nextMilestone = SobrietyProgressCalculator.nextMilestone(widget.progressDays);
    final daysToNext = nextMilestone != null
        ? nextMilestone.days - widget.progressDays
        : 0;

    return Column(
      children: [
        // Прогресс-бар для положительных значений
        SizedBox(
          height: 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Фоновая полоса
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Анимированный положительный прогресс
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final width = constraints.maxWidth * min(_progressAnimation.value, 1.0);
                      return Container(
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green],
                            stops: [0.0, 0.33, 0.66, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Индикатор следующей вехи - на одной строке
        if (nextMilestone != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _localize('next_step_title'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$daysToNext ${_localize('days')}",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

        // Вехи для положительного прогресса
        const SizedBox(height: 12),
        Row(
          children: SobrietyProgressCalculator.milestones.map((milestone) {
            return Expanded(
              child: MilestoneIndicator(
                milestone: milestone,
                isCompleted: widget.progressDays >= milestone.days,
                isNext: nextMilestone?.days == milestone.days,
                title: _localize(milestone.titleKey),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPostYearProgress() {
    final nextMilestone = SobrietyProgressCalculator.nextPostYearMilestone(widget.progressDays);
    final daysToNext = nextMilestone != null
        ? nextMilestone - widget.progressDays
        : 0;

    return Column(
      children: [
        // Большая цифра с анимацией свечения
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          child: _buildGlowingText(
            number: "${widget.progressDays}",
            suffix: _localize('positive_days_suffix'),
            textColor: Colors.white,
            glowColor: Colors.green,
            glow: _glowAnimation,
          ),
        ),
        const SizedBox(height: 2),

        // Следующий рубеж - на одной строке
        if (nextMilestone != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _localize('next_step_title'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$daysToNext${_localize('days')}",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

        // Вехи после года
        const SizedBox(height: 12),
        Row(
          children: SobrietyProgressCalculator.postYearMilestones.map((milestone) {
            final isNext = nextMilestone == milestone;

            return Expanded(
              child: PostYearMilestoneIndicator(
                milestone: milestone,
                isCompleted: widget.progressDays >= milestone,
                isNext: isNext,
                title: '$milestone${_localize('positive_days_suffix')}',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGlowingText({
    required String number,
    required String suffix,
    required Color textColor,
    Color? glowColor, // если не указан, используется textColor
    required bool glow,
  }) {
    final baseStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 60,
      fontWeight: FontWeight.bold,
    );

    final effectiveGlowColor = glowColor ?? textColor;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Число с эффектом свечения
          Stack(
            children: [
              if (glow) ...[
                // Внешнее размытое свечение (большой радиус)
                Text(
                  number,
                  style: baseStyle.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = effectiveGlowColor.withOpacity(0.3)
                      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20),
                  ),
                ),
                // Среднее свечение
                Text(
                  number,
                  style: baseStyle.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = effectiveGlowColor.withOpacity(0.5)
                      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12),
                  ),
                ),
                // Ближнее свечение
                Text(
                  number,
                  style: baseStyle.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = effectiveGlowColor.withOpacity(0.8)
                      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
                  ),
                ),
              ],
              // Основной текст (без размытия)
              Text(
                number,
                style: baseStyle.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Суффикс (без свечения)
          Flexible(
            child: Text(
              suffix,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _localize(String key) {
    return AppLocalizations.of(context).translate(key);
  }

  String _getFormattedValue(int progressDays) {
    if (progressDays < 0) {
      return "${progressDays.abs()}${_localize('negative_days_suffix')}";
    } else {
      return "$progressDays${_localize('positive_days_suffix')}";
    }
  }
}

// Виджеты индикаторов вех
class MilestoneIndicator extends StatelessWidget {
  final Milestone milestone;
  final bool isCompleted;
  final bool isNext;
  final String title;

  const MilestoneIndicator({
    super.key,
    required this.milestone,
    required this.isCompleted,
    required this.isNext,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          )
              : Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isNext ? Colors.white : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              color: isNext ? Colors.white.withOpacity(0.1) : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: isNext ? FontWeight.w500 : FontWeight.normal,
            color: isCompleted
                ? Colors.green
                : isNext
                ? Colors.white
                : Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class PostYearMilestoneIndicator extends StatelessWidget {
  final int milestone;
  final bool isCompleted;
  final bool isNext;
  final String title;

  const PostYearMilestoneIndicator({
    super.key,
    required this.milestone,
    required this.isCompleted,
    required this.isNext,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(
            Icons.emoji_events,
            color: Colors.yellow,
            size: 16,
          )
              : Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isNext ? Colors.white : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              color: isNext ? Colors.white.withOpacity(0.1) : Colors.transparent,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 9,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.yellow : Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class NegativeMilestoneIndicator extends StatelessWidget {
  final int milestone;
  final bool isCompleted;
  final bool isNext;
  final String title;

  const NegativeMilestoneIndicator({
    super.key,
    required this.milestone,
    required this.isCompleted,
    required this.isNext,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: isCompleted
              ? Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.red,
              size: 8,
            ),
          )
              : Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isNext ? Colors.white : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              color: isNext ? Colors.white.withOpacity(0.1) : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.red : Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class PostNegativeMilestoneIndicator extends StatelessWidget {
  final int milestone;
  final bool isCompleted;
  final bool isNext;
  final String title;

  const PostNegativeMilestoneIndicator({
    super.key,
    required this.milestone,
    required this.isCompleted,
    required this.isNext,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: isCompleted
              ? Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.red, size: 8),
          )
              : Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isNext ? Colors.white : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              color: isNext ? Colors.white.withOpacity(0.1) : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.red : Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}