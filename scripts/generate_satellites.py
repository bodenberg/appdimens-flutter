#!/usr/bin/env python3
"""Generates AppDimens Flutter satellite strategy packages from a config table.

Mirrors the KMP/Dynamic per-strategy files: engine (formula + facade object),
extensions (num getters + facilitators), and barrel. Formulas are transcribed
verbatim from _refs/appdimens-kmp/library-*.
"""
import os
import json

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "packages")

HEADER = '''/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
'''

STRATEGIES = {
    "power": {
        "stem": "pw",
        "class": "DimenPower",
        "title": "Power strategy — sub-linear curve `(axis/300)^0.75`.",
        "formula_doc": "`base × (d/300)^0.75` — perceptual sub-linear growth.",
        "calc": "CalcType.power",
        "qualifier_driven": True,
        "body": """    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    final p =
        math.pow(d / DesignScaleConstants.baseWidthDp, PowerFactors.exponent);
    return StrategyResolution.applyAr(
        base * p.toDouble(), metrics, applyAspectRatio, customSensitivityK);""",
        "extra": """/// Perceptual exponent of the power curve (0.75 — Stevens' exponents).
abstract final class PowerFactors {
  /// EN Sub-linear exponent applied to the normalized axis.
  /// PT Expoente sublinear aplicado ao eixo normalizado.
  static const double exponent = 0.75;
}

""",
    },
    "fluid": {
        "stem": "f",
        "class": "DimenFluid",
        "title": "Fluid strategy — clamped lerp between `base×0.8` and `base×1.2` over `[320, 768]` dp.",
        "formula_doc": "plateau at `b×0.8` below 320 dp, plateau at `b×1.2` above 768 dp, linear lerp between.",
        "calc": "CalcType.fluid",
        "qualifier_driven": True,
        "body": """    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    final minV = base * FluidRange.minScale;
    final maxV = base * FluidRange.maxScale;
    if (d <= FluidRange.minWidth) {
      return StrategyResolution.applyAr(
          minV, metrics, applyAspectRatio, customSensitivityK);
    }
    if (d >= FluidRange.maxWidth) {
      return StrategyResolution.applyAr(
          maxV, metrics, applyAspectRatio, customSensitivityK);
    }
    final t =
        (d - FluidRange.minWidth) / (FluidRange.maxWidth - FluidRange.minWidth);
    final lerped = minV + (maxV - minV) * t;
    return StrategyResolution.applyAr(
        lerped, metrics, applyAspectRatio, customSensitivityK);""",
        "extra": """/// Fluid range constants (CSS-clamp-like plateaus).
abstract final class FluidRange {
  static const double minScale = 0.8;
  static const double maxScale = 1.2;
  static const double minWidth = 320;
  static const double maxWidth = 768;
}

""",
    },
    "auto": {
        "stem": "a",
        "class": "DimenAuto",
        "title": "Auto strategy — linear on phones, log-damped beyond the 480 dp transition.",
        "formula_doc": "`d ≤ 480 : d/300`; else `480/300 + 0.4·ln(1 + (d−480)/300)`.",
        "calc": "CalcType.auto",
        "qualifier_driven": True,
        "body": """    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    double scale;
    if (d <= AutoTransition.pointDp) {
      scale = d * DimenCache.invBaseRatio;
    } else {
      scale = AutoTransition.pointDp * DimenCache.invBaseRatio +
          AutoTransition.slope *
              math.log(1 + (d - AutoTransition.pointDp) * DimenCache.invBaseRatio);
    }
    return StrategyResolution.applyAr(
        base * scale, metrics, applyAspectRatio, customSensitivityK);""",
        "extra": """/// Transition point and slope of the auto curve.
abstract final class AutoTransition {
  static const double pointDp = 480;
  static const double slope = 0.4;
}

""",
    },
    "diagonal": {
        "stem": "dg",
        "class": "DimenDiagonal",
        "title": "Diagonal strategy — screen-diagonal ratio against the design baseline.",
        "formula_doc": "`base × √(min² + max²) / 611.6305` (qualifier-independent).",
        "calc": "CalcType.diagonal",
        "qualifier_driven": False,
        "body": """    return StrategyResolution.applyAr(base * metrics.diagonalScale, metrics,
        applyAspectRatio, customSensitivityK);""",
        "extra": "",
    },
    "fill": {
        "stem": "fl",
        "class": "DimenFill",
        "title": "Fill strategy — CSS `cover`: the larger axis ratio wins.",
        "formula_doc": "`base × max(minSide/300, maxSide/533)` (may crop overflow).",
        "calc": "CalcType.fill",
        "qualifier_driven": False,
        "body": """    final rMin = metrics.minDimensionDp / DesignScaleConstants.baseWidthDp;
    final rMax = metrics.maxDimensionDp / DesignScaleConstants.baseHeightDp;
    return StrategyResolution.applyAr(
        base * math.max(rMin, rMax), metrics, applyAspectRatio, customSensitivityK);""",
        "extra": "",
    },
    "fit": {
        "stem": "ft",
        "class": "DimenFit",
        "title": "Fit strategy — CSS `contain`: the smaller axis ratio wins.",
        "formula_doc": "`base × min(minSide/300, maxSide/533)` (always fits).",
        "calc": "CalcType.fit",
        "qualifier_driven": False,
        "body": """    final rMin = metrics.minDimensionDp / DesignScaleConstants.baseWidthDp;
    final rMax = metrics.maxDimensionDp / DesignScaleConstants.baseHeightDp;
    return StrategyResolution.applyAr(
        base * math.min(rMin, rMax), metrics, applyAspectRatio, customSensitivityK);""",
        "extra": "",
    },
    "interpolated": {
        "stem": "i",
        "class": "DimenInterpolated",
        "title": "Interpolated strategy — fixed 50% blend between raw and fully-scaled values.",
        "formula_doc": "`out = b + (b·d/300 − b) × 0.5`.",
        "calc": "CalcType.interpolated",
        "qualifier_driven": True,
        "body": """    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    final linear = base * (d * DimenCache.invBaseRatio);
    return StrategyResolution.applyAr(
        base + (linear - base) * Interpolation.defaultBlend,
        metrics,
        applyAspectRatio,
        customSensitivityK);""",
        "extra": """/// Blend factor of the interpolated curve.
abstract final class Interpolation {
  /// EN 0.0 = raw base · 1.0 = fully scaled.
  /// PT 0.0 = base crua · 1.0 = totalmente escalada.
  static const double defaultBlend = 0.5;
}

""",
    },
    "logarithmic": {
        "stem": "log",
        "class": "DimenLogarithmic",
        "title": "Logarithmic strategy — symmetric ±0.4·ln damping around the 300 dp baseline.",
        "formula_doc": "`d > 300 : 1 + 0.4·ln(d/300)` · `d ≤ 300 : 1 − 0.4·ln(300/d)`.",
        "calc": "CalcType.logarithmic",
        "qualifier_driven": True,
        "body": """    final d = StrategyResolution.axisDp(metrics, effectiveQualifier);
    double scale;
    if (d > DesignScaleConstants.baseWidthDp) {
      scale =
          1 + LogarithmicCurve.slope * math.log(d * DimenCache.invBaseRatio);
    } else if (d > 0) {
      scale = 1 -
          LogarithmicCurve.slope *
              math.log(DesignScaleConstants.baseWidthDp / d);
    } else {
      scale = 1;
    }
    return StrategyResolution.applyAr(
        base * scale, metrics, applyAspectRatio, customSensitivityK);""",
        "extra": """/// Sensitivity of the logarithmic curve.
abstract final class LogarithmicCurve {
  static const double slope = 0.4;
}

""",
    },
    "perimeter": {
        "stem": "pr",
        "class": "DimenPerimeter",
        "title": "Perimeter strategy — half-perimeter ratio against the design baseline.",
        "formula_doc": "`base × (minSide + maxSide) / 833` (qualifier-independent).",
        "calc": "CalcType.perimeter",
        "qualifier_driven": False,
        "body": """    return StrategyResolution.applyAr(base * metrics.perimeterScale, metrics,
        applyAspectRatio, customSensitivityK);""",
        "extra": "",
    },
    "density": {
        "stem": "d",
        "class": "DimenDensity",
        "title": "Density strategy — physical-density alignment against the 160 dpi reference.",
        "formula_doc": "`base × (dpi / 160)` (qualifier-independent).",
        "calc": "CalcType.density",
        "qualifier_driven": False,
        "body": """    return StrategyResolution.applyAr(base * metrics.density, metrics,
        applyAspectRatio, customSensitivityK);""",
        "extra": "",
    },
}

