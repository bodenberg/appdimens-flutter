import 'package:flutter_test/flutter_test.dart';
import 'package:appdimens_bom/appdimens_bom.dart';

import '../../appdimens_flutter/test/reference_vectors.dart';

const _phoneCfg = ScreenConfiguration(
  screenWidthDp: 392,
  screenHeightDp: 832,
  densityDpi: 440,
  orientation: ScreenConfiguration.orientationPortrait,
);

void main() {
  setUp(() {
    AppDimensScope.clear();
    DimenCache.clear();
    DimenCache.isEnabled = true;
  });

  group('satellite parity', () {
    test('all strategy stems match reference vectors', () {
      AppDimensScope.withMetrics(DimenMetrics.from(_phoneCfg), () {
        void expectVector(String key, double actual) =>
            expect(actual, closeTo(kReferenceVectors[key]!, 1e-6), reason: key);
        expectVector('percent_psdp', 16.psdp);
        expectVector('percent_phdp', 16.phdp);
        expectVector('power_pwsdp', 16.pwsdp);
        expectVector('fluid_fsdp', 16.fsdp);
        expectVector('auto_asdp', 16.asdp);
        expectVector('auto_awdp_800', 800.awdp);
        expectVector('log_logsdp', 16.logsdp);
        expectVector('interp_isdp', 16.isdp);
        expectVector('diag_dgsdp', 16.dgsdp);
        expectVector('perim_prsdp', 16.prsdp);
        expectVector('fill_flsdp', 16.flsdp);
        expectVector('fit_ftsdp', 16.ftsdp);
        expectVector('density_dsdp', 16.dsdp);
        expectVector('power_pwsdpa', 16.pwsdpa);
        expectVector('auto_asdpa', 16.asdpa);
      });
    });

    test('literal percent space family', () {
      AppDimensScope.withMetrics(DimenMetrics.from(_phoneCfg), () {
        expect(50.spaceW, closeTo(kReferenceVectors['spaceW50']!, 1e-9));
        expect(25.spaceH, closeTo(kReferenceVectors['spaceH25']!, 1e-9));
        expect(10.spaceSw, closeTo(kReferenceVectors['spaceSw10']!, 1e-9));
        expect(DimenPercent.spaceSw(-5), closeTo(-0.05 * 392, 1e-9),
            reason:
                'negative percents follow the literal formula (KMP parity)');
        expect(DimenPercent.spaceSw(double.nan), 0.0,
            reason: 'non-finite guard returns zero');
      });
    });

    test('fluid plateaus at both ends', () {
      const small = FakeAppDimensContext(
        configuration: ScreenConfiguration(
          screenWidthDp: 300,
          screenHeightDp: 600,
          densityDpi: 440,
          orientation: ScreenConfiguration.orientationPortrait,
        ),
        density: 2.75,
      );
      AppDimensScope.withMetrics(DimenMetrics.from(small.configuration), () {
        expect(100.fsdp, 80.0, reason: 'below 320 clamps to base×0.8');
      });
    });
  });

  group('units', () {
    test('25.4 mm equals 16 dp at the 160 dpi reference', () {
      const base = FakeAppDimensContext();
      expect(
        DimenPhysicalUnits.toDpFromMm(25.4, scope: base),
        kReferenceVectors['units_mm25p4_dp'],
      );
      expect(DimenPhysicalUnits.mmToCm(25.4), 2.54);
      expect(DimenPhysicalUnits.cmToInch(2.54), 1.0);
    });
  });
}
