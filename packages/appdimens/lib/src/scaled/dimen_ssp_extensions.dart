/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Scaled strategy — `sp` families (ssp · hsp · wsp and no-font-scale
/// sem · hem · wem).
import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/orientation.dart';
import '../common/ui_mode_type.dart';
import '../core/dimen_cache.dart';
import 'dimen_sdp_extensions.dart';

double _fontScaleOf() => AppDimensScope.metricsOrDefault.fontScale;

double _densityOf() => AppDimensScope.metricsOrDefault.density;

/// EN: Scaled **sp** families on [num].
///
/// - `ssp` / `hsp` / `wsp` — scaled sp; the framework applies the system font
///   scale when rendering, exactly like Kotlin `TextUnit.sp`.
/// - `…Px` twins — rendered physical pixels (include density × fontScale).
/// - `sem` / `hem` / `wem` — "ignore system font scale": the value is divided
///   by the font scale so the framework multiplication cancels out.
///
/// The same suffix grammar of the dp family applies (`a`, `i`, `ia`,
/// `Ph/Lh/Pw/Lw`).
///
/// PT: Famílias **sp** escaladas em [num].
///
/// - `ssp` / `hsp` / `wsp` — sp escalado; o framework aplica a escala de
///   fonte do sistema ao renderizar, como o `TextUnit.sp` do Kotlin.
/// - Gêmeos `…Px` — pixels físicos renderizados (densidade × fontScale).
/// - `sem` / `hem` / `wem` — "ignora escala de fonte do sistema": o valor é
///   dividido pela escala para que a multiplicação do framework se cancele.
///
/// A mesma gramática de sufixos da família dp se aplica (`a`, `i`, `ia`,
/// `Ph/Lh/Pw/Lw`).
extension AppDimensScaledSp on num {
  // ── ssp (smallest width) ────────────────────────────────────────────────

  double get ssp => ScaledKernel.sw(toDouble(), false);
  double get sspa => ScaledKernel.swAr(toDouble(), false);
  double get sspi => ScaledKernel.sw(toDouble(), true);
  double get sspia => ScaledKernel.swAr(toDouble(), true);

  double get sspPh => ScaledKernel.inverted(toDouble(), Inverter.swToPh);
  double get sspPha =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPh, ar: true);
  double get sspPhi =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPh, mw: true);
  double get sspPhia =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPh, ar: true, mw: true);

  double get sspLh => ScaledKernel.inverted(toDouble(), Inverter.swToLh);
  double get sspLha =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLh, ar: true);
  double get sspLhi =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLh, mw: true);
  double get sspLhia =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLh, ar: true, mw: true);

  double get sspPw => ScaledKernel.inverted(toDouble(), Inverter.swToPw);
  double get sspPwa =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPw, ar: true);
  double get sspPwi =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPw, mw: true);
  double get sspPwia =>
      ScaledKernel.inverted(toDouble(), Inverter.swToPw, ar: true, mw: true);

  double get sspLw => ScaledKernel.inverted(toDouble(), Inverter.swToLw);
  double get sspLwa =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLw, ar: true);
  double get sspLwi =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLw, mw: true);
  double get sspLwia =>
      ScaledKernel.inverted(toDouble(), Inverter.swToLw, ar: true, mw: true);

  // Rendered physical pixels.
  double get sspPx => ssp * _densityOf() * _fontScaleOf();
  double get sspPhPx => sspPh * _densityOf() * _fontScaleOf();
  double get sspLhPx => sspLh * _densityOf() * _fontScaleOf();
  double get sspPwPx => sspPw * _densityOf() * _fontScaleOf();
  double get sspLwPx => sspLw * _densityOf() * _fontScaleOf();

  // ── hsp (height) ────────────────────────────────────────────────────────

  double get hsp => ScaledKernel.h(toDouble(), false);
  double get hspa => ScaledKernel.hAr(toDouble(), false);
  double get hspi => ScaledKernel.h(toDouble(), true);
  double get hspia => ScaledKernel.hAr(toDouble(), true);

  double get hspLw => ScaledKernel.inverted(toDouble(), Inverter.phToLw);
  double get hspLwa =>
      ScaledKernel.inverted(toDouble(), Inverter.phToLw, ar: true);
  double get hspLwi =>
      ScaledKernel.inverted(toDouble(), Inverter.phToLw, mw: true);
  double get hspLwia =>
      ScaledKernel.inverted(toDouble(), Inverter.phToLw, ar: true, mw: true);

  double get hspPw => ScaledKernel.inverted(toDouble(), Inverter.lhToPw);
  double get hspPwa =>
      ScaledKernel.inverted(toDouble(), Inverter.lhToPw, ar: true);
  double get hspPwi =>
      ScaledKernel.inverted(toDouble(), Inverter.lhToPw, mw: true);
  double get hspPwia =>
      ScaledKernel.inverted(toDouble(), Inverter.lhToPw, ar: true, mw: true);

  double get hspPx => hsp * _densityOf() * _fontScaleOf();
  double get hspLwPx => hspLw * _densityOf() * _fontScaleOf();
  double get hspPwPx => hspPw * _densityOf() * _fontScaleOf();

  // ── wsp (width) ─────────────────────────────────────────────────────────

  double get wsp => ScaledKernel.w(toDouble(), false);
  double get wspa => ScaledKernel.wAr(toDouble(), false);
  double get wspi => ScaledKernel.w(toDouble(), true);
  double get wspia => ScaledKernel.wAr(toDouble(), true);

  double get wspLh => ScaledKernel.inverted(toDouble(), Inverter.pwToLh);
  double get wspLha =>
      ScaledKernel.inverted(toDouble(), Inverter.pwToLh, ar: true);
  double get wspLhi =>
      ScaledKernel.inverted(toDouble(), Inverter.pwToLh, mw: true);
  double get wspLhia =>
      ScaledKernel.inverted(toDouble(), Inverter.pwToLh, ar: true, mw: true);

  double get wspPh => ScaledKernel.inverted(toDouble(), Inverter.lwToPh);
  double get wspPha =>
      ScaledKernel.inverted(toDouble(), Inverter.lwToPh, ar: true);
  double get wspPhi =>
      ScaledKernel.inverted(toDouble(), Inverter.lwToPh, mw: true);
  double get wspPhia =>
      ScaledKernel.inverted(toDouble(), Inverter.lwToPh, ar: true, mw: true);

  double get wspPx => wsp * _densityOf() * _fontScaleOf();
  double get wspLhPx => wspLh * _densityOf() * _fontScaleOf();
  double get wspPhPx => wspPh * _densityOf() * _fontScaleOf();

  // ── sem / hem / wem (ignore system font scale) ─────────────────────────

  double _noScale(double scaled) {
    final fs = _fontScaleOf();
    return fs > 0 ? scaled / fs : scaled;
  }

  double get sem => _noScale(ssp);
  double get sema => _noScale(sspa);
  double get semi => _noScale(sspi);
  double get semia => _noScale(sspia);
  double get semPh => _noScale(sspPh);
  double get semPha => _noScale(sspPha);
  double get semPhi => _noScale(sspPhi);
  double get semPhia => _noScale(sspPhia);
  double get semLh => _noScale(sspLh);
  double get semLha => _noScale(sspLha);
  double get semLhi => _noScale(sspLhi);
  double get semLhia => _noScale(sspLhia);
  double get semPw => _noScale(sspPw);
  double get semPwa => _noScale(sspPwa);
  double get semPwi => _noScale(sspPwi);
  double get semPwia => _noScale(sspPwia);
  double get semLw => _noScale(sspLw);
  double get semLwa => _noScale(sspLwa);
  double get semLwi => _noScale(sspLwi);
  double get semLwia => _noScale(sspLwia);

  double get hem => _noScale(hsp);
  double get hema => _noScale(hspa);
  double get hemi => _noScale(hspi);
  double get hemia => _noScale(hspia);
  double get hemLw => _noScale(hspLw);
  double get hemLwa => _noScale(hspLwa);
  double get hemLwi => _noScale(hspLwi);
  double get hemLwia => _noScale(hspLwia);
  double get hemPw => _noScale(hspPw);
  double get hemPwa => _noScale(hspPwa);
  double get hemPwi => _noScale(hspPwi);
  double get hemPwia => _noScale(hspPwia);

  double get wem => _noScale(wsp);
  double get wema => _noScale(wspa);
  double get wemi => _noScale(wspi);
  double get wemia => _noScale(wspia);
  double get wemLh => _noScale(wspLh);
  double get wemLha => _noScale(wspLha);
  double get wemLhi => _noScale(wspLhi);
  double get wemLhia => _noScale(wspLhia);
  double get wemPh => _noScale(wspPh);
  double get wemPha => _noScale(wspPha);
  double get wemPhi => _noScale(wspPhi);
  double get wemPhia => _noScale(wspPhia);

  // Physical pixels for the no-font-scale families (density only).
  double get semPx => sem * _densityOf() * _fontScaleOf();
  double get hemPx => hem * _densityOf() * _fontScaleOf();
  double get wemPx => wem * _densityOf() * _fontScaleOf();
}