SW_INVERTERS = [("Ph", "swToPh"), ("Lh", "swToLh"), ("Pw", "swToPw"), ("Lw", "swToLw")]
H_INVERTERS = [("Lw", "phToLw"), ("Pw", "lhToPw")]
W_INVERTERS = [("Lh", "pwToLh"), ("Ph", "lwToPh")]


def cap(s):
    return s[0].upper() + s[1:] if s else s


def gen_engine(name, cfg):
    pkg = f"appdimens_{name}"
    cls = cfg["class"]
    calc = cfg["calc"]
    body = "\n".join("    " + ln.strip() if False else ln for ln in [cfg["body"]])
    needs_math = "math." in cfg["body"]
    needs_factors = bool(cfg["extra"].strip())
    imp = "import 'package:appdimens/appdimens.dart';\n\n"
    if needs_math:
        imp = "import 'dart:math' as math;\n\n" + imp
    if needs_factors:
        imp += "import 'factors.dart';\n"
    imports = imp
    src = HEADER + f"""/// {cfg['title']}
///
/// EN: Formula: {cfg['formula_doc']}
///
/// PT: Fórmula: {cfg['formula_doc']}
{imports}/// {name.capitalize()} strategy kernels (family port parity).
abstract final class {cls} {{
  /// Core {name} kernel used by every extension in this package.
  static double dp(
    double base,
    DimenMetrics metrics,
    DpQualifier effectiveQualifier,
    bool applyAspectRatio,
    double? customSensitivityK,
  ) {{
{body}
  }}

  /// Starts the conditional [StrategyChain] for this strategy.
  static StrategyChain scaled(num value) => StrategyChain(
        base: value.toDouble(),
        formula: dp,
        calcType: {calc},
      );
}}
"""
    path = os.path.join(ROOT, pkg, "lib", "src", f"{name}_engine.dart")
    write(path, src)

    factors = os.path.join(ROOT, pkg, "lib", "src", "factors.dart")
    extra_types = cfg["extra"]
    if extra_types.strip():
        write(factors, HEADER + "/// Curve constants for this strategy.\n" +
              extra_types.replace("import 'dart:math' as math;\n\nimport 'package:appdimens/appdimens.dart';\n\n", ""))
    else:
        write(factors, HEADER + "/// Reserved for future curve tuning.\nlibrary;\n")


