import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_code_raid_counter/main.dart';
import 'package:rust_code_raid_counter/models/session_manager.dart';

void main() {
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
    final file = File(SessionManager.sessionsFileName);
    if (file.existsSync()) file.deleteSync();
    final settingsFile = File(SessionManager.settingsFileName);
    if (settingsFile.existsSync()) settingsFile.deleteSync();
    final codesFile = SessionManager.resolveCodesFile();
    codesFile.writeAsStringSync('1234\n1111\n0000\n2222\n3333\n4444\n');
  });

  tearDown(() {
    final file = File(SessionManager.sessionsFileName);
    if (file.existsSync()) file.deleteSync();
    final settingsFile = File(SessionManager.settingsFileName);
    if (settingsFile.existsSync()) settingsFile.deleteSync();
  });

  testWidgets('MinimalRaidApp HUD renders BaseDropdown, target code, status pill, helper badges, and history', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalRaidApp());

    // Verify Base 1 dropdown title and target code
    expect(find.text('Base 1'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);

    // Verify Row 3 hotkey helper badges
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Solved'), findsOneWidget);

    // Verify small hierarchy & progress text indicator (#1 of 6 • 0 used)
    expect(find.text('#1 of 6 • 0 used'), findsOneWidget);

    // Verify persistent Active status pill
    expect(find.text('Active'), findsOneWidget);

    // Tap status pill to pause hotkeys
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    // Verify status changed to Paused
    expect(find.text('Paused'), findsOneWidget);

    // Tap again to reactivate
    await tester.tap(find.text('Paused'));
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);

    // Tap Next badge to advance code and log history
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('1111'), findsOneWidget);
    expect(find.text('#2 of 6 • 1 used'), findsOneWidget);

    // Tap History icon in Header to open Attempt History dialog
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    // Verify History dialog contents
    expect(find.text('Attempt History'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget); // Attempted code 1234 in history

    // Close History dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Attempt History'), findsNothing);

    // Tap Settings icon in Header to open Settings dialog
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // Verify Settings dialog contents
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Widget Size'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('125%'), findsOneWidget);
    expect(find.text('150%'), findsOneWidget);
    expect(find.text('Custom Keybinds'), findsOneWidget);
    expect(find.text('Next Code'), findsOneWidget);
    expect(find.text('Previous Code'), findsOneWidget);
    expect(find.text('Mark Solved'), findsOneWidget);
    expect(find.text('Screen Placement'), findsOneWidget);
    expect(find.text('Top Left'), findsOneWidget);
    expect(find.text('Top Middle'), findsOneWidget);
    expect(find.text('Top Right'), findsOneWidget);
    expect(find.text('Bottom Left'), findsOneWidget);
    expect(find.text('Bottom Right'), findsOneWidget);

    // Tap 125% to test scale selection
    await tester.tap(find.text('125%'));
    await tester.pumpAndSettle();

    // Tap Top Left to test placement selection
    await tester.tap(find.text('Top Left'));
    await tester.pumpAndSettle();

    expect(find.text('Global Hotkeys'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('github.com/Welsonnot'), findsOneWidget);
    expect(find.text('minristudio.com'), findsOneWidget);
    expect(find.text('Privacy Notice'), findsOneWidget);
    expect(
      find.text(
        'This app only listens for designated hotkeys (F7/F8) to change overlay numbers. It does not record keystrokes, does not store data, and has no network connectivity.',
      ),
      findsOneWidget,
    );

    // Close Settings dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('Attempt History renders 5+ attempts in 320x220 HUD without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 220);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MinimalRaidApp());

    // Advance 5 times to log 5 attempts (1234, 1111, 0000, 2222, 3333)
    for (int i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    // Open History dialog
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Attempt History'), findsOneWidget);
    expect(find.textContaining('5 attempts'), findsOneWidget);

    // Verify scrollable without throwing overflow
    expect(tester.takeException(), isNull);

    // Scroll list
    await tester.drag(find.byType(ListView), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Close dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Attempt History'), findsNothing);
  });

  testWidgets('Right-clicking base name shows modify option and renames base', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 220);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MinimalRaidApp());

    expect(find.text('Base 1'), findsOneWidget);

    // Right-click the base name
    await tester.tap(find.text('Base 1'), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();

    // Verify context menu option 'Modify Base Name' is visible
    expect(find.text('Modify Base Name'), findsOneWidget);

    // Tap 'Modify Base Name'
    await tester.tap(find.text('Modify Base Name'));
    await tester.pumpAndSettle();

    // Verify rename dialog opened
    expect(find.byType(TextField), findsOneWidget);

    // Enter new base name and tap Save
    await tester.enterText(find.byType(TextField), 'Sulfur Bunker');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify updated base name on HUD
    expect(find.text('Sulfur Bunker'), findsOneWidget);
    expect(find.text('Base 1'), findsNothing);
  });

  testWidgets('HUD card scales and fills larger window bounds without letterbox margin', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 330);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MinimalRaidApp());

    // Verify fitted box expands to fill full 480x330 window
    final fittedBoxFinder = find.byType(FittedBox);
    expect(fittedBoxFinder, findsOneWidget);
    final size = tester.getSize(fittedBoxFinder);
    expect(size.width, 480.0);
    expect(size.height, 330.0);
  });

  testWidgets('HUD renders drag handle, RepaintBoundary, and dynamic animated transitions', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalRaidApp());

    // Verify drag handle indicator is rendered
    expect(find.byIcon(Icons.drag_indicator_rounded), findsOneWidget);

    // Verify RepaintBoundary and AnimatedSwitcher isolate the counter display
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(find.byType(RepaintBoundary), findsWidgets);
    expect(find.text('1234'), findsOneWidget);

    // Dynamic advance: tap Next
    await tester.tap(find.text('Next'));
    // Pump one frame mid-transition to ensure ticker animation is active
    await tester.pump(const Duration(milliseconds: 100));
    // Settle transition
    await tester.pumpAndSettle();
    expect(find.text('1111'), findsOneWidget);

    // Dynamic step back: tap Back
    await tester.tap(find.text('Back'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('1234'), findsOneWidget);

    // Dynamic solved actuation: tap Solved
    await tester.tap(find.text('Solved'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('Theme toggle in HUD switches between Dark Mode and Light Mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalRaidApp());

    // Initially in Dark Mode: sun icon is shown to allow switching to Light Mode
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsNothing);

    // Tap theme toggle to switch to Light Mode
    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();

    // Now in Light Mode: moon icon is shown to allow switching back to Dark Mode
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_rounded), findsNothing);

    // Tap theme toggle again to switch back to Dark Mode
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsNothing);
  });

  testWidgets('Mute toggle in HUD and Settings dialog toggles sound muted state', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalRaidApp());

    // Initially sound is not muted: volume up icon is visible
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsNothing);

    // Tap mute button in HUD
    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.pumpAndSettle();

    // Now muted: volume off icon is visible
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsNothing);

    // Tap mute button again to unmute
    await tester.tap(find.byIcon(Icons.volume_off_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsNothing);
  });

  testWidgets('HUD hierarchy text shows progress from first to last and updates on next/back/solved', (WidgetTester tester) async {
    await tester.pumpWidget(const MinimalRaidApp());

    // Initial state: index 0 out of 6 -> #1 of 6 • 0 used
    expect(find.text('#1 of 6 • 0 used'), findsOneWidget);

    // Advance to index 1 -> #2 of 6 • 1 used
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('#2 of 6 • 1 used'), findsOneWidget);

    // Advance to index 2 -> #3 of 6 • 2 used
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('#3 of 6 • 2 used'), findsOneWidget);

    // Step back to index 1 -> #2 of 6 • 1 used
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('#2 of 6 • 1 used'), findsOneWidget);

    // Mark solved -> Solved at #2 of 6 • 1 used
    await tester.tap(find.text('Solved'));
    await tester.pumpAndSettle();
    expect(find.text('Solved at #2 of 6 • 1 used'), findsOneWidget);

    // Unmark solved -> #2 of 6 • 1 used
    await tester.tap(find.text('Solved ✓'));
    await tester.pumpAndSettle();
    expect(find.text('#2 of 6 • 1 used'), findsOneWidget);
  });
}
