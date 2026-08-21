/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// Lock-free-friendly snapshot-partitioned result cache + the global fast-lane
/// metrics scope.
import '../common/dp_qualifier.dart';
import '../common/inverter.dart';
import '../common/ui_mode_type.dart';
import 'dimen_metrics.dart';
import 'screen_configuration.dart';

/// Calculation family encoded in a [CacheKey].
enum CalcType {
  auto,
  diagonal,
  fill,
  fit,
  fluid,
  interpolated,
  logarithmic,
  percent,
  perimeter,
  power,
  resize,
  scaled,
  unities,
  aspectRatio,
  density,
}

/// Output unit encoded in a [CacheKey].
enum ValueType { dp, px, spWithScale, spNoScale, spPxWithScale, spPxNoScale }

/// Immutable cache key (web-safe: no 64-bit bit packing, exact equality).
class CacheKey {
  final double baseValue;
  final bool isLandscape;
  final bool ignoreMultiWindows;
  final CalcType calcType;
  final DpQualifier qualifier;
  final Inverter inverter;
  final bool applyAspectRatio;
  final ValueType valueType;
  final double? customSensitivityK;

  late final int _fingerprint = () {
    if (customSensitivityK == null) return 0xFFFF;
    return (customSensitivityK! * 100000).round() & 0xFFFF;
  }();

  late final int _hash = Object.hash(
    baseValue,
    isLandscape ? 1 : 0,
    ignoreMultiWindows ? 1 : 0,
    calcType.index,
    qualifier.index,
    inverter.index,
    applyAspectRatio ? 1 : 0,
    valueType.index,
    _fingerprint,
  );

  CacheKey({
    required this.baseValue,
    required this.isLandscape,
    required this.ignoreMultiWindows,
    required this.calcType,
    required this.qualifier,
    required this.inverter,
    required this.applyAspectRatio,
    required this.valueType,
    this.customSensitivityK,
  });

  bool get hasCustomSensitivity => customSensitivityK != null;

  @override
  bool operator ==(Object other) =>
      other is CacheKey &&
      other._hash == _hash &&
      other.baseValue == baseValue &&
      other.isLandscape == isLandscape &&
      other.ignoreMultiWindows == ignoreMultiWindows &&
      other.calcType == calcType &&
      other.qualifier == qualifier &&
      other.inverter == inverter &&
      other.applyAspectRatio == applyAspectRatio &&
      other.valueType == valueType &&
      other._fingerprint == _fingerprint;

  @override
  int get hashCode => _hash;
}

/// Per-snapshot cache partition with bounded capacity.
class SnapshotCache {
  final DimenMetrics metrics;
  final Map<CacheKey, double> entries = {};

  SnapshotCache(this.metrics);

  void insert(CacheKey key, double value) {
    if (entries.length >= DimenCache.snapshotCacheSize && !entries.containsKey(key)) {
      final oldest = entries.keys.first;
      entries.remove(oldest);
    }
    entries[key] = value;
  }
}

/// EN: Global resolution scope — the Flutter analog of the KMP
/// `metricsScope` / Compose `LocalDimenMetrics`. `AppDimensProvider`
/// publishes each window snapshot here so `num.sdp`-style getters resolve
/// through one static read + one multiply (the fast lane).
///
/// PT: Escopo global de resolução — o análogo Flutter do `metricsScope` /
/// `LocalDimenMetrics` do KMP. O `AppDimensProvider` publica cada snapshot de
/// janela aqui para que getters como `num.sdp` resolvam com uma leitura
/// estática e uma multiplicação (a faixa rápida).
abstract final class AppDimensScope {
  static DimenMetrics? _slot;
  static AppDimensContextLike? _contextSlot;
  static UiModeType? _uiModeType;

  /// Currently published snapshot, or `null` before any publication.
  static DimenMetrics? get metrics => _slot;

  /// Currently published window context, or `null`.
  static AppDimensContextLike? get context => _contextSlot;

  /// Publishes [metrics] as the process-wide snapshot (fast-lane slot).
  static void publish(DimenMetrics metrics) => _slot = metrics;

  /// Publishes the window context used by facilitators and the full engine.
  static void publishContext(AppDimensContextLike context) =>
      _contextSlot = context;

