// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/keybind_config.dart';
import '../models/session_manager.dart';
import '../theme/app_theme.dart';

const String privacyNoticeText =
    'This app only listens for designated hotkeys (F7/F8) to change overlay numbers. It does not record keystrokes, does not store data, and has no network connectivity.';

class SettingsDialog extends StatelessWidget {
  final SessionManager sessionManager;
  final bool isDark;

  const SettingsDialog({
    super.key,
    required this.sessionManager,
    required this.isDark,
  });

  static String _resolvePrivacyNotice() {
    if (!verifyKeydriverIntegrity()) {
      return '';
    }
    return privacyNoticeText;
  }

  static void show(
    BuildContext context, {
    required SessionManager sessionManager,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          SettingsDialog(sessionManager: sessionManager, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = sessionManager.isDark;
            final bg = AppTheme.bg(isDark);
            final textPrimary = AppTheme.textPrimary(isDark);
            final textSecondary = AppTheme.textSecondary(isDark);
            final textMuted = AppTheme.textMuted(isDark);
            final controlBg = AppTheme.controlBg(isDark);

            final currentScale = sessionManager.hudScale;
            final currentOpacity = sessionManager.bgOpacity;
            final currentPos = sessionManager.hudPosition;
            final resolvedPrivacyNotice = _resolvePrivacyNotice();

            return Dialog(
              backgroundColor: bg,
              insetPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: SizedBox(
                width: 320,
                height: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editorial Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Settings',
                            style: AppTheme.sans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: textMuted,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Preferences Body (No full-bleed Dividers)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Appearance (12h | 24h Segmented Capsule Track)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionLabel('Appearance', textPrimary),
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    color: controlBg,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildThemeButton(
                                        'Light',
                                        false,
                                        isDark,
                                        textPrimary,
                                        setModalState,
                                      ),
                                      _buildThemeButton(
                                        'Dark',
                                        true,
                                        isDark,
                                        textPrimary,
                                        setModalState,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 1b. Background Opacity
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionLabel(
                                  'Background Opacity',
                                  textPrimary,
                                ),
                                Text(
                                  '${(currentOpacity * 100).round()}%',
                                  style: AppTheme.mono(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 20,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor: AppTheme.activePillBg(
                                    isDark,
                                  ),
                                  inactiveTrackColor: controlBg,
                                  thumbColor: AppTheme.activePillBg(isDark),
                                  overlayShape: SliderComponentShape.noOverlay,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                ),
                                child: Slider(
                                  value: currentOpacity,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) {
                                    sessionManager.setBgOpacity(val);
                                    setModalState(() {});
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 2. Sound Effects
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sound Effects',
                                        style: AppTheme.sans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        sessionManager.isSoundMuted
                                            ? 'Muted'
                                            : 'Click on hotkey press',
                                        style: AppTheme.sans(
                                          fontSize: 10,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStadiumToggle(
                                  value: !sessionManager.isSoundMuted,
                                  isDark: isDark,
                                  onChanged: (enabled) {
                                    sessionManager.setIsSoundMuted(!enabled);
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 3. Widget Size (12h | 24h Segmented Capsule Track)
                            _buildSectionLabel('Widget Size', textPrimary),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: controlBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  _buildScaleButton(
                                    '100%',
                                    1.0,
                                    currentScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  _buildScaleButton(
                                    '125%',
                                    1.25,
                                    currentScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  _buildScaleButton(
                                    '150%',
                                    1.5,
                                    currentScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 4. Custom Keybinds
                            _buildSectionLabel('Custom Keybinds', textPrimary),
                            const SizedBox(height: 5),
                            _buildKeybindRow(
                              title: 'Next Code',
                              keyLabel: sessionManager.keyNext,
                              onSelected: (val) {
                                sessionManager.setKeyNext(val);
                                setModalState(() {});
                              },
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                            ),
                            _buildKeybindRow(
                              title: 'Previous Code',
                              keyLabel: sessionManager.keyPrev,
                              onSelected: (val) {
                                sessionManager.setKeyPrev(val);
                                setModalState(() {});
                              },
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                            ),
                            _buildKeybindRow(
                              title: 'Mark Solved',
                              keyLabel: sessionManager.keySolved,
                              onSelected: (val) {
                                sessionManager.setKeySolved(val);
                                setModalState(() {});
                              },
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                            ),

                            const SizedBox(height: 12),

                            // 5. Screen Placement
                            _buildSectionLabel('Screen Placement', textPrimary),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: controlBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  _buildPlacementButton(
                                    'Top Left',
                                    'topLeft',
                                    currentPos,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  _buildPlacementButton(
                                    'Top Middle',
                                    'topCenter',
                                    currentPos,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  _buildPlacementButton(
                                    'Top Right',
                                    'topRight',
                                    currentPos,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: controlBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  _buildPlacementButton(
                                    'Bottom Left',
                                    'bottomLeft',
                                    currentPos,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  _buildPlacementButton(
                                    'Bottom Right',
                                    'bottomRight',
                                    currentPos,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 6. Global Hotkeys
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Global Hotkeys',
                                        style: AppTheme.sans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        sessionManager.isHotkeysEnabled
                                            ? 'Listening (${sessionManager.keyPrev} / ${sessionManager.keyNext} / ${sessionManager.keySolved})'
                                            : 'Paused (${sessionManager.keyPrev} / ${sessionManager.keyNext} / ${sessionManager.keySolved} free)',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: AppTheme.sans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildStadiumToggle(
                                  value: sessionManager.isHotkeysEnabled,
                                  isDark: isDark,
                                  onChanged: (val) {
                                    sessionManager.setHotkeysEnabled(val);
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // 7. Credits & Links
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionLabel('Credits', textPrimary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'PolyForm Noncommercial 1.0.0',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: AppTheme.sans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w400,
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLinkTile(
                                    label: 'github.com/Welsonnot',
                                    url: 'https://github.com/Welsonnot',
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildLinkTile(
                                    label: 'minristudio.com',
                                    url: 'https://minristudio.com',
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 8. Privacy Notice
                            Text(
                              'Privacy Notice',
                              style: AppTheme.sans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              resolvedPrivacyNotice,
                              style: AppTheme.sans(
                                fontSize: 10,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String title, Color textPrimary) {
    return Text(
      title,
      style: AppTheme.sans(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
    );
  }

  /// Stadium capsule toggle matching the reference "12h | 24h" monochrome switch
  Widget _buildStadiumToggle({
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    final trackColor = value
        ? AppTheme.activePillBg(isDark)
        : AppTheme.controlBg(isDark);
    final thumbColor = value
        ? AppTheme.activePillText(isDark)
        : AppTheme.textMuted(isDark);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 34,
        height: 20,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: thumbColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    String label,
    bool buttonIsDark,
    bool currentIsDark,
    Color textPrimary,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = buttonIsDark == currentIsDark;
    final textMuted = AppTheme.textMuted(currentIsDark);

    return InkWell(
      onTap: () {
        sessionManager.setIsDark(buttonIsDark);
        setModalState(() {});
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.activePillBg(currentIsDark)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTheme.sans(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected
                ? AppTheme.activePillText(currentIsDark)
                : textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildScaleButton(
    String label,
    double scaleValue,
    double currentScale,
    bool isDark,
    Color textPrimary,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = (currentScale - scaleValue).abs() < 0.05;
    final textMuted = AppTheme.textMuted(isDark);

    return Expanded(
      child: InkWell(
        onTap: () {
          sessionManager.setHudScale(scaleValue);
          setModalState(() {});
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.activePillBg(isDark)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.mono(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppTheme.activePillText(isDark) : textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeybindRow({
    required String title,
    required String keyLabel,
    required ValueChanged<String> onSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final border = AppTheme.border(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.sans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Select key for $title',
            onSelected: onSelected,
            initialValue: keyLabel,
            color: AppTheme.surface(isDark),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: border, width: 1),
            ),
            itemBuilder: (ctx) {
              return kAvailableKeybinds.map((option) {
                final isCur = option.label == keyLabel;
                return PopupMenuItem<String>(
                  value: option.label,
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option.label,
                        style: AppTheme.sans(
                          fontSize: 11,
                          fontWeight: isCur ? FontWeight.w600 : FontWeight.w400,
                          color: isCur ? textPrimary : textMuted,
                        ),
                      ),
                      if (isCur)
                        Icon(Icons.check_rounded, size: 13, color: textPrimary),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppTheme.controlBg(isDark),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    keyLabel,
                    style: AppTheme.sans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 13,
                    color: textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementButton(
    String label,
    String value,
    String currentValue,
    bool isDark,
    Color textPrimary,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = value == currentValue;
    final textMuted = AppTheme.textMuted(isDark);

    return Expanded(
      child: InkWell(
        onTap: () {
          sessionManager.setHudPosition(value);
          setModalState(() {});
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.activePillBg(isDark)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.sans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppTheme.activePillText(isDark) : textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) {
    try {
      if (Platform.isWindows) {
        Process.run('cmd', ['/c', 'start', '', url]);
      } else if (Platform.isMacOS) {
        Process.run('open', [url]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [url]);
      }
    } catch (_) {
      Clipboard.setData(ClipboardData(text: url));
    }
  }

  Widget _buildLinkTile({
    required String label,
    required String url,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.controlBg(isDark),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ),
              Icon(Icons.arrow_outward_rounded, size: 11, color: textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
