# AppDimens Units

> Part of the **AppDimens Flutter** family — Flutter port of
> [AppDimens Dynamic](https://github.com/bodenberg/appdimens-dynamic) /
> [AppDimens KMP](https://github.com/bodenberg/appdimens-kmp).

Physical units: mm/cm/inch → dp/px/sp conversions with optional calibrated ppi, pure unit↔unit converters and radius helpers.

## Installation

```yaml
dependencies:
  appdimens_units: ^3.2.0
```

> Prefer one dependency for everything? Use [`appdimens_bom`](https://pub.dev/packages/appdimens_bom).

## Usage

```dart
import 'package:appdimens_units/appdimens_units.dart';
final card = DimenPhysicalUnits.toDpFromMm(85, scope: scope);
final cm   = 25.4.mmToCm;
```

## Family grammar

Every strategy shares the same API grammar — suffixes (`a` · `i` · `ia`),
orientation inverters (`Ph/Lh/Pw/Lw`), facilitators (`Rotate/Mode/Qualifier/
Screen` + Plain pairs), sp twins (`ssp`) and no-font-scale stems (`sem`):

| Stem | Axis | Sp | No font scale |
|------|------|----|----------------|
| Stem | Axis | Text (sp) | No font scale |
|---|---|---|---|
| mm / cm / inch converters | physical | — | — |


See the complete guide: [DOCUMENTATION/physical-units.md](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/physical-units.md) ·
[Math](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/MATHEMATICS-AND-CALCULUS.md) ·
[API conventions](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/API-CONVENTIONS.md)

## License

Apache License 2.0 — © Jean Bodenberg.
