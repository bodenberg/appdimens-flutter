/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Fill strategy — CSS `cover`: the larger axis ratio wins.
///
/// EN: `flsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `flsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
library;

import 'package:appdimens_flutter/appdimens.dart';

import 'fill_engine.dart';

extension AppDimensFillDp on num {
  // ── flsdp (smallest width) ────────────────────────────────────────────────────
  /// Monomorphic fast lane — `max(minDp/300, maxDp/533)` hoisted per snapshot.
  double get flsdp => toDouble() * AppDimensScope.metricsOrDefault.fillScale;
  double get flsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get flsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get flsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get flsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get flsdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get flsdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get flsdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get flsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get flsdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get flsdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get flsdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get flsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get flsdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get flsdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get flsdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get flsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get flsdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get flsdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get flsdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get flsdpPx => flsdp * AppDimensScope.metricsOrDefault.density;

  // ── flhdp (height) ────────────────────────────────────────────────────────────
  /// Monomorphic fast lane — fill is axis-independent.
  double get flhdp => toDouble() * AppDimensScope.metricsOrDefault.fillScale;
  double get flhdpa => _v(DpQualifier.height, ar: true);
  double get flhdpi => _v(DpQualifier.height, mw: true);
  double get flhdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get flhdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get flhdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get flhdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get flhdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get flhdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get flhdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get flhdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get flhdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get flhdpPx => flhdp * AppDimensScope.metricsOrDefault.density;

  // ── flwdp (width) ─────────────────────────────────────────────────────────────
  /// Monomorphic fast lane — fill is axis-independent.
  double get flwdp => toDouble() * AppDimensScope.metricsOrDefault.fillScale;
  double get flwdpa => _v(DpQualifier.width, ar: true);
  double get flwdpi => _v(DpQualifier.width, mw: true);
  double get flwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get flwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get flwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get flwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get flwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get flwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get flwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get flwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get flwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get flwdpPx => flwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get flssp => flsdp;
  double get flsspa => flsdpa;
  double get flsspi => flsdpi;
  double get flsspia => flsdpia;
  double get flhsp => flhdp;
  double get flwsp => flwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get flsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? flsdp / fs : flsdp;
  }

  double get flhem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? flhdp / fs : flhdp;
  }

  double get flwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? flwdp / fs : flwdp;
  }

  double get flsspPx =>
      flssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenFill.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.fill,
      );
}

/// EN: Facilitators (`flsdpRotate`, `flsdpMode`, `flsdpQualifier`, `flsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`flsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensFillFacilitators on num {
  double flsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.flsdp,
        resolveDefault: (v) => v.flsdp,
      );

  double flhdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.flhdp,
        resolveDefault: (v) => v.flhdp,
      );

  double flwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.flwdp,
        resolveDefault: (v) => v.flwdp,
      );

  double flsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.flsdp,
        resolveDefault: (v) => v.flsdp,
      );

  double flsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.flsdp,
        resolveDefault: (v) => v.flsdp,
      );

  double flsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.flsdp,
        resolveDefault: (v) => v.flsdp,
      );

  double flsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double flsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double flsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double flsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
