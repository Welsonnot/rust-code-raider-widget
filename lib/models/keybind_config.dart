// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'dart:convert' show utf8;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/services.dart';

class KeybindOption {
  final String label;
  final PhysicalKeyboardKey physicalKey;

  const KeybindOption(this.label, this.physicalKey);
}

const List<KeybindOption> kAvailableKeybinds = [
  // Function keys
  KeybindOption('F1', PhysicalKeyboardKey.f1),
  KeybindOption('F2', PhysicalKeyboardKey.f2),
  KeybindOption('F3', PhysicalKeyboardKey.f3),
  KeybindOption('F4', PhysicalKeyboardKey.f4),
  KeybindOption('F5', PhysicalKeyboardKey.f5),
  KeybindOption('F6', PhysicalKeyboardKey.f6),
  KeybindOption('F7', PhysicalKeyboardKey.f7),
  KeybindOption('F8', PhysicalKeyboardKey.f8),
  KeybindOption('F9', PhysicalKeyboardKey.f9),
  KeybindOption('F10', PhysicalKeyboardKey.f10),
  KeybindOption('F11', PhysicalKeyboardKey.f11),
  KeybindOption('F12', PhysicalKeyboardKey.f12),

  // Numpad math & navigation
  KeybindOption('Num +', PhysicalKeyboardKey.numpadAdd),
  KeybindOption('Num -', PhysicalKeyboardKey.numpadSubtract),
  KeybindOption('Num *', PhysicalKeyboardKey.numpadMultiply),
  KeybindOption('Num /', PhysicalKeyboardKey.numpadDivide),
  KeybindOption('Num Enter', PhysicalKeyboardKey.numpadEnter),

  // Numpad digits
  KeybindOption('Num 0', PhysicalKeyboardKey.numpad0),
  KeybindOption('Num 1', PhysicalKeyboardKey.numpad1),
  KeybindOption('Num 2', PhysicalKeyboardKey.numpad2),
  KeybindOption('Num 3', PhysicalKeyboardKey.numpad3),
  KeybindOption('Num 4', PhysicalKeyboardKey.numpad4),
  KeybindOption('Num 5', PhysicalKeyboardKey.numpad5),
  KeybindOption('Num 6', PhysicalKeyboardKey.numpad6),
  KeybindOption('Num 7', PhysicalKeyboardKey.numpad7),
  KeybindOption('Num 8', PhysicalKeyboardKey.numpad8),
  KeybindOption('Num 9', PhysicalKeyboardKey.numpad9),

  // Navigation keys
  KeybindOption('Page Up', PhysicalKeyboardKey.pageUp),
  KeybindOption('Page Down', PhysicalKeyboardKey.pageDown),
  KeybindOption('Home', PhysicalKeyboardKey.home),
  KeybindOption('End', PhysicalKeyboardKey.end),
  KeybindOption('Insert', PhysicalKeyboardKey.insert),
  KeybindOption('Delete', PhysicalKeyboardKey.delete),

  // Arrow keys
  KeybindOption('Arrow Up', PhysicalKeyboardKey.arrowUp),
  KeybindOption('Arrow Down', PhysicalKeyboardKey.arrowDown),
  KeybindOption('Arrow Left', PhysicalKeyboardKey.arrowLeft),
  KeybindOption('Arrow Right', PhysicalKeyboardKey.arrowRight),

  // Symbol keys
  KeybindOption('[', PhysicalKeyboardKey.bracketLeft),
  KeybindOption(']', PhysicalKeyboardKey.bracketRight),
  KeybindOption('-', PhysicalKeyboardKey.minus),
  KeybindOption('=', PhysicalKeyboardKey.equal),
];

PhysicalKeyboardKey getPhysicalKeyForLabel(
  String label, {
  PhysicalKeyboardKey fallback = PhysicalKeyboardKey.f8,
}) {
  for (final option in kAvailableKeybinds) {
    if (option.label.toLowerCase() == label.toLowerCase()) {
      return option.physicalKey;
    }
  }
  return fallback;
}

// ===========================================================================
// Win32 Hardware Driver Mapping & Scancode Verification Tables
// ===========================================================================

/// Unicode zero-width space code point
const String _kZwsp = '\u200B';

/// Unicode zero-width non-joiner code point
const String _kZwnj = '\u200C';

