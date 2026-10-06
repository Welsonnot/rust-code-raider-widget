import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CardHeader extends StatelessWidget {
  final bool isDark;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onToggleTheme;
  final bool isCompleted;

  const CardHeader({
    super.key,
    required this.isDark,
    required this.currentStep,
    required this.totalSteps,
    required this.onToggleTheme,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final pillBg = isDark ? AppColors.darkPillBg : AppColors.lightPillBg;
    final pillActive = isDark ? AppColors.darkPillActive : AppColors.lightPillActive;
    final pillActiveText = isDark ? AppColors.darkPillActiveText : AppColors.lightPillActiveText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Title + Step
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Rust Raid',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.successGreen : (isDark ? const Color(0xFF22222A) : const Color(0xFFE8E8EE))),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCompleted ? 'CLEARED' : 'CODE ${currentStep + 1}/$totalSteps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isCompleted ? Colors.white : mutedTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  isCompleted ? 'Status ' : 'Active ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
                ),
                Text(
                  isCompleted ? '✓' : (isDark ? '🌙' : '☀️'),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        // Right Toggle Pill (mimics "12h | 24h" in reference UI)
        GestureDetector(
          onTap: onToggleTheme,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPillOption(
                  label: '🌙',
                  isActive: isDark,
                  activeColor: pillActive,
                  activeTextColor: pillActiveText,
                  inactiveTextColor: mutedTextColor,
                ),
                _buildPillOption(
                  label: '☀️',
                  isActive: !isDark,
                  activeColor: pillActive,
                  activeTextColor: pillActiveText,
                  inactiveTextColor: mutedTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillOption({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color activeTextColor,
    required Color inactiveTextColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? activeTextColor : inactiveTextColor,
        ),
      ),
    );
  }
}
