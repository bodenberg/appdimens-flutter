/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// BenchLab benchmark models — converted from the KMP/Dynamic
/// `benchmark/BenchmarkModels.kt`.
library;

/// Phases of the BenchLab pipeline.
enum BenchPhase {
  idle('Idle', 0.0),
  warmup('Warm-up', 0.15),
  composeApi('Benchmark A — UI probe', 0.45),
  coreEngine('Benchmark B — engine (isolate)', 0.7),
  legacy('Legacy T1/T2/T3', 0.9),
  done('Done', 1.0);

  const BenchPhase(this.label, this.progress);
  final String label;
  final double progress;
}

/// Median/min/P90/max statistics in ns-per-op.
class TimingStats {
  final double medianNs;
  final double minNs;
  final double p90Ns;
  final double maxNs;

  const TimingStats({
    required this.medianNs,
    required this.minNs,
    required this.p90Ns,
    required this.maxNs,
  });

  static TimingStats fromSamples(List<double> samplesNsPerOp) {
    final sorted = [...samplesNsPerOp]..sort();
    double at(int i) => sorted[i.clamp(0, sorted.length - 1)];
    return TimingStats(
      medianNs: at(sorted.length ~/ 2),
      minNs: sorted.isEmpty ? 0 : sorted.first,
      p90Ns: at((sorted.length * 0.9).floor()),
      maxNs: sorted.isEmpty ? 0 : sorted.last,
    );
  }
}

/// Per-library timing for one workload.
class LibraryTiming {
  final TimingStats constant1dp;
  final TimingStats mixedValues;
  final double constantChecksum;

  const LibraryTiming({
    required this.constant1dp,
    required this.mixedValues,
    required this.constantChecksum,
  });
}

/// Benchmark A result (UI-thread chunked probe).
class ComposeApiResult {
  final LibraryTiming appdimens;
  final LibraryTiming legacyModel;
  final LibraryTiming naiveModel;

  const ComposeApiResult({
    required this.appdimens,
    required this.legacyModel,
    required this.naiveModel,
  });
}

/// Benchmark B result (isolate engine probe).
class CoreEngineResult {
  final LibraryTiming appdimens;
  final LibraryTiming legacyModel;

  const CoreEngineResult({required this.appdimens, required this.legacyModel});
}

/// Resolution parity row (px for 1/10/100 dp).
class DpResolution3 {
  final double dp1AppDimens, dp10AppDimens, dp100AppDimens;
  final double dp1Legacy, dp10Legacy, dp100Legacy;
  final double dp1Naive, dp10Naive, dp100Naive;

  const DpResolution3({
    required this.dp1AppDimens,
    required this.dp10AppDimens,
    required this.dp100AppDimens,
    required this.dp1Legacy,
    required this.dp10Legacy,
    required this.dp100Legacy,
    required this.dp1Naive,
    required this.dp10Naive,
    required this.dp100Naive,
  });
}

/// Legacy T1/T2/T3 single-dp timing averages.
class SingleDpTiming3 {
  final double appDimensNs;
  final double legacyNs;
  final double naiveNs;

  const SingleDpTiming3({
    required this.appDimensNs,
    required this.legacyNs,
    required this.naiveNs,
  });
}

class LegacyTestResult {
  final List<SingleDpTiming3> passes;
  final double avgAppDimensNs;
  final double avgLegacyNs;
  final double avgNaiveNs;

  LegacyTestResult(this.passes)
      : avgAppDimensNs =
            passes.map((p) => p.appDimensNs).reduce((a, b) => a + b) /
                passes.length,
        avgLegacyNs = passes.map((p) => p.legacyNs).reduce((a, b) => a + b) /
            passes.length,
        avgNaiveNs = passes.map((p) => p.naiveNs).reduce((a, b) => a + b) /
            passes.length;
}

/// Aggregate result of the full pipeline.
class BenchLabResult {
  final ComposeApiResult composeApi;
  final CoreEngineResult coreEngine;
  final LegacyTestResult legacy;
  final DpResolution3 resolution;
  final double windowWidthDp;
  final double windowHeightDp;
  final double density;

  const BenchLabResult({
    required this.composeApi,
    required this.coreEngine,
    required this.legacy,
    required this.resolution,
    required this.windowWidthDp,
    required this.windowHeightDp,
    required this.density,
  });

  String formatReport() {
    final b = StringBuffer()
      ..writeln('=== AppDimens BenchLab Report ===')
      ..writeln()
      ..writeln('Window: ${windowWidthDp.toStringAsFixed(0)} × '
          '${windowHeightDp.toStringAsFixed(0)} dp @ density '
          '${density.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('— Benchmark A · UI probe (median ns/op) —')
      ..writeln('AppDimens fast lane: '
          '${composeApi.appdimens.constant1dp.medianNs.toStringAsFixed(1)}')
      ..writeln('Legacy model:        '
          '${composeApi.legacyModel.constant1dp.medianNs.toStringAsFixed(1)}')
      ..writeln('Naive recompute:     '
          '${composeApi.naiveModel.constant1dp.medianNs.toStringAsFixed(1)}')
      ..writeln()
      ..writeln('— Benchmark B · engine isolate (median ns/op) —')
      ..writeln(
          'AppDimens: ${coreEngine.appdimens.constant1dp.medianNs.toStringAsFixed(1)}')
      ..writeln(
          'Legacy:    ${coreEngine.legacyModel.constant1dp.medianNs.toStringAsFixed(1)}')
      ..writeln()
      ..writeln('— Legacy T1/T2/T3 average (ns per 1 dp call) —')
      ..writeln('AppDimens: ${legacy.avgAppDimensNs.toStringAsFixed(1)} · '
          'Legacy model: ${legacy.avgLegacyNs.toStringAsFixed(1)} · '
          'Naive: ${legacy.avgNaiveNs.toStringAsFixed(1)}')
      ..writeln()
      ..writeln('— Resolution parity (px, 1 / 10 / 100 dp) —')
      ..writeln('AppDimens: ${resolution.dp1AppDimens.toStringAsFixed(4)} / '
          '${resolution.dp10AppDimens.toStringAsFixed(4)} / '
          '${resolution.dp100AppDimens.toStringAsFixed(4)}')
      ..writeln('Legacy:    ${resolution.dp1Legacy.toStringAsFixed(4)} / '
          '${resolution.dp10Legacy.toStringAsFixed(4)} / '
          '${resolution.dp100Legacy.toStringAsFixed(4)}')
      ..writeln('Naive:     ${resolution.dp1Naive.toStringAsFixed(4)} / '
          '${resolution.dp10Naive.toStringAsFixed(4)} / '
          '${resolution.dp100Naive.toStringAsFixed(4)}');
    return b.toString();
  }
}

extension FormatNs on double {
  String get formatNs {
    if (this >= 1e6) return '${(this / 1e6).toStringAsFixed(2)} ms';
    if (this >= 1e3) return '${(this / 1e3).toStringAsFixed(2)} µs';
    return '${toStringAsFixed(1)} ns';
  }
}
