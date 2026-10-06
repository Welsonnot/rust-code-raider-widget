// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'models/keybind_config.dart';
import 'models/session_manager.dart';
import 'services/audio_service.dart';
import 'widgets/base_dropdown.dart';
import 'widgets/history_dialog.dart';
import 'widgets/settings_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(() {
    verifyKeydriverIntegrity(verbose: true);
    return true;
  }());
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      await windowManager.ensureInitialized();

      double initialScale = 1.0;
      try {
        final file = File(SessionManager.settingsFileName);
        if (file.existsSync()) {
          final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          if (data.containsKey('hudScale')) {
            initialScale = ((data['hudScale'] as num?)?.toDouble() ?? 1.0).clamp(1.0, 2.5);
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
      debugPrint('WindowManager init error: $e');
    }
  }
  runApp(const MinimalRaidApp());
}

class MinimalRaidApp extends StatefulWidget {
  final SessionManager? sessionManager;
  const MinimalRaidApp({super.key, this.sessionManager});

  @override
  State<MinimalRaidApp> createState() => _MinimalRaidAppState();
}

class _MinimalRaidAppState extends State<MinimalRaidApp> {
  late final SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _sessionManager = widget.sessionManager ?? SessionManager();
    _sessionManager.addListener(_onManagerChanged);
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onManagerChanged);
    super.dispose();
  }

  void _onManagerChanged() {
    if (mounted) setState(() {});
  }

  void _toggleTheme() {
    _sessionManager.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _sessionManager.isDark;
    return MaterialApp(
      title: 'Code Raid Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        ),
      ),
      home: RaidCardScreen(
        isDark: isDark,
        onToggleTheme: _toggleTheme,
        sessionManager: _sessionManager,
      ),
    );
  }
}

class RaidCardScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final SessionManager? sessionManager;

  const RaidCardScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.sessionManager,
  });

  @override
  State<RaidCardScreen> createState() => _RaidCardScreenState();
}

class _RaidCardScreenState extends State<RaidCardScreen> with WindowListener {
  late final SessionManager _sessionManager;

