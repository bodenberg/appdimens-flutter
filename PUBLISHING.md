# Publishing Guide — AppDimens Flutter

Step-by-step to publish the family to **pub.dev**. All packages are already
prepared: versioned intra-workspace constraints (`^3.2.0`), per-package
README/CHANGELOG/LICENSE, and `publish_to: none` on the apps (never
published).

## Status (2026-08-22)

- **Live on pub.dev:** appdimens_flutter, percent, power, fluid, interpolated,
  diagonal, perimeter, density, resize, units, auto, logarithmic.
- **Pending** (blocked by pub.dev's *daily* new-package rate limit — 12/day):
  `appdimens_fill`, `appdimens_fit`, `appdimens_bom`. Retry after the window
  resets:

```bash
for p in appdimens_fill appdimens_fit appdimens_bom; do \
  (cd "packages/$p" && dart pub publish --force); done
```

> The principal artifact is named `appdimens_flutter`: pub.dev rejected the
> bare name `appdimens` as too similar to the existing `app_dimen` package.

## 0. One-time setup

1. Log in with a Google account: `dart pub login` (browser flow).
2. *(Optional, recommended)* Create a **verified publisher**
   (e.g. `bodenberg.dev`) at pub.dev → Publisher settings, then add
   `publisher: bodenberg.dev` to every package pubspec — the equivalent of
   the `io.github.bodenberg` group id used by the Kotlin family.
3. Confirm the names are free: `appdimens_flutter`, `appdimens_percent`, … (checked
   free at preparation time).

## 1. Validate everything

```bash
for p in appdimens appdimens_auto appdimens_bom appdimens_density \
         appdimens_diagonal appdimens_fill appdimens_fit appdimens_fluid \
         appdimens_interpolated appdimens_logarithmic appdimens_percent \
         appdimens_perimeter appdimens_power appdimens_resize appdimens_units; do
  (cd "packages/$p" && flutter pub publish --dry-run) || echo "FAIL $p"
done
```

Every run must end in `Package has 0 warnings.`

## 2. Publish (order matters)

Consumers resolve hosted dependencies, so publish the core first and the BOM
last:

```bash
cd packages/appdimens_flutter        && flutter pub publish        # 1. core
cd ../appdimens_percent      && flutter pub publish        # 2. satellites…
cd ../appdimens_power        && flutter pub publish
cd ../appdimens_fluid        && flutter pub publish
cd ../appdimens_auto         && flutter pub publish
cd ../appdimens_logarithmic  && flutter pub publish
cd ../appdimens_interpolated && flutter pub publish
cd ../appdimens_diagonal     && flutter pub publish
cd ../appdimens_perimeter    && flutter pub publish
cd ../appdimens_density      && flutter pub publish
cd ../appdimens_fill         && flutter pub publish
cd ../appdimens_fit          && flutter pub publish
cd ../appdimens_resize       && flutter pub publish
cd ../appdimens_units        && flutter pub publish
cd ../appdimens_bom          && flutter pub publish        # 15. last
```

All inter-package dependencies are declared as **hosted constraints**
(`appdimens_flutter: ^3.2.0`). Inside the workspace, pub resolves them automatically
to the local members; on publish, the hosted source is used directly — the
pattern recommended by the official workspace docs (no `path` dependencies in
publishable packages).

## 3. Automated publishing (recommended for next versions)

1. On pub.dev → package Admin → *Automated publishing*, register the GitHub
   repository/workflow.
2. Use `.github/workflows/publish.yml` in this repo (tag `v3.x.y` → publishes
   all 15 packages in order with `--force`).

## 4. Version policy

- Keep one version across the family per release (currently `3.2.0`),
  aligned with AppDimens Dynamic/KMP.
- Bump → update `CHANGELOG.md` (root) → regenerate package assets
  (`python3 scripts/generate_package_docs.py`) → tag `v3.x.y`.

## Checklist

- [ ] `flutter analyze .` zero issues
- [ ] `flutter test packages apps` green
- [ ] `--dry-run` clean on all 15 packages
- [ ] Root CHANGELOG updated
- [ ] Tag pushed after publishing
