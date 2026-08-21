/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// INTERNAL: shared resolution machinery for the family satellite packages
/// (percent, power, fluid, …). Not meant for direct application use — import
/// `package:appdimens/appdimens.dart` plus the satellite barrels instead.
import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/orientation.dart';
import '../common/ui_mode_type.dart';
import '../core/dimen_cache.dart';
import '../core/dimen_calculation_plumbing.dart';
import '../core/dimen_metrics.dart';
import '../scaled/dimen_scaled_builder.dart' show DpQualifierEntry, ScaledEntry;

/// Pure strategy formula over a resolved axis: receives the base value, the
/// coherent snapshot, the effective (post-inverter) qualifier, the aspect
/// ratio flag and the custom sensitivity.
typedef StrategyFormula = double Function(
  double base,
  DimenMetrics metrics,
  DpQualifier effectiveQualifier,
  bool applyAspectRatio,
  double? customSensitivityK,
);

/// EN: Shared scope-based resolution used by every satellite stem
/// (`psdp`, `pwsdp`, …): multi-window guard → formula → unit conversion.
/// Mirrors the Kotlin per-strategy `calculate<Strategy>Dp` plumbing.
///
/// PT: Resolução compartilhada por escopo usada por todos os stems dos
/// satélites (`psdp`, `pwsdp`, …): guarda de multi-janela → fórmula →
/// conversão de unidade. Espelha o encanamento Kotlin por estratégia.
abstract final class StrategyResolution {
  /// Logical-dp value through the published scope.
  static double value(
    double base,
    StrategyFormula formula,
    DpQualifier qualifier,
    Inverter inverter, {
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
    CalcType calcType = CalcType.auto,
    ValueType valueType = ValueType.dp,
  }) {
    final m = AppDimensScope.metricsOrDefault;
    if (ignoreMultiWindows && m.isInMultiWindowMode) {
      return _unitConvert(base, m, valueType);
    }
    final effectiveQ = DimenCalculationPlumbing.effectiveQualifier(
      qualifier,
      inverter,
      m.isLandscape,
      m.isPortrait,
    );
    final computed =
        formula(base, m, effectiveQ, applyAspectRatio, customSensitivityK);
    return _unitConvertSp(computed, m, valueType);
  }

  /// Explicit-context variant (full engine path, cached when eligible).
  static double valueFor(
    AppDimensContextLike scope,
    double base,
    StrategyFormula formula,
    DpQualifier qualifier, {
    Inverter inverter = Inverter.standard,
    bool ignoreMultiWindows = false,
    bool applyAspectRatio = false,
    double? customSensitivityK,
    CalcType calcType = CalcType.auto,
    ValueType valueType = ValueType.dp,
  }) {
    final configuration = scope.configuration;
    final key = CacheKey(
      baseValue: base,
      isLandscape: configuration.isLandscape,
      ignoreMultiWindows: ignoreMultiWindows,
      calcType: calcType,
      qualifier: qualifier,
      inverter: inverter,
      applyAspectRatio: applyAspectRatio,
      valueType: valueType,
      customSensitivityK: customSensitivityK,
    );
    final metrics = scope.dimenMetrics;
    return DimenCache.getOrPutFor(metrics, key, () {
      if (ignoreMultiWindows && metrics.isInMultiWindowMode) {
        return _unitConvert(base, metrics, valueType);
      }
      final effectiveQ = DimenCalculationPlumbing.effectiveQualifier(
        qualifier,
        inverter,
        configuration.isLandscape,
        configuration.isPortrait,
      );
      final computed = formula(
          base, metrics, effectiveQ, applyAspectRatio, customSensitivityK);
      return _unitConvertSp(computed, metrics, valueType);
    });
  }

  static double _unitConvert(double v, DimenMetrics m, ValueType t) {
    switch (t) {
      case ValueType.dp:
      case ValueType.spWithScale:
      case ValueType.spNoScale:
        return v;
      case ValueType.px:
        return v * m.density;
      case ValueType.spPxWithScale:
        return v * m.density * (m.fontScale > 0 ? m.fontScale : 1.0);
      case ValueType.spPxNoScale:
        return v * m.density;
    }
  }

  static double _unitConvertSp(double v, DimenMetrics m, ValueType t) {
    switch (t) {
      case ValueType.dp:
      case ValueType.px:
      case ValueType.spWithScale:
      case ValueType.spPxWithScale:
        return _unitConvert(v, m, t);
      case ValueType.spNoScale:
      case ValueType.spPxNoScale:
        final fs = m.fontScale;
        final divided = fs > 0 ? v / fs : v;
        return _unitConvert(divided, m, t);
    }
  }

