import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_database_bloc/admin_database_bloc.dart';
import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_database_bloc/admin_database_event.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class AddFeaturedProductView extends StatefulWidget {
  const AddFeaturedProductView({super.key});

  @override
  State<AddFeaturedProductView> createState() => _AddFeaturedProductViewState();
}

class _AddFeaturedProductViewState extends State<AddFeaturedProductView> {
  final TextEditingController _suggestionInputController = TextEditingController();
  List<Product>? products;
  Product? _product;

  @override
  void initState() {
    products = context.read<DatabaseBloc>().state.products;
    super.initState();
  }

  @override
  void dispose() {
    _suggestionInputController.dispose();
    super.dispose();
  }

  List<DropdownMenuEntry<Product>> _products(BuildContext context) {
    List<DropdownMenuEntry<Product>> result = [];
    List<Product> products = context.read<DatabaseBloc>().state.products!;
    for (var product in products) {
      result.add(DropdownMenuEntry(value: product, label: product.name));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        !Navigator.of(context).canPop() ? context.go(AppRoutes.support.path) : context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.support.path);
              }
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          children: [
            DropdownMenu<Product>(
              dropdownMenuEntries: _products(context),
              controller: _suggestionInputController,
              onSelected: (value) => setState(() {
                _product = value;
              }),
              expandedInsets: EdgeInsets.zero,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: context.appColorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_product != null) {
                  context.read<DatabaseBlocAdmin>().add(
                    DatabaseEventAddFeaturedProductAdmin(product: _product!),
                  );
                  // Fluttertoast.showToast(msg: '$_productId');
                } else {
                  Fluttertoast.showToast(msg: context.l10n.wrongInput);
                }
              },
              child: Text(context.l10n.addTheFeaturedProductId),
            ),
            ElevatedButton(
              onPressed: () {
                if (_product != null) {
                  context.read<DatabaseBlocAdmin>().add(
                    DatabaseEventDeleteFeaturedProductAdmin(product: _product!),
                  );
                  // Fluttertoast.showToast(msg: '$_productId');
                } else {
                  Fluttertoast.showToast(msg: context.l10n.wrongInput);
                }
              },
              child: Text(context.l10n.deleteTheFeaturedProductId),
            ),
          ],
        ),
      ),
    );
  }
}
