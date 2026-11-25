import 'dart:convert';

import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_outer_circle/outer_cart_handler_with_supabase.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/platform_channel_mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerTestFallbackValues();
    registerFakeLogger();
  });

  tearDownAll(() {
    unregisterFakeLogger();
  });

  group('OuterCartHandlerWithSupabase', () {
    late MockGraphQLClient mock;
    late MockSupabaseClient supabaseClient;
    late MockInnerConnectionMonitor monitor;
    late FakeAppLifecycleService lifecycle;
    late OuterCartHandlerWithSupabase handler;

    setUp(() {
      mock = MockGraphQLClient();
      supabaseClient = MockSupabaseClient();
      monitor = MockInnerConnectionMonitor();
      mockFlutterToastChannel();
      when(() => monitor.statusStream).thenAnswer((_) => Stream<ServerConnectionStatus>.empty());
      when(() => monitor.currentStatus).thenReturn(ServerConnectionStatus.online);
      lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      handler = OuterCartHandlerWithSupabase(
        appLifecycleService: lifecycle,
        connectionMonitor: monitor,
        client: mock,
        supabaseClient: supabaseClient,
        retryOptions: noRetry,
      );
    });

    tearDown(() {
      handler.dispose();
    });

    QueryResult okResult(Map<String, dynamic> data) => QueryResult(
      options: QueryOptions(document: gql('query { __typename }')),
      data: data,
      source: QueryResultSource.network,
    );

    QueryResult okMutationResult(Map<String, dynamic> data) => QueryResult(
      options: MutationOptions(document: gql('mutation { __typename }')),
      data: data,
      source: QueryResultSource.network,
    );

    Map<String, dynamic> queryVariables() => (verify(() => mock.query(captureAny())).captured.last as QueryOptions).variables;

    Map<String, dynamic> mutationVariables() => (verify(() => mock.mutate(captureAny())).captured.last as MutationOptions).variables;

    group('fetchCartItemsToBuy / fetchPendingCartItems / fetchItemsOfOrder (_dataCasting)', () {
      test('casts purchaseData from a JSON string and purchaseData from a Map', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {
              'edges': [
                {
                  'node': {
                    'id': 'ci-1',
                    'userId': 'user-1',
                    'userName': 'User One',
                    'productId': 'p-1',
                    'productName': 'Laptop',
                    'purchaseData': '{"Region":"EU","Seats":1}',
                    'currency': 'rub',
                    'checkoutPrice': 100,
                    'status': 'created',
                    'comment': null,
                    'paymentId': 'pm-1',
                    'createdAt': '2026-01-15T10:30:00',
                  },
                },
                {
                  'node': {
                    'id': 'ci-2',
                    'userId': 'user-1',
                    'userName': 'User One',
                    'productId': 'p-2',
                    'productName': 'Mouse',
                    'purchaseData': {'Region': 'EU'},
                    'currency': 'rub',
                    'checkoutPrice': 40.5,
                    'status': 'failed',
                    'comment': null,
                    'paymentId': null,
                    'createdAt': '2026-01-15T10:30:00',
                    'statusChangedAt': '2026-01-16T09:00:00',
                  },
                },
              ],
            },
          }),
        );
        final items = await handler.fetchCartItemsToBuy('user-1');
        expect(items.length, 2);
        expect(items[0].purchaseData, {'Region': 'EU', 'Seats': '1'});
        expect(items[0].checkoutPrice, 100.0);
        expect(items[0].createdAt, DateTime.parse('2026-01-15T10:30:00').toLocal());
        expect(items[0].statusChangedAt, isNull);
        expect(items[1].purchaseData, {'Region': 'EU'});
        expect(items[1].statusChangedAt, DateTime.parse('2026-01-16T09:00:00').toLocal());
      });

      test('falls back to DateTime(0) when createdAt/statusChangedAt are missing', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {
              'edges': [
                {
                  'node': {
                    'id': 'ci-3',
                    'userId': 'user-1',
                    'userName': 'User One',
                    'productId': 'p-1',
                    'productName': 'Laptop',
                    'purchaseData': null,
                    'currency': 'rub',
                    'checkoutPrice': 10,
                    'status': 'created',
                  },
                },
              ],
            },
          }),
        );
        final items = await handler.fetchCartItemsToBuy('user-1');
        expect(items.first.createdAt, DateTime(0));
        expect(items.first.statusChangedAt, isNull);
      });

      test('fetchPendingCartItems sends paymentId variable and casts items', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {
              'edges': [
                {
                  'node': {
                    'id': 'ci-4',
                    'userId': 'user-1',
                    'userName': 'User One',
                    'productId': 'p-1',
                    'productName': 'Laptop',
                    'purchaseData': '{"Region":"EU"}',
                    'currency': 'rub',
                    'checkoutPrice': 55.25,
                    'status': 'pending',
                    'paymentId': 'pm-9',
                    'paymentLink': 'https://example.com/pay',
                  },
                },
              ],
            },
          }),
        );
        final items = await handler.fetchPendingCartItems('pm-9');
        expect(queryVariables()['paymentId'], 'pm-9');
        expect(items.length, 1);
        expect(items.first.purchaseData, {'Region': 'EU'});
        expect(items.first.paymentId, 'pm-9');
        expect(items.first.paymentLink, 'https://example.com/pay');
      });

      test('fetchItemsOfOrder sends userId/orderId variables and casts items', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {
              'edges': [
                {
                  'node': {
                    'id': 'ci-5',
                    'userId': 'user-1',
                    'userName': 'User One',
                    'productId': 'p-1',
                    'productName': 'Laptop',
                    'purchaseData': {'Region': 'EU'},
                    'currency': 'rub',
                    'checkoutPrice': 77,
                    'status': 'created',
                    'paymentId': 'pm-8',
                  },
                },
              ],
            },
          }),
        );
        final items = await handler.fetchItemsOfOrder('user-1', 'pm-8');
        final variables = queryVariables();
        expect(variables['userId'], 'user-1');
        expect(variables['orderId'], 'pm-8');
        expect(items.length, 1);
        expect(items.first.checkoutPrice, 77.0);
      });
    });

    group('fetchNotDeliveredOrdersIds / fetchDeliveredOrdersIds', () {
      test('maps pageInfo to PaginatedResult', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'userUniquePaymentCollection': {
              'pageInfo': {'hasNextPage': true, 'endCursor': 'cursor-abc'},
              'edges': [
                {
                  'node': {'paymentId': 'pm-1'},
                },
                {
                  'node': {'paymentId': 'pm-2'},
                },
              ],
            },
          }),
        );
        final result = await handler.fetchNotDeliveredOrdersIds('user-1');
        final variables = queryVariables();
        expect(result.objects, ['pm-1', 'pm-2']);
        expect(result.hasMore, isTrue);
        expect(result.nextPageToken, 'cursor-abc');
        expect(variables['userId'], 'user-1');
        expect(variables['afterCursor'], isNull);
      });

      test('fetchDeliveredOrdersIds maps pageInfo to PaginatedResult', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'userUniquePaymentCollection': {
              'pageInfo': {'hasNextPage': false, 'endCursor': 'cursor-x'},
              'edges': [
                {
                  'node': {'paymentId': 'pm-1'},
                },
              ],
            },
          }),
        );
        final result = await handler.fetchDeliveredOrdersIds('user-1', pageToken: 'cursor-x');
        expect(result.objects, ['pm-1']);
        expect(result.hasMore, isFalse);
        expect(result.nextPageToken, 'cursor-x');
      });
    });

    group('fetchSearchedOrdersIds', () {
      test('uses pageToken as int offset and hasMore when edges.length == 4', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'userUniquePaymentCollection': {
              'edges': [
                {
                  'node': {'paymentId': 'pm-1'},
                },
                {
                  'node': {'paymentId': 'pm-2'},
                },
                {
                  'node': {'paymentId': 'pm-3'},
                },
                {
                  'node': {'paymentId': 'pm-4'},
                },
              ],
            },
          }),
        );
        final result = await handler.fetchSearchedOrdersIds(userId: 'user-1', pageToken: '5');
        final variables = queryVariables();
        expect(result.objects.length, 4);
        expect(result.hasMore, isTrue);
        expect(result.nextPageToken, '9');
        expect(variables['offset'], 5);
        expect(variables['userId'], 'user-1');
      });

      test('trims orderId and converts date filters to UTC', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'userUniquePaymentCollection': {
              'edges': [
                {
                  'node': {'paymentId': 'pm-42'},
                },
              ],
            },
          }),
        );

        final fromDate = DateTime(2026, 1, 15, 10, 30, 0, 0, 3);
        final toDate = DateTime(2026, 1, 16, 11, 0, 0, 0, -5);
        final result = await handler.fetchSearchedOrdersIds(
          userId: 'user-1',
          orderId: '  pm-42  ',
          fromDate: fromDate,
          toDate: toDate,
        );

        expect(result.objects, ['pm-42']);
        final options = verify(() => mock.query(captureAny())).captured.last as QueryOptions;
        expect(options.variables['orderId'], 'pm-42');
        expect(options.variables['fromDate'], fromDate.toUtc().toIso8601String());
        expect(options.variables['toDate'], toDate.toUtc().toIso8601String());
        expect(fromDate.toUtc().toIso8601String(), endsWith('Z'));

        // Check the generated GraphQL query declares the filter variables.
        final operation = options.document.definitions.first as dynamic;
        final variableNames = (operation.variableDefinitions as List).map((v) => v.variable.name.value).toList();
        expect(variableNames, containsAll(['offset', 'orderId', 'fromDate', 'toDate']));
        final collectionField =
            (operation.selectionSet.selections as List).firstWhere(
                  (node) => node.name.value == 'userUniquePaymentCollection',
                )
                as dynamic;
        final filterArgument =
            (collectionField.arguments as List).firstWhere(
                  (argument) => argument.name.value == 'filter',
                )
                as dynamic;
        final filterFields = (filterArgument.value.fields as List).map((field) => field.name.value).toList();
        expect(filterFields, containsAll(['paymentId', 'latestCreatedAt']));
      });
    });

    group('mutations', () {
      test('addCartItem sends purchaseData jsonEncode(d) variables', () async {
        when(() => mock.mutate(any())).thenAnswer((_) async => okMutationResult({}));
        final item = makeCartItem();
        await handler.addCartItem(item);
        final variables = mutationVariables();
        expect(variables['userId'], item.userId);
        expect(variables['userName'], item.userName);
        expect(variables['productId'], item.productId);
        expect(variables['productName'], item.productName);
        expect(variables['purchaseData'], jsonEncode(item.purchaseData));
        expect(variables['currency'], item.currency);
        expect(variables['checkoutPrice'], item.checkoutPrice);
        expect(variables['status'], item.status);
        expect(variables['comment'], item.comment);
      });

      test('deleteCartItem sends id variable', () async {
        when(() => mock.mutate(any())).thenAnswer((_) async => okMutationResult({}));
        await handler.deleteCartItem('ci-1');
        expect(mutationVariables()['id'], 'ci-1');
      });

      test('updateCartItem sends status=beingCheckedOut and id variables when user is null', () async {
        when(() => mock.mutate(any())).thenAnswer((_) async => okMutationResult({}));
        final item = makeCartItem();
        await handler.updateCartItem(<CartItem>[item], null);
        final variables = mutationVariables();
        expect(variables['id'], item.id);
        expect(variables['status'], 'beingCheckedOut');
        expect(variables['time'], isNotNull);
      });

      test('updateCartItem with a non-null AppAuthUser is a no-op', () async {
        // Documents current behavior: only the anonymous-user branch sends mutations.
        final item = makeCartItem();
        await expectLater(handler.updateCartItem(<CartItem>[item], makeAuthUser()), completes);
        verifyNever(() => mock.mutate(any()));
      });

      test('getProductCartItemAmount returns the node count', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'ofUserOfProductCartItemCounterCollection': {
              'edges': [
                {
                  'node': {'productCartItemCount': 3},
                },
              ],
            },
          }),
        );
        final items = await handler.getProductCartItemAmount('user-1', 'p-1');
        final variables = queryVariables();
        expect(items, 3);
        expect(variables['uId'], 'user-1');
        expect(variables['pId'], 'p-1');
      });

      test('deleteLastAddedProductCartItem deletes the first matching edge node', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {
              'edges': [
                {
                  'node': {'id': 'ci-9'},
                },
              ],
            },
          }),
        );
        when(() => mock.mutate(any())).thenAnswer(
          (_) async => okMutationResult({
            'deleteFromcartItemCollection': {'affectedCount': 1},
          }),
        );
        expect(await handler.deleteLastAddedProductCartItem('user-1', 'p-1'), isTrue);
        expect(mutationVariables()['id'], 'ci-9');
      });

      test('deleteLastAddedProductCartItem returns false when no created cart item exists', () async {
        when(() => mock.query(any())).thenAnswer(
          (_) async => okResult({
            'cartItemCollection': {'edges': []},
          }),
        );

        expect(await handler.deleteLastAddedProductCartItem('user-1', 'p-1'), isFalse);
        verifyNever(() => mock.mutate(any()));
      });
    });
  });
}
