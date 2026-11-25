import 'package:crabpay/core/backend/database/general_db/db_outer_circle/outer_database_handler_with_supabase.dart';
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

  group('OuterDatabaseHandlerWithSupabase', () {
    late MockGraphQLClient mock;

    setUp(() {
      mock = MockGraphQLClient();
      mockFlutterToastChannel();
    });

    QueryResult okResult(Map<String, dynamic> data) => QueryResult(
      options: QueryOptions(document: gql('query { __typename }')),
      data: data,
      source: QueryResultSource.network,
    );

    QueryResult errorResult() => QueryResult(
      options: QueryOptions(document: gql('query { __typename }')),
      exception: OperationException(graphqlErrors: <GraphQLError>[const GraphQLError(message: 'boom')]),
      source: QueryResultSource.network,
    );

    test('fetchAllProducts maps productCollection.edges[].node to Product', () async {
      when(() => mock.query(any())).thenAnswer(
        (_) async => okResult({
          'productCollection': {
            'edges': [
              {
                'node': {'id': 'p-1', 'name': 'Laptop', 'imageUrl': 'https://img.png', 'description': 'A laptop', 'currencies': 'rub', 'category': 'tech'},
              },
            ],
          },
        }),
      );
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      final products = await handler.fetchAllProducts();
      expect(products, isNotNull);
      expect(products!.length, 1);
      final product = products.first;
      expect(product.id, 'p-1');
      expect(product.name, 'Laptop');
      expect(product.image, 'https://img.png');
      expect(product.description, 'A laptop');
      expect(product.currencies, 'rub');
      expect(product.category, 'tech');
    });

    test('fetchAllProducts returns null when the query has an exception', () async {
      when(() => mock.query(any())).thenAnswer((_) async => errorResult());
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      expect(await handler.fetchAllProducts(), isNull);
    });

    test('fetchProductFields decodes priceImages (JSON string and Map) and expectedData', () async {
      when(() => mock.query(any())).thenAnswer(
        (_) async => okResult({
          'productFieldCollection': {
            'edges': [
              {
                'node': {
                  'id': 'f-1',
                  'productId': 'p-1',
                  'order': 1,
                  'fieldName': 'Price',
                  'isPriceImage': true,
                  'handler': 'dropdown',
                  'priceImages': '{"UR":3.5,"USD":2}',
                  'expectedData': ['a', 'b'],
                },
              },
              {
                'node': {
                  'id': 'f-2',
                  'productId': 'p-1',
                  'order': 2,
                  'fieldName': 'Region',
                  'isPriceImage': false,
                  'handler': 'dropdown',
                  'priceImages': {'UR': 1.5},
                  'expectedData': [],
                },
              },
            ],
          },
        }),
      );
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      final fields = await handler.fetchProductFields(productId: 'p-1');
      expect(fields, isNotNull);
      expect(fields!.length, 2);
      expect(fields[0].priceImages?['UR'], 3.5);
      expect(fields[0].priceImages?['USD'], 2.0);
      expect(fields[0].expectedData, ['a', 'b']);
      expect(fields[1].priceImages?['UR'], 1.5);
      expect(fields[1].expectedData, isNull);
    });

    test('fetchProductFields rethrows GraphQL exceptions', () async {
      when(() => mock.query(any())).thenAnswer((_) async => errorResult());
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      await expectLater(handler.fetchProductFields(productId: 'p-1'), throwsA(isA<OperationException>()));
    });

    test('fetchAllCurencies maps numeric rub/usd to double', () async {
      when(() => mock.query(any())).thenAnswer(
        (_) async => okResult({
          'currenciesCollection': {
            'edges': [
              {
                'node': {'id': 'c-1', 'name': 'Rubles', 'mainCurrency': 'rub', 'rub': 1, 'usd': 0.011},
              },
            ],
          },
        }),
      );
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      final currencies = await handler.fetchAllCurencies();
      expect(currencies, isNotNull);
      expect(currencies!.length, 1);
      expect(currencies.first.rub, 1.0);
      expect(currencies.first.usd, 0.011);
    });

    test('fetchAllCurencies returns an empty list when the query result has an exception', () async {
      when(() => mock.query(any())).thenAnswer((_) async => errorResult());
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      // Documents current bug: this handler ignores result.hasException and returns [].
      expect(await handler.fetchAllCurencies(), isEmpty);
    });

    test('fetchAllFeaturedProducts maps featuredProductId strings', () async {
      when(() => mock.query(any())).thenAnswer(
        (_) async => okResult({
          'featuredProductCollection': {
            'edges': [
              {
                'node': {'featuredProductId': 'f-1'},
              },
              {
                'node': {'featuredProductId': 'f-2'},
              },
            ],
          },
        }),
      );
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      expect(await handler.fetchAllFeaturedProducts(), ['f-1', 'f-2']);
    });

    test('fetchAllFeaturedProducts returns an empty list when the query result has an exception', () async {
      when(() => mock.query(any())).thenAnswer((_) async => errorResult());
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      // Documents current bug: this handler ignores result.hasException and returns [].
      expect(await handler.fetchAllFeaturedProducts(), isEmpty);
    });

    test('fetchUserPreferences maps favoriteProductId strings and sends uId variable', () async {
      when(() => mock.query(any())).thenAnswer(
        (_) async => okResult({
          'userPreferenceCollection': {
            'edges': [
              {
                'node': {'favoriteProductId': 'fav-1'},
              },
              {
                'node': {'favoriteProductId': 'fav-2'},
              },
            ],
          },
        }),
      );
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      final prefs = await handler.fetchUserPreferences(userId: 'user-1');
      expect(prefs, ['fav-1', 'fav-2']);
      final options = verify(() => mock.query(captureAny())).captured.last as QueryOptions;
      expect(options.variables['uId'], 'user-1');
    });

    test('fetchUserPreferences returns an empty list when the query result has an exception', () async {
      when(() => mock.query(any())).thenAnswer((_) async => errorResult());
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      // Documents current bug: this handler ignores result.hasException and returns [].
      expect(await handler.fetchUserPreferences(userId: 'user-1'), isEmpty);
    });

    test('addUserPreference sends uId/pId in mutation variables', () async {
      when(() => mock.mutate(any())).thenAnswer((_) async => okResult({}));
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      await handler.addUserPreference(userId: 'user-1', productId: 'p-1');
      final options = verify(() => mock.mutate(captureAny())).captured.last as MutationOptions;
      expect(options.variables, containsPair('uId', 'user-1'));
      expect(options.variables, containsPair('pId', 'p-1'));
    });

    test('deleteUserPreference sends uId/pId in mutation variables', () async {
      when(() => mock.mutate(any())).thenAnswer((_) async => okResult({}));
      final handler = OuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
      await handler.deleteUserPreference(userId: 'user-1', productId: 'p-1');
      final options = verify(() => mock.mutate(captureAny())).captured.last as MutationOptions;
      expect(options.variables, containsPair('uId', 'user-1'));
      expect(options.variables, containsPair('pId', 'p-1'));
    });
  });
}
