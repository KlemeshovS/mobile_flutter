// lib/widgets/percentage_bar_view.dart
import 'package:flutter/material.dart';
import 'package:wobbly/utils/localization.dart';

class PercentageBarView extends StatefulWidget {
  final double drinkingPercentage;
  final double sportPercentage;

  const PercentageBarView({
    super.key,
    required this.drinkingPercentage,
    required this.sportPercentage,
  });

  @override
  State<PercentageBarView> createState() => _PercentageBarViewState();
}

class _PercentageBarViewState extends State<PercentageBarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drinkingRounded = widget.drinkingPercentage.round();
    final sportRounded = widget.sportPercentage.round();
    final localizations = AppLocalizations.of(context); // Получаем локализацию

    // Определяем, какая часть занимает 100%
    final isDrinkingFull = drinkingRounded == 100 && sportRounded == 0;
    final isSportFull = sportRounded == 100 && drinkingRounded == 0;
    final hasBoth = drinkingRounded > 0 && sportRounded > 0;

    return Column(
      children: [
        // Заголовок (уже использует alcoholVsSportTitle)
        Text(
          localizations.alcoholVsSportTitle, // Используем существующий геттер
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),

        // Прогресс-бар
        Container(
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                children: [
                  // Алкогольная часть
                  if (widget.drinkingPercentage > 0)
                    Expanded(
                      flex: (widget.drinkingPercentage * _animation.value).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: _getDrinkingBorderRadius(isDrinkingFull, hasBoth),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEA0505), // Красный
                              Color(0xFFFF8A65), // Оранжевый
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),

                  // Спортивная часть
                  if (widget.sportPercentage > 0)
                    Expanded(
                      flex: (widget.sportPercentage * _animation.value).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: _getSportBorderRadius(isSportFull, hasBoth),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFC7FF00), // Ярко-зеленый
                              Color(0xFFA8E6A8), // Светло-зеленый
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 12),

        // Легенда с процентами
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Алкоголь
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEA0505),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '${localizations.alcoholLabel} ${widget.drinkingPercentage.round()}%', // Используем локализацию
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            // Спорт
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC7FF00),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '${localizations.sportLabelBar} ${widget.sportPercentage.round()}%', // Используем локализацию
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Метод для определения скругления алкогольной части
  BorderRadiusGeometry _getDrinkingBorderRadius(bool isDrinkingFull, bool hasBoth) {
    if (isDrinkingFull) {
      // Если алкоголь 100% - скругляем все углы
      return BorderRadius.circular(8);
    } else if (hasBoth) {
      // Если есть обе части - скругляем только левые углы
      return BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    } else {
      // Только алкоголь (но не 100%) - тоже скругляем все углы
      return BorderRadius.circular(8);
    }
  }

  // Метод для определения скругления спортивной части
  BorderRadiusGeometry _getSportBorderRadius(bool isSportFull, bool hasBoth) {
    if (isSportFull) {
      // Если спорт 100% - скругляем все углы
      return BorderRadius.circular(8);
    } else if (hasBoth) {
      // Если есть обе части - скругляем только правые углы
      return BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    } else {
      // Только спорт (но не 100%) - тоже скругляем все углы
      return BorderRadius.circular(8);
    }
  }
}