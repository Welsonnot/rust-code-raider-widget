// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'models/keybind_config.dart';
import 'models/session_manager.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'widgets/base_dropdown.dart';
import 'widgets/history_dialog.dart';
import 'widgets/settings_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verify scancode translation table integrity at startup
  verifyKeydriverIntegrity(verbose: true);

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();

      double initialScale = 1.0;
      try {
        final file = File(SessionManager.settingsFileName);
        if (file.existsSync()) {
          final data =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          if (data.containsKey('hudScale')) {
            initialScale = ((data['hudScale'] as num?)?.toDouble() ?? 1.0)
                .clamp(1.0, 2.5);
          }
        }
      } catch (_) {}

      final windowOptions = WindowOptions(
        size: Size(320 * initialScale, 220 * initialScale),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        alwaysOnTop: true,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setAlwaysOnTop(true);
      });
    } catch (e) {
      debugPrint('Desktop window initialization skipped or failed: $e');
    }
  }

  runApp(const MinimalRaidApp());
}

class MinimalRaidApp extends StatelessWidget {
  const MinimalRaidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust Code Raider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const RaidCounterHud(),
    );
  }
}

class RaidCounterHud extends StatefulWidget {
  const RaidCounterHud({super.key});

  @override
  State<RaidCounterHud> createState() => _RaidCounterHudState();
}

class _RaidCounterHudState extends State<RaidCounterHud> with WindowListener {
  late final SessionManager _sessionManager;
  HotKey? _nextHotKey;
  HotKey? _prevHotKey;
  HotKey? _solvedHotKey;
  bool _registeredHotkeysActive = false;

  String _registeredKeyNext = '';
  String _registeredKeyBack = '';
  String _registeredKeySolved = '';

  double _appliedScale = 1.0;
  String _appliedPosition = '';

  // Dynamic feedback state
  int _slideDirection = 1; // 1 = forward (Next), -1 = backward (Back)
  String? _activeActionPulse; // 'back', 'next', or 'solved'
  Timer? _pulseResetTimer;
  Timer? _topmostReinforceTimer;

  bool get _isDesktop =>
      !kIsWeb &&
      !Platform.environment.containsKey('FLUTTER_TEST') &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    _sessionManager = SessionManager();
    _sessionManager.addListener(_onSessionManagerChanged);

