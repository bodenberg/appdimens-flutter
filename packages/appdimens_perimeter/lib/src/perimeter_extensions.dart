/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Perimeter strategy — half-perimeter ratio against the design baseline.
///
/// EN: `prsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `prsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'perimeter_engine.dart';

extension AppDimensPerimeterDp on num {
  // ── prsdp (smallest width) ────────────────────────────────────────────────────
  double get prsdp => _v(DpQualifier.smallWidth);
  double get prsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get prsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get prsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get prsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get prsdpPha => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get prsdpPhi => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get prsdpPhia => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get prsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get prsdpLha => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get prsdpLhi => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get prsdpLhia => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get prsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get prsdpPwa => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get prsdpPwi => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get prsdpPwia => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get prsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get prsdpLwa => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get prsdpLwi => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get prsdpLwia => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get prsdpPx => prsdp * AppDimensScope.metricsOrDefault.density;

  // ── prhdp (height) ────────────────────────────────────────────────────────────
  double get prhdp => _v(DpQualifier.height);
  double get prhdpa => _v(DpQualifier.height, ar: true);
  double get prhdpi => _v(DpQualifier.height, mw: true);
  double get prhdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get prhdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get prhdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get prhdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get prhdpLwia => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get prhdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get prhdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get prhdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get prhdpPwia => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get prhdpPx => prhdp * AppDimensScope.metricsOrDefault.density;

  // ── prwdp (width) ─────────────────────────────────────────────────────────────
  double get prwdp => _v(DpQualifier.width);
  double get prwdpa => _v(DpQualifier.width, ar: true);
  double get prwdpi => _v(DpQualifier.width, mw: true);
  double get prwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get prwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get prwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get prwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get prwdpLhia => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get prwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get prwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get prwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get prwdpPhia => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get prwdpPx => prwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get prssp => prsdp;
  double get prsspa => prsdpa;
  double get prsspi => prsdpi;
  double get prsspia => prsdpia;
  double get prhsp => prhdp;
  double get prwsp => prwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get prsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? prsdp / fs : prsdp;
  }

  double get prhem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? prhdp / fs : prhdp;
  }

  double get prwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? prwdp / fs : prwdp;
  }

  double get prsspPx => prssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenPerimeter.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.perimeter,
      );
}

/// EN: Facilitators (`prsdpRotate`, `prsdpMode`, `prsdpQualifier`, `prsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`prsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensPerimeterFacilitators on num {
  double prsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.prsdp,
        resolveDefault: (v) => v.prsdp,
      );

  double prhdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.prhdp,
        resolveDefault: (v) => v.prhdp,
      );

  double prwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.prwdp,
        resolveDefault: (v) => v.prwdp,
      );

  double prsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.prsdp,
        resolveDefault: (v) => v.prsdp,
      );

  double prsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.prsdp,
        resolveDefault: (v) => v.prsdp,
      );

  double prsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.prsdp,
        resolveDefault: (v) => v.prsdp,
      );

  double prsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double prsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double prsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double prsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
