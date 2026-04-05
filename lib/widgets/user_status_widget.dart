// lib/widgets/user_status_widget.dart
import 'package:flutter/material.dart';
import 'package:wobbly/models/user_status.dart';
import 'package:wobbly/utils/localization.dart';
import 'package:google_fonts/google_fonts.dart';


class UserStatusWidget extends StatelessWidget {
  final UserStatus status;
  final VoidCallback onTap;

  const UserStatusWidget({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final color = _getColorFromHex(status.hexColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/${status.iconName}.png',
                  width: 46,
                  height: 46,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.getUserStatusTitle(status),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('0xFF$hex'));
    }
    return Colors.white;
  }
}