# Contributing

## Setup

```bash
git clone https://github.com/bodenberg/appdimens-flutter.git
cd appdimens-flutter
flutter pub get          # workspace resolution (Dart ≥3.6 / Flutter ≥3.27)
```

## Rules

1. **Single source of truth for satellites** — edit
   `scripts/generate_satellites.py`, then regenerate
   (`python3 scripts/generate_satellites.py`). Do not hand-edit generated
   extension files except through the generator.
2. **Formulas are frozen contracts** — any math change must regenerate
   `packages/appdimens/test/reference_vectors.dart` and be justified against
   the Kotlin family docs.
3. **Quality gates** before every PR:

```bash
flutter analyze .            # zero issues
flutter test packages apps   # all suites green
```

4. Docs follow the per-strategy skeleton in DOCUMENTATION/README.md.
5. Commits follow Conventional Commits (`feat:, fix:, perf:, docs:…`).
