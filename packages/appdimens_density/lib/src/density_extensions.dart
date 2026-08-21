/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Density strategy — physical-density alignment against the 160 dpi reference.
///
/// EN: `dsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `dsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'density_engine.dart';

extension AppDimensDensityDp on num {
  // ── dsdp (smallest width) ────────────────────────────────────────────────────
  double get dsdp => _v(DpQualifier.smallWidth);
  double get dsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get dsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get dsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get dsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get dsdpPha => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get dsdpPhi => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get dsdpPhia => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get dsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get dsdpLha => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get dsdpLhi => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get dsdpLhia => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get dsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get dsdpPwa => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get dsdpPwi => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get dsdpPwia => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get dsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get dsdpLwa => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get dsdpLwi => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get dsdpLwia => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get dsdpPx => dsdp * AppDimensScope.metricsOrDefault.density;

  // ── dhdp (height) ────────────────────────────────────────────────────────────
  double get dhdp => _v(DpQualifier.height);
  double get dhdpa => _v(DpQualifier.height, ar: true);
  double get dhdpi => _v(DpQualifier.height, mw: true);
  double get dhdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get dhdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get dhdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get dhdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get dhdpLwia => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get dhdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get dhdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get dhdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get dhdpPwia => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get dhdpPx => dhdp * AppDimensScope.metricsOrDefault.density;

  // ── dwdp (width) ─────────────────────────────────────────────────────────────
  double get dwdp => _v(DpQualifier.width);
  double get dwdpa => _v(DpQualifier.width, ar: true);
  double get dwdpi => _v(DpQualifier.width, mw: true);
  double get dwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get dwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get dwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get dwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get dwdpLhia => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get dwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get dwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get dwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get dwdpPhia => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get dwdpPx => dwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get dssp => dsdp;
  double get dsspa => dsdpa;
  double get dsspi => dsdpi;
  double get dsspia => dsdpia;
  double get dhsp => dhdp;
  double get dwsp => dwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get dsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dsdp / fs : dsdp;
  }

  double get dhem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dhdp / fs : dhdp;
  }

  double get dwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dwdp / fs : dwdp;
  }

  double get dsspPx => dssp * AppDimensScope.metricsOrDefault.density * _safeFs();

  double _safeFs() {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? fs : 1.0;
  }

  double _v(
    DpQualifier q, {
    Inverter inv = Inverter.standard,
    bool ar = false,
    bool mw = false,
  }) =>
      StrategyResolution.value(
        toDouble(),
        DimenDensity.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.density,
      );
}

/// EN: Facilitators (`dsdpRotate`, `dsdpMode`, `dsdpQualifier`, `dsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`dsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensDensityFacilitators on num {
  double dsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dsdp,
        resolveDefault: (v) => v.dsdp,
      );

  double dhdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dhdp,
        resolveDefault: (v) => v.dhdp,
      );

  double dwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dwdp,
        resolveDefault: (v) => v.dwdp,
      );

  double dsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.dsdp,
        resolveDefault: (v) => v.dsdp,
      );

  double dsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.dsdp,
        resolveDefault: (v) => v.dsdp,
      );

  double dsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.dsdp,
        resolveDefault: (v) => v.dsdp,
      );

  double dsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double dsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double dsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double dsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
