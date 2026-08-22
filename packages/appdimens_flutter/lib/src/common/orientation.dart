/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Device orientation codes shared by the configuration snapshot and builders.
enum DimensOrientation {
  /// EN Undefined / not resolved (matches Android `ORIENTATION_UNDEFINED`).
  /// PT Indefinida / não resolvida (equivale a `ORIENTATION_UNDEFINED` do Android).
  undefined,

  /// EN Portrait.
  /// PT Retrato.
  portrait,

  /// EN Landscape.
  /// PT Paisagem.
  landscape,
}

/// Builder-facing orientation request used by [DimenScaled]-style chains and
/// facilitators (`*Rotate`).
enum OrientationRequest {
  /// EN Apply on both orientations (no orientation filter).
  /// PT Aplica nas duas orientações (sem filtro de orientação).
  any,

  /// EN Apply only in portrait.
  /// PT Aplica somente em retrato.
  portrait,

  /// EN Apply only in landscape.
  /// PT Aplica somente em paisagem.
  landscape,
}
