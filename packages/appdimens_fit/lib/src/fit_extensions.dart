/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Fit strategy — CSS `contain`: the smaller axis ratio wins.
///
/// EN: `ftsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `ftsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'fit_engine.dart';

extension AppDimensFitDp on num {
  // ── ftsdp (smallest width) ────────────────────────────────────────────────────
  double get ftsdp => _v(DpQualifier.smallWidth);
  double get ftsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get ftsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get ftsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get ftsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get ftsdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get ftsdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get ftsdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get ftsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get ftsdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get ftsdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get ftsdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get ftsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get ftsdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get ftsdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get ftsdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get ftsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get ftsdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get ftsdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get ftsdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get ftsdpPx => ftsdp * AppDimensScope.metricsOrDefault.density;

  // ── fthdp (height) ────────────────────────────────────────────────────────────
  double get fthdp => _v(DpQualifier.height);
  double get fthdpa => _v(DpQualifier.height, ar: true);
  double get fthdpi => _v(DpQualifier.height, mw: true);
  double get fthdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get fthdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get fthdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get fthdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get fthdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get fthdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get fthdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get fthdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get fthdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get fthdpPx => fthdp * AppDimensScope.metricsOrDefault.density;

  // ── ftwdp (width) ─────────────────────────────────────────────────────────────
  double get ftwdp => _v(DpQualifier.width);
  double get ftwdpa => _v(DpQualifier.width, ar: true);
  double get ftwdpi => _v(DpQualifier.width, mw: true);
  double get ftwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get ftwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get ftwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get ftwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get ftwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get ftwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get ftwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get ftwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get ftwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get ftwdpPx => ftwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get ftssp => ftsdp;
  double get ftsspa => ftsdpa;
  double get ftsspi => ftsdpi;
  double get ftsspia => ftsdpia;
  double get fthsp => fthdp;
  double get ftwsp => ftwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get ftsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? ftsdp / fs : ftsdp;
  }

  double get fthem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? fthdp / fs : fthdp;
  }

  double get ftwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? ftwdp / fs : ftwdp;
  }

  double get ftsspPx =>
      ftssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenFit.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.fit,
      );
}

/// EN: Facilitators (`ftsdpRotate`, `ftsdpMode`, `ftsdpQualifier`, `ftsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`ftsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensFitFacilitators on num {
  double ftsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.ftsdp,
        resolveDefault: (v) => v.ftsdp,
      );

  double fthdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.fthdp,
        resolveDefault: (v) => v.fthdp,
      );

  double ftwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.ftwdp,
        resolveDefault: (v) => v.ftwdp,
      );

  double ftsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.ftsdp,
        resolveDefault: (v) => v.ftsdp,
      );

  double ftsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.ftsdp,
        resolveDefault: (v) => v.ftsdp,
      );

  double ftsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.ftsdp,
        resolveDefault: (v) => v.ftsdp,
      );

  double ftsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double ftsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double ftsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double ftsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
