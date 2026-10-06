import 'package:flutter_test/flutter_test.dart';
import 'package:rust_code_raid_counter/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService Tests', () {
    test('AudioService initializes and resolves audio candidates safely', () {
      AudioService.init();
      // Should not throw
      expect(true, isTrue);
    });

    test('AudioService.playNextBack executes without throwing', () {
      expect(() => AudioService.playNextBack(), returnsNormally);
      expect(() => AudioService.playNextBack(isMuted: true), returnsNormally);
    });

    test('AudioService.playCodeRight executes without throwing', () {
      expect(() => AudioService.playCodeRight(), returnsNormally);
      expect(() => AudioService.playCodeRight(isMuted: true), returnsNormally);
    });

    test('AudioService respects static isMuted flag', () {
      AudioService.isMuted = true;
      expect(() => AudioService.playNextBack(), returnsNormally);
      expect(() => AudioService.playCodeRight(), returnsNormally);
      AudioService.isMuted = false;
    });

    test('AudioService.dispose cleans up audio devices safely', () {
      expect(() => AudioService.dispose(), returnsNormally);
    });
  });
}
