import 'package:cached_network_image/cached_network_image.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/core/utilities.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/material_shimering_place_holder.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/_sub/orders_on_payment_sheet/driver/orders_on_payment_sheet_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showMaterialPendingOrderDetailsDialog({
  required BuildContext context,
  required PendingOrder order,
  required List<Product> products,
  required OrdersOnPaymentSheetLayout layout,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _OrderDetails(order: order, products: products, layout: layout),
  );
}

class MaterialOrdersOnPaymentSheet extends StatelessWidget {
  final Function(String) onPaymentLinkPressed;
  final List<PendingOrder> orders;
  final Function(PendingOrder) onOrderDetailsPressed;
  final OrdersOnPaymentSheetLayout layout;
  const MaterialOrdersOnPaymentSheet({
    super.key,
    required this.onPaymentLinkPressed,
    required this.orders,
    required this.onOrderDetailsPressed,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final highGraphics = context.select<GlobalGraphicBloc, bool>(
      (cubit) => cubit.state.highGraphics,
    );
    return Center(
      heightFactor: 1.0,
      child: SizedBox(
        width: layout.sheetWidth,
        child: Material(
          color: context.appColorScheme.surfaceContainer.withValues(
            alpha: highGraphics ? .5 : .95,
          ),
          borderRadius: .vertical(top: .circular(layout.sheetCornerRadius)),
          clipBehavior: .antiAlias,
          child: BackdropFilter(
            enabled: highGraphics,
            filter: .blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.only(bottom: layout.sheetBottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: layout.headerPadding,
                    child: Container(
                      constraints: BoxConstraints(minHeight: layout.headerHeight),
                      decoration: BoxDecoration(
                        borderRadius: .circular(layout.headerCornerRadius),
                        color: context.appColorScheme.secondary,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: layout.orderCardPadding.left),
                          child: Text(
                            orders.isEmpty ? context.l10n.howDidYouGEtHere : context.l10n.waitingYourPayment,
                            textAlign: .center,
                            style: TextStyle(
                              color: context.appColorScheme.onSecondary,
                              fontSize: layout.headerFontSize,
                              fontWeight: .w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: layout.orderCardSpacing),
                      itemCount: orders.length,
                      itemBuilder: (context, index) => OrderContainerForOrdersOnPaymentSheet(
                        order: orders[index],
                        layout: layout,
                        onPaymentLinkPressed: onPaymentLinkPressed,
                        onDetailsPressed: (order) => onOrderDetailsPressed(order),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderContainerForOrdersOnPaymentSheet extends StatelessWidget {
  final PendingOrder order;
  final Function(String) onPaymentLinkPressed;
  final Function(PendingOrder) onDetailsPressed;
  final OrdersOnPaymentSheetLayout layout;
  const OrderContainerForOrdersOnPaymentSheet({
    super.key,
    required this.order,
    required this.onPaymentLinkPressed,
    required this.onDetailsPressed,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: layout.orderCardMargin,
      decoration: BoxDecoration(
        borderRadius: .circular(layout.orderCardCornerRadius),
        color: context.appColorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: layout.orderCardPadding,
        child: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                spacing: layout.orderCardSpacing,
                children: [
                  Text(
                    '${context.l10n.order}: ${order.paymentId.substring(0, 7)}',
                    style: TextStyle(
                      color: context.appColorScheme.onSurface,
                      fontSize: layout.orderCardFontSize,
                      fontWeight: .w500,
                    ),
                  ),
                  Text(
                    '${context.l10n.total}: ${order.totalPrice}',
                    style: TextStyle(
                      color: context.appColorScheme.onSurface,
                      fontSize: layout.orderCardFontSize,
                      fontWeight: .w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: layout.orderActionGap,
              children: [
                ElevatedButton(
                  onPressed: () => onDetailsPressed(order),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(layout.actionButtonSize, layout.actionButtonSize),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.more_horiz_rounded),
                ),
                ElevatedButton(
                  onPressed: () => onPaymentLinkPressed(order.paymentLink),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(layout.actionButtonSize, layout.actionButtonSize),
                  ),
                  child: Text(
                    context.l10n.pay,
                    style: TextStyle(fontSize: layout.actionButtonFontSize),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String generateDetails(CartItem cartItem) {
  String result = '';
  for (var key in cartItem.purchaseData.keys) {
    result += '$key: ${cartItem.purchaseData[key]}\n';
  }
  return result.trimRight();
}

class _OrderDetails extends StatelessWidget {
  final PendingOrder order;
  final List<Product> products;
  final OrdersOnPaymentSheetLayout layout;
  const _OrderDetails({required this.order, required this.products, required this.layout});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: .circular(layout.dialogCornerRadius)),
      child: Container(
        margin: layout.dialogOuterMargin,
        width: layout.dialogWidth,
        constraints: BoxConstraints(maxHeight: layout.dialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: layout.dialogSectionGap,
          crossAxisAlignment: .start,
          children: [
            Card(
              color: context.appColorScheme.surfaceContainerLowest,
              margin: .all(0),
              shape: RoundedRectangleBorder(borderRadius: .circular(layout.dialogInnerCornerRadius)),
              child: Container(
                margin: layout.dialogHeaderMargin,
                padding: layout.dialogHeaderPadding,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              dateConversion(
                                order.cartItems.last.createdAt.toString(),
                              ),
                              style: TextStyle(
                                fontWeight: .w600,
                                fontSize: layout.dialogHeaderFontSize,
                              ),
                            ),
                            Text(
                              '${context.l10n.order}: ${order.paymentId.substring(0, 7)}',
                              style: TextStyle(fontSize: layout.dialogHeaderFontSize),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: layout.dialogSectionGap / 2),
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                context.l10n.products,
                                style: TextStyle(fontSize: layout.dialogHeaderFontSize),
                              ),
                              Text(
                                ' ${order.cartItems.length}',
                                style: TextStyle(fontSize: layout.dialogHeaderFontSize),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                context.l10n.orderPrice,
                                style: TextStyle(fontSize: layout.dialogHeaderFontSize),
                              ),
                              Text(
                                ' \$${order.totalPrice}',
                                style: TextStyle(fontSize: layout.dialogHeaderFontSize),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColorScheme.surfaceContainerLow,
                  borderRadius: .circular(layout.dialogInnerCornerRadius),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: layout.dialogListPadding,
                      sliver: SliverList.builder(
                        itemCount: order.cartItems.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: layout.dialogSectionGap),
                            child: Row(
                              crossAxisAlignment: .start,
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: layout.dialogSectionGap),
                                  height: layout.dialogThumbnailSize,
                                  width: layout.dialogThumbnailSize,
                                  decoration: BoxDecoration(
                                    borderRadius: .circular(layout.dialogThumbnailCornerRadius),
                                  ),
                                  clipBehavior: .antiAlias,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://regred-rainbowbridge.ru/crabpay/images/products/${(products.firstWhere((element) => element.id == order.cartItems[index].productId)).image}.png',
                                    fit: .cover,
                                    errorWidget: (context, error, stackTrace) => Container(
                                      color: context.appColorScheme.onInverseSurface,
                                      alignment: Alignment.center,
                                      child: Text(
                                        context.l10n.emptyKey,
                                        style: TextStyle(fontSize: layout.dialogDetailsFontSize),
                                      ),
                                    ),
                                    placeholder: (context, url) => MaterialShimeringPlaceHolder(
                                      width: layout.dialogThumbnailSize,
                                      height: layout.dialogThumbnailSize,
                                      cornerRadius: layout.dialogThumbnailCornerRadius,
                                      color: context.appColorScheme.surfaceContainerHigh,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layout.orderCardPadding.left,
                                      vertical: layout.dialogSectionGap / 2,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          order.cartItems[index].productName,
                                          style: TextStyle(fontSize: layout.orderCardFontSize),
                                        ),
                                        Text(
                                          '${order.cartItems[index].checkoutPrice}',
                                          style: TextStyle(
                                            fontSize: layout.dialogPriceFontSize,
                                            color: context.appColorScheme.primary,
                                            fontWeight: .w600,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: context.appColorScheme.surfaceContainerHigh,
                                            borderRadius: .circular(layout.dialogInnerCornerRadius),
                                          ),
                                          padding: layout.dialogOuterMargin,
                                          child: Text(
                                            generateDetails(
                                              order.cartItems[index],
                                            ),
                                            style: TextStyle(fontSize: layout.dialogDetailsFontSize),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
