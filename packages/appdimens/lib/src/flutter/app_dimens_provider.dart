/// Author & Developer: Jean Bodenberg
/// GIT: https://github.com/bodenberg/appdimens
///
/// Library: AppDimens
///
/// `AppDimensProvider` / `AppDimensApp` — publish the window snapshot into
/// the global fast-lane scope on every configuration change.
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' show FlutterView;

import '../common/ui_mode_type.dart';
import '../core/app_dimens_context.dart';
import '../core/dimen_cache.dart';
import '../core/dimen_metrics.dart';
import '../core/screen_configuration.dart';

/// Optional provider-level overrides.
class AppDimensConfig {
  final UiModeType? forcedUiModeType;
  final bool? forcedMultiWindow;

  const AppDimensConfig({this.forcedUiModeType, this.forcedMultiWindow});

  @override
  bool operator ==(Object other) =>
      other is AppDimensConfig &&
      other.forcedUiModeType == forcedUiModeType &&
      other.forcedMultiWindow == forcedMultiWindow;

  @override
  int get hashCode => Object.hash(forcedUiModeType, forcedMultiWindow);
}

/// Data carried by [AppDimensProvider] to descendants.
class AppDimensSnapshot {
  final DimenMetrics metrics;
  final AppDimensContext context;
  final UiModeType uiModeType;

  const AppDimensSnapshot({
    required this.metrics,
    required this.context,
    required this.uiModeType,
  });
}

/// Builds a [ViewAppDimensContext] from the ambient [MediaQueryData] (or a
/// [FlutterView] fallback), mirroring the KMP window-handle contract.
ViewAppDimensContext buildAppDimensContext(
    MediaQueryData? media, FlutterView? view) {
  if (media != null) {
    final dpr = media.devicePixelRatio;
    final safeDpr = dpr.isFinite && dpr > 0 ? dpr : 1.0;
    final w = media.size.width;
    final h = media.size.height;
    final fsRaw = media.textScaler.scale(10) / 10;
    final fs = fsRaw.isFinite && fsRaw > 0 ? fsRaw : 1.0;
    return ViewAppDimensContext(
      configuration: ScreenConfiguration(
        screenWidthDp: w.round().clamp(1, 1 << 20),
        screenHeightDp: h.round().clamp(1, 1 << 20),
        densityDpi: (safeDpr * 160).round(),
        fontScale: fs,
        orientation: h >= w
            ? ScreenConfiguration.orientationPortrait
            : ScreenConfiguration.orientationLandscape,
      ),
      density: safeDpr,
      xdpi: safeDpr * 160,
      fontScale: fs,
      isInMultiWindowMode: false,
    );
  }
  if (view != null) return ViewAppDimensContext.fromView(view);
  return ViewAppDimensContext(
      configuration: ScreenConfiguration.baseline);
}

/// EN: Wrap your app once:
/// ```dart
/// AppDimensApp(
///   child: MaterialApp(home: MyPage()),
/// )
/// ```
/// Every metrics change (rotation, resize, split-screen, font-scale) is
/// observed and republished into [AppDimensScope], so `16.sdp`-style getters
/// always read the live window — the Flutter analog of the KMP event-driven
/// config watcher.
///
/// PT: Envolva seu app uma vez. Cada mudança de métricas (rotação,
/// redimensionamento, split-screen, escala de fonte) é observada e
/// republicada no [AppDimensScope], de modo que getters como `16.sdp` leiam
/// sempre a janela atual — o análogo Flutter do watcher de configuração
/// orientado a eventos do KMP.
class AppDimensApp extends StatefulWidget {
  final AppDimensConfig config;
  final Widget child;

  const AppDimensApp({
    super.key,
    this.config = const AppDimensConfig(),
    required this.child,
  });

  @override
  State<AppDimensApp> createState() => _AppDimensAppState();
}

class _AppDimensAppState extends State<AppDimensApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _publish();
  }

  @override
  void didUpdateWidget(AppDimensApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) _publish();
  }

  @override
  void didChangeMetrics() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publish();
    });
  }

  @override
  void didChangeTextScaleFactor() => _publish();

  @override
  void didChangePlatformBrightness() => _publish();

  void _publish() {
    final view = WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
        ? WidgetsBinding.instance.platformDispatcher.views.first
        : null;
    final ctx = buildAppDimensContext(null, view);
    publishAppDimensContext(ctx, widget.config);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AppDimensProvider(config: widget.config, child: widget.child);
}

/// Publishes an explicit context into the global fast-lane scope.
void publishAppDimensContext(
  AppDimensContext context,
  AppDimensConfig config,
) {
  final metrics = DimenMetrics.from(
    context.configuration,
    isInMultiWindowMode: config.forcedMultiWindow ?? context.isInMultiWindowMode,
  );
  AppDimensScope.publish(metrics);
  AppDimensScope.publishContext(context);
  AppDimensScope.publishUiModeType(
      config.forcedUiModeType ??
          (context.uiModeType == UiModeType.undefined
              ? UiModeType.normal
              : context.uiModeType));
}

/// EN: In-tree publisher for `MaterialApp.builder` — depends on
/// [MediaQuery], so rotation, split-screen, resize and text-scale changes
/// republish the snapshot with zero timers:
/// ```dart
/// MaterialApp(
///   builder: (context, child) =>
///       AppDimensScopeBinder(child: child ?? const SizedBox.shrink()),
/// )
/// ```
///
/// PT: Publicador em árvore para `MaterialApp.builder` — depende de
/// [MediaQuery]; rotações, split-screen, redimensionamentos e escala de texto
/// republicam o snapshot sem timers.
class AppDimensScopeBinder extends StatelessWidget {
  final AppDimensConfig config;
  final Widget child;

  const AppDimensScopeBinder({
    super.key,
    this.config = const AppDimensConfig(),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);
    publishAppDimensContext(buildAppDimensContext(media, view), config);
    return AppDimensProvider(config: config, child: child);
  }
}

/// EN: InheritedWidget exposing the resolved snapshot to descendants.
///
/// PT: InheritedWidget que expõe o snapshot resolvido aos descendentes.
class AppDimensProvider extends InheritedWidget {
  final AppDimensConfig config;

  const AppDimensProvider({
    super.key,
    this.config = const AppDimensConfig(),
    required super.child,
  });

  /// Nearest snapshot; builds one from the ambient view when no provider is
  /// mounted above [context].
  static AppDimensSnapshot snapshotOf(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<AppDimensProvider>();
    final widget = element?.widget as AppDimensProvider?;
    final media = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);
    final ctx = buildAppDimensContext(media, view);
    final metrics = DimenMetrics.from(
      ctx.configuration,
      isInMultiWindowMode: widget?.config.forcedMultiWindow ?? ctx.isInMultiWindowMode,
    );
    return AppDimensSnapshot(
      metrics: metrics,
      context: ctx,
      uiModeType: widget?.config.forcedUiModeType ??
          (ctx.uiModeType == UiModeType.undefined
              ? UiModeType.normal
              : ctx.uiModeType),
    );
  }

  @override
  bool updateShouldNotify(AppDimensProvider oldWidget) =>
      config != oldWidget.config;
}
