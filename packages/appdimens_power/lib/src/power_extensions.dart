/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Power strategy — sub-linear curve `(axis/300)^0.75`.
///
/// EN: `pwsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `pwsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
library;

import 'package:appdimens/appdimens.dart';

import 'power_engine.dart';

extension AppDimensPowerDp on num {
  // ── pwsdp (smallest width) ────────────────────────────────────────────────────

  /// EN: Monomorphic fast lane — one snapshot read + one multiply
  /// (bit-exact with the engine's default sw path).
  /// PT: Faixa rápida monomórfica — uma leitura de snapshot + uma
  /// multiplicação (bit-exato com o caminho sw padrão do engine).
  double get pwsdp => toDouble() * AppDimensScope.metricsOrDefault.powerScale;
  double get pwsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get pwsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get pwsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get pwsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get pwsdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get pwsdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get pwsdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get pwsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get pwsdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get pwsdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get pwsdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get pwsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get pwsdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get pwsdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get pwsdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get pwsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get pwsdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get pwsdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get pwsdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get pwsdpPx => pwsdp * AppDimensScope.metricsOrDefault.density;

  // ── pwhdp (height) ────────────────────────────────────────────────────────────

  /// Monomorphic fast lane — `(base × h/300)^0.75` hoisted per snapshot.
  double get pwhdp =>
      toDouble() * AppDimensScope.metricsOrDefault.powerHeightFactor;
  double get pwhdpa => _v(DpQualifier.height, ar: true);
  double get pwhdpi => _v(DpQualifier.height, mw: true);
  double get pwhdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get pwhdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get pwhdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get pwhdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get pwhdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get pwhdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get pwhdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get pwhdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get pwhdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get pwhdpPx => pwhdp * AppDimensScope.metricsOrDefault.density;

  // ── pwwdp (width) ─────────────────────────────────────────────────────────────

  /// Monomorphic fast lane — `(base × w/300)^0.75` hoisted per snapshot.
  double get pwwdp =>
      toDouble() * AppDimensScope.metricsOrDefault.powerWidthFactor;
  double get pwwdpa => _v(DpQualifier.width, ar: true);
  double get pwwdpi => _v(DpQualifier.width, mw: true);
  double get pwwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get pwwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get pwwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get pwwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get pwwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get pwwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get pwwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get pwwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get pwwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get pwwdpPx => pwwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get pwssp => pwsdp;
  double get pwsspa => pwsdpa;
  double get pwsspi => pwsdpi;
  double get pwsspia => pwsdpia;
  double get pwhsp => pwhdp;
  double get pwwsp => pwwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get pwsem {
    // Monomorphic single-scope-read no-font-scale stem.
    final m = AppDimensScope.metricsOrDefault;
    final v = toDouble() * m.powerScale;
    final fs = m.fontScale;
    return fs > 0 ? v / fs : v;
  }

  double get pwhem {
    // Monomorphic single-scope-read no-font-scale stem.
    final m = AppDimensScope.metricsOrDefault;
    final v = toDouble() * m.powerHeightFactor;
    final fs = m.fontScale;
    return fs > 0 ? v / fs : v;
  }

  double get pwwem {
    // Monomorphic single-scope-read no-font-scale stem.
    final m = AppDimensScope.metricsOrDefault;
    final v = toDouble() * m.powerWidthFactor;
    final fs = m.fontScale;
    return fs > 0 ? v / fs : v;
  }

  double get pwsspPx =>
      pwssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenPower.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.power,
      );
}

/// EN: Facilitators (`pwsdpRotate`, `pwsdpMode`, `pwsdpQualifier`, `pwsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`pwsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensPowerFacilitators on num {
  double pwsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.pwsdp,
        resolveDefault: (v) => v.pwsdp,
      );

  double pwhdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.pwhdp,
        resolveDefault: (v) => v.pwhdp,
      );

  double pwwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.pwwdp,
        resolveDefault: (v) => v.pwwdp,
      );

  double pwsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.pwsdp,
        resolveDefault: (v) => v.pwsdp,
      );

  double pwsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.pwsdp,
        resolveDefault: (v) => v.pwsdp,
      );

  double pwsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.pwsdp,
        resolveDefault: (v) => v.pwsdp,
      );

  double pwsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double pwsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double pwsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double pwsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
