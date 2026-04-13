import 'package:flutter/material.dart';
import '../utils/localization.dart';

/// Универсальное информационное окно с одной кнопкой.
///
/// Показывает сообщение [message] и кнопку с текстом [buttonText].
/// При нажатии на кнопку вызывается [onButtonPressed] и окно закрывается.
class InfoSheet extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const InfoSheet({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  static void show({
    required BuildContext context,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: InfoSheet(
          message: message,
          buttonText: buttonText ?? localizations.ok,
          onButtonPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Полоска для свайпа (как в других bottom sheets)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Кнопка OK в стиле градиента
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onButtonPressed();
                Navigator.of(context).pop(); // закрываем окно
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    buttonText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
