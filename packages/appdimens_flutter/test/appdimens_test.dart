import 'package:flutter_test/flutter_test.dart';
import 'package:appdimens_flutter/appdimens.dart';

import 'reference_vectors.dart';

const _phone = FakeAppDimensContext(
  configuration: ScreenConfiguration(
    screenWidthDp: 392,
    screenHeightDp: 832,
    densityDpi: 440,
    orientation: ScreenConfiguration.orientationPortrait,
  ),
  density: 2.75,
  xdpi: 440,
);

const _base = FakeAppDimensContext();

DimenMetrics _phoneMetrics() => DimenMetrics.from(
      const ScreenConfiguration(
        screenWidthDp: 392,
        screenHeightDp: 832,
        densityDpi: 440,
        orientation: ScreenConfiguration.orientationPortrait,
      ),
    );

void main() {
  setUp(() {
    AppDimensScope.clear();
    DimenCache.clear();
    DimenCache.isEnabled = true;
  });

  group('parity — explicit-context kernels', () {
    test('matches independently computed reference vectors', () {
      expect(16.sdpOf(_phone), closeTo(kReferenceVectors['sdp_phone']!, 1e-9));
      expect(
          16.sdpaOf(_phone), closeTo(kReferenceVectors['sdpa_phone']!, 1e-9));
      expect(16.hdpOf(_phone), closeTo(kReferenceVectors['hdp_phone']!, 1e-9));
      expect(16.wdpOf(_phone), closeTo(kReferenceVectors['wdp_phone']!, 1e-9));
      expect(
          16.sdpPxOf(_phone), closeTo(kReferenceVectors['sdpPx_phone']!, 1e-6));
      expect(16.sdpOf(_base),
          closeTo(kReferenceVectors['sdp_baseline_exact']!, 1e-6));
      expect(
          16.hdpOf(_base), closeTo(kReferenceVectors['hdp_baseline']!, 1e-9));
    });

    test('baseline preservation: sw=300 keeps values exact', () {
      for (final v in [1, 4, 10, 16, 48, 100]) {
        expect(v.sdpOf(_base), closeTo(v.toDouble(), 1e-5), reason: 'sdp($v)');
        expect(v.sspOf(_base), closeTo(v.toDouble(), 1e-5), reason: 'ssp($v)');
      }
    });
  });

  group('parity — scope fast lane', () {
    test('scope getters match reference vectors', () {
      AppDimensScope.withMetrics(_phoneMetrics(), () {
        expect(16.sdp, closeTo(kReferenceVectors['sdp_phone']!, 1e-9));
        expect(16.sdpa, closeTo(kReferenceVectors['sdpa_phone']!, 1e-9));
        expect(16.hdp, closeTo(kReferenceVectors['hdp_phone']!, 1e-9));
        expect(16.wdp, closeTo(kReferenceVectors['wdp_phone']!, 1e-9));
        expect(16.sdpPx, closeTo(kReferenceVectors['sdpPx_phone']!, 1e-6));
        // Inverter: portrait phone → Ph swaps SW to height.
        expect(16.sdpPh, closeTo(kReferenceVectors['sdpPh_portrait']!, 1e-9));
        expect(16.wdpPh, closeTo(kReferenceVectors['wdpPh_portrait']!, 1e-9));
        // sp family follows the same dp curve.
        expect(16.ssp, closeTo(kReferenceVectors['ssp_value']!, 1e-9));
        expect(16.sem, closeTo(kReferenceVectors['sem_no_fs']!, 1e-9));
      });
    });

    test('fast lane equals full engine path (bitwise closeness)', () {
      final m = _phoneMetrics();
      AppDimensScope.withMetrics(m, () {
        final fast = 16.sdp;
        final full = 16.toDynamicScaledDp(_phone, DpQualifier.smallWidth);
        expect(fast, full);
      });
    });
  });

  group('multi-window suppression', () {
    test('sdpi returns raw base inside multi-window', () {
      final m = DimenMetrics.from(
        const ScreenConfiguration(
          screenWidthDp: 200,
          screenHeightDp: 400,
          densityDpi: 440,
          orientation: ScreenConfiguration.orientationPortrait,
        ),
        isInMultiWindowMode: true,
      );
      AppDimensScope.withMetrics(m, () {
        expect(16.sdpi, 16.0);
        expect(16.sdpia, 16.0);
        expect(16.sdp, closeTo(16 * 200 * DimenCache.invBaseRatio, 1e-9));
      });
    });
  });

  group('facilitators & plain branching', () {
    test('rotate picks the branch by orientation', () {
      AppDimensScope.withMetrics(_phoneMetrics(), () {
        // Portrait phone: landscape request does not match → base branch.
        final r = 50.sdpRotate(70);
        expect(r, closeTo(50 * 392 * DimenCache.invBaseRatio, 1e-9));
        // Plain variant returns the chosen token unscaled.
        expect(50.sdpRotatePlain(70), 50.0);
        expect(50.sdpRotatePlain(70, orientation: OrientationRequest.portrait),
            70.0);
      });
    });

    test('mode/qualifier/screen facilitators', () {
      AppDimensScope.withMetrics(_phoneMetrics(), () {
        expect(30.sdpModePlain(60, UiModeType.television), 30.0);
        AppDimensScope.publishUiModeType(UiModeType.television);
        expect(30.sdpModePlain(60, UiModeType.television), 60.0);
        // qualifier: sw=392 ≥ 360
        expect(30.sdpQualifierPlain(60, DpQualifier.smallWidth, 360), 60.0);
        expect(30.sdpQualifierPlain(60, DpQualifier.smallWidth, 999), 30.0);
        expect(
            30.sdpScreenPlain(
                60, UiModeType.television, DpQualifier.smallWidth, 360),
            60.0);
      });
    });
  });

  group('DimenScaled builder', () {
    test('priority resolution and terminal scaling', () {
      final chain = DimenSdp.scaled(100)
          .withIgnoreMultiWindows()
          .screen(UiModeType.television, DpQualifier.smallWidth, 600, 250)
          .screenMode(UiModeType.television, 500)
          .screenQualifier(DpQualifier.smallWidth, 600, 150)
          .screenOrientation(OrientationRequest.landscape, 120);

      // Phone portrait, sw 392 ≥ 600? No. TV? No. Landscape? No → base.
      expect(chain.resolve(_phone),
          closeTo(100 * 392 * DimenCache.invBaseRatio, 1e-9));

      // TV with sw ≥ 600 wins priority 1.
      const tv = FakeAppDimensContext(
        configuration: ScreenConfiguration(
          screenWidthDp: 960,
          screenHeightDp: 540,
          smallestScreenWidthDp: 540,
          densityDpi: 320,
          orientation: ScreenConfiguration.orientationLandscape,
        ),
        density: 2.0,
        uiModeType: UiModeType.television,
      );
      AppDimensScope.publishUiModeType(UiModeType.television);
      expect(
          chain.resolve(tv), closeTo(500 * 540 * DimenCache.invBaseRatio, 1e-6),
          reason: 'sw 540 < 600 so P1 misses; P2 (ui-mode) wins with 500');
    });
  });

  group('cache coherence', () {
    test('partitioned per snapshot and bypassed on default path', () {
      final before = DimenCache.stats();
      AppDimensScope.withMetrics(_phoneMetrics(), () {
        // Default sdp bypasses the hash (raw multiply).
        16.sdp;
        final afterBypass = DimenCache.stats();
        expect(afterBypass.populated, before.populated);
      });
    });

    test('memoized families register hits through getOrPutFor', () {
      final m = _phoneMetrics();
      final key = CacheKey(
        baseValue: 16,
        isLandscape: false,
        ignoreMultiWindows: false,
        calcType: CalcType.auto,
        qualifier: DpQualifier.smallWidth,
        inverter: Inverter.standard,
        applyAspectRatio: false,
        valueType: ValueType.dp,
      );
      DimenCache.resetDiagnostics();
      DimenCache.getOrPutFor(m, key, () => 42.0);
      final second = DimenCache.getOrPutFor(m, key, () => 0.0);
      final stats = DimenCache.stats();
      expect(second, 42.0);
      expect(stats.hits, greaterThanOrEqualTo(1));
    });

    test('invalidateOnConfigChange drops the matching partition only', () {
      final other = DimenMetrics.from(const ScreenConfiguration(
        screenWidthDp: 800,
        screenHeightDp: 1280,
        densityDpi: 320,
      ));
      DimenCache.invalidateOnConfigChange(other.configuration);
      expect(DimenCache.fallbackMetrics, DimenMetrics.baseline);
    });
  });

  group('resize math', () {
    test('step table is monotonic and ends at max', () {
      final steps = ResizeMath.buildResizeStepsPx(10, 20, 2);
      expect(steps, orderedEquals([10, 12, 14, 16, 18, 20]));
    });

    test('largest fitting search returns 0 when nothing fits', () {
      final steps = ResizeMath.buildResizeStepsPx(10, 20, 2);
      expect(ResizeMath.findLargestFittingResizePx(steps, (_) => false), 0.0);
      expect(
        ResizeMath.findLargestFittingResizePx(steps, (v) => v <= 15),
        14.0,
      );
    });
  });

  group('metrics snapshot', () {
    test('derived factors are stable and guarded', () {
      final m = _phoneMetrics();
      expect(m.smallestWidthDp, 392.0);
      expect(m.scale, closeTo(392 * DimenCache.invBaseRatio, 1e-9));
      expect(m.isPortrait, isTrue);
      expect(m.normalizedAspectRatio, closeTo((832 / 392) / 1.78, 1e-12));
      expect(m.density, 2.75);
    });

    test('degenerate configurations fall back safely', () {
      final m = DimenMetrics.from(const ScreenConfiguration(
        screenWidthDp: 0,
        screenHeightDp: 0,
        densityDpi: 0,
      ));
      expect(m.smallestWidthDp, DesignScaleConstants.baseWidthDp);
      expect(m.density, 1.0);
      expect(m.normalizedAspectRatio, closeTo(1.0 / 1.78, 1e-12),
          reason: 'degenerate raw AR (1.0) still divides by the reference');
    });
  });
}
