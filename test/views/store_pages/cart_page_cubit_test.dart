import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
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

  CartPageCubit buildCubit(CartBloc cartBloc, AppLifecycleService lifecycle) {
    final cubit = CartPageCubit(cartBloc: cartBloc, products: [makeProduct()], appLifecycleService: lifecycle);
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
}
