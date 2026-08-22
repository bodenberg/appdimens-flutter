/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Immutable conditional builder chains (`DimenScaled` / `ScaledSp`) with the
/// family priority model: **UiMode+Qualifier → UiMode → Qualifier →
/// Orientation**.
library;

import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/orientation.dart';
import '../common/ui_mode_type.dart';
import '../core/app_dimens_context.dart';
import '../core/dimen_cache.dart';
import '../core/dimen_scaled_engine.dart';

/// One conditional branch inside a builder chain.
class ScaledEntry {
  final UiModeType? uiModeType;
  final DpQualifierEntry? dpQualifierEntry;
  final OrientationRequest orientation;
  final double customValue;
  final DpQualifier? finalQualifierResolver;
  final int priority;
  final Inverter inverter;
  final bool fontScale;

  const ScaledEntry({
    this.uiModeType,
    this.dpQualifierEntry,
    this.orientation = OrientationRequest.any,
    required this.customValue,
    this.finalQualifierResolver,
    required this.priority,
    this.inverter = Inverter.standard,
    this.fontScale = true,
  });
}

/// Typed qualifier threshold (`type ≥ value`).
class DpQualifierEntry {
  final DpQualifier type;
  final double value;
  const DpQualifierEntry(this.type, this.value);
}

/// EN: Immutable builder for conditionally-scaled dimensions. Start from
/// `100.scaledDp` (or `DimenSdp.scaled(100)`), add `.screen(...)` branches and
/// resolve with the terminal getters. Entries are matched by priority:
/// 1. ui-mode **and** qualifier **and** orientation
/// 2. ui-mode and orientation
/// 3. qualifier and orientation
/// 4. orientation only
/// The winner's custom value (else the base) is scaled through the full
/// engine with the entry's resolver/inverter.
///
/// PT: Construtor imutável para dimensões condicionalmente escaladas. Comece
/// com `100.scaledDp` (ou `DimenSdp.scaled(100)`), adicione ramos
/// `.screen(...)` e resolva com os terminais. Os ramos são avaliados por
/// prioridade (ui-mode + qualificador + orientação → … → apenas orientação).
/// O valor customizado do vencedor (ou a base) é escalado pelo motor completo.
class DimenScaled {
  final double base;
  final List<ScaledEntry> entries;
  final bool ignoreMultiWindows;
  final bool applyAspectRatio;
  final double? customSensitivityK;

  const DimenScaled(
    this.base, {
    this.entries = const [],
    this.ignoreMultiWindows = false,
    this.applyAspectRatio = false,
    this.customSensitivityK,
  });

  DimenScaled _copy({
    List<ScaledEntry>? entries,
    bool? ignoreMultiWindows,
    bool? applyAspectRatio,
    double? customSensitivityK,
    bool clearCustomK = false,
  }) =>
      DimenScaled(
        base,
        entries: entries ?? this.entries,
        ignoreMultiWindows: ignoreMultiWindows ?? this.ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio ?? this.applyAspectRatio,
        customSensitivityK: clearCustomK
            ? null
            : (customSensitivityK ?? this.customSensitivityK),
      );

  /// Enables the aspect-ratio aware curve.
  DimenScaled withAspectRatio({bool apply = true, double? sensitivityK}) =>
      _copy(applyAspectRatio: apply, customSensitivityK: sensitivityK);

  /// Suppresses scaling inside multi-window modes.
  DimenScaled withIgnoreMultiWindows({bool ignore = true}) =>
      _copy(ignoreMultiWindows: ignore);

  // ── Branches (priority 1 → 4) ───────────────────────────────────────────

