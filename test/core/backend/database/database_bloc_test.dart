import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_state.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/currencies_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_fields_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('DatabaseBloc', () {
    late StreamController<AppAuthUser> userController;
    late MockInnerDatabaseHandler databaseHandler;
    late MockAuthInnerInterface authInterface;
    late Product product1;
    late Product product2;
    late Product product;
    late ProductField field;
    late Currencies currencies;

    DatabaseBloc buildBloc() {
      final bloc = DatabaseBloc(databaseHandler: databaseHandler, authInnerface: authInterface);
      addTearDown(bloc.close);
      return bloc;
    }

    test('initial state is DatabaseStates.dbLoading', () {
      databaseHandler = MockInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
      final bloc = buildBloc();
      expect(bloc.state.states, DatabaseStates.dbLoading);
    });

    blocTest(
      'Initialize populates products, featured products and user preferences',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        product1 = makeProduct(id: 'product-1');
        product2 = makeProduct(id: 'product-2');
        final products = [product1, product2];
        when(() => databaseHandler.fetchAllProducts()).thenAnswer((_) async => products);
        when(() => databaseHandler.fetchAllFeaturedProducts()).thenAnswer((_) async => ['product-1']);
        when(() => databaseHandler.fetchUserPreferences(userId: 'user-1')).thenAnswer((_) async => ['product-2']);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventInitialize(currentUser: makeAuthUser())),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.initialized),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchAllProducts()).called(1);
        verify(() => databaseHandler.fetchAllFeaturedProducts()).called(1);
        verify(() => databaseHandler.fetchUserPreferences(userId: 'user-1')).called(1);
        final DatabaseState state = bloc.state;
        expect(state.states, DatabaseStates.initialized);
        expect(state.products, [product1, product2]);
        expect(state.featuredProducts, [product1]);
        expect(state.userPreferences, [product2]);
      },
    );

    blocTest(
      'Initialize skips user preferences for anonymous users',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.fetchAllProducts()).thenAnswer((_) async => [makeProduct(id: 'product-1')]);
        when(() => databaseHandler.fetchAllFeaturedProducts()).thenAnswer((_) async => <String>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventInitialize(currentUser: makeAuthUser(isAnonymous: true))),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.initialized),
      ],
      verify: (bloc) {
        verifyNever(() => databaseHandler.fetchUserPreferences(userId: 'user-1'));
        verify(() => databaseHandler.fetchAllProducts()).called(1);
      },
    );

    blocTest(
      'FlushUserData sets the flushedUserData state',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventFlushUserData()),
      expect: () => [isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.flushedUserData)],
    );

    blocTest(
      'FetchAllProducts stores the fetched products',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        product = makeProduct(id: 'product-1');
        final products = [product];
        when(() => databaseHandler.fetchAllProducts()).thenAnswer((_) async => products);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventFetchAllProducts()),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.productsFetched).having((s) => s.products, 'products', [product]),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchAllProducts()).called(1);
      },
    );

    blocTest(
      'FetchAllProducts handles a null product list',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.fetchAllProducts()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventFetchAllProducts()),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.productsFetched),
      ],
    );

    blocTest(
      'FetchProductFields caches the fetched fields for the product id',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        field = makeProductField(id: 'field-1', productId: 'product-1');
        when(() => databaseHandler.fetchProductFields(productId: 'product-1')).thenAnswer((_) async => [field]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventFetchProductFields(productId: 'product-1')),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.fieldsFetched).having((s) => s.cachedProductFields, 'cachedProductFields', {
          'product-1': [field],
        }),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchProductFields(productId: 'product-1')).called(1);
      },
    );

    blocTest(
      'FetchAllCurrencies stores the fetched currencies',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        currencies = makeCurrencies();
        when(() => databaseHandler.fetchAllCurencies()).thenAnswer((_) async => [currencies]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventFetchAllCurrencies()),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.currenciesFetched).having((s) => s.currencies, 'currencies', [currencies]),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchAllCurencies()).called(1);
      },
    );

    blocTest(
      'FetchAllFeaturedProducts returns featured products from the loaded products',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        product = makeProduct(id: 'product-1');
        when(() => databaseHandler.fetchAllFeaturedProducts()).thenAnswer((_) async => ['product-1']);
        return buildBloc();
      },
      seed: () => DatabaseState(products: [product]),
      act: (bloc) => bloc.add(DatabaseEventFetchAllFeaturedProducts()),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.featuedProductsFetched).having((s) => s.featuredProducts, 'featuredProducts', [product]),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchAllFeaturedProducts()).called(1);
      },
    );

    blocTest(
      'FetchUserPreferences resolves preference products from the loaded products',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        product = makeProduct(id: 'product-1');
        when(() => databaseHandler.fetchUserPreferences(userId: 'user-1')).thenAnswer((_) async => ['product-1']);
        return buildBloc();
      },
      seed: () => DatabaseState(products: [product]),
      act: (bloc) => bloc.add(DatabaseEventFetchUserPreferences(userId: 'user-1')),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.userPreferencesFetched).having((s) => s.userPreferences, 'userPreferences', [product]),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.fetchUserPreferences(userId: 'user-1')).called(1);
      },
    );

    blocTest(
      'AddUserPreference adds the product to the user preferences',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        product = makeProduct(id: 'product-1');
        when(() => databaseHandler.addUserPreference(userId: 'user-1', productId: 'product-1')).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventAddUserPreference(userId: 'user-1', product: product)),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.userPreferencesAdded).having((s) => s.userPreferences, 'userPreferences', [product]),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.addUserPreference(userId: 'user-1', productId: 'product-1')).called(1);
      },
    );

    blocTest(
      'DeleteUserPreference removes the product from the user preferences',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.deleteUserPreference(userId: 'user-1', productId: 'product-1')).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DatabaseEventDeleteUserPreference(product: product, userId: 'user-1')),
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.userPreferencesDeleted),
      ],
      verify: (bloc) {
        verify(() => databaseHandler.deleteUserPreference(userId: 'user-1', productId: 'product-1')).called(1);
      },
    );

    blocTest(
      'Auth stream user change reinitializes the database for the new user',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        product = makeProduct(id: 'product-1');
        when(() => databaseHandler.fetchAllProducts()).thenAnswer((_) async => [product]);
        when(() => databaseHandler.fetchAllFeaturedProducts()).thenAnswer((_) async => <String>[]);
        when(() => databaseHandler.fetchUserPreferences(userId: 'user-1')).thenAnswer((_) async => <String>[]);
        when(() => databaseHandler.fetchUserPreferences(userId: 'user-2')).thenAnswer((_) async => <String>[]);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(DatabaseEventInitialize(currentUser: makeAuthUser()));
        await pumpEventQueue();
        userController.add(makeAuthUser(id: 'user-2'));
        await pumpEventQueue();
      },
      verify: (bloc) {
        verify(() => databaseHandler.fetchAllProducts()).called(2);
        verify(() => databaseHandler.fetchUserPreferences(userId: 'user-2')).called(1);
        final DatabaseState state = bloc.state;
        expect(state.states, DatabaseStates.initialized);
        expect(state.products, [product]);
      },
    );

    blocTest(
      'Initialize emits notInitialized and rethrows when fetchAllProducts throws',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.fetchAllProducts()).thenThrow(Exception('products failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(DatabaseEventInitialize(currentUser: makeAuthUser()));
        await pumpEventQueue();
      },
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.notInitialized),
      ],
      errors: () => contains(isA<Exception>()),
    );

    blocTest(
      'FetchAllProducts emits productsNotFetched and rethrows when the handler throws',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.fetchAllProducts()).thenThrow(Exception('products failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(DatabaseEventFetchAllProducts());
        await pumpEventQueue();
      },
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.productsNotFetched),
      ],
      errors: () => contains(isA<Exception>()),
    );

    blocTest(
      'FetchProductFields emits fieldsNotFetched and rethrows when the handler throws',
      build: () {
        databaseHandler = MockInnerDatabaseHandler();
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => databaseHandler.fetchProductFields(productId: 'product-1')).thenThrow(Exception('fields failed'));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(DatabaseEventFetchProductFields(productId: 'product-1'));
        await pumpEventQueue();
      },
      expect: () => [
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.dbLoading),
        isA<DatabaseState>().having((s) => s.states, 'states', DatabaseStates.fieldsNotFetched),
      ],
      errors: () => contains(isA<Exception>()),
    );
  });
}
