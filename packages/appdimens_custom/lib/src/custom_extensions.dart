/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Custom scaling strategies — `num` extensions, [BuildContext] helpers and
/// the [ScalingStrategyScope] widget.
library;

import 'package:appdimens_flutter/appdimens.dart';
import 'package:flutter/widgets.dart';

import 'custom_strategy.dart';

/// EN `16.cdp` (default strategy) / `16.cdpWith(brand)` — mirrors Kotlin
/// `16.cdp` / `16.cdp(Brand)`. Values are logical pixels (dp).
/// PT `16.cdp` (estratégia padrão) / `16.cdpWith(brand)`.
extension AppDimensCustom on num {
  /// EN Default strategy · dp.
  double get cdp => ScalingStrategies.defaultStrategy.dp(this);

  /// EN Default strategy · physical px.
  double get cdpPx => ScalingStrategies.defaultStrategy.px(this);

  /// EN Default strategy · `fontSize` (TextScaler applied by Flutter).
  double get csp => ScalingStrategies.defaultStrategy.sp(this);

  /// EN Default strategy · text physical px.
  double get cspPx => ScalingStrategies.defaultStrategy.spPx(this);

  /// EN Explicit strategy (instance or id) · dp: `16.cdpWith(brand)`.
  double cdpWith(Object strategy) => _pick(strategy).dp(this);

  /// EN Explicit strategy · physical px.
  double cdpPxWith(Object strategy) => _pick(strategy).px(this);

  /// EN Explicit strategy · `fontSize`.
  double cspWith(Object strategy) => _pick(strategy).sp(this);

  /// EN Explicit strategy · text physical px.
  double cspPxWith(Object strategy) => _pick(strategy).spPx(this);
}

ScalingStrategy _pick(Object strategy) => switch (strategy) {
      ScalingStrategy s => s,
      String id => ScalingStrategies.getOrThrow(id),
      _ => throw ArgumentError(
          'Expected a ScalingStrategy or a strategy id, got ${strategy.runtimeType}'),
    };

/// EN Provides a strategy to a subtree: `context.cdp(16)` below it uses
/// [strategy]. Rebuilds dependents when the strategy changes.
/// PT Fornece uma estratégia a uma subárvore.
class ScalingStrategyScope extends InheritedWidget {
  final ScalingStrategy strategy;

  const ScalingStrategyScope(
      {super.key, required this.strategy, required super.child});

  /// EN Nearest scoped strategy, else [ScalingStrategies.defaultStrategy].
  static ScalingStrategy of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ScalingStrategyScope>()
          ?.strategy ??
      ScalingStrategies.defaultStrategy;

  @override
  bool updateShouldNotify(ScalingStrategyScope oldWidget) =>
      !identical(oldWidget.strategy, strategy);
}

/// EN Context helpers that also subscribe the widget to window / text-scale
/// changes (`MediaQuery`), so values update on rotation and resize.
/// PT Helpers de contexto que também inscrevem o widget em mudanças de janela.
extension AppDimensCustomContext on BuildContext {
  /// EN Strategy in effect here (scope, then the global default).
  ScalingStrategy get scalingStrategy => ScalingStrategyScope.of(this);

  ScalingStrategy _strategy(Object? strategy) {
    MediaQuery.maybeSizeOf(this);
    MediaQuery.maybeTextScalerOf(this);
    return strategy == null ? ScalingStrategyScope.of(this) : _pick(strategy);
  }

  /// EN dp with the scoped strategy (or [strategy]).
  double cdp(num value, [Object? strategy]) => _strategy(strategy).dp(value);

  /// EN physical px with the scoped strategy (or [strategy]).
  double cdpPx(num value, [Object? strategy]) => _strategy(strategy).px(value);

  /// EN `fontSize` with the scoped strategy (or [strategy]).
  double csp(num value, [Object? strategy]) => _strategy(strategy).sp(value);

  /// EN Debug breakdown of the scoped strategy (or [strategy]).
  String explainScaling([Object? strategy]) => _strategy(strategy).explain();
}

/// EN Builder that rebuilds when the window snapshot changes and hands out the
/// strategy in effect: `ScalingStrategyBuilder(builder: (context, s) => …s.dp(16)…)`.
class ScalingStrategyBuilder extends StatelessWidget {
  final ScalingStrategy? strategy;
  final Widget Function(BuildContext context, ScalingStrategy strategy) builder;

  const ScalingStrategyBuilder(
      {super.key, this.strategy, required this.builder});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppDimensScope.notifier,
        builder: (context, _) {
          MediaQuery.maybeSizeOf(context);
          return builder(context, strategy ?? ScalingStrategyScope.of(context));
        },
      );
}
