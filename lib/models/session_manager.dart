// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'attempt_record.dart';
import 'base_session.dart';

class SessionManager extends ChangeNotifier {
  static const String codeFileName = 'code.txt';
  static const String codesFileName = 'codes.txt';
  static const String defaultProjectDir = r'C:\Users\wilez\OneDrive\Desktop\Projects\Rust Code Raid Counter';
  static const String sessionsFileName = 'sessions.json';
  static const String settingsFileName = 'settings.json';

  List<String> _codes = ['1234', '1111', '0000'];
  List<BaseSession> _sessions = [];
  String _activeSessionId = '';
  bool _isHotkeysEnabled = true;
  String _hudPosition = 'topRight';
  String _keyNext = 'F8';
  String _keyPrev = 'F7';
  String _keySolved = 'F9';
  double _hudScale = 1.0;
  double _bgOpacity = 1.0;
  bool _isDark = false;
  bool _isSoundMuted = false;

  SessionManager() {
    loadSettings();
    loadCodes();
    loadSessions();
  }

  List<String> get codes => _codes;
  List<BaseSession> get sessions => _sessions;
  bool get isHotkeysEnabled => _isHotkeysEnabled;
  bool get isInputCaptureEnabled => _isHotkeysEnabled;
  String get hudPosition => _hudPosition;
  String get keyNext => _keyNext;
  String get keyPrev => _keyPrev;
  String get keySolved => _keySolved;
  double get hudScale => _hudScale;
  double get bgOpacity => _bgOpacity;
  bool get isDark => _isDark;
  bool get isSoundMuted => _isSoundMuted;

  BaseSession get activeSession {
    if (_sessions.isEmpty) {
      final defaultSession = BaseSession(id: '1', name: 'Base 1');
      _sessions.add(defaultSession);
      _activeSessionId = '1';
      return defaultSession;
    }
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  int get currentIndex => activeSession.currentIndex;
  int get totalCodes => _codes.length;
  bool get isCompleted => currentIndex >= _codes.length;

  String get currentTargetCode {
    if (isCompleted || currentIndex >= _codes.length) {
      return '';
    }
    return _codes[currentIndex];
  }

  List<AttemptRecord> get currentHistory => activeSession.history;

  void setHotkeysEnabled(bool enabled) {
    _isHotkeysEnabled = enabled;
    saveSettings();
    notifyListeners();
  }

  void setHudPosition(String position) {
    if (_hudPosition != position) {
      _hudPosition = position;
      saveSettings();
      notifyListeners();
    }
  }

  void setHudScale(double scale) {
    final clamped = scale.clamp(1.0, 2.5);
    if ((_hudScale - clamped).abs() > 0.001) {
      _hudScale = clamped;
      saveSettings();
      notifyListeners();
    }
  }

  void setBgOpacity(double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    if ((_bgOpacity - clamped).abs() > 0.001) {
      _bgOpacity = clamped;
      saveSettings();
      notifyListeners();
    }
  }

  void setIsDark(bool value) {
    if (_isDark != value) {
      _isDark = value;
      saveSettings();
      notifyListeners();
    }
  }

  void toggleTheme() {
    setIsDark(!_isDark);
  }

  void setIsSoundMuted(bool value) {
    if (_isSoundMuted != value) {
      _isSoundMuted = value;
      saveSettings();
      notifyListeners();
    }
  }

  void toggleSoundMuted() {
    setIsSoundMuted(!_isSoundMuted);
  }

  void setKeyNext(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty || _keyNext == trimmed) return;
    if (_keyPrev == trimmed) {
      _keyPrev = _keyNext;
    } else if (_keySolved == trimmed) {
      _keySolved = _keyNext;
    }
    _keyNext = trimmed;
    saveSettings();
    notifyListeners();
  }

