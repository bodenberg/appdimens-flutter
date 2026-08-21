/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Device UI-mode type used by facilitators (`*Mode`, `*Screen`) and builders.
enum UiModeType {
  /// EN Undefined / not resolved.
  /// PT Indefinido / não resolvido.
  undefined(0),

  /// EN Normal phone / tablet / desktop UI.
  /// PT UI normal de telefone / tablet / desktop.
  normal(1),

  /// EN Television.
  /// PT Televisão.
  television(2),

  /// EN Car system.
  /// PT Sistema automotivo.
  car(3),

  /// EN Watch / wearable.
  /// PT Relógio / wearable.
  watch(4),

  /// EN Appliance (IoT panel, kiosk).
  /// PT Eletrodoméstico (painel IoT, quiosque).
  appliance(6),

  /// EN VR headset.
  /// PT Headset de realidade virtual.
  vrHeadset(7),

  /// EN Foldable with the hinge open (large inner display active).
  /// PT Dobrável com a dobra aberta (tela interna grande ativa).
  foldOpen(-101),

  /// EN Foldable with the hinge closed (cover display active).
  /// PT Dobrável com a dobra fechada (tela externa ativa).
  foldClosed(-102),

  /// EN Flip-style device opened.
  /// PT Dispositivo flip aberto.
  flipOpen(-103),

  /// EN Flip-style device closed.
  /// PT Dispositivo flip fechado.
  flipClosed(-104),

  /// EN Foldable half-opened (laptop / tent posture).
  /// PT Dobrável meio aberto (postura laptop / tenda).
  foldHalfOpened(-105),

  /// EN Flip device half-opened.
  /// PT Dispositivo flip meio aberto.
  flipHalfOpened(-106);

  const UiModeType(this.configValue);

  /// Raw configuration value (mirrors the Android/KMP contract).
  final int configValue;

  /// Resolves a raw configuration value; unknown values fall back to [normal].
  static UiModeType fromConfigurationValue(int value) {
    for (final type in UiModeType.values) {
      if (type.configValue == value) return type;
    }
    return UiModeType.normal;
  }
}
