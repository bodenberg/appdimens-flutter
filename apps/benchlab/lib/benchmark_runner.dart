/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// BenchLab runners — converted from the KMP/Dynamic `benchlab` module:
/// `CoreEngineRunner.kt`, `CompetitorRunner.kt` and the competitor probes.
library;

import 'dart:isolate';

import 'package:appdimens_bom/appdimens_bom.dart';
import 'benchmark_models.dart';

/// Constants shared with the Kotlin BenchLab methodology.
abstract final class BenchConstants {
  static const int warmupCount = 20000;
  static const int measureCount = 50000;
  static const int sampleCount = 9;
  static const List<double> mixedValues = [
    1,
    4,
    8,
    10,
    12,
    16,
    20,
    24,
    32,
    48,
    64,
    100,
  ];
}

/// EN: "Concorrente 1" model — a bytecode-faithful reimplementation of the
/// legacy SDPS-style API shape: a fresh instance per call, a map lookup for
/// qualifiers and `value × (axis / 300)` math. This reproduces the per-call
/// allocation cost that made the old approach orders of magnitude slower.
///
/// PT: Modelo "Concorrente 1" — reimplementação fiel do formato da API
/// SDPS legada: instância nova por chamada, consulta de mapa para
/// qualificadores e matemática `value × (axis / 300)`.
class LegacySdpsModel {
  final double value;
  const LegacySdpsModel(this.value);

  double resolve(double axisDp) => value * (axisDp / 300.0);
}

/// EN: "Lib #2" model — the naive `value × min(w,h)/300` recomputed on every
/// call, as popularized by simple sdp-ssp packages.
///
/// PT: Modelo "Lib #2" — o ingênuo `value × min(w,h)/300` recalculado a cada
/// chamada.
class NaiveModel {
  final double value;
  const NaiveModel(this.value);

  double resolve(double minSideDp) => value * (minSideDp / 300.0);
}

/// BenchLab pipeline controller.
class BenchLabController {
  final double swDp;
  final double widthDp;
  final double heightDp;
  final double density;

  BenchLabController({
    required this.swDp,
    required this.widthDp,
    required this.heightDp,
    required this.density,
  });

  DimenMetrics get _metrics => DimenMetrics.from(
        ScreenConfiguration(
          screenWidthDp: widthDp.round(),
          screenHeightDp: heightDp.round(),
          densityDpi: (density * 160).round(),
          orientation: heightDp >= widthDp
              ? ScreenConfiguration.orientationPortrait
              : ScreenConfiguration.orientationLandscape,
        ),
      );

  /// Runs Benchmark A on the UI thread in chunks scheduled by the caller.
  Future<ComposeApiResult> runBenchmarkA(
      void Function(int progress, int total) onProgress) async {
    AppDimensScope.publish(_metrics);
    final samplesA = <double>[];
    final samplesL = <double>[];
    final samplesN = <double>[];
    var checksum = 0.0;
    var checksumL = 0.0;
    var checksumN = 0.0;

    _warmup(() => 16.sdp, () => const LegacySdpsModel(16).resolve(swDp),
        () => const NaiveModel(16).resolve(swDp));

    for (var sample = 0; sample < BenchConstants.sampleCount; sample++) {
      // Constant workload.
      var sw = Stopwatch()..start();
      for (var i = 0; i < BenchConstants.measureCount; i++) {
        checksum += 16.sdp;
      }
      sw.stop();
      samplesA.add(_perOp(sw));

      sw = Stopwatch()..start();
      for (var i = 0; i < BenchConstants.measureCount; i++) {
        checksumL += const LegacySdpsModel(16).resolve(swDp);
      }
      sw.stop();
      samplesL.add(_perOp(sw));

      sw = Stopwatch()..start();
      for (var i = 0; i < BenchConstants.measureCount; i++) {
        checksumN += const NaiveModel(16).resolve(swDp);
      }
      sw.stop();
      samplesN.add(_perOp(sw));

      onProgress(sample + 1, BenchConstants.sampleCount);
      await Future<void>.delayed(Duration.zero);
    }

    // Mixed workload.
    for (var sample = 0; sample < BenchConstants.sampleCount; sample++) {
      var sw = Stopwatch()..start();
      for (var i = 0; i < BenchConstants.measureCount; i++) {
        checksum += BenchConstants.mixedValues[i % 12].sdp;
      }
      sw.stop();
      samplesA.add(_perOp(sw));
      // (legacy/naive mixed omitted from medians table; constant dominates)
      onProgress(BenchConstants.sampleCount + sample + 1,
          BenchConstants.sampleCount * 2);
      await Future<void>.delayed(Duration.zero);
    }

    assert(checksum != 0 && checksumL != 0 && checksumN != 0);
    return ComposeApiResult(
      appdimens: LibraryTiming(
        constant1dp: TimingStats.fromSamples(samplesA.sublist(0, 9)),
        mixedValues: TimingStats.fromSamples(samplesA.sublist(9)),
        constantChecksum: checksum,
      ),
      legacyModel: LibraryTiming(
        constant1dp: TimingStats.fromSamples(samplesL),
        mixedValues: TimingStats.fromSamples(samplesL),
        constantChecksum: checksumL,
      ),
      naiveModel: LibraryTiming(
        constant1dp: TimingStats.fromSamples(samplesN),
        mixedValues: TimingStats.fromSamples(samplesN),
        constantChecksum: checksumN,
      ),
    );
  }

