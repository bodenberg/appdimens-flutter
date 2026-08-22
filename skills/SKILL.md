---
name: appdimens-flutter-workflow
description: Use this skill for any Flutter responsive layout or scaling question — including making apps look right on tablets, foldables, desktop windows, or different screen sizes — and whenever the user mentions appdimens, sdp, hdp, wdp, ssp, sem, DimenMetrics, DimenCache, AutoResize, responsive dp/sp, or scaling strategies. Also trigger when the user wants to add the AppDimens Flutter dependency, choose between the fast-lane getters and explicit-context APIs, implement constraint-based resize, or convert plain dp/sp values to scaled equivalents. When in doubt, use this skill — it covers the full lifecycle: install, strategy selection, implementation under the provider, and resize.
---

# AppDimens Flutter — project workflow

**Library (3.2.0):** `appdimens` (scaled + core), `appdimens_<strategy>`, BOM `appdimens_bom`. See [MODULES.md](../DOCUMENTATION/MODULES.md).

**Install:** `appdimens: ^3.2.0` plus the strategy satellites you need (or `appdimens_bom: ^3.2.0` for everything).

On release bumps, update version URLs in this file, `library-map.md`, and `reference.md` together.

**Architecture in one paragraph:** every window configuration maps to an immutable `DimenMetrics` snapshot with eagerly precomputed factors. `AppDimensApp` / `AppDimensScopeBinder` republish the snapshot on rotation, resize, split-screen and font-scale changes. The hot path (`16.sdp`) is one static slot read + one multiply (~6–12 ns); dominant families bypass the cache hash exactly like the Kotlin engine.

