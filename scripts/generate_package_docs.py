#!/usr/bin/env python3
"""Generates per-package publish assets (README.md, CHANGELOG.md, LICENSE)
for every publishable package in the AppDimens Flutter workspace.

Run after changing package metadata:  python3 scripts/generate_package_docs.py
"""
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "packages")
VER = "3.2.0"
LICENSE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "LICENSE")

HEADER = """# {title}

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

{blurb}

## Installation

```yaml
dependencies:
  {pkg}: ^{ver}
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:{pkg}/{pkg}.dart';
{usage}
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
{stems}

See the complete guide: [DOCUMENTATION/{doc}.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/{doc}.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
"""

PACKAGES = {
    "appdimens": dict(
        title="AppDimens — Smart Responsive Dimensioning",
        blurb=(
            "The principal artifact: core engine, immutable window snapshots, "
            "snapshot-partitioned cache and the default **Scaled** strategy "
            "(`sdp/hdp/wdp` + text `ssp/hsp/wsp`, no-font-scale `sem/hem/wem`). "
            "`16.sdp` resolves through a fast lane: one static snapshot read + one multiply."
        ),
        usage="""final pad  = 16.sdp;    // smallest-width curve
final h    = 48.hdp;    // height curve
final size = 100.wdp;   // width curve

// conditional chain (priority: ui+qualifier → ui → qualifier → orientation)
final box = 100.scaledDp
    .screenMode(UiModeType.television, 500)
    .screenQualifier(DpQualifier.smallWidth, 600, 150);""",
        doc="scaled",
        stems=("| `sdp` / `hdp` / `wdp` | smallest width / height / width | `ssp/hsp/wsp` | `sem/hem/wem` |\n"),
        pkg="appdimens",
    ),
    "appdimens_percent": dict(
        title="AppDimens Percent",
        blurb="Percentage strategy: the linear Scaled law under the `psdp/phdp/pwdp` stems plus a **literal** percentage family — `30.spaceW` is exactly 30 % of the window width.",
        usage="""final frac = 30.spaceW;     // 30% of current width
final band = 25.spaceH;     // 25% of current height
final pad  = 10.psdp;       // Scaled-law percent stem""",
        doc="percent",
        stems=("| `psdp` / `phdp` / `pwdp` | smallest width / height / width | `pssp/phsp/pwsp` | `psem/phem/pwem` |\n"),
        pkg="appdimens_percent",
    ),
    "appdimens_power": dict(
        title="AppDimens Power",
        blurb="Sub-linear perceptual growth: `base × (d/300)^0.75`. Sizes grow on large screens but progressively less — memoized factor on the default path.",
        usage="""final pad = 16.pwsdp;
final ar  = 16.pwsdpa;   // + aspect-ratio multiplier""",
        doc="power",
        stems=("| `pwsdp` / `pwhdp` / `pwwdp` | smallest width / height / width | `pwssp/pwhsp/pwwsp` | `pwsem/phem/pwem` |\n".replace("pwsem","pwsem").replace("phem","pwhem")),
        pkg="appdimens_power",
    ),
    "appdimens_fluid": dict(
        title="AppDimens Fluid",
        blurb="CSS-clamp-like strategy: plateaus at `b×0.8` below 320 dp and `b×1.2` above 768 dp, with a smooth lerp between — hard bounds guaranteed.",
        usage="""final text = 16.fsdp;    // fluid clamp on smallest width""",
        doc="fluid",
        stems=("| `fsdp` / `fhdp` / `fwdp` | smallest width / height / width | `fssp/fhsp/fwsp` | `fsem/fhem/fwem` |\n"),
        pkg="appdimens_fluid",
    ),
    "appdimens_auto": dict(
        title="AppDimens Auto",
        blurb="Linear on phones, logarithmically damped beyond the 480 dp transition — the pragmatic hybrid recommended as the second choice after Scaled.",
        usage="""final pad = 16.asdp;
final w   = 800.awdp;""",
        doc="auto",
        stems=("| `asdp` / `ahdp` / `awdp` | smallest width / height / width | `assp/ahsp/awsp` | `asem/ahem/awem` |\n"),
        pkg="appdimens_auto",
    ),
    "appdimens_diagonal": dict(
        title="AppDimens Diagonal",
        blurb="Scales by the window diagonal against the design baseline (√(300²+533²)) — orientation-stable and qualifier-independent.",
        usage="""final size = 16.dgsdp;   // same value on every axis/rotation""",
        doc="diagonal",
        stems=("| `dgsdp` / `dghdp` / `dgwdp` | any (independent) | `dgssp/dghsp/dgwsp` | `dgsem/dghem/dgwem` |\n"),
        pkg="appdimens_diagonal",
    ),
    "appdimens_fill": dict(
        title="AppDimens Fill",
        blurb="CSS `cover` semantics for dimensioning: uses the larger axis ratio so elements always cover their area (may overflow).",
        usage="""final bg = 120.flsdp;""",
        doc="fill",
        stems=("| `flsdp` / `flhdp` / `flwdp` | cover ratio | `flssp/flhsp/flwsp` | `flsem/flhem/flwem` |\n"),
        pkg="appdimens_fill",
    ),
    "appdimens_fit": dict(
        title="AppDimens Fit",
        blurb="CSS `contain` semantics: uses the smaller axis ratio so elements always fit inside their target area.",
        usage="""final logo = 64.ftsdp;""",
        doc="fit",
        stems=("| `ftsdp` / `fthdp` / `ftwdp` | contain ratio | `ftssp/fthsp/ftwsp` | `ftsem/fthem/ftwem` |\n"),
        pkg="appdimens_fit",
    ),
    "appdimens_interpolated": dict(
        title="AppDimens Interpolated",
        blurb="Fixed 50 % blend between the raw value and the fully-scaled value — exactly half of linear growth.",
        usage="""final pad = 16.isdp;""",
        doc="interpolated",
        stems=("| `isdp` / `ihdp` / `iwdp` | smallest width / height / width | `issp/ihsp/iwsp` | `isem/ihem/iwem` |\n"),
        pkg="appdimens_interpolated",
    ),
    "appdimens_logarithmic": dict(
        title="AppDimens Logarithmic",
        blurb="Symmetric ±0.4·ln damping around the 300 dp baseline — the most conservative growth, ideal for density-first layouts.",
        usage="""final pad = 16.logsdp;""",
        doc="logarithmic",
        stems=("| `logsdp` / `loghdp` / `logwdp` | smallest width / height / width | `logssp/loghsp/logwsp` | `logsem/loghem/logwem` |\n"),
        pkg="appdimens_logarithmic",
    ),
    "appdimens_perimeter": dict(
        title="AppDimens Perimeter",
        blurb="Half-perimeter ratio `(min+max)/833` — orientation-stable growth based on both sides of the window.",
        usage="""final bar = 56.prsdp;""",
        doc="perimeter",
        stems=("| `prsdp` / `prhdp` / `prwdp` | any (independent) | `prssp/prhsp/prwsp` | `prsem/prhem/prwem` |\n"),
        pkg="appdimens_perimeter",
    ),
    "appdimens_density": dict(
        title="AppDimens Density",
        blurb="Anchors sizes to the physical pixel density (`dpi/160`) instead of the window size — for games, AR overlays and calibration UIs.",
        usage="""final marker = 24.dsdp;""",
        doc="density",
        stems=("| `dsdp` / `dhdp` / `dwdp` | density-driven | `dssp/dhsp/dwsp` | `dsem/dhem/dwem` |\n"),
        pkg="appdimens_density",
    ),
    "appdimens_resize": dict(
        title="AppDimens Resize",
        blurb="Constraint-based auto-fit: builds a step table and binary-searches the largest candidate that fits — plus ready widgets `AutoResizeText` and `AutoResizeSquare`.",
        usage="""AutoResizeText('Headline', minSp: 10, maxSp: 28),
AutoResizeSquare(min: 40, max: 120, child: Icon(Icons.aspect_ratio));""",
        doc="resize",
        stems=("| Range search + fitting predicates | not axis-bound | sp bounds supported | — |\n"),
        pkg="appdimens_resize",
    ),
    "appdimens_units": dict(
        title="AppDimens Units",
        blurb="Physical units: mm/cm/inch → dp/px/sp conversions with optional calibrated ppi, pure unit↔unit converters and radius helpers.",
        usage="""final card = DimenPhysicalUnits.toDpFromMm(85, scope: scope);
final cm   = 25.4.mmToCm;""",
        doc="physical-units",
        stems=("| mm / cm / inch converters | physical | — | — |\n"),
        pkg="appdimens_units",
    ),
}

