import 'dart:async';

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLayoutState', () {
    test('caps the width and clamps negative insets', () {
      final AppLayoutState wide = AppLayoutState.fromMetrics(rawWidth: 1200, topPadding: -10, bottomPadding: -20);

      expect(wide.width, 512.0);
      expect(wide.topPadding, 0.0);
      expect(wide.bottomPadding, 0.0);
      expect(wide.largeFontSize, closeTo(512 * const AppLayoutConfig().largeFontCoeff, 1e-9));
    });

    test('derives every metric from the capped width', () {
      const AppLayoutConfig config = AppLayoutConfig();
      final AppLayoutState state = AppLayoutState.fromMetrics(rawWidth: 390, topPadding: 24, bottomPadding: 34, config: config);

      expect(state.width, 390.0);
      expect(state.standardPadding, closeTo(390 * config.standardPaddingCoeff, 1e-9));
      expect(state.screenEdgePadding, closeTo(390 * config.screenEdgePaddingCoeff, 1e-9));
      expect(state.cornerRadius, closeTo(390 * config.cornerRadiusCoeff, 1e-9));
      expect(state.tinyFontSize, closeTo(390 * config.tinyFontCoeff, 1e-9));
      expect(state.smallFontSize, closeTo(390 * config.smallFontCoeff, 1e-9));
      expect(state.mediumFontSize, closeTo(390 * config.mediumFontCoeff, 1e-9));
      expect(state.bigFontSize, closeTo(390 * config.bigFontCoeff, 1e-9));
      expect(state.largeFontSize, closeTo(390 * config.largeFontCoeff, 1e-9));
      expect(state.topPadding, 24.0);
      expect(state.bottomPadding, 34.0);
    });

    test('initial state uses the fallback width', () {
      expect(AppLayoutState.initial().width, const AppLayoutConfig().fallbackWidth);
      expect(AppLayoutState.initial().topPadding, 0.0);
      expect(AppLayoutState.initial().bottomPadding, 0.0);
    });

    test('inner corner radius stays inside the outer radius', () {
      final AppLayoutState state = AppLayoutState.fromMetrics(rawWidth: 390);

      expect(state.innerCornerRadius(4), closeTo(state.cornerRadius - 4, 1e-9));
      expect(state.innerCornerRadius(1000), 0.0);
      expect(state.borderRadius.topLeft.x, state.cornerRadius);
    });
  });

  group('AppLayoutCubit', () {
    test('starts from the injected metrics', () {
      final AppLayoutCubit cubit = AppLayoutCubit(
        observeBinding: false,
        metricsReader: () => (width: 400, topPadding: 24, bottomPadding: 34),
      );
      addTearDown(cubit.close);

      expect(cubit.state.width, 400.0);
      expect(cubit.state.topPadding, 24.0);
      expect(cubit.state.bottomPadding, 34.0);
    });

    test('falls back when no metrics are available', () {
      final AppLayoutCubit cubit = AppLayoutCubit(observeBinding: false, metricsReader: () => null);
      addTearDown(cubit.close);

      expect(cubit.state.width, const AppLayoutConfig().fallbackWidth);
    });

    test('ignores invalid widths', () {
      final AppLayoutCubit cubit = AppLayoutCubit(observeBinding: false, metricsReader: () => null);
      addTearDown(cubit.close);
      final double initialWidth = cubit.state.width;

      cubit.updateMetrics(rawWidth: 0);
      cubit.updateMetrics(rawWidth: -10);
      cubit.updateMetrics(rawWidth: double.nan);

      expect(cubit.state.width, initialWidth);
    });

    test('does not emit for equivalent metrics above the width cap', () async {
      final AppLayoutCubit cubit = AppLayoutCubit(observeBinding: false, metricsReader: () => (width: 800, topPadding: 0, bottomPadding: 0));
      addTearDown(cubit.close);

      // The first emit always happens: the initial state was never streamed.
      cubit.updateMetrics(rawWidth: 800);
      await pumpEventQueue();

      final List<AppLayoutState> states = <AppLayoutState>[];
      final StreamSubscription<AppLayoutState> subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      cubit.updateMetrics(rawWidth: 800);
      cubit.updateMetrics(rawWidth: 1200);
      cubit.updateMetrics(rawWidth: 2000);
      await pumpEventQueue();

      expect(states, isEmpty);

      cubit.updateMetrics(rawWidth: 400);
      await pumpEventQueue();

      expect(states.length, 1);
      expect(states.single.width, 400.0);
    });

    test('syncFromPlatform updates the state when metrics change', () {
      double width = 400;
      double bottomPadding = 0;
      final AppLayoutCubit cubit = AppLayoutCubit(
        observeBinding: false,
        metricsReader: () => (width: width, topPadding: 24, bottomPadding: bottomPadding),
      );
      addTearDown(cubit.close);

      expect(cubit.state.width, 400.0);
      expect(cubit.state.bottomPadding, 0.0);

      width = 1024;
      bottomPadding = 34;
      cubit.syncFromPlatform();

      expect(cubit.state.width, 512.0);
      expect(cubit.state.bottomPadding, 34.0);
    });

    test('stops updating after close', () {
      double width = 400;
      final AppLayoutCubit cubit = AppLayoutCubit(
        observeBinding: false,
        metricsReader: () => (width: width, topPadding: 0, bottomPadding: 0),
      );

      cubit.close();
      width = 300;
      cubit.syncFromPlatform();

      expect(cubit.state.width, 400.0);
    });
  });

  group('AppLayoutCubit platform binding', () {
    testWidgets('follows browser resize, rotation and safe area changes', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);

      final AppLayoutCubit cubit = AppLayoutCubit();
      addTearDown(() async {
        if (!cubit.isClosed) await cubit.close();
      });

      expect(cubit.state.width, 400.0);
      expect(cubit.state.topPadding, 24.0);
      expect(cubit.state.bottomPadding, 34.0);

      tester.view.physicalSize = const Size(1200, 800);
      tester.view.viewPadding = const FakeViewPadding(top: 0, bottom: 20);
      await tester.pump();

      expect(cubit.state.width, 512.0);
      expect(cubit.state.topPadding, 0.0);
      expect(cubit.state.bottomPadding, 20.0);

      await cubit.close();

      tester.view.physicalSize = const Size(300, 500);
      await tester.pump();

      expect(cubit.state.width, 512.0);

      tester.view.resetPhysicalSize();
      tester.view.resetViewPadding();
      tester.view.resetDevicePixelRatio();
    });
  });
}