  /// Publishes the detected/forced [UiModeType] (used by `*Mode`/`*Screen`).
  static void publishUiModeType(UiModeType type) => _uiModeType = type;

  /// Clears every slot (used by tests).
  static void clear() {
    _slot = null;
    _contextSlot = null;
    _uiModeType = null;
  }

  /// The effective ui-mode type: published value, else `undefined`.
  static UiModeType get uiModeTypeOrDefault =>
      _uiModeType ?? UiModeType.undefined;

  /// Runs [body] with an explicit [metrics] scope (save/restore), mirroring
  /// `DimenCache.withMetrics`.
  static T withMetrics<T>(DimenMetrics metrics, T Function() body) {
    final previous = _slot;
    final previousContext = _contextSlot;
    _slot = metrics;
    _contextSlot = null;
    try {
      return body();
    } finally {
      _slot = previous;
      _contextSlot = previousContext;
    }
  }

  /// The effective snapshot: explicit slot, else the engine fallback.
  static DimenMetrics get metricsOrDefault => _slot ?? DimenCache.fallbackMetrics;
}

/// EN: Snapshot-partitioned memoization shared by code APIs, widgets and every
/// strategy satellite. The dominant families bypass the hash entirely on the
/// default path because one multiply (~2 ns native) beats a lookup — exactly
/// like the Kotlin engine (`shouldBypassCache`).
///
/// PT: Memoização particionada por snapshot compartilhada por APIs de código,
/// widgets e todos os satélites de estratégia. As famílias dominantes ignoram
/// o hash no caminho padrão porque uma multiplicação vence a consulta — como
/// no motor Kotlin (`shouldBypassCache`).
abstract final class DimenCache {
  // ── Math constants (bit-parity with Kotlin) ─────────────────────────────
  static const double invBaseRatio = 0.0033333334; // 1f / 300f
  static const double adjustmentScale = 0.0033333334; // 0.10f / 30f
  static const double sensitivityDefault = 0.0026666667; // 0.08f / 30f

  // ── Partition geometry ──────────────────────────────────────────────────
  static const int maxSnapshotCaches = 4;
  static const int snapshotCacheSize = 512;

  static final Map<DimenMetrics, SnapshotCache> _partitions = {};
  static DimenMetrics _fallback = DimenMetrics.baseline;
  static bool _enabled = true;
  static int _hits = 0;
  static int _misses = 0;
  static int _evictions = 0;
  static final List<void Function()> _resetListeners = [];

  /// Fallback snapshot used when nothing was published yet.
  static DimenMetrics get fallbackMetrics => _fallback;

  /// Enables/disables memoization (math always runs the full path when off).
  static bool get isEnabled => _enabled;

  static set isEnabled(bool value) {
    _enabled = value;
    if (!value) clear();
  }

  /// Publishes the fallback snapshot (no-op when equal to the current one).
  static void init(ScreenConfiguration configuration) {
    final m = DimenMetrics.from(configuration);
    if (_fallback != m) {
      _fallback = m;
      notifyResetListeners();
    }
  }

  /// Registers a listener invoked whenever partitions are invalidated.
  static void addResetListener(void Function() listener) =>
      _resetListeners.add(listener);

  static void removeResetListener(void Function() listener) {
    _resetListeners.remove(listener);
  }

  static void notifyResetListeners() {
    for (final l in List.of(_resetListeners)) {
      l();
    }
  }

  /// The snapshot currently driving resolutions (scope → published → fallback).
  static DimenMetrics get currentMetrics =>
      AppDimensScope.metrics ?? _fallback;

  /// Coherent snapshot for an explicit context (never retained).
  static DimenMetrics metricsFor(AppDimensContextLike context) =>
      context.dimenMetrics;

  // ── Partition management ───────────────────────────────────────────────

  static SnapshotCache _cacheFor(DimenMetrics metrics) {
    final existing = _partitions[metrics];
    if (existing != null) return existing;
    if (_partitions.length >= maxSnapshotCaches) {
      final victim = _partitions.keys
          .firstWhere((k) => !identical(k, metrics), orElse: () => metrics);
      _partitions.remove(victim);
      _evictions++;
    }
    final created = SnapshotCache(metrics);
    _partitions[metrics] = created;
    return created;
  }

