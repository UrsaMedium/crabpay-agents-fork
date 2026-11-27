import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/cart_item_widget.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/driver/cart_page_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialCartPageView extends StatelessWidget {
  final Future<void> Function() reFresher;
  final Function(CartItem) onACartItemDelete;
  final VoidCallback onBuyPressed;
  final VoidCallback onShowBottonSheet;
  const MaterialCartPageView({
    super.key,
    required this.onACartItemDelete,
    required this.onBuyPressed,
    required this.onShowBottonSheet,
    required this.reFresher,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.select<CartPageCubit, CartPageLayout>(
      (cubit) => cubit.state.layout,
    );
    return Center(
      child: SizedBox(
        width: layout.pageWidth,
        child: Scaffold(
          body: Stack(
            clipBehavior: .antiAlias,
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  edgeOffset: layout.topPadding,
                  onRefresh: reFresher,
                  child: _ListOfCartItemsWidget(
                    layout: layout,
                    onACartItemDelete: (p0) => onACartItemDelete(p0),
                  ),
                ),
              ),
              _BuyPannelWidget(
                layout: layout,
                onBuyPressed: onBuyPressed,
                onShowBottonSheet: onShowBottonSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListOfCartItemsWidget extends StatelessWidget {
  final Function(CartItem) onACartItemDelete;
  final CartPageLayout layout;
  const _ListOfCartItemsWidget({required this.onACartItemDelete, required this.layout});

  @override
  Widget build(BuildContext context) {
    final cartItemsToBuy = context.select<CartPageCubit, List<CartItem>>(
      (cubit) => cubit.state.cartItemsTuBuy ?? [],
    );
    final hasPendingOrders = context.select<CartPageCubit, bool>(
      (cubit) => (cubit.state.pendingOrder ?? []).isNotEmpty,
    );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: hasPendingOrders ? layout.listBottomPaddingWithPending : layout.listBottomPaddingWithoutPending,
      ),
      children: [
        Padding(
          padding: layout.titlePadding,
          child: Text(
            context.l10n.shoppingCart,
            textAlign: .left,
            style: TextStyle(
              color: context.appColorScheme.primaryFixedDim,
              fontSize: layout.titleFontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Padding(
          padding: layout.subtitlePadding,
          child: Text(
            context.l10n.confirmThePurchase,
            textAlign: .left,
            style: TextStyle(fontSize: layout.subtitleFontSize),
          ),
        ),
        cartItemsToBuy.isEmpty
            ? Center(
                child: Padding(
                  padding: layout.emptyStatePadding,
                  child: Text(
                    context.l10n.heyYouHaven,
                    textAlign: .center,
                    style: TextStyle(
                      color: context.appColorScheme.secondary,
                      fontSize: layout.emptyStateFontSize,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItemsToBuy.length,
                padding: EdgeInsets.only(top: layout.itemListTopPadding),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CartItemWidgetDriver(
                    layout: layout,
                    onACartItemDelete: onACartItemDelete,
                    cartItem: cartItemsToBuy[index],
                    product: context.read<CartPageCubit>().state.products.firstWhere(
                      (product) => product.id == cartItemsToBuy[index].productId,
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class _BuyPannelWidget extends StatelessWidget {
  final VoidCallback onBuyPressed;
  final VoidCallback onShowBottonSheet;
  final CartPageLayout layout;
  const _BuyPannelWidget({
    required this.onBuyPressed,
    required this.onShowBottonSheet,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final pendingOrders = context.select<CartPageCubit, List<PendingOrder>>(
      (cubit) => cubit.state.pendingOrder ?? [],
    );
    final cartItemsToBuy = context.select<CartPageCubit, List<CartItem>>(
      (cubit) => cubit.state.cartItemsTuBuy ?? [],
    );
    final totalPrice = context.select<CartPageCubit, double?>(
      (cubit) => cubit.state.totalPrice,
    );
    final highGraphics = context.select<GlobalGraphicBloc, bool>(
      (bloc) => bloc.state.highGraphics,
    );
    return Positioned(
      bottom: layout.buyPanelBottomOffset,
      right: layout.buyPanelHorizontalInset,
      left: layout.buyPanelHorizontalInset,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: .circular(layout.buyPanelCornerRadius),
            clipBehavior: .antiAlias,
            child: BackdropFilter(
              enabled: highGraphics,
              filter: .blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: context.appColorScheme.surfaceContainerHigh.withValues(
                  alpha: highGraphics ? .5 : .97,
                ),
                child: Padding(
                  padding: layout.buyPanelContentPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: layout.buyPanelTotalRowPadding,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.total,
                                style: TextStyle(
                                  fontSize: layout.buyPanelTotalFontSize,
                                  fontWeight: .w500,
                                ),
                              ),
                            ),
                            Text(
                              '$totalPrice',
                              style: TextStyle(fontSize: layout.buyPanelTotalFontSize),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: layout.buyPanelButtonHorizontalPadding,
                        child: ElevatedButton(
                          onPressed: cartItemsToBuy.isEmpty ? null : onBuyPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColorScheme.primary,
                            foregroundColor: context.appColorScheme.onPrimary,
                            minimumSize: Size(double.maxFinite, layout.buyPanelButtonHeight),
                          ),
                          child: Text(
                            context.l10n.checkout,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: layout.buyPanelButtonFontSize,
                            ),
                          ),
                        ),
                      ),
                      if (pendingOrders.isNotEmpty)
                        Padding(
                          padding: layout.buyPanelPendingButtonPadding,
                          child: ElevatedButton(
                            onPressed: onShowBottonSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColorScheme.primary,
                              foregroundColor: context.appColorScheme.onPrimary,
                              minimumSize: Size(double.maxFinite, layout.buyPanelButtonHeight),
                            ),
                            child: Text(
                              pendingOrders.length == 1
                                  ? context.l10n.youHave1UnpaidOrder
                                  : '${context.l10n.youHavenUnpaidOrdersSTART} ${pendingOrders.length} ${context.l10n.youHavenUnpaidOrdersEND}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: layout.buyPanelButtonFontSize,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [
                    context.appColorScheme.outline.withValues(alpha: .2),
                    context.appColorScheme.outline.withValues(alpha: .1),
                    Colors.transparent,
                    Colors.transparent,
                    context.appColorScheme.outline.withValues(alpha: .1),
                  ],
                ).createShader(bounds),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: .circular(layout.buyPanelCornerRadius),
                    border: .all(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
