import 'package:crabpay/core/utilities.dart';
import 'package:crabpay/views/main_screen/_sub/orders_view/driver/crab_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('CrabOrder.fromOrderEntry', () {
    test('populates display id, date, price and item maps', () {
      // Documents current bug: dateConversion(statusChangedAt.toString()) throws when
      // statusChangedAt is null, so the fixtures below set it explicitly as a workaround.
      final item1 = makeCartItem(
        id: 'order-123456789',
        productId: 'product-1',
        checkoutPrice: 10,
        status: 'delivered',
        statusChangedAt: testDate,
      );
      final item2 = makeCartItem(
        id: 'order-123456790',
        productId: 'product-2',
        checkoutPrice: 25,
        status: 'pending',
        statusChangedAt: testDate,
      );
      final products = [
        makeProduct(id: 'product-1'),
        makeProduct(id: 'product-2', name: 'Product Two'),
      ];

      final order = CrabOrder.fromOrderEntry(orderEntry: MapEntry('order-123456789', [item1, item2]), products: products);

      expect(order.orderId, 'order-123456789');
      expect(order.orderIdToDisplay, 'order-12');
      expect(order.orderDate, dateConversion(item1.statusChangedAt!.toString()));
      expect(order.orderPrice, 35);
      expect(order.amountOfItems, 2);
      expect(order.amountOfDeliveredItems, 1);
      expect(order.items, [item1, item2]);
      expect(order.itemsToProductMap[item1]!.id, 'product-1');
      expect(order.itemsToProductMap[item2]!.name, 'Product Two');
      expect(order.itemsToImagesMap[item1], 'https://example.com/product.png');
    });

    test('throws on a short order key', () {
      final item = makeCartItem();
      expect(
        () => CrabOrder.fromOrderEntry(orderEntry: MapEntry('short', [item]), products: [makeProduct()]),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws when a product is missing from the list', () {
      final item = makeCartItem(id: 'order-123456789', productId: 'missing-product', statusChangedAt: testDate);
      expect(
        () => CrabOrder.fromOrderEntry(orderEntry: MapEntry('order-123456789', [item]), products: []),
        throwsA(isA<StateError>()),
      );
    });
  });
}
