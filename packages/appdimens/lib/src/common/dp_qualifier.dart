/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Screen axis qualifier used by the dynamic scaling engine.
///
/// EN: Selects which window dimension drives the scaling curve.
/// PT: Seleciona qual dimensão da janela conduz a curva de escalonamento.
enum DpQualifier {
  /// EN Smallest window width (`sw`), stable across rotations. Recommended default.
  /// PT Menor largura da janela (`sw`), estável entre rotações. Padrão recomendado.
  smallWidth,

  /// EN Current window height (`h`).
  /// PT Altura atual da janela (`h`).
  height,

  /// EN Current window width (`w`).
  /// PT Largura atual da janela (`w`).
  width,
}
