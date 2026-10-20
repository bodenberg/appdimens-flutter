import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:appdimens_custom/appdimens_custom.dart';
import 'package:appdimens_flutter/appdimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _phone = ScreenSnapshot(
    widthDp: 411, heightDp: 891, smallestWidthDp: 411, density: 2.625);
final _tablet = ScreenSnapshot(
    widthDp: 1280, heightDp: 800, smallestWidthDp: 800, density: 2);

DimenMetrics _metrics(int w, int h, {double fontScale = 1, int uiMode = 1}) =>
    DimenMetrics.from(
      ScreenConfiguration(
        screenWidthDp: w,
        screenHeightDp: h,
        smallestScreenWidthDp: math.min(w, h),
        densityDpi: 420,
        fontScale: fontScale,
        orientation: w > h
            ? ScreenConfiguration.orientationLandscape
            : ScreenConfiguration.orientationPortrait,
        uiMode: uiMode,
      ),
    );

void main() {
  setUp(() {
    ScalingStrategies.resetForTest();
    AppDimensScope.clear();
  });

  group('engine', () {
    test('built-ins match the built-in formulas', () {
      for (final s in [_phone, _tablet]) {
        final sw = s.smallestWidthDp;
        expect(BuiltInStrategies.scaled.resolveScreen(s).factor,
            closeTo(sw / 300, 1e-12));
        expect(BuiltInStrategies.power.resolveScreen(s).factor,
            closeTo(math.pow(sw / 300, 0.75), 1e-12));
        expect(BuiltInStrategies.logarithmic.resolveScreen(s).factor,
            closeTo(1 + 0.4 * math.log(sw / 300), 1e-12));
        expect(BuiltInStrategies.interpolated.resolveScreen(s).factor,
            closeTo(1 + (sw / 300 - 1) * 0.5, 1e-12));
        expect(BuiltInStrategies.perimeter.resolveScreen(s).factor,
            closeTo((s.minDp + s.maxDp) / 833, 1e-12));
      }
    });

    test('built-ins match the core snapshot factors', () {
      final m = _metrics(411, 891);
      expect(BuiltInStrategies.power.factor(m), closeTo(m.powerScale, 1e-6));
      expect(BuiltInStrategies.interpolated.factor(m),
          closeTo(m.interpolatedScale, 1e-6));
      expect(BuiltInStrategies.logarithmic.factor(m),
          closeTo(m.logarithmicScale, 1e-5));
      expect(
          BuiltInStrategies.diagonal.factor(m), closeTo(m.diagonalScale, 1e-5));
      expect(BuiltInStrategies.perimeter.factor(m),
          closeTo(m.perimeterScale, 1e-6));
    });

    test('rules apply in order and later wins; clamps and font scale', () {
      final s = ScalingStrategy.define('r', register: false, rules: [
        ScalingRule.on({DeviceClass.tablet},
            ScalingPatch(curve: ScalingCurve.power(0.5), multiplier: 0.9),
            name: 'tab'),
        const ScalingRule(
            ScreenCondition(landscape: true), ScalingPatch(multiplier: 0.8),
            name: 'land'),
      ]);
      final r = s.resolveScreen(_tablet);
      expect(r.appliedRules, ['tab', 'land']);
      expect(r.factor, closeTo(math.pow(800 / 300, 0.5) * 0.8, 1e-12));
      final c = ScalingStrategy.define('c',
          register: false,
          minValue: 4,
          maxValue: 20,
          fontScale: FontScalePolicy.clamp(1.3));
      expect(c.resolveScreen(_phone).scale(100), 20);
      expect(c.resolveScreen(_phone).scale(-100), -20);
      expect(c.resolveScreen(_phone).scale(0), 0);
      final big = ScreenSnapshot(widthDp: 411, heightDp: 891, fontScale: 2);
      expect(c.resolveScreen(big).scaleSpDp(10),
          closeTo(10 * (411 / 300) * 1.3, 1e-9));
      expect(c.resolveScreen(big).scaleSpUnits(10),
          closeTo(10 * (411 / 300) * 1.3 / 2, 1e-9));
    });

    test('invalid configs are rejected', () {
      expect(() => ScalingStrategy.define('x', minFactor: 2, maxFactor: 1),
          throwsArgumentError);
      expect(() => ReferenceScreen(width: 0), throwsArgumentError);
      expect(() => ScalingStrategy.define(' '), throwsArgumentError);
    });
  });

  group('JSON', () {
    test('load, extends, default and round trip', () {
      final loaded = ScalingStrategies.loadJson(jsonEncode({
        'version': 1,
        'default': 'brand',
        'strategies': [
          {
            'id': 'brand',
            'extends': 'tabletFriendly',
            'curve': {'type': 'power', 'exponent': 0.8}
          },
          {
            'id': 'text',
            'extends': 'brand',
            'fontScale': 'ignore',
            'valueClamp': {'min': 10}
          },
        ],
      }));
      expect(ScalingStrategies.defaultStrategy, same(loaded['brand']));
      expect(loaded['text']!.config.rules, hasLength(1));
      expect(loaded['text']!.isValueDependent, isTrue);
      for (final s in [
        ...CustomPresets.all,
        ...BuiltInStrategies.all,
        ...loaded.values
      ]) {
        final back =
            ScalingStrategyJson.parse(s.toJson(), (_) => null).configs[s.id]!;
        expect(ScalingStrategy(s.id, back).resolveScreen(_tablet).factor,
            s.resolveScreen(_tablet).factor,
            reason: s.id);
      }
    });

    test('errors are descriptive', () {
      expect(
          () => ScalingStrategyJson.parse(
              '[{"id":"a","extends":"b"},{"id":"b","extends":"a"}]',
              (_) => null),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('Cyclic'))));
      expect(
          () => ScalingStrategyJson.parse(
              '{"id":"a","curve":{"type":"wave"}}', (_) => null),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains("type 'wave'"))));
      expect(
          () => ScalingStrategyJson.parse('{"id":"a",}', (_) => null),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('Invalid JSON'))));
      expect(
          () => ScalingStrategies.getOrThrow('missing'), throwsArgumentError);
    });

    test('cross-platform fixture (Kotlin reference engine)', () {
      final fixture = jsonDecode(
              File('test/custom-strategy-fixture.json').readAsStringSync())
          as Map<String, dynamic>;
      final tol = (fixture['tolerance'] as num).toDouble();
      final configs = ScalingStrategyJson.parse(fixture['document'] as Object,
          (id) => ScalingStrategies.get(id)?.config).configs;
      final screens = (fixture['screens'] as Map<String, dynamic>).map((k, v) {
        final s = v as Map<String, dynamic>;
        return MapEntry(
            k,
            ScreenSnapshot(
              widthDp: (s['width'] as num).toDouble(),
              heightDp: (s['height'] as num).toDouble(),
              smallestWidthDp: (s['smallestWidth'] as num).toDouble(),
              density: (s['density'] as num).toDouble(),
              fontScale: (s['fontScale'] as num).toDouble(),
              isLandscape: s['landscape'] as bool,
              isMultiWindow: s['multiWindow'] as bool,
              device: DeviceClass.fromJson(s['device'] as String),
            ));
      });
      final cases = fixture['cases'] as List;
      expect(cases.length, greaterThan(100));
      for (final c in cases.cast<Map<String, dynamic>>()) {
        final r =
            ScalingStrategy(c['strategy'] as String, configs[c['strategy']]!)
                .resolveScreen(screens[c['screen']]!);
        final base = (c['base'] as num).toDouble();
        final label = '${c['strategy']}@${c['screen']}x$base';
        double t(Object e) => tol * math.max(1, (e as num).abs());
        expect(
            r.factor, closeTo((c['factor'] as num).toDouble(), t(c['factor'])),
            reason: label);
        expect(r.scale(base), closeTo((c['dp'] as num).toDouble(), t(c['dp'])),
            reason: label);
        expect(r.scaleSpDp(base),
            closeTo((c['spDp'] as num).toDouble(), t(c['spDp'])),
            reason: label);
        expect(r.appliedRules, List<String>.from(c['rules'] as List),
            reason: label);
      }
    });
  });

  group('Flutter binding', () {
    test('num extensions follow the scope snapshot and the default', () {
      final m = _metrics(411, 891);
      AppDimensScope.publish(m);
      expect(
          16.cdp,
          closeTo(16 * m.scale,
              1e-5)); // default = scaled = sdp (core uses the float 1/300 constant)
      final brand =
          ScalingStrategy.define('brand', curve: ScalingCurve.power(0.8));
      expect(16.cdpWith(brand), closeTo(16 * math.pow(411 / 300, 0.8), 1e-9));
      expect(16.cdpWith('brand'), 16.cdpWith(brand));
      ScalingStrategies.defaultStrategy = brand;
      expect(16.cdp, 16.cdpWith(brand));
      AppDimensScope.publish(_metrics(800, 1280));
      expect(16.cdp, closeTo(16 * math.pow(800 / 300, 0.8), 1e-9));
    });

    test('device class from UI mode and resolver', () {
      final tv = _metrics(960, 540);
      expect(
          screenSnapshotOf(tv, UiModeType.television).device, DeviceClass.tv);
      expect(
          CustomPresets.tvSafe.resolve(tv, UiModeType.television).appliedRules,
          ['tv']);
      ScalingStrategies.deviceClassResolver = (_, __) => DeviceClass.watch;
      expect(screenSnapshotOf(tv).device, DeviceClass.watch);
    });

    testWidgets('ScalingStrategyScope + context helpers', (tester) async {
      AppDimensScope.publish(_metrics(411, 891));
      final brand =
          ScalingStrategy.define('brand', curve: ScalingCurve.power(0.8));
      late double value;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ScalingStrategyScope(
          strategy: brand,
          child: Builder(builder: (context) {
            value = context.cdp(16);
            return Text('x', style: TextStyle(fontSize: context.csp(14)));
          }),
        ),
      ));
      expect(value, closeTo(16 * math.pow(411 / 300, 0.8), 1e-9));
    });

    test('extend / withAxis / explain', () {
      final soft = BuiltInStrategies.power
          .extend('soft', curve: ScalingCurve.power(0.6));
      expect(ScalingStrategies.get('soft'), same(soft));
      expect(soft.withAxis(ScalingAxis.height),
          same(soft.withAxis(ScalingAxis.height)));
      expect(soft.explain(_metrics(411, 891)), contains('[soft]'));
    });
  });
}