/// EN: Sp facilitators mirroring the dp set (`sspRotate`, `sspMode`,
/// `sspQualifier`, `sspScreen` + Plain variants).
///
/// PT: Facilitadores de sp espelhando o conjunto dp (`sspRotate`, `sspMode`,
/// `sspQualifier`, `sspScreen` + variantes Plain).
extension AppDimensScaledSpFacilitators on num {
  double sspRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      AppDimensScaledFacilitators(this)
          .sdpRotate(rotationValue, orientation: orientation);

  double hspRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      AppDimensScaledFacilitators(this)
          .hdpRotate(rotationValue, orientation: orientation);

  double wspRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      AppDimensScaledFacilitators(this)
          .wdpRotate(rotationValue, orientation: orientation);

  double sspRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      AppDimensScaledFacilitators(this)
          .sdpRotatePlain(alternative, orientation: orientation);

  double sspMode(num modeValue, UiModeType uiModeType) =>
      AppDimensScaledFacilitators(this).sdpMode(modeValue, uiModeType);

  double sspModePlain(num alternative, UiModeType uiModeType) =>
      AppDimensScaledFacilitators(this).sdpModePlain(alternative, uiModeType);

  double sspQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      AppDimensScaledFacilitators(this)
          .sdpQualifier(qualifiedValue, qualifierType, qualifierValue);

  double sspQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      AppDimensScaledFacilitators(this)
          .sdpQualifierPlain(alternative, qualifierType, qualifierValue);

  double sspScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      AppDimensScaledFacilitators(this)
          .sdpScreen(screenValue, uiModeType, qualifierType, qualifierValue);

  double sspScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      AppDimensScaledFacilitators(this).sdpScreenPlain(
          alternative, uiModeType, qualifierType, qualifierValue);
}
