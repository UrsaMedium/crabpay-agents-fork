import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/material_shimering_place_holder.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialHomePageFavoriteContainer extends StatelessWidget {
  const MaterialHomePageFavoriteContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final userPreferences = context.select<HomePageCubit, List<Product>>(
      (cubit) => cubit.state.userPreferences ?? [],
    );
    final isInitialized = context.select<HomePageCubit, bool>(
      (cubit) => cubit.state.isInitialized,
    );
    final layout = context.read<HomePageCubit>().state.layout;

    return Container(
      decoration: BoxDecoration(
        color: context.appColorScheme.surfaceContainer,
        borderRadius: .circular(layout.outerCornerRadius),
      ),
      width: layout.outerWidth,
      child: Padding(
        padding: .all(layout.padding),
        child: Row(
          crossAxisAlignment: .start,
          spacing: layout.gap,
          children: [
            userPreferences.isNotEmpty
                ? Column(
                    mainAxisSize: .min,
                    children: [
                      ...List.generate(
                        (userPreferences.length + 1) ~/ 2,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 0 : layout.gap,
                          ),
                          child: ProductCardDriver(
                            product: userPreferences[index * 2],
                            tag: '${userPreferences[index * 2].id}-favorite-$index',
                            width: layout.colWidth,
                            cornerRadius: layout.innerCornerRadius,
                          ),
                        ),
                      ),
                    ],
                  )
                : !isInitialized
                ? _PlaceHolder(layout: layout)
                : SizedBox(),
            Column(
              mainAxisSize: .min,
              children: [
                Container(
                  width: layout.colWidth,
                  margin: .only(
                    bottom: (isInitialized && userPreferences.isEmpty) ? 0 : layout.gap,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: .circular(layout.innerCornerRadius),
                    color: context.appColorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Padding(
                      padding: layout.bannerPadding,
                      child: Text(
                        (isInitialized && userPreferences.isEmpty) ? context.l10n.favoriteEmpty : context.l10n.favorite,
                        textAlign: .center,
                        style: TextStyle(
                          fontSize: layout.bannerFontSize,
                          fontWeight: .w700,
                          color: context.appColorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                if (userPreferences.isNotEmpty)
                  ...List.generate(
                    userPreferences.length ~/ 2,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : layout.gap,
                      ),
                      child: ProductCardDriver(
                        product: userPreferences[index * 2 + 1],
                        tag: '${userPreferences[index * 2 + 1].id}-favorite-$index',
                        width: layout.colWidth,
                        cornerRadius: layout.innerCornerRadius,
                      ),
                    ),
                  ),
                if (userPreferences.isEmpty && !isInitialized) _PlaceHolder(layout: layout),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceHolder extends StatelessWidget {
  final HomePageLayout layout;
  const _PlaceHolder({required this.layout});

  @override
  Widget build(BuildContext context) {
    return MaterialShimeringPlaceHolder(
      color: context.appColorScheme.surfaceContainerHigh,
      shimeringColor: context.appColorScheme.outline,
      cycleLongevityFactor: 278 * 10,
      height: layout.topRowHeight,
      width: layout.colWidth,
      cornerRadius: layout.innerCornerRadius,
    );
  }
}