def gen_extensions(name, cfg):
    pkg = f"appdimens_{name}"
    cls = cfg["class"]
    stem = cfg["stem"]
    calc = cfg["calc"]

    lines = []
    A = lines.append
    A(HEADER)
    A(f"/// {cfg['title']}")
    A("///")
    A(f"/// EN: `{stem}sdp` family on [num] — suffix grammar identical to the whole")
    A("/// AppDimens family: *(none)* / **a** (aspect ratio) / **i** (ignore multi-window)")
    A("/// / **ia**; inverters **Ph/Lh/Pw/Lw**; `…Px` twins return physical pixels.")
    A("///")
    A(f"/// PT: Família `{stem}sdp` em [num] — gramática de sufixos idêntica a toda a")
    A("/// família AppDimens: *(nenhum)* / **a** (proporção) / **i** (ignora multi-janela)")
    A("/// / **ia**; inversores **Ph/Lh/Pw/Lw**; gêmeos `…Px` retornam pixels físicos.")
    A("import 'package:appdimens/appdimens.dart';")
    A("")
    A(f"import '{name}_engine.dart';")
    A("")
    A(f"extension AppDimens{name.capitalize()}Dp on num {{")
    A("  // ── %ssdp (smallest width) ────────────────────────────────────────────────────" % stem)
    A(f"  double get {stem}sdp => _v(DpQualifier.smallWidth);")
    A(f"  double get {stem}sdpa => _v(DpQualifier.smallWidth, ar: true);")
    A(f"  double get {stem}sdpi => _v(DpQualifier.smallWidth, mw: true);")
    A(f"  double get {stem}sdpia => _v(DpQualifier.smallWidth, ar: true, mw: true);")
    A("")
    for suf, inv in SW_INVERTERS:
        for flags, flag_args in [("", ""), ("a", ", ar: true"), ("i", ", mw: true"), ("ia", ", ar: true, mw: true")]:
            A(f"  double get {stem}sdp{suf}{flags} => _v(DpQualifier.smallWidth, inv: Inverter.{inv}{flag_args});")
    A("")
    A(f"  double get {stem}sdpPx => {stem}sdp * AppDimensScope.metricsOrDefault.density;")
    A("")
    A("  // ── %shdp (height) ────────────────────────────────────────────────────────────" % stem)
    A(f"  double get {stem}hdp => _v(DpQualifier.height);")
    A(f"  double get {stem}hdpa => _v(DpQualifier.height, ar: true);")
    A(f"  double get {stem}hdpi => _v(DpQualifier.height, mw: true);")
    A(f"  double get {stem}hdpia => _v(DpQualifier.height, ar: true, mw: true);")
    for suf, inv in H_INVERTERS:
        for flags, flag_args in [("", ""), ("a", ", ar: true"), ("i", ", mw: true"), ("ia", ", ar: true, mw: true")]:
            A(f"  double get {stem}hdp{suf}{flags} => _v(DpQualifier.height, inv: Inverter.{inv}{flag_args});")
    A("")
    A(f"  double get {stem}hdpPx => {stem}hdp * AppDimensScope.metricsOrDefault.density;")
    A("")
    A("  // ── %swdp (width) ─────────────────────────────────────────────────────────────" % stem)
    A(f"  double get {stem}wdp => _v(DpQualifier.width);")
    A(f"  double get {stem}wdpa => _v(DpQualifier.width, ar: true);")
    A(f"  double get {stem}wdpi => _v(DpQualifier.width, mw: true);")
    A(f"  double get {stem}wdpia => _v(DpQualifier.width, ar: true, mw: true);")
    for suf, inv in W_INVERTERS:
        for flags, flag_args in [("", ""), ("a", ", ar: true"), ("i", ", mw: true"), ("ia", ", ar: true, mw: true")]:
            A(f"  double get {stem}wdp{suf}{flags} => _v(DpQualifier.width, inv: Inverter.{inv}{flag_args});")
    A("")
    A(f"  double get {stem}wdpPx => {stem}wdp * AppDimensScope.metricsOrDefault.density;")
    A("")
    A("  // ── Sp stems ──────────────────────────────────────────────────────────────────")
    A(f"  double get {stem}ssp => {stem}sdp;")
    A(f"  double get {stem}sspa => {stem}sdpa;")
    A(f"  double get {stem}sspi => {stem}sdpi;")
    A(f"  double get {stem}sspia => {stem}sdpia;")
    A(f"  double get {stem}hsp => {stem}hdp;")
    A(f"  double get {stem}wsp => {stem}wdp;")
    A("")
    A("  /// No-font-scale stem: pre-divides by the font scale so rendering cancels.")
    A(f"  double get {stem}sem {{")
    A("    final fs = AppDimensScope.metricsOrDefault.fontScale;")
    A(f"    return fs > 0 ? {stem}sdp / fs : {stem}sdp;")
    A("  }")
    A("")
    A(f"  double get {stem}hem {{")
    A("    final fs = AppDimensScope.metricsOrDefault.fontScale;")
    A(f"    return fs > 0 ? {stem}hdp / fs : {stem}hdp;")
    A("  }")
    A("")
    A(f"  double get {stem}wem {{")
    A("    final fs = AppDimensScope.metricsOrDefault.fontScale;")
    A(f"    return fs > 0 ? {stem}wdp / fs : {stem}wdp;")
    A("  }")
    A("")
    A(f"  double get {stem}sspPx => {stem}ssp * AppDimensScope.metricsOrDefault.density * _safeFs();")
    A("")
    A("  double _safeFs() {")
    A("    final fs = AppDimensScope.metricsOrDefault.fontScale;")
    A("    return fs > 0 ? fs : 1.0;")
    A("  }")
    A("")
    A("  double _v(")
    A("    DpQualifier q, {")
    A("    Inverter inv = Inverter.standard,")
    A("    bool ar = false,")
    A("    bool mw = false,")
    A("  }) =>")
    A("      StrategyResolution.value(")
    A("        toDouble(),")
    A(f"        {cls}.dp,")
    A("        q,")
    A("        inv,")
    A("        ignoreMultiWindows: mw,")
    A("        applyAspectRatio: ar,")
    A(f"        calcType: {calc},")
    A("      );")
    A("}")
    A("")
    A("/// EN: Facilitators (`" + stem + "sdpRotate`, `" + stem + "sdpMode`, `"
      + stem + "sdpQualifier`, `" + stem + "sdpScreen`)")
    A("/// plus logic-only Plain pairs.")
    A("///")
    A("/// PT: Facilitadores (`" + stem + "sdpRotate`, …) mais os pares Plain somente-lógica.")
    A(f"extension AppDimens{name.capitalize()}Facilitators on num {{")
    A(f"  double {stem}sdpRotate(num rotationValue,")
    A("          {OrientationRequest orientation = OrientationRequest.landscape}) =>")
    A("      StrategyBranching.rotate(")
    A("        base: this,")
    A("        alternate: rotationValue,")
    A("        orientation: orientation,")
    A(f"        resolveWhenMatched: (v) => v.{stem}sdp,")
    A(f"        resolveDefault: (v) => v.{stem}sdp,")
    A("      );")
    A("")
    A(f"  double {stem}hdpRotate(num rotationValue,")
    A("          {OrientationRequest orientation = OrientationRequest.landscape}) =>")
    A("      StrategyBranching.rotate(")
    A("        base: this,")
    A("        alternate: rotationValue,")
    A("        orientation: orientation,")
    A(f"        resolveWhenMatched: (v) => v.{stem}hdp,")
    A(f"        resolveDefault: (v) => v.{stem}hdp,")
    A("      );")
    A("")
    A(f"  double {stem}wdpRotate(num rotationValue,")
    A("          {OrientationRequest orientation = OrientationRequest.landscape}) =>")
    A("      StrategyBranching.rotate(")
    A("        base: this,")
    A("        alternate: rotationValue,")
    A("        orientation: orientation,")
    A(f"        resolveWhenMatched: (v) => v.{stem}wdp,")
    A(f"        resolveDefault: (v) => v.{stem}wdp,")
    A("      );")
    A("")
    A(f"  double {stem}sdpMode(num modeValue, UiModeType uiModeType) =>")
    A("      StrategyBranching.mode(")
    A("        base: this,")
    A("        alternate: modeValue,")
    A("        uiModeType: uiModeType,")
    A(f"        resolveWhenMatched: (v) => v.{stem}sdp,")
    A(f"        resolveDefault: (v) => v.{stem}sdp,")
    A("      );")
    A("")
    A(f"  double {stem}sdpQualifier(")
    A("          num qualifiedValue, DpQualifier qualifierType, num qualifierValue) =>")
    A("      StrategyBranching.qualifier(")
    A("        base: this,")
    A("        alternate: qualifiedValue,")
    A("        qualifierType: qualifierType,")
    A("        qualifierValue: qualifierValue,")
    A(f"        resolveWhenMatched: (v) => v.{stem}sdp,")
    A(f"        resolveDefault: (v) => v.{stem}sdp,")
    A("      );")
    A("")
    A(f"  double {stem}sdpScreen(num screenValue, UiModeType uiModeType,")
    A("          DpQualifier qualifierType, num qualifierValue) =>")
    A("      StrategyBranching.screen(")
    A("        base: this,")
    A("        alternate: screenValue,")
    A("        uiModeType: uiModeType,")
    A("        qualifierType: qualifierType,")
    A("        qualifierValue: qualifierValue,")
    A(f"        resolveWhenMatched: (v) => v.{stem}sdp,")
    A(f"        resolveDefault: (v) => v.{stem}sdp,")
    A("      );")
    A("")
    A(f"  double {stem}sdpRotatePlain(num alternative,")
    A("          {OrientationRequest orientation = OrientationRequest.landscape}) =>")
    A("      StrategyBranching.matchesOrientation(orientation)")
    A("          ? alternative.toDouble()")
    A("          : toDouble();")
    A("")
    A(f"  double {stem}sdpModePlain(num alternative, UiModeType uiModeType) =>")
    A("      StrategyBranching.matchesUiMode(uiModeType)")
    A("          ? alternative.toDouble()")
    A("          : toDouble();")
    A("")
    A(f"  double {stem}sdpQualifierPlain(")
    A("          num alternative, DpQualifier qualifierType, num qualifierValue) =>")
    A("      StrategyBranching.matchesQualifier(qualifierType, qualifierValue)")
    A("          ? alternative.toDouble()")
    A("          : toDouble();")
    A("")
    A(f"  double {stem}sdpScreenPlain(num alternative, UiModeType uiModeType,")
    A("          DpQualifier qualifierType, num qualifierValue) =>")
    A("      StrategyBranching.matchesUiMode(uiModeType) &&")
    A("              StrategyBranching.matchesQualifier(qualifierType, qualifierValue)")
    A("          ? alternative.toDouble()")
    A("          : toDouble();")
    A("}")
    A("")

    path = os.path.join(ROOT, pkg, "lib", "src", f"{name}_extensions.dart")
    write(path, "\n".join(lines))


def gen_barrel(name, cfg):
    pkg = f"appdimens_{name}"
    src = HEADER + f"""/// AppDimens {name.capitalize()} — {name} strategy module of the AppDimens
/// Flutter family (port of `appdimens-dynamic-{name}` /
/// `appdimens-kmp-{name}`).
library;

export 'package:appdimens/appdimens.dart'
    show DpQualifier, Inverter, OrientationRequest, UiModeType;
export 'src/{name}_engine.dart';
export 'src/{name}_extensions.dart';
export 'src/factors.dart';
"""
    path = os.path.join(ROOT, pkg, "lib", f"{pkg}.dart")
    write(path, src)


def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)


for name, cfg in STRATEGIES.items():
    gen_engine(name, cfg)
    gen_extensions(name, cfg)
    gen_barrel(name, cfg)
    print("generated", name)
