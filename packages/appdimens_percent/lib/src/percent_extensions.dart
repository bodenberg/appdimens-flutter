/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Percent strategy — `num` extension surface (`psdp · phdp · pwdp` and the
/// sp stems `pssp · phsp · pwsp` / `psem · phem · pwem`).
import 'package:appdimens/appdimens.dart';

import 'percent_engine.dart';

/// EN: Percent family on [num]. The dp curve follows the Scaled linear law on
/// the chosen axis; suffix grammar identical to the whole family:
/// *(none)* / **a** (aspect ratio) / **i** (ignore multi-window) / **ia**;
/// inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.
///
/// PT: Família Percent em [num]. A curva dp segue a lei linear do Scaled no
/// eixo escolhido; gramática de sufixos idêntica a toda a família:
/// *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela) / **ia**;
/// inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.
extension AppDimensPercentDp on num {
  // ── psdp (smallest width) ───────────────────────────────────────────────

  double get psdp => _v(DpQualifier.smallWidth);
  double get psdpa => _v(DpQualifier.smallWidth, ar: true);
  double get psdpi => _v(DpQualifier.smallWidth, mw: true);
  double get psdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);

  double get psdpPh => _v(DpQualifier.smallWidth, inv: Inverter.swToPh);
  double get psdpPha => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true);
  double get psdpPhi => _v(DpQualifier.smallWidth, inv: Inverter.swToPh, mw: true);
  double get psdpPhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPh, ar: true, mw: true);

  double get psdpLh => _v(DpQualifier.smallWidth, inv: Inverter.swToLh);
  double get psdpLha => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true);
  double get psdpLhi => _v(DpQualifier.smallWidth, inv: Inverter.swToLh, mw: true);
  double get psdpLhia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLh, ar: true, mw: true);

  double get psdpPw => _v(DpQualifier.smallWidth, inv: Inverter.swToPw);
  double get psdpPwa => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true);
  double get psdpPwi => _v(DpQualifier.smallWidth, inv: Inverter.swToPw, mw: true);
  double get psdpPwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToPw, ar: true, mw: true);

  double get psdpLw => _v(DpQualifier.smallWidth, inv: Inverter.swToLw);
  double get psdpLwa => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true);
  double get psdpLwi => _v(DpQualifier.smallWidth, inv: Inverter.swToLw, mw: true);
  double get psdpLwia =>
      _v(DpQualifier.smallWidth, inv: Inverter.swToLw, ar: true, mw: true);

  double get psdpPx => psdp * AppDimensScope.metricsOrDefault.density;

  // ── phdp (height) ───────────────────────────────────────────────────────

  double get phdp => _v(DpQualifier.height);
  double get phdpa => _v(DpQualifier.height, ar: true);
  double get phdpi => _v(DpQualifier.height, mw: true);
  double get phdpia => _v(DpQualifier.height, ar: true, mw: true);

  double get phdpLw => _v(DpQualifier.height, inv: Inverter.phToLw);
  double get phdpPw => _v(DpQualifier.height, inv: Inverter.lhToPw);

  double get phdpPx => phdp * AppDimensScope.metricsOrDefault.density;

  // ── pwdp (width) ────────────────────────────────────────────────────────

  double get pwdp => _v(DpQualifier.width);
  double get pwdpa => _v(DpQualifier.width, ar: true);
  double get pwdpi => _v(DpQualifier.width, mw: true);
  double get pwdpia => _v(DpQualifier.width, ar: true, mw: true);

  double get pwdpLh => _v(DpQualifier.width, inv: Inverter.pwToLh);
  double get pwdpPh => _v(DpQualifier.width, inv: Inverter.lwToPh);

  double get pwdpPx => pwdp * AppDimensScope.metricsOrDefault.density;

  // ── Sp stems ────────────────────────────────────────────────────────────

  double get pssp => psdp;
  double get psspa => psdpa;
  double get psspi => psdpi;
  double get psspia => psdpia;
  double get phsp => phdp;
  double get pwsp => pwdp;

  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.
  double get psem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? psdp / fs : psdp;
  }

  double get phem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? phdp / fs : phdp;
  }

  double get pwem {
    final fs = AppDimensScope.metricsOrDefault.fontScale;
    return fs > 0 ? pwdp / fs : pwdp;
  }

  double get psspPx => pssp * AppDimensScope.metricsOrDefault.density *
      _safeFs();

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
        DimenPercent.dp,
        q,
        inv,
        ignoreMultiWindows: mw,
        applyAspectRatio: ar,
        calcType: CalcType.percent,
      );
}

/// EN: Percent facilitators — `psdpRotate`, `psdpMode`, `psdpQualifier`,
/// `psdpScreen`, plus logic-only Plain pairs and literal space helpers.
///
/// PT: Facilitadores Percent — `psdpRotate`, `psdpMode`, `psdpQualifier`,
/// `psdpScreen`, mais os pares Plain somente-lógica e os auxiliares de
/// espaço literal.
extension AppDimensPercentFacilitators on num {
  double psdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.psdp,
        resolveDefault: (v) => v.psdp,
      );

  double phdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.phdp,
        resolveDefault: (v) => v.phdp,
      );

  double pwdpRotate(num rotationValue,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.rotate(
        base: this,
        alternate: rotationValue,
        orientation: orientation,
        resolveWhenMatched: (v) => v.pwdp,
        resolveDefault: (v) => v.pwdp,
      );

  double psdpMode(num modeValue, UiModeType uiModeType) =>
      StrategyBranching.mode(
        base: this,
        alternate: modeValue,
        uiModeType: uiModeType,
        resolveWhenMatched: (v) => v.psdp,
        resolveDefault: (v) => v.psdp,
      );

  double psdpQualifier(
          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.qualifier(
        base: this,
        alternate: qualifiedValue,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.psdp,
        resolveDefault: (v) => v.psdp,
      );

  double psdpScreen(num screenValue, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.screen(
        base: this,
        alternate: screenValue,
        uiModeType: uiModeType,
        qualifierType: qualifierType,
        qualifierValue: qualifierValue,
        resolveWhenMatched: (v) => v.psdp,
        resolveDefault: (v) => v.psdp,
      );

  // Logic-only Plain pairs.
  double psdpRotatePlain(num alternative,
          {OrientationRequest orientation = OrientationRequest.landscape}) =>
      StrategyBranching.matchesOrientation(orientation)
          ? alternative.toDouble()
          : toDouble();

  double psdpModePlain(num alternative, UiModeType uiModeType) =>
      StrategyBranching.matchesUiMode(uiModeType)
          ? alternative.toDouble()
          : toDouble();

  double psdpQualifierPlain(
          num alternative, DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();

  double psdpScreenPlain(num alternative, UiModeType uiModeType,
          DpQualifier qualifierType, num qualifierValue) =>
      StrategyBranching.matchesUiMode(uiModeType) &&
              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)
          ? alternative.toDouble()
          : toDouble();
}

/// EN: Literal percentage space helpers (`30.spaceW` = 30% of the width).
///
/// PT: Auxiliares de espaço percentual literal (`30.spaceW` = 30% da largura).
extension AppDimensPercentSpace on num {
  double get spaceW => DimenPercent.spaceW(toDouble());
  double get spaceH => DimenPercent.spaceH(toDouble());
  double get spaceSw => DimenPercent.spaceSw(toDouble());
  double spaceOf(num referenceDp) =>
      DimenPercent.space(toDouble(), referenceDp.toDouble());
}
