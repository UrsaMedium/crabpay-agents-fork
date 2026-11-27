import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_state.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the cart page needs, derived once per layout sync so the
/// views can render them without any arithmetic.
@immutable
class CartPageLayout extends Equatable {
  /// Platform safe area plus the in-app top bar height.
  final double topPadding;

  /// Platform safe area plus the in-app bottom navigation bar height.
  final double bottomPadding;

  /// Full page width, capped by the app layout.
  final double pageWidth;

  /// Width available between the page edges.
  final double outerWidth;

  /// Base corner radius for cards and floating panels.
  final double outerCornerRadius;

  /// Page margin between the screen edge and the content.
  final double screenEdgePadding;

  /// Inner content padding.
  final double padding;

  final EdgeInsets titlePadding;
  final double titleFontSize;
  final EdgeInsets subtitlePadding;
  final double subtitleFontSize;
  final EdgeInsets emptyStatePadding;
  final double emptyStateFontSize;

  /// Horizontal padding around each cart item card.
  final double itemHorizontalPadding;

  /// Corner radius of each cart item card.
  final double itemCornerRadius;

  /// Inner padding of each cart item card.
  final double itemInnerPadding;

  /// Size of the square product image inside a cart item card.
  final double itemImageSize;

  /// Corner radius of the product image inside a cart item card.
  final double itemImageCornerRadius;

  /// Font size of the checkout price inside a cart item card.
  final double itemPriceFontSize;

  /// Size of the delete button inside a cart item card.
  final double itemDeleteButtonSize;

  /// Top spacing above the list of cart item cards.
  final double itemListTopPadding;

  /// Distance between the buy panel and the bottom edge of the page.
  final double buyPanelBottomOffset;

  /// Horizontal inset of the floating buy panel.
  final double buyPanelHorizontalInset;
  final double buyPanelCornerRadius;
  final EdgeInsets buyPanelContentPadding;
  final EdgeInsets buyPanelTotalRowPadding;
  final double buyPanelTotalFontSize;
  final EdgeInsets buyPanelButtonHorizontalPadding;
  final EdgeInsets buyPanelPendingButtonPadding;
  final double buyPanelButtonHeight;
  final double buyPanelButtonFontSize;

  /// Bottom padding that keeps the last cart item above the buy panel.
  final double listBottomPaddingWithoutPending;

  /// Bottom padding that keeps the last cart item above both buy panel buttons.
  final double listBottomPaddingWithPending;

  const CartPageLayout({
    required this.topPadding,
    required this.bottomPadding,
    required this.pageWidth,
    required this.outerWidth,
    required this.outerCornerRadius,
    required this.screenEdgePadding,
    required this.padding,
    required this.titlePadding,
    required this.titleFontSize,
    required this.subtitlePadding,
    required this.subtitleFontSize,
    required this.emptyStatePadding,
    required this.emptyStateFontSize,
    required this.itemHorizontalPadding,
    required this.itemCornerRadius,
    required this.itemInnerPadding,
    required this.itemImageSize,
    required this.itemImageCornerRadius,
    required this.itemPriceFontSize,
    required this.itemDeleteButtonSize,
    required this.itemListTopPadding,
    required this.buyPanelBottomOffset,
    required this.buyPanelHorizontalInset,
    required this.buyPanelCornerRadius,
    required this.buyPanelContentPadding,
    required this.buyPanelTotalRowPadding,
    required this.buyPanelTotalFontSize,
    required this.buyPanelButtonHorizontalPadding,
    required this.buyPanelPendingButtonPadding,
    required this.buyPanelButtonHeight,
    required this.buyPanelButtonFontSize,
    required this.listBottomPaddingWithoutPending,
    required this.listBottomPaddingWithPending,
  });

