import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_category_view/store_category_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_page_search/driver/store_search_bar_cubit.dart';
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
    test('syncs layout metrics from AppLayoutCubit', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      expect(cubit.state.layout.pageWidth, closeTo(512, 1e-9));
      expect(cubit.state.layout.outerWidth, closeTo(512 - 512 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.padding, closeTo(512 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(512 * config.cornerRadiusCoeff, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      expect(cubit.state.layout.pageWidth, closeTo(360, 1e-9));
      expect(cubit.state.layout.outerWidth, closeTo(360 - 360 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.padding, closeTo(360 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(360 * config.cornerRadiusCoeff, 1e-9));
      expect(cubit.state.layout.topPadding, closeTo(layoutCubit.state.pageTopPadding, 1e-9));
      expect(cubit.state.layout.bottomPadding, closeTo(layoutCubit.state.pageBottomPadding, 1e-9));
    });

    test('precalculates store layout values on layout sync', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      final layout = cubit.state.layout;
      expect(
        layout.listTopSpacerHeight,
        closeTo(layout.topPadding + layoutCubit.state.appBarHeight + layout.padding * 2, 1e-9),
      );
      expect(layout.listBottomSpacerHeight, closeTo(layout.bottomPadding + layout.padding, 1e-9));
      expect(layout.searchBarPadding.top, closeTo(layout.topPadding + layout.padding, 1e-9));
      expect(layout.listHorizontalPadding.left, closeTo(layout.listHorizontalPadding.right, 1e-9));
      expect(layout.categoryCarouselHeight, closeTo(layout.outerWidth * 1.6 / 8, 1e-9));
      expect(layout.categoryProductWidth, closeTo(layout.outerWidth / 8, 1e-9));
      expect(layout.categoryCarouselPadding, EdgeInsets.all(layout.outerCornerRadius / 3));
      expect(layout.categoryCardMargin.bottom, closeTo(layout.listHorizontalPadding.left * 2, 1e-9));
      expect(layout.categoryTitleFontSize, inInclusiveRange(16.0, 22.0));
    });

    test('syncs products and productsToShow from DatabaseBloc', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state.products, products);
      expect(cubit.state.productsToShow, products);
    });

    test('setFilteredList falls back to all products when empty', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.setFilteredList(const []);
      expect(cubit.state.productsToShow, products);
    });

    test('setFilteredList shows non-empty filters', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
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
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      cubit.setHeroFlightTrue('hero-product');
      expect(cubit.state.isHeroFlies, true);
      expect(cubit.state.whoFlies, 'hero-product');

      cubit.setHeroFlightFalse();
      expect(cubit.state.isHeroFlies, false);
    });

    test('close cancels subscriptions: no state is emitted from DatabaseBloc or AppLayoutCubit afterwards', () async {
      final dbBloc = buildDbBloc();
      addTearDown(dbBloc.close);
      await pumpEventQueue();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StorePageCubit(dbBLoc: dbBloc, layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      final emitted = <StorePageState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      expect(cubit.isClosed, false);
      await cubit.close();
      expect(cubit.isClosed, true);

      dbBloc.add(DatabaseEventFetchAllProducts());
      layoutCubit.updateMetrics(rawWidth: 300);
      await pumpEventQueue();

      expect(emitted, isEmpty);
      expect(cubit.state.products, products);
    });
  });

  group('StoreSearchBarCubit', () {
    test('derives the search bar layout and syncs on layout changes', () async {
      const AppLayoutConfig config = AppLayoutConfig();
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StoreSearchBarCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      expect(cubit.state.layout.expandedWidth, closeTo(512 - 512 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.barHeight, closeTo(layoutCubit.state.appBarHeight, 1e-9));
      expect(cubit.state.layout.barCornerRadius, closeTo(cubit.state.layout.barHeight / 2, 1e-9));

      layoutCubit.updateMetrics(rawWidth: 360);
      await pumpEventQueue();

      expect(cubit.state.layout.expandedWidth, closeTo(360 - 360 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.collapsedTextMaxWidth, closeTo(360 / 2 - 110, 1e-9));
      expect(cubit.state.layout.barHeight, closeTo(layoutCubit.state.appBarHeight, 1e-9));
    });

    test('close cancels layout updates', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StoreSearchBarCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      final emitted = <StoreSearchBarState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.close();
      layoutCubit.updateMetrics(rawWidth: 360);
      await pumpEventQueue();

      expect(emitted, isEmpty);
    });
  });

  group('StoreCategoryCubit', () {
    test('derives the category layout and syncs on layout changes', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StoreCategoryCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);

      void expectMatchesState() {
        final layout = cubit.state.layout;
        expect(layout.pageWidth, closeTo(layout.outerWidth + layout.gridPadding.left + layout.gridPadding.right, 1e-9));
        expect(layout.cardWidth, closeTo((layout.outerWidth - layout.itemTopSpacing) / 2, 1e-9));
        expect(layout.columnHalfGap, closeTo(layout.itemTopSpacing / 2, 1e-9));
        expect(layout.gridPadding.left, closeTo(layout.gridPadding.right, 1e-9));
      }

      expectMatchesState();

      layoutCubit.updateMetrics(rawWidth: 360, topPadding: 24, bottomPadding: 34);
      await pumpEventQueue();

      expectMatchesState();
      expect(cubit.state.layout.topPadding, closeTo(layoutCubit.state.pageTopPadding, 1e-9));
      expect(cubit.state.layout.bottomPadding, closeTo(layoutCubit.state.pageBottomPadding, 1e-9));
      expect(
        cubit.state.layout.staggeredFirstItemTopOffset,
        closeTo(cubit.state.layout.gridPadding.left + layoutCubit.state.appBarHeight, 1e-9),
      );
    });

    test('close cancels layout updates', () async {
      final layoutCubit = buildLayoutCubit();
      addTearDown(layoutCubit.close);
      final cubit = StoreCategoryCubit(layoutCubit: layoutCubit);
      addTearDown(cubit.close);
      final emitted = <StoreCategoryState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.close();
      layoutCubit.updateMetrics(rawWidth: 360);
      await pumpEventQueue();

      expect(emitted, isEmpty);
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

      layoutCubit.updateMetrics(rawWidth: 400);
      await pumpEventQueue();

      expect(cubit.state.layout.outerWidth, closeTo(400 - 400 * config.screenEdgePaddingCoeff * 2, 1e-9));
      expect(cubit.state.layout.padding, closeTo(400 * config.standardPaddingCoeff, 1e-9));
      expect(cubit.state.layout.outerCornerRadius, closeTo(400 * config.cornerRadiusCoeff, 1e-9));
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
        expect(layout.topPadding, closeTo(layoutCubit.state.pageTopPadding, 1e-9));
        expect(
          layout.pagePadding.top,
          closeTo(layoutCubit.state.pageTopPadding + layoutCubit.state.screenEdgePadding, 1e-9),
        );
        expect(
          layout.pagePadding.bottom,
          closeTo(layoutCubit.state.pageBottomPadding + layoutCubit.state.screenEdgePadding, 1e-9),
        );
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
      expect(cubit.state.layout.outerWidth, closeTo(320 - 320 * config.screenEdgePaddingCoeff * 2, 1e-9));
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