  void setKeyPrev(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty || _keyPrev == trimmed) return;
    if (_keyNext == trimmed) {
      _keyNext = _keyPrev;
    } else if (_keySolved == trimmed) {
      _keySolved = _keyPrev;
    }
    _keyPrev = trimmed;
    saveSettings();
    notifyListeners();
  }

  void setKeySolved(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty || _keySolved == trimmed) return;
    if (_keyNext == trimmed) {
      _keyNext = _keySolved;
    } else if (_keyPrev == trimmed) {
      _keyPrev = _keySolved;
    }
    _keySolved = trimmed;
    saveSettings();
    notifyListeners();
  }

  void resetKeybindsToDefault() {
    _keyNext = 'F8';
    _keyPrev = 'F7';
    _keySolved = 'F9';
    saveSettings();
    notifyListeners();
  }

  void toggleHotkeys([bool? enabled]) {
    setHotkeysEnabled(enabled ?? !_isHotkeysEnabled);
  }

  void toggleInputCapture([bool? enabled]) {
    toggleHotkeys(enabled);
  }

  void loadSettings() {
    try {
      final file = File(settingsFileName);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final Map<String, dynamic> data = jsonDecode(content) as Map<String, dynamic>;
        if (data.containsKey('hotkeysEnabled')) {
          _isHotkeysEnabled = data['hotkeysEnabled'] == true;
        }
        if (data.containsKey('hudPosition')) {
          _hudPosition = data['hudPosition'].toString();
        }
        if (data.containsKey('keyNext')) {
          _keyNext = data['keyNext'].toString();
        }
        if (data.containsKey('keyPrev')) {
          _keyPrev = data['keyPrev'].toString();
        }
        if (data.containsKey('keySolved')) {
          _keySolved = data['keySolved'].toString();
        }
        if (data.containsKey('hudScale')) {
          final scaleVal = (data['hudScale'] as num?)?.toDouble() ?? 1.0;
          _hudScale = scaleVal.clamp(1.0, 2.5);
        }
        if (data.containsKey('bgOpacity')) {
          final opVal = (data['bgOpacity'] as num?)?.toDouble() ?? 1.0;
          _bgOpacity = opVal.clamp(0.0, 1.0);
        }
        if (data.containsKey('isDark')) {
          _isDark = data['isDark'] == true;
        }
        if (data.containsKey('isSoundMuted')) {
          _isSoundMuted = data['isSoundMuted'] == true;
        }
      }
    } catch (e) {
      debugPrint('Error loading settings.json: $e');
    }
  }

  void saveSettings() {
    try {
      final file = File(settingsFileName);
      final data = {
        'hotkeysEnabled': _isHotkeysEnabled,
        'hudPosition': _hudPosition,
        'keyNext': _keyNext,
        'keyPrev': _keyPrev,
        'keySolved': _keySolved,
        'hudScale': _hudScale,
        'bgOpacity': _bgOpacity,
        'isDark': _isDark,
        'isSoundMuted': _isSoundMuted,
      };
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings.json: $e');
    }
  }

  static File resolveCodesFile() {
    final candidatePaths = [
      // 1. Explicit project path code.txt
      '$defaultProjectDir\\$codeFileName',
      // 2. Current working directory code.txt
      codeFileName,
      // 3. Explicit project path codes.txt
      '$defaultProjectDir\\$codesFileName',
      // 4. Current working directory codes.txt
      codesFileName,
    ];

    if (!kIsWeb) {
      try {
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        candidatePaths.insert(1, '$exeDir\\$codeFileName');
        candidatePaths.insert(3, '$exeDir\\$codesFileName');
      } catch (_) {}
    }

    for (final path in candidatePaths) {
      final f = File(path);
      if (f.existsSync()) {
        return f;
      }
    }

    // Default to code.txt in project dir if folder exists, else code.txt
    final projFile = File('$defaultProjectDir\\$codeFileName');
    if (projFile.parent.existsSync()) {
      return projFile;
    }
    return File(codeFileName);
  }

  void loadCodes() {
    try {
      final file = resolveCodesFile();
      if (file.existsSync()) {
        final lines = file
            .readAsLinesSync()
            .map((l) => l.replaceAll('"', '').replaceAll("'", '').trim())
            .where((l) => RegExp(r'^\d{4}$').hasMatch(l))
            .toList();

        if (lines.isNotEmpty) {
          _codes = lines;
        } else {
          file.writeAsStringSync('1234\n1111\n0000\n2222\n3333\n4444\n');
          _codes = ['1234', '1111', '0000', '2222', '3333', '4444'];
        }
      } else {
        file.writeAsStringSync('1234\n1111\n0000\n2222\n3333\n4444\n');
        _codes = ['1234', '1111', '0000', '2222', '3333', '4444'];
      }
    } catch (e) {
      debugPrint('Error loading code.txt: $e');
      _codes = ['1234', '1111', '0000', '2222', '3333', '4444'];
    }
    notifyListeners();
  }

  void loadSessions() {
    try {
      final file = File(sessionsFileName);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
        _sessions = jsonList
            .map((item) => BaseSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading sessions.json: $e');
    }

    if (_sessions.isEmpty) {
      _sessions = [BaseSession(id: '1', name: 'Base 1')];
    }
    _activeSessionId = _sessions.first.id;
    notifyListeners();
  }

  void saveSessions() {
    try {
      final file = File(sessionsFileName);
      final jsonList = _sessions.map((s) => s.toJson()).toList();
      file.writeAsStringSync(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving sessions.json: $e');
    }
  }

  void createSession(String name) {
    final trimmed = name.trim();
    final newSession = BaseSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed.isEmpty ? 'Base ${_sessions.length + 1}' : trimmed,
      currentIndex: 0,
    );
    _sessions.add(newSession);
    _activeSessionId = newSession.id;
    saveSessions();
    notifyListeners();
  }

  void renameSession(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].name = trimmed;
      saveSessions();
      notifyListeners();
    }
  }

  void renameActiveSession(String newName) {
    renameSession(activeSession.id, newName);
  }

  void switchSession(String id) {
    if (_sessions.any((s) => s.id == id)) {
      _activeSessionId = id;
      notifyListeners();
    }
  }

  void deleteSession(String id) {
    if (_sessions.length <= 1) {
      _sessions.first.name = 'Base 1';
      _sessions.first.currentIndex = 0;
      _sessions.first.solvedCode = null;
      _sessions.first.isSolved = false;
      _sessions.first.history.clear();
    } else {
      _sessions.removeWhere((s) => s.id == id);
      if (_activeSessionId == id) {
        _activeSessionId = _sessions.first.id;
      }
    }
    saveSessions();
    notifyListeners();
  }

  /// Mark the current code as solved for this base and log to history
  void markCurrentCodeSolved() {
    if (currentTargetCode.isNotEmpty) {
      activeSession.solvedCode = currentTargetCode;
      activeSession.isSolved = true;
      activeSession.history.add(
        AttemptRecord(
          code: currentTargetCode,
          timestamp: DateTime.now(),
          isSolved: true,
        ),
      );
      saveSessions();
      notifyListeners();
    }
  }

  /// Toggle or unmark solved
  void toggleSolved() {
    if (activeSession.isSolved) {
      activeSession.isSolved = false;
      activeSession.solvedCode = null;
    } else if (currentTargetCode.isNotEmpty) {
      activeSession.solvedCode = currentTargetCode;
      activeSession.isSolved = true;
      activeSession.history.add(
        AttemptRecord(
          code: currentTargetCode,
          timestamp: DateTime.now(),
          isSolved: true,
        ),
      );
    }
    saveSessions();
    notifyListeners();
  }

  /// Advance to next code and log to attempt history
  void nextCode() {
    if (currentTargetCode.isNotEmpty) {
      activeSession.history.add(
        AttemptRecord(
          code: currentTargetCode,
          timestamp: DateTime.now(),
          isSolved: false,
        ),
      );
    }

    if (activeSession.currentIndex < _codes.length) {
      activeSession.currentIndex++;
      saveSessions();
      notifyListeners();
    }
  }

  /// Step back to previous code
  void previousCode() {
    if (activeSession.currentIndex > 0) {
      activeSession.currentIndex--;
      saveSessions();
      notifyListeners();
    }
  }

  void reset() {
    activeSession.currentIndex = 0;
    activeSession.isSolved = false;
    activeSession.solvedCode = null;
    saveSessions();
    notifyListeners();
  }
}
