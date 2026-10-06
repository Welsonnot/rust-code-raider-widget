import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DigitSlots extends StatelessWidget {
  final String input;
  final bool isError;
  final String errorMessage;
  final bool isDark;
  final bool isKeyboardReadingEnabled;
  final VoidCallback onToggleKeyboardReading;

  const DigitSlots({
    super.key,
    required this.input,
    required this.isError,
    required this.errorMessage,
    required this.isDark,
    required this.isKeyboardReadingEnabled,
    required this.onToggleKeyboardReading,
  });

  @override
  Widget build(BuildContext context) {
    final slotBg = isDark ? AppColors.darkSlotBg : AppColors.lightSlotBg;
    final slotBorder = isDark ? AppColors.darkSlotBorder : AppColors.lightSlotBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear Text Toggle Button for Keyboard Reading
        GestureDetector(
          onTap: onToggleKeyboardReading,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isKeyboardReadingEnabled
                  ? (isDark ? const Color(0xFF132A1C) : const Color(0xFFE8F8EE))
                  : (isDark ? const Color(0xFF261D18) : const Color(0xFFFDF0E9)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isKeyboardReadingEnabled
                    ? AppColors.successGreen
                    : const Color(0xFFFF9500),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isKeyboardReadingEnabled
                      ? Icons.keyboard_alt_rounded
                      : Icons.keyboard_hide_rounded,
                  size: 13,
                  color: isKeyboardReadingEnabled
                      ? AppColors.successGreen
                      : const Color(0xFFFF9500),
                ),
                const SizedBox(width: 6),
                Text(
                  isKeyboardReadingEnabled
                      ? 'READING NUMBERS: ENABLED'
                      : 'READING NUMBERS: DISABLED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isKeyboardReadingEnabled
                        ? AppColors.successGreen
                        : const Color(0xFFFF9500),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isKeyboardReadingEnabled
                        ? AppColors.successGreen.withValues(alpha: 0.2)
                        : const Color(0xFFFF9500).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isKeyboardReadingEnabled ? 'DISABLE' : 'ENABLE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isKeyboardReadingEnabled
                          ? AppColors.successGreen
                          : const Color(0xFFFF9500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4 Input Digit Slots
        Opacity(
          opacity: isKeyboardReadingEnabled ? 1.0 : 0.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final bool hasDigit = index < input.length;
              final String digit = hasDigit ? input[index] : '';
              final bool isCurrentFocus = index == input.length && !isError && isKeyboardReadingEnabled;

              Color borderColor = slotBorder;
              Color bgColor = slotBg;

              if (isError) {
                borderColor = AppColors.errorRed;
                bgColor = AppColors.errorRedBg;
              } else if (isCurrentFocus) {
                borderColor = isDark ? Colors.white70 : Colors.black87;
              } else if (hasDigit) {
                borderColor = isDark ? Colors.white38 : Colors.black26;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 44,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: isError || isCurrentFocus ? 1.8 : 1.2,
                  ),
                  boxShadow: isError
                      ? [
                          BoxShadow(
                            color: AppColors.errorRed.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      ),
                      child: child,
                    );
                  },
                  child: hasDigit
                      ? Text(
                          digit,
                          key: ValueKey('digit_${index}_$digit'),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: isError ? AppColors.errorRed : primaryTextColor,
                          ),
                        )
                      : (isCurrentFocus
                          ? Container(
                              width: 8,
                              height: 2,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white54 : Colors.black38,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        // Status banner / Error message / Hint
        SizedBox(
          height: 22,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isError
                ? Row(
                    key: const ValueKey('error_banner'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        errorMessage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  )
                : (!isKeyboardReadingEnabled
                    ? Text(
                        'KEYBOARD READING IS DISABLED',
                        key: const ValueKey('disabled_banner'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFFFF9500),
                        ),
                      )
                    : Text(
                        'TYPE 4 DIGITS ON KEYBOARD',
                        key: const ValueKey('hint_banner'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: mutedTextColor,
                        ),
                      )),
          ),
        ),
      ],
    );
  }
}