  Timer? _topmostReinforceTimer;
  bool _lastHotkeysState = true;
  String _lastHudPosition = '';
  String _lastKeyNext = '';
  String _lastKeyPrev = '';
  String _lastKeySolved = '';
  double _lastHudScale = 1.0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.addListener(this);
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _topmostReinforceTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          _reinforceAlwaysOnTop();
        });
      }
    }
    _sessionManager = widget.sessionManager ?? SessionManager();
    _sessionManager.addListener(_onStateChanged);
    _lastHotkeysState = _sessionManager.isHotkeysEnabled;
    _lastHudPosition = _sessionManager.hudPosition;
    _lastKeyNext = _sessionManager.keyNext;
    _lastKeyPrev = _sessionManager.keyPrev;
    _lastKeySolved = _sessionManager.keySolved;
    _lastHudScale = _sessionManager.hudScale;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupWindowAndHotkeys();
    });
  }

  void _reinforceAlwaysOnTop() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      if (_sessionManager.isHotkeysEnabled) {
        windowManager.setAlwaysOnTop(true);
      }
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

  Future<void> _setupWindowAndHotkeys() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        await windowManager.ensureInitialized();
        await windowManager.setResizable(true);
        await windowManager.setAspectRatio(320 / 220);
        await windowManager.setMinimumSize(const Size(320, 220));
        final scale = _sessionManager.hudScale;
        await windowManager.setSize(Size(320 * scale, 220 * scale));
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
        await windowManager.setBackgroundColor(Colors.transparent);
        await _applyWindowAlignment(_sessionManager.hudPosition);
        await windowManager.show();
        await windowManager.focus();
        if (_sessionManager.isHotkeysEnabled) {
          await windowManager.setAlwaysOnTop(true);
        }
      } catch (e) {
        debugPrint('WindowManager setup error: $e');
      }

      if (_sessionManager.isHotkeysEnabled) {
        await _registerGlobalHotkeys();
      }
    }
  }

  Future<void> _registerGlobalHotkeys() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        await hotKeyManager.unregisterAll();

        final nextKey = getPhysicalKeyForLabel(_sessionManager.keyNext, fallback: PhysicalKeyboardKey.f8);
        final prevKey = getPhysicalKeyForLabel(_sessionManager.keyPrev, fallback: PhysicalKeyboardKey.f7);
        final solvedKey = getPhysicalKeyForLabel(_sessionManager.keySolved, fallback: PhysicalKeyboardKey.f9);

        await hotKeyManager.register(
          HotKey(key: nextKey, modifiers: [], scope: HotKeyScope.system),
          keyDownHandler: (_) => _advanceNext(),
        );

        await hotKeyManager.register(
          HotKey(key: prevKey, modifiers: [], scope: HotKeyScope.system),
          keyDownHandler: (_) => _stepPrev(),
        );

        await hotKeyManager.register(
          HotKey(key: solvedKey, modifiers: [], scope: HotKeyScope.system),
          keyDownHandler: (_) => _markSolved(),
        );

        // Register auxiliary numpad shortcuts if non-conflicting
        if (nextKey != PhysicalKeyboardKey.numpadAdd &&
            prevKey != PhysicalKeyboardKey.numpadAdd &&
            solvedKey != PhysicalKeyboardKey.numpadAdd) {
          await hotKeyManager.register(
            HotKey(key: PhysicalKeyboardKey.numpadAdd, modifiers: [], scope: HotKeyScope.system),
            keyDownHandler: (_) => _advanceNext(),
          );
        }

        if (nextKey != PhysicalKeyboardKey.numpadSubtract &&
            prevKey != PhysicalKeyboardKey.numpadSubtract &&
            solvedKey != PhysicalKeyboardKey.numpadSubtract) {
          await hotKeyManager.register(
            HotKey(key: PhysicalKeyboardKey.numpadSubtract, modifiers: [], scope: HotKeyScope.system),
            keyDownHandler: (_) => _stepPrev(),
          );
        }
      } catch (e) {
        debugPrint('Global hotkey registration error: $e');
      }
    }
  }

  void _onStateChanged() {
    if (mounted) {
      final hotkeysChanged = _lastKeyNext != _sessionManager.keyNext ||
          _lastKeyPrev != _sessionManager.keyPrev ||
          _lastKeySolved != _sessionManager.keySolved ||
          _lastHotkeysState != _sessionManager.isHotkeysEnabled;

      if (hotkeysChanged) {
        _lastHotkeysState = _sessionManager.isHotkeysEnabled;
        _lastKeyNext = _sessionManager.keyNext;
        _lastKeyPrev = _sessionManager.keyPrev;
        _lastKeySolved = _sessionManager.keySolved;
        _updateHotkeyRegistration(_lastHotkeysState);
      }
      if (_lastHudPosition != _sessionManager.hudPosition) {
        _lastHudPosition = _sessionManager.hudPosition;
        _applyWindowAlignment(_lastHudPosition);
      }
      if ((_lastHudScale - _sessionManager.hudScale).abs() > 0.001) {
        _lastHudScale = _sessionManager.hudScale;
        _applyWindowScale(_lastHudScale);
      }
      setState(() {});
    }
  }

  Future<void> _applyWindowScale(double scale) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final targetSize = Size(320 * scale, 220 * scale);
        await windowManager.setSize(targetSize);
        await windowManager.setAspectRatio(320 / 220);
        await _applyWindowAlignment(_sessionManager.hudPosition);
        if (_sessionManager.isHotkeysEnabled) {
          await windowManager.setAlwaysOnTop(true);
        }
      } catch (e) {
        debugPrint('Error applying window scale: $e');
      }
    }
  }

  Future<void> _applyWindowAlignment(String position) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        Alignment alignment;
        switch (position) {
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
        if (_sessionManager.isHotkeysEnabled) {
          await windowManager.setAlwaysOnTop(true);
        }
      } catch (e) {
        debugPrint('Error applying window alignment: $e');
      }
    }
  }

  Future<void> _updateHotkeyRegistration(bool enabled) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      if (enabled) {
        await _registerGlobalHotkeys();
        try {
          await windowManager.setAlwaysOnTop(true);
        } catch (_) {}
      } else {
        try {
          await hotKeyManager.unregisterAll();
        } catch (e) {
          debugPrint('Unregister hotkeys error: $e');
        }
        try {
          await windowManager.setAlwaysOnTop(false);
        } catch (_) {}
      }
    }
  }

  bool _isMovingForward = true;
  String? _activeActuationKey;

  void _triggerActuation(String actionId) {
    if (mounted) {
      setState(() {
        _activeActuationKey = actionId;
      });
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted && _activeActuationKey == actionId) {
          setState(() {
            _activeActuationKey = null;
          });
        }
      });
    }
  }

  void _advanceNext() {
    _triggerActuation('next');
    if (mounted) {
      setState(() {
        _isMovingForward = true;
      });
    }
    _sessionManager.nextCode();
    AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
  }

  void _stepPrev() {
    _triggerActuation('prev');
    if (mounted) {
      setState(() {
        _isMovingForward = false;
      });
    }
    _sessionManager.previousCode();
    AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
  }

  void _markSolved() {
    _triggerActuation('solved');
    _sessionManager.toggleSolved();
    if (_sessionManager.activeSession.isSolved) {
      AudioService.playCodeRight(isMuted: _sessionManager.isSoundMuted);
    } else {
      AudioService.playNextBack(isMuted: _sessionManager.isSoundMuted);
    }
  }

  void _toggleHotkeys() {
    _sessionManager.toggleHotkeys();
    if (!_sessionManager.isSoundMuted) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  void dispose() {
    AudioService.dispose();
    _topmostReinforceTimer?.cancel();
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.removeListener(this);
      try {
        hotKeyManager.unregisterAll();
      } catch (_) {}
    }
    _sessionManager.removeListener(_onStateChanged);
    super.dispose();
  }

  String _formatCount(int number) {
    if (number < 1000) return number.toString();
    final s = number.toString();
    final buffer = StringBuffer();
    final offset = s.length % 3;
    if (offset > 0) {
      buffer.write(s.substring(0, offset));
    }
    for (int i = offset; i < s.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(s.substring(i, i + 3));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isCompleted = _sessionManager.isCompleted;
    final isSolved = _sessionManager.activeSession.isSolved;
    final currentIndex = _sessionManager.currentIndex;
    final totalCodes = _sessionManager.totalCodes;

    final cardBg = isDark ? const Color(0xF2121216) : const Color(0xF7FFFFFF);
    final textPrimary = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);
    final border = isDark ? const Color(0xFF26262E) : const Color(0xFFDCDCDE);
    const successGreen = Color(0xFF34C759);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {
          if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
            windowManager.startDragging();
          }
        },
        onPanEnd: (_) {
          _reinforceAlwaysOnTop();
        },
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 320,
              height: 220,
              child: Container(
                width: 320,
                height: 220,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Session name / Dropdown + Drag grip + Status Pill (Active / Paused) + Audio Mute + Theme + History + Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  'assets/images/app_logo_small.png',
                                  width: 14,
                                  height: 14,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.drag_indicator_rounded,
                                size: 14,
                                color: textMuted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: BaseDropdown(
                                  sessionManager: _sessionManager,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // History Icon
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => HistoryDialog.show(
                                context,
                                sessionManager: _sessionManager,
                                isDark: isDark,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 16,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Status Pill (Active / Paused)
                            GestureDetector(
                              onTap: _toggleHotkeys,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: _sessionManager.isHotkeysEnabled
                                      ? const Color(0x2234C759)
                                      : const Color(0x22FF9500),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _sessionManager.isHotkeysEnabled
                                        ? const Color(0x6634C759)
                                        : const Color(0x66FF9500),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _sessionManager.isHotkeysEnabled
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF9500),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _sessionManager.isHotkeysEnabled ? 'Active' : 'Paused',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.1,
                                        color: _sessionManager.isHotkeysEnabled
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF9500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Audio Mute Toggle Icon
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                _sessionManager.toggleSoundMuted();
                                if (!_sessionManager.isSoundMuted) {
                                  SystemSound.play(SystemSoundType.click);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  _sessionManager.isSoundMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  size: 16,
                                  color: _sessionManager.isSoundMuted
                                      ? const Color(0xFFFF9500)
                                      : textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Theme Toggle Icon (Sun / Moon)
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                _sessionManager.toggleTheme();
                                SystemSound.play(SystemSoundType.click);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  size: 16,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Settings Icon
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => SettingsDialog.show(
                                context,
                                sessionManager: _sessionManager,
                                isDark: isDark,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Row 2: Dynamic Large High-Contrast Monospace Code Display (52px) with Ticker Animation
                    RepaintBoundary(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            final inOffset = Tween<Offset>(
                              begin: Offset(0.0, _isMovingForward ? 0.35 : -0.35),
                              end: Offset.zero,
                            ).animate(animation);
                            return SlideTransition(
                              position: inOffset,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: isSolved
                              ? Row(
                                  key: ValueKey('solved_${_sessionManager.activeSession.solvedCode}'),
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 28, color: successGreen),
                                    const SizedBox(width: 8),
                                    Text(
                                      _sessionManager.activeSession.solvedCode ?? '',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.0,
                                        height: 1.0,
                                        color: successGreen,
                                      ),
                                    ),
                                  ],
                                )
                              : (isCompleted
                                  ? Text(
                                      'All Tried',
                                      key: const ValueKey('all_tried'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                        color: textPrimary,
                                      ),
                                    )
                                  : Opacity(
                                      key: ValueKey('code_${_sessionManager.currentTargetCode}'),
                                      opacity: _sessionManager.isHotkeysEnabled ? 1.0 : 0.88,
                                      child: Text(
                                        _sessionManager.currentTargetCode,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 52,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1.5,
                                          height: 1.0,
                                          color: isDark ? Colors.white : const Color(0xFF111111),
                                        ),
                                      ),
                                    )),
                        ),
                      ),
                    ),

                    // Hierarchy & Progress indicator (small text showing hierarchy from first to last and codes used)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF18181E) : const Color(0xFFEBEBF0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSolved
                                ? successGreen.withValues(alpha: 0.5)
                                : (isDark ? const Color(0xFF262630) : const Color(0xFFD4D4D8)),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isSolved
                              ? 'Solved at #${currentIndex + 1} of ${_formatCount(totalCodes)} • $currentIndex used'
                              : (isCompleted
                                  ? 'All ${_formatCount(totalCodes)} codes used'
                                  : '#${currentIndex + 1} of ${_formatCount(totalCodes)} • $currentIndex used'),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isSolved ? successGreen : textMuted,
                          ),
                        ),
                      ),
                    ),

                    // Row 3: Compact Hotkey Helper Badges ([key] Next, [key] Back, [key] Solved) with Dynamic Feedback
                    Row(
                      children: [
                        Expanded(child: _buildHotkeyBadge(_sessionManager.keyPrev, 'Back', _stepPrev, actionId: 'prev')),
                        const SizedBox(width: 4),
                        Expanded(child: _buildHotkeyBadge(_sessionManager.keyNext, 'Next', _advanceNext, actionId: 'next')),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildHotkeyBadge(
                            _sessionManager.keySolved,
                            isSolved ? 'Solved ✓' : 'Solved',
                            _markSolved,
                            isHighlight: isSolved,
                            actionId: 'solved',
                          ),
                        ),
                      ],
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

  Widget _buildHotkeyBadge(
    String keyLabel,
    String actionLabel,
    VoidCallback onTap, {
    bool isHighlight = false,
    String actionId = '',
  }) {
    final isDark = widget.isDark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);
    final isActuated = _activeActuationKey == actionId && actionId.isNotEmpty;

    return AnimatedScale(
      scale: isActuated ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3.0),
          decoration: BoxDecoration(
            color: isActuated
                ? (isDark ? const Color(0xFF383844) : const Color(0xFFD0D0DA))
                : (isHighlight
                    ? const Color(0x3334C759)
                    : (isDark ? const Color(0xFF1C1C22) : const Color(0xFFE8E8ED))),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActuated
                  ? const Color(0xFF007AFF)
                  : (isHighlight
                      ? const Color(0xFF34C759)
                      : (isDark ? const Color(0xFF2E2E38) : const Color(0xFFD1D1D6))),
              width: isActuated ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF282832) : const Color(0xFFD6D6DC),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  keyLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  actionLabel,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isHighlight ? const Color(0xFF34C759) : textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