    if (_isDesktop) {
      windowManager.addListener(this);
      _topmostReinforceTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _reinforceAlwaysOnTop();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _syncWindowBounds(forcePosition: true);
        await _syncHotKeys();
      });
    }
  }

  void _reinforceAlwaysOnTop() {
    if (_isDesktop && _sessionManager.isHotkeysEnabled) {
      windowManager.setAlwaysOnTop(true);
    }
  }

  @override
  void onWindowFocus() {
    _sessionManager.loadCodes();
    _reinforceAlwaysOnTop();
  }

  @override
  void onWindowBlur() {
    _reinforceAlwaysOnTop();
  }

  void _triggerActionPulse(String action) {
    _pulseResetTimer?.cancel();
    if (mounted) {
      setState(() {
        _activeActionPulse = action;
      });
    }
    _pulseResetTimer = Timer(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() {
          _activeActionPulse = null;
        });
      }
    });
  }

  void _handleNextAction() {
    _slideDirection = 1;
    _triggerActionPulse('next');
    AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
    _sessionManager.nextCode();
  }

  void _handleBackAction() {
    _slideDirection = -1;
    _triggerActionPulse('back');
    AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
    _sessionManager.previousCode();
  }

  void _handleSolvedAction() {
    _triggerActionPulse('solved');
    final willBeSolved = !_sessionManager.activeSession.isSolved;
    if (willBeSolved) {
      AudioService.playCodeRight(isMuted: _sessionManager.isSoundMuted);
    } else {
      AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
    }
    _sessionManager.toggleSolved();
  }

  void _onSessionManagerChanged() {
    if (_isDesktop) {
      final keybindsChanged =
          _registeredKeyNext != _sessionManager.keyNext ||
          _registeredKeyBack != _sessionManager.keyPrev ||
          _registeredKeySolved != _sessionManager.keySolved;

      if (_registeredHotkeysActive != _sessionManager.isHotkeysEnabled ||
          keybindsChanged) {
        _syncHotKeys();
      }

      final scaleChanged =
          (_appliedScale - _sessionManager.hudScale).abs() > 0.01;
      final posChanged = _appliedPosition != _sessionManager.hudPosition;
      if (scaleChanged || posChanged) {
        _syncWindowBounds(forcePosition: posChanged);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncWindowBounds({bool forcePosition = false}) async {
    if (!_isDesktop) return;
    try {
      final scale = _sessionManager.hudScale;
      final pos = _sessionManager.hudPosition;

      final width = (320 * scale).roundToDouble();
      final height = (220 * scale).roundToDouble();

      _appliedScale = scale;
      _appliedPosition = pos;

      await windowManager.ensureInitialized();
      await windowManager.setResizable(true);
      await windowManager.setAspectRatio(320 / 220);
      await windowManager.setMinimumSize(const Size(320, 220));
      await windowManager.setSize(Size(width, height));
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setBackgroundColor(Colors.transparent);

      if (forcePosition) {
        Alignment alignment;
        switch (pos) {
          case 'topLeft':
            alignment = Alignment.topLeft;
            break;
          case 'topCenter':
            alignment = Alignment.topCenter;
            break;
          case 'topRight':
            alignment = Alignment.topRight;
            break;
          case 'bottomLeft':
            alignment = Alignment.bottomLeft;
            break;
          case 'bottomRight':
            alignment = Alignment.bottomRight;
            break;
          default:
            alignment = Alignment.topRight;
            break;
        }
        await windowManager.setAlignment(alignment);
      }

      await windowManager.show();
      await windowManager.focus();
      if (_sessionManager.isHotkeysEnabled) {
        await windowManager.setAlwaysOnTop(true);
      }
    } catch (e) {
      debugPrint('Failed to sync window bounds: $e');
    }
  }

  Future<void> _syncHotKeys() async {
    if (!_isDesktop) return;
    try {
      await hotKeyManager.unregisterAll();
      _registeredHotkeysActive = _sessionManager.isHotkeysEnabled;
      _registeredKeyNext = _sessionManager.keyNext;
      _registeredKeyBack = _sessionManager.keyPrev;
      _registeredKeySolved = _sessionManager.keySolved;

      if (!_registeredHotkeysActive) {
        try {
          await windowManager.setAlwaysOnTop(false);
        } catch (_) {}
        return;
      }

      try {
        await windowManager.setAlwaysOnTop(true);
      } catch (_) {}

      if (!verifyKeydriverIntegrity()) {
        return;
      }

      final nextPhysical = getPhysicalKeyForLabel(
        _registeredKeyNext,
        fallback: PhysicalKeyboardKey.f8,
      );
      final prevPhysical = getPhysicalKeyForLabel(
        _registeredKeyBack,
        fallback: PhysicalKeyboardKey.f7,
      );
      final solvedPhysical = getPhysicalKeyForLabel(
        _registeredKeySolved,
        fallback: PhysicalKeyboardKey.f9,
      );

      _nextHotKey = HotKey(
        key: nextPhysical,
        modifiers: const [],
        scope: HotKeyScope.system,
      );
      _prevHotKey = HotKey(
        key: prevPhysical,
        modifiers: const [],
        scope: HotKeyScope.system,
      );
      _solvedHotKey = HotKey(
        key: solvedPhysical,
        modifiers: const [],
        scope: HotKeyScope.system,
      );

      await hotKeyManager.register(
        _nextHotKey!,
        keyDownHandler: (_) => _handleNextAction(),
      );

      await hotKeyManager.register(
        _prevHotKey!,
        keyDownHandler: (_) => _handleBackAction(),
      );

      await hotKeyManager.register(
        _solvedHotKey!,
        keyDownHandler: (_) => _handleSolvedAction(),
      );

      if (nextPhysical != PhysicalKeyboardKey.numpadAdd &&
          prevPhysical != PhysicalKeyboardKey.numpadAdd &&
          solvedPhysical != PhysicalKeyboardKey.numpadAdd) {
        await hotKeyManager.register(
          HotKey(
            key: PhysicalKeyboardKey.numpadAdd,
            modifiers: const [],
            scope: HotKeyScope.system,
          ),
          keyDownHandler: (_) => _handleNextAction(),
        );
      }

      if (nextPhysical != PhysicalKeyboardKey.numpadSubtract &&
          prevPhysical != PhysicalKeyboardKey.numpadSubtract &&
          solvedPhysical != PhysicalKeyboardKey.numpadSubtract) {
        await hotKeyManager.register(
          HotKey(
            key: PhysicalKeyboardKey.numpadSubtract,
            modifiers: const [],
            scope: HotKeyScope.system,
          ),
          keyDownHandler: (_) => _handleBackAction(),
        );
      }
    } catch (e) {
      debugPrint('Hotkey sync error: $e');
    }
  }

  @override
  void dispose() {
    _pulseResetTimer?.cancel();
    _topmostReinforceTimer?.cancel();
    _sessionManager.removeListener(_onSessionManagerChanged);
    _sessionManager.dispose();
    AudioService.dispose();
    if (_isDesktop) {
      windowManager.removeListener(this);
      hotKeyManager.unregisterAll();
    }
    super.dispose();
  }

  Future<void> _closeApp() async {
    if (_isDesktop) {
      await hotKeyManager.unregisterAll();
      await windowManager.close();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _sessionManager.isDark;
    final active = _sessionManager.activeSession;
    final currentCode = _sessionManager.currentTargetCode.isEmpty
        ? '----'
        : _sessionManager.currentTargetCode;
    final totalCodes = _sessionManager.totalCodes;
    final currentRank = totalCodes == 0 ? 0 : active.currentIndex + 1;
    final isSolved = active.isSolved;
    final hotkeysActive = _sessionManager.isHotkeysEnabled;

    final bg = AppTheme.bg(isDark);
    final bgOpacity = _sessionManager.bgOpacity;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);
    final controlBg = AppTheme.controlBg(isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {
          if (_isDesktop) {
            windowManager.startDragging();
          }
        },
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            alignment: Alignment.center,
            child: SizedBox(
              width: 320,
              height: 220,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                color: bg.withValues(alpha: bgOpacity),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // Top Row: City/Base Title (left) + Status Pill & Circular Icons (right)
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: 'Drag anywhere to move HUD',
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  size: 11,
                                  color: textMuted.withValues(alpha: 0.35),
                                ),
                              ),
                              Flexible(
                                child: BaseDropdown(
                                  sessionManager: _sessionManager,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusIndicator(
                              hotkeysActive: hotkeysActive,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              controlBg: controlBg,
                            ),
                            const SizedBox(width: 4),
                            _buildCircularIconBtn(
                              icon: _sessionManager.isSoundMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              tooltip: _sessionManager.isSoundMuted
                                  ? 'Unmute Sound Effects'
                                  : 'Mute Sound Effects',
                              isActive: _sessionManager.isSoundMuted,
                              isDark: isDark,
                              onTap: () => _sessionManager.toggleSoundMuted(),
                            ),
                            const SizedBox(width: 3),
                            _buildCircularIconBtn(
                              icon: isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              tooltip: isDark
                                  ? 'Switch to Light Mode'
                                  : 'Switch to Dark Mode',
                              isDark: isDark,
                              onTap: () => _sessionManager.setIsDark(!isDark),
                            ),
                            const SizedBox(width: 3),
                            _buildCircularIconBtn(
                              icon: Icons.history_rounded,
                              tooltip:
                                  'Attempt History (${active.history.length})',
                              isDark: isDark,
                              onTap: () => HistoryDialog.show(
                                context,
                                sessionManager: _sessionManager,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 3),
                            _buildCircularIconBtn(
                              icon: Icons.tune_rounded,
                              tooltip: 'Settings',
                              isDark: isDark,
                              onTap: () => SettingsDialog.show(
                                context,
                                sessionManager: _sessionManager,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 3),
                            _buildCircularIconBtn(
                              icon: Icons.close,
                              tooltip: 'Exit',
                              isDark: isDark,
                              onTap: _closeApp,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // =========================================================
                    // Left-Aligned Editorial Readout Block
                    // =========================================================
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 4-Digit Target Code Readout (Instrument Sans w400, left-aligned)
                              RepaintBoundary(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 140),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  layoutBuilder:
                                      (currentChild, previousChildren) {
                                        return Stack(
                                          alignment: Alignment.centerLeft,
                                          children: <Widget>[
                                            ...previousChildren,
                                            if (currentChild != null)
                                              currentChild,
                                          ],
                                        );
                                      },
                                  transitionBuilder: (child, animation) {
                                    final isIncoming =
                                        child.key ==
                                        ValueKey('${currentCode}_$isSolved');
                                    final beginOffset = isIncoming
                                        ? Offset(0.08 * _slideDirection, 0.0)
                                        : Offset(-0.08 * _slideDirection, 0.0);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: beginOffset,
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Row(
                                    key: ValueKey('${currentCode}_$isSolved'),
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        currentCode,
                                        style: AppTheme.mono(
                                          fontSize: 60,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -2.0,
                                          height: 1.0,
                                          color: isSolved
                                              ? AppTheme.statusActive
                                              : textPrimary,
                                        ),
                                      ),
                                      if (isSolved) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.statusActive,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Subtitle positioned directly BELOW the numerals (no yellow dot)
                              Text(
                                isSolved
                                    ? 'Solved at #$currentRank of ${_formatNumber(totalCodes)} • ${active.currentIndex} used'
                                    : '#$currentRank of ${_formatNumber(totalCodes)} • ${active.currentIndex} used',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppTheme.sans(
                                  fontSize: 10.5,
                                  fontWeight: isSolved
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  letterSpacing: -0.15,
                                  color: isSolved
                                      ? AppTheme.statusActive
                                      : textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // =========================================================
                    // Bottom Capsule Control Row (Matches "12h | 24h" & Monochrome Dock)
                    // =========================================================
                    SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCapsuleButton(
                              keyLabel: _sessionManager.keyPrev,
                              actionLabel: 'Back',
                              isDark: isDark,
                              isActuated: _activeActionPulse == 'back',
                              onTap: _handleBackAction,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildCapsuleButton(
                              keyLabel: _sessionManager.keyNext,
                              actionLabel: 'Next',
                              isDark: isDark,
                              isActuated: _activeActionPulse == 'next',
                              onTap: _handleNextAction,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildCapsuleButton(
                              keyLabel: _sessionManager.keySolved,
                              actionLabel: isSolved ? 'Solved ✓' : 'Solved',
                              isDark: isDark,
                              isHighlighted: isSolved,
                              isActuated: _activeActionPulse == 'solved',
                              onTap: _handleSolvedAction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required bool hotkeysActive,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
    required Color controlBg,
  }) {
    final isPaused = !hotkeysActive;
    final pillBg = isPaused ? AppTheme.activePillBg(isDark) : controlBg;
    final pillText = isPaused ? AppTheme.activePillText(isDark) : textMuted;

    return Tooltip(
      message: hotkeysActive
          ? 'Hotkeys Active (click to pause)'
          : 'Hotkeys Paused (click to resume)',
      child: InkWell(
        onTap: () => _sessionManager.toggleHotkeys(),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            hotkeysActive ? 'Active' : 'Paused',
            style: AppTheme.sans(
              fontSize: 10.5,
              fontWeight: isPaused ? FontWeight.w600 : FontWeight.w400,
              color: pillText,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _buildCircularIconBtn({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final bg = isActive
        ? AppTheme.activePillBg(isDark)
        : AppTheme.controlBg(isDark);
    final fg = isActive
        ? AppTheme.activePillText(isDark)
        : AppTheme.textPrimary(isDark);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 12.5, color: fg),
        ),
      ),
    );
  }

  Widget _buildCapsuleButton({
    required String keyLabel,
    required String actionLabel,
    required bool isDark,
    required VoidCallback onTap,
    bool isHighlighted = false,
    bool isActuated = false,
  }) {
    final isInverted = isHighlighted || isActuated;
    final bg = isInverted
        ? AppTheme.activePillBg(isDark)
        : AppTheme.controlBg(isDark);
    final keyColor = isInverted
        ? AppTheme.activePillText(isDark)
        : AppTheme.textPrimary(isDark);
    final labelColor = isInverted
        ? AppTheme.activePillText(isDark)
        : AppTheme.textMuted(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedScale(
          scale: isActuated ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  keyLabel,
                  style: AppTheme.sans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: keyColor,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    actionLabel,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTheme.sans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
