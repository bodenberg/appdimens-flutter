# AppDimens Resize

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Constraint-based auto-fit: builds a step table and binary-searches the largest candidate that fits — plus ready widgets `AutoResizeText` and `AutoResizeSquare`.

## Installation

```yaml
dependencies:
  appdimens_resize: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_resize/appdimens_resize.dart';
AutoResizeText('Headline', minSp: 10, maxSp: 28),
AutoResizeSquare(min: 40, max: 120, child: Icon(Icons.aspect_ratio));
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| Range search + fitting predicates | not axis-bound | sp bounds supported | — |


See the complete guide: [DOCUMENTATION/resize.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/resize.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
