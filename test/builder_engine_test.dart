import 'package:appdimens/appdimens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const phone = AppDimensViewport(width: 360, height: 800);
  const tablet = AppDimensViewport(width: 800, height: 1280);

  test(
    'dynamic uses proportional scaling and fixed uses logarithmic scaling',
    () {
      final dynamic = AppDimensDynamic(16).calculateViewport(phone);
      final fixed = AppDimensFixed(16).calculateViewport(phone);
      expect(dynamic, 16);
      expect(fixed, 16);
      expect(
        AppDimensDynamic(16).calculateViewport(tablet),
        greaterThan(dynamic),
      );
      expect(AppDimensFixed(16).calculateViewport(tablet), greaterThan(fixed));
    },
  );

  test('override precedence is deterministic', () {
    final value = AppDimensDynamic(10)
        .deviceType(DeviceType.tablet, 20)
        .uiMode(UiModeType.tv, 30)
        .screenWithIntersection(
          UiModeType.tv,
          DpQualifier.smallestWidth600,
          600,
          40,
        )
        .calculateViewport(
          tablet,
          deviceType: DeviceType.tablet,
          uiModeType: UiModeType.tv,
        );
    expect(value, 40);
  });

  test('largest matching device size override wins', () {
    final builder = AppDimensDynamic(10)
        .screenWithSize(DeviceType.tablet, 600, 20)
        .screenWithSize(DeviceType.tablet, 720, 30);
    expect(
      builder.calculateViewport(tablet, deviceType: DeviceType.tablet),
      30,
    );
  });

  test('viewport helpers have exact geometry', () {
    const viewport = AppDimensViewport(width: 3, height: 4);
    expect(viewport.diagonal, 5);
    expect(viewport.perimeter, 14);
    expect(viewport.shortestSide, 3);
    expect(viewport.longestSide, 4);
  });
}
