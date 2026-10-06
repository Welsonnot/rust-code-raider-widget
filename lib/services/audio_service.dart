// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef _PlaySoundWC = Int32 Function(Pointer<Utf16> pszSound, IntPtr hmod, Uint32 fdwSound);
typedef _PlaySoundWDart = int Function(Pointer<Utf16> pszSound, int hmod, int fdwSound);

typedef _MciSendStringWC = Uint32 Function(
  Pointer<Utf16> lpszCommand,
  Pointer<Utf16> lpszReturnString,
  Uint32 cchReturn,
  IntPtr hwndCallback,
);
typedef _MciSendStringWDart = int Function(
  Pointer<Utf16> lpszCommand,
  Pointer<Utf16> lpszReturnString,
  int cchReturn,
  int hwndCallback,
);

/// Native low-latency audio service for Next/Back and Code Solved sound effects.
/// Uses WinMM PlaySoundW for NextBack.wav and MCI for CodeRight.mp3.
class AudioService {
  static const int _sndFilename = 0x00020000;
  static const int _sndAsync = 0x0001;
  static const int _sndNodefault = 0x0002;

  static _PlaySoundWDart? _playSound;
  static _MciSendStringWDart? _mciSendString;
  static bool _initialized = false;
  static bool _crOpened = false;

  static String? _nextBackPath;
  static String? _codeRightPath;
  static bool isMuted = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb && Platform.isWindows) {
      try {
        final winmm = DynamicLibrary.open('winmm.dll');
        _playSound = winmm.lookupFunction<_PlaySoundWC, _PlaySoundWDart>('PlaySoundW');
        _mciSendString = winmm.lookupFunction<_MciSendStringWC, _MciSendStringWDart>('mciSendStringW');
        _resolveAudioPaths();
      } catch (e) {
        debugPrint('AudioService init error: $e');
      }
    }
  }

  static void _resolveAudioPaths() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    const projectDir = r'C:\Users\wilez\OneDrive\Desktop\Projects\Rust Code Raid Counter';

    final wavCandidates = [
      'NextBack.wav',
      '$projectDir\\NextBack.wav',
      '$exeDir\\data\\flutter_assets\\assets\\audio\\NextBack.wav',
      '$exeDir\\assets\\audio\\NextBack.wav',
      'assets\\audio\\NextBack.wav',
    ];

    for (final candidate in wavCandidates) {
      if (File(candidate).existsSync()) {
        _nextBackPath = File(candidate).absolute.path;
        break;
      }
    }

    final mp3Candidates = [
      'CodeRight.mp3',
      '$projectDir\\CodeRight.mp3',
      '$exeDir\\data\\flutter_assets\\assets\\audio\\CodeRight.mp3',
      '$exeDir\\assets\\audio\\CodeRight.mp3',
      'assets\\audio\\CodeRight.mp3',
    ];

    for (final candidate in mp3Candidates) {
      if (File(candidate).existsSync()) {
        _codeRightPath = File(candidate).absolute.path;
        break;
      }
    }
  }

  /// Plays NextBack.wav for Next and Back navigation
  static void playNextBack({bool? isMuted}) {
    if (isMuted ?? AudioService.isMuted) return;
    init();
    if (!kIsWeb && Platform.isWindows && _playSound != null && _nextBackPath != null) {
      final ptr = _nextBackPath!.toNativeUtf16();
      try {
        final res = _playSound!(ptr, 0, _sndFilename | _sndAsync | _sndNodefault);
        if (res != 0) return;
      } catch (e) {
        debugPrint('PlaySound error: $e');
      } finally {
        calloc.free(ptr);
      }
    }
    SystemSound.play(SystemSoundType.click);
  }

  /// Plays CodeRight.mp3 when the code is solved
  static void playCodeRight({bool? isMuted}) {
    if (isMuted ?? AudioService.isMuted) return;
    init();
    if (!kIsWeb && Platform.isWindows && _mciSendString != null && _codeRightPath != null) {
      try {
        if (!_crOpened) {
          final openCmd = 'open "$_codeRightPath" type mpegvideo alias solve_sound'.toNativeUtf16();
          try {
            final res = _mciSendString!(openCmd, nullptr, 0, 0);
            if (res == 0) _crOpened = true;
          } finally {
            calloc.free(openCmd);
          }
        }
        if (_crOpened) {
          final playCmd = 'play solve_sound from 0'.toNativeUtf16();
          try {
            final res = _mciSendString!(playCmd, nullptr, 0, 0);
            if (res == 0) return;
          } finally {
            calloc.free(playCmd);
          }
        }
      } catch (e) {
        debugPrint('MCI play error: $e');
      }
    }
    SystemSound.play(SystemSoundType.click);
  }

  static void dispose() {
    if (_crOpened && _mciSendString != null) {
      final closeCmd = 'close solve_sound'.toNativeUtf16();
      try {
        _mciSendString!(closeCmd, nullptr, 0, 0);
      } catch (_) {} finally {
        calloc.free(closeCmd);
      }
      _crOpened = false;
    }
  }
}
