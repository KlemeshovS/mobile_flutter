import 'package:flutter/material.dart';
import 'package:wobbly/services/auth_service.dart';
import 'package:wobbly/utils/localization.dart';

/// Компактный bottom sheet с кнопками авторизации (Google + Яндекс).
/// Показывается когда неавторизованный пользователь пытается выполнить
/// действие требующее авторизации.
class LoginBottomSheet extends StatefulWidget {
  /// Вызывается после успешной авторизации (до закрытия листа).
  final VoidCallback? onLoginSuccess;

  const LoginBottomSheet({super.key, this.onLoginSuccess});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final success = await AuthService().signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      widget.onLoginSuccess?.call();
      Navigator.pop(context);
    }
  }

  Future<void> _signInWithYandex() async {
    setState(() => _isLoading = true);
    final success = await AuthService().signInWithYandex();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      widget.onLoginSuccess?.call();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('yandex_sign_in_error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2B55),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ручка
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF8B5CF6),
            child: Icon(Icons.person_outline, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('profile_guest_title'),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('profile_guest_message'),
            style: const TextStyle(fontSize: 13, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            )
          else ...[
            // Кнопка Google
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  surfaceTintColor: Colors.transparent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/google_logo.png', height: 22, width: 22),
                    const SizedBox(width: 12),
                    Text(
                      loc.translate('google_sign_in_button'),
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Кнопка Яндекс
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _signInWithYandex,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/yandex_logo.png',
                      height: 22, width: 22,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.translate('sign_in_with_yandex'),
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
