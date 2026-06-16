import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/localization.dart';
import '../utils/review_manager.dart';
import '../utils/achievement_manager.dart';
import 'info_sheet.dart';

class ReviewPromptView extends StatefulWidget {
  final VoidCallback onLater;
  final VoidCallback onRate;

  const ReviewPromptView({
    super.key,
    required this.onLater,
    required this.onRate,
  });

  static void show(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ReviewPromptView(
            onLater: () {
              // Закрываем основное окно отзыва
              Navigator.of(context).pop();
              // Показываем информационное окно
              InfoSheet.show(
                context: context,
                message: AppLocalizations.of(context).reviewLaterMessage,
                onButtonPressed: () {
                  ReviewManager().didShowPrompt(); // выполняем логику напоминания позже
                },
              );
            },
            onRate: () async {
              Navigator.of(context).pop();
              await ReviewManager().didRate();
              await AchievementManager().unlockReviewAchievement();
              const packageName = 'com.tritan.wobbly_flutter'; // Ссылка на приложение в google play
              final url = 'market://details?id=$packageName';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                final webUrl = 'https://play.google.com/store/apps/details?id=$packageName';
                if (await canLaunch(webUrl)) {
                  await launch(webUrl);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  State<ReviewPromptView> createState() => _ReviewPromptViewState();
}

class _ReviewPromptViewState extends State<ReviewPromptView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D2B55), Color(0xFF3E3B6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.reviewTitle,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                localizations.reviewMessage,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14, color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onRate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: Text(
                        localizations.reviewRateButton,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onLater,
                child: Text(
                  localizations.reviewLaterButton,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14, color: Colors.white.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}