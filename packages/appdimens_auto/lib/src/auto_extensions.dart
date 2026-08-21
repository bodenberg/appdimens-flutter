/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Auto strategy — linear on phones, log-damped beyond the 480 dp transition.
///
/// EN: `asdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `asdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'auto_engine.dart';

extension AppDimensAutoDp on num {
  // ── asdp (smallest width) ────────────────────────────────────────────────────
  double get asdp => _v(DpQualifier.smallWidth);
  double get asdpa => _v(DpQualifier.smallWidth, ar: true);
  double get asdpi => _v(DpQualifier.smallWidth, mw: true);
  double get asdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get asdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get asdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get asdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get asdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get asdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get asdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get asdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get asdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get asdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get asdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get asdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get asdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get asdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get asdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get asdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get asdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get asdpPx => asdp * AppDimensScope.metricsOrDefault.density;

  // ── ahdp (height) ────────────────────────────────────────────────────────────
  double get ahdp => _v(DpQualifier.height);
  double get ahdpa => _v(DpQualifier.height, ar: true);
  double get ahdpi => _v(DpQualifier.height, mw: true);
  double get ahdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get ahdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get ahdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get ahdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get ahdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get ahdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get ahdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get ahdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get ahdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get ahdpPx => ahdp * AppDimensScope.metricsOrDefault.density;

  // ── awdp (width) ─────────────────────────────────────────────────────────────
  double get awdp => _v(DpQualifier.width);
  double get awdpa => _v(DpQualifier.width, ar: true);
  double get awdpi => _v(DpQualifier.width, mw: true);
  double get awdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get awdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get awdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get awdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get awdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get awdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get awdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get awdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get awdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get awdpPx => awdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get assp => asdp;
  double get asspa => asdpa;
  double get asspi => asdpi;
  double get asspia => asdpia;
  double get ahsp => ahdp;
  double get awsp => awdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get asem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? asdp / fs : asdp;
  }

  double get ahem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? ahdp / fs : ahdp;
  }

  double get awem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? awdp / fs : awdp;
  }

  double get asspPx =>
      assp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenAuto.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.auto,
      );
}

/// EN: Facilitators (`asdpRotate`, `asdpMode`, `asdpQualifier`, `asdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`asdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensAutoFacilitators on num {
  double asdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.asdp,
        resolveDefault: (v) => v.asdp,
      );

  double ahdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.ahdp,
        resolveDefault: (v) => v.ahdp,
      );

  double awdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.awdp,
        resolveDefault: (v) => v.awdp,
      );

  double asdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.asdp,
        resolveDefault: (v) => v.asdp,
      );

  double asdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.asdp,
        resolveDefault: (v) => v.asdp,
      );

  double asdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.asdp,
        resolveDefault: (v) => v.asdp,
      );

  double asdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double asdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double asdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double asdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
