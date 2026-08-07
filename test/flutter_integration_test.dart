import 'package:appdimens/appdimens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('provider exposes one window configuration', (tester) async {
    late DimensConfiguration c;
    await tester.pumpWidget(
      AppDimensProvider(
        config: const AppDimensConfig(
          uiMode: UiModeType.television,
          maximumWindowSize: Size(1920, 1080),
        ),
        child: MediaQuery(
          data: const MediaQueryData(size: Size(960, 540), devicePixelRatio: 2),
          child: Builder(
            builder: (context) {
              c = context.dimensConfiguration;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(c.uiMode, UiModeType.television);
    expect(c.isMultiWindow, isTrue);
    expect(c.displayScale, 2);
  });
}