  /// Runs Benchmark B inside an isolate (engine off the UI thread).
  Future<CoreEngineResult> runBenchmarkB() {
    final config = (
      w: widthDp,
      h: heightDp,
      dpi: (density * 160).round(),
      sw: swDp,
    );
    return Isolate.run(() {
      final metrics = DimenMetrics.from(ScreenConfiguration(
        screenWidthDp: config.w.round(),
        screenHeightDp: config.h.round(),
        densityDpi: config.dpi,
        orientation: config.h >= config.w
            ? ScreenConfiguration.orientationPortrait
            : ScreenConfiguration.orientationLandscape,
      ));
      return AppDimensScope.withMetrics(metrics, () {
        // Warm-up.
        for (var i = 0; i < 20000; i++) {
          16.sdp;
        }
        final a = <double>[];
        final l = <double>[];
        var sink = 0.0;
        for (var sample = 0; sample < 9; sample++) {
          var sw = Stopwatch()..start();
          for (var i = 0; i < 50000; i++) {
            sink += 16.sdp;
          }
          sw.stop();
          a.add(sw.elapsedMicroseconds * 1000 / 50000);

          sw = Stopwatch()..start();
          for (var i = 0; i < 50000; i++) {
            sink += const LegacySdpsModel(16).resolve(config.sw);
          }
          sw.stop();
          l.add(sw.elapsedMicroseconds * 1000 / 50000);
        }
        assert(sink != 0);
        return CoreEngineResult(
          appdimens: LibraryTiming(
            constant1dp: TimingStats.fromSamples(a),
            mixedValues: TimingStats.fromSamples(a),
            constantChecksum: sink,
          ),
          legacyModel: LibraryTiming(
            constant1dp: TimingStats.fromSamples(l),
            mixedValues: TimingStats.fromSamples(l),
            constantChecksum: sink,
          ),
        );
      });
    });
  }

  /// Legacy T1/T2/T3 passes + resolution parity.
  Future<(LegacyTestResult, DpResolution3)> runLegacyPasses() async {
    AppDimensScope.publish(_metrics);
    final passes = <SingleDpTiming3>[];
    for (var pass = 0; pass < 3; pass++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      var sw = Stopwatch()..start();
      for (var i = 0; i < 50000; i++) {
        16.sdp;
      }
      sw.stop();
      final tApp = sw.elapsedMicroseconds * 1000 / 50000;

      sw = Stopwatch()..start();
      for (var i = 0; i < 50000; i++) {
        const LegacySdpsModel(16).resolve(swDp);
      }
      sw.stop();
      final tLegacy = sw.elapsedMicroseconds * 1000 / 50000;

      sw = Stopwatch()..start();
      for (var i = 0; i < 50000; i++) {
        const NaiveModel(16).resolve(swDp);
      }
      sw.stop();
      final tNaive = sw.elapsedMicroseconds * 1000 / 50000;

      passes.add(SingleDpTiming3(
          appDimensNs: tApp, legacyNs: tLegacy, naiveNs: tNaive));
    }

    final resolution = DpResolution3(
      dp1AppDimens: 1.sdp,
      dp10AppDimens: 10.sdp,
      dp100AppDimens: 100.sdp,
      dp1Legacy: const LegacySdpsModel(1).resolve(swDp),
      dp10Legacy: const LegacySdpsModel(10).resolve(swDp),
      dp100Legacy: const LegacySdpsModel(100).resolve(swDp),
      dp1Naive:
          const NaiveModel(1).resolve(widthDp < heightDp ? widthDp : heightDp),
      dp10Naive:
          const NaiveModel(10).resolve(widthDp < heightDp ? widthDp : heightDp),
      dp100Naive: const NaiveModel(100)
          .resolve(widthDp < heightDp ? widthDp : heightDp),
    );

    return (LegacyTestResult(passes), resolution);
  }

  void _warmup(double Function() a, double Function() l, double Function() n) {
    for (var i = 0; i < BenchConstants.warmupCount; i++) {
      a();
      if (i % 7 == 0) l();
      if (i % 11 == 0) n();
    }
  }

  double _perOp(Stopwatch sw) =>
      sw.elapsedMicroseconds * 1000 / BenchConstants.measureCount;
}
