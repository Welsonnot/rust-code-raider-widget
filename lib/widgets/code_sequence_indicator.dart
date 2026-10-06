import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CodeSequenceIndicator extends StatelessWidget {
  final List<String> codes;
  final int currentIndex;
  final bool isCompleted;
  final bool isDark;

  const CodeSequenceIndicator({
    super.key,
    required this.codes,
    required this.currentIndex,
    required this.isCompleted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(codes.length, (index) {
        final bool isCurrent = !isCompleted && index == currentIndex;
        final bool isDone = isCompleted || index < currentIndex;
        final String code = codes[index];

        Color bgColor;
        Color textColor;
        Color borderColor;

        if (isDone) {
          bgColor = isDark ? const Color(0xFF132A1C) : const Color(0xFFE8F8EE);
          borderColor = AppColors.successGreen.withValues(alpha: 0.6);
          textColor = AppColors.successGreen;
        } else if (isCurrent) {
          bgColor = isDark ? Colors.white : Colors.black;
          borderColor = isDark ? Colors.white : Colors.black;
          textColor = isDark ? Colors.black : Colors.white;
        } else {
          bgColor = isDark ? const Color(0xFF191920) : const Color(0xFFEEEEF2);
          borderColor = isDark ? const Color(0xFF282832) : const Color(0xFFE0E0E6);
          textColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isCurrent ? 1.5 : 1.0,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDone) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 11,
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.5,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