  /// Applies the satellite aspect-ratio multiplier **after** the base formula
  /// (`1 + k·lnAR`, default sensitivity when [k] is null).
  static double applyAr(
      double value, DimenMetrics m, bool applyAspectRatio, double? k) {
    if (!applyAspectRatio) return value;
    return value * m.aspectRatioMultiplier(k);
  }

  /// Axis dimension in dp for the effective qualifier.
  static double axisDp(DimenMetrics m, DpQualifier effectiveQualifier) =>
      switch (effectiveQualifier) {
        DpQualifier.smallWidth => m.smallestWidthDp,
        DpQualifier.width => m.screenWidthDp.toDouble(),
        DpQualifier.height => m.screenHeightDp.toDouble(),
      };
}

/// Shared conditional branching for facilitators (`*Rotate`, `*Mode`,
/// `*Qualifier`, `*Screen`) and their logic-only Plain pairs.
abstract final class StrategyBranching {
  static bool matchesOrientation(OrientationRequest orientation) {
    final m = AppDimensScope.metricsOrDefault;
    return switch (orientation) {
      OrientationRequest.landscape => m.isLandscape,
      OrientationRequest.portrait => m.isPortrait,
      OrientationRequest.any => true,
    };
  }

  static bool matchesUiMode(UiModeType uiModeType) =>
      AppDimensScope.uiModeTypeOrDefault == uiModeType;

  static bool matchesQualifier(DpQualifier type, num value) {
    final m = AppDimensScope.metricsOrDefault;
    final metric = switch (type) {
      DpQualifier.smallWidth => m.smallestWidthDp,
      DpQualifier.width => m.screenWidthDp.toDouble(),
      DpQualifier.height => m.screenHeightDp.toDouble(),
    };
    return metric >= value.toDouble();
  }

  static double rotate({
    required num base,
    required num alternate,
    required OrientationRequest orientation,
    required double Function(num value) resolveWhenMatched,
    required double Function(num value) resolveDefault,
  }) =>
      matchesOrientation(orientation)
          ? resolveWhenMatched(alternate)
          : resolveDefault(base);

  static double mode({
    required num base,
    required num alternate,
    required UiModeType uiModeType,
    required double Function(num value) resolveWhenMatched,
    required double Function(num value) resolveDefault,
  }) =>
      matchesUiMode(uiModeType)
          ? resolveWhenMatched(alternate)
          : resolveDefault(base);

  static double qualifier({
    required num base,
    required num alternate,
    required DpQualifier qualifierType,
    required num qualifierValue,
    required double Function(num value) resolveWhenMatched,
    required double Function(num value) resolveDefault,
  }) =>
      matchesQualifier(qualifierType, qualifierValue)
          ? resolveWhenMatched(alternate)
          : resolveDefault(base);

  static double screen({
    required num base,
    required num alternate,
    required UiModeType uiModeType,
    required DpQualifier qualifierType,
    required num qualifierValue,
    required double Function(num value) resolveWhenMatched,
    required double Function(num value) resolveDefault,
  }) =>
      matchesUiMode(uiModeType) &&
              matchesQualifier(qualifierType, qualifierValue)
          ? resolveWhenMatched(alternate)
          : resolveDefault(base);
}

/// EN: Generic conditional chain builder shared by the satellite strategies
/// (`DimenPercent.scaled(100)…`, `DimenPower.scaled(100)…`). Same four-level
/// priority model as [DimenScaled]; the winner value is scaled through the
/// strategy [formula].
///
/// PT: Construtor genérico de cadeias condicionais compartilhado pelas
/// estratégias satélites (`DimenPercent.scaled(100)…`, …). Mesmo modelo de
/// prioridades em quatro níveis de [DimenScaled]; o valor vencedor é escalado
/// pela [formula] da estratégia.
class StrategyChain {
  final double base;
  final List<ScaledEntry> entries;
  final bool ignoreMultiWindows;
  final bool applyAspectRatio;
  final double? customSensitivityK;
  final StrategyFormula formula;
  final CalcType calcType;

  const StrategyChain({
    required this.base,
    this.entries = const [],
    this.ignoreMultiWindows = false,
    this.applyAspectRatio = false,
    this.customSensitivityK,
    required this.formula,
    this.calcType = CalcType.auto,
  });

  StrategyChain _copy({
    List<ScaledEntry>? entries,
    bool? ignoreMultiWindows,
    bool? applyAspectRatio,
    double? customSensitivityK,
    bool clearCustomK = false,
  }) =>
      StrategyChain(
        base: base,
        formula: formula,
        calcType: calcType,
        entries: entries ?? this.entries,
        ignoreMultiWindows: ignoreMultiWindows ?? this.ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio ?? this.applyAspectRatio,
        customSensitivityK: clearCustomK
            ? null
            : (customSensitivityK ?? this.customSensitivityK),
      );

