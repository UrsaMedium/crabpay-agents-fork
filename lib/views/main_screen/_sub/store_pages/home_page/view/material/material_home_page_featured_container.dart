import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/material_shimering_place_holder.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card_horizontal.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card_small.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class MaterialHomePageFeaturedContainer extends StatelessWidget {
  const MaterialHomePageFeaturedContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredProducts = context.select<HomePageCubit, List<Product>>(
      (cubit) => cubit.state.featuredProducts ?? [],
    );
    final layout = context.select<HomePageCubit, HomeFeaturedLayout>(
      (cubit) => cubit.state.featuredLayout,
    );

    return Container(
      width: layout.outerWidth,
      decoration: BoxDecoration(
        color: context.appColorScheme.tertiaryContainer,
        borderRadius: .circular(layout.outerCornerRadius),
      ),
      child: featuredProducts.isNotEmpty
          ? Padding(
              padding: .all(layout.padding),
              child: Column(
                spacing: layout.gap,
                children: [
                  _FeaturedTopRow(
                    layout: layout,
                    featuredProducts: featuredProducts,
                  ),
                  if (featuredProducts.length > 1)
                    ProductCardHorizontalDriver(
                      product: featuredProducts[1],
                      tag: '${featuredProducts[1].id}-featuredProduct-1',
                      height: layout.horizontalHeight,
                      width: layout.innerWidth,
                      cornerRadius: layout.innerCornerRadius,
                    ),
                ],
              ),
            )
          : _PlaceHolder(layout: layout),
    );
  }
}

class _FeaturedTopRow extends StatelessWidget {
  final HomeFeaturedLayout layout;
  final List<Product> featuredProducts;
  const _FeaturedTopRow({required this.layout, required this.featuredProducts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.innerWidth,
      height: layout.topRowHeight,
      child: Row(
        crossAxisAlignment: .start,
        spacing: layout.gap,
        children: [
          SizedBox(
            width: layout.colWidth,
            height: layout.topRowHeight,
            child: Column(
              spacing: layout.gap,
              children: [
                Expanded(child: _FeaturedTitleBanner(layout: layout)),
                ProductCardSmallDriver(
                  padding: layout.smallCardPadding,
                  product: featuredProducts[0],
                  tag: '${featuredProducts[0].id}-featuredProduct-0',
                  width: layout.colWidth,
                  cornerRadius: layout.innerCornerRadius,
                ),
              ],
            ),
          ),
          if (featuredProducts.length > 2)
            ProductCardDriver(
              product: featuredProducts[2],
              tag: '${featuredProducts[2].id}-featuredProduct-2',
              width: layout.colWidth,
              cornerRadius: layout.innerCornerRadius,
            ),
        ],
      ),
    );
  }
}

class _FeaturedTitleBanner extends StatelessWidget {
  final HomeFeaturedLayout layout;
  const _FeaturedTitleBanner({required this.layout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: layout.bannerPadding,
      decoration: BoxDecoration(
        borderRadius: .circular(layout.innerCornerRadius),
        color: context.appColorScheme.onTertiaryContainer,
      ),
      child: Center(
        child: FittedBox(
          fit: .scaleDown,
          child: Text(
            context.l10n.featuredndeals,
            textAlign: .center,
            style: TextStyle(
              fontSize: layout.bannerFontSize,
              height: 1.05,
              fontWeight: .w700,
              color: context.appColorScheme.tertiaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceHolder extends StatelessWidget {
  final HomeFeaturedLayout layout;
  const _PlaceHolder({required this.layout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(layout.padding),
      child: Column(
        spacing: layout.gap,
        children: [
          SizedBox(
            width: layout.innerWidth,
            height: layout.topRowHeight,
            child: Row(
              crossAxisAlignment: .start,
              spacing: layout.gap,
              children: [
                SizedBox(
                  width: layout.colWidth,
                  height: layout.topRowHeight,
                  child: Column(
                    spacing: layout.gap,
                    children: [
                      Expanded(child: _FeaturedTitleBanner(layout: layout)),
                      _ShimmerTile(
                        width: layout.colWidth,
                        height: layout.smallCardHeight,
                        cornerRadius: layout.innerCornerRadius,
                      ),
                    ],
                  ),
                ),
                _ShimmerTile(
                  width: layout.colWidth,
                  height: layout.topRowHeight,
                  cornerRadius: layout.innerCornerRadius,
                ),
              ],
            ),
          ),
          _ShimmerTile(
            width: layout.innerWidth,
            height: layout.horizontalHeight,
            cornerRadius: layout.innerCornerRadius,
          ),
        ],
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final double width;
  final double height;
  final double cornerRadius;
  const _ShimmerTile({
    required this.width,
    required this.height,
    required this.cornerRadius,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialShimeringPlaceHolder(
      color: context.appColorScheme.surfaceContainerHigh,
      shimeringColor: context.appColorScheme.outline,
      cycleLongevityFactor: 278 * 10,
      width: width,
      height: height,
      cornerRadius: cornerRadius,
    );
  }
}
