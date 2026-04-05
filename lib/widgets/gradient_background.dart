import 'package:flutter/material.dart';
import 'package:wobbly/app/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
      ),
      padding: padding,
      child: child,
    );
  }
}