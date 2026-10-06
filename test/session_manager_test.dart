import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_code_raid_counter/models/session_manager.dart';

void main() {
  group('SessionManager Tests', () {
    String? originalCodesContent;

    setUpAll(() {
      final codesFile = SessionManager.resolveCodesFile();
      if (codesFile.existsSync()) {
        originalCodesContent = codesFile.readAsStringSync();
      }
    });

    tearDownAll(() {
      if (originalCodesContent != null) {
        final codesFile = SessionManager.resolveCodesFile();
        codesFile.writeAsStringSync(originalCodesContent!);
      }
    });

    setUp(() {
      // Ensure clean test environment
      final file = File(SessionManager.sessionsFileName);
      if (file.existsSync()) file.deleteSync();
      final settingsFile = File(SessionManager.settingsFileName);
      if (settingsFile.existsSync()) settingsFile.deleteSync();
      final codesFile = SessionManager.resolveCodesFile();
      codesFile.writeAsStringSync('1234\n1111\n0000\n');
    });

    tearDown(() {
      final file = File(SessionManager.sessionsFileName);
      if (file.existsSync()) file.deleteSync();
      final settingsFile = File(SessionManager.settingsFileName);
      if (settingsFile.existsSync()) settingsFile.deleteSync();
    });

    test('Initializes with default session Base 1 and codes from file', () {
      final manager = SessionManager();
      expect(manager.activeSession.name, 'Base 1');
      expect(manager.codes, ['1234', '1111', '0000']);
      expect(manager.currentIndex, 0);
      expect(manager.currentTargetCode, '1234');
      expect(manager.isHotkeysEnabled, true);
    });

    test('Create new base session and switch between sessions', () {
      final manager = SessionManager();
      manager.createSession('Sulfur Quarry');

      expect(manager.sessions.length, 2);
      expect(manager.activeSession.name, 'Sulfur Quarry');
      expect(manager.currentIndex, 0);

      // Advance in Sulfur Quarry
      manager.nextCode();
      expect(manager.currentIndex, 1);

      // Switch back to Base 1
      final base1Id = manager.sessions.first.id;
      manager.switchSession(base1Id);
      expect(manager.activeSession.name, 'Base 1');
      expect(manager.currentIndex, 0); // Base 1 was on 0
    });

    test('Mark code as solved logs to attempt history', () {
      final manager = SessionManager();
      expect(manager.activeSession.isSolved, false);
      expect(manager.currentHistory.isEmpty, true);

      manager.markCurrentCodeSolved();
      expect(manager.activeSession.isSolved, true);
      expect(manager.activeSession.solvedCode, '1234');
      expect(manager.currentHistory.length, 1);
      expect(manager.currentHistory.first.code, '1234');
      expect(manager.currentHistory.first.isSolved, true);

      // Toggle solved removes it
      manager.toggleSolved();
      expect(manager.activeSession.isSolved, false);
      expect(manager.activeSession.solvedCode, isNull);
    });

    test('nextCode() logs attempt history with timestamp', () {
      final manager = SessionManager();
      expect(manager.currentHistory.isEmpty, true);

      manager.nextCode(); // tries 1234, advances to 1111
      expect(manager.currentIndex, 1);
      expect(manager.currentTargetCode, '1111');
      expect(manager.currentHistory.length, 1);
      expect(manager.currentHistory.first.code, '1234');
      expect(manager.currentHistory.first.isSolved, false);
      expect(manager.currentHistory.first.formattedTime.isNotEmpty, true);

      manager.nextCode(); // tries 1111, advances to 0000
      expect(manager.currentIndex, 2);
      expect(manager.currentHistory.length, 2);
      expect(manager.currentHistory[1].code, '1111');
    });

    test('Delete session removes it from list', () {
      final manager = SessionManager();
      manager.createSession('Base 2');
      expect(manager.sessions.length, 2);

      final base2Id = manager.activeSession.id;
      manager.deleteSession(base2Id);
      expect(manager.sessions.length, 1);
      expect(manager.activeSession.name, 'Base 1');
    });

    test('Hotkeys setting persists across SessionManager instances via settings.json', () {
      final manager1 = SessionManager();
      expect(manager1.isHotkeysEnabled, true);

      // Disable hotkeys
      manager1.setHotkeysEnabled(false);
      expect(manager1.isHotkeysEnabled, false);
      expect(File(SessionManager.settingsFileName).existsSync(), true);

      // New instance should read disabled state from settings.json
      final manager2 = SessionManager();
      expect(manager2.isHotkeysEnabled, false);

      // Toggle back on
      manager2.toggleHotkeys();
      expect(manager2.isHotkeysEnabled, true);

      final manager3 = SessionManager();
      expect(manager3.isHotkeysEnabled, true);
    });

    test('Attempt history persists across SessionManager instances via sessions.json', () {
      final manager1 = SessionManager();
      manager1.nextCode(); // logs 1234
      manager1.markCurrentCodeSolved(); // logs 1111 as solved

      expect(manager1.currentHistory.length, 2);

      // Re-load in second manager instance
      final manager2 = SessionManager();
      expect(manager2.currentHistory.length, 2);
      expect(manager2.currentHistory[0].code, '1234');
      expect(manager2.currentHistory[0].isSolved, false);
      expect(manager2.currentHistory[1].code, '1111');
      expect(manager2.currentHistory[1].isSolved, true);
    });

    test('HUD position setting persists across SessionManager instances via settings.json', () {
      final manager1 = SessionManager();
      expect(manager1.hudPosition, 'topRight');

      // Change to bottomLeft
      manager1.setHudPosition('bottomLeft');
      expect(manager1.hudPosition, 'bottomLeft');
      expect(File(SessionManager.settingsFileName).existsSync(), true);

      // New instance should read bottomLeft
      final manager2 = SessionManager();
      expect(manager2.hudPosition, 'bottomLeft');

      // Change to topCenter
      manager2.setHudPosition('topCenter');
      final manager3 = SessionManager();
      expect(manager3.hudPosition, 'topCenter');
    });

    test('Loads codes from code.txt file with custom numbers', () {
      final codeFile = SessionManager.resolveCodesFile();
      codeFile.writeAsStringSync('9876\n5432\n1000\n');

      final manager = SessionManager();
      expect(manager.codes, ['9876', '5432', '1000']);
      expect(manager.currentTargetCode, '9876');
    });

    test('renameSession and renameActiveSession update name and persist via sessions.json', () {
      final manager = SessionManager();
      expect(manager.activeSession.name, 'Base 1');

      // Rename active session
      manager.renameActiveSession('Bunker 2x2');
      expect(manager.activeSession.name, 'Bunker 2x2');

      // Create second session and rename by ID
      manager.createSession('Old Name');
      final secondId = manager.activeSession.id;
      expect(manager.activeSession.name, 'Old Name');

      manager.renameSession(secondId, 'Main Compound');
      expect(manager.activeSession.name, 'Main Compound');

      // Check persistence in new instance
      final manager2 = SessionManager();
      expect(manager2.sessions.first.name, 'Bunker 2x2');
      expect(manager2.sessions[1].name, 'Main Compound');
    });

    test('Keybinds default to F8, F7, F9 and can be modified with auto-swapping', () {
      final manager = SessionManager();
      expect(manager.keyNext, 'F8');
      expect(manager.keyPrev, 'F7');
      expect(manager.keySolved, 'F9');

      // Set keyNext to Page Down
      manager.setKeyNext('Page Down');
      expect(manager.keyNext, 'Page Down');
      expect(manager.keyPrev, 'F7');
      expect(manager.keySolved, 'F9');

      // Test auto-swapping: set keyNext to F7 (which was keyPrev)
      manager.setKeyNext('F7');
      expect(manager.keyNext, 'F7');
      expect(manager.keyPrev, 'Page Down'); // swapped!

      // Reset to defaults
      manager.resetKeybindsToDefault();
      expect(manager.keyNext, 'F8');
      expect(manager.keyPrev, 'F7');
      expect(manager.keySolved, 'F9');
    });

    test('Keybinds and HUD scale persist across SessionManager instances via settings.json', () {
      final manager1 = SessionManager();
      manager1.setKeyNext('Num +');
      manager1.setKeyPrev('Num -');
      manager1.setKeySolved('Num Enter');
      manager1.setHudScale(1.5);

      expect(manager1.keyNext, 'Num +');
      expect(manager1.keyPrev, 'Num -');
      expect(manager1.keySolved, 'Num Enter');
      expect(manager1.hudScale, 1.5);
      expect(File(SessionManager.settingsFileName).existsSync(), true);

      // Verify loaded in new instance
      final manager2 = SessionManager();
      expect(manager2.keyNext, 'Num +');
      expect(manager2.keyPrev, 'Num -');
      expect(manager2.keySolved, 'Num Enter');
      expect(manager2.hudScale, 1.5);
    });

    test('HUD scale is clamped between 1.0 and 2.5', () {
      final manager = SessionManager();
      manager.setHudScale(0.5);
      expect(manager.hudScale, 1.0);

      manager.setHudScale(3.0);
      expect(manager.hudScale, 2.5);
    });

    test('isDark and Light Mode toggle persist across SessionManager instances via settings.json', () {
      final manager1 = SessionManager();
      expect(manager1.isDark, true);

      // Switch to Light Mode
      manager1.setIsDark(false);
      expect(manager1.isDark, false);
      expect(File(SessionManager.settingsFileName).existsSync(), true);

      // New instance should read Light Mode (isDark: false)
      final manager2 = SessionManager();
      expect(manager2.isDark, false);

      // Toggle back to Dark Mode
      manager2.toggleTheme();
      expect(manager2.isDark, true);

      final manager3 = SessionManager();
      expect(manager3.isDark, true);
    });

    test('isSoundMuted and Mute toggle persist across SessionManager instances via settings.json', () {
      final manager1 = SessionManager();
      expect(manager1.isSoundMuted, false);

      // Mute sound
      manager1.setIsSoundMuted(true);
      expect(manager1.isSoundMuted, true);
      expect(File(SessionManager.settingsFileName).existsSync(), true);

      // New instance should read isSoundMuted: true
      final manager2 = SessionManager();
      expect(manager2.isSoundMuted, true);

      // Toggle back to unmuted
      manager2.toggleSoundMuted();
      expect(manager2.isSoundMuted, false);

      final manager3 = SessionManager();
      expect(manager3.isSoundMuted, false);
    });
  });
}
