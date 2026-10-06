import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HotkeyGuide extends StatelessWidget {
  final bool isDark;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const HotkeyGuide({
    super.key,
    required this.isDark,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161B) : const Color(0xFFF1F1F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF282832) : const Color(0xFFDFDFE6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous button / hotkey
          _buildHotkeyButton(
            keyLabel: 'F7',
            altKeyLabel: 'Num -',
            actionLabel: 'PREV',
            color: const Color(0xFFFF9500),
            isDark: isDark,
            onTap: onPrev,
          ),
          const SizedBox(width: 8),

          // Divider dot
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Next button / hotkey
          _buildHotkeyButton(
            keyLabel: 'F8',
            altKeyLabel: 'Num +',
            actionLabel: 'NEXT',
            color: AppColors.successGreen,
            isDark: isDark,
            onTap: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildHotkeyButton({
    required String keyLabel,
    required String altKeyLabel,
    required String actionLabel,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF22222A) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                keyLabel,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              actionLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
