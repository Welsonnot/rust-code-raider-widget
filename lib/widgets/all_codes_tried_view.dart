import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AllCodesTriedView extends StatelessWidget {
  final bool isDark;
  final int totalAttempts;
  final int wrongAttempts;
  final VoidCallback onRestart;

  const AllCodesTriedView({
    super.key,
    required this.isDark,
    required this.totalAttempts,
    required this.wrongAttempts,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final buttonBg = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success Checkmark Badge
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.successGreenBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.successGreen,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 34,
            color: AppColors.successGreen,
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          'ALL CODES TRIED',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          '1234  •  1111  •  0000',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: mutedTextColor,
          ),
        ),
        const SizedBox(height: 14),

        // Statistics Pill Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatPill('Attempts', '$totalAttempts', isDark, mutedTextColor, primaryTextColor),
            const SizedBox(width: 8),
            _buildStatPill('Errors', '$wrongAttempts', isDark, mutedTextColor, AppColors.errorRed),
          ],
        ),
        const SizedBox(height: 16),

        // Restart button
        GestureDetector(
          onTap: onRestart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: buttonBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: buttonBg.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: buttonTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'TRY AGAIN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: buttonTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(
    String label,
    String value,
    bool isDark,
    Color labelColor,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181D) : const Color(0xFFF2F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: labelColor),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
