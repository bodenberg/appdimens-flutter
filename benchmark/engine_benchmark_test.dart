// ignore_for_file: avoid_print
import 'package:appdimens/appdimens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DimensFactors hot path', () {
    const c = DimensConfiguration(screenWidth: 1440, screenHeight: 900);
    final factors = DimensFactors(c);
    var checksum = 0.0;
    const iterations = 1000000;
    final watch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      checksum += factors.resolve(16, DimensStrategy.diagonal);
    }
    watch.stop();
    print(
      'DimensFactors: ${watch.elapsedMicroseconds * 1000 / iterations} ns/op',
    );
    expect(checksum, greaterThan(0));
  });
}
