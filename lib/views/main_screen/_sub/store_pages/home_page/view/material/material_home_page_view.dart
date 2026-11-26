import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/driver/home_page_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/view/material/material_home_page_favorite_container.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/home_page/view/material/material_home_page_featured_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MaterialHomePageView extends StatelessWidget {
  final Future<void> Function() reFresher;
  const MaterialHomePageView({super.key, required this.reFresher});

  @override
  Widget build(BuildContext context) {
    final pagePadding = context.select<HomePageCubit, EdgeInsets>(
      (cubit) => cubit.state.pagePadding,
    );
    final topPadding = context.select<HomePageCubit, double>(
      (cubit) => cubit.state.topPadding,
    );

    return RefreshIndicator(
      edgeOffset: topPadding,
      onRefresh: reFresher,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: pagePadding,
            child: Center(
              child: Column(
                children: [
                  MaterialHomePageFeaturedContainer(),
                  Padding(
                    padding: .symmetric(horizontal: 22, vertical: 6),
                    child: Divider(),
                  ),
                  MaterialHomePageFavoriteContainer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
