import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomDock extends StatelessWidget {
  final bool isDark;
  final bool isAlwaysOnTop;
  final bool isSoundEnabled;
  final bool isKeyboardReadingEnabled;
  final VoidCallback onReset;
  final VoidCallback onToggleAlwaysOnTop;
  final VoidCallback onToggleSound;
  final VoidCallback onToggleKeyboardReading;

  const BottomDock({
    super.key,
    required this.isDark,
    required this.isAlwaysOnTop,
    required this.isSoundEnabled,
    required this.isKeyboardReadingEnabled,
    required this.onReset,
    required this.onToggleAlwaysOnTop,
    required this.onToggleSound,
    required this.onToggleKeyboardReading,
  });

  @override
  Widget build(BuildContext context) {
    final dockBg = isDark ? const Color(0xFF19191E) : const Color(0xFFEBEBF0);
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reset Button
          _buildDockButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Restart Codes (R / Esc)',
            onTap: onReset,
            isDark: isDark,
            iconColor: iconColor,
          ),
          const SizedBox(width: 8),

          // Center Button: Keyboard Reading Toggle
          Tooltip(
            message: isKeyboardReadingEnabled
                ? 'Keyboard Reading: ENABLED (Tap to Disable)'
                : 'Keyboard Reading: DISABLED (Tap to Enable)',
            child: GestureDetector(
              onTap: onToggleKeyboardReading,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isKeyboardReadingEnabled
                      ? (isDark ? Colors.white : Colors.black)
                      : const Color(0xFFE65100),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isKeyboardReadingEnabled
                          ? Colors.black.withValues(alpha: 0.2)
                          : const Color(0xFFE65100).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isKeyboardReadingEnabled
                      ? Icons.dialpad_rounded
                      : Icons.keyboard_hide_rounded,
                  size: 20,
                  color: isKeyboardReadingEnabled
                      ? (isDark ? Colors.black : Colors.white)
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Sound Toggle Button
          _buildDockButton(
            icon: isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            tooltip: isSoundEnabled ? 'Mute Clicks' : 'Enable Clicks',
            onTap: onToggleSound,
            isDark: isDark,
            iconColor: isSoundEnabled ? iconColor : iconColor.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 6),

          // Pin / Always On Top Button
          _buildDockButton(
            icon: isAlwaysOnTop ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            tooltip: isAlwaysOnTop ? 'Unpin Window' : 'Always On Top (Overlay)',
            onTap: onToggleAlwaysOnTop,
            isDark: isDark,
            iconColor: isAlwaysOnTop ? AppColors.sunYellow : iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    required Color iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 19,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
