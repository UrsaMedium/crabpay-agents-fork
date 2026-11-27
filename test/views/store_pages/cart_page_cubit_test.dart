import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/_sub/orders_on_payment_sheet/driver/orders_on_payment_sheet_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/driver/cart_page_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({CartBloc cartBloc, MockInnerCartHandler cartHandler}) createCartBloc({required List<CartItem> fetchResult}) {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final cartHandler = MockInnerCartHandler();
    when(() => cartHandler.fetchCartItemsToBuy(any())).thenAnswer((_) async => fetchResult);
    final lifecycle = FakeAppLifecycleService();
    addTearDown(lifecycle.dispose);
    final cartBloc = CartBloc(
      cartHandler: cartHandler,
      authInterface: authInterface,
      appLifecycleService: lifecycle,
    );
    addTearDown(cartBloc.close);
    return (cartBloc: cartBloc, cartHandler: cartHandler);
  }

  AppLayoutCubit buildLayoutCubit() {
    return AppLayoutCubit(
      observeBinding: false,
      metricsReader: () => (width: 800, topPadding: 0, bottomPadding: 0),
    );
  }

  CartPageCubit buildCubit(CartBloc cartBloc, AppLifecycleService lifecycle, {AppLayoutCubit? layoutCubit}) {
    final layout = layoutCubit ?? buildLayoutCubit();
    if (layoutCubit == null) addTearDown(layout.close);
    final cubit = CartPageCubit(
      cartBloc: cartBloc,
      products: [makeProduct()],
      appLifecycleService: lifecycle,
      layoutCubit: layout,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  group('CartPageCubit total price', () {
    test('sums checkoutPrice across multiple items', () async {
      final items = [
        makeCartItem(id: 'item-1', checkoutPrice: 10),
        makeCartItem(id: 'item-2', checkoutPrice: 25.5),
      ];
      final cart = createCartBloc(fetchResult: items);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);

      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();

      expect(cubit.state.cartItemsTuBuy, hasLength(2));
      expect(cubit.state.totalPrice, closeTo(35.5, 1e-9));
    });

    test('is zero when the cart is empty', () async {
      final cart = createCartBloc(fetchResult: []);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);

      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();

      expect(cubit.state.cartItemsTuBuy, isEmpty);
      expect(cubit.state.totalPrice, 0);
    });
  });

  group('CartPageCubit actions', () {
    test('setDeletingItem stores the item', () async {
      final cart = createCartBloc(fetchResult: [makeCartItem()]);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);

      final item = makeCartItem(id: 'to-delete');
      cubit.setDeletingItem(item);
      expect(cubit.state.itemToDelete, item);
    });

    test('flushCartItems empties the items to buy', () async {
      final cart = createCartBloc(fetchResult: [makeCartItem()]);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);

      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();
      expect(cubit.state.cartItemsTuBuy, isNotEmpty);

      cubit.flushCartItems();
      expect(cubit.state.cartItemsTuBuy, isEmpty);
    });
  });

  group('CartPageCubit app lifecycle reaction', () {
    test('ignores cart changes while paused and resyncs on active', () async {
      final items = [makeCartItem(id: 'item-1', checkoutPrice: 12), makeCartItem(id: 'item-2', checkoutPrice: 5)];
      final cart = createCartBloc(fetchResult: items);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);

      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();
      expect(cubit.state.totalPrice, closeTo(17, 1e-9));

      lifecycle.emit(AppState.paused);

      // The cart changes while the cubit's subscription is paused.
      when(() => cart.cartHandler.fetchCartItemsToBuy(any())).thenAnswer(
        (_) async => [
          makeCartItem(id: 'item-3', checkoutPrice: 100),
        ],
      );
      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();

      expect(cubit.state.totalPrice, closeTo(17, 1e-9));
      expect(cubit.state.cartItemsTuBuy, hasLength(2));

      lifecycle.emit(AppState.active);
      await pumpEventQueue();

      expect(cubit.state.cartItemsTuBuy, hasLength(1));
      expect(cubit.state.totalPrice, closeTo(100, 1e-9));
    });
  });

  group('CartPageCubit layout', () {
    test('derives layout metrics from AppLayoutCubit and syncs on changes', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final cart = createCartBloc(fetchResult: []);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(cart.cartBloc, lifecycle, layoutCubit: layoutCubit);

      expect(cubit.state.layout.pageWidth, closeTo(512, 1e-9));
      expect(
        cubit.state.layout.outerWidth,
        closeTo(512 - 512 * config.screenEdgePaddingCoeff * 2, 1e-9),
      );
      expect(cubit.state.layout.padding, closeTo(512 * config.standardPaddingCoeff, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      expect(cubit.state.layout.pageWidth, closeTo(360, 1e-9));
      expect(cubit.state.layout.topPadding, closeTo(layoutCubit.state.pageTopPadding, 1e-9));
      expect(cubit.state.layout.bottomPadding, closeTo(layoutCubit.state.pageBottomPadding, 1e-9));
      expect(
        cubit.state.layout.listBottomPaddingWithPending,
        greaterThan(cubit.state.layout.listBottomPaddingWithoutPending),
      );
      expect(
        cubit.state.layout.listBottomPaddingWithoutPending,
        greaterThan(cubit.state.layout.bottomPadding),
      );
      expect(
        cubit.state.layout.buyPanelBottomOffset,
        closeTo(cubit.state.layout.bottomPadding + cubit.state.layout.padding, 1e-9),
      );
    });

    test('clamps the page width to the configured minimum', () async {
      final cart = createCartBloc(fetchResult: []);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(cart.cartBloc, lifecycle, layoutCubit: layoutCubit);

      layoutCubit.updateMetrics(rawWidth: 80);
      await pumpEventQueue();

      expect(cubit.state.layout.pageWidth, closeTo(320, 1e-9));
    });

    test('close cancels layout updates', () async {
      final cart = createCartBloc(fetchResult: []);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = buildCubit(cart.cartBloc, lifecycle, layoutCubit: layoutCubit);
      final emitted = <CartPageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.close();
      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(emitted, isEmpty);
    });
  });

  group('CartPageCubit.close', () {
    test('cancels subscriptions: no state is emitted from CartBloc afterwards', () async {
      final cart = createCartBloc(fetchResult: []);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      final cubit = buildCubit(cart.cartBloc, lifecycle);
      final emitted = <CartPageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(cubit.isClosed, false);
      await cubit.close();
      expect(cubit.isClosed, true);

      when(() => cart.cartHandler.fetchCartItemsToBuy(any())).thenAnswer(
        (_) async => [
          makeCartItem(id: 'item-after-close', checkoutPrice: 100),
        ],
      );
      cart.cartBloc.add(CartEventFetchCartItems(userId: 'user-1'));
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(cubit.state.totalPrice, isNull);
    });
  });

  group('OrdersOnPaymentSheetCubit', () {
    test('derives the sheet layout and syncs on layout changes', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = OrdersOnPaymentSheetCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      expect(cubit.state.layout.sheetWidth, closeTo(512, 1e-9));
      expect(
        cubit.state.layout.dialogWidth,
        closeTo(512 - 512 * config.screenEdgePaddingCoeff * 2, 1e-9),
      );
      expect(cubit.state.layout.headerCornerRadius, closeTo(cubit.state.layout.headerHeight / 2, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      expect(cubit.state.layout.sheetWidth, closeTo(360, 1e-9));
      expect(cubit.state.layout.sheetBottomPadding, greaterThan(0));
      expect(cubit.state.layout.dialogMaxHeight, inInclusiveRange(320.0, 440.0));
    });

    test('close cancels layout updates', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = OrdersOnPaymentSheetCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      final emitted = <OrdersOnPaymentSheetState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.close();
      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(emitted, isEmpty);
    });
  });
}
