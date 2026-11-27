import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/product_card.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_category_view/store_category_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_page_search/driver/store_search_bar_driver.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class MaterialStoreCategoryView extends StatelessWidget {
  final String tag;
  final bool canPop;
  final List<Product> products;
  final StoreCategoryLayout layout;
  final Function(List<Product>) onSearchSubmitedCallBack;
  final Function(bool) setCanPopState;
  const MaterialStoreCategoryView({
    super.key,
    required this.tag,
    required this.products,
    required this.layout,
    required this.onSearchSubmitedCallBack,
    required this.canPop,
    required this.setCanPopState,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setCanPopState(true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pop();
          }
        });
      },
      child: Center(
        child: SizedBox(
          width: layout.pageWidth,
          child: Scaffold(
            body: Stack(
              alignment: .topRight,
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: layout.gridPadding,
                      sliver: Builder(
                        builder: (context) {
                          return SliverCrossAxisGroup(
                            slivers: [
                              SliverPadding(
                                padding: .only(right: layout.columnHalfGap),
                                sliver: SliverList.builder(
                                  itemCount: (products.length + 1) ~/ 2,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(top: layout.itemTopSpacing),
                                    child: ProductCardDriver(
                                      product: products[index * 2],
                                      tag: '${products[index * 2].id}-$tag',
                                      width: layout.cardWidth,
                                      cornerRadius: layout.cardCornerRadius,
                                    ),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: .only(left: layout.columnHalfGap),
                                sliver: SliverList.builder(
                                  itemCount: products.length ~/ 2,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? layout.staggeredFirstItemTopOffset : layout.itemTopSpacing,
                                    ),
                                    child: ProductCardDriver(
                                      product: products[index * 2 + 1],
                                      tag: '${products[index * 2 + 1].id}-$tag',
                                      width: layout.cardWidth,
                                      cornerRadius: layout.cardCornerRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: layout.searchBarPadding,
                  child: Hero(
                    tag: tag,
                    createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end),
                    child: MaterialStoreSearchBarDriver(
                      products: products,
                      onSearchSubmitedCallBack: (prdcts) => onSearchSubmitedCallBack(prdcts),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
