import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/driver/store_page_cubit.dart';
import 'package:flutter/widgets.dart';
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

  AppLayoutCubit buildLayoutCubit() {
    return AppLayoutCubit(
      observeBinding: false,
      metricsReader: () => (width: 800, topPadding: 0, bottomPadding: 0),
    );
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
    test('syncs layout metrics from AppLayoutCubit', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = HomePageCubit(dbBloc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      expect(cubit.state.layout.outerWidth, closeTo(512 - 512 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.padding, closeTo(512 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(512 * config.cornerRadiusCoeff, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(cubit.state.layout.outerWidth, closeTo(300 - 300 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.padding, closeTo(300 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(300 * config.cornerRadiusCoeff, 1e-9));
    });

    test('precalculates featured layout and page padding on layout sync', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = HomePageCubit(dbBloc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      void expectMatchesState() {
        final layout = cubit.state.layout;
        final padding = layout.padding;
        final innerWidth = layout.outerWidth - padding * 2;
        final colWidth = (innerWidth - padding) / 2;

        expect(layout.gap, closeTo(padding, 1e-9));
        expect(layout.innerWidth, closeTo(innerWidth, 1e-9));
        expect(layout.colWidth, closeTo(colWidth, 1e-9));
        expect(layout.topRowHeight, closeTo(colWidth * 1.5 + 2, 1e-9));
        expect(layout.smallCardHeight, closeTo(colWidth * 1.25, 1e-9));
        expect(layout.horizontalHeight, closeTo(colWidth, 1e-9));
        expect(layout.innerCornerRadius, closeTo(layout.outerCornerRadius - padding, 1e-9));
        expect(layout.smallCardPadding, 4.0);
        expect(layout.bannerPadding, EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2));
        expect(layout.pagePadding.left, closeTo(layout.pagePadding.right, 1e-9));
        expect(layout.topPadding, 0.0);
      }

      expectMatchesState();

      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expectMatchesState();
    });

    test('clamps the page width to the configured minimum', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = HomePageCubit(dbBloc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      layoutCubit.updateMetrics(rawWidth: 80);
      await pumpEventQueue();

      const AppLayoutConfig config = AppLayoutConfig();
      expect(cubit.state.layout.outerWidth, closeTo(128 - 128 * config.screenEdgePaddingCoeff * 2, 1e-9));
    });

    test('syncs featuredProducts and sets isInitialized from DatabaseBloc', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = HomePageCubit(dbBloc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      dbBloc.add(DatabaseEventInitialize(currentUser: makeAuthUser()));
      await pumpEventQueue();

      expect(cubit.state.isInitialized, true);
      expect(cubit.state.featuredProducts, [products.first]);
    });

    test('close cancels subscriptions: no state is emitted from DatabaseBloc afterwards', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = HomePageCubit(dbBloc: dbBloc, layoutCubit: layoutCubit);
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
      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(cubit.state.isInitialized, isTrue);
    });
  });
}
