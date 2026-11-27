import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc_state.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the main screen chrome needs, derived once per layout
/// sync so the views can render them without any arithmetic.
@immutable
class MainScreenLayout extends Equatable {
  /// Platform safe area at the top of the screen.
  final double topPadding;

  /// Platform safe area at the bottom of the screen.
  final double bottomPadding;

  /// Width available between the page edges.
  final double contentWidth;

  /// Width of the floating app bar, matching its horizontal margins.
  final double appBarWidth;
  final double appBarHeight;
  final double appBarCornerRadius;

  /// Outer padding that positions the app bar below the safe area.
  final EdgeInsets appBarPadding;

  /// Height of the gradient scrim behind the app bar.
  final double appBarScrimHeight;

  /// Height the [Scaffold] must reserve for the app bar, excluding the top
  /// system inset, so a scaled bar is never clipped.
  final double appBarPreferredHeight;

  /// Inset of the app bar title from the bar's left edge.
  final EdgeInsets appBarTitlePadding;

  /// Gap between the last app bar action and the bar's right edge.
  final double appBarTrailingGap;
  final double appBarTitleFontSize;

  /// Size of the app bar action icons, scaled with the bar height.
  final double appBarIconSize;

  /// Width of the floating bottom navigation bar.
  final double navBarWidth;
  final double navBarHeight;
  final double navBarCornerRadius;

  /// Distance between the navigation bar and the bottom safe area.
  final double navBarBottomMargin;

  /// Height of the gradient scrim behind the navigation bar.
  final double navBarScrimHeight;

  /// Margin between the bar edge and the selected-item indicator.
  final double navBarIndicatorInset;
  final double navBarIndicatorCornerRadius;

  /// Width of each of the four navigation items.
  final double navBarItemWidth;
  final double navBarItemIconSize;

  /// Top padding that vertically centers the navigation items.
  final double navBarContentTopPadding;

  const MainScreenLayout({
    required this.topPadding,
    required this.bottomPadding,
    required this.contentWidth,
    required this.appBarWidth,
    required this.appBarHeight,
    required this.appBarCornerRadius,
    required this.appBarPadding,
    required this.appBarScrimHeight,
    required this.appBarPreferredHeight,
    required this.appBarTitlePadding,
    required this.appBarTrailingGap,
    required this.appBarTitleFontSize,
    required this.appBarIconSize,
    required this.navBarWidth,
    required this.navBarHeight,
    required this.navBarCornerRadius,
    required this.navBarBottomMargin,
    required this.navBarScrimHeight,
    required this.navBarIndicatorInset,
    required this.navBarIndicatorCornerRadius,
    required this.navBarItemWidth,
    required this.navBarItemIconSize,
    required this.navBarContentTopPadding,
  });

  factory MainScreenLayout.fromAppLayout(AppLayoutState layout) {
    final double topPadding = math.max(0.0, layout.topPadding);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double standardPadding = math.max(0.0, layout.standardPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);

    final double contentWidth = math.max(0.0, layout.width - screenEdgePadding * 2);
    final double appBarWidth = math.max(0.0, layout.width - standardPadding * 2);
    final double appBarHeight = math.max(0.0, layout.appBarHeight);
    final double appBarTopPadding = math.max(0.0, layout.appBarTopPadding);
    final double appBarScrimHeight = appBarTopPadding * 2;
    final double navBarHeight = math.max(0.0, layout.navBarHeight);
    final double navBarBottomMargin = math.max(0.0, layout.navBarBottomPadding);
    final double navBarWidth = math.min(navBarHeight * 5.5, contentWidth);
    final double navBarIndicatorInset = (navBarHeight * 0.07).clamp(3.0, 6.0).toDouble();

    return MainScreenLayout(
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      contentWidth: contentWidth,
      appBarWidth: appBarWidth,
      appBarHeight: appBarHeight,
      appBarCornerRadius: appBarHeight / 2,
      appBarPadding: EdgeInsets.only(top: appBarTopPadding, left: standardPadding, right: standardPadding),
      appBarScrimHeight: appBarScrimHeight,
      appBarPreferredHeight: math.max(0.0, math.max(layout.pageTopPadding, appBarScrimHeight) - topPadding),
      appBarTitlePadding: EdgeInsets.only(left: screenEdgePadding),
      appBarTrailingGap: standardPadding,
      appBarTitleFontSize: layout.largeFontSize.clamp(18.0, 26.0).toDouble(),
      appBarIconSize: (appBarHeight * 0.5).clamp(20.0, 28.0).toDouble(),
      navBarWidth: navBarWidth,
      navBarHeight: navBarHeight,
      navBarCornerRadius: navBarHeight / 2,
      navBarBottomMargin: navBarBottomMargin,
      navBarScrimHeight: navBarBottomMargin + navBarHeight * 0.85,
      navBarIndicatorInset: navBarIndicatorInset,
      navBarIndicatorCornerRadius: math.max(0.0, navBarHeight / 2 - navBarIndicatorInset),
      navBarItemWidth: navBarWidth / 4,
      navBarItemIconSize: (navBarHeight * 0.5).clamp(22.0, 32.0).toDouble(),
      navBarContentTopPadding: 3.0,
    );
  }