  StrategyChain withAspectRatio({bool apply = true, double? sensitivityK}) =>
      _copy(applyAspectRatio: apply, customSensitivityK: sensitivityK);

  StrategyChain withIgnoreMultiWindows({bool ignore = true}) =>
      _copy(ignoreMultiWindows: ignore);

  StrategyChain screen(
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue,
    num customValue, {
    OrientationRequest orientation = OrientationRequest.any,
    DpQualifier? finalQualifierResolver,
    Inverter inverter = Inverter.standard,
  }) =>
      _add(ScaledEntry(
        uiModeType: uiModeType,
        dpQualifierEntry:
            DpQualifierEntry(qualifierType, qualifierValue.toDouble()),
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 1,
        inverter: inverter,
      ));

  StrategyChain screenMode(
    UiModeType uiModeType,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    OrientationRequest orientation = OrientationRequest.any,
    Inverter inverter = Inverter.standard,
  }) =>
      _add(ScaledEntry(
        uiModeType: uiModeType,
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 2,
        inverter: inverter,
      ));

  StrategyChain screenQualifier(
    DpQualifier qualifierType,
    num qualifierValue,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    OrientationRequest orientation = OrientationRequest.any,
    Inverter inverter = Inverter.standard,
  }) =>
      _add(ScaledEntry(
        dpQualifierEntry:
            DpQualifierEntry(qualifierType, qualifierValue.toDouble()),
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 3,
        inverter: inverter,
      ));

  StrategyChain screenOrientation(
    OrientationRequest orientation,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    Inverter inverter = Inverter.standard,
  }) =>
      _add(ScaledEntry(
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 4,
        inverter: inverter,
      ));

  StrategyChain _add(ScaledEntry entry) {
    final next = [...entries, entry]..sort((a, b) {
        final p = a.priority.compareTo(b.priority);
        if (p != 0) return p;
        return (b.dpQualifierEntry?.value ?? 0)
            .compareTo(a.dpQualifierEntry?.value ?? 0);
      });
    return _copy(entries: next);
  }

  bool _match(ScaledEntry e, DimenMetrics metrics, UiModeType uiMode) {
    if (e.uiModeType != null && uiMode != e.uiModeType) return false;
    final q = e.dpQualifierEntry;
    if (q != null) {
      final metric = switch (q.type) {
        DpQualifier.smallWidth => metrics.smallestWidthDp,
        DpQualifier.width => metrics.screenWidthDp.toDouble(),
        DpQualifier.height => metrics.screenHeightDp.toDouble(),
      };
      if (metric < q.value) return false;
    }
    return switch (e.orientation) {
      OrientationRequest.any => true,
      OrientationRequest.portrait => metrics.isPortrait,
      OrientationRequest.landscape => metrics.isLandscape,
    };
  }

  /// Resolves through an explicit scope (logical dp).
  double resolveFor(
    AppDimensContextLike scope, {
    DpQualifier qualifier = DpQualifier.smallWidth,
  }) {
    final metrics = scope.dimenMetrics;
    for (final e in entries) {
      if (_match(e, metrics, scope.uiModeType)) {
        return StrategyResolution.valueFor(
          scope,
          e.customValue,
          formula,
          e.finalQualifierResolver ?? qualifier,
          inverter: e.inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK,
          calcType: calcType,
        );
      }
    }
    return StrategyResolution.valueFor(
      scope,
      base,
      formula,
      qualifier,
      ignoreMultiWindows: ignoreMultiWindows,
      applyAspectRatio: applyAspectRatio,
      customSensitivityK: customSensitivityK,
      calcType: calcType,
    );
  }

  /// Resolves through the published scope (logical dp).
  double resolve({DpQualifier qualifier = DpQualifier.smallWidth}) {
    final m = AppDimensScope.metricsOrDefault;
    final ui = AppDimensScope.uiModeTypeOrDefault;
    for (final e in entries) {
      if (_match(e, m, ui)) {
        return StrategyResolution.value(
          e.customValue,
          formula,
          e.finalQualifierResolver ?? qualifier,
          e.inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK,
          calcType: calcType,
        );
      }
    }
    return StrategyResolution.value(
      base,
      formula,
      qualifier,
      Inverter.standard,
      ignoreMultiWindows: ignoreMultiWindows,
      applyAspectRatio: applyAspectRatio,
      customSensitivityK: customSensitivityK,
      calcType: calcType,
    );
  }
}
