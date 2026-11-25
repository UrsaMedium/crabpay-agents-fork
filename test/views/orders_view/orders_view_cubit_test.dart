import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_bloc.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_event.dart';
import 'package:crabpay/core/backend/common/paginated_result_data_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/views/main_screen/_sub/orders_view/driver/cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/platform_channel_mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(mockFlutterToastChannel);

  OrdersViewCubit buildCubit({required CartBloc cartBloc, required ChatBloc chatBloc}) {
    return OrdersViewCubit(cartBloc: cartBloc, chatBloc: chatBloc, products: [makeProduct()]);
  }

  ({OrdersViewCubit cubit, CartBloc cartBloc, ChatBloc chatBloc, MockInnerCartHandler cartHandler}) buildParts({
    MockInnerCartHandler? cartHandler,
    MockInnerChatHandler? chatHandler,
  }) {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final resolvedCartHandler = cartHandler ?? MockInnerCartHandler();
    final resolvedChatHandler = chatHandler ?? MockInnerChatHandler();
    final lifecycle = FakeAppLifecycleService();
    addTearDown(lifecycle.dispose);
    final cartBloc = CartBloc(
      cartHandler: resolvedCartHandler,
      authInterface: authInterface,
      appLifecycleService: lifecycle,
    );
    final chatBloc = ChatBloc(chatHandler: resolvedChatHandler, authInterface: authInterface);
    final cubit = buildCubit(cartBloc: cartBloc, chatBloc: chatBloc);
    addTearDown(cartBloc.close);
    addTearDown(chatBloc.close);
    addTearDown(cubit.close);
    return (cubit: cubit, cartBloc: cartBloc, chatBloc: chatBloc, cartHandler: resolvedCartHandler);
  }

  group('OrdersViewCubit order grouping', () {
    test('groups not-delivered orders from CartBloc emissions', () async {
      final cartHandler = MockInnerCartHandler();
      when(() => cartHandler.fetchNotDeliveredOrdersIds(any(), pageToken: any(named: 'pageToken'))).thenAnswer((_) async => PaginatedResult<String>(objects: ['order-1234567'], hasMore: false));
      when(() => cartHandler.fetchItemsOfOrder(any(), any())).thenAnswer((_) async => [makeCartItem(id: 'cart-item-1', productId: 'product-1', checkoutPrice: 12, statusChangedAt: testDate)]);
      final parts = buildParts(cartHandler: cartHandler);

      parts.cartBloc.add(CartEventFetchNotDeliveredOrders(userId: 'user-1', pageToken: null));
      await pumpEventQueue();

      expect(parts.cubit.state.crabNotDeliveredOrders, hasLength(1));
      expect(parts.cubit.state.crabNotDeliveredOrders!.first.orderId, 'order-1234567');
      expect(parts.cubit.state.hasMoreNotDeliveredOrders, false);
    });

    test('groups delivered orders and syncs hasMoreDeliveredOrders', () async {
      final cartHandler = MockInnerCartHandler();
      when(() => cartHandler.fetchDeliveredOrdersIds(any(), pageToken: any(named: 'pageToken'))).thenAnswer((_) async => PaginatedResult<String>(objects: ['order-7654321'], hasMore: false));
      when(() => cartHandler.fetchItemsOfOrder(any(), any())).thenAnswer(
        (_) async => [
          makeCartItem(id: 'cart-item-2', productId: 'product-1', checkoutPrice: 20, status: 'delivered', statusChangedAt: testDate),
        ],
      );
      final parts = buildParts(cartHandler: cartHandler);

      parts.cartBloc.add(CartEventFetchDeliveredOrders(userId: 'user-1', pageToken: null));
      await pumpEventQueue();

      expect(parts.cubit.state.crabDeliveredOrders, hasLength(1));
      expect(parts.cubit.state.crabDeliveredOrders!.first.orderId, 'order-7654321');
      expect(parts.cubit.state.crabDeliveredOrders!.first.amountOfDeliveredItems, 1);
      expect(parts.cubit.state.hasMoreDeliveredOrders, false);
    });

    test('groups searched orders and syncs hasMoreSearchedOrders', () async {
      final cartHandler = MockInnerCartHandler();
      when(
        () => cartHandler.fetchSearchedOrdersIds(
          userId: any(named: 'userId'),
          pageToken: any(named: 'pageToken'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
          orderId: any(named: 'orderId'),
        ),
      ).thenAnswer((_) async => PaginatedResult<String>(objects: ['order-1111111'], hasMore: false));
      when(() => cartHandler.fetchItemsOfOrder(any(), any())).thenAnswer(
        (_) async => [
          makeCartItem(id: 'cart-item-3', productId: 'product-1', checkoutPrice: 30, statusChangedAt: testDate),
        ],
      );
      final parts = buildParts(cartHandler: cartHandler);

      parts.cartBloc.add(
        CartEventFetchSearchedOrders(
          userId: 'user-1',
          pageToken: null,
          fromDate: DateTime(2026, 1, 1),
          toDate: DateTime(2026, 1, 31),
          orderId: null,
        ),
      );
      await pumpEventQueue();

      expect(parts.cubit.state.crabSearchedOrders, hasLength(1));
      expect(parts.cubit.state.crabSearchedOrders!.first.orderId, 'order-1111111');
      expect(parts.cubit.state.hasMoreSearchedOrders, false);
    });
  });

  group('OrdersViewCubit search state', () {
    test('setSearchingState opens search and clears existing filters', () async {
      final parts = buildParts();

      parts.cubit.setSearchFilterParameters(DateTime(2026, 1, 5), DateTime(2026, 1, 6));
      expect(parts.cubit.state.fromDate, DateTime(2026, 1, 5));
      expect(parts.cubit.state.toDate, DateTime(2026, 1, 6));

      parts.cubit.setSearchingState(true);
      expect(parts.cubit.state.isSerchOpen, true);
      expect(parts.cubit.state.fromDate, isNull);
      expect(parts.cubit.state.toDate, isNull);
    });

    test('setSearchFilterParameters stores dates and DateTime(0) clears them', () async {
      final parts = buildParts();

      parts.cubit.setSearchFilterParameters(DateTime(2026, 1, 5), DateTime(2026, 1, 6));
      expect(parts.cubit.state.fromDate, DateTime(2026, 1, 5));
      expect(parts.cubit.state.toDate, DateTime(2026, 1, 6));

      parts.cubit.setSearchFilterParameters(DateTime(0), DateTime(0));
      expect(parts.cubit.state.fromDate, isNull);
      expect(parts.cubit.state.toDate, isNull);
    });
  });

  group('OrdersViewCubit misc setters', () {
    test('setPage, setSyncingState, setLoadingState and setSupportMessageStateTrue', () async {
      final parts = buildParts();

      parts.cubit.setPage(2);
      expect(parts.cubit.state.page, 2);

      parts.cubit.setSyncingState(true);
      expect(parts.cubit.state.isSyncingPages, true);

      parts.cubit.setLoadingState(true);
      expect(parts.cubit.state.isLoadingMore, true);

      parts.cubit.setSupportMessageStateTrue();
      expect(parts.cubit.state.isSupportMessageSending, true);
    });
  });

  group('OrdersViewCubit chat reaction', () {
    test('isSupportMessageSending resets when a shadow message is sent', () async {
      final chatHandler = MockInnerChatHandler();
      when(() => chatHandler.getOrCreateThread(userId: any(named: 'userId'))).thenAnswer((_) async => makeSupportThread());
      when(
        () => chatHandler.sendShadowMessage(
          content: any(named: 'content'),
          shadowContent: any(named: 'shadowContent'),
          senderId: any(named: 'senderId'),
          threadId: any(named: 'threadId'),
        ),
      ).thenAnswer((_) async {});
      final parts = buildParts(chatHandler: chatHandler);

      parts.cubit.setSupportMessageStateTrue();
      parts.chatBloc.add(ChatEventSendShadowMessage(content: 'hi', senderId: 'user-1', shadowContent: 'hi?'));
      await pumpEventQueue();

      expect(parts.cubit.state.isSupportMessageSending, false);
    });
  });

  group('OrdersViewCubit.close', () {
    test('cancels subscriptions: no state is emitted from CartBloc afterwards', () async {
      final parts = buildParts();
      final emitted = <OrdersViewState>[];
      final subscription = parts.cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(parts.cubit.isClosed, false);
      await parts.cubit.close();
      expect(parts.cubit.isClosed, true);

      when(() => parts.cartHandler.fetchNotDeliveredOrdersIds(any(), pageToken: any(named: 'pageToken'))).thenAnswer((_) async => PaginatedResult<String>(objects: ['order-9999999'], hasMore: false));
      when(() => parts.cartHandler.fetchItemsOfOrder(any(), any())).thenAnswer(
        (_) async => [
          makeCartItem(id: 'cart-item-9', productId: 'product-1', checkoutPrice: 1, statusChangedAt: testDate),
        ],
      );
      parts.cartBloc.add(CartEventFetchNotDeliveredOrders(userId: 'user-1', pageToken: null));
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(parts.cubit.state.crabNotDeliveredOrders, isEmpty);
    });
  });
}
