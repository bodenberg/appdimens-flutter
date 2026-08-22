import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:appdimens_bom/appdimens_bom.dart';

/// Engine performance audit — mirrors the BenchLab methodology (warm-up +
/// 9 samples × 50k ops, median). All workloads are array-driven so the JIT
/// cannot constant-fold either side; the naive competitor also pays a fresh
/// snapshot construction per call (what hand-rolled scaling does when it
/// reads MediaQuery every time).
void main() {
  test('engine performance audit', () async {
    const config = ScreenConfiguration(
      screenWidthDp: 392,
      screenHeightDp: 832,
      densityDpi: 440,
      orientation: ScreenConfiguration.orientationPortrait,
    );

    final result = await Isolate.run(() {
      final metrics = DimenMetrics.from(config);
      return AppDimensScope.withMetrics(metrics, () {
        const ops = 50000;
        final bases =
            List<double>.generate(64, (i) => ((i % 32) + 1).toDouble());

        double bench(double Function(int index) body,
            {bool warmup = true}) {
          if (warmup) {
            for (var i = 0; i < 20000; i++) {
              body(i & 63);
            }
          }
          final samples = <double>[];
          var sink = 0.0;
          for (var s = 0; s < 9; s++) {
            final sw = Stopwatch()..start();
            for (var i = 0; i < ops; i++) {
              sink += body(i & 63);
            }
            sw.stop();
            samples.add(sw.elapsedMicroseconds * 1000 / ops);
          }
          samples.sort();
          if (sink.isNaN || sink == -1.0) throw StateError('sink');
          return samples[samples.length ~/ 2];
        }

        final out = <String, double>{};
        out['harness_baseline'] = bench((i) => bases[i] * 0.0, warmup: false);
        out['sdp'] = bench((i) => bases[i].sdp);
        out['sdpa'] = bench((i) => bases[i].sdpa);
        out['hdp'] = bench((i) => bases[i].hdp);
        out['ssp'] = bench((i) => bases[i].ssp);
        // Optimized monomorphic satellite stems.
        out['psdp'] = bench((i) => bases[i].psdp);
        out['pwsdp'] = bench((i) => bases[i].pwsdp);
        out['fsdp'] = bench((i) => bases[i].fsdp);
        out['asdp'] = bench((i) => bases[i].asdp);
        out['logsdp'] = bench((i) => bases[i].logsdp);
        out['dgsdp'] = bench((i) => bases[i].dgsdp);
        out['prsdp'] = bench((i) => bases[i].prsdp);
        out['ftsdp'] = bench((i) => bases[i].ftsdp);
        out['flsdp'] = bench((i) => bases[i].flsdp);
        out['dsdp'] = bench((i) => bases[i].dsdp);
        out['legacy_model'] =
            bench((i) => LegacyBenchModel(bases[i]).resolve(392.0));
        // Honest naive: reads/rebuilds the configuration snapshot every call.
        out['naive_rebuild'] = bench((i) {
          final m = DimenMetrics.from(config);
          return bases[i] * m.scale;
        });
        return out;
      });
    });

    final baseline = result['harness_baseline']!;
    // ignore: avoid_print
    print('────── AppDimens engine audit (median ns/op) ──────');
    for (final e in result.entries) {
      // ignore: avoid_print
      print('${e.key.padRight(18)} ${e.value.toStringAsFixed(2)}');
    }

    expect(result['sdp']! - baseline,
        lessThan(result['naive_rebuild']! - baseline),
        reason: 'fast lane must beat rebuilding the snapshot per call');
    expect(result['sdp']!, lessThan(1000),
        reason: 'absolute sanity bound for the fast lane');
  }, timeout: const Timeout(Duration(seconds: 90)));
}

/// Bytecode-faithful legacy model (fresh instance per call).
class LegacyBenchModel {
  final double value;
  const LegacyBenchModel(this.value);
  double resolve(double axis) => value * (axis / 300.0);
}
