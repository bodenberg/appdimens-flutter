# Mathematics and Calculus — AppDimens Flutter

> Mirrors `DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md` of the Kotlin family.
> All math runs in IEEE-754 **double precision** using the same constants as
> the Kotlin engine (which uses 32-bit floats; parity tolerance is far below
> the family's `< 0.05 dp` policy).

## 1. Symbols

| Symbol | Meaning |
|---|---|
| `b` | base value being scaled |
| `w`, `h` | current window width/height in **dp** |
| `s_min`, `s_max` | shorter / longer window side in dp |
| `sw` | smallest window width (`smallestScreenWidthDp` contract) |
| `d` | effective axis dimension selected by the qualifier |
| `ρ = s_max / s_min` | raw aspect ratio |
| `r_AR = ρ / 1.78` | normalized aspect ratio |
| `L_AR = ln(r_AR)` | log of the normalized ratio |
| `k` | custom sensitivity (null → default) |
| `ι = 0.0033333334` | inverse baseline width (1/300) |

## 2. Hardcoded constants

```text
BASE_WIDTH_DP            = 300
BASE_HEIGHT_DP           = 533
BASE_DIAGONAL_DP         = 611.6305      // √(300² + 533²)
BASE_PERIMETER_DP        = 833           // 300 + 533
REFERENCE_ASPECT_RATIO   = 1.78          // 16:9
INV_REFERENCE_ASPECT_RATIO = 0.5617978   // 1 / 1.78

INV_BASE_RATIO      = 0.0033333334       // ι  = 1/300
ADJUSTMENT_SCALE    = 0.0033333334       //    = 0.10/30
SENSITIVITY_DEFAULT = 0.0026666667       // k₀ = 0.08/30
```

## 3. The resolution snapshot (`DimenMetrics`)

One immutable object per window configuration; every derived factor is
computed **once** at construction (plain final fields — no lazy checks on the
hot path):

| Factor | Expression |
|---|---|
| `density` | `dpi / 160` (guarded to finite > 0) |
| `scale` | `sw · ι` |
| `screenWidthFactor` | `w · ι` |
| `screenHeightFactor` | `h · ι` |
| `normalizedAspectRatio` | `(s_max / s_min) / 1.78` |
| `logNormalizedAspectRatio` | `ln(normalizedAspectRatio)` |
| `defaultAspectRatioMultiplier` | `1 + k₀ · L_AR` |
| `defaultScaledAspectRatioMultiplier` | `1 + (sw − 300)(ADJUSTMENT_SCALE + k₀ · L_AR)` |
| `powerScale` *(lazy)* | `(sw · ι)^{0.75}` |
| `interpolatedScale` *(lazy)* | `1 + (sw·ι − 1) × 0.5` |
| `diagonalScale` *(lazy)* | `√(s_min² + s_max²) / 611.6305` |
| `perimeterScale` *(lazy)* | `(s_min + s_max) / 833` |
| `logarithmicScale` *(lazy)* | piecewise below |

Snapshot equality is an exact cache-partition key: two snapshots are equal iff
all inputs match.

## 4. Scaled engine (the principal strategy)

```text
q' = effectiveQualifier(q, inverter, orientation)     // §6
if ignoreMultiWindows ∧ multiWindowConstrained → return b

default path (q = SMALL_WIDTH, inverter = standard, k = null):
    AR off : out = b · scale
    AR on  : out = b · defaultScaledAspectRatioMultiplier

general path:
    d = axisDp(q')
    AR off : out = b · (d · ι)
    AR on  : out = b · (1 + (d − 300) · (ADJUSTMENT_SCALE + k·L_AR))
```

Unit conversion:

```text
PX          = dp · density
SP (value)  = dp                       // framework applies fontScale on render
SP no-scale = dp / fontScale           // render cancels it back ("sem" family)
SP px       = sp · density · fontScale
```

## 5. Strategy formulas

| Strategy | Formula | Notes |
|---|---|---|
| Percent | `b · d·ι` | same linear law as Scaled; literal family: `(p/100)·axis` |
| Power | `b · (d·ι)^{0.75}` | sub-linear growth (Stevens-like) |
| Fluid | plateaus `b×0.8` ≤ 320, `b×1.2` ≥ 768, linear lerp between | CSS-clamp-like |
| Auto | `d ≤ 480 : d·ι`; else `480·ι + 0.4·ln(1 + (d−480)·ι)` | linear phones, damped tablets |
| Logarithmic | `d > 300 : 1 + 0.4·ln(d·ι)` · `0 < d ≤ 300 : 1 − 0.4·ln(300/d)` | symmetric damping |
| Diagonal | `√(s_min² + s_max²) / 611.6305` | qualifier-independent |
| Fill (cover) | `max(s_min/300, s_max/533)` | may overflow |
| Fit (contain) | `min(s_min/300, s_max/533)` | always fits |
| Interpolated | `b + (b·d·ι − b) × 0.5` | fixed ½ blend |
| Perimeter | `(s_min + s_max) / 833` | qualifier-independent |
| Density | `b · (dpi/160)` | px path multiplies density again |
| Resize | step table `[min…max]` (cap 4096, ends exactly at max) + binary search for the largest fitting candidate | not a curve |
| Units | `mm → dp = mm · xdpi / 25.4 / density`; cm = mm×10; inch = mm×25.4; pure converters for unit↔unit | approximate physical size |

**Aspect ratio for satellites:** every satellite applies the multiplier
**after** its base formula:

```text
out = baseFormula · aspectRatioMultiplier(k)
aspectRatioMultiplier(null) = 1 + k₀ · L_AR
aspectRatioMultiplier(k)    = 1 + k · L_AR
```

**Memoized default paths (KMP parity):** when the effective qualifier is the
smallest width and no custom flags are set, Power / Interpolated /
Logarithmic / Diagonal / Perimeter return `base · <memoized snapshot factor>`
directly — one field read + one multiply, no `pow`/`sqrt`/`ln` per call.

## 6. Inverters (`effectiveQualifier`)

| Inverter | Condition → swap |
|---|---|
| `standard` | none |
| `phToLw` | landscape ∧ HEIGHT → WIDTH |
| `pwToLh` | landscape ∧ WIDTH → HEIGHT |
| `lhToPw` | portrait ∧ HEIGHT → WIDTH |
| `lwToPh` | portrait ∧ WIDTH → HEIGHT |
| `swToLh` | landscape ∧ SMALL_WIDTH → HEIGHT |
| `swToLw` | landscape ∧ SMALL_WIDTH → WIDTH |
| `swToPh` | portrait ∧ SMALL_WIDTH → HEIGHT |
| `swToPw` | portrait ∧ SMALL_WIDTH → WIDTH |

## 7. Multi-window heuristic

When suppression is requested:

```text
known flag from context? → use it
otherwise: (sw − w) ≥ sw × 10%   ⇒ constrained (return base unscaled)
```

## 8. Cache anatomy

* Partitions keyed by exact snapshot; **max 4 partitions**, each a bounded map
  of **512 entries** (oldest-insert evicted).
* Bypass rules (identical to the Kotlin engine): PERCENT, SCALED, DENSITY,
  DIAGONAL, INTERPOLATED, PERIMETER always bypass on their default path;
  POWER and LOGARITHMIC bypass only on the default sw path; AUTO, FLUID, FIT,
  FILL always memoize.
* Custom sensitivity keys are never cached.
* Correctness never depends on the cache: values are pure functions of the
  snapshot, so a stale partition can only waste memory, never produce wrong
  numbers. `DimenCache.invalidateOnConfigChange` releases memory eagerly.

## 9. Precision policy

* Dart runs doubles; Kotlin runs floats. Differences appear after ~7 significant
  digits (e.g. `16.sdp` on a 392 dp phone differs from the float result by
  ≈ 3×10⁻⁷ dp).
* Generated reference vectors (`packages/appdimens/test/reference_vectors.dart`)
  verify every formula against an independent model with a `10⁻⁶` tolerance —
  four orders of magnitude stricter than the family's `< 0.05 dp` policy.
* Degenerate inputs are guarded: non-positive dimensions fall back to the
  300×533 baseline; invalid sensitivities throw instead of leaking NaN into a
  layout; non-finite percent literals resolve to zero.