  @override
  List<Object?> get props => [
    topPadding,
    bottomPadding,
    contentWidth,
    appBarWidth,
    appBarHeight,
    appBarCornerRadius,
    appBarPadding,
    appBarScrimHeight,
    appBarPreferredHeight,
    appBarTitlePadding,
    appBarTrailingGap,
    appBarTitleFontSize,
    appBarIconSize,
    navBarWidth,
    navBarHeight,
    navBarCornerRadius,
    navBarBottomMargin,
    navBarScrimHeight,
    navBarIndicatorInset,
    navBarIndicatorCornerRadius,
    navBarItemWidth,
    navBarItemIconSize,
    navBarContentTopPadding,
  ];
}

@immutable
class MainScreenState extends Equatable {
  final int page;
  final AppAuthUser? currentUser;
  final bool isLoggedIn;
  final bool isAdmin;
  final int userCartItemAmount;
  final bool isSyncingByNavBarTap;
  final GlobalKey profileIconButtonKey;
  final int amountOfPendingOrders;
  final MainScreenLayout layout;

  const MainScreenState({
    this.page = 0,
    this.currentUser,
    this.userCartItemAmount = 0,
    this.isLoggedIn = false,
    this.isAdmin = false,
    this.isSyncingByNavBarTap = false,
    required this.profileIconButtonKey,
    this.amountOfPendingOrders = 0,
    required this.layout,
  });

  /// Builds the state with every derived layout value from [layout].
  factory MainScreenState.fromLayout(
    AppLayoutState layout, {
    required GlobalKey profileIconButtonKey,
  }) => MainScreenState(
    profileIconButtonKey: profileIconButtonKey,
    layout: MainScreenLayout.fromAppLayout(layout),
  );

  MainScreenState copyWith({
    int? page,
    AppAuthUser? currentUser,
    int? userCartItemAmount,
    bool? isLoggedIn,
    bool? isAdmin,
    bool? isSyncingByNavBarTap,
    GlobalKey? profileIconButtonKey,
    int? amountOfPendingOrders,
    MainScreenLayout? layout,
  }) {
    return MainScreenState(
      page: page ?? this.page,
      currentUser: currentUser ?? this.currentUser,
      userCartItemAmount: userCartItemAmount ?? this.userCartItemAmount,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isAdmin: isAdmin ?? this.isAdmin,
      isSyncingByNavBarTap: isSyncingByNavBarTap ?? this.isSyncingByNavBarTap,
      profileIconButtonKey: profileIconButtonKey ?? this.profileIconButtonKey,
      amountOfPendingOrders: amountOfPendingOrders ?? this.amountOfPendingOrders,
      layout: layout ?? this.layout,
    );
  }

  @override
  List<Object?> get props => [
    page,
    currentUser,
    userCartItemAmount,
    isLoggedIn,
    isAdmin,
    isSyncingByNavBarTap,
    amountOfPendingOrders,
    layout,
  ];
}

class MainScreenCubit extends Cubit<MainScreenState> {
  final AuthBloc _authBloc;
  final CartBloc _cartBloc;
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _authSubscription;
  late final StreamSubscription _cartSubscription;
  late final StreamSubscription _layoutSubscription;
  MainScreenCubit({
    required AuthBloc authBloc,
    required CartBloc cartBloc,
    required GlobalKey globalKey,
    required AppLayoutCubit layoutCubit,
  }) : _authBloc = authBloc,
       _cartBloc = cartBloc,
       _appLayoutCubit = layoutCubit,
       super(MainScreenState.fromLayout(layoutCubit.state, profileIconButtonKey: globalKey)) {
    _authSubscription = _authBloc.stream.listen((authState) {
      final isLoggedIn = !(authState.currentUser.email == null || authState.currentUser.isAnonymous);
      emit(
        state.copyWith(
          currentUser: authState.currentUser,
          isLoggedIn: isLoggedIn,
          isAdmin: authState.currentUser.isAdmin,
        ),
      );
    });
    _cartSubscription = _cartBloc.stream.listen((cartState) {
      if (cartState.states == CartStates.updatedUserCartItemCount) {
        emit(state.copyWith(userCartItemAmount: cartState.userCartItemAmount));
      }
      if (cartState.pendingOrdersState == PendingOrdersState.updated) {
        emit(
          state.copyWith(
            amountOfPendingOrders: cartState.pendingOrders?.length ?? 0,
          ),
        );
      }
    });
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: MainScreenLayout.fromAppLayout(layout)),
  );

  void onPageSwipe(int index) {
    if (state.page != index) {
      emit(state.copyWith(page: index));
    }
  }

  void setSyncByNavBarState(bool isInSync) {
    emit(state.copyWith(isSyncingByNavBarTap: isInSync));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _cartSubscription.cancel();
    _layoutSubscription.cancel();
    return super.close();
  }
}
