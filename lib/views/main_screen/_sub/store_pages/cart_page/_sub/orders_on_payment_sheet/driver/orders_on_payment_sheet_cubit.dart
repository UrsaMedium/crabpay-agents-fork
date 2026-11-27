import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the pending orders sheet needs, derived once per layout
/// sync so the views can render them without any arithmetic.
@immutable
class OrdersOnPaymentSheetLayout extends Equatable {
  /// Width of the centered sheet column.
  final double sheetWidth;
  final double sheetCornerRadius;

  /// Bottom inset that keeps the sheet content above the system navigation bar.
  final double sheetBottomPadding;

  final EdgeInsets headerPadding;
  final double headerHeight;
  final double headerCornerRadius;
  final double headerFontSize;

  final EdgeInsets orderCardMargin;
  final EdgeInsets orderCardPadding;
  final double orderCardCornerRadius;
  final double orderCardFontSize;
  final double orderCardSpacing;
  final double orderActionGap;

  /// Size of the square action buttons inside an order card.
  final double actionButtonSize;
  final double actionButtonFontSize;

  /// Font size of the order details dialog header rows.
  final double dialogHeaderFontSize;

  final double dialogWidth;
  final double dialogMaxHeight;
  final double dialogCornerRadius;
  final double dialogInnerCornerRadius;
  final EdgeInsets dialogOuterMargin;
  final double dialogSectionGap;
  final EdgeInsets dialogHeaderMargin;
  final EdgeInsets dialogHeaderPadding;
  final EdgeInsets dialogListPadding;
  final double dialogThumbnailSize;
  final double dialogThumbnailCornerRadius;
  final double dialogPriceFontSize;
  final double dialogDetailsFontSize;

  const OrdersOnPaymentSheetLayout({
    required this.sheetWidth,
    required this.sheetCornerRadius,
    required this.sheetBottomPadding,
    required this.headerPadding,
    required this.headerHeight,
    required this.headerCornerRadius,
    required this.headerFontSize,
    required this.orderCardMargin,
    required this.orderCardPadding,
    required this.orderCardCornerRadius,
    required this.orderCardFontSize,
    required this.orderCardSpacing,
    required this.orderActionGap,
    required this.actionButtonSize,
    required this.actionButtonFontSize,
    required this.dialogHeaderFontSize,
    required this.dialogWidth,
    required this.dialogMaxHeight,
    required this.dialogCornerRadius,
    required this.dialogInnerCornerRadius,
    required this.dialogOuterMargin,
    required this.dialogSectionGap,
    required this.dialogHeaderMargin,
    required this.dialogHeaderPadding,
    required this.dialogListPadding,
    required this.dialogThumbnailSize,
    required this.dialogThumbnailCornerRadius,
    required this.dialogPriceFontSize,
    required this.dialogDetailsFontSize,
  });

  factory OrdersOnPaymentSheetLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double cornerRadius = math.max(0.0, layout.cornerRadius);
    final double headerHeight = layout.appBarHeight * 0.85;

    return OrdersOnPaymentSheetLayout(
      sheetWidth: width,
      sheetCornerRadius: cornerRadius,
      sheetBottomPadding: math.max(0.0, layout.bottomPadding) + screenEdgePadding,
      headerPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding * 2, vertical: screenEdgePadding),
      headerHeight: headerHeight,
      headerCornerRadius: headerHeight / 2,
      headerFontSize: layout.mediumFontSize,
      orderCardMargin: EdgeInsets.only(left: screenEdgePadding, right: screenEdgePadding, bottom: padding),
      orderCardPadding: EdgeInsets.all(screenEdgePadding),
      orderCardCornerRadius: cornerRadius,
      orderCardFontSize: layout.mediumFontSize,
      orderCardSpacing: padding * 0.75,
      orderActionGap: padding / 2,
      actionButtonSize: layout.appBarHeight,
      actionButtonFontSize: layout.mediumFontSize,
      dialogHeaderFontSize: layout.smallFontSize,
      dialogWidth: math.max(0.0, width - screenEdgePadding * 2),
      dialogMaxHeight: width * 0.92,
      dialogCornerRadius: cornerRadius,
      dialogInnerCornerRadius: layout.innerCornerRadius(padding / 2),
      dialogOuterMargin: EdgeInsets.all(padding / 2),
      dialogSectionGap: padding / 2,
      dialogHeaderMargin: EdgeInsets.all(padding),
      dialogHeaderPadding: EdgeInsets.symmetric(horizontal: screenEdgePadding, vertical: padding / 2),
      dialogListPadding: EdgeInsets.all(padding * 1.5),
      dialogThumbnailSize: width * 0.10,
      dialogThumbnailCornerRadius: padding,
      dialogPriceFontSize: layout.smallFontSize,
      dialogDetailsFontSize: layout.tinyFontSize,
    );
  }

  @override
  List<Object?> get props => [
    sheetWidth,
    sheetCornerRadius,
    sheetBottomPadding,
    headerPadding,
    headerHeight,
    headerCornerRadius,
    headerFontSize,
    orderCardMargin,
    orderCardPadding,
    orderCardCornerRadius,
    orderCardFontSize,
    orderCardSpacing,
    orderActionGap,
    actionButtonSize,
    actionButtonFontSize,
    dialogHeaderFontSize,
    dialogWidth,
    dialogMaxHeight,
    dialogCornerRadius,
    dialogInnerCornerRadius,
    dialogOuterMargin,
    dialogSectionGap,
    dialogHeaderMargin,
    dialogHeaderPadding,
    dialogListPadding,
    dialogThumbnailSize,
    dialogThumbnailCornerRadius,
    dialogPriceFontSize,
    dialogDetailsFontSize,
  ];
}

@immutable
class OrdersOnPaymentSheetState extends Equatable {
  final OrdersOnPaymentSheetLayout layout;

  const OrdersOnPaymentSheetState({required this.layout});

  /// Builds the state with every derived layout value from [layout].
  factory OrdersOnPaymentSheetState.fromLayout(AppLayoutState layout) => OrdersOnPaymentSheetState(
    layout: OrdersOnPaymentSheetLayout.fromAppLayout(layout),
  );

  OrdersOnPaymentSheetState copyWith({OrdersOnPaymentSheetLayout? layout}) =>
      OrdersOnPaymentSheetState(layout: layout ?? this.layout);

  @override
  List<Object?> get props => [layout];
}

class OrdersOnPaymentSheetCubit extends Cubit<OrdersOnPaymentSheetState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  OrdersOnPaymentSheetCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(OrdersOnPaymentSheetState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: OrdersOnPaymentSheetLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
