import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the store search bar needs, derived once per layout sync.
@immutable
class StoreSearchBarLayout extends Equatable {
  /// Padding that keeps the collapsed bar clear of the page edge.
  final double collapsedRightPadding;

  /// Left margin of the collapsed search text.
  final double collapsedTextLeftMargin;
  final double collapsedTextRightPadding;

  /// Maximum width of the collapsed search text before it ellipsizes.
  final double collapsedTextMaxWidth;

  /// Font size of the search text and suggestions.
  final double textFontSize;

  /// Height of the search bar, matching the main screen top bar.
  final double barHeight;

  final double barCornerRadius;
  final double searchIconSize;
  final double searchIconMinWidth;

  /// Padding that keeps the expanded bar clear of the page edge.
  final double expandedRightPadding;
  final double expandedWidth;
  final double suggestionsMaxHeight;

  const StoreSearchBarLayout({
    required this.collapsedRightPadding,
    required this.collapsedTextLeftMargin,
    required this.collapsedTextRightPadding,
    required this.collapsedTextMaxWidth,
    required this.textFontSize,
    required this.barHeight,
    required this.barCornerRadius,
    required this.searchIconSize,
    required this.searchIconMinWidth,
    required this.expandedRightPadding,
    required this.expandedWidth,
    required this.suggestionsMaxHeight,
  });

  factory StoreSearchBarLayout.fromAppLayout(AppLayoutState layout) {
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double barHeight = math.max(0.0, layout.appBarHeight);

    return StoreSearchBarLayout(
      collapsedRightPadding: screenEdgePadding,
      collapsedTextLeftMargin: screenEdgePadding,
      collapsedTextRightPadding: layout.standardPadding / 4,
      collapsedTextMaxWidth: math.max(0.0, layout.width / 2 - barHeight - screenEdgePadding * 2),
      textFontSize: layout.mediumFontSize,
      barHeight: barHeight,
      barCornerRadius: barHeight / 2,
      searchIconSize: barHeight * 0.6,
      searchIconMinWidth: barHeight,
      expandedRightPadding: screenEdgePadding,
      expandedWidth: math.max(0.0, layout.width - screenEdgePadding * 2),
      suggestionsMaxHeight: layout.width * 0.8,
    );
  }

  @override
  List<Object?> get props => [
    collapsedRightPadding,
    collapsedTextLeftMargin,
    collapsedTextRightPadding,
    collapsedTextMaxWidth,
    textFontSize,
    barHeight,
    barCornerRadius,
    searchIconSize,
    searchIconMinWidth,
    expandedRightPadding,
    expandedWidth,
    suggestionsMaxHeight,
  ];
}

@immutable
class StoreSearchBarState extends Equatable {
  final bool isSearchOpen;
  final bool keyBoardEventCanBeTriggered;
  final List<Product>? products;
  final StoreSearchBarLayout layout;

  const StoreSearchBarState({
    this.isSearchOpen = false,
    this.products,
    this.keyBoardEventCanBeTriggered = false,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory StoreSearchBarState.fromLayout(AppLayoutState layout) => StoreSearchBarState(
    layout: StoreSearchBarLayout.fromAppLayout(layout),
  );

  StoreSearchBarState copyWith({
    bool? isSearchOpen,
    List<Product>? products,
    bool? keyBoardEventCanBeTriggered,
    StoreSearchBarLayout? layout,
  }) => StoreSearchBarState(
    isSearchOpen: isSearchOpen ?? this.isSearchOpen,
    products: products ?? this.products,
    keyBoardEventCanBeTriggered: keyBoardEventCanBeTriggered ?? this.keyBoardEventCanBeTriggered,
    layout: layout ?? this.layout,
  );

  @override
  List<Object?> get props => [
    isSearchOpen,
    products,
    keyBoardEventCanBeTriggered,
    layout,
  ];
}

class StoreSearchBarCubit extends Cubit<StoreSearchBarState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  StoreSearchBarCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(StoreSearchBarState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: StoreSearchBarLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
