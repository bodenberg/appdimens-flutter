import 'package:flutter/widgets.dart';

import 'appdimens_types.dart';

@immutable
class AppDimensConfig {
  const AppDimensConfig({
    this.aspectRatioEnabled = true,
    this.cacheEnabled = true,
    this.ignoreMultiWindowAdjustment = false,
    this.forcedDeviceType,
    this.forcedUiModeType,
  });

  final bool aspectRatioEnabled;
  final bool cacheEnabled;
  final bool ignoreMultiWindowAdjustment;
  final DeviceType? forcedDeviceType;
  final UiModeType? forcedUiModeType;

  AppDimensConfig copyWith({
    bool? aspectRatioEnabled,
    bool? cacheEnabled,
    bool? ignoreMultiWindowAdjustment,
    DeviceType? forcedDeviceType,
    UiModeType? forcedUiModeType,
  }) =>
      AppDimensConfig(
        aspectRatioEnabled: aspectRatioEnabled ?? this.aspectRatioEnabled,
        cacheEnabled: cacheEnabled ?? this.cacheEnabled,
        ignoreMultiWindowAdjustment: ignoreMultiWindowAdjustment ??
            this.ignoreMultiWindowAdjustment,
        forcedDeviceType: forcedDeviceType ?? this.forcedDeviceType,
        forcedUiModeType: forcedUiModeType ?? this.forcedUiModeType,
      );

  @override
  bool operator ==(Object other) =>
      other is AppDimensConfig &&
      other.aspectRatioEnabled == aspectRatioEnabled &&
      other.cacheEnabled == cacheEnabled &&
      other.ignoreMultiWindowAdjustment == ignoreMultiWindowAdjustment &&
      other.forcedDeviceType == forcedDeviceType &&
      other.forcedUiModeType == forcedUiModeType;

  @override
  int get hashCode => Object.hash(aspectRatioEnabled, cacheEnabled,
      ignoreMultiWindowAdjustment, forcedDeviceType, forcedUiModeType);
}

class AppDimensProvider extends InheritedWidget {
  const AppDimensProvider({
    required this.config,
    required super.child,
    super.key,
  });

  final AppDimensConfig config;

  static AppDimensProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDimensProvider>();
  static AppDimensProvider? of(BuildContext context) => maybeOf(context);

  static AppDimensProvider require(BuildContext context) {
    final provider = maybeOf(context);
    if (provider == null) {
      throw FlutterError('No AppDimensProvider found above this context.');
    }
    return provider;
  }

  @override
  bool updateShouldNotify(AppDimensProvider oldWidget) =>
      config != oldWidget.config;
}

class AppDimensApp extends StatelessWidget {
  const AppDimensApp({
    required this.child,
    this.config = const AppDimensConfig(),
    super.key,
  });
  final AppDimensConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AppDimensProvider(config: config, child: child);
}

typedef AppDimensWidgetBuilder = Widget Function(
    BuildContext context, AppDimensConfig config);

class AppDimensConsumer extends StatelessWidget {
  const AppDimensConsumer({required this.builder, super.key});
  final AppDimensWidgetBuilder builder;
  @override
  Widget build(BuildContext context) => builder(context, context.appDimensConfig);
}

class AppDimensHook extends AppDimensConsumer {
  const AppDimensHook({required super.builder, super.key});
}

class AppDimensScope extends AppDimensApp {
  const AppDimensScope({
    required super.config,
    required super.child,
    super.key,
  });
}

mixin AppDimensMixin<T extends StatefulWidget> on State<T> {
  AppDimensConfig get appDimensConfig => context.appDimensConfig;
  bool get isAspectRatioEnabled => appDimensConfig.aspectRatioEnabled;
  bool get isCacheEnabled => appDimensConfig.cacheEnabled;
  bool get isMultiWindowAdjustmentIgnored =>
      appDimensConfig.ignoreMultiWindowAdjustment;
  DeviceType? get forcedDeviceType => appDimensConfig.forcedDeviceType;
  UiModeType? get forcedUiModeType => appDimensConfig.forcedUiModeType;
}

extension AppDimensBuildContextExtension on BuildContext {
  AppDimensConfig get appDimensConfig =>
      AppDimensProvider.maybeOf(this)?.config ?? const AppDimensConfig();
  AppDimensProvider? get appDimensProvider => AppDimensProvider.maybeOf(this);
}
