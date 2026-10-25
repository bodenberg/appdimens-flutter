# AppDimens Flutter — Documentation Hub

> Version 3.2.0 · Flutter port of the AppDimens Dynamic / KMP family

Every strategy guide follows the same skeleton: **what it is → calculation →
how to use → why use it → when to use it → advantages & trade-offs →
recommended usage** — mirroring the documentation of the Kotlin family.

## Strategy guides (14)

| # | Strategy | Package | Guide | Dp stems |
|---|----------|---------|-------|----------|
| 1 | Scaled *(default)* | `appdimens_flutter` | [scaled.md](scaled.md) | `sdp` / `hdp` / `wdp` |
| 2 | Percent | `appdimens_percent` | [percent.md](percent.md) | `psdp` / `phdp` / `pwdp` |
| 3 | Power | `appdimens_power` | [power.md](power.md) | `pwsdp` / `pwhdp` / `pwwdp` |
| 4 | Fluid | `appdimens_fluid` | [fluid.md](fluid.md) | `fsdp` / `fhdp` / `fwdp` |
| 5 | Auto | `appdimens_auto` | [auto.md](auto.md) | `asdp` / `ahdp` / `awdp` |
| 6 | Diagonal | `appdimens_diagonal` | [diagonal.md](diagonal.md) | `dgsdp` / `dghdp` / `dgwdp` |
| 7 | Fill (cover) | `appdimens_fill` | [fill.md](fill.md) | `flsdp` / `flhdp` / `flwdp` |
| 8 | Fit (contain) | `appdimens_fit` | [fit.md](fit.md) | `ftsdp` / `fthdp` / `ftwdp` |
| 9 | Interpolated | `appdimens_interpolated` | [interpolated.md](interpolated.md) | `isdp` / `ihdp` / `iwdp` |
| 10 | Logarithmic | `appdimens_logarithmic` | [logarithmic.md](logarithmic.md) | `logsdp` / `loghdp` / `logwdp` |
| 11 | Perimeter | `appdimens_perimeter` | [perimeter.md](perimeter.md) | `prsdp` / `prhdp` / `prwdp` |
| 12 | Density | `appdimens_density` | [density.md](density.md) | `dsdp` / `dhdp` / `dwdp` |
| 13 | Resize | `appdimens_resize` | [resize.md](resize.md) | `AutoResizeText`, `AutoResizeSquare`, `ResizeBound`… |
| 14 | Physical units | `appdimens_units` | [physical-units.md](physical-units.md) | mm / cm / inch converters |
| 15 | **Custom (your own)** | `appdimens_custom` | [custom.md](custom.md) · [full guide](custom/README.md) | `cdp` / `cdpWith(s)` / `context.cdp(v)` — axis, curve and rules set by the strategy |

Every dp stem has sp twins (`ssp`, `hsp`, `wsp` with the strategy prefix, e.g.
`pssp`) and no-font-scale variants (`sem`, `hem`, `wem`).

## Cross-cutting documents

| Document | Content |
|---|---|
| [API-CONVENTIONS.md](API-CONVENTIONS.md) | Suffix grammar, inverters, facilitators, builders, Px twins, Flutter adaptations |
| [MATHEMATICS-AND-CALCULUS.md](MATHEMATICS-AND-CALCULUS.md) | Formal formulas, hardcoded constants, precomputation matrix, precision policy |
| [MODULES.md](MODULES.md) | Package graph and dependency rules |
| [../LLMS.txt](../LLMS.txt) | LLM-oriented library index |
| [../skills/SKILL.md](../skills/SKILL.md) | AI-agent workflow skill (with [library-map](../skills/library-map.md) / [reference](../skills/reference.md)) |

## Decision flowchart

```text
Need a size that grows with the screen?
│
├─ Just "bigger screen = bigger UI"          → Scaled (sdp/hdp/wdp)      ← start here
├─ Text must never overflow                  → Resize (AutoResizeText)
├─ Size as a fraction of the screen          → Percent (or literal spaceW/spaceH)
├─ Sub-linear growth on big screens          → Auto or Logarithmic
├─ Smooth clamp between min/max              → Fluid
├─ Preserve shape on extreme aspect ratios   → add the a suffix (aspect ratio)
└─ Real-world physical size                  → Units (mm/cm/inch)
└─ No built-in curve fits / shared design law → Custom (appdimens_custom)
```

## Precision policy

All math runs in IEEE-754 doubles using the same constants as the Kotlin
engine (`ι = 0.0033333334`, `k = 0.0026666667`, reference AR `1.78`). Parity
against the Kotlin formulas is verified by generated reference vectors with a
tolerance far below the family's `< 0.05 dp` policy.
