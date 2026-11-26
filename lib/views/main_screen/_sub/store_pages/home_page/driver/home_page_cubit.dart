import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_state.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// Layout values for the home page's featured bento, derived once per layout
/// sync so the view can render them without any arithmetic.
@immutable
class HomeFeaturedLayout extends Equatable {
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

  const HomeFeaturedLayout({
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
  });

  factory HomeFeaturedLayout.fromAppLayout(AppLayoutState layout) {
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerWidth = math.max(0.0, layout.width - layout.screenEdgePadding * 2);
    final double innerWidth = math.max(0.0, outerWidth - padding * 2);
    final double colWidth = math.max(0.0, (innerWidth - padding) / 2);
    final double topRowHeight = colWidth * 1.5 + 2;
    final double smallCardHeight = colWidth * 1.25;
    final double bannerFontSize = (math.max(0.0, topRowHeight - smallCardHeight - padding) * 0.34).clamp(10.0, 16.0).toDouble();

    return HomeFeaturedLayout(
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
      smallCardPadding: 4.0,
      bannerPadding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      bannerFontSize: bannerFontSize,
    );
  }

  @override
  List<Object?> get props => [
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
  ];
}

@immutable
class HomePageState extends Equatable {
  final List<Product>? featuredProducts;
  final List<Product>? userPreferences;
  final bool isLoading;
  final double outerCornerRadius;
  final double containerWidth;
  final double containerPadding;
  final EdgeInsets pagePadding;
  final double topPadding;
  final HomeFeaturedLayout featuredLayout;
  final bool isInitialized;

  const HomePageState({
    this.featuredProducts,
    this.userPreferences,
    this.isLoading = true,
    this.isInitialized = false,
    required this.outerCornerRadius,
    required this.containerWidth,
    required this.containerPadding,
    required this.pagePadding,
    required this.topPadding,
    required this.featuredLayout,
  });

  /// Builds the page state and every derived layout value from [layout].
  factory HomePageState.fromLayout(AppLayoutState layout) => HomePageState(
    containerWidth: layout.width - layout.screenEdgePadding * 2,
    outerCornerRadius: layout.cornerRadius,
    containerPadding: layout.standardPadding,
    pagePadding: EdgeInsets.fromLTRB(
      layout.screenEdgePadding,
      layout.topPadding + layout.screenEdgePadding,
      layout.screenEdgePadding,
      layout.bottomPadding + layout.screenEdgePadding,
    ),
    topPadding: layout.topPadding,
    featuredLayout: HomeFeaturedLayout.fromAppLayout(layout),
  );

  HomePageState copyWith({
    List<Product>? featuredProducts,
    List<Product>? userPreferences,
    double? outerCornerRadius,
    double? containerWidth,
    double? containerPadding,
    EdgeInsets? pagePadding,
    double? topPadding,
    HomeFeaturedLayout? featuredLayout,
    bool? isLoading,
    bool? isInitialized,
  }) => HomePageState(
    featuredProducts: featuredProducts ?? this.featuredProducts,
    userPreferences: userPreferences ?? this.userPreferences,
    isLoading: isLoading ?? this.isLoading,
    isInitialized: isInitialized ?? this.isInitialized,
    containerWidth: containerWidth ?? this.containerWidth,
    outerCornerRadius: outerCornerRadius ?? this.outerCornerRadius,
    containerPadding: containerPadding ?? this.containerPadding,
    pagePadding: pagePadding ?? this.pagePadding,
    topPadding: topPadding ?? this.topPadding,
    featuredLayout: featuredLayout ?? this.featuredLayout,
  );

  @override
  List<Object?> get props => [
    featuredProducts,
    userPreferences,
    isLoading,
    isInitialized,
    outerCornerRadius,
    containerWidth,
    containerPadding,
    pagePadding,
    topPadding,
    featuredLayout,
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
    HomePageState.fromLayout(layout).copyWith(
      featuredProducts: state.featuredProducts,
      userPreferences: state.userPreferences,
      isLoading: state.isLoading,
      isInitialized: state.isInitialized,
    ),
  );

  @override
  Future<void> close() {
    _dbSubscription.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