BOM_README = """# AppDimens BOM

Meta-package that re-exports the principal artifact
([appdimens](https://pub.dev/packages/appdimens)) and **every** strategy
satellite at a coherent version — the Maven-BOM equivalent of the AppDimens
Kotlin family.

## Installation

```yaml
dependencies:
  appdimens_bom: ^{ver}
```

## Usage

One import gives you the whole family:

```dart
import 'package:appdimens_bom/appdimens_bom.dart';

final pad = 16.sdp;      // scaled (principal artifact)
final w   = 50.spaceW;   // percent
final t   = 16.fsdp;     // fluid
```

Included modules: appdimens · percent · power · fluid · auto · diagonal ·
fill · fit · interpolated · logarithmic · perimeter · density · resize · units.

Family docs: [DOCUMENTATION](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/README.md).
""".replace("{ver}", VER)


def stems_table(rows):
    return "| Stem | Axis | Text (sp) | No font scale |\n|---|---|---|---|\n" + rows


for pkg, cfg in PACKAGES.items():
    d = os.path.join(ROOT, pkg)
    readme = HEADER.format(
        title=cfg["title"],
        blurb=cfg["blurb"],
        pkg=pkg,
        ver=VER,
        usage=cfg["usage"],
        doc=cfg["doc"],
        stems=stems_table(cfg["stems"]),
    )
    open(os.path.join(d, "README.md"), "w").write(readme)

open(os.path.join(ROOT, "appdimens_bom", "README.md"), "w").write(BOM_README)

CHANGELOG = """# Changelog

All notable changes are tracked at the repository root:
[CHANGELOG.md](https://github.com/bodenberg/appdimens-flutter/blob/main/CHANGELOG.md).

## [{ver}]

- Initial release of this module as part of the AppDimens Flutter 3.2 family
  (port of AppDimens Dynamic 3.1.9 / KMP 1.0.1).
"""

for pkg in list(PACKAGES) + ["appdimens_bom"]:
    d = os.path.join(ROOT, pkg)
    open(os.path.join(d, "CHANGELOG.md"), "w").write(CHANGELOG.replace("{ver}", VER))
    if os.path.exists(LICENSE):
        open(os.path.join(d, "LICENSE"), "wb").write(open(LICENSE, "rb").read())

print("generated publish assets for", len(PACKAGES) + 1, "packages")
