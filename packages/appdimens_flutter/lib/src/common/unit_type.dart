/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Physical / logical unit type used by the units module and radius helpers.
enum UnitType {
  /// EN International inch.
  /// PT Polegada internacional.
  inch,

  /// EN Centimeter.
  /// PT Centímetro.
  cm,

  /// EN Millimeter.
  /// PT Milímetro.
  mm,

  /// EN Scale-independent pixel (respects the system font scale).
  /// PT Pixel independente de escala (respeita a fonte do sistema).
  sp,

  /// EN Density-independent pixel.
  /// PT Pixel independente de densidade.
  dp,

  /// EN Physical device pixel.
  /// PT Pixel físico do dispositivo.
  px,
}
