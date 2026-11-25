import 'package:crabpay/views/main_screen/_sub/store_pages/cart_page/orders_on_payment_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('generateDetails', () {
    test('returns empty string for empty purchaseData', () {
      final cartItem = makeCartItem(purchaseData: {});
      expect(generateDetails(cartItem), isEmpty);
    });

    test('formats a single entry as "key: value"', () {
      final cartItem = makeCartItem(purchaseData: {'Region': 'EU'});
      expect(generateDetails(cartItem), 'Region: EU');
    });

    test('formats multiple entries separated by newlines', () {
      final cartItem = makeCartItem(purchaseData: {'Region': 'EU', 'Note': 'x'});
      expect(generateDetails(cartItem), 'Region: EU\nNote: x');
    });
  });
}
