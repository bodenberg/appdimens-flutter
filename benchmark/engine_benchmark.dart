// ignore_for_file: avoid_print

import 'package:appdimens/appdimens.dart';

void main() {
  const iterations = 1000000;
  const viewport = AppDimensViewport(width: 1440, height: 900);
  const scale = AppDimensScale(
    16,
    strategy: AppDimensStrategy.balanced,
  );
  var checksum = 0.0;
  final watch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    checksum += scale.calculateViewport(viewport);
  }
  watch.stop();
  final nanoseconds = watch.elapsedMicroseconds * 1000 / iterations;
  print('balanced: ${nanoseconds.toStringAsFixed(2)} ns/op');
  print('checksum: $checksum');
}
