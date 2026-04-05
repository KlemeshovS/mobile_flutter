import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:shared_preferences/shared_preferences.dart'; // добавить этот импорт

typedef OnAnimationComplete = void Function(Map<String, DayRecord>? data, bool isFirstLaunch);

class SplashScreen extends StatefulWidget {
  final OnAnimationComplete onAnimationComplete;
  final Duration displayDuration;
  final Future<Map<String, DayRecord>> dataFuture;
  final Future<SharedPreferences> prefsFuture;
  final Future<void> achievementsFuture;

  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
    this.displayDuration = const Duration(seconds: 3),
    required this.dataFuture,
    required this.prefsFuture,
    required this.achievementsFuture,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late AnimationController _subtitleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _rotationAnimation;

  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    print('🕐 SplashScreen initState: ${DateTime.now().millisecondsSinceEpoch}');

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _subtitleController.forward();
    });

    _generateParticles();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Ожидаем минимальное время показа и ВСЕ Future
    Future.wait([
      Future.delayed(widget.displayDuration),
      widget.dataFuture,
      widget.prefsFuture,
      widget.achievementsFuture,
    ]).then((results) {
      if (!mounted) return;
      final data = results[1] as Map<String, DayRecord>;
      final prefs = results[2] as SharedPreferences;
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;
      widget.onAnimationComplete(data, isFirstLaunch);
    }).catchError((error) {
      // Если что-то пошло не так — безопасно показываем туториал
      if (!mounted) return;
      widget.onAnimationComplete(null, true);
    });
  }

  void _generateParticles() {
    final random = math.Random();
    const count = 30;
    for (int i = 0; i < count; i++) {
      _particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        baseOpacity: random.nextDouble() * 0.2 + 0.1,
        speed: random.nextDouble() * 1 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    _subtitleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🕐 SplashScreen build: ${DateTime.now().millisecondsSinceEpoch}');

    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF2A1E5C),
              Color(0xFF4B3A91),
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: 2 * math.pi,
                      transform: GradientRotation(_rotationAnimation.value),
                      colors: const [
                        Color(0xFF8B5CF6),
                        Color(0xFF4B3A91),
                        Color(0xFF2A1E5C),
                        Color(0xFF8B5CF6),
                      ].map((c) => c.withOpacity(0.3)).toList(),
                    ),
                  ),
                );
              },
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticlesPainter(
                        particles: _particles,
                        time: _particleController.value * 2 * math.pi,
                      ),
                    );
                  },
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _glowController]),
                    builder: (context, child) {
                      final glowValue = _glowController.value;
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF8B5CF6).withOpacity(0.3 + glowValue * 0.3),
                                    const Color(0xFF4B3A91).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  width: 4,
                                  color: const Color(0xFF8B5CF6).withOpacity(0.8 + glowValue * 0.2),
                                ),
                              ),
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/icon.png',
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  AnimatedBuilder(
                    animation: _titleOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              localizations.appTitle,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xCC8B5CF6),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeTransition(
                              opacity: _subtitleOpacity,
                              child: Text(
                                localizations.appSubtitle,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Невидимый текст для принудительной загрузки шрифта
            Offstage(
              offstage: true,
              child: Text(
                '',
                style: TextStyle(
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double speed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.speed,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _ParticlesPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      paint.color = Colors.white.withOpacity(p.baseOpacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}