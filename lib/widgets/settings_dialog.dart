// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:io' show Platform, Process;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:google_fonts/google_fonts.dart';
import '../models/keybind_config.dart';
import '../models/session_manager.dart';

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

  static Future<void> show(
    BuildContext context, {
    required SessionManager sessionManager,
    required bool isDark,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(
        sessionManager: sessionManager,
        isDark: isDark,
      ),
    );
  }

  static Future<void> showPrivacyModal(BuildContext context, {required bool isDark}) {
    final bg = isDark ? const Color(0xFF141418) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF7A7A80) : const Color(0xFF8E8E93);
    final border = isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA);

    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: bg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 1),
        ),
        child: Container(
          width: 300,
          constraints: const BoxConstraints(maxHeight: 196),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF007AFF)),
                      const SizedBox(width: 6),
                      Text(
                        'Privacy Notice',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close_rounded, size: 18, color: textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      privacyNoticeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Understood', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        final isDark = sessionManager.isDark;
        final bg = isDark ? const Color(0xFF141418) : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
        final textMuted = isDark ? const Color(0xFF7A7A80) : const Color(0xFF8E8E93);
        final border = isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA);
        final windowHeight = MediaQuery.of(context).size.height;
        final windowWidth = MediaQuery.of(context).size.width;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final isHotkeysOn = sessionManager.isHotkeysEnabled;

        return Dialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border, width: 1),
          ),
          child: Container(
            width: (windowWidth - 16).clamp(296.0, 440.0),
            constraints: BoxConstraints(
              maxHeight: (windowHeight - 16).clamp(196.0, 560.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Title + Close)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'assets/images/app_logo_small.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Settings',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close_rounded, size: 18, color: textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Appearance / Theme Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                        size: 13,
                                        color: textPrimary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Appearance',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    isDark ? 'Dark Mode' : 'Light Mode',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF007AFF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildThemeButton(
                                      'Dark',
                                      Icons.dark_mode_rounded,
                                      true,
                                      isDark,
                                      textPrimary,
                                      setModalState,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildThemeButton(
                                      'Light',
                                      Icons.light_mode_rounded,
                                      false,
                                      isDark,
                                      textPrimary,
                                      setModalState,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Sound Effects / Audio Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        sessionManager.isSoundMuted
                                            ? Icons.volume_off_rounded
                                            : Icons.volume_up_rounded,
                                        size: 13,
                                        color: textPrimary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Sound Effects',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: CupertinoSwitch(
                                      value: !sessionManager.isSoundMuted,
                                      activeTrackColor: const Color(0xFF34C759),
                                      onChanged: (val) {
                                        sessionManager.setIsSoundMuted(!val);
                                        setModalState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sessionManager.isSoundMuted
                                    ? 'Sound muted (silent mode)'
                                    : 'Next/Back audio & Solved chime active',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 1. Widget Size / Scale Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.aspect_ratio_rounded,
                                        size: 13,
                                        color: textPrimary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Widget Size',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(sessionManager.hudScale * 100).round()}% (${(320 * sessionManager.hudScale).round()}×${(220 * sessionManager.hudScale).round()})',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final newScale = (sessionManager.hudScale - 0.25).clamp(1.0, 2.5);
                                      sessionManager.setHudScale(newScale);
                                      setModalState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8),
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Icon(Icons.remove_rounded, size: 12, color: textPrimary),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  _buildScaleButton(
                                    '100%',
                                    1.0,
                                    sessionManager.hudScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildScaleButton(
                                    '125%',
                                    1.25,
                                    sessionManager.hudScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildScaleButton(
                                    '150%',
                                    1.5,
                                    sessionManager.hudScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildScaleButton(
                                    '175%',
                                    1.75,
                                    sessionManager.hudScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildScaleButton(
                                    '200%',
                                    2.0,
                                    sessionManager.hudScale,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      final newScale = (sessionManager.hudScale + 0.25).clamp(1.0, 2.5);
                                      sessionManager.setHudScale(newScale);
                                      setModalState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8),
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Icon(Icons.add_rounded, size: 12, color: textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 2. Custom Keybinds Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_outlined,
                                        size: 13,
                                        color: textPrimary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Custom Keybinds',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      sessionManager.resetKeybindsToDefault();
                                      setModalState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text(
                                        'Reset',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF007AFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildKeybindRow(
                                title: 'Next Code',
                                keyLabel: sessionManager.keyNext,
                                onSelected: (k) {
                                  sessionManager.setKeyNext(k);
                                  setModalState(() {});
                                },
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                              _buildKeybindRow(
                                title: 'Previous Code',
                                keyLabel: sessionManager.keyPrev,
                                onSelected: (k) {
                                  sessionManager.setKeyPrev(k);
                                  setModalState(() {});
                                },
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                              _buildKeybindRow(
                                title: 'Mark Solved',
                                keyLabel: sessionManager.keySolved,
                                onSelected: (k) {
                                  sessionManager.setKeySolved(k);
                                  setModalState(() {});
                                },
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ],
                          ),
                        ),

                        // 3. Screen Placement Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.dashboard_customize_outlined,
                                    size: 13,
                                    color: textPrimary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Screen Placement',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Top Row: Top Left, Top Middle, Top Right
                              Row(
                                children: [
                                  _buildPlacementButton(
                                    'Top Left',
                                    'topLeft',
                                    sessionManager.hudPosition,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildPlacementButton(
                                    'Top Middle',
                                    'topCenter',
                                    sessionManager.hudPosition,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildPlacementButton(
                                    'Top Right',
                                    'topRight',
                                    sessionManager.hudPosition,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Bottom Row: Bottom Left, Bottom Right
                              Row(
                                children: [
                                  _buildPlacementButton(
                                    'Bottom Left',
                                    'bottomLeft',
                                    sessionManager.hudPosition,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildPlacementButton(
                                    'Bottom Right',
                                    'bottomRight',
                                    sessionManager.hudPosition,
                                    isDark,
                                    textPrimary,
                                    setModalState,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 4. Global Hotkeys Toggle Switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Global Hotkeys',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          '${sessionManager.keyNext} (Next) / ${sessionManager.keyPrev} (Prev) / ${sessionManager.keySolved} (Solve)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w400,
                                            color: textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: CupertinoSwitch(
                                      value: isHotkeysOn,
                                      activeTrackColor: const Color(0xFF34C759),
                                      onChanged: (val) {
                                        sessionManager.setHotkeysEnabled(val);
                                        setModalState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isHotkeysOn
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFFF9500),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isHotkeysOn ? 'Hotkeys Active' : 'Hotkeys Inactive',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isHotkeysOn
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFFF9500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 5. Credits (Made by welsonnot)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1D1D24) : const Color(0xFFF2F2F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    size: 13,
                                    color: const Color(0xFF007AFF),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Credits',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF).withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'PolyForm 1.0.0',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF007AFF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              _buildLinkTile(
                                icon: Icons.code_rounded,
                                label: 'github.com/Welsonnot',
                                url: 'https://github.com/Welsonnot',
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                              const SizedBox(height: 5),
                              _buildLinkTile(
                                icon: Icons.language_rounded,
                                label: 'minristudio.com',
                                url: 'https://minristudio.com',
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ],
                          ),
                        ),

                        // 6. Privacy Notice Banner
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF007AFF)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Privacy Notice',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF007AFF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                privacyNoticeText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                  color: textPrimary.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
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

  Widget _buildThemeButton(
    String label,
    IconData icon,
    bool buttonIsDark,
    bool currentIsDark,
    Color textPrimary,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = buttonIsDark == currentIsDark;
    final activeBg = const Color(0xFF007AFF).withValues(alpha: currentIsDark ? 0.28 : 0.16);
    const activeBorder = Color(0xFF007AFF);
    final inactiveBg = currentIsDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8);
    final inactiveBorder = currentIsDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8);

    return InkWell(
      onTap: () {
        sessionManager.setIsDark(buttonIsDark);
        setModalState(() {});
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeBorder : inactiveBorder,
            width: isSelected ? 1.0 : 0.6,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? const Color(0xFF007AFF) : (currentIsDark ? const Color(0xFF8E8E93) : const Color(0xFF636366)),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? textPrimary : (currentIsDark ? const Color(0xFF8E8E93) : const Color(0xFF636366)),
              ),
            ),
          ],
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
    final activeBg = const Color(0xFF007AFF).withValues(alpha: isDark ? 0.28 : 0.16);
    const activeBorder = Color(0xFF007AFF);
    final inactiveBg = isDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8);
    final inactiveBorder = isDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8);

    return Expanded(
      child: InkWell(
        onTap: () {
          sessionManager.setHudScale(scaleValue);
          setModalState(() {});
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? activeBorder : inactiveBorder,
              width: isSelected ? 1.0 : 0.6,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF007AFF) : textPrimary,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Select key for $title',
            onSelected: onSelected,
            initialValue: keyLabel,
            color: isDark ? const Color(0xFF1E1E26) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isDark ? const Color(0xFF33333F) : const Color(0xFFD1D1D8),
              ),
            ),
            itemBuilder: (ctx) {
              return kAvailableKeybinds.map((option) {
                final isCur = option.label == keyLabel;
                return PopupMenuItem<String>(
                  value: option.label,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option.label,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: isCur ? FontWeight.w700 : FontWeight.w500,
                          color: isCur
                              ? const Color(0xFF007AFF)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isCur)
                        const Icon(Icons.check_rounded, size: 14, color: Color(0xFF007AFF)),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282834) : const Color(0xFFE2E2E8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A3A4A) : const Color(0xFFC8C8D0),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    keyLabel,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 14,
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
    final activeBg = const Color(0xFF007AFF).withValues(alpha: isDark ? 0.28 : 0.16);
    const activeBorder = Color(0xFF007AFF);
    final inactiveBg = isDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8);
    final inactiveBorder = isDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8);

    return Expanded(
      child: InkWell(
        onTap: () {
          sessionManager.setHudPosition(value);
          setModalState(() {});
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? activeBorder : inactiveBorder,
              width: isSelected ? 1.0 : 0.6,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF007AFF) : textPrimary,
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
    required IconData icon,
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.5, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262630) : const Color(0xFFE4E4E8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF343440) : const Color(0xFFD4D4D8),
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF007AFF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 10,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
