import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_state.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// Every layout value the home page needs, derived once per layout sync so the
/// views can render them without any arithmetic.
@immutable
class HomePageLayout extends Equatable {
  /// Padding from the page edges, including the platform safe area.
  final EdgeInsets pagePadding;

  /// Platform safe area at the top of the screen.
  final double topPadding;

  /// Outer card width, equal to the page's content width.
  final double outerWidth;
  final double outerCornerRadius;

  /// Outer frame padding, also reused as the inner gutter between tiles.
  final double padding;
  final double gap;

  /// Width available inside [padding].
  final double innerWidth;

  /// Concentric radius for tiles nested one [padding] step inside the card.
  final double innerCornerRadius;

  /// Width of each half-width tile.
  final double colWidth;

  /// Height of the tall (right) card, matching `ProductCardDriver`.
  final double topRowHeight;

  /// Height of the short (left) card, matching `ProductCardSmallDriver`.
  final double smallCardHeight;

  /// Height of the bottom horizontal card.
  final double horizontalHeight;

  /// Inner image inset used by the small card, matching `ProductCardDriver`.
  final double smallCardPadding;

  final EdgeInsets bannerPadding;
  final double bannerFontSize;

  /// Padding around the divider between the featured and favorite sections.
  final EdgeInsets dividerPadding;

  const HomePageLayout({
    required this.pagePadding,
    required this.topPadding,
    required this.outerWidth,
    required this.outerCornerRadius,
    required this.padding,
    required this.gap,
    required this.innerWidth,
    required this.innerCornerRadius,
    required this.colWidth,
    required this.topRowHeight,
    required this.smallCardHeight,
    required this.horizontalHeight,
    required this.smallCardPadding,
    required this.bannerPadding,
    required this.bannerFontSize,
    required this.dividerPadding,
  });

  factory HomePageLayout.fromAppLayout(AppLayoutState layout) {
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerWidth = math.max(0.0, layout.width - layout.screenEdgePadding * 2);
    final double innerWidth = math.max(0.0, outerWidth - padding * 2);
    final double colWidth = math.max(0.0, (innerWidth - padding) / 2);
    final double topRowHeight = colWidth * 1.5 + 2;
    final double smallCardHeight = colWidth * 1.25;

    return HomePageLayout(
      pagePadding: EdgeInsets.fromLTRB(
        layout.screenEdgePadding,
        layout.pageTopPadding + layout.screenEdgePadding,
        layout.screenEdgePadding,
        layout.pageBottomPadding + layout.screenEdgePadding,
      ),
      topPadding: layout.pageTopPadding,
      outerWidth: outerWidth,
      outerCornerRadius: math.max(0.0, layout.cornerRadius),
      padding: padding,
      gap: padding,
      innerWidth: innerWidth,
      innerCornerRadius: layout.innerCornerRadius(padding),
      colWidth: colWidth,
      topRowHeight: topRowHeight,
      smallCardHeight: smallCardHeight,
      horizontalHeight: colWidth,
      smallCardPadding: padding / 2,
      bannerPadding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      bannerFontSize: layout.mediumFontSize,
      dividerPadding: EdgeInsets.symmetric(horizontal: layout.screenEdgePadding, vertical: padding * 0.75),
    );
  }

  @override
  List<Object?> get props => [
    pagePadding,
    topPadding,
    outerWidth,
    outerCornerRadius,
    padding,
    gap,
    innerWidth,
    innerCornerRadius,
    colWidth,
    topRowHeight,
    smallCardHeight,
    horizontalHeight,
    smallCardPadding,
    bannerPadding,
    bannerFontSize,
    dividerPadding,
  ];
}

@immutable
class HomePageState extends Equatable {
  final List<Product>? featuredProducts;
  final List<Product>? userPreferences;
  final bool isLoading;
  final bool isInitialized;
  final HomePageLayout layout;

  const HomePageState({
    this.featuredProducts,
    this.userPreferences,
    this.isLoading = true,
    this.isInitialized = false,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory HomePageState.fromLayout(AppLayoutState layout) => HomePageState(
    layout: HomePageLayout.fromAppLayout(layout),
  );

  HomePageState copyWith({
    List<Product>? featuredProducts,
    List<Product>? userPreferences,
    bool? isLoading,
    bool? isInitialized,
    HomePageLayout? layout,
  }) => HomePageState(
    featuredProducts: featuredProducts ?? this.featuredProducts,
    userPreferences: userPreferences ?? this.userPreferences,
    isLoading: isLoading ?? this.isLoading,
    isInitialized: isInitialized ?? this.isInitialized,
    layout: layout ?? this.layout,
  );

  @override
  List<Object?> get props => [
    featuredProducts,
    userPreferences,
    isLoading,
    isInitialized,
    layout,
  ];
}

class HomePageCubit extends Cubit<HomePageState> {
  final DatabaseBloc _dbBloc;
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _dbSubscription;
  late final StreamSubscription _layoutSubscription;

  HomePageCubit({required DatabaseBloc dbBloc, required AppLayoutCubit layoutCubit})
    : _dbBloc = dbBloc,
      _appLayoutCubit = layoutCubit,
      super(HomePageState.fromLayout(layoutCubit.state)) {
    _dbSubscription = _dbBloc.stream.listen((dbState) {
      _syncDabaseData(dbState);
    });
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncDabaseData(DatabaseState dbState) {
    if (dbState.states == DatabaseStates.initialized) {
      emit(state.copyWith(isInitialized: true));
    }
    emit(state.copyWith(featuredProducts: _dbBloc.state.featuredProducts));
    emit(state.copyWith(userPreferences: _dbBloc.state.userPreferences));
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: HomePageLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _dbSubscription.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
