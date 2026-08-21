/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Orientation-based dimension swap rule applied before reading the screen axis.
enum Inverter {
  /// EN No swap — the qualifier is used as-is.
  /// PT Sem troca — o qualificador é usado como está.
  standard,

  /// EN HEIGHT in landscape becomes WIDTH (`hdpLw` family).
  /// PT HEIGHT em paisagem torna-se WIDTH (família `hdpLw`).
  phToLw,

  /// EN WIDTH in landscape becomes HEIGHT (`wdpLh` family).
  /// PT WIDTH em paisagem torna-se HEIGHT (família `wdpLh`).
  pwToLh,

  /// EN HEIGHT in portrait becomes WIDTH (`hdpPw` family).
  /// PT HEIGHT em retrato torna-se WIDTH (família `hdpPw`).
  lhToPw,

  /// EN WIDTH in portrait becomes HEIGHT (`wdpPh` family).
  /// PT WIDTH em retrato torna-se HEIGHT (família `wdpPh`).
  lwToPh,

  /// EN SMALL_WIDTH in landscape becomes HEIGHT (`sdpLh` family).
  /// PT SMALL_WIDTH em paisagem torna-se HEIGHT (família `sdpLh`).
  swToLh,

  /// EN SMALL_WIDTH in landscape becomes WIDTH (`sdpLw` family).
  /// PT SMALL_WIDTH em paisagem torna-se WIDTH (família `sdpLw`).
  swToLw,

  /// EN SMALL_WIDTH in portrait becomes HEIGHT (`sdpPh` family).
  /// PT SMALL_WIDTH em retrato torna-se HEIGHT (família `sdpPh`).
  swToPh,

  /// EN SMALL_WIDTH in portrait becomes WIDTH (`sdpPw` family).
  /// PT SMALL_WIDTH em retrato torna-se WIDTH (família `sdpPw`).
  swToPw,
}
