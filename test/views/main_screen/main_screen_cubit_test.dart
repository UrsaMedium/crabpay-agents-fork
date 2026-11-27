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

  ({AuthBloc authBloc, CartBloc cartBloc, MainScreenCubit cubit}) buildParts() {
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
    return (authBloc: authBloc, cartBloc: cartBloc, cubit: cubit);
  }

  group('MainScreenCubit', () {
    test('onPageSwipe and setSyncByNavBarState', () async {
      final parts = buildParts();

      parts.cubit.onPageSwipe(1);
      expect(parts.cubit.state.page, 1);

      parts.cubit.setSyncByNavBarState(true);
      expect(parts.cubit.state.isSyncingByNavBarTap, true);
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
