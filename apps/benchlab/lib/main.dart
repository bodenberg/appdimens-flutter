/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// BenchLab — competitor benchmark dashboard, converted from the KMP/Dynamic
/// `BenchlabActivity.kt`.
library;

import 'package:appdimens_bom/appdimens_bom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'benchmark_models.dart';
import 'benchmark_runner.dart';

void main() => runApp(const BenchLabApp());

class BenchLabApp extends StatelessWidget {
  const BenchLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppDimens BenchLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const BenchlabScreen(),
    );
  }
}

class BenchlabScreen extends StatefulWidget {
  const BenchlabScreen({super.key});

  @override
  State<BenchlabScreen> createState() => _BenchlabScreenState();
}

class _BenchlabScreenState extends State<BenchlabScreen> {
  BenchPhase _phase = BenchPhase.idle;
  double _progress = 0;
  ComposeApiResult? _composeApi;
  CoreEngineResult? _coreEngine;
  LegacyTestResult? _legacy;
  DpResolution3? _resolution;
  String _report = '';

  late BenchLabController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final dpr = view.devicePixelRatio;
    final size = view.physicalSize / dpr;
    _controller = BenchLabController(
      swDp: size.width < size.height ? size.width : size.height,
      widthDp: size.width,
      heightDp: size.height,
      density: dpr,
    );
  }

  Future<void> _runFull() async {
    setState(() {
      _phase = BenchPhase.warmup;
      _progress = 0;
      _composeApi = null;
      _coreEngine = null;
      _legacy = null;
      _resolution = null;
    });

    setState(() => _phase = BenchPhase.composeApi);
    _composeApi = await _controller.runBenchmarkA((p, total) {
      setState(() =>
          _progress = BenchPhase.composeApi.progress * (p / total));
    });
    setState(() => _progress = BenchPhase.coreEngine.progress);

    setState(() => _phase = BenchPhase.coreEngine);
    _coreEngine = await _controller.runBenchmarkB();
    setState(() => _progress = BenchPhase.legacy.progress);

    setState(() => _phase = BenchPhase.legacy);
    final (legacy, resolution) = await _controller.runLegacyPasses();
    _legacy = legacy;
    _resolution = resolution;

    setState(() {
      _phase = BenchPhase.done;
      _progress = 1;
      _report = _buildResult().formatReport();
    });
  }

  BenchLabResult _buildResult() {
    return BenchLabResult(
      composeApi: _composeApi!,
      coreEngine: _coreEngine!,
      legacy: _legacy!,
      resolution: _resolution!,
      windowWidthDp: _controller.widthDp,
      windowHeightDp: _controller.heightDp,
      density: _controller.density,
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return Scaffold(
      appBar: AppBar(title: const Text('AppDimens BenchLab')),
      body: Container(
        color: const Color(0xFF0D0F14),
        child: ListView(
          padding: EdgeInsets.all(16.sdp),
          children: [
            _deviceCard(size, view.devicePixelRatio),
            SizedBox(height: 12.sdp),
            _actionPanel(),
            SizedBox(height: 8.sdp),
            _statusPanel(),
            _methodologyCard(),
            if (_composeApi != null) _composeSection(),
            if (_coreEngine != null) _engineSection(),
            if (_legacy != null && _resolution != null) _legacySections(),
            if (_report.isNotEmpty)
              Card(
                color: const Color(0xFF161B24),
                child: Padding(
                  padding: EdgeInsets.all(12.sdp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Report',
                              style: TextStyle(
                                  fontSize: 14.ssp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent)),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: _report)),
                          ),
                        ],
                      ),
                      SelectableText(_report,
                          style:
                              TextStyle(fontSize: 11.ssp, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _deviceCard(Size size, double dpr) {
    return Card(
      color: const Color(0xFF161B24),
      child: Padding(
        padding: EdgeInsets.all(12.sdp),
        child: Text(
          'Window ${size.width.toStringAsFixed(0)} × '
          '${size.height.toStringAsFixed(0)} dp · density ${dpr.toStringAsFixed(2)} · '
          'sw ${(size.width < size.height ? size.width : size.height).toStringAsFixed(0)} dp',
          style: TextStyle(fontSize: 13.ssp),
        ),
      ),
    );
  }

  Widget _actionPanel() {
    return FilledButton.icon(
      icon: _phase == BenchPhase.done || _phase == BenchPhase.idle
          ? const Icon(Icons.play_arrow)
          : SizedBox(
              width: 16.sdp,
              height: 16.sdp,
              child: const CircularProgressIndicator(strokeWidth: 2)),
      label: const Text('Rodar benchmark completo'),
      onPressed: (_phase == BenchPhase.idle ||
              _phase == BenchPhase.done ||
              _phase == BenchPhase.warmup)
          ? _runFull
          : null,
    );
  }

  Widget _statusPanel() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sdp),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 10.sdp,
              height: 10.sdp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _phase == BenchPhase.idle ? Colors.grey : Colors.cyanAccent,
              ),
            ),
            SizedBox(width: 8.sdp),
            Expanded(child: Text(_phase.label, style: TextStyle(fontSize: 13.ssp))),
          ]),
          SizedBox(height: 6.sdp),
          LinearProgressIndicator(value: _progress, minHeight: 5.sdp),
        ],
      ),
    );
  }

  Widget _methodologyCard() {
    return Card(
      color: const Color(0xFF161B24),
      margin: EdgeInsets.only(bottom: 12.sdp),
      child: Padding(
        padding: EdgeInsets.all(12.sdp),
        child: Text(
          'Metodologia — Benchmark A roda na UI thread em amostras de '
          '${BenchConstants.measureCount} chamadas (9 amostras por workload, '
          '${BenchConstants.warmupCount} aquecimentos); a mediana das amostras é o número '
          'divulgado. Benchmark B replica a metodologia fora da thread de UI '
          '(isolate). Checksums anti-DCE garantem que os compiladores não '
          'eliminem as chamadas. T1/T2/T3 repetem três passes com resoluções '
          'de 1/10/100 dp.',
          style: TextStyle(fontSize: 12.ssp, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _statCells(TimingStats s) {
    String f(double v) => v.formatNs;
    return Wrap(
      spacing: 10.sdp,
      runSpacing: 4.sdp,
      children: [
        _cell('Mediana', f(s.medianNs)),
        _cell('Min', f(s.minNs)),
        _cell('P90', f(s.p90Ns)),
        _cell('Max', f(s.maxNs)),
      ],
    );
  }

  Widget _cell(String k, String v) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sdp, vertical: 4.sdp),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6.sdp),
        ),
        child: Text('$k $v',
            style: TextStyle(fontSize: 11.ssp, fontFamily: 'monospace')),
      );

  Widget _libBlock(String title, LibraryTiming t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13.ssp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.sdp),
          _statCells(t.constant1dp),
        ],
      ),
    );
  }

  Widget _ratioLine(String label, double a, double b) {
    final ratio = b / a;
    return Container(
      margin: EdgeInsets.only(bottom: 6.sdp),
      padding: EdgeInsets.all(8.sdp),
      decoration: BoxDecoration(
        color: (ratio >= 1 ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.sdp),
      ),
      child: Text(
        ratio >= 1
            ? '⚡ AppDimens é ×${ratio.toStringAsFixed(1)} mais rápido que $label'
            : '🐢 AppDimens está ×${(1 / ratio).toStringAsFixed(2)} mais lento que $label',
        style: TextStyle(fontSize: 13.ssp),
      ),
    );
  }

  Widget _composeSection() {
    return Card(
      color: const Color(0xFF161B24),
      margin: EdgeInsets.only(bottom: 12.sdp),
      child: Padding(
        padding: EdgeInsets.all(12.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Benchmark A — UI probe'),
            _libBlock('AppDimens fast lane', _composeApi!.appdimens),
            _libBlock('Concorrente 1 (modelo SDPS legado)',
                _composeApi!.legacyModel),
            _libBlock('Lib #2 (recomputo ingênuo)', _composeApi!.naiveModel),
            _ratioLine('o modelo legado', _composeApi!.appdimens.constant1dp.medianNs,
                _composeApi!.legacyModel.constant1dp.medianNs),
            _ratioLine('o recomputo ingênuo', _composeApi!.appdimens.constant1dp.medianNs,
                _composeApi!.naiveModel.constant1dp.medianNs),
          ],
        ),
      ),
    );
  }

  Widget _engineSection() {
    return Card(
      color: const Color(0xFF161B24),
      margin: EdgeInsets.only(bottom: 12.sdp),
      child: Padding(
        padding: EdgeInsets.all(12.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Benchmark B — engine (isolate)'),
            _libBlock('AppDimens', _coreEngine!.appdimens),
            _libBlock('Concorrente 1 (legado)', _coreEngine!.legacyModel),
            _ratioLine('o modelo legado (off-main)', _coreEngine!.appdimens.constant1dp.medianNs,
                _coreEngine!.legacyModel.constant1dp.medianNs),
          ],
        ),
      ),
    );
  }

  Widget _legacySections() {
    final r = _resolution!;
    Widget row(String lib, double a, double b, double c) => Padding(
          padding: EdgeInsets.symmetric(vertical: 2.sdp),
          child: Text('$lib: ${a.toStringAsFixed(3)} / '
              '${b.toStringAsFixed(3)} / ${c.toStringAsFixed(3)} px',
              style: TextStyle(fontSize: 12.ssp, fontFamily: 'monospace')),
        );

    return Column(
      children: [
        Card(
          color: const Color(0xFF161B24),
          margin: EdgeInsets.only(bottom: 12.sdp),
          child: Padding(
            padding: EdgeInsets.all(12.sdp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('Resolução — 1 / 10 / 100 dp'),
                row('AppDimens', r.dp1AppDimens, r.dp10AppDimens, r.dp100AppDimens),
                row('Legado', r.dp1Legacy, r.dp10Legacy, r.dp100Legacy),
                row('Ingênuo', r.dp1Naive, r.dp10Naive, r.dp100Naive),
              ],
            ),
          ),
        ),
        Card(
          color: const Color(0xFF161B24),
          margin: EdgeInsets.only(bottom: 12.sdp),
          child: Padding(
            padding: EdgeInsets.all(12.sdp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('T1 / T2 / T3 — média por passada (1 dp)'),
                ..._legacy!.passes.mapIndexed((i, p) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.sdp),
                      child: Text(
                        'T${i + 1}: AppDimens ${p.appDimensNs.formatNs} · '
                        'Legado ${p.legacyNs.formatNs} · Ingênuo ${p.naiveNs.formatNs}',
                        style: TextStyle(fontSize: 12.ssp),
                      ),
                    )),
                SizedBox(height: 6.sdp),
                _ratioLine('a média do modelo legado', _legacy!.avgAppDimensNs,
                    _legacy!.avgLegacyNs),
                _ratioLine('a média do recomputo', _legacy!.avgAppDimensNs,
                    _legacy!.avgNaiveNs),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget sectionTitle(String text) => Padding(
      padding: EdgeInsets.only(bottom: 8.sdp),
      child: Text(text,
          style: TextStyle(
              fontSize: 14.ssp,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent)),
    );

extension MapIndexedX<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int, T) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