  /// P1 — matches ui-mode AND qualifier threshold.
  DimenScaled screen(
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

  /// P2 — matches ui-mode (and optional orientation).
  DimenScaled screenMode(
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

  /// P3 — matches a qualifier threshold (and optional orientation).
  DimenScaled screenQualifier(
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

  /// P4 — matches an orientation only.
  DimenScaled screenOrientation(
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

  DimenScaled _add(ScaledEntry entry) {
    final next = [...entries, entry]..sort((a, b) {
        final p = a.priority.compareTo(b.priority);
        if (p != 0) return p;
        return (b.dpQualifierEntry?.value ?? 0)
            .compareTo(a.dpQualifierEntry?.value ?? 0);
      });
    return _copy(entries: next);
  }

  // ── Resolution ──────────────────────────────────────────────────────────

  bool _match(ScaledEntry e, AppDimensContextLike scope) {
    final metrics = scope.dimenMetrics;
    if (e.uiModeType != null && scope.uiModeType != e.uiModeType) return false;
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

  /// Resolves against an explicit window [context] (logical dp).
  double resolve(AppDimensContext context,
      {DpQualifier qualifier = DpQualifier.smallWidth}) {
    for (final e in entries) {
      if (_match(e, context)) {
        return DimenScaledEngine.resolveScaledDp(
          e.customValue,
          context,
          e.finalQualifierResolver ?? qualifier,
          inverter: e.inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK,
        );
      }
    }
    return DimenScaledEngine.resolveScaledDp(
      base,
      context,
      qualifier,
      ignoreMultiWindows: ignoreMultiWindows,
      applyAspectRatio: applyAspectRatio,
      customSensitivityK: customSensitivityK,
    );
  }

  /// Resolves through the published scope (logical dp). Requires
  /// `AppDimensProvider` (or an explicit context publication).
  double get sdp => _resolveScope(DpQualifier.smallWidth);

  double get hdp => _resolveScope(DpQualifier.height);

  double get wdp => _resolveScope(DpQualifier.width);

  double _resolveScope(DpQualifier qualifier) {
    final ctx = AppDimensScope.context;
    if (ctx == null) {
      throw StateError('No AppDimensScope context published. Wrap your app '
          'in AppDimensProvider or call resolve(context).');
    }
    return resolve(ctx as AppDimensContext, qualifier: qualifier);
  }
}

/// EN: Sp variant of [DimenScaled] — same priority model plus per-branch
/// [fontScale] control; started via `16.scaledSp`.
///
/// PT: Variante sp de [DimenScaled] — mesmo modelo de prioridades com controle
/// de [fontScale] por ramo; iniciada via `16.scaledSp`.
class ScaledSp {
  final double base;
  final List<ScaledEntry> entries;
  final bool ignoreMultiWindows;
  final bool applyAspectRatio;
  final double? customSensitivityK;

  const ScaledSp(
    this.base, {
    this.entries = const [],
    this.ignoreMultiWindows = false,
    this.applyAspectRatio = false,
    this.customSensitivityK,
  });

  ScaledSp _copy({
    List<ScaledEntry>? entries,
    bool? ignoreMultiWindows,
    bool? applyAspectRatio,
    double? customSensitivityK,
    bool clearCustomK = false,
  }) =>
      ScaledSp(
        base,
        entries: entries ?? this.entries,
        ignoreMultiWindows: ignoreMultiWindows ?? this.ignoreMultiWindows,
        applyAspectRatio: applyAspectRatio ?? this.applyAspectRatio,
        customSensitivityK: clearCustomK
            ? null
            : (customSensitivityK ?? this.customSensitivityK),
      );

  ScaledSp withAspectRatio({bool enable = true, double? sensitivityK}) =>
      _copy(applyAspectRatio: enable, customSensitivityK: sensitivityK);

  ScaledSp withIgnoreMultiWindows({bool ignore = true}) =>
      _copy(ignoreMultiWindows: ignore);

  ScaledSp screen(
    UiModeType uiModeType,
    DpQualifier qualifierType,
    num qualifierValue,
    num customValue, {
    OrientationRequest orientation = OrientationRequest.any,
    DpQualifier? finalQualifierResolver,
    Inverter inverter = Inverter.standard,
    bool fontScale = true,
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
        fontScale: fontScale,
      ));

  ScaledSp screenMode(
    UiModeType uiModeType,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    OrientationRequest orientation = OrientationRequest.any,
    Inverter inverter = Inverter.standard,
    bool fontScale = true,
  }) =>
      _add(ScaledEntry(
        uiModeType: uiModeType,
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 2,
        inverter: inverter,
        fontScale: fontScale,
      ));

  ScaledSp screenQualifier(
    DpQualifier qualifierType,
    num qualifierValue,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    OrientationRequest orientation = OrientationRequest.any,
    Inverter inverter = Inverter.standard,
    bool fontScale = true,
  }) =>
      _add(ScaledEntry(
        dpQualifierEntry:
            DpQualifierEntry(qualifierType, qualifierValue.toDouble()),
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 3,
        inverter: inverter,
        fontScale: fontScale,
      ));

  ScaledSp screenOrientation(
    OrientationRequest orientation,
    num customValue, {
    DpQualifier? finalQualifierResolver,
    Inverter inverter = Inverter.standard,
    bool fontScale = true,
  }) =>
      _add(ScaledEntry(
        orientation: orientation,
        customValue: customValue.toDouble(),
        finalQualifierResolver: finalQualifierResolver,
        priority: 4,
        inverter: inverter,
        fontScale: fontScale,
      ));

  ScaledSp _add(ScaledEntry entry) {
    final next = [...entries, entry]..sort((a, b) {
        final p = a.priority.compareTo(b.priority);
        if (p != 0) return p;
        return (b.dpQualifierEntry?.value ?? 0)
            .compareTo(a.dpQualifierEntry?.value ?? 0);
      });
    return _copy(entries: next);
  }

  double resolve(AppDimensContext context,
      {DpQualifier qualifier = DpQualifier.smallWidth}) {
    for (final e in entries) {
      if (_matches(e, context)) {
        final value = DimenScaledEngine.resolveScaledSpValue(
          e.customValue,
          context,
          e.finalQualifierResolver ?? qualifier,
          fontScale: e.fontScale,
          inverter: e.inverter,
          ignoreMultiWindows: ignoreMultiWindows,
          applyAspectRatio: applyAspectRatio,
          customSensitivityK: customSensitivityK,
        );
        return e.fontScale ? value : value * context.fontScale;
      }
    }
    return DimenScaledEngine.resolveScaledSpValue(
      base,
      context,
      qualifier,
      inverter: Inverter.standard,
      ignoreMultiWindows: ignoreMultiWindows,
      applyAspectRatio: applyAspectRatio,
      customSensitivityK: customSensitivityK,
    );
  }

  bool _matches(ScaledEntry e, AppDimensContextLike scope) {
    final metrics = scope.dimenMetrics;
    if (e.uiModeType != null && scope.uiModeType != e.uiModeType) return false;
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
}
