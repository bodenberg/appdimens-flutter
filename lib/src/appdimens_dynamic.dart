import 'appdimens_builder.dart';
import 'appdimens_scale.dart';

/// Proportional AppDimens Dynamic compatibility facade.
class AppDimensDynamic extends AppDimensBuilder<AppDimensDynamic> {
  AppDimensDynamic(double value, {bool ignoreMultiWindowAdjustment = false})
    : super(
        value,
        AppDimensStrategy.defaultScaling,
        ignoreMultiWindowAdjustment: ignoreMultiWindowAdjustment,
      );
}
