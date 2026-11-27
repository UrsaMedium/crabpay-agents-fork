import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the category view needs, derived once per layout sync.
@immutable
class StoreCategoryLayout extends Equatable {
  /// Platform safe area at the top of the screen.
  final double topPadding;

  /// Platform safe area at the bottom of the screen.
  final double bottomPadding;

  /// Full page width, capped by the app layout.
  final double pageWidth;

  /// Width of the centered content column.
  final double outerWidth;

  /// Padding around the product grid, including the platform safe area.
  final EdgeInsets gridPadding;

  /// Half of the gutter between the two product columns.
  final double columnHalfGap;

  /// Vertical spacing between cards in a column.
  final double itemTopSpacing;

  /// Extra top offset for the first card of the right column so the columns
  /// look staggered.
  final double staggeredFirstItemTopOffset;

  /// Width of each product card.
  final double cardWidth;
  final double cardCornerRadius;

  /// Placement of the floating search bar.
  final EdgeInsets searchBarPadding;

  const StoreCategoryLayout({
    required this.topPadding,
    required this.bottomPadding,
    required this.pageWidth,
    required this.outerWidth,
    required this.gridPadding,
    required this.columnHalfGap,
    required this.itemTopSpacing,
    required this.staggeredFirstItemTopOffset,
    required this.cardWidth,
    required this.cardCornerRadius,
    required this.searchBarPadding,
  });

  factory StoreCategoryLayout.fromAppLayout(AppLayoutState layout) {
    final double topPadding = math.max(0.0, layout.pageTopPadding);
    final double bottomPadding = math.max(0.0, layout.pageBottomPadding);
    final double appBarHeight = math.max(0.0, layout.appBarHeight);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerWidth = math.max(0.0, layout.width - screenEdgePadding * 2);

    return StoreCategoryLayout(
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      pageWidth: math.max(0.0, layout.width),
      outerWidth: outerWidth,
      gridPadding: EdgeInsets.fromLTRB(
        screenEdgePadding,
        topPadding + padding,
        screenEdgePadding,
        bottomPadding + screenEdgePadding,
      ),
      columnHalfGap: padding / 2,
      itemTopSpacing: padding,
      staggeredFirstItemTopOffset: screenEdgePadding + appBarHeight,
      cardWidth: math.max(0.0, (outerWidth - padding) / 2),
      cardCornerRadius: math.max(0.0, layout.cornerRadius),
      searchBarPadding: EdgeInsets.only(top: topPadding + screenEdgePadding, left: screenEdgePadding),
    );
  }

  @override
  List<Object?> get props => [
    topPadding,
    bottomPadding,
    pageWidth,
    outerWidth,
    gridPadding,
    columnHalfGap,
    itemTopSpacing,
    staggeredFirstItemTopOffset,
    cardWidth,
    cardCornerRadius,
    searchBarPadding,
  ];
}

@immutable
class StoreCategoryState extends Equatable {
  final StoreCategoryLayout layout;

  const StoreCategoryState({required this.layout});

  /// Builds the state with every derived layout value from [layout].
  factory StoreCategoryState.fromLayout(AppLayoutState layout) => StoreCategoryState(
    layout: StoreCategoryLayout.fromAppLayout(layout),
  );

  StoreCategoryState copyWith({StoreCategoryLayout? layout}) => StoreCategoryState(layout: layout ?? this.layout);

  @override
  List<Object?> get props => [layout];
}

class StoreCategoryCubit extends Cubit<StoreCategoryState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  StoreCategoryCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(StoreCategoryState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: StoreCategoryLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