  factory CartPageLayout.fromAppLayout(AppLayoutState layout) {
    final double topPadding = math.max(0.0, layout.pageTopPadding);
    final double bottomPadding = math.max(0.0, layout.pageBottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double outerWidth = math.max(0.0, layout.width - screenEdgePadding * 2);
    final double outerCornerRadius = math.max(0.0, layout.cornerRadius);

    final double buyPanelBottomOffset = bottomPadding + padding;
    final double buyPanelButtonHeight = math.max(48.0, layout.appBarHeight);
    final double buyPanelTotalFontSize = layout.mediumFontSize.clamp(14.0, 18.0).toDouble();
    final double listBottomPaddingWithoutPending =
        buyPanelBottomOffset + buyPanelButtonHeight + screenEdgePadding * 3 + buyPanelTotalFontSize + padding * 2;

    return CartPageLayout(
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      pageWidth: math.max(0.0, layout.width),
      outerWidth: outerWidth,
      outerCornerRadius: outerCornerRadius,
      screenEdgePadding: screenEdgePadding,
      padding: padding,
      titlePadding: EdgeInsets.only(top: topPadding + padding, left: screenEdgePadding, right: screenEdgePadding),
      titleFontSize: (layout.largeFontSize * 1.15).clamp(24.0, 32.0).toDouble(),
      subtitlePadding: EdgeInsets.only(left: screenEdgePadding, right: screenEdgePadding, bottom: padding / 2),
      subtitleFontSize: layout.mediumFontSize.clamp(13.0, 17.0).toDouble(),
      emptyStatePadding: EdgeInsets.symmetric(vertical: screenEdgePadding, horizontal: screenEdgePadding),
      emptyStateFontSize: layout.mediumFontSize.clamp(13.0, 17.0).toDouble(),
      itemHorizontalPadding: screenEdgePadding,
      itemCornerRadius: outerCornerRadius,
      itemInnerPadding: padding * 1.5,
      itemImageSize: (layout.width * 0.138).clamp(48.0, 60.0).toDouble(),
      itemImageCornerRadius: layout.innerCornerRadius(padding * 1.5),
      itemPriceFontSize: layout.smallFontSize.clamp(13.0, 16.0).toDouble(),
      itemDeleteButtonSize: 48.0,
      itemListTopPadding: padding,
      buyPanelBottomOffset: buyPanelBottomOffset,
      buyPanelHorizontalInset: screenEdgePadding,
      buyPanelCornerRadius: outerCornerRadius,
      buyPanelContentPadding: EdgeInsets.all(screenEdgePadding),
      buyPanelTotalRowPadding: EdgeInsets.only(bottom: screenEdgePadding, left: padding, right: padding),
      buyPanelTotalFontSize: buyPanelTotalFontSize,
      buyPanelButtonHorizontalPadding: EdgeInsets.symmetric(horizontal: padding),
      buyPanelPendingButtonPadding: EdgeInsets.only(left: padding, right: padding, top: padding),
      buyPanelButtonHeight: buyPanelButtonHeight,
      buyPanelButtonFontSize: layout.mediumFontSize.clamp(14.0, 18.0).toDouble(),
      listBottomPaddingWithoutPending: listBottomPaddingWithoutPending,
      listBottomPaddingWithPending: listBottomPaddingWithoutPending + buyPanelButtonHeight + padding,
    );
  }

  @override
  List<Object?> get props => [
    topPadding,
    bottomPadding,
    pageWidth,
    outerWidth,
    outerCornerRadius,
    screenEdgePadding,
    padding,
    titlePadding,
    titleFontSize,
    subtitlePadding,
    subtitleFontSize,
    emptyStatePadding,
    emptyStateFontSize,
    itemHorizontalPadding,
    itemCornerRadius,
    itemInnerPadding,
    itemImageSize,
    itemImageCornerRadius,
    itemPriceFontSize,
    itemDeleteButtonSize,
    itemListTopPadding,
    buyPanelBottomOffset,
    buyPanelHorizontalInset,
    buyPanelCornerRadius,
    buyPanelContentPadding,
    buyPanelTotalRowPadding,
    buyPanelTotalFontSize,
    buyPanelButtonHorizontalPadding,
    buyPanelPendingButtonPadding,
    buyPanelButtonHeight,
    buyPanelButtonFontSize,
    listBottomPaddingWithoutPending,
    listBottomPaddingWithPending,
  ];
}

@immutable
class CartPageState extends Equatable {
  final List<CartItem>? cartItemsTuBuy;
  final List<PendingOrder>? pendingOrder;
  final CartItem? itemToDelete;
  final List<Product> products;
  final double? totalPrice;
  final CartPageLayout layout;

  const CartPageState({
    this.itemToDelete,
    this.cartItemsTuBuy,
    required this.products,
    this.totalPrice,
    this.pendingOrder,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory CartPageState.fromLayout(AppLayoutState layout, {required List<Product> products}) => CartPageState(
    products: products,
    layout: CartPageLayout.fromAppLayout(layout),
  );

  CartPageState copyWith({
    CartItem? itemToDelete,
    List<CartItem>? cartItemsTuBuy,
    List<Product>? products,
    List<PendingOrder>? pendingOrder,
    double? totalPrice,
    CartPageLayout? layout,
  }) => CartPageState(
    itemToDelete: itemToDelete ?? this.itemToDelete,
    cartItemsTuBuy: cartItemsTuBuy ?? this.cartItemsTuBuy,
    pendingOrder: pendingOrder ?? this.pendingOrder,
    products: products ?? this.products,
    totalPrice: totalPrice ?? this.totalPrice,
    layout: layout ?? this.layout,
  );

  @override
  List<Object?> get props => [
    itemToDelete,
    totalPrice,
    cartItemsTuBuy,
    pendingOrder,
    products,
    layout,
  ];
}

class CartPageCubit extends Cubit<CartPageState> {
  final CartBloc _cartBloc;
  final AppLifecycleService _appLifecycleService;
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _cartSubscription;
  late final StreamSubscription _appLifecycleSub;
  late final StreamSubscription _layoutSubscription;
  CartPageCubit({
    required CartBloc cartBloc,
    required List<Product> products,
    required AppLifecycleService appLifecycleService,
    required AppLayoutCubit layoutCubit,
  }) : _cartBloc = cartBloc,
       _appLifecycleService = appLifecycleService,
       _appLayoutCubit = layoutCubit,
       super(CartPageState.fromLayout(layoutCubit.state, products: products)) {
    _cartSubscription = _cartBloc.stream.listen((cartState) {
      _cartSync(cartState);
    });
    _appLifecycleSub = _appLifecycleService.appStateStream.listen((appState) {
      if (appState == AppState.paused) {
        _cartSubscription.pause();
      }
      if (appState == AppState.active) {
        _cartSync(cartBloc.state);
        _cartSubscription.resume();
      }
    });
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: CartPageLayout.fromAppLayout(layout)),
  );

  void _cartSync(CartState cartState) {
    emit(
      state.copyWith(
        cartItemsTuBuy: cartState.cartItemsToBuy ?? [],
        pendingOrder: cartState.pendingOrders ?? [],
      ),
    );
    _countTotal();
  }

  void _countTotal() {
    final total =
        state.cartItemsTuBuy?.fold(
          .0,
          (sum, item) => sum + item.checkoutPrice,
        ) ??
        0;
    emit(state.copyWith(totalPrice: total));
  }

  void setDeletingItem(CartItem? itemToDelete) => emit(state.copyWith(itemToDelete: itemToDelete));

  void flushCartItems() {
    emit(state.copyWith(cartItemsTuBuy: []));
  }

  @override
  Future<void> close() {
    _cartSubscription.cancel();
    _appLifecycleSub.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
