# Performance

Custom strategies cost about the same as the built-ins when they only depend on the screen. Which form you pick decides the work done per value.

| Form | Per window | Per value |
|---|---|---|
| `customScaleStrategy((s) => …)`, any curve, rules, factor bounds, aspect ratio | function / curve once | one multiply |
| text formula shaped `base * E` (E reads no value) | `E` once | one multiply |
| `minValue` / `maxValue` | | a few comparisons |
| `scalingFormulaOf((s) => …)`, `transform` | | your function, on every call |
| other text formulas | | the parsed formula, on every call |

## How it works

- **Memo per window.** Each strategy keeps the last resolved window (rules applied, factor computed), keyed by the immutable `DimenMetrics` snapshot and the UI mode. `AppDimensApp` publishes a new snapshot only when the window really changes (rotation, resize, fold, font scale, UI mode), so a new window resolves again once and every other call is a memo hit.
- **No per-value cache.** Flutter does not keep a per-value table for custom strategies: a value-dependent strategy runs its formula on each call. Text formulas are parsed once, when the strategy is created; evaluating the parsed tree costs a few operations.
- **Fast path for text.** `base * E` is detected when the formula is parsed; the result is bit for bit the same as evaluating it per value, and `isValueDependent` is `false`.
- **Shared text strategies.** `16.cdpFormula('…')` and `ScalingStrategies.formula('…')` look the text up in a map of up to 256 entries, so the same text keeps its memo across calls.

## Guidelines

1. Prefer a factor (`customScaleStrategy`, a curve, rules) over a per-value formula when the math is "base × something about the screen".
2. Use `minValue` / `maxValue` only for real absolute limits (tap targets ≥ 48 dp, max text size).
3. Declare strategies once: a top-level `final`, a `static final` in an `AppStrategies` class, or a JSON document loaded at startup. A strategy built in `build` has an empty memo, so it resolves the window again on every call.
4. Keep functions pure and cheap. They run on the calling isolate (the UI thread), on every memo miss or, for `scalingFormulaOf`, on every call.
5. Text formulas inline (`16.cdpFormula('…')`) are shared per text, so they are fine in `build`. Building strategies from dynamic strings in a loop is not: past 256 distinct texts each call builds a new strategy.

[Back to the custom docs](README.md)
