import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_state.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the store page needs, derived once per layout sync so the
/// views can render them without any arithmetic.
@immutable
class StorePageLayout extends Equatable {
  /// Platform safe area at the top of the screen.
  final double topPadding;

  /// Platform safe area at the bottom of the screen.
  final double bottomPadding;

  /// Full page width, capped by the app layout.
  final double pageWidth;

  /// Width of the centered content column.
  final double outerWidth;
  final double outerCornerRadius;

  /// Inner content padding.
  final double padding;

  /// Horizontal padding of the product list.
  final EdgeInsets listHorizontalPadding;

  /// Empty space above the first card so it clears the app bar and search bar.
  final double listTopSpacerHeight;

  /// Empty space below the last card so it clears the bottom nav bar.
  final double listBottomSpacerHeight;

  /// Placement of the floating search bar.
  final EdgeInsets searchBarPadding;

  final EdgeInsets categoryCardMargin;
  final EdgeInsets categoryHeaderPadding;
  final double categoryTitleFontSize;
  final double categoryCarouselHeight;
  final EdgeInsets categoryCarouselPadding;
  final double categoryProductWidth;
  final double categoryProductMargin;
  final EdgeInsets categoryMoreButtonOuterPadding;
  final EdgeInsets categoryMoreButtonPadding;
  final double categoryMoreButtonCornerRadius;
  final double categoryMoreButtonFontSize;

  const StorePageLayout({
    required this.topPadding,
    required this.bottomPadding,
    required this.pageWidth,
    required this.outerWidth,
    required this.outerCornerRadius,
    required this.padding,
    required this.listHorizontalPadding,
    required this.listTopSpacerHeight,
    required this.listBottomSpacerHeight,
    required this.searchBarPadding,
    required this.categoryCardMargin,
    required this.categoryHeaderPadding,
    required this.categoryTitleFontSize,
    required this.categoryCarouselHeight,
    required this.categoryCarouselPadding,
    required this.categoryProductWidth,
    required this.categoryProductMargin,
    required this.categoryMoreButtonOuterPadding,
    required this.categoryMoreButtonPadding,
    required this.categoryMoreButtonCornerRadius,
    required this.categoryMoreButtonFontSize,
  });

  factory StorePageLayout.fromAppLayout(AppLayoutState layout) {
    final double topPadding = math.max(0.0, layout.pageTopPadding);
    final double bottomPadding = math.max(0.0, layout.pageBottomPadding);
    final double appBarHeight = math.max(0.0, layout.appBarHeight);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerWidth = math.max(0.0, layout.width - screenEdgePadding * 2);
    final double outerCornerRadius = math.max(0.0, layout.cornerRadius);

    return StorePageLayout(
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      pageWidth: math.max(0.0, layout.width),
      outerWidth: outerWidth,
      outerCornerRadius: outerCornerRadius,
      padding: padding,
      listHorizontalPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding),
      listTopSpacerHeight: topPadding + appBarHeight + padding * 2,
      listBottomSpacerHeight: bottomPadding + padding,
      searchBarPadding: EdgeInsets.only(top: topPadding + padding, left: screenEdgePadding),
      categoryCardMargin: EdgeInsets.only(bottom: screenEdgePadding * 2),
      categoryHeaderPadding: EdgeInsets.only(left: screenEdgePadding, right: screenEdgePadding, top: padding),
      categoryTitleFontSize: layout.bigFontSize,
      categoryCarouselHeight: outerWidth * 1.6 / 8,
      categoryCarouselPadding: EdgeInsets.all(outerCornerRadius / 3),
      categoryProductWidth: outerWidth / 8,
      categoryProductMargin: padding / 4,
      categoryMoreButtonOuterPadding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 4),
      categoryMoreButtonPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding, vertical: padding),
      categoryMoreButtonCornerRadius: layout.cornerRadius,
      categoryMoreButtonFontSize: layout.mediumFontSize,
    );
  }

  @override
  List<Object?> get props => [
    topPadding,
    bottomPadding,
    pageWidth,
    outerWidth,
    outerCornerRadius,
    padding,
    listHorizontalPadding,
    listTopSpacerHeight,
    listBottomSpacerHeight,
    searchBarPadding,
    categoryCardMargin,
    categoryHeaderPadding,
    categoryTitleFontSize,
    categoryCarouselHeight,
    categoryCarouselPadding,
    categoryProductWidth,
    categoryProductMargin,
    categoryMoreButtonOuterPadding,
    categoryMoreButtonPadding,
    categoryMoreButtonCornerRadius,
    categoryMoreButtonFontSize,
  ];
}

@immutable
class StorePageState extends Equatable {
  final bool isHeroFlies;
  final String? whoFlies;
  final List<Product>? filterdProductList;
  final List<Product>? products;
  final List<Product>? productsToShow;
  final StorePageLayout layout;

  const StorePageState({
    this.filterdProductList,
    this.products,
    this.productsToShow,
    this.isHeroFlies = false,
    this.whoFlies,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory StorePageState.fromLayout(AppLayoutState layout) => StorePageState(
    layout: StorePageLayout.fromAppLayout(layout),
  );

  StorePageState copyWith({
    List<Product>? filterdProductList,
    List<Product>? products,
    List<Product>? productsToShow,
    bool? isHeroFlies,
    String? whoFlies,
    StorePageLayout? layout,
  }) {
    return StorePageState(
      filterdProductList: filterdProductList ?? this.filterdProductList,
      products: products ?? this.products,
      productsToShow: productsToShow ?? this.productsToShow,
      isHeroFlies: isHeroFlies ?? this.isHeroFlies,
      whoFlies: whoFlies == null
          ? this.whoFlies
          : whoFlies.isEmpty
          ? null
          : whoFlies,
      layout: layout ?? this.layout,
    );
  }

  @override
  List<Object?> get props => [
    filterdProductList,
    products,
    productsToShow,
    isHeroFlies,
    whoFlies,
    layout,
  ];
}

class StorePageCubit extends Cubit<StorePageState> {
  final DatabaseBloc _dbBloc;
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _dbSubscription;
  late final StreamSubscription _layoutSubscription;
  StorePageCubit({required DatabaseBloc dbBLoc, required AppLayoutCubit layoutCubit})
    : _dbBloc = dbBLoc,
      _appLayoutCubit = layoutCubit,
      super(StorePageState.fromLayout(layoutCubit.state)) {
    final prdtcs = dbBLoc.state.products;
    emit(state.copyWith(products: prdtcs, productsToShow: prdtcs));
    _dbSubscription = _dbBloc.stream.listen((dbState) {
      if (dbState.states == DatabaseStates.productsFetched) {
        emit(
          state.copyWith(
            products: dbState.products,
            productsToShow: (state.filterdProductList?.isEmpty ?? true) ? dbState.products : state.filterdProductList,
          ),
        );
      }
    });
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: StorePageLayout.fromAppLayout(layout)),
  );

  void setFilteredList(List<Product> filteredList) {
    if (filteredList.isEmpty) {
      emit(state.copyWith(productsToShow: state.products));
    } else {
      emit(state.copyWith(productsToShow: filteredList));
    }
  }

  void setHeroFlightTrue(String whoFlies) {
    emit(state.copyWith(isHeroFlies: true, whoFlies: whoFlies));
  }

  void setHeroFlightFalse() {
    emit(state.copyWith(isHeroFlies: false, whoFlies: ''));
  }

  @override
  Future<void> close() {
    _dbSubscription.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
