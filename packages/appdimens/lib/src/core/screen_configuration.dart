/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Immutable window-configuration snapshot shared by the whole engine.

/// EN: A value snapshot of the current window — the Flutter analog of the
/// Kotlin `ScreenConfiguration`. All fields are inputs that affect a result,
/// so equality can be used as an exact cache-partition key.
///
/// PT: Um snapshot de valores da janela atual — o análogo Flutter do
/// `ScreenConfiguration` em Kotlin. Todos os campos afetam o resultado, de
/// forma que a igualdade pode ser usada como chave exata de partição de cache.
class ScreenConfiguration {
  static const int orientationUndefined = 0;
  static const int orientationPortrait = 1;
  static const int orientationLandscape = 2;

  /// Current window bounds width in dp (logical pixels).
  final int screenWidthDp;

  /// Current window bounds height in dp.
  final int screenHeightDp;

  /// Smallest historical window width in dp; when unknown/zero it is derived
  /// from [screenWidthDp]/[screenHeightDp].
  final int smallestScreenWidthDp;

  /// Display density in dpi (`devicePixelRatio × 160` by convention).
  final int densityDpi;

  /// Configured system font scale (normalized to a safe value later).
  final double fontScale;

  /// Raw orientation code (0 undefined · 1 portrait · 2 landscape).
  final int orientation;

  /// Raw ui-mode value (see [UiModeType.configValue]).
  final int uiMode;

  const ScreenConfiguration({
    this.screenWidthDp = 300,
    this.screenHeightDp = 533,
    this.smallestScreenWidthDp = 0,
    this.densityDpi = 160,
    this.fontScale = 1.0,
    this.orientation = orientationUndefined,
    this.uiMode = 0,
  });

  /// Baseline reference configuration (300 × 533 @ 160dpi, font scale 1.0).
  static const ScreenConfiguration baseline = ScreenConfiguration();

  bool get isPortrait => orientation == orientationPortrait;

  bool get isLandscape => orientation == orientationLandscape;

  /// Resolves the effective smallest width, falling back to the min dimension
  /// and finally to the 300 dp design baseline.
  int get effectiveSmallestWidthDp {
    if (smallestScreenWidthDp > 0) return smallestScreenWidthDp;
    final minDim = screenWidthDp < screenHeightDp ? screenWidthDp : screenHeightDp;
    if (minDim > 0) return minDim;
    return 300;
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenConfiguration &&
        other.screenWidthDp == screenWidthDp &&
        other.screenHeightDp == screenHeightDp &&
        other.smallestScreenWidthDp == smallestScreenWidthDp &&
        other.densityDpi == densityDpi &&
        other.fontScale == fontScale &&
        other.orientation == orientation &&
        other.uiMode == uiMode;
  }

  @override
  int get hashCode => Object.hash(
        screenWidthDp,
        screenHeightDp,
        smallestScreenWidthDp,
        densityDpi,
        fontScale,
        orientation,
        uiMode,
      );

  @override
  String toString() =>
      'ScreenConfiguration(${screenWidthDp}×${screenHeightDp}, sw=$smallestScreenWidthDp, '
      'dpi=$densityDpi, fs=$fontScale, or=$orientation, ui=$uiMode)';
}
