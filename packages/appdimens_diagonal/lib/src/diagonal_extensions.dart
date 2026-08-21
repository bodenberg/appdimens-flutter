/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Diagonal strategy — screen-diagonal ratio against the design baseline.
///
/// EN: `dgsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `dgsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'diagonal_engine.dart';

extension AppDimensDiagonalDp on num {
  // ── dgsdp (smallest width) ────────────────────────────────────────────────────
  double get dgsdp => _v(DpQualifier.smallWidth);
  double get dgsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get dgsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get dgsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get dgsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get dgsdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get dgsdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get dgsdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get dgsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get dgsdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get dgsdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get dgsdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get dgsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get dgsdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get dgsdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get dgsdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get dgsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get dgsdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get dgsdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get dgsdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get dgsdpPx => dgsdp * AppDimensScope.metricsOrDefault.density;

  // ── dghdp (height) ────────────────────────────────────────────────────────────
  double get dghdp => _v(DpQualifier.height);
  double get dghdpa => _v(DpQualifier.height, ar: true);
  double get dghdpi => _v(DpQualifier.height, mw: true);
  double get dghdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get dghdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get dghdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get dghdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get dghdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get dghdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get dghdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get dghdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get dghdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get dghdpPx => dghdp * AppDimensScope.metricsOrDefault.density;

  // ── dgwdp (width) ─────────────────────────────────────────────────────────────
  double get dgwdp => _v(DpQualifier.width);
  double get dgwdpa => _v(DpQualifier.width, ar: true);
  double get dgwdpi => _v(DpQualifier.width, mw: true);
  double get dgwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get dgwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get dgwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get dgwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get dgwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get dgwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get dgwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get dgwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get dgwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get dgwdpPx => dgwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get dgssp => dgsdp;
  double get dgsspa => dgsdpa;
  double get dgsspi => dgsdpi;
  double get dgsspia => dgsdpia;
  double get dghsp => dghdp;
  double get dgwsp => dgwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get dgsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dgsdp / fs : dgsdp;
  }

  double get dghem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dghdp / fs : dghdp;
  }

  double get dgwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? dgwdp / fs : dgwdp;
  }

  double get dgsspPx =>
      dgssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenDiagonal.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.diagonal,
      );
}

/// EN: Facilitators (`dgsdpRotate`, `dgsdpMode`, `dgsdpQualifier`, `dgsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`dgsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensDiagonalFacilitators on num {
  double dgsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dgsdp,
        resolveDefault: (v) => v.dgsdp,
      );

  double dghdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dghdp,
        resolveDefault: (v) => v.dghdp,
      );

  double dgwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.dgwdp,
        resolveDefault: (v) => v.dgwdp,
      );

  double dgsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.dgsdp,
        resolveDefault: (v) => v.dgsdp,
      );

  double dgsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.dgsdp,
        resolveDefault: (v) => v.dgsdp,
      );

  double dgsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.dgsdp,
        resolveDefault: (v) => v.dgsdp,
      );

  double dgsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double dgsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double dgsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double dgsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
