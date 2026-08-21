/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Resize widgets — auto-resize text and sizes inside `LayoutBuilder`
/// constraints (the Flutter analog of the KMP `BoxWithConstraints` APIs).
import 'package:flutter/widgets.dart';

import 'package:appdimens/appdimens.dart';
import 'resize_engine.dart';

/// EN: Lays out [child] with the largest square side in `[min, max]` that
/// fits the incoming constraints (minus [padding]).
///
/// PT: Aplica em [child] o maior lado quadrado dentro de `[min, max]` que
/// caiba nas restrições recebidas (menos o [padding]).
class AutoResizeSquare extends StatelessWidget {
  final num min;
  final num max;
  final num step;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const AutoResizeSquare({
    super.key,
    required this.min,
    required this.max,
    this.step = 4,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scope = context.appDimensScopeSnapshot();
      final pad = padding?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;
      final inner = DimenResize.innerMaxDimensionsPx(
        boxWidthPx: constraints.maxWidth * scope.metrics.density,
        boxHeightPx: constraints.maxHeight * scope.metrics.density,
        paddingLeftPx: pad.left * scope.metrics.density,
        paddingRightPx: pad.right * scope.metrics.density,
        paddingTopPx: pad.top * scope.metrics.density,
        paddingBottomPx: pad.bottom * scope.metrics.density,
      );
      final range = DimenResize.rangePx(scope, min, max, step: step);
      var side =
          DimenResize.fittingInnerSquareSidePx(range, inner.width, inner.height);
      if (side <= 0) side = range.lowPx;
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SizedBox(
          width: side / scope.metrics.density,
          height: side / scope.metrics.density,
          child: child,
        ),
      );
    });
  }
}

/// EN: Text whose font size is the largest sp value within
/// `[minSp, maxSp]` whose measured layout still fits its constraints.
///
/// PT: Texto cujo tamanho da fonte é o maior valor sp dentro de
/// `[minSp, maxSp]` cujo layout medido ainda cabe nas restrições.
class AutoResizeText extends StatelessWidget {
  final String text;
  final num minSp;
  final num maxSp;
  final num stepSp;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextStyle? style;

  const AutoResizeText(
    this.text, {
    super.key,
    this.minSp = 10,
    this.maxSp = 28,
    this.stepSp = 1,
    this.maxLines,
    this.textAlign,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scope = context.appDimensScopeSnapshot();
      final density = scope.metrics.density;
      final fontScale = scope.metrics.fontScale > 0 ? scope.metrics.fontScale : 1.0;
      final steps = ResizeMath.buildResizeStepsPx(
        minSp.toDouble() * density,
        maxSp.toDouble() * density,
        stepSp.toDouble().clamp(0.1, double.infinity) * density,
      );
      final measurer = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      );
      double chosenPx = steps.isEmpty ? minSp.toDouble() * density : steps.first;
      for (final candidate in steps) {
        final sp = candidate / density;
        measurer.text = TextSpan(
          text: text,
          style: (style ?? const TextStyle()).copyWith(fontSize: sp),
        );
        measurer.layout(maxWidth: constraints.maxWidth);
        final fitsHeight =
            maxLines == null || !measurer.didExceedMaxLines;
        if (measurer.width <= constraints.maxWidth + 0.5 &&
            measurer.height <= constraints.maxHeight + 0.5 &&
            fitsHeight) {
          chosenPx = candidate;
        } else {
          break;
        }
      }
      // Convert px back to an sp value that survives framework font scaling.
      final spValue = chosenPx / density / fontScale;
      return Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: (style ?? const TextStyle()).copyWith(fontSize: spValue),
      );
    });
  }
}

extension on BuildContext {
  _ScopeSnapshot appDimensScopeSnapshot() => _ScopeSnapshot(AppDimensScope.metricsOrDefault);
}

class _ScopeSnapshot implements AppDimensContextLike {
  final DimenMetrics metrics;
  _ScopeSnapshot(this.metrics);

  @override
  DimenMetrics get dimenMetrics => metrics;

  @override
  ScreenConfiguration get configuration => metrics.configuration;

  @override
  UiModeType get uiModeType => AppDimensScope.uiModeTypeOrDefault;
}
