import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_category_view/material_store_category_view.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/store_page/_sub/store_category_view/store_category_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreCategoryViewDriver extends StatefulWidget {
  static const String routeName = 'category';
  final String tag;
  const StoreCategoryViewDriver({super.key, required this.tag});

  @override
  State<StoreCategoryViewDriver> createState() => _StoreCategoryViewDriverState();
}

class _StoreCategoryViewDriverState extends State<StoreCategoryViewDriver> {
  late final List<Product> products;
  late final StoreCategoryCubit _categoryCubit;
  List<Product> filteredProducts = [];
  bool _canPop = false;

  @override
  void initState() {
    products = (context.read<DatabaseBloc>().state.products ?? []).where((element) => element.category == widget.tag).toList();
    _categoryCubit = StoreCategoryCubit(layoutCubit: context.read<AppLayoutCubit>());
    super.initState();
  }

  @override
  void dispose() {
    _categoryCubit.close();
    super.dispose();
  }

  void _onSearchSubmitedCallBack(List<Product> productsFromSearch) {
    filteredProducts = productsFromSearch;
    setState(() {});
  }

  void _setCanPopState(bool canPop) {
    setState(() {
      _canPop = canPop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoryCubit,
      child: Builder(
        builder: (context) {
          final layout = context.select<StoreCategoryCubit, StoreCategoryLayout>(
            (cubit) => cubit.state.layout,
          );
          return MaterialStoreCategoryView(
            canPop: _canPop,
            setCanPopState: (p0) => _setCanPopState(p0),
            tag: widget.tag,
            layout: layout,
            products: filteredProducts.isEmpty ? products : filteredProducts,
            onSearchSubmitedCallBack: (prdcts) => _onSearchSubmitedCallBack(prdcts),
          );
        },
      ),
    );
  }
}
