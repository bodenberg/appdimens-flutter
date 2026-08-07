import 'package:flutter/foundation.dart';
import 'configuration.dart';
import 'scaled.dart';

@immutable
class AutoCondition {
  const AutoCondition({
    this.mode,
    this.orientation,
    this.qualifier,
    this.minimum = 0,
  });
  final UiModeType? mode;
  final DimensOrientation? orientation;
  final DpQualifier? qualifier;
  final double minimum;
  bool matches(DimensConfiguration c) =>
      (mode == null || mode == c.uiMode) &&
      (orientation == null || orientation == c.orientation) &&
      (qualifier == null || c.dimension(qualifier!) >= minimum);
  int get priority =>
      (mode == null ? 0 : 4) +
      (qualifier == null ? 0 : 2) +
      (orientation == null ? 0 : 1);
}

class _AutoEntry {
  const _AutoEntry(this.condition, this.value, this.order);
  final AutoCondition condition;
  final double value;
  final int order;
}

@immutable
class AutoDp {
  const AutoDp(this.value)
    : _entries = const [],
      applyAspectRatio = false,
      ignoreMultiWindow = false,
      sensitivity = null;
  const AutoDp._(
    this.value,
    this._entries,
    this.applyAspectRatio,
    this.ignoreMultiWindow,
    this.sensitivity,
  );
  final double value;
  final List<_AutoEntry> _entries;
  final bool applyAspectRatio, ignoreMultiWindow;
  final double? sensitivity;
  AutoDp screen(double value, {required AutoCondition condition}) =>
      _copy(entry: _AutoEntry(condition, value, _entries.length));
  AutoDp qualifier(double value, DpQualifier q, {required double minimum}) =>
      screen(
        value,
        condition: AutoCondition(qualifier: q, minimum: minimum),
      );
  AutoDp mode(double value, UiModeType mode) =>
      screen(value, condition: AutoCondition(mode: mode));
  AutoDp rotate(
    double value, [
    DimensOrientation orientation = DimensOrientation.landscape,
  ]) => screen(value, condition: AutoCondition(orientation: orientation));
  AutoDp aspectRatio([bool enabled = true, double? sensitivity]) =>
      AutoDp._(value, _entries, enabled, ignoreMultiWindow, sensitivity);
  AutoDp ignoreMultiWindows([bool enabled = true]) =>
      AutoDp._(value, _entries, applyAspectRatio, enabled, sensitivity);
  AutoDp _copy({required _AutoEntry entry}) => AutoDp._(
    value,
    List.unmodifiable([..._entries, entry]),
    applyAspectRatio,
    ignoreMultiWindow,
    sensitivity,
  );
  double resolve(
    DimensConfiguration c, {
    DpQualifier qualifier = DpQualifier.smallWidth,
  }) {
    final matches = _entries.where((e) => e.condition.matches(c)).toList()
      ..sort((a, b) {
        final p = b.condition.priority.compareTo(a.condition.priority);
        if (p != 0) return p;
        final m = b.condition.minimum.compareTo(a.condition.minimum);
        return m != 0 ? m : a.order.compareTo(b.order);
      });
    return AppDimens.dp(
      matches.isEmpty ? value : matches.first.value,
      configuration: c,
      qualifier: qualifier,
      ignoreMultiWindows: ignoreMultiWindow,
      applyAspectRatio: applyAspectRatio,
      sensitivity: sensitivity,
    );
  }
}

@immutable
class AutoSp {
  const AutoSp(this.dp, {this.fontScale = true});
  final AutoDp dp;
  final bool fontScale;
  factory AutoSp.value(double value, {bool fontScale = true}) =>
      AutoSp(AutoDp(value), fontScale: fontScale);
  AutoSp screen(double value, {required AutoCondition condition}) =>
      AutoSp(dp.screen(value, condition: condition), fontScale: fontScale);
  double resolve(
    DimensConfiguration c, {
    DpQualifier qualifier = DpQualifier.smallWidth,
  }) {
    final geometry = dp.resolve(c, qualifier: qualifier);
    return fontScale ? geometry * c.fontScale : geometry;
  }
}

extension AppDimensAutoNum on num {
  AutoDp get autoScaledDp => AutoDp(toDouble());
  AutoSp get autoSp => AutoSp.value(toDouble());
}
