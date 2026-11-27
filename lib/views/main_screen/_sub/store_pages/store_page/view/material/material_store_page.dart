import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_page_search/driver/store_search_bar_driver.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/driver/store_page_cubit.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card_small.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class MaterialStorePage extends StatelessWidget {
  final Future<void> Function() reFresher;
  final Function(String) onCategoryViewOpen;
  final Function(List<Product>) onSearchSubmitedCallBack;
  const MaterialStorePage({
    super.key,
    required this.reFresher,
    required this.onCategoryViewOpen,
    required this.onSearchSubmitedCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.select<StorePageCubit, StorePageLayout>(
      (cubit) => cubit.state.layout,
    );
    return Center(
      child: SizedBox(
        width: layout.pageWidth,
        child: Scaffold(
          body: Stack(
            alignment: .topRight,
            children: [
              RefreshIndicator(
                edgeOffset: layout.topPadding,
                onRefresh: reFresher,
                child: Padding(
                  padding: layout.listHorizontalPadding,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(height: layout.listTopSpacerHeight),
                      ),
                      SliverList.builder(
                        itemCount: 2,
                        itemBuilder: (context, index) => _CategoryCard(
                          index: index,
                          layout: layout,
                          onCategoryViewOpen: (tag) => onCategoryViewOpen(tag),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: layout.listBottomSpacerHeight),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: layout.searchBarPadding,
                child: MaterialStoreSearchBarDriver(
                  products: context.read<DatabaseBloc>().state.products ?? [],
                  onSearchSubmitedCallBack: (prdcts) => onSearchSubmitedCallBack(prdcts),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Function(String) onCategoryViewOpen;
  final int index;
  final StorePageLayout layout;
  const _CategoryCard({required this.index, required this.layout, required this.onCategoryViewOpen});

  @override
  Widget build(BuildContext context) {
    final highGraphics = context.select<GlobalGraphicBloc, bool>(
      (bloc) => bloc.state.highGraphics,
    );
    final products = context.select<StorePageCubit, List<Product>>(
      (cubit) => (cubit.state.products ?? [])
          .where(
            (element) => element.category == (index == 0 ? 'Mobile Game' : 'Service'),
          )
          .toList(),
    );
    final subTag = index == 0 ? 'Mobile Game' : 'Service';
    return GestureDetector(
      onTap: () => onCategoryViewOpen(subTag),
      child: Card(
        margin: layout.categoryCardMargin,
        shape: RoundedRectangleBorder(borderRadius: .circular(layout.outerCornerRadius)),
        surfaceTintColor: context.appColorScheme.primary,
        color: context.appColorScheme.surfaceContainerHigh,
        child: Column(
          children: [
            Padding(
              padding: layout.categoryHeaderPadding,
              child: Row(
                children: [
                  Text(
                    index == 0 ? context.l10n.mobileGames : context.l10n.services,
                    style: TextStyle(
                      color: context.appColorScheme.secondary,
                      fontSize: layout.categoryTitleFontSize,
                      fontWeight: .bold,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(
              height: layout.categoryCarouselHeight,
              width: layout.outerWidth,
              child: Padding(
                padding: layout.categoryCarouselPadding,
                child: Stack(
                  alignment: .bottomEnd,
                  children: [
                    ListView.builder(
                      itemCount: products.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => ProductCardSmallDriver(
                        product: products[index],
                        tag: subTag,
                        width: layout.categoryProductWidth,
                        // cornerRadius: 4,
                        padding: 0,
                        margin: layout.categoryProductMargin,
                      ),
                    ),
                    Padding(
                      padding: layout.categoryMoreButtonOuterPadding,
                      child: Row(
                        children: [
                          Spacer(),
                          Hero(
                            tag: subTag,
                            createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: .circular(layout.categoryMoreButtonCornerRadius),
                              clipBehavior: .antiAlias,
                              child: BackdropFilter(
                                enabled: highGraphics,
                                filter: .blur(sigmaX: 12, sigmaY: 12),
                                child: GestureDetector(
                                  onTap: () => onCategoryViewOpen(subTag),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.appColorScheme.secondaryContainer.withValues(
                                        alpha: highGraphics ? .4 : .9,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: layout.categoryMoreButtonPadding,
                                      child: Text(
                                        context.l10n.more,
                                        style: TextStyle(
                                          fontSize: layout.categoryMoreButtonFontSize,
                                          color: context.appColorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
