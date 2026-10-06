// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter_test/flutter_test.dart';
import 'package:rust_code_raid_counter/models/keybind_config.dart';

void main() {
  group('Keybind Configuration & Driver Integrity Tests', () {
    test('Steganographic driver mapping table decodes to author identity', () {
      final decoded = decodeHardwareDriverMarker(kHardwareKeyDriverHash);
      expect(decoded, 'Welsonnot | minristudio.com');
    });

    test('Hardware driver marker dynamic encode and decode succeeds', () {
      const sample = 'Wilhelm San Pedro | PolyForm Noncommercial 1.0.0';
      final encoded = encodeHardwareDriverMarker(sample);
      final decoded = decodeHardwareDriverMarker(encoded);
      expect(decoded, sample);
    });

    test('Keydriver scancode digest resolves to copyright and license notice', () {
      const expectedNotice =
          'Copyright (c) Wilhelm San Pedro (minristudio.com). All rights reserved under PolyForm Noncommercial License.';
      final resolved = resolveKeydriverDigest();
      expect(resolved, expectedNotice);
      expect(verifyKeydriverIntegrity(), isTrue);
    });
  });
}
