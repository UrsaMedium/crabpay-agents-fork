import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/cart_bloc/cart_bloc.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:crabpay/core/backend/pyament_services/payment_bloc/payment_bloc.dart';
import 'package:crabpay/core/backend/pyament_services/payment_bloc/payment_event.dart';
import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/_sub/orders_on_payment_sheet/view/material/material_orders_on_payment_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrdersOnPaymentSheetDriver extends StatelessWidget {
  const OrdersOnPaymentSheetDriver({super.key});

  void _onPaymentLinkPressed(BuildContext context, String? link) {
    if (link != null) {
      context.read<PaymentBloc>().add(PaymentEventReturnToProvider(link: link));
      context.pop();
    }
  }

  void _onOrderDetailsPressed(
    BuildContext context,
    List<Product> products,
    PendingOrder order,
  ) async {
    await showMaterialPendingOrderDetailsDialog(
      context: context,
      order: order,
      products: products,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrders = context.select<CartBloc, List<PendingOrder>>(
      (bloc) => bloc.state.pendingOrders ?? [],
    );
    return MaterialOrdersOnPaymentSheet(
      orders: pendingOrders,
      onPaymentLinkPressed: (paymentLink) => _onPaymentLinkPressed(context, paymentLink),
      onOrderDetailsPressed: (order) => _onOrderDetailsPressed(
        context,
        context.read<DatabaseBloc>().state.products ?? [],
        order,
      ),
    );
  }
}
