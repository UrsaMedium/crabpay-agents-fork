import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/material_shimering_place_holder.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/driver/cart_page_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemWidgetDriver extends StatefulWidget {
  final Function(CartItem) onACartItemDelete;
  final Product product;
  final CartItem cartItem;
  final CartPageLayout? layout;
  // final bool isBeingDeleted;
  const CartItemWidgetDriver({
    super.key,
    required this.onACartItemDelete,
    required this.product,
    required this.cartItem,
    this.layout,
    // required this.isBeingDeleted,
  });

  @override
  State<CartItemWidgetDriver> createState() => _CartItemWidgetDriverState();
}

class _CartItemWidgetDriverState extends State<CartItemWidgetDriver> {
  bool _isExpanded = false;
  String details = '';
  late final Color? surfaceTintColor;

  @override
  void initState() {
    for (var key in widget.cartItem.purchaseData.keys) {
      details += '$key: ${widget.cartItem.purchaseData[key]}\n';
    }
    details = details.trimRight();

    surfaceTintColor = context.read<DatabaseBloc>().state.cachedProductImageDominantColor?[widget.product.id] == null
        ? null
        : Color(
            context.read<DatabaseBloc>().state.cachedProductImageDominantColor![widget.product.id]!,
          );
    super.initState();
  }

  void _setExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialCartItemWidget(
      cartItem: widget.cartItem,
      // isBeingDeleted: widget.isBeingDeleted,
      onACartItemDelete: widget.onACartItemDelete,
      product: widget.product,
      isExpanded: _isExpanded,
      setExpanded: _setExpanded,
      details: details,
      surfaceTintColor: surfaceTintColor,
      layout: widget.layout,
    );
  }
}

class MaterialCartItemWidget extends StatelessWidget {
  final Function(CartItem) onACartItemDelete;
  final Product product;
  final CartItem cartItem;
  // final bool isBeingDeleted;
  final bool isExpanded;
  final VoidCallback setExpanded;
  final String details;
  final Color? surfaceTintColor;
  final CartPageLayout? layout;
  const MaterialCartItemWidget({
    super.key,
    required this.onACartItemDelete,
    required this.product,
    required this.cartItem,
    // required this.isBeingDeleted,
    required this.isExpanded,
    required this.setExpanded,
    required this.details,
    this.surfaceTintColor,
    this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final toDelete = context.select<CartPageCubit, CartItem?>(
      (cubit) => cubit.state.itemToDelete,
    );
    final isBeingDeleted = cartItem.id == toDelete?.id;
    final horizontalPadding = layout?.itemHorizontalPadding ?? 16.0;
    final cornerRadius = layout?.itemCornerRadius ?? 39.0;
    final innerPadding = layout?.itemInnerPadding ?? 12.0;
    final imageSize = layout?.itemImageSize ?? 54.0;
    final imageCornerRadius = layout?.itemImageCornerRadius ?? 30.0;
    final priceFontSize = layout?.itemPriceFontSize ?? 14.0;
    final deleteButtonSize = layout?.itemDeleteButtonSize ?? 40.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: setExpanded,
        child: Card(
          elevation: 3,
          surfaceTintColor: surfaceTintColor,
          clipBehavior: Clip.antiAlias,
          color: context.appColorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            side: BorderSide(
              color: context.appColorScheme.surfaceContainerHigh,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(innerPadding),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOutCubic,
                  child: Row(
                    crossAxisAlignment: isExpanded ? .start : .center,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(imageCornerRadius),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: 'https://regred-rainbowbridge.ru/crabpay/images/products/${product.image}.png',
                          fit: .cover,
                          height: imageSize,
                          width: imageSize,
                          errorWidget: (context, error, stackTrace) => Container(
                            color: context.appColorScheme.onInverseSurface,
                            alignment: Alignment.center,
                            child: Text(context.l10n.emptyKey),
                          ),
                          placeholder: (context, url) => MaterialShimeringPlaceHolder(
                            width: imageSize,
                            height: imageSize,
                            cornerRadius: imageCornerRadius,
                            color: context.appColorScheme.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(product.name),
                              Text(
                                '${cartItem.checkoutPrice}',
                                style: TextStyle(
                                  fontSize: priceFontSize,
                                  color: context.appColorScheme.primary,
                                  fontWeight: .w600,
                                ),
                              ),
                              if (isExpanded) Text(details),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: .only(right: innerPadding + 2, top: isExpanded ? innerPadding / 2 : 0),
                        height: deleteButtonSize,
                        width: deleteButtonSize,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: context.appColorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(deleteButtonSize),
                        ),
                        child: IconButton(
                          iconSize: deleteButtonSize * 0.62,
                          padding: .all(0),
                          onPressed: () => onACartItemDelete(cartItem),
                          icon: Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isBeingDeleted)
                BackdropFilter(
                  filter: .blur(sigmaX: 12, sigmaY: 12),
                  child: AbsorbPointer(
                    absorbing: true,
                    child: ClipRRect(
                      borderRadius: .circular(50),
                      child: Center(child: Text(context.l10n.deleting)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
