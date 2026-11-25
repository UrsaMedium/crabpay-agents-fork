import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/common/paginated_result_data_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_state.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('CartBloc', () {
    late StreamController<AppAuthUser> userController;
    late MockInnerCartHandler cartHandler;
    late MockAuthInnerInterface authInterface;
    late FakeAppLifecycleService appLifecycleService;

    CartBloc buildBloc() {
      final bloc = CartBloc(cartHandler: cartHandler, authInterface: authInterface, appLifecycleService: appLifecycleService);
      addTearDown(bloc.close);
      addTearDown(appLifecycleService.dispose);
      return bloc;
    }

    test('CartState.copyWith turns empty lists and maps into null', () {
      final state = CartState();
      expect(state.copyWith(cartItemsToBuy: []).cartItemsToBuy, isNull);
      expect(state.copyWith(cartItemsToBuy: [makeCartItem()]).cartItemsToBuy, isNotNull);
      expect(state.copyWith(productCartItemAmount: -1).productCartItemAmount, isNull);
      expect(state.copyWith(productCartItemAmount: 5).productCartItemAmount, 5);
      expect(state.copyWith(userCartItemAmount: -1).userCartItemAmount, isNull);
      expect(state.copyWith(userCartItemAmount: 7).userCartItemAmount, 7);
      expect(
        state.copyWith(notDeliveredOrders: PaginatedResult(objects: [], hasMore: false)).notDeliveredOrders,
        isNull,
      );
      expect(
        state.copyWith(notDeliveredOrders: PaginatedResult(objects: ['o-1'], hasMore: false)).notDeliveredOrders?.objects,
        ['o-1'],
      );

      final populated = CartState(
        deliveredOrders: PaginatedResult(objects: ['d-1'], hasMore: false),
        searchedOrders: PaginatedResult(objects: ['s-1'], hasMore: true),
        pendingOrders: [makePendingOrder()],
        itemsOfNotDeliveredOrders: {
          'n-1': [makeCartItem()],
        },
        itemsOfDeliveredOrders: {
          'd-1': [makeCartItem()],
        },
        itemsOfSearchedOrders: {
          's-1': [makeCartItem()],
        },
      );
      expect(
        populated.copyWith(deliveredOrders: PaginatedResult(objects: [], hasMore: false)).deliveredOrders,
        isNull,
      );
      expect(
        populated.copyWith(searchedOrders: PaginatedResult(objects: [], hasMore: false)).searchedOrders,
        isNull,
      );
      expect(populated.copyWith(pendingOrders: []).pendingOrders, isNull);
      expect(populated.copyWith(itemsOfNotDeliveredOrders: {}).itemsOfNotDeliveredOrders, isNull);
      expect(populated.copyWith(itemsOfDeliveredOrders: {}).itemsOfDeliveredOrders, isNull);
      expect(populated.copyWith(itemsOfSearchedOrders: {}).itemsOfSearchedOrders, isNull);
      expect(
        populated.copyWith(deliveredOrders: PaginatedResult(objects: ['d-2'], hasMore: false)).deliveredOrders?.objects,
        ['d-2'],
      );
      expect(populated.copyWith(pendingOrders: [makePendingOrder()]).pendingOrders, hasLength(1));
      expect(
        populated
            .copyWith(
              itemsOfDeliveredOrders: {
                'd-2': [makeCartItem()],
              },
            )
            .itemsOfDeliveredOrders
            ?.keys,
        contains('d-2'),
      );
    });

    blocTest(
      'FetchCartItems fetches the cart items to buy',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchCartItemsToBuy('user-1')).thenAnswer((_) async => [makeCartItem(id: 'item-1')]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventFetchCartItems(userId: 'user-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.got),
      ],
      verify: (bloc) {
        verify(() => cartHandler.fetchCartItemsToBuy('user-1')).called(1);
      },
    );

    blocTest(
      'AddCartItem adds a cart item and reports the product amount',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.addCartItem(any())).thenAnswer((_) async {});
        when(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).thenAnswer((_) async => 3);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        CartEventAddCartItem(
          userId: 'user-1',
          cartItem: makeCartItem(id: 'item-1', productId: 'product-1'),
        ),
      ),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.added).having((s) => s.productCartItemAmount, 'productCartItemAmount', 3),
      ],
      verify: (bloc) {
        verify(() => cartHandler.addCartItem(any())).called(1);
        verify(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).called(1);
      },
    );

    blocTest(
      'DeleteCartItem removes the item from the cart items to buy',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.deleteCartItem('item-1')).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => CartState(
        cartItemsToBuy: [
          makeCartItem(id: 'item-1'),
          makeCartItem(id: 'item-2'),
        ],
        states: CartStates.got,
      ),
      act: (bloc) => bloc.add(
        CartEventDeleteCartItem(
          userId: 'user-1',
          cartItem: makeCartItem(id: 'item-1'),
        ),
      ),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.deleted),
      ],
      verify: (bloc) {
        verify(() => cartHandler.deleteCartItem('item-1')).called(1);
      },
    );

    blocTest(
      'FetchProductCartItemAmount fetches the amount of a product in the cart',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).thenAnswer((_) async => 42);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventFetchProductCartItemAmount(userId: 'user-1', productId: 'product-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.fetchedProductCartItemCount).having((s) => s.productCartItemAmount, 'productCartItemAmount', 42),
      ],
      verify: (bloc) {
        verify(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).called(1);
      },
    );

    blocTest(
      'DeleteLastAddedProductCartItem deletes the last added product cart item',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.deleteLastAddedProductCartItem('user-1', 'product-1')).thenAnswer((_) async => true);
        when(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).thenAnswer((_) async => 0);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventDeleteLastAddedProductCartItem(userId: 'user-1', productId: 'product-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.deletedLastAddedProductCartItem),
      ],
      verify: (bloc) {
        verify(() => cartHandler.deleteLastAddedProductCartItem('user-1', 'product-1')).called(1);
      },
    );

    blocTest(
      'StartStreamUserCartItemAmount streams the user cart item amount',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.streamUserCartItemAmount('user-1')).thenAnswer((_) => Stream.value(6));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventStartStreamUserCartItemAmount(userId: 'user-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.updatedUserCartItemCount).having((s) => s.userCartItemAmount, 'userCartItemAmount', 6),
      ],
      verify: (bloc) {
        verify(() => cartHandler.streamUserCartItemAmount('user-1')).called(1);
      },
    );

    blocTest(
      'StartStreamPendingOrders streams the pending orders',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchCartItemsToBuy('user-1')).thenAnswer((_) async => <CartItem>[]);
        when(() => cartHandler.fetchPendingCartItems('payment-1')).thenAnswer((_) async => [makeCartItem(checkoutPrice: 100)]);
        when(() => cartHandler.streamPendingOrders('user-1')).thenAnswer((_) => Stream.value([makePendingOrder(paymentId: 'payment-1', userId: 'user-1', paymentLink: 'https://example.com/pay')]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventStartStreamPendingOrders(userId: 'user-1')),
      expect: () => [
        isA<CartState>().having((s) => s.pendingOrdersState, 'pendingOrdersState', PendingOrdersState.updated),
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.got),
      ],
      verify: (bloc) {
        verify(() => cartHandler.streamPendingOrders('user-1')).called(1);
        verify(() => cartHandler.fetchPendingCartItems('payment-1')).called(1);
        verify(() => cartHandler.fetchCartItemsToBuy('user-1')).called(1);
      },
    );

    blocTest(
      'Auth stream user change flushes the cart and restarts the streams',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        when(() => cartHandler.streamUserCartItemAmount('user-2')).thenAnswer((_) => Stream.value(5));
        when(() => cartHandler.streamPendingOrders('user-2')).thenAnswer((_) => Stream.value(<PendingOrder>[]));
        when(() => cartHandler.fetchCartItemsToBuy('user-2')).thenAnswer((_) async => <CartItem>[]);
        return buildBloc();
      },
      act: (bloc) async {
        userController.add(makeAuthUser(id: 'user-2'));
        await pumpEventQueue();
      },
      verify: (bloc) {
        verify(() => cartHandler.streamUserCartItemAmount('user-2')).called(1);
        verify(() => cartHandler.streamPendingOrders('user-2')).called(1);
        verify(() => cartHandler.fetchCartItemsToBuy('user-2')).called(2);
        final CartState state = bloc.state;
        expect(state.userCartItemAmount, 5);
        expect(state.isCartStreaming, IsCartStreamingUserCarItemAmount.yes);
      },
    );

    blocTest(
      'App lifecycle active state refetches the cart items of the active user',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.streamUserCartItemAmount('user-1')).thenAnswer((_) => Stream.value(5));
        when(() => cartHandler.fetchCartItemsToBuy('user-1')).thenAnswer((_) async => <CartItem>[]);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(CartEventStartStreamUserCartItemAmount(userId: 'user-1'));
        await pumpEventQueue();
        appLifecycleService.emit(AppState.active);
        await pumpEventQueue();
      },
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.updatedUserCartItemCount),
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.got),
      ],
      verify: (bloc) {
        verify(() => cartHandler.fetchCartItemsToBuy('user-1')).called(1);
      },
    );

    blocTest(
      'FetchNotDeliveredOrders pages through the orders',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchNotDeliveredOrdersIds('user-1', pageToken: 'token-1')).thenAnswer(
          (_) async => PaginatedResult<String>(objects: ['order-1'], hasMore: true, nextPageToken: 'token-2'),
        );
        when(() => cartHandler.fetchItemsOfOrder('user-1', 'order-1')).thenAnswer((_) async => [makeCartItem()]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventFetchNotDeliveredOrders(userId: 'user-1', pageToken: 'token-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.loadedMoreOrdersNotDeliveredOrders),
      ],
      verify: (bloc) {
        verify(() => cartHandler.fetchNotDeliveredOrdersIds('user-1', pageToken: 'token-1')).called(1);
        verify(() => cartHandler.fetchItemsOfOrder('user-1', 'order-1')).called(1);
      },
    );

    blocTest(
      'FetchDeliveredOrders pages through the delivered orders',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchDeliveredOrdersIds('user-1', pageToken: 'token-1')).thenAnswer(
          (_) async => PaginatedResult<String>(objects: ['order-2'], hasMore: false),
        );
        when(() => cartHandler.fetchItemsOfOrder('user-1', 'order-2')).thenAnswer((_) async => [makeCartItem()]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CartEventFetchDeliveredOrders(userId: 'user-1', pageToken: 'token-1')),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.loadedMoreOrdersDeliveredOrders),
      ],
      verify: (bloc) {
        verify(() => cartHandler.fetchDeliveredOrdersIds('user-1', pageToken: 'token-1')).called(1);
        verify(() => cartHandler.fetchItemsOfOrder('user-1', 'order-2')).called(1);
      },
    );

    blocTest(
      'FetchSearchedOrders pages through the searched orders',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchSearchedOrdersIds(userId: 'user-1', pageToken: 'token-1', fromDate: testDate, toDate: testDate, orderId: 'order-3')).thenAnswer(
          (_) async => PaginatedResult<String>(objects: ['order-3'], hasMore: true, nextPageToken: 'token-4'),
        );
        when(() => cartHandler.fetchItemsOfOrder('user-1', 'order-3')).thenAnswer((_) async => [makeCartItem()]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        CartEventFetchSearchedOrders(
          userId: 'user-1',
          pageToken: 'token-1',
          fromDate: testDate,
          toDate: testDate,
          orderId: 'order-3',
        ),
      ),
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.searchedOrders),
      ],
      verify: (bloc) {
        verify(() => cartHandler.fetchSearchedOrdersIds(userId: 'user-1', pageToken: 'token-1', fromDate: testDate, toDate: testDate, orderId: 'order-3')).called(1);
        verify(() => cartHandler.fetchItemsOfOrder('user-1', 'order-3')).called(1);
      },
    );

    blocTest(
      'FetchCartItems only rethrows when fetchCartItemsToBuy throws',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.fetchCartItemsToBuy('user-1')).thenThrow(Exception('fetch failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(CartEventFetchCartItems(userId: 'user-1'));
        await pumpEventQueue();
      },
      // Documents current bug: the failedToGet state is created with
      // state.copyWith but never emitted, so the only observable failure is
      // the rethrown exception.
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
      ],
      errors: () => contains(isA<Exception>()),
    );

    blocTest(
      'AddCartItem emits failedToAdd and rethrows when addCartItem throws',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.addCartItem(any())).thenThrow(Exception('add failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          CartEventAddCartItem(
            userId: 'user-1',
            cartItem: makeCartItem(id: 'item-1', productId: 'product-1'),
          ),
        );
        await pumpEventQueue();
      },
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.failedToAdd),
      ],
      errors: () => contains(isA<Exception>()),
    );

    blocTest(
      'FetchProductCartItemAmount emits a failure state and rethrows when the handler throws',
      build: () {
        cartHandler = MockInnerCartHandler();
        authInterface = MockAuthInnerInterface();
        appLifecycleService = FakeAppLifecycleService();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => cartHandler.getProductCartItemAmount('user-1', 'product-1')).thenThrow(Exception('amount failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(CartEventFetchProductCartItemAmount(userId: 'user-1', productId: 'product-1'));
        await pumpEventQueue();
      },
      expect: () => [
        isA<CartState>().having((s) => s.states, 'states', CartStates.loading),
        isA<CartState>().having((s) => s.states, 'states', CartStates.faildFetchedProductCartItemCount),
      ],
      errors: () => contains(isA<Exception>()),
    );
  });
}
