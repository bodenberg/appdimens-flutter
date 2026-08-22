/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Fluid strategy — clamped lerp between `base×0.8` and `base×1.2` over `[320, 768]` dp.
///
/// EN: `fsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `fsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
library;

import 'package:appdimens_flutter/appdimens.dart';

import 'factors.dart';
import 'fluid_engine.dart';

extension AppDimensFluidDp on num {
  // ── fsdp (smallest width) ────────────────────────────────────────────────────
  /// EN: Monomorphic fast lane — inlines the clamp/lerp with the exact
  /// engine op order (`minV + (maxV − minV) × t`), reading the axis straight
  /// from the snapshot. Bit-exact, no dispatch.
  /// PT: Faixa rápida monomórfica — embute o clamp/lerp com a ordem exata de
  /// operações do engine, lendo o eixo direto do snapshot. Bit-exato.
  double get fsdp {
    final m = AppDimensScope.metricsOrDefault;
    final b = toDouble();
    final d = m.smallestWidthDp;
    final minV = b * FluidRange.minScale;
    final maxV = b * FluidRange.maxScale;
    if (d <= FluidRange.minWidth) return minV;
    if (d >= FluidRange.maxWidth) return maxV;
    final t =
        (d - FluidRange.minWidth) / (FluidRange.maxWidth - FluidRange.minWidth);
    return minV + (maxV - minV) * t;
  }
  double get fsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get fsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get fsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get fsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get fsdpPha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get fsdpPhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get fsdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get fsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get fsdpLha =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get fsdpLhi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get fsdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get fsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get fsdpPwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get fsdpPwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get fsdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get fsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get fsdpLwa =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get fsdpLwi =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get fsdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get fsdpPx => fsdp * AppDimensScope.metricsOrDefault.density;

  // ── fhdp (height) ────────────────────────────────────────────────────────────
  /// Monomorphic fast lane — height-axis fluid clamp/lerp, engine op order.
  double get fhdp {
    final m = AppDimensScope.metricsOrDefault;
    final b = toDouble();
    final d = m.screenHeightDp.toDouble();
    final minV = b * FluidRange.minScale;
    final maxV = b * FluidRange.maxScale;
    if (d <= FluidRange.minWidth) return minV;
    if (d >= FluidRange.maxWidth) return maxV;
    final t =
        (d - FluidRange.minWidth) / (FluidRange.maxWidth - FluidRange.minWidth);
    return minV + (maxV - minV) * t;
  }
  double get fhdpa => _v(DpQualifier.height, ar: true);
  double get fhdpi => _v(DpQualifier.height, mw: true);
  double get fhdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get fhdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get fhdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get fhdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get fhdpLwia =>
      _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get fhdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get fhdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get fhdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get fhdpPwia =>
      _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get fhdpPx => fhdp * AppDimensScope.metricsOrDefault.density;

  // ── fwdp (width) ─────────────────────────────────────────────────────────────
  /// Monomorphic fast lane — width-axis fluid clamp/lerp, engine op order.
  double get fwdp {
    final m = AppDimensScope.metricsOrDefault;
    final b = toDouble();
    final d = m.screenWidthDp.toDouble();
    final minV = b * FluidRange.minScale;
    final maxV = b * FluidRange.maxScale;
    if (d <= FluidRange.minWidth) return minV;
    if (d >= FluidRange.maxWidth) return maxV;
    final t =
        (d - FluidRange.minWidth) / (FluidRange.maxWidth - FluidRange.minWidth);
    return minV + (maxV - minV) * t;
  }
  double get fwdpa => _v(DpQualifier.width, ar: true);
  double get fwdpi => _v(DpQualifier.width, mw: true);
  double get fwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get fwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get fwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get fwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get fwdpLhia =>
      _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get fwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get fwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get fwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get fwdpPhia =>
      _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get fwdpPx => fwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get fssp => fsdp;
  double get fsspa => fsdpa;
  double get fsspi => fsdpi;
  double get fsspia => fsdpia;
  double get fhsp => fhdp;
  double get fwsp => fwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get fsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? fsdp / fs : fsdp;
  }

  double get fhem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? fhdp / fs : fhdp;
  }

  double get fwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? fwdp / fs : fwdp;
  }

  double get fsspPx =>
      fssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenFluid.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.fluid,
      );
}

/// EN: Facilitators (`fsdpRotate`, `fsdpMode`, `fsdpQualifier`, `fsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`fsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensFluidFacilitators on num {
  double fsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.fsdp,
        resolveDefault: (v) => v.fsdp,
      );

  double fhdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.fhdp,
        resolveDefault: (v) => v.fhdp,
      );

  double fwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.fwdp,
        resolveDefault: (v) => v.fwdp,
      );

  double fsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.fsdp,
        resolveDefault: (v) => v.fsdp,
      );

  double fsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.fsdp,
        resolveDefault: (v) => v.fsdp,
      );

  double fsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.fsdp,
        resolveDefault: (v) => v.fsdp,
      );

  double fsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double fsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double fsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double fsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
