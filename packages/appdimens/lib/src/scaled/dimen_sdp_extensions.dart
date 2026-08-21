/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Scaled strategy — primary `num` extension surface (sdp · hdp · wdp).
import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/orientation.dart';
import '../common/ui_mode_type.dart';
import '../core/dimen_cache.dart';
import '../core/dimen_metrics.dart';
import '../core/dimen_scaled_engine.dart';
import 'dimen_scaled_builder.dart';

DimenMetrics get _m => AppDimensScope.metricsOrDefault;

double _arFactorFor(DimenMetrics m, double axisDp) =>
    1 +
    (axisDp - 300.0) *
        (DimenCache.adjustmentScale +
            DimenCache.sensitivityDefault * m.logNormalizedAspectRatio);

double _axisDpFor(DimenMetrics m, Inverter inverter) {
  switch (inverter) {
    case Inverter.standard:
      return m.smallestWidthDp;
    case Inverter.phToLw:
      return m.isLandscape ? m.screenWidthDp.toDouble() : m.screenHeightDp.toDouble();
    case Inverter.pwToLh:
      return m.isLandscape ? m.screenHeightDp.toDouble() : m.screenWidthDp.toDouble();
    case Inverter.lhToPw:
      return m.isPortrait ? m.screenWidthDp.toDouble() : m.screenHeightDp.toDouble();
    case Inverter.lwToPh:
      return m.isPortrait ? m.screenHeightDp.toDouble() : m.screenWidthDp.toDouble();
    case Inverter.swToLh:
      return m.isLandscape ? m.screenHeightDp.toDouble() : m.smallestWidthDp;
    case Inverter.swToLw:
      return m.isLandscape ? m.screenWidthDp.toDouble() : m.smallestWidthDp;
    case Inverter.swToPh:
      return m.isPortrait ? m.screenHeightDp.toDouble() : m.smallestWidthDp;
    case Inverter.swToPw:
      return m.isPortrait ? m.screenWidthDp.toDouble() : m.smallestWidthDp;
  }
}

/// EN: Shared resolution state used by the fast-lane kernels.
///
/// PT: Estado de resolução compartilhado pelos kernels da faixa rápida.
class ScaledKernel {
  final double base;
  const ScaledKernel(this.base);

  double sw(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * m.scale;
  }

  double swAr(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * m.defaultScaledAspectRatioMultiplier;
  }

  double h(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * m.screenHeightFactor;
  }

  double hAr(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * _arFactorFor(m, m.screenHeightDp.toDouble());
  }

  double w(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * m.screenWidthFactor;
  }

  double wAr(bool mw) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    return base * _arFactorFor(m, m.screenWidthDp.toDouble());
  }

  double inverted(Inverter inverter, {bool ar = false, bool mw = false}) {
    final m = _m;
    if (mw && m.isInMultiWindowMode) return base;
    final axisDp = _axisDpFor(m, inverter);
    return ar ? base * _arFactorFor(m, axisDp) : base * (axisDp * DimenCache.invBaseRatio);
  }
}

/// EN: The **Scaled** family on [num] — resolves through the global
/// [AppDimensScope] fast lane published by `AppDimensProvider`.
///
/// Suffix grammar (identical across the whole AppDimens family):
/// - *(none)* — default curve
/// - **a** — aspect-ratio aware
/// - **i** — ignore multi-window (returns the raw base inside split-screen)
/// - **ia** — both flags
///
/// Orientation inverters: **Ph/Lh/Pw/Lw** swap the driving axis on the
/// matching orientation (e.g. `32.sdpPh` uses height while in portrait).
/// Twins ending in **Px** return physical device pixels.
///
/// PT: A família **Scaled** em [num] — resolve pela faixa rápida global
/// [AppDimensScope] publicada pelo `AppDimensProvider`.
///
/// Gramática de sufixos (idêntica em toda a família AppDimens):
/// - *(nenhum)* — curva padrão
/// - **a** — sensível à proporção da tela
/// - **i** — ignora multi-janela (retorna a base crua em split-screen)
/// - **ia** — ambas as flags
///
/// Inversores de orientação: **Ph/Lh/Pw/Lw** trocam o eixo na orientação
/// correspondente (ex.: `32.sdpPh` usa a altura em retrato). Gêmeos com
/// sufixo **Px** retornam pixels físicos do dispositivo.
extension AppDimensScaledDp on num {
  // ── Smallest Width (sdp) ────────────────────────────────────────────────

