# AppDimens BOM

Meta-package that re-exports the principal artifact
([appdimens_flutter](https://pub.dev/packages/appdimens_flutter)) and **every** strategy
satellite at a coherent version — the Maven-BOM equivalent of the AppDimens
Kotlin family.

## Installation

```yaml
dependencies:
  appdimens_bom: ^3.2.0
```

## Usage

One import gives you the whole family:

```dart
import 'package:appdimens_bom/appdimens_bom.dart';

final pad = 16.sdp;      // scaled (principal artifact)
final w   = 50.spaceW;   // percent
final t   = 16.fsdp;     // fluid
```

Included modules: appdimens_flutter · percent · power · fluid · auto · diagonal ·
fill · fit · interpolated · logarithmic · perimeter · density · resize · units.

Family docs: [DOCUMENTATION](https://github.com/bodenberg/appdimens-flutter/blob/main/DOCUMENTATION/README.md).
