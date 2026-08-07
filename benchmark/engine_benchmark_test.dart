// ignore_for_file: avoid_print

import 'package:appdimens/appdimens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('balanced strategy hot path benchmark', () {
    const iterations = 1000000;
    const viewport = AppDimensViewport(width: 1440, height: 900);
    final scale = AppDimensScale(16, strategy: AppDimensStrategy.balanced);
    var checksum = 0.0;
    final watch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      checksum += scale.calculateViewport(viewport);
    }
    watch.stop();
    final nanoseconds = watch.elapsedMicroseconds * 1000 / iterations;
    print('balanced: ${nanoseconds.toStringAsFixed(2)} ns/op');
    expect(checksum, greaterThan(0));
  });
}
