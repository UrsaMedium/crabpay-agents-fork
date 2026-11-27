import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/view/material/material_home_page_favorite_container.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/view/material/material_home_page_featured_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:async';

class MaterialHomePageView extends StatelessWidget {
  final Future<void> Function() reFresher;
  const MaterialHomePageView({super.key, required this.reFresher});

  @override
  Widget build(BuildContext context) {
    final layout = context.select<HomePageCubit, HomePageLayout>(
      (cubit) => cubit.state.layout,
    );

    return RefreshIndicator(
      edgeOffset: layout.topPadding,
      onRefresh: reFresher,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: layout.pagePadding,
            child: Center(
              child: SizedBox(
                width: layout.outerWidth,
                child: Column(
                  children: [
                    MaterialHomePageFeaturedContainer(),
                    Padding(
                      padding: layout.dividerPadding,
                      child: Divider(),
                    ),
                    MaterialHomePageFavoriteContainer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
