import 'dart:async';

import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_database_bloc/admin_database_bloc.dart';
import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_database_bloc/admin_database_event.dart';
import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_database_bloc/admin_database_state.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/currencies_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_fields_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('DatabaseBlocAdmin', () {
    late MockAdminInnerDatabaseHandler databaseHandlerAdmin;
    late MockAuthInnerInterface authInterface;
    late Product product;
    late ProductField field;
    late ProductField imageField;
    late Currencies currencies;

    // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
    Future<void> closeBlocIgnoringBug(DatabaseBlocAdmin bloc) async {
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
    }

    DatabaseBlocAdmin buildBloc() {
      final bloc = DatabaseBlocAdmin(databaseHandlerAdmin: databaseHandlerAdmin, authInnerface: authInterface);
      addTearDown(() => closeBlocIgnoringBug(bloc));
      return bloc;
    }

    /// Handler failures are rethrown by the bloc; keep them from failing the
    /// test as unhandled async errors while asserting the emitted error state.
    /// The bloc must be created inside [body] so its streams belong to this zone.
    Future<List<Object>> runWithUnhandledErrors(Future<void> Function() body) async {
      final errors = <Object>[];
      await runZonedGuarded(body, (error, _) => errors.add(error));
      return errors;
    }

    test('initial state is DatabaseStatesAdmin.initialized', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      final bloc = buildBloc();
      expect(bloc.state.states, DatabaseStatesAdmin.initialized);
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
    });

    test('close() throws because the auth subscription is never initialized', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      final bloc = buildBloc();
      var threw = false;
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {
        threw = true;
      }
      expect(threw, isTrue);
    });

    test('AddProductAdmin adds a product', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      when(() => databaseHandlerAdmin.addProductAdmin(product: product)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventAddProductAdmin(product: product));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.productsAdded,
      ]);
      verify(() => databaseHandlerAdmin.addProductAdmin(product: product)).called(1);
    });

    test('DeleteProductAdmin deletes a product', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      when(() => databaseHandlerAdmin.deleteProductAdmin(product: product)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventDeleteProductAdmin(product: product));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.productsDeleted,
      ]);
      verify(() => databaseHandlerAdmin.deleteProductAdmin(product: product)).called(1);
    });

    test('UpdateProductAdmin updates a product', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      when(() => databaseHandlerAdmin.updateProductAdmin(product: product)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventUpdateProductAdmin(product: product));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.productsUpdated,
      ]);
      verify(() => databaseHandlerAdmin.updateProductAdmin(product: product)).called(1);
    });

    test('AddProductFieldAdmin adds a product field', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      field = makeProductField(id: 'field-1', productId: 'product-1');
      when(() => databaseHandlerAdmin.addProductFieldAdmin(field: field)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventAddProductFieldAdmin(productField: field));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.fieldsAdded,
      ]);
      verify(() => databaseHandlerAdmin.addProductFieldAdmin(field: field)).called(1);
    });

    test('DeleteProductFieldAdmin deletes a product field', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      field = makeProductField(id: 'field-1', productId: 'product-1');
      when(() => databaseHandlerAdmin.deleteProductFieldAdmin(field: field)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventDeleteProductFieldAdmin(productField: field));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.fieldsDeleted,
      ]);
      verify(() => databaseHandlerAdmin.deleteProductFieldAdmin(field: field)).called(1);
    });

    test('UpdateProductFieldAdmin updates a product field', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      field = makeProductField(id: 'field-1', productId: 'product-1');
      when(() => databaseHandlerAdmin.updateProductFieldAdmin(field: field)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventUpdateProductFieldAdmin(field: field));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.fieldsUpdated,
      ]);
      verify(() => databaseHandlerAdmin.updateProductFieldAdmin(field: field)).called(1);
    });

    test('UpdateProductFieldSwapImageFieldAdmin swaps image fields', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      field = makeProductField(id: 'field-1', productId: 'product-1');
      imageField = makeProductField(id: 'field-2', productId: 'product-1');
      when(() => databaseHandlerAdmin.updateProductFieldAdmin(field: any(named: "field"))).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(
        DatabaseEventUpdateProductFieldSwapImageFieldAdmin(
          oldImageField: field,
          newImageField: imageField,
        ),
      );
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.fieldsUpdated,
      ]);
      final List<dynamic> captured = verify(() => databaseHandlerAdmin.updateProductFieldAdmin(field: captureAny(named: "field"))).captured;
      expect(captured, hasLength(2));
      expect((captured[0] as ProductField).isPriceImage, isFalse);
      expect((captured[1] as ProductField).isPriceImage, isTrue);
      expect(captured[1], isA<ProductField>());
    });

    test('AddCurrenciesAdmin adds currencies', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      currencies = makeCurrencies();
      when(() => databaseHandlerAdmin.addCurrenciesAdmin(currencies: currencies)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventAddCurrenciesAdmin(currencies: currencies));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.currenciesAdded,
      ]);
      verify(() => databaseHandlerAdmin.addCurrenciesAdmin(currencies: currencies)).called(1);
    });

    test('DeleteCurrenciesAdmin deletes currencies', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      currencies = makeCurrencies();
      when(() => databaseHandlerAdmin.deleteCurrenciesAdmin(currencies: currencies)).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventDeleteCurrenciesAdmin(currencies: currencies));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.currenciesDeleted,
      ]);
      verify(() => databaseHandlerAdmin.deleteCurrenciesAdmin(currencies: currencies)).called(1);
    });

    test('AddFeaturedProductAdmin adds a featured product', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      when(() => databaseHandlerAdmin.addFeaturedProductAdmin(productId: 'product-1')).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventAddFeaturedProductAdmin(product: product));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.featuedProductsAdded,
      ]);
      verify(() => databaseHandlerAdmin.addFeaturedProductAdmin(productId: 'product-1')).called(1);
    });

    test('DeleteFeaturedProductAdmin deletes a featured product', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      when(() => databaseHandlerAdmin.deleteFeaturedProductAdmin(productId: 'product-1')).thenAnswer((_) async {});
      final bloc = buildBloc();
      final states = <DatabaseStateAdmin>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(DatabaseEventDeleteFeaturedProductAdmin(product: product));
      await pumpEventQueue();
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
      await sub.cancel();
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.featuedProductsDeleted,
      ]);
      verify(() => databaseHandlerAdmin.deleteFeaturedProductAdmin(productId: 'product-1')).called(1);
    });

    // Documents current bug: DatabaseEventFlushDataAdmin has no registered handler in DatabaseBlocAdmin.
    test('FlushDataAdmin has no registered handler', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      final bloc = buildBloc();
      expect(() => bloc.add(DatabaseEventFlushDataAdmin()), throwsStateError);
      // Documents current bug: DatabaseBlocAdmin.close() throws LateInitializationError (_authSubscription is never assigned).
      try {
        await bloc.close();
      } catch (_) {}
    });

    test('AddProductAdmin emits productsNotAdded when the handler throws', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      product = makeProduct(id: 'product-1');
      final error = Exception('add product failed');
      when(() => databaseHandlerAdmin.addProductAdmin(product: product)).thenThrow(error);
      final states = <DatabaseStateAdmin>[];
      late final StreamSubscription<DatabaseStateAdmin> sub;
      final errors = await runWithUnhandledErrors(() async {
        final bloc = buildBloc();
        sub = bloc.stream.listen(states.add);
        bloc.add(DatabaseEventAddProductAdmin(product: product));
        await pumpEventQueue();
      });
      addTearDown(sub.cancel);
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.productsNotAdded,
      ]);
      expect(errors, contains(same(error)));
      verify(() => databaseHandlerAdmin.addProductAdmin(product: product)).called(1);
    });

    test('AddCurrenciesAdmin emits currenciesNotAdded when the handler throws', () async {
      databaseHandlerAdmin = MockAdminInnerDatabaseHandler();
      authInterface = MockAuthInnerInterface();
      currencies = makeCurrencies();
      final error = Exception('add currencies failed');
      when(() => databaseHandlerAdmin.addCurrenciesAdmin(currencies: currencies)).thenThrow(error);
      final states = <DatabaseStateAdmin>[];
      late final StreamSubscription<DatabaseStateAdmin> sub;
      final errors = await runWithUnhandledErrors(() async {
        final bloc = buildBloc();
        sub = bloc.stream.listen(states.add);
        bloc.add(DatabaseEventAddCurrenciesAdmin(currencies: currencies));
        await pumpEventQueue();
      });
      addTearDown(sub.cancel);
      expect(states.map((s) => s.states), [
        DatabaseStatesAdmin.dbLoading,
        DatabaseStatesAdmin.currenciesNotAdded,
      ]);
      expect(errors, contains(same(error)));
      verify(() => databaseHandlerAdmin.addCurrenciesAdmin(currencies: currencies)).called(1);
    });
  });
}