**Authoritative GitHub docs (ref `main`):**
- [README.md](https://github.com/bodenberg/appdimens-flutter/blob/main/README.md) — install, `AppDimensApp`, fast lane overview
- [DOCUMENTATION/MODULES.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MODULES.md) — pub workspace graph (principal vs satellites)
- [DOCUMENTATION/README.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/README.md) — all strategies, decision flow
- [DOCUMENTATION/API-CONVENTIONS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md) — suffix grammar, inverters, facilitators, Plain pairs, builders, resolution modes
- [DOCUMENTATION/resize.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/resize.md) — `AutoResizeText`, `AutoResizeSquare`, engine-level fitting
- [GUIDE-FOR-BEGINNERS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/GUIDE-FOR-BEGINNERS.md) — narrative walkthrough
- [MIGRATION.md](https://github.com/bodenberg/appdimens-flutter/blob/main/MIGRATION.md) — replacing the deprecated 2.x `fx/dy` API
- Examples: [Sample app](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/sample/lib/main.dart) · [Strategy routing](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/sample/lib/demo_routing.dart) · [BenchLab](https://github.com/bodenberg/appdimens-flutter/blob/main/apps/benchlab/lib/main.dart)

**Package map and strategy → doc index:** [library-map.md](library-map.md)

---

## Agent Preflight (run before any non-trivial edit)

1. Read [library-map.md](library-map.md) for package layout and strategy ↔ doc mapping.
2. For the **specific packages/symbols** you'll touch: browse [`packages/appdimens/`](https://github.com/bodenberg/appdimens-flutter/tree/main/packages/appdimens/lib) (principal) or the matching [`packages/appdimens_<strategy>/`](https://github.com/bodenberg/appdimens-flutter/tree/main/packages) satellite on GitHub, or use IDE "Navigate to Declaration" on the pub package. For API detail, see [DOCUMENTATION/API-CONVENTIONS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md). Do not rely on memory.
3. Skim the upstream example that matches the user's task (links above). Restrict deep reading to **relevant packages and call sites** — full module audits only when explicitly requested.

**Hard rule:** never surface `ignoreMultiWindows`, `*i`, or `*ia` suffixes to users.

---

## Phase 0 — Interactive Baseline

Ask questions **one at a time**. Wait for the answer before moving to the next step. Skip any already answered in the conversation.

### 0.1 Resolution Mode

Which surface is in scope?

| Choice | API family | Key note |
|--------|-----------|----------|
| **Fast lane (widget tree)** | `16.sdp`, `50.psdp`, `16.scaledDp…` | needs `AppDimensApp` (or `AppDimensScopeBinder` in `MaterialApp.builder`) |
| **Explicit context** | `16.sdpOf(context)`, `16.toDynamicScaledDp(ctx, q, …)`, `DimenSdp.sdp(ctx, v)` | tests, isolates, code before the first frame; deterministic 300×533 fallback without provider |

Record: drives imports, provider need, and test strategy.

*→ Wait for answer, then ask 0.2.*

### 0.2 Screen Metric Qualifier (`DpQualifier`)

Which axis should qualifier-aware APIs use? (Affects `.sdpQualifier`, `.sdpScreen`, rotates such as `.sdpRotate` vs axis variants `.hdpRotate`/`.wdpRotate`.)

- **`DpQualifier.smallWidth` (default)** — smallest-width baseline; correct for most phone/tablet layouts.
- **Explicit `DpQualifier.width` / `.height`** — when design requires width-dp or height-dp branching. Read [API-CONVENTIONS.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md) before proposing thresholds.

Record before suggesting any `.screen`, `.qualifier`, rotate, or power-curve APIs.

*→ Wait for answer, then ask 0.3.*

### 0.3 Task Type

Disambiguate first — these are **separate** workflows:
- **Scaling strategy** = global dimension curve (`sdp`, percent, fluid, …) → Phase 1.
- **Resize** = constraint-based fit (`AutoResizeText`, `AutoResizeSquare`, `DimenResize`) → Phase 3.

Ask which applies:
- **Strategy selection only** — also ask: **manual** (user picks after seeing options) or **AI-proposed** (you propose, user confirms)? Warn that automatic proposals are more error-prone on mixed form factors and resize-heavy UIs.
- **Resize only** — still complete 0.1, 0.2, and 0.4; go directly to Phase 3.
- **Both** — run Phase 1, then Phase 3.

If automatic strategy mode: confirm each major screen or module after proposing, before bulk edits.

*→ Wait for answer, then ask 0.4.*

### 0.4 Scope

Full migration (app-wide) or partial? For partial scope, list concrete paths or identifiers (files, widgets, screens, specific dimensions) before editing.

*→ Wait for answer, then ask 0.5.*

### 0.5 Acceptance Criteria

For each major screen or module, ask for plain-language criteria (e.g., "no clipped titles on foldable inner display", "comfortable padding on 10-inch tablet"). Tie every recommendation explicitly to these.

*→ Once answered, proceed to the relevant phase(s).*

---

## Phase 1 — Scaling Strategy Selection

*Run only when Phase 0.3 includes strategy selection. Skip for resize-only tasks with unchanged surrounding curves.*

### Default: Scaled

**`packages/appdimens`** — recommend this first. Linear scaling around a **300 dp** reference on the chosen axis.

| Variant | Typical use |
|---------|-------------|
| `.sdp` | General spacing, padding, corner radii |
| `.hdp` | Vertical rhythm, row heights |
| `.wdp` | Width-driven columns |
| `.ssp` | Text (framework applies font scale); `sem` ignores it |
| `.sdpa` / `.hdpa` | Very wide or tall screens where plain scaled is too aggressive or too conservative |

In **manual mode**: present this default and ask which UI areas use it. Accept "everything scaled except …" rules.
In **automatic mode**: propose per screen, confirm before bulk edits.

### Other Strategies

Use only when requirements or QA justify leaving scaled. **Before recommending any strategy below**, read its matching doc in `DOCUMENTATION/` — see [library-map.md](library-map.md) § "Strategy → doc". Pull trade-offs from that doc, not from memory.

| Strategy | Package | Role | Typically when | Not ideal when |
|----------|---------|------|----------------|----------------|
| **Percent** | `appdimens_percent` | Literal fraction of a screen axis | Sizes must track sw/w/h directly (`50.spaceW` = 50 % of width) | Only need "design at 300 dp" feel — use scaled |
| **Power** | `appdimens_power` | Sub-linear growth `(d/300)^0.75` | Large phones/tablets feel "too big" with linear | Need predictable linear mapping everywhere |
| **Fluid** | `appdimens_fluid` | Clamped band ±20 % over [320, 768] | Hard min/max bounds required (typography) | One simple curve app-wide without band tuning |
| **Auto** | `appdimens_auto` | Linear phones, log-damped past 480 dp | Clear "phone vs tablet" knee in the curve | Need mathematically smooth everywhere |
| **Diagonal** | `appdimens_diagonal` | Window-diagonal ratio | Rotation must not change the size | Simple portrait phone layouts |
| **Fill** | `appdimens_fill` | Cover-like growth (larger axis) | Backgrounds/hero art that must fill | Risk oversized touch targets without QA |
| **Fit** | `appdimens_fit` | Contain-like growth (smaller axis) | Logos/badges that must never overflow | Need aggressive use of space on tablets |
| **Interpolated** | `appdimens_interpolated` | Fixed 50 % blend | Halving linear growth app-wide | No intermediate data — high maintenance |
| **Logarithmic** | `appdimens_logarithmic` | Strong damping ±0.4·ln | Density-first layouts (dashboards, IDEs) | Need linear proportional feel |
| **Perimeter** | `appdimens_perimeter` | Half-perimeter ratio | Rotation-stable bars/toolbars | No such requirement |
| **Density** | `appdimens_density` | DPI/160 alignment | Games, AR, physical calibration | Want screen-shape-aware curves |
| **Physical units** | `appdimens_units` | mm / cm / in helpers | Real-world sizing (rulers, print-like UI) | Most Material layout — use scaled instead |
| **Resize** | `appdimens_resize` | *(not a global curve)* Largest discrete step in [min,max] fitting constraints | Auto-fit text or boxes inside known max | Whole-screen proportional layout |

---

## Phase 2 — Implementation Rules

Apply regardless of strategy or resolution mode:

1. **Strategy isolation** — satellites depend only on `appdimens` and do not cross-import. One strategy per calculation path.
2. **`AppDimensApp`** — required once at the root for fast-lane getters; `AppDimensScopeBinder` belongs in `MaterialApp.builder`. Facilitators (`sdpMode`, `sdpScreen`, `sspScreen`) read the published ui-mode/qualifier slots.
3. **Config churn** — no explicit invalidation is required for correctness: every resolution is keyed by the immutable per-window `DimenMetrics` snapshot, so a rotated/resized window can never read a stale value. `DimenCache.invalidateOnConfigChange` exists as an eager memory-release hook only.
4. **Hot paths** — the extension getters allocate nothing; prefer them over building chains per frame. Cache `DimenScaled`/`StrategyChain` instances outside `build` when the chain is static.
5. **Nested Plain facilitators** — use the `*Plain` pairs to avoid double-scaling (they pick between two already-resolved values).
6. **Tests** — without a provider, getters resolve against the 300×533 baseline (`16.sdp == 16` exactly); use `AppDimensScope.withMetrics(DimenMetrics.from(cfg), () { … })` to simulate devices.

---

## Phase 3 — Resize Work

*Run when the user touches `AutoResize*`, `ResizeBound`, `ResizeRangePx`, or `DimenResize`.*

Ask in order, waiting for each answer before continuing:

1. **Element type** — text (font size sweep in sp → `AutoResizeText`) or non-text component (square/width/height sweeps → `AutoResizeSquare` or engine-level `ResizeRangePx`)?
2. **Constraint source** — widgets run inside `LayoutBuilder` (constraints in logical px). Engine-level: how is max px/dp obtained?
3. **Expected behavior** — fill to cap, shrink to fit, or prefer a size? Any min/max in dp, sp, or axis percent (`resizePercentSw/W/H`)?
4. **Bounds semantics** — `ResizeFixedDp` / `ResizeFixedSp` / `ResizePercent` (sw/w/h axis); inner-box percent via `DimenResize.rangePxPercentOfInnerBox` with `AutoResizePercentBasis` (width, height, minSide). Remind: fitting search returns `0.0` when nothing fits.
5. **Approach check** — global proportional sizing across the screen is usually scaled/percent/fluid, not resize. Reserve resize for fit-to-container problems.

Reference: [DOCUMENTATION/resize.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/resize.md)

---

## Phase 4 — Execution Checklist

- [ ] Agent Preflight completed for touched symbols.
- [ ] Phase 0 answered: resolution mode, `DpQualifier` baseline, task type (strategy / resize / both), scope, acceptance criteria.
- [ ] Scaled presented as default; other strategies have matching `DOCUMENTATION/*.md` opened and trade-offs cited.
- [ ] `ignoreMultiWindows` / `*i` / `*ia` not surfaced to user.
- [ ] Docs read for anything beyond trivial one-liners.
- [ ] Diffs are small and reviewable; aligned with upstream example patterns.
- [ ] `flutter analyze` and the touched package's tests pass.

---

## Output Style

For every decision state: chosen strategy, package (`appdimens` or `appdimens_<strategy>`), resolution mode (fast lane vs explicit context), axis (`sdp` vs `hdp` vs `wdp`), whether resize vs global scaling, and which acceptance criterion it satisfies. Prefer small, reviewable diffs aligned with existing project patterns.
