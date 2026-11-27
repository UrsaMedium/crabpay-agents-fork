import 'dart:math' as math;

import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/driver/main_screen_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({AuthBloc authBloc, CartBloc cartBloc, MainScreenCubit cubit, AppLayoutCubit layoutCubit}) buildParts() {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final authBloc = AuthBloc(authInterface);
    final cartHandler = MockInnerCartHandler();
    when(() => cartHandler.fetchPendingCartItems(any())).thenAnswer((_) async => [makeCartItem()]);
    final lifecycle = FakeAppLifecycleService();
    addTearDown(lifecycle.dispose);
    final cartBloc = CartBloc(
      cartHandler: cartHandler,
      authInterface: authInterface,
      appLifecycleService: lifecycle,
    );
    final layoutCubit = AppLayoutCubit(
      observeBinding: false,
      metricsReader: () => (width: 800, topPadding: 0, bottomPadding: 0),
    );
    final cubit = MainScreenCubit(
      authBloc: authBloc,
      cartBloc: cartBloc,
      globalKey: GlobalKey(),
      layoutCubit: layoutCubit,
    );
    addTearDown(authBloc.close);
    addTearDown(cartBloc.close);
    addTearDown(layoutCubit.close);
    addTearDown(cubit.close);
    return (authBloc: authBloc, cartBloc: cartBloc, cubit: cubit, layoutCubit: layoutCubit);
  }

  group('MainScreenCubit', () {
    test('onPageSwipe and setSyncByNavBarState', () async {
      final parts = buildParts();

      parts.cubit.onPageSwipe(1);
      expect(parts.cubit.state.page, 1);

      parts.cubit.setSyncByNavBarState(true);
      expect(parts.cubit.state.isSyncingByNavBarTap, true);
    });

    test('derives scaled bar sizes and paddings from the app layout', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final parts = buildParts();
      final initial = parts.cubit.state.layout;

      expect(initial.appBarHeight, closeTo(512 * config.appBarHeightCoeff, 1e-9));
      expect(initial.appBarPadding.top, closeTo(512 * config.appBarTopPaddingCoeff, 1e-9));
      expect(initial.appBarCornerRadius, closeTo(initial.appBarHeight / 2, 1e-9));
      expect(initial.appBarPreferredHeight, greaterThanOrEqualTo(initial.appBarHeight));
      expect(initial.navBarHeight, closeTo(512 * config.navBarHeightCoeff, 1e-9));
      expect(initial.navBarBottomMargin, closeTo(512 * config.navBarBottomPaddingCoeff, 1e-9));

      parts.layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      final updated = parts.cubit.state.layout;
      expect(updated.topPadding, 24.0);
      expect(updated.appBarHeight, closeTo(360 * config.appBarHeightCoeff, 1e-9));
      expect(updated.appBarPadding.top, closeTo(24 + 360 * config.appBarTopPaddingCoeff, 1e-9));
      expect(updated.appBarPreferredHeight, closeTo(updated.appBarPadding.top + updated.appBarHeight - 24, 1e-9));
      expect(updated.navBarHeight, closeTo(360 * config.navBarHeightCoeff, 1e-9));
      expect(updated.navBarBottomMargin, closeTo(34 + 360 * config.navBarBottomPaddingCoeff, 1e-9));
      expect(updated.navBarScrimHeight, closeTo(updated.navBarBottomMargin + updated.navBarHeight * 0.85, 1e-9));
      expect(updated.navBarWidth, closeTo(math.min(updated.navBarHeight * 5.5, updated.contentWidth), 1e-9));
    });

    test('reacts to AuthBloc emissions', () async {
      final parts = buildParts();

      parts.authBloc.add(AuthEventOnStreamUserChanged(makeAuthUser(isAdmin: true)));
      await pumpEventQueue();

      expect(parts.cubit.state.isLoggedIn, true);
      expect(parts.cubit.state.currentUser!.id, 'user-1');
      expect(parts.cubit.state.isAdmin, true);
    });

    test('reacts to CartBloc emissions', () async {
      final parts = buildParts();

      parts.cartBloc.add(CartEventUpdateUserCartItemAmountFromStream(amount: 3));
      await pumpEventQueue();
      expect(parts.cubit.state.userCartItemAmount, 3);

      parts.cartBloc.add(CartEventUpdatePendingOrders(pendingOrders: [makePendingOrder(), makePendingOrder()]));
      await pumpEventQueue();
      expect(parts.cubit.state.amountOfPendingOrders, 2);
    });

    test('close cancels subscriptions: no state is emitted from AuthBloc/CartBloc afterwards', () async {
      final parts = buildParts();
      final emitted = <MainScreenState>[];
      final subscription = parts.cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(parts.cubit.isClosed, false);
      await parts.cubit.close();
      expect(parts.cubit.isClosed, true);

      parts.authBloc.add(AuthEventOnStreamUserChanged(makeAuthUser(isAdmin: true)));
      parts.cartBloc.add(CartEventUpdateUserCartItemAmountFromStream(amount: 7));
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(parts.cubit.state.isLoggedIn, isFalse);
      expect(parts.cubit.state.userCartItemAmount, 0);
    });
  });
}
