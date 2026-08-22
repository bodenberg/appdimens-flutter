/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// AppDimens Sample — converted from the AppDimens KMP / Dynamic sample app.
///
/// Demonstrates: strategy routing (12 curves), core extensions, orientation
/// inverters, facilitators + Plain branching, the DimenScaled builder chain,
/// auto-resize widgets and the performance dashboard.
library;

import 'package:appdimens_bom/appdimens_bom.dart';
import 'package:flutter/material.dart';

import 'benchmark_screen.dart';
import 'demo_routing.dart';

void main() => runApp(const SampleApp());

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDimensApp(
      child: MaterialApp(
        title: 'AppDimens Sample',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  DemoCalcStrategy _strategy = DemoCalcStrategy.scaled;

  @override
  Widget build(BuildContext context) {
    return DemoCalcScope(
      strategy: _strategy,
      onStrategyChanged: (s) => setState(() => _strategy = s),
      child: Scaffold(
        appBar: AppBar(
          title: Text('AppDimens SDP Demo', style: TextStyle(fontSize: 18.ssp)),
          actions: [
            StrategyPicker(
              value: _strategy,
              onChanged: (s) => setState(() => _strategy = s),
            ),
          ],
        ),
        body: AppDimensReactiveBuilder(
          builder: (context) => ListView(
            padding: EdgeInsets.all(16.sdp),
            children: [
              _header(context),
              SizedBox(height: 16.sdp),
              _sectionTitle('1. Core extensions (sdp · sdpa · hdp · wdp)'),
              _coreCards(),
              SizedBox(height: 16.sdp),
              _sectionTitle('2. Orientation inverters (Ph · Lw · Lh)'),
              _inverterCards(),
              SizedBox(height: 16.sdp),
              _sectionTitle(
                  '3. Facilitators (Rotate · Mode · Qualifier · Screen + Plain)'),
              _facilitatorCards(),
              SizedBox(height: 16.sdp),
              _sectionTitle('4. DimenScaled builder chain'),
              const BuilderCard(),
              SizedBox(height: 16.sdp),
              _sectionTitle('5. Auto-resize (constraint fitting)'),
              const AutoResizeCard(),
              SizedBox(height: 16.sdp),
              FilledButton.icon(
                icon: const Icon(Icons.speed),
                label: const Text('Run Performance Benchmark'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BenchmarkScreen()),
                ),
              ),
              SizedBox(height: 32.sdp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Responsive dimensions on every screen',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20.ssp)),
            SizedBox(height: 8.hdp),
            Text(
              'Every size on this page resolves through the AppDimens fast lane '
              '(one snapshot read + one multiply). Switch the strategy above to '
              're-route the whole page through a different curve — exactly like '
              'the KMP/Dynamic DemoCalcRouting layer.\n\n'
              'Cada tamanho desta página resolve pela faixa rápida do AppDimens. '
              'Troque a estratégia acima para re-rotear a página inteira.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14.ssp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: EdgeInsets.only(bottom: 8.sdp),
        child: Text(title,
            style: TextStyle(fontSize: 15.ssp, fontWeight: FontWeight.w700)),
      );

  Widget _coreCards() {
    return Column(
      children: [
        _demoBox('60.demoSwDp → ${60.demoSwDp.toStringAsFixed(1)}', 60.demoSwDp,
            Colors.lightBlue),
        _demoBox('60.demoSwDpa (+AR) → ${60.demoSwDpa.toStringAsFixed(1)}',
            60.demoSwDpa, Colors.indigo),
        _demoBox('80.demoHdp → ${80.demoHdp.toStringAsFixed(1)}', 80.demoHdp,
            Colors.teal),
        _demoBox('100.demoWdp → ${100.demoWdp.toStringAsFixed(1)}', 100.demoWdp,
            Colors.deepPurple),
      ],
    );
  }

  Widget _inverterCards() {
    return Column(
      children: [
        _demoBox('70.demoSwPh → ${70.demoSwPh.toStringAsFixed(1)}', 70.demoSwPh,
            Colors.orange),
        _demoBox('70.demoSwLw → ${70.demoSwLw.toStringAsFixed(1)}', 70.demoSwLw,
            Colors.pink),
        _demoBox('80.demoHLw → ${80.demoHLw.toStringAsFixed(1)}', 80.demoHLw,
            Colors.brown),
        _demoBox('90.demoWLh → ${90.demoWLh.toStringAsFixed(1)}', 90.demoWLh,
            Colors.blueGrey),
      ],
    );
  }

  Widget _facilitatorCards() {
    return Column(
      children: [
        _demoBox(
            'demoSdpRotate(50) → ${50.demoSdpRotate(70).toStringAsFixed(1)}',
            50.demoSdpRotate(70),
            Colors.cyan),
        _demoBox(
            'demoSdpMode(200, TV) → ${40.demoSdpMode(90, UiModeType.television).toStringAsFixed(1)}',
            40.demoSdpMode(90, UiModeType.television),
            Colors.green),
        _demoBox(
            'demoSdpQualifier(120, sw≥600) → ${30.demoSdpQualifier(60, DpQualifier.smallWidth, 600).toStringAsFixed(1)}',
            30.demoSdpQualifier(60, DpQualifier.smallWidth, 600),
            Colors.amber),
        _demoBox(
            'Plain chain → ${30.demoSdpRotatePlain(44).toStringAsFixed(1)}',
            30.demoSdpRotatePlain(44),
            Colors.deepOrange),
      ],
    );
  }

  Widget _demoBox(String label, double size, Color color) {
    final s = size.clamp(28, 220).toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sdp),
      child: Row(
        children: [
          Container(
            width: s,
            height: s * 0.5,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              border: Border.all(color: color, width: 1.5.sdp),
              borderRadius: BorderRadius.circular(8.sdp),
            ),
            alignment: Alignment.center,
            child: Text(size.toStringAsFixed(0),
                style: TextStyle(fontSize: (s * 0.22).clamp(9, 28).toDouble())),
          ),
          SizedBox(width: 12.sdp),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.ssp)),
          ),
        ],
      ),
    );
  }
}

class BuilderCard extends StatelessWidget {
  const BuilderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final resolved = 100
        .scaledDp
        .screen(UiModeType.television, DpQualifier.smallWidth, 600, 250)
        .screenMode(UiModeType.television, 500)
        .screenQualifier(DpQualifier.smallWidth, 600, 150)
        .screenOrientation(OrientationRequest.landscape, 120);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '100.scaledDp'
              '\n  .screen(TV + sw≥600 → 250)'
              '\n  .screenMode(TV → 500)'
              '\n  .screenQualifier(sw≥600 → 150)'
              '\n  .screenOrientation(landscape → 120)',
              style: TextStyle(fontSize: 12.ssp, fontFamily: 'monospace'),
            ),
            SizedBox(height: 12.sdp),
            Text('Resolved now: ${resolved.sdp.toStringAsFixed(2)} dp',
                style:
                    TextStyle(fontSize: 16.ssp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class AutoResizeCard extends StatelessWidget {
  const AutoResizeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoResizeText(
              'Headline that must fit',
              minSp: 10,
              maxSp: 28,
              stepSp: 1,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.sdp),
            AutoResizeSquare(
              min: 40,
              max: 120,
              step: 4,
              child: ColoredBox(
                color: Colors.lightBlue.withValues(alpha: 0.2),
                child: Center(child: Icon(Icons.aspect_ratio, size: 40.wdp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StrategyPicker extends StatelessWidget {
  final DemoCalcStrategy value;
  final ValueChanged<DemoCalcStrategy> onChanged;

  const StrategyPicker(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // EN: Adaptive — collapses to an icon-only trigger when the AppBar
    // trailing slot gets too narrow (e.g. small web windows), so the scaled
    // label never overflows the toolbar.
    //
    // PT: Adaptativo — colapsa para um gatilho só de ícone quando o slot
    // trailing do AppBar fica estreito demais (ex.: janelas web pequenas),
    // evitando que o rótulo escalado transborde a barra.
    return PopupMenuButton<DemoCalcStrategy>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final s in DemoCalcStrategy.values)
          PopupMenuItem(value: s, child: Text(s.labelEn)),
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 120.wdp;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.wdp, vertical: 8.sdp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 18.wsp),
              if (wide) ...[
                SizedBox(width: 6.sdp),
                Flexible(
                  child: Text(value.labelEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.ssp)),
                ),
              ],
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      }),
    );
  }
}