  /// True when this key's family must skip the hash on the default path.
  static bool shouldBypassCache(CacheKey key) {
    if (key.hasCustomSensitivity) return false;
    switch (key.calcType) {
      case CalcType.percent:
      case CalcType.scaled:
      case CalcType.density:
      case CalcType.diagonal:
      case CalcType.interpolated:
      case CalcType.perimeter:
        return !_keyHasAr(key) || _isDefaultSwPath(key);
      case CalcType.power:
      case CalcType.logarithmic:
        return _isDefaultSwPath(key);
      case CalcType.auto:
      case CalcType.fill:
      case CalcType.fit:
      case CalcType.fluid:
      case CalcType.resize:
      case CalcType.unities:
      case CalcType.aspectRatio:
        return false;
    }
  }

  static bool _keyHasAr(CacheKey key) => key.applyAspectRatio;

  static bool _isDefaultSwPath(CacheKey key) =>
      key.qualifier == DpQualifier.smallWidth &&
      key.inverter == Inverter.standard;

  /// Resolves [key] against the current snapshot partition.
  static double getOrPut(CacheKey key, double Function() compute) =>
      getOrPutFor(currentMetrics, key, compute);

  /// Resolves [key] against an explicit coherent [metrics] snapshot.
  static double getOrPutFor(
    DimenMetrics metrics,
    CacheKey key,
    double Function() compute,
  ) {
    if (!_enabled || key.hasCustomSensitivity || shouldBypassCache(key)) {
      return compute();
    }
    final cache = _cacheFor(metrics);
    final hit = cache.entries[key];
    if (hit != null) {
      _hits++;
      return hit;
    }
    _misses++;
    final value = compute();
    if (value.isFinite) cache.insert(key, value);
    return value;
  }

  /// Reads without computing.
  static double? peek(CacheKey key) =>
      _partitions[currentMetrics]?.entries[key];

  /// Drops the partition of [metrics] (or all partitions when null).
  static void invalidate([DimenMetrics? metrics]) {
    if (metrics == null) {
      _partitions.clear();
    } else {
      _partitions.remove(metrics);
    }
    notifyResetListeners();
  }

  /// Event-driven hook: call when a window configuration changes. Partitions
  /// are keyed by exact snapshot, so correctness never depends on this — it
  /// only releases memory earlier.
  static void invalidateOnConfigChange(ScreenConfiguration configuration) {
    invalidate(DimenMetrics.from(configuration));
  }

  /// Clears everything (tests / low-memory hooks).
  static void clear() {
    _partitions.clear();
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    notifyResetListeners();
  }

  /// Aggregated diagnostics for BenchLab.
  static CacheStats stats() {
    var populated = 0;
    for (final p in _partitions.values) {
      populated += p.entries.length;
    }
    final lookups = _hits + _misses;
    return CacheStats(
      partitions: _partitions.length,
      capacity: maxSnapshotCaches * snapshotCacheSize,
      populated: populated,
      hits: _hits,
      misses: _misses,
      evictions: _evictions,
      hitRate: lookups == 0 ? 0 : _hits / lookups,
    );
  }

  /// Resets diagnostic counters.
  static void resetDiagnostics() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }
}

/// Structural window view needed by the engine — satisfied by every
/// [AppDimensContext] and by test fakes; keeps core import cycles flat.
abstract interface class AppDimensContextLike {
  ScreenConfiguration get configuration;

  /// Coherent snapshot derived from [configuration].
  DimenMetrics get dimenMetrics;

  /// Detected / forced UI-mode type.
  UiModeType get uiModeType;
}

/// Immutable cache statistics (mirrors KMP `CacheStats`).
class CacheStats {
  final int partitions;
  final int capacity;
  final int populated;
  final int hits;
  final int misses;
  final int evictions;
  final double hitRate;

  const CacheStats({
    required this.partitions,
    required this.capacity,
    required this.populated,
    required this.hits,
    required this.misses,
    required this.evictions,
    required this.hitRate,
  });

  @override
  String toString() => 'CacheStats(partitions=$partitions, '
      'populated=$populated/$capacity, hitRate=${(hitRate * 100).toStringAsFixed(1)}%)';
}
