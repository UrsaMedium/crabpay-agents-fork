import 'dart:convert';

import 'package:crabpay/core/backend/admin/admin_database/admin_outer_database_handler/admin_outer_database_handler_with_supabase.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
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

  group('AdminOuterDatabaseHandlerWithSupabase', () {
    late MockGraphQLClient mock;
    late AdminOuterDatabaseHandlerWithSupabase handler;

    QueryResult okResult(Map<String, dynamic> data) => QueryResult(
      options: MutationOptions(document: gql('mutation { __typename }')),
      data: data,
      source: QueryResultSource.network,
    );

    QueryResult errorResult() => QueryResult(
      options: MutationOptions(document: gql('mutation { __typename }')),
      exception: OperationException(graphqlErrors: <GraphQLError>[const GraphQLError(message: 'boom')]),
      source: QueryResultSource.network,
    );

    Map<String, dynamic> capturedVariables() => (verify(() => mock.mutate(captureAny())).captured.last as MutationOptions).variables;

    setUp(() {
      mock = MockGraphQLClient();
      mockFlutterToastChannel();
      when(() => mock.mutate(any())).thenAnswer((_) async => okResult({}));
      handler = AdminOuterDatabaseHandlerWithSupabase(client: mock, retryOptions: noRetry);
    });

    test('addProductAdmin sends id/name/imageUrl/description/currencies variables', () async {
      final product = makeProduct();
      await handler.addProductAdmin(product: product);
      final variables = capturedVariables();
      expect(variables['id'], product.id);
      expect(variables['name'], product.name);
      expect(variables['imageUrl'], product.image);
      expect(variables['description'], product.description);
      expect(variables['currencies'], product.currencies);
    });

    test('addProductAdmin sends null id when product id is empty', () async {
      await handler.addProductAdmin(product: Product.intial());
      expect(capturedVariables()['id'], isNull);
    });

    test('updateProductAdmin sends id and set(imageUrl, name, description)', () async {
      final product = makeProduct();
      await handler.updateProductAdmin(product: product);
      final variables = capturedVariables();
      expect(variables['id'], product.id);
      expect(variables['set'], {
        'imageUrl': product.image,
        'name': product.name,
        'description': product.description,
      });
    });

    test('deleteProductAdmin sends id variable', () async {
      final product = makeProduct();
      await handler.deleteProductAdmin(product: product);
      expect(capturedVariables()['id'], product.id);
    });

    test('addProductFieldAdmin sends jsonEncode(priceImages) and expectedData', () async {
      final field = makeProductField(priceImages: {'UR': 2.5}, expectedData: ['a', 'b']);
      await handler.addProductFieldAdmin(field: field);
      final variables = capturedVariables();
      expect(variables['productId'], field.productId);
      expect(variables['order'], field.order);
      expect(variables['fieldName'], field.fieldName);
      expect(variables['isPriceImage'], field.isPriceImage);
      expect(variables['handler'], field.handler);
      expect(variables['priceImages'], jsonEncode(field.priceImages));
      expect(variables['expectedData'], ['a', 'b']);
    });

    test('updateProductFieldAdmin sends id and set with jsonEncode(priceImages)', () async {
      final field = makeProductField(priceImages: {'UR': 2.5}, expectedData: ['a', 'b']);
      await handler.updateProductFieldAdmin(field: field);
      final variables = capturedVariables();
      expect(variables['id'], field.id);
      expect(variables['set'], {
        'order': field.order,
        'fieldName': field.fieldName,
        'isPriceImage': field.isPriceImage,
        'priceImages': jsonEncode(field.priceImages),
        'expectedData': ['a', 'b'],
      });
    });

    test('deleteProductFieldAdmin sends id variable', () async {
      final field = makeProductField();
      await handler.deleteProductFieldAdmin(field: field);
      expect(capturedVariables()['id'], field.id);
    });

    test('addCurrenciesAdmin sends name/mainCurrency/rub/usd variables', () async {
      final currencies = makeCurrencies();
      await handler.addCurrenciesAdmin(currencies: currencies);
      final variables = capturedVariables();
      expect(variables['name'], currencies.name);
      expect(variables['mainCurrency'], currencies.mainCurrency);
      expect(variables['rub'], currencies.rub);
      expect(variables['usd'], currencies.usd);
    });

    test('deleteCurrenciesAdmin sends id variable', () async {
      final currencies = makeCurrencies();
      await handler.deleteCurrenciesAdmin(currencies: currencies);
      expect(capturedVariables()['id'], currencies.id);
    });

    test('addFeaturedProductAdmin sends fId variable', () async {
      await handler.addFeaturedProductAdmin(productId: 'p-1');
      expect(capturedVariables()['fId'], 'p-1');
    });

    test('deleteFeaturedProductAdmin sends fId variable', () async {
      await handler.deleteFeaturedProductAdmin(productId: 'p-1');
      expect(capturedVariables()['fId'], 'p-1');
    });

    // Documents current bug: add/delete swallow errors (toast only) while update rethrows.
    test('add/delete product swallow GraphQL errors while the other mutations rethrow', () async {
      when(() => mock.mutate(any())).thenAnswer((_) async => errorResult());
      await expectLater(handler.addProductAdmin(product: makeProduct()), completes);
      await expectLater(handler.updateProductAdmin(product: makeProduct()), throwsA(isA<Exception>()));
      await expectLater(handler.deleteProductAdmin(product: makeProduct()), completes);
      await expectLater(handler.addProductFieldAdmin(field: makeProductField()), throwsA(isA<Exception>()));
      await expectLater(handler.updateProductFieldAdmin(field: makeProductField()), throwsA(isA<Exception>()));
      await expectLater(handler.deleteProductFieldAdmin(field: makeProductField()), throwsA(isA<Exception>()));
      await expectLater(handler.addCurrenciesAdmin(currencies: makeCurrencies()), throwsA(isA<Exception>()));
      await expectLater(handler.deleteCurrenciesAdmin(currencies: makeCurrencies()), throwsA(isA<Exception>()));
      await expectLater(handler.addFeaturedProductAdmin(productId: 'p-1'), throwsA(isA<Exception>()));
      await expectLater(handler.deleteFeaturedProductAdmin(productId: 'p-1'), throwsA(isA<Exception>()));
    });

    test('updateProductFieldSwapImageFieldAdmin throws UnimplementedError', () async {
      await expectLater(
        () => handler.updateProductFieldSwapImageFieldAdmin(oldImageField: makeProductField(), newImageField: makeProductField()),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