  /// EN `base × sw/300` — the default recommended path.
  /// PT `base × sw/300` — o caminho padrão recomendado.
  double get sdp => ScaledKernel(toDouble()).sw(false);
  double get sdpa => ScaledKernel(toDouble()).swAr(false);
  double get sdpi => ScaledKernel(toDouble()).sw(true);
  double get sdpia => ScaledKernel(toDouble()).swAr(true);

  /// EN SW in portrait acts as HEIGHT.
  /// PT SW em retrato age como HEIGHT.
  double get sdpPh => ScaledKernel(toDouble()).inverted(Inverter.swToPh);
  double get sdpPha => ScaledKernel(toDouble()).inverted(Inverter.swToPh, ar: true);
  double get sdpPhi => ScaledKernel(toDouble()).inverted(Inverter.swToPh, mw: true);
  double get sdpPhia =>
      ScaledKernel(toDouble()).inverted(Inverter.swToPh, ar: true, mw: true);

  /// EN SW in landscape acts as HEIGHT.
  /// PT SW em paisagem age como HEIGHT.
  double get sdpLh => ScaledKernel(toDouble()).inverted(Inverter.swToLh);
  double get sdpLha => ScaledKernel(toDouble()).inverted(Inverter.swToLh, ar: true);
  double get sdpLhi => ScaledKernel(toDouble()).inverted(Inverter.swToLh, mw: true);
  double get sdpLhia =>
      ScaledKernel(toDouble()).inverted(Inverter.swToLh, ar: true, mw: true);

  /// EN SW in portrait acts as WIDTH.
  /// PT SW em retrato age como WIDTH.
  double get sdpPw => ScaledKernel(toDouble()).inverted(Inverter.swToPw);
  double get sdpPwa => ScaledKernel(toDouble()).inverted(Inverter.swToPw, ar: true);
  double get sdpPwi => ScaledKernel(toDouble()).inverted(Inverter.swToPw, mw: true);
  double get sdpPwia =>
      ScaledKernel(toDouble()).inverted(Inverter.swToPw, ar: true, mw: true);

  /// EN SW in landscape acts as WIDTH.
  /// PT SW em paisagem age como WIDTH.
  double get sdpLw => ScaledKernel(toDouble()).inverted(Inverter.swToLw);
  double get sdpLwa => ScaledKernel(toDouble()).inverted(Inverter.swToLw, ar: true);
  double get sdpLwi => ScaledKernel(toDouble()).inverted(Inverter.swToLw, mw: true);
  double get sdpLwia =>
      ScaledKernel(toDouble()).inverted(Inverter.swToLw, ar: true, mw: true);

  /// Physical-pixel twins of the sdp family.
  double get sdpPx => sdp * _m.density;
  double get sdpaPx => sdpa * _m.density;
  double get sdpiPx => sdpi * _m.density;
  double get sdpiaPx => sdpia * _m.density;
  double get sdpPhPx => sdpPh * _m.density;
  double get sdpLhPx => sdpLh * _m.density;
  double get sdpPwPx => sdpPw * _m.density;
  double get sdpLwPx => sdpLw * _m.density;

  // ── Height (hdp) ────────────────────────────────────────────────────────

  /// EN `base × h/300`.
  /// PT `base × h/300`.
  double get hdp => ScaledKernel(toDouble()).h(false);
  double get hdpa => ScaledKernel(toDouble()).hAr(false);
  double get hdpi => ScaledKernel(toDouble()).h(true);
  double get hdpia => ScaledKernel(toDouble()).hAr(true);

  /// EN HEIGHT in landscape acts as WIDTH.
  /// PT HEIGHT em paisagem age como WIDTH.
  double get hdpLw => ScaledKernel(toDouble()).inverted(Inverter.phToLw);
  double get hdpLwa => ScaledKernel(toDouble()).inverted(Inverter.phToLw, ar: true);
  double get hdpLwi => ScaledKernel(toDouble()).inverted(Inverter.phToLw, mw: true);
  double get hdpLwia =>
      ScaledKernel(toDouble()).inverted(Inverter.phToLw, ar: true, mw: true);

