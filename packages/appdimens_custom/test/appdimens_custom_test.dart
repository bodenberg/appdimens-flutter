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
        ScalingRule(ScreenCondition(landscape: true),
            const ScalingPatch(multiplier: 0.8),
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
      expect(
          () => ScalingStrategyJson.parse(
              '{"strategies":[{"id":"x","rules":[{"when":{"width":600},'
              '"set":{"multiplier":2}}]}]}',
              (_) => null),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              contains('must be an object'))));
    });

    test('ignoreMultiWindow skips formulas in multi-window', () {
      final configs = ScalingStrategyJson.parse(
          '{"id":"mw","ignoreMultiWindow":true,"formula":"base * 3"}',
          (_) => null).configs;
      final s = ScalingStrategy('mw', configs['mw']!);
      final multi = ScreenSnapshot(
          widthDp: 411,
          heightDp: 891,
          smallestWidthDp: 411,
          density: 2.625,
          isMultiWindow: true);
      final r = s.resolveScreen(multi);
      expect(r.multiWindowIgnored, isTrue);
      expect(r.scale(16), 16);
      expect(s.resolveScreen(_phone).scale(16), 48);
    });

    test('malformed JSON fails loudly and load is atomic', () {
      Matcher fails(String text) => throwsA(isA<FormatException>()
          .having((e) => e.message, 'message', contains(text)));
      expect(
          () => ScalingStrategies.loadJson(
              '{"strategies":[{"id":"x","rules":[{"when":"tablet",'
              '"set":{"multiplier":2}}]}]}'),
          fails('when must be an object'));
      expect(
          () => ScalingStrategies.loadJson(
              '{"strategies":[{"id":"x","ignoreMultiWindow":"true"}]}'),
          fails('must be a boolean'));
      expect(
          () => ScalingStrategies.loadJson(
              '{"strategies":[{"id":"x","clamp":1.5}]}'),
          fails('clamp must be an object'));
      expect(
          () => ScalingStrategy.define('neg', register: false, maxValue: -1),
          throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
              contains('maxValue must be >= 0'))));
      expect(
          () => ScalingStrategies.loadJson(
              '{"default":"missing","strategies":[{"id":"atomic","multiplier":2}]}'),
          throwsA(isA<ArgumentError>().having(
              (e) => e.message, 'message', contains('missing'))));
      expect(ScalingStrategies.get('atomic'), isNull);
      // withAxis is cached per source instance, not per id.
      final a = ScalingStrategy.define('same', register: false, multiplier: 1);
      final b = ScalingStrategy.define('same', register: false, multiplier: 2);
      expect(a.withAxis(ScalingAxis.height).config.multiplier, 1);
      expect(b.withAxis(ScalingAxis.height).config.multiplier, 2);
      expect(b.withAxis(ScalingAxis.height),
          same(b.withAxis(ScalingAxis.height)));
      // A sensitivity-only rule patch survives export + import.
      final s = ScalingStrategies.loadJson(
          '{"strategies":[{"id":"sens","aspectRatio":true,"rules":[{"when":'
          '{"device":"tablet"},"set":{"sensitivity":0.01}}]}]}')['sens']!;
      final again = ScalingStrategies.loadJson(
          jsonEncode({'strategies': [s.toJson()]}))['sens']!;
      expect(again.resolveScreen(_tablet).factor,
          s.resolveScreen(_tablet).factor);
      expect(s.resolveScreen(_tablet).factor,
          isNot(ScalingStrategy.define('noSens', register: false,
                  aspectRatio: true)
              .resolveScreen(_tablet)
              .factor));
    });

    test('ScreenCondition freezes its device set', () {
      final devices = {DeviceClass.phone};
      final c = ScreenCondition(devices: devices);
      devices.add(DeviceClass.tablet);
      expect(c.devices, {DeviceClass.phone});
      expect(() => c.devices!.add(DeviceClass.tv), throwsUnsupportedError);
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

  group('free-form expressions', () {
    double ev(String src, [ScreenSnapshot? screen]) =>
        ScalingExpression.parse(src).evaluate(expressionVariables(
            screen ?? _phone, 1.5, 411, 300, ReferenceScreen.standard,
            base: 16, scaled: 20, factor: 1.25));

    test('operators, functions and variables', () {
      const cases = {
        '1 + 2 * 3': 7.0,
        '(1 + 2) * 3': 9.0,
        '2 ^ 3 ^ 2': 512.0,
        '-2 ^ 2': -4.0,
        '-7 % 3': -1.0,
        '1 < 2 && 2 <= 2 && !(3 == 4) && 3 != 4': 1.0,
        '0 || 5': 1.0,
        '0 ? 2 : 1 ? 3 : 4': 3.0,
        'true && !false': 1.0,
        '1.5e3': 1500.0,
        'min(3, 1, 2) + max(3, 1, 2)': 4.0,
        'clamp(5, 0, 2)': 2.0,
        'round(2.5) + round(-2.5)': 1.0,
        'smoothstep(0, 10, 5)': 0.5,
        'step(1, 1) + lerp(10, 20, 0.5)': 16.0,
        'sw': 411.0,
        'phone && portrait && !landscape && !tablet': 1.0,
        'base + scaled + ratio': 37.5,
      };
      cases.forEach((src, expected) =>
          expect(ev(src), closeTo(expected, 1e-9), reason: src));
    });

    test('parse errors are descriptive', () {
      const cases = {
        'sw +': 'unexpected end',
        'foo * 2': "unknown variable 'foo'",
        'wave(1)': "unknown function 'wave'",
        'clamp(1, 2)': "'clamp' takes 3",
        '(1 + 2': "expected ')'",
        '1 ? 2': "expected ':'",
        '': 'empty',
      };
      cases.forEach((src, message) => expect(
          () => ScalingExpression.parse(src),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains(message)))));
      expect(() => ScalingCurve.expression('base'), throwsFormatException);
    });

    test('curve is factor-only, formula is value-dependent', () {
      final curve = ScalingStrategy.define('e',
          curve: ScalingCurve.expression('pow(ratio, 0.75)'), register: false);
      expect(curve.isValueDependent, isFalse);
      expect(curve.resolveScreen(_tablet).factor,
          closeTo(BuiltInStrategies.power.resolveScreen(_tablet).factor, 1e-9));
      final free = ScalingStrategy.define('f',
          formula: 'base * pow(sw / 360, 0.7) + 2', register: false);
      expect(free.isValueDependent, isTrue);
      expect(free.resolveScreen(_tablet).scale(16),
          closeTo(16 * math.pow(800 / 360, 0.7) + 2, 1e-9));
      final bad = ScalingStrategy.define('b',
          curve: ScalingCurve.expression('1 / (sw - sw)'), register: false);
      expect(() => bad.resolveScreen(_phone), throwsStateError);
    });

    test('JSON round trip, null clears, errors carry the path', () {
      final loaded = ScalingStrategies.loadJson(jsonEncode([
        {
          'id': 'a',
          'curve': {
            'type': 'expression',
            'expression': 'ratio * (tablet ? 0.9 : 1)'
          },
          'formula': 'max(scaled, 12)',
        },
        {'id': 'b', 'extends': 'a', 'formula': null},
      ]));
      final a = loaded['a']!;
      final back = ScalingStrategy('a',
          ScalingStrategyJson.parse(a.toJson(), (_) => null).configs['a']!);
      expect(back.resolveScreen(_tablet).scale(4),
          closeTo(a.resolveScreen(_tablet).scale(4), 1e-9));
      expect(a.resolveScreen(_phone).scale(1), 12);
      expect(loaded['b']!.isValueDependent, isFalse);
      expect(
          () => ScalingStrategyJson.parse(
              '{"id":"x","curve":{"type":"expression","expression":"base"}}',
              (_) => null),
          throwsA(isA<FormatException>().having(
              (e) => e.message,
              'message',
              allOf(contains('x.curve.expression'),
                  contains("unknown variable 'base'")))));
    });
  });

  group('scaling formula', () {
    test('text formula is the final value', () {
      final s = scalingFormula('base * pow(sw / 360, 0.8)');
      expect(s.resolveScreen(_phone).scale(16),
          16 * math.pow(411 / 360, 0.8).toDouble());
      expect(scalingFormula('base + 2').resolveScreen(_phone).scale(16), 18);
      expect(scalingFormula('base * ratio').resolveScreen(_phone).scale(16),
          closeTo(16 * 411 / 300, 1e-9)); // ratio = sw / 300, like sdp
      expect(
          scalingFormula('base * (tablet ? 0.9 : 1)')
              .resolveScreen(_tablet)
              .scale(16),
          closeTo(16 * 0.9, 1e-12));
    });

    test('proportional formula: fast path matches the slow path bit for bit',
        () {
      for (final src in [
        'base',
        'base * pow(sw / 360, 0.8)',
        '(sw / 360) * base',
        'base * (tablet ? 0.9 : 1.1)',
      ]) {
        final fast = scalingFormula(src);
        expect(fast.isValueDependent, isFalse, reason: src);
        // Same text, but not proportional (`+ 0` forces the per-value path).
        final slow = scalingFormula('$src + 0');
        expect(slow.isValueDependent, isTrue, reason: src);
        for (final screen in [_phone, _tablet]) {
          for (final base in [1.0, 16.0, 48.0, -8.0, 0.5]) {
            expect(fast.resolveScreen(screen).scale(base),
                slow.resolveScreen(screen).scale(base),
                reason: '$src x $base');
          }
        }
      }
      // Reads the value inside E → not proportional.
      expect(scalingFormula('base * min(base, 20)').isValueDependent, isTrue);
      expect(scalingFormula('max(base * sw / 360, base)').isValueDependent,
          isTrue);
      // `(base * sw) / 360` is evaluated as written (per value).
      expect(scalingFormula('base * sw / 360').isValueDependent, isTrue);
    });

    test('proportional formula inside define and JSON is screen-only too', () {
      final defined = ScalingStrategy.define('p',
          formula: 'base * (sw / 360)', register: false);
      expect(defined.isValueDependent, isFalse);
      final json = ScalingStrategies.loadJson(
          '{"strategies":[{"id":"j","formula":"base * 1.1"}]}')['j']!;
      expect(json.isValueDependent, isFalse);
      expect(json.resolveScreen(_phone).scale(16), closeTo(16 * 1.1, 1e-12));
      expect(
          ScalingStrategy.define('v', formula: 'round(scaled)', register: false)
              .isValueDependent,
          isTrue);
      expect(defined.resolveScreen(_phone).explain('p'),
          contains('then formula(base * (sw / 360))'));
    });

    test('text formula is shared per text unless an id is given', () {
      expect(scalingFormula('base * 2'), same(scalingFormula('base * 2')));
      expect(ScalingStrategies.formula('base * 2'),
          same(scalingFormula('base * 2')));
      expect(scalingFormula('base * 2').id, 'formula:base * 2');
      expect(ScalingStrategies.get('formula:base * 2'), isNull);
      final named = scalingFormula('base * 2', id: 'double');
      expect(named, isNot(same(scalingFormula('base * 2'))));
      expect(ScalingStrategies.get('double'), same(named)); // id registers
    });

    test('code formula has no limits', () {
      final s = scalingFormulaOf(
          (s) => s.base * s.pow(s.sw / 360, 0.8) + (s.landscape ? 2 : 0));
      expect(s.resolveScreen(_phone).scale(16),
          closeTo(16 * math.pow(411 / 360, 0.8), 1e-9));
      expect(s.resolveScreen(_tablet).scale(16),
          closeTo(16 * math.pow(800 / 360, 0.8) + 2, 1e-9));
      expect(s.isValueDependent, isTrue);
      expect(s.id, startsWith('formula#'));
      expect(scalingFormulaOf((s) => s.base).id, isNot(s.id));
      expect(() => s.toJson(), throwsStateError);
      final named = scalingFormulaOf((s) => s.base * 3, id: 'hud');
      expect(ScalingStrategies.get('hud'), same(named));
      expect(named.resolveScreen(_phone).explain('hud'),
          contains('then transform'));
    });

    test('programmable factor is screen-only and multiplies every value', () {
      final product =
          customScaleStrategy((s) => s.clamp(s.width / 360, 0.85, 1.80));
      expect(product.isValueDependent, isFalse);
      expect(product.resolveScreen(_phone).factor, closeTo(411 / 360, 1e-12));
      expect(product.resolveScreen(_tablet).factor, 1.8); // 1280 / 360 clamped
      expect(product.resolveScreen(_phone).scale(16),
          closeTo(16 * 411 / 360, 1e-9));
      expect(product.id, startsWith('scale#'));
      final named = customScaleStrategy((_) => 1.25, id: 'product');
      expect(ScalingStrategies.get('product'), same(named));
      expect(named.resolveScreen(_phone).scale(16), 20);
      expect(
          () => customScaleStrategy((_) => double.nan).resolveScreen(_phone),
          throwsA(isA<StateError>().having(
              (e) => e.message, 'message', contains('non-finite'))));
    });

    test('code scope matches the text language', () {
      final pairs = <(ScalingStrategy, String)>[
        (
          scalingFormulaOf((s) => s.base * s.pow(s.sw / 360, 0.8)),
          'base * pow(sw / 360, 0.8)'
        ),
        (scalingFormulaOf((s) => s.base * s.ratio), 'base * ratio'),
        (
          scalingFormulaOf((s) =>
              s.base * (s.tablet ? 0.9 : 1) * s.clamp(s.width / 360, 0.85, 1.6)),
          'base * (tablet ? 0.9 : 1) * clamp(width / 360, 0.85, 1.6)'
        ),
        (
          scalingFormulaOf((s) => s.round(s.base * s.lerp(1, s.aspectRatio, 0.1))),
          'round(base * lerp(1, aspectRatio, 0.1))'
        ),
        (
          scalingFormulaOf((s) =>
              s.base * s.smoothstep(300, 900, s.longSide) + s.sqrt(s.diagonal)),
          'base * smoothstep(300, 900, longSide) + sqrt(diagonal)'
        ),
      ];
      for (final (code, text) in pairs) {
        final fromText = scalingFormula(text);
        for (final screen in [_phone, _tablet]) {
          for (final base in [1.0, 16.0, 48.0]) {
            expect(code.resolveScreen(screen).scale(base),
                closeTo(fromText.resolveScreen(screen).scale(base), 1e-4),
                reason: text);
          }
        }
      }
      final tvScreen = ScreenSnapshot(
          widthDp: 960,
          heightDp: 540,
          smallestWidthDp: 540,
          density: 2,
          isLandscape: true,
          device: DeviceClass.tv);
      final factor =
          customScaleStrategy((s) => s.tv ? s.height / 540 : s.ratio);
      expect(factor.resolveScreen(tvScreen).factor, 1);
      expect(factor.resolveScreen(_phone).factor, closeTo(411 / 300, 1e-12));
    });

    test('text formula errors are reported early', () {
      expect(
          () => scalingFormula('base * sww'),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              contains("unknown variable 'sww'"))));
    });

    test('font scale is followed for text', () {
      final big = ScreenSnapshot(
          widthDp: 411, heightDp: 891, smallestWidthDp: 411, fontScale: 1.5);
      expect(scalingFormula('base * 2').resolveScreen(big).scaleSpDp(16),
          closeTo(16 * 2 * 1.5, 1e-9));
    });

    test('num and context helpers take the formula text', () {
      AppDimensScope.publish(_metrics(411, 891));
      expect(16.cdpFormula('base * (sw / 360)'),
          scalingFormula('base * (sw / 360)').dp(16));
      expect(16.cdpFormula('base * (sw / 360)'), closeTo(16 * 411 / 360, 1e-9));
      expect(14.cspFormula('base * 2'), scalingFormula('base * 2').sp(14));
      expect(8.cdpPxFormula('base'), scalingFormula('base').px(8));
      expect(8.cspPxFormula('base'), scalingFormula('base').spPx(8));
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
