/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///

/// Logarithmic strategy — symmetric ±0.4·ln damping around the 300 dp baseline.
///
/// EN: `logsdp` family on [num] — suffix grammar identical to the whole
/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)
/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família `logsdp` em [num] — gramática de sufixos idêntica a toda a
/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)
/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
import 'package:appdimens/appdimens.dart';

import 'logarithmic_engine.dart';

extension AppDimensLogarithmicDp on num {
  // ── logsdp (smallest width) ────────────────────────────────────────────────────
  double get logsdp => _v(DpQualifier.smallWidth);
  double get logsdpa => _v(DpQualifier.smallWidth, ar: true);
  double get logsdpi => _v(DpQualifier.smallWidth, mw: true);
  double get logsdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get logsdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get logsdpPha => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get logsdpPhi => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get logsdpPhia => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);
  double get logsdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get logsdpLha => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get logsdpLhi => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get logsdpLhia => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);
  double get logsdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get logsdpPwa => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get logsdpPwi => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get logsdpPwia => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);
  double get logsdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get logsdpLwa => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get logsdpLwi => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get logsdpLwia => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get logsdpPx => logsdp * AppDimensScope.metricsOrDefault.density;

  // ── loghdp (height) ────────────────────────────────────────────────────────────
  double get loghdp => _v(DpQualifier.height);
  double get loghdpa => _v(DpQualifier.height, ar: true);
  double get loghdpi => _v(DpQualifier.height, mw: true);
  double get loghdpia => _v(DpQualifier.height, ar: true, mw: true);
  double get loghdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get loghdpLwa => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true);
  double get loghdpLwi => _v(DpQualifier.height, inv: Inverter.phToLw, mw: true);
  double get loghdpLwia => _v(DpQualifier.height, inv: Inverter.phToLw, ar: true, mw: true);
  double get loghdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);
  double get loghdpPwa => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true);
  double get loghdpPwi => _v(DpQualifier.height, inv: Inverter.lhToPw, mw: true);
  double get loghdpPwia => _v(DpQualifier.height, inv: Inverter.lhToPw, ar: true, mw: true);

  double get loghdpPx => loghdp * AppDimensScope.metricsOrDefault.density;

  // ── logwdp (width) ─────────────────────────────────────────────────────────────
  double get logwdp => _v(DpQualifier.width);
  double get logwdpa => _v(DpQualifier.width, ar: true);
  double get logwdpi => _v(DpQualifier.width, mw: true);
  double get logwdpia => _v(DpQualifier.width, ar: true, mw: true);
  double get logwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get logwdpLha => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true);
  double get logwdpLhi => _v(DpQualifier.width, inv: Inverter.pwToLh, mw: true);
  double get logwdpLhia => _v(DpQualifier.width, inv: Inverter.pwToLh, ar: true, mw: true);
  double get logwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);
  double get logwdpPha => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true);
  double get logwdpPhi => _v(DpQualifier.width, inv: Inverter.lwToPh, mw: true);
  double get logwdpPhia => _v(DpQualifier.width, inv: Inverter.lwToPh, ar: true, mw: true);

  double get logwdpPx => logwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ──────────────────────────────────────────────────────────────────
  double get logssp => logsdp;
  double get logsspa => logsdpa;
  double get logsspi => logsdpi;
  double get logsspia => logsdpia;
  double get loghsp => loghdp;
  double get logwsp => logwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get logsem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? logsdp / fs : logsdp;
  }

  double get loghem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? loghdp / fs : loghdp;
  }

  double get logwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? logwdp / fs : logwdp;
  }

  double get logsspPx => logssp * AppDimensScope.metricsOrDefault.density * _safeFs();

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
        DimenLogarithmic.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.logarithmic,
      );
}

/// EN: Facilitators (`logsdpRotate`, `logsdpMode`, `logsdpQualifier`, `logsdpScreen`)
/// plus logic-only Plain pairs.
///
/// PT: Facilitadores (`logsdpRotate`, …) mais os pares Plain somente-lógica.
extension AppDimensLogarithmicFacilitators on num {
  double logsdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.logsdp,
        resolveDefault: (v) => v.logsdp,
      );

  double loghdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.loghdp,
        resolveDefault: (v) => v.loghdp,
      );

  double logwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.logwdp,
        resolveDefault: (v) => v.logwdp,
      );

  double logsdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.logsdp,
        resolveDefault: (v) => v.logsdp,
      );

  double logsdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.logsdp,
        resolveDefault: (v) => v.logsdp,
      );

  double logsdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.logsdp,
        resolveDefault: (v) => v.logsdp,
      );

  double logsdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double logsdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double logsdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double logsdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}
