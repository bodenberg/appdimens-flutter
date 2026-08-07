import 'appdimens_builder.dart';
import 'appdimens_scale.dart';

/// Conservative AppDimens Fixed compatibility facade.
class AppDimensFixed extends AppDimensBuilder<AppDimensFixed> {
  AppDimensFixed(double value, {bool ignoreMultiWindowAdjustment = false})
      : super(value, AppDimensStrategy.logarithmic,
            ignoreMultiWindowAdjustment: ignoreMultiWindowAdjustment);
}