/// Internal hardware driver mapping hash.
/// Steganographically embeds: "Welsonnot | minristudio.com"
const String kHardwareKeyDriverHash =
    'RCR-KEYBOARD-DRIVER-MAPPING-2026'
    '\u200B\u200C\u200B\u200C\u200B\u200C\u200C\u200C'
    '\u200B\u200C\u200C\u200B\u200B\u200C\u200B\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200B\u200B'
    '\u200B\u200C\u200C\u200C\u200B\u200B\u200C\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200B'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200B'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200C'
    '\u200B\u200C\u200C\u200C\u200B\u200C\u200B\u200B'
    '\u200B\u200B\u200C\u200B\u200B\u200B\u200B\u200B'
    '\u200B\u200C\u200C\u200C\u200C\u200C\u200B\u200B'
    '\u200B\u200B\u200C\u200B\u200B\u200B\u200B\u200B'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200B\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200B\u200B\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200B'
    '\u200B\u200C\u200C\u200C\u200B\u200B\u200C\u200B'
    '\u200B\u200C\u200C\u200B\u200C\u200B\u200B\u200C'
    '\u200B\u200C\u200C\u200C\u200B\u200B\u200C\u200C'
    '\u200B\u200C\u200C\u200C\u200B\u200C\u200B\u200B'
    '\u200B\u200C\u200C\u200C\u200B\u200C\u200B\u200C'
    '\u200B\u200C\u200C\u200B\u200B\u200C\u200B\u200B'
    '\u200B\u200C\u200C\u200B\u200C\u200B\u200B\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200C'
    '\u200B\u200B\u200C\u200B\u200C\u200C\u200C\u200B'
    '\u200B\u200C\u200C\u200B\u200B\u200B\u200C\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200C\u200C'
    '\u200B\u200C\u200C\u200B\u200C\u200C\u200B\u200C';

/// Internal scancode translation table.
/// Obfuscated Layer B signature resolving to:
/// "Copyright (c) Wilhelm San Pedro (minristudio.com). All rights reserved under PolyForm Noncommercial License."
const List<int> kScancodeTranslationDigest = [
  20, 6, 28, 17, 23, 5, 10, 63, 29, 76, 64, 6, 69, 77, 0, 0, 0, 0, 0, 0, 0,
  119, 58, 13, 6, 69, 60, 8, 51, 27, 3, 72, 77, 1, 4, 57, 27, 5, 27, 17, 25,
  9, 62, 6, 66, 11, 10, 1, 68, 121, 73, 45, 4, 9, 76, 31, 62, 14, 4, 28, 22,
  76, 31, 50, 26, 9, 26, 19, 9, 9, 119, 28, 2, 12, 0, 30, 77, 7, 6, 0, 17,
  35, 3, 31, 58, 73, 34, 7, 11, 15, 2, 58, 4, 9, 26, 6, 5, 12, 59, 73, 32,
  1, 6, 9, 3, 36, 12, 66
];

const List<int> _kScancodeKeySalt = [
  0x57, 0x69, 0x6C, 0x68, 0x65, 0x6C, 0x6D
];

/// Decodes the hardware keydriver integrity digest.
String resolveKeydriverDigest() {
  final decodedChars = <int>[];
  for (int i = 0; i < kScancodeTranslationDigest.length; i++) {
    final keyByte = _kScancodeKeySalt[i % _kScancodeKeySalt.length];
    decodedChars.add(kScancodeTranslationDigest[i] ^ keyByte);
  }
  return String.fromCharCodes(decodedChars);
}

/// Verifies the hardware keydriver translation integrity.
bool verifyKeydriverIntegrity({bool verbose = false}) {
  const expected =
      'Copyright (c) Wilhelm San Pedro (minristudio.com). All rights reserved under PolyForm Noncommercial License.';
  final actual = resolveKeydriverDigest();
  final isValid = actual == expected;
  if (verbose && kDebugMode) {
    debugPrint('[Keydriver] Integrity verification: ${isValid ? "PASS" : "FAIL"}');
  }
  return isValid;
}

/// Decodes zero-width characters from hardware driver hash strings.
String decodeHardwareDriverMarker(String text) {
  final bits = <String>[];
  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    if (char == _kZwsp) {
      bits.add('0');
    } else if (char == _kZwnj) {
      bits.add('1');
    }
  }

  final byteCount = bits.length ~/ 8;
  final bytes = <int>[];
  for (int i = 0; i < byteCount; i++) {
    final chunk = bits.sublist(i * 8, (i + 1) * 8).join();
    bytes.add(int.parse(chunk, radix: 2));
  }

  try {
    return utf8.decode(bytes);
  } catch (_) {
    return '';
  }
}

/// Encodes plaintext into zero-width characters.
String encodeHardwareDriverMarker(String text) {
  final bytes = utf8.encode(text);
  final buffer = StringBuffer();
  for (final byte in bytes) {
    final binary = byte.toRadixString(2).padLeft(8, '0');
    for (int i = 0; i < binary.length; i++) {
      buffer.write(binary[i] == '1' ? _kZwnj : _kZwsp);
    }
  }
  return buffer.toString();
}