  /// EN HEIGHT in portrait acts as WIDTH.
  /// PT HEIGHT em retrato age como WIDTH.
  double get hdpPw => ScaledKernel(toDouble()).inverted(Inverter.lhToPw);
  double get hdpPwa => ScaledKernel(toDouble()).inverted(Inverter.lhToPw, ar: true);
  double get hdpPwi => ScaledKernel(toDouble()).inverted(Inverter.lhToPw, mw: true);
  double get hdpPwia =>
      ScaledKernel(toDouble()).inverted(Inverter.lhToPw, ar: true, mw: true);

  double get hdpPx => hdp * _m.density;
  double get hdpaPx => hdpa * _m.density;
  double get hdpLwPx => hdpLw * _m.density;
  double get hdpPwPx => hdpPw * _m.density;

  // ── Width (wdp) ─────────────────────────────────────────────────────────

  /// EN `base × w/300`.
  /// PT `base × w/300`.
  double get wdp => ScaledKernel(toDouble()).w(false);
  double get wdpa => ScaledKernel(toDouble()).wAr(false);
  double get wdpi => ScaledKernel(toDouble()).w(true);
  double get wdpia => ScaledKernel(toDouble()).wAr(true);

  /// EN WIDTH in landscape acts as HEIGHT.
  /// PT WIDTH em paisagem age como HEIGHT.
  double get wdpLh => ScaledKernel(toDouble()).inverted(Inverter.pwToLh);
  double get wdpLha => ScaledKernel(toDouble()).inverted(Inverter.pwToLh, ar: true);
  double get wdpLhi => ScaledKernel(toDouble()).inverted(Inverter.pwToLh, mw: true);
  double get wdpLhia =>
      ScaledKernel(toDouble()).inverted(Inverter.pwToLh, ar: true, mw: true);

  /// EN WIDTH in portrait acts as HEIGHT.
  /// PT WIDTH em retrato age como HEIGHT.
  double get wdpPh => ScaledKernel(toDouble()).inverted(Inverter.lwToPh);
  double get wdpPha => ScaledKernel(toDouble()).inverted(Inverter.lwToPh, ar: true);
  double get wdpPhi => ScaledKernel(toDouble()).inverted(Inverter.lwToPh, mw: true);
  double get wdpPhia =>
      ScaledKernel(toDouble()).inverted(Inverter.lwToPh, ar: true, mw: true);

  double get wdpPx => wdp * _m.density;
  double get wdpaPx => wdpa * _m.density;
  double get wdpLhPx => wdpLh * _m.density;
  double get wdpPhPx => wdpPh * _m.density;

  /// Starts the immutable [DimenScaled] builder chain from this base value.
  DimenScaled get scaledDp => DimenScaled(toDouble());
}

// ═══════════════════════════════════════════════════════════════════════════
// FACILITATORS — Rotate / Mode / Qualifier / Screen (+ Plain logic-only)
// ═══════════════════════════════════════════════════════════════════════════

/// EN: Conditional facilitators for the Scaled family. Each resolves either
/// `this` (base) or the branch value through the full engine, honoring the
/// standard flags. The **Plain** variants are logic-only: they pick between
/// two already-resolved values without scaling anything twice.
///
/// PT: Facilitadores condicionais da família Scaled. Cada um resolve `this`
/// (base) ou o valor do ramo pelo motor completo, respeitando as flags
/// padrão. As variantes **Plain** são apenas lógica: escolhem entre dois
/// valores já resolvidos sem escalar nada duas vezes.
extension AppDimensScaledFacilitators on num {
  // ── Rotate ──────────────────────────────────────────────────────────────

