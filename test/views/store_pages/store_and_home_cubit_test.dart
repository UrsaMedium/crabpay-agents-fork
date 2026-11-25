import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/driver/store_page_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final products = [
    makeProduct(id: 'product-1'),
    makeProduct(id: 'product-2', name: 'Product Two'),
  ];

  DatabaseBloc buildDbBloc() {
    final authInterface = MockAuthInnerInterface();
    when(() => authInterface.userStream).thenAnswer((_) => Stream.empty());
    final dbHandler = MockInnerDatabaseHandler();
    when(() => dbHandler.fetchAllProducts()).thenAnswer((_) async => products);
    when(() => dbHandler.fetchAllFeaturedProducts()).thenAnswer((_) async => ['product-1']);
    when(() => dbHandler.fetchUserPreferences(userId: any(named: 'userId'))).thenAnswer((_) async => []);
    final dbBloc = DatabaseBloc(databaseHandler: dbHandler, authInnerface: authInterface);
    dbBloc.add(DatabaseEventInitialize(currentUser: makeAuthUser()));
    return dbBloc;
  }

  group('StorePageCubit', () {
    test('setLayouts caps width at 600 with radius 5% and padding 2%', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);

      cubit.setLayouts(containerWidth: 800);
      expect(cubit.state.containerWidth, 600);
      expect(cubit.state.outerCornerRadius, 30);
      expect(cubit.state.containerPadding, 12);

      cubit.setLayouts(containerWidth: 300);
      expect(cubit.state.containerWidth, 300);
      expect(cubit.state.outerCornerRadius, 15);
      expect(cubit.state.containerPadding, 6);
    });

    test('syncs products and productsToShow from DatabaseBloc', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state.products, products);
      expect(cubit.state.productsToShow, products);
    });

    test('setFilteredList falls back to all products when empty', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.setFilteredList(const []);
      expect(cubit.state.productsToShow, products);
    });

    test('setFilteredList shows non-empty filters', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);
      await pumpEventQueue();

      final filtered = [products.first];
      cubit.setFilteredList(filtered);
      expect(cubit.state.productsToShow, filtered);
    });

    test('setHeroFlightTrue/False toggles the flying state', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);

      cubit.setHeroFlightTrue('hero-product');
      expect(cubit.state.isHeroFlies, true);
      expect(cubit.state.whoFlies, 'hero-product');

      cubit.setHeroFlightFalse();
      expect(cubit.state.isHeroFlies, false);
    });

    test('close cancels subscriptions: no state is emitted from DatabaseBloc afterwards', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final cubit = StorePageCubit(dbBLoc: dbBloc);
      addTearDown(cubit.close);
      final emitted = <StorePageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(cubit.isClosed, false);
      await cubit.close();
      expect(cubit.isClosed, true);

      dbBloc.add(DatabaseEventFetchAllProducts());
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(cubit.state.products, products);
    });
  });

  group('HomePageCubit', () {
    test('setLayouts caps width at 600 with radius 5% and padding 2%', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final cubit = HomePageCubit(dbBloc: dbBloc);
      addTearDown(cubit.close);

      cubit.setLayouts(containerWidth: 800);
      expect(cubit.state.containerWidth, 600);
      expect(cubit.state.outerCornerRadius, 30);
      expect(cubit.state.containerPadding, 12);

      cubit.setLayouts(containerWidth: 300);
      expect(cubit.state.containerWidth, 300);
      expect(cubit.state.outerCornerRadius, 15);
      expect(cubit.state.containerPadding, 6);
    });

    test('syncs featuredProducts and sets isInitialized from DatabaseBloc', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final cubit = HomePageCubit(dbBloc: dbBloc);
      addTearDown(cubit.close);
      dbBloc.add(DatabaseEventInitialize(currentUser: makeAuthUser()));
      await pumpEventQueue();

      expect(cubit.state.isInitialized, true);
      expect(cubit.state.featuredProducts, [products.first]);
    });

    test('close cancels subscriptions: no state is emitted from DatabaseBloc afterwards', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final cubit = HomePageCubit(dbBloc: dbBloc);
      addTearDown(cubit.close);
      final emitted = <HomePageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      emitted.clear();

      expect(cubit.isClosed, false);
      await cubit.close();
      expect(cubit.isClosed, true);

      dbBloc.add(DatabaseEventFetchAllProducts());
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(cubit.state.isInitialized, isTrue);
    });
  });
}
