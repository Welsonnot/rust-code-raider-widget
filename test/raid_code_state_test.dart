import 'package:flutter_test/flutter_test.dart';
import 'package:rust_code_raid_counter/models/raid_code_state.dart';

void main() {
  group('RaidCodeState Tests', () {
    test('Initial state has code 1234 at index 0', () {
      final state = RaidCodeState();
      expect(state.currentIndex, 0);
      expect(state.currentTargetCode, '1234');
      expect(state.currentInput, '');
      expect(state.isError, false);
      expect(state.isCompleted, false);
    });

    test('nextCode() steps through 1234 -> 1111 -> 0000 -> Completed', () {
      final state = RaidCodeState();
      expect(state.currentTargetCode, '1234');

      state.nextCode();
      expect(state.currentIndex, 1);
      expect(state.currentTargetCode, '1111');

      state.nextCode();
      expect(state.currentIndex, 2);
      expect(state.currentTargetCode, '0000');

      state.nextCode();
      expect(state.isCompleted, true);

      // Next again loops back to start
      state.nextCode();
      expect(state.currentIndex, 0);
      expect(state.currentTargetCode, '1234');
      expect(state.isCompleted, false);
    });

    test('previousCode() steps back correctly', () {
      final state = RaidCodeState();
      state.nextCode(); // at 1111
      state.nextCode(); // at 0000
      expect(state.currentIndex, 2);

      state.previousCode();
      expect(state.currentIndex, 1);
      expect(state.currentTargetCode, '1111');

      state.previousCode();
      expect(state.currentIndex, 0);
      expect(state.currentTargetCode, '1234');

      // Cannot step back before 0
      state.previousCode();
      expect(state.currentIndex, 0);
    });

    test('Typing non-numeric keys is ignored', () {
      final state = RaidCodeState();
      expect(state.addDigit('a'), isNull);
      expect(state.addDigit('!'), isNull);
      expect(state.addDigit(' '), isNull);
      expect(state.currentInput, '');
    });

    test('Wrong code triggers error and increments wrong attempts', () {
      final state = RaidCodeState();
      state.addDigit('1');
      state.addDigit('2');
      state.addDigit('3');
      final result = state.addDigit('5');

      expect(result, false);
      expect(state.isError, true);
      expect(state.errorMessage, contains('WRONG CODE'));
      expect(state.wrongAttempts, 1);
      expect(state.totalAttempts, 1);
      expect(state.currentIndex, 0);

      // Next keypress clears error and starts fresh
      state.addDigit('1');
      expect(state.isError, false);
      expect(state.currentInput, '1');
    });

    test('Full sequence via addDigit: 1234 -> 1111 -> 0000 -> Completed', () {
      final state = RaidCodeState();

      // Step 1: 1234
      state.addDigit('1');
      state.addDigit('2');
      state.addDigit('3');
      final res1 = state.addDigit('4');
      expect(res1, true);

      // Step 2: 1111
      state.addDigit('1');
      state.addDigit('1');
      state.addDigit('1');
      final res2 = state.addDigit('1');
      expect(res2, true);

      // Step 3: 0000
      state.addDigit('0');
      state.addDigit('0');
      state.addDigit('0');
      final res3 = state.addDigit('0');
      expect(res3, true);

      expect(state.isCompleted, true);
    });

    test('Reset returns to step 1 (1234)', () {
      final state = RaidCodeState();
      state.nextCode();
      expect(state.currentIndex, 1);

      state.reset();
      expect(state.currentIndex, 0);
      expect(state.currentTargetCode, '1234');
      expect(state.totalAttempts, 0);
    });
  });
}
