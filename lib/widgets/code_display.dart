import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CodeDisplay extends StatelessWidget {
  final String targetCode;
  final bool isDark;
  final bool isCompleted;

  const CodeDisplay({
    super.key,
    required this.targetCode,
    required this.isDark,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtle category label like "Day ☀️" or "Target Code"
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            isCompleted ? 'STATUS' : 'TARGET PIN',
            key: ValueKey('lbl_${isCompleted ? "done" : targetCode}'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: mutedTextColor,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Giant high-contrast number display
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            final inAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.25),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: inAnimation,
                child: child,
              ),
            );
          },
          child: isCompleted
              ? _buildCompletedText()
              : _buildDigitsText(primaryTextColor),
        ),
      ],
    );
  }

  Widget _buildDigitsText(Color color) {
    return Text(
      targetCode,
      key: ValueKey(targetCode),
      style: GoogleFonts.jetBrainsMono(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        letterSpacing: 4.0,
        height: 1.05,
        color: color,
      ),
    );
  }

  Widget _buildCompletedText() {
    return Column(
      key: const ValueKey('all_codes_tried_title'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Text(
          'ALL CODES TRIED',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            height: 1.1,
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }
}
