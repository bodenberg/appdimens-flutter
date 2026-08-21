# Security Policy

## Supported versions
| Version | Supported |
|---|---|
| 3.2.x | ✅ |
| ≤ 2.x (deprecated) | ❌ |

## Reporting a vulnerability
Open a GitHub security advisory ("Report a vulnerability" on the repository)
or contact the maintainer via GitHub (@bodenberg). Please do not open public
issues for suspected vulnerabilities.

The library is pure Dart/UI logic: no network access, no platform channels,
no file I/O. Attack surface is limited to numeric edge cases — the engine
guards non-finite inputs and rejects invalid sensitivities with exceptions
rather than leaking NaN into layouts.