  /// SW-based; when in [orientation], scales [rotationValue] instead.
  double sdpRotate(
    num rotationValue, {
    DpQualifier finalQualifierResolver = DpQualifier.smallWidth,
    OrientationRequest orientation = OrientationRequest.landscape,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchRotate(rotationValue, DpQualifier.smallWidth,
          finalQualifierResolver: finalQualifierResolver,
          orientation: orientation,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  /// HEIGHT-based rotate facilitator.
  double hdpRotate(
    num rotationValue, {
    DpQualifier finalQualifierResolver = DpQualifier.height,
    OrientationRequest orientation = OrientationRequest.landscape,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchRotate(rotationValue, DpQualifier.height,
          finalQualifierResolver: finalQualifierResolver,
          orientation: orientation,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  /// WIDTH-based rotate facilitator.
  double wdpRotate(
    num rotationValue, {
    DpQualifier finalQualifierResolver = DpQualifier.width,
    OrientationRequest orientation = OrientationRequest.landscape,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchRotate(rotationValue, DpQualifier.width,
          finalQualifierResolver: finalQualifierResolver,
          orientation: orientation,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  // ── Mode ────────────────────────────────────────────────────────────────

  /// SW-based; when the device matches [uiModeType], scales [modeValue].
  double sdpMode(
    num modeValue,
    UiModeType uiModeType, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchMode(modeValue, uiModeType, DpQualifier.smallWidth,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double hdpMode(
    num modeValue,
    UiModeType uiModeType, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchMode(modeValue, uiModeType, DpQualifier.height,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double wdpMode(
    num modeValue,
    UiModeType uiModeType, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchMode(modeValue, uiModeType, DpQualifier.width,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  // ── Qualifier ───────────────────────────────────────────────────────────

  /// SW-based; when the metric of [qualifierType] ≥ [qualifierValue], scales
  /// [qualifiedValue] instead.
  double sdpQualifier(
    num qualifiedValue,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchQualifier(qualifiedValue, qualifierType, qualifierValue,
          DpQualifier.smallWidth,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double hdpQualifier(
    num qualifiedValue,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchQualifier(qualifiedValue, qualifierType, qualifierValue,
          DpQualifier.height,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double wdpQualifier(
    num qualifiedValue,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchQualifier(qualifiedValue, qualifierType, qualifierValue,
          DpQualifier.width,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  // ── Screen (ui-mode + qualifier) ────────────────────────────────────────

  /// SW-based; requires BOTH the ui-mode AND the qualifier to match.
  double sdpScreen(
    num screenValue,
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchScreen(screenValue, uiModeType, qualifierType, qualifierValue,
          DpQualifier.smallWidth,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double hdpScreen(
    num screenValue,
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchScreen(screenValue, uiModeType, qualifierType, qualifierValue,
          DpQualifier.height,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  double wdpScreen(
    num screenValue,
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue, {
    DpQualifier? finalQualifierResolver,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
  }) =>
      _branchScreen(screenValue, uiModeType, qualifierType, qualifierValue,
          DpQualifier.width,
          finalQualifierResolver: finalQualifierResolver,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK);

  // ── Plain (logic-only) ──────────────────────────────────────────────────

  /// Logic-only rotate: picks `this` or [alternative] by orientation; neither
  /// side is scaled twice.
  double sdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      _plainRotate(alternative, orientation);

  double hdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      _plainRotate(alternative, orientation);

  double wdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      _plainRotate(alternative, orientation);

  /// Logic-only mode pick (no second scaling).
  double sdpModePlain(num alternative, UiModeType uiModeType) =>
      _plainMode(alternative, uiModeType);

  double hdpModePlain(num alternative, UiModeType uiModeType) =>
      _plainMode(alternative, uiModeType);

  double wdpModePlain(num alternative, UiModeType uiModeType) =>
      _plainMode(alternative, uiModeType);

  /// Logic-only qualifier pick (no second scaling).
  double sdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      _plainQualifier(alternative, qualifierType, qualifierValue);

  double hdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      _plainQualifier(alternative, qualifierType, qualifierValue);

  double wdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      _plainQualifier(alternative, qualifierType, qualifierValue);

  /// Logic-only combined pick (no second scaling).
  double sdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      _plainScreen(alternative, uiModeType, qualifierType, qualifierValue);

  double hdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      _plainScreen(alternative, uiModeType, qualifierType, qualifierValue);

  double wdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      _plainScreen(alternative, uiModeType, qualifierType, qualifierValue);

  // ── Branch internals ───────────────────────────────────────────────────

  double _resolveBranch(
    num value,
    DpQualifier qualifier, {
    required bool ignoreMultiWindows,
    required bool applyAspectRatio,
    required double? customSensitivityK,
  }) {
    final ctx = AppDimensScope.context;
    if (ctx != null) {
      return DimenScaledEngine.resolveScaledDp(
        value.toDouble(),
        ctx,
        qualifier,
        ignoreMultiWindows: ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio,
        customSensitivityK: customSensitivityK,
      );
    }
    final m = _m;
    if (ignoreMultiWindows && m.isInMultiWindowMode) return value.toDouble();
    return value.toDouble() *
        m.fastScaledMultiplier(qualifier, applyAspectRatio);
  }

  double _branchRotate(
    num other,
    DpQualifier fallbackQualifier, {
    required DpQualifier finalQualifierResolver,
    required OrientationRequest orientation,
    required bool ignoreMultiWindows,
    required bool applyAspectRatio,
    required double? customSensitivityK,
  }) {
    final matches = _matchesOrientation(orientation);
    return matches
        ? _resolveBranch(other, finalQualifierResolver,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK)
        : _resolveBranch(this, fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK);
  }

  double _branchMode(
    num other,
    UiModeType uiModeType,
    DpQualifier fallbackQualifier, {
    required DpQualifier? finalQualifierResolver,
    required bool ignoreMultiWindows,
    required bool applyAspectRatio,
    required double? customSensitivityK,
  }) {
    final match = AppDimensScope.uiModeTypeOrDefault == uiModeType;
    return match
        ? _resolveBranch(other, finalQualifierResolver ?? fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK)
        : _resolveBranch(this, fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK);
  }

  double _branchQualifier(
    num other,
    DpQualifier qualifierType,
    num qualifierValue,
    DpQualifier fallbackQualifier, {
    required DpQualifier? finalQualifierResolver,
    required bool ignoreMultiWindows,
    required bool applyAspectRatio,
    required double? customSensitivityK,
  }) {
    final match = _metricOf(qualifierType) >= qualifierValue.toDouble();
    return match
        ? _resolveBranch(other, finalQualifierResolver ?? fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK)
        : _resolveBranch(this, fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK);
  }

  double _branchScreen(
    num other,
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue,
    DpQualifier fallbackQualifier, {
    required DpQualifier? finalQualifierResolver,
    required bool ignoreMultiWindows,
    required bool applyAspectRatio,
    required double? customSensitivityK,
  }) {
    final match = AppDimensScope.uiModeTypeOrDefault == uiModeType &&
        _metricOf(qualifierType) >= qualifierValue.toDouble();
    return match
        ? _resolveBranch(other, finalQualifierResolver ?? fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK)
        : _resolveBranch(this, fallbackQualifier,
            ignoreMultiWindows: ignoreMultiWindows,
            applyAspectRatio: applyAspectRatio,
            customSensitivityK: customSensitivityK);
  }

  bool _matchesOrientation(OrientationRequest orientation) {
    final m = _m;
    return switch (orientation) {
      OrientationRequest.landscape => m.isLandscape,
      OrientationRequest.portrait => m.isPortrait,
      OrientationRequest.any => true,
    };
  }

  double _plainRotate(num alternative, OrientationRequest orientation) =>
      _matchesOrientation(orientation) ? alternative.toDouble() : toDouble();

  double _plainMode(num alternative, UiModeType uiModeType) =>
      AppDimensScope.uiModeTypeOrDefault == uiModeType
          ? alternative.toDouble()
          : toDouble();

  double _plainQualifier(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      _metricOf(qualifierType) >= qualifierValue.toDouble()
          ? alternative.toDouble()
          : toDouble();

  double _plainScreen(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      (AppDimensScope.uiModeTypeOrDefault == uiModeType &&
              _metricOf(qualifierType) >= qualifierValue.toDouble())
          ? alternative.toDouble()
          : toDouble();

  double _metricOf(DpQualifier qualifier) {
    final m = _m;
    return switch (qualifier) {
      DpQualifier.smallWidth => m.smallestWidthDp,
      DpQualifier.width => m.screenWidthDp.toDouble(),
      DpQualifier.height => m.screenHeightDp.toDouble(),
    };
  }
}
