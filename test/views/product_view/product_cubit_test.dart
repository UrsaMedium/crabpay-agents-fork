import 'dart:ui';

import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_fields_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_event.dart';
import 'package:crabpay/views/main_screen/_sub/product_view/driver/product_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const Color tint = Color(0xFFFFC107);

  ({ProductViewCubit cubit, DatabaseBloc dbBloc, CartBloc cartBloc, MockInnerDatabaseHandler dbHandler, MockInnerCartHandler cartHandler}) buildParts({
    required List<ProductField> productFields,
  }) {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final dbHandler = MockInnerDatabaseHandler();
    final cartHandler = MockInnerCartHandler();
    final lifecycle = FakeAppLifecycleService();
    addTearDown(lifecycle.dispose);
    final dbBloc = DatabaseBloc(databaseHandler: dbHandler, authInnerface: authInterface);
    final cartBloc = CartBloc(
      cartHandler: cartHandler,
      authInterface: authInterface,
      appLifecycleService: lifecycle,
    );
    final cubit = ProductViewCubit(
      databaseBloc: dbBloc,
      cartBloc: cartBloc,
      isAdmin: true,
      isAnonymous: false,
      userId: 'user-1',
      product: makeProduct(),
      productFields: productFields,
      tintColor: tint,
    );
    addTearDown(dbBloc.close);
    addTearDown(cartBloc.close);
    addTearDown(cubit.close);
    return (cubit: cubit, dbBloc: dbBloc, cartBloc: cartBloc, dbHandler: dbHandler, cartHandler: cartHandler);
  }

  ProductViewCubit buildCubit({required List<ProductField> productFields}) => buildParts(productFields: productFields).cubit;

  group('ProductViewCubit constructor', () {
    test('stores product fields and sets price function values', () {
      final imageField = makeProductField(
        id: 'field-1',
        fieldName: 'Size',
        isPriceImage: true,
        priceImages: {'small': 50, 'big': 200},
      );
      final cubit = buildCubit(productFields: [imageField]);

      expect(cubit.state.isPageReady, false);
      expect(cubit.state.isFavoriteLoading, false);
      expect(cubit.state.isFavorite, false);
      expect(cubit.state.productFields, [imageField]);
      expect(cubit.state.amountOfRequiredFields, 1);
      expect(cubit.state.priceFunction, {'small': 50, 'big': 200});
      expect(cubit.state.tintColor, tint);
    });
  });

  group('ProductViewCubit.onUserInput', () {
    test('linear price math multiplies numeric input by values.first', () {
      final imageField = makeProductField(
        id: 'linear-field',
        fieldName: 'Quantity',
        handler: 'InputField',
        isPriceImage: true,
        priceImages: {'per-unit': 10},
      );
      final cubit = buildCubit(productFields: [imageField]);

      cubit.onUserInput(fieldName: 'Quantity', dataReceived: '3');
      expect(cubit.state.precalculatedPrice, 30);

      // Non-numeric input yields 0, but ProductViewState.copyWith keeps the previous
      // precalculatedPrice because it maps null to `this.precalculatedPrice`.
      // Documents current bug: ProductViewState.copyWith cannot clear precalculatedPrice to null, so invalid input leaves a stale price.
      cubit.onUserInput(fieldName: 'Quantity', dataReceived: 'not-a-number');
      expect(cubit.state.precalculatedPrice, 30);
    });

    test('discrete priceFunction lookup returns the mapped value', () {
      final imageField = makeProductField(
        id: 'discrete-field',
        fieldName: 'Size',
        isPriceImage: true,
        priceImages: {'small': 50, 'big': 200},
      );
      final cubit = buildCubit(productFields: [imageField]);

      cubit.onUserInput(fieldName: 'Size', dataReceived: 'small');
      expect(cubit.state.precalculatedPrice, 50);

      // Unknown key yields 0, but ProductViewState.copyWith keeps the previous
      // precalculatedPrice because it maps null to `this.precalculatedPrice`.
      // Documents current bug: ProductViewState.copyWith cannot clear precalculatedPrice to null, so invalid input leaves a stale price.
      cubit.onUserInput(fieldName: 'Size', dataReceived: 'huge');
      expect(cubit.state.precalculatedPrice, 50);
    });

    test('empty input for a required field does not invalidate it (dead statement at product_cubit.dart:389)', () {
      final cubit = buildCubit(
        productFields: [
          makeProductField(id: 'field-1', fieldName: 'Region'),
          makeProductField(id: 'field-2', fieldName: 'Size', isPriceImage: true, priceImages: {'high': 900}),
        ],
      );

      cubit.onUserInput(fieldName: 'Region', dataReceived: 'EU');
      cubit.onUserInput(fieldName: 'Size', dataReceived: 'high');
      expect(cubit.state.isEveryFieldSatisfied, isTrue);
      expect(cubit.state.precalculatedPrice, 900);

      // The `isEveryFieldSatisfied;` statement in the empty-value loop does nothing;
      // the flag stays true and the stale price remains because copyWith maps null to the old value.
      // Documents current bug: ProductViewState.copyWith cannot clear precalculatedPrice to null, so invalid input leaves a stale price.
      cubit.onUserInput(fieldName: 'Size', dataReceived: '');
      expect(cubit.state.retrievedData!['Size'], isEmpty);
      expect(cubit.state.isEveryFieldSatisfied, isTrue);
      expect(cubit.state.precalculatedPrice, 900);
    });

    test('isEveryFieldSatisfied tracks all required fields', () {
      final cubit = buildCubit(
        productFields: [
          makeProductField(id: 'field-1', fieldName: 'Region'),
          makeProductField(id: 'field-2', fieldName: 'Details', isPriceImage: true, priceImages: {'high': 900}),
        ],
      );

      cubit.onUserInput(fieldName: 'Region', dataReceived: 'EU');
      expect(cubit.state.isEveryFieldSatisfied, isFalse);

      cubit.onUserInput(fieldName: 'Details', dataReceived: 'high');
      expect(cubit.state.isEveryFieldSatisfied, isTrue);
    });
  });

  group('ProductViewCubit layout setters', () {
    test('setLayoutBoundries computes descPosition and buyPosition', () {
      final cubit = buildCubit(productFields: [makeProductField(isPriceImage: true)]);

      cubit.setLayoutBoundries({'height': 800, 'paddingBottom': 40, 'width': 300});

      expect(cubit.state.descPosition, 800 - 40 - 300);
      expect(cubit.state.buyPosition, 800 - 40 - 54);
      expect(cubit.state.descMinPosition, 460);
    });

    test('setFavoriteLoadingStateTrue and setPageReadyTrue flip flags', () {
      final cubit = buildCubit(productFields: [makeProductField(isPriceImage: true)]);

      cubit.setFavoriteLoadingStateTrue();
      expect(cubit.state.isFavoriteLoading, true);

      cubit.setPageReadyTrue();
      expect(cubit.state.isPageReady, true);
    });
  });

  group('ProductViewCubit source bloc syncing', () {
    test('_syncCartData updates itemsInCart from CartBloc', () async {
      final parts = buildParts(productFields: [makeProductField(isPriceImage: true)]);
      when(() => parts.cartHandler.getProductCartItemAmount(any(), any())).thenAnswer((_) async => 4);

      parts.cartBloc.add(CartEventFetchProductCartItemAmount(userId: 'user-1', productId: 'product-1'));
      await pumpEventQueue();

      expect(parts.cubit.state.itemsInCart, 4);
      expect(parts.cubit.state.isCartLoading, false);
    });

    test('_syncDabaseData updates isFavorite from user preference events', () async {
      final parts = buildParts(productFields: [makeProductField(isPriceImage: true)]);
      expect(parts.cubit.state.isFavorite, isFalse);
      when(
        () => parts.dbHandler.addUserPreference(
          userId: any(named: 'userId'),
          productId: any(named: 'productId'),
        ),
      ).thenAnswer((_) async {});

      parts.dbBloc.add(DatabaseEventAddUserPreference(userId: 'user-1', product: makeProduct()));
      await pumpEventQueue();

      expect(parts.cubit.state.isFavorite, isTrue);
      expect(parts.cubit.state.isFavoriteLoading, isFalse);
    });

    test('_syncDabaseData refreshes fields and priceFunction on fieldsFetched', () async {
      final parts = buildParts(productFields: [makeProductField(isPriceImage: true)]);
      final fetchedFields = [
        makeProductField(id: 'fetched-field', fieldName: 'Color', isPriceImage: true, priceImages: {'red': 123}),
      ];
      when(() => parts.dbHandler.fetchProductFields(productId: any(named: 'productId'))).thenAnswer((_) async => fetchedFields);

      parts.dbBloc.add(const DatabaseEventFetchProductFields(productId: 'product-1'));
      await pumpEventQueue();

      expect(parts.cubit.state.productFields, fetchedFields);
      expect(parts.cubit.state.imageField, fetchedFields.first);
      expect(parts.cubit.state.priceFunction, {'red': 123});
      expect(parts.cubit.state.amountOfRequiredFields, 1);
    });
  });

  group('ProductViewCubit.close', () {
    test('cancels subscriptions: no state is emitted from source blocs afterwards', () async {
      final parts = buildParts(productFields: [makeProductField(isPriceImage: true)]);
      final emitted = <ProductViewState>[];
      final subscription = parts.cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(parts.cubit.isClosed, false);
      await parts.cubit.close();
      expect(parts.cubit.isClosed, true);

      when(
        () => parts.dbHandler.addUserPreference(
          userId: any(named: 'userId'),
          productId: any(named: 'productId'),
        ),
      ).thenAnswer((_) async {});
      when(() => parts.cartHandler.getProductCartItemAmount(any(), any())).thenAnswer((_) async => 9);
      parts.dbBloc.add(DatabaseEventAddUserPreference(userId: 'user-1', product: makeProduct()));
      parts.cartBloc.add(CartEventFetchProductCartItemAmount(userId: 'user-1', productId: 'product-1'));
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(parts.cubit.state.isFavorite, isFalse);
      expect(parts.cubit.state.itemsInCart, 0);
    });
  });
}
