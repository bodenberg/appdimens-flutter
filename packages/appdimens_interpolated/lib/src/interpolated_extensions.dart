/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Interpolated strategy — fixed 50% blend between raw and fully-scaled values.
///
/// EN: `isdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `isdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
library;

import 'package:appdimens/appdimens.dart';

import 'factors.dart';
import 'interpolated_engine.dart';

extension AppDimensInterpolatedDp on num {
  // ── isdp (smallest width) ────────────────────────────────────────────────────

  /// EN: Monomorphic fast lane — bit-exact with the engine's memoized sw path.
  /// PT: Faixa rápida monomórfica — bit-exato com o caminho sw memoizado.
  double get isdp =>
      toDouble() * AppDimensScope.metricsOrDefault.interpolatedScale;
  double get isdpa => _v(DpQualifier.smallWidth, ar: true);
  double get isdpi => _v(DpQualifier.smallWidth, mw: true);
  double get isdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get isdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get isdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get isdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get isdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get isdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get isdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get isdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get isdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get isdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get isdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get isdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get isdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get isdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get isdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get isdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get isdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get isdpPx => isdp * AppDimensScope.metricsOrDefault.density;

  // ── ihdp (height) ────────────────────────────────────────────────────────────

  /// Monomorphic fast lane — inlines the blend with the exact engine op order
  /// (`b + (b·(h/300) − b) × 0.5`) using the snapshot factor for `h/300`.
  double get ihdp {
    final b = toDouble();
    final linear =
        b * AppDimensScope.metricsOrDefault.screenHeightFactor;
    return b + (linear - b) * Interpolation.defaultBlend;
  }

  double get ihdpa => _v(DpQualifier.height, ar: true);
  double get ihdpi => _v(DpQualifier.height, mw: true);
  double get ihdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get ihdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get ihdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get ihdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get ihdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get ihdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get ihdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get ihdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get ihdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get ihdpPx => ihdp * AppDimensScope.metricsOrDefault.density;

  // ── iwdp (width) ─────────────────────────────────────────────────────────────
  /// Monomorphic fast lane — inlines the blend with the exact engine op order
  /// (`b + (b·(w/300) − b) × 0.5`) using the snapshot factor for `w/300`.
  double get iwdp {
    final b = toDouble();
    final linear = b * AppDimensScope.metricsOrDefault.screenWidthFactor;
    return b + (linear - b) * Interpolation.defaultBlend;
  }

  double get iwdpa => _v(DpQualifier.width, ar: true);
  double get iwdpi => _v(DpQualifier.width, mw: true);
  double get iwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get iwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get iwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get iwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get iwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get iwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get iwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get iwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get iwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get iwdpPx => iwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get issp => isdp;
  double get isspa => isdpa;
  double get isspi => isdpi;
  double get isspia => isdpia;
  double get ihsp => ihdp;
  double get iwsp => iwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get isem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? isdp / fs : isdp;
  }

  double get ihem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? ihdp / fs : ihdp;
  }

  double get iwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? iwdp / fs : iwdp;
  }

  double get isspPx =>
      issp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenInterpolated.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.interpolated,
      );
}

/// EN: Facilitators (`isdpRotate`, `isdpMode`, `isdpQualifier`, `isdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`isdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensInterpolatedFacilitators on num {
  double isdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.isdp,
        resolveDefault: (v) => v.isdp,
      );

  double ihdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.ihdp,
        resolveDefault: (v) => v.ihdp,
      );

  double iwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.iwdp,
        resolveDefault: (v) => v.iwdp,
      );

  double isdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.isdp,
        resolveDefault: (v) => v.isdp,
      );

  double isdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.isdp,
        resolveDefault: (v) => v.isdp,
      );

  double isdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.isdp,
        resolveDefault: (v) => v.isdp,
      );

  double isdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double isdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double isdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double isdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
