/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Curve constants for this strategy.
/// Blend factor of the interpolated curve.
abstract final class Interpolation {
  /// EN 0.0 = raw base · 1.0 = fully scaled.
  /// PT 0.0 = base crua · 1.0 = totalmente escalada.
  static const double defaultBlend = 0.5;
}

