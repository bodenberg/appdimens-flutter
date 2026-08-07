import 'package:flutter/widgets.dart';
import 'configuration.dart';

@immutable
class AppDimensConfig {
  const AppDimensConfig({
    this.uiMode = UiModeType.undefined,
    this.maximumWindowSize,
  });
  final UiModeType uiMode;
  final Size? maximumWindowSize;
}

class AppDimensProvider extends InheritedWidget {
  const AppDimensProvider({
    required super.child,
    this.config = const AppDimensConfig(),
    super.key,
  });
  final AppDimensConfig config;
  static AppDimensProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDimensProvider>();
  static AppDimensProvider of(BuildContext context) {
    final value = maybeOf(context);
    if (value == null) throw FlutterError('No AppDimensProvider found.');
    return value;
  }

  @override
  bool updateShouldNotify(AppDimensProvider oldWidget) =>
      config != oldWidget.config;
}

extension AppDimensContext on BuildContext {
  DimensConfiguration get dimensConfiguration {
    final provider = AppDimensProvider.maybeOf(this);
    return DimensConfiguration.fromMediaQuery(
      MediaQuery.of(this),
      uiMode: provider?.config.uiMode ?? UiModeType.undefined,
      maximumWindowSize: provider?.config.maximumWindowSize,
    );
  }
}

class AppDimensBuilder extends StatelessWidget {
  const AppDimensBuilder({required this.builder, super.key});
  final Widget Function(BuildContext, DimensConfiguration) builder;
  @override
  Widget build(BuildContext context) =>
      builder(context, context.dimensConfiguration);
}
