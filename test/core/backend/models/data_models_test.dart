import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/support_thread_model.dart';
import 'package:crabpay/core/backend/common/paginated_result_data_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/currencies_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_fields_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('Product', () {
    test('Product.intial has all empty strings', () {
      final product = Product.intial();
      expect(product.id, '');
      expect(product.name, '');
      expect(product.image, '');
      expect(product.description, '');
      expect(product.currencies, '');
      expect(product.category, '');
    });

    test('makeProduct preserves fixture values', () {
      final product = makeProduct();
      expect(product.id, 'product-1');
      expect(product.name, 'Product One');
      expect(product.image, 'https://example.com/product.png');
      expect(product.description, 'A product description');
      expect(product.currencies, 'rub');
      expect(product.category, 'games');
    });
  });

  group('ProductField', () {
    test('ProductField.intial has defaults', () {
      final field = ProductField.intial();
      expect(field.id, '');
      expect(field.productId, '');
      expect(field.order, 0);
      expect(field.fieldName, '');
      expect(field.handler, '');
      expect(field.isPriceImage, isFalse);
      expect(field.priceImages, isNull);
      expect(field.expectedData, isNull);
    });

    test('makeProductField preserves fixture values', () {
      final field = makeProductField();
      expect(field.id, 'field-1');
      expect(field.productId, 'product-1');
      expect(field.order, 0);
      expect(field.fieldName, 'Region');
      expect(field.handler, 'dropdown');
      expect(field.isPriceImage, isFalse);
    });

    test('makeThemImage setter mutates isPriceImage', () {
      final field = makeProductField();
      field.makeThemImage = true;
      expect(field.isPriceImage, isTrue);
    });

    test('giveImageToAttributes setter mutates priceImages', () {
      final field = makeProductField();
      field.giveImageToAttributes = {'size': 2.5};
      expect(field.priceImages, {'size': 2.5});
    });
  });

  group('Currencies', () {
    test('Currencies.intial has zeros and empty strings', () {
      final currencies = Currencies.intial();
      expect(currencies.id, '');
      expect(currencies.name, '');
      expect(currencies.mainCurrency, '');
      expect(currencies.rub, 0);
      expect(currencies.usd, 0);
    });

    test('makeCurrencies preserves fixture values', () {
      final currencies = makeCurrencies();
      expect(currencies.id, 'currency-1');
      expect(currencies.name, 'Rubles');
      expect(currencies.mainCurrency, 'rub');
      expect(currencies.rub, 1);
      expect(currencies.usd, 0.011);
    });
  });

  group('CartItem', () {
    test('CartItem.intial has defaults', () {
      final item = CartItem.intial();
      expect(item.id, '');
      expect(item.userId, '');
      expect(item.userName, '');
      expect(item.productId, '');
      expect(item.productName, '');
      expect(item.purchaseData, isEmpty);
      expect(item.currency, '');
      expect(item.checkoutPrice, 0);
      expect(item.status, '');
      expect(item.createdAt, DateTime(0));
    });

    test('makeCartItem preserves fixture values', () {
      final item = makeCartItem();
      expect(item.id, 'cart-item-1');
      expect(item.userId, 'user-1');
      expect(item.userName, 'User One');
      expect(item.productId, 'product-1');
      expect(item.productName, 'Product One');
      expect(item.purchaseData, {'Region': 'EU'});
      expect(item.currency, 'rub');
      expect(item.checkoutPrice, 100);
      expect(item.status, 'pending');
    });
  });

  group('PendingOrder', () {
    test('PendingOrder.initial has defaults', () {
      final order = PendingOrder.initial();
      expect(order.paymentId, '');
      expect(order.userId, '');
      expect(order.paymentLink, '');
      expect(order.totalPrice, 0);
      expect(order.cartItems, isEmpty);
    });

    test('makePendingOrder preserves fixture values', () {
      final order = makePendingOrder();
      expect(order.paymentId, 'payment-1');
      expect(order.userId, 'user-1');
      expect(order.paymentLink, 'https://example.com/pay');
      expect(order.totalPrice, 100);
      expect(order.cartItems, hasLength(1));
    });
  });

  group('ChatMessage', () {
    test('ChatMessage.intial has defaults', () {
      final message = ChatMessage.intial();
      expect(message.id, '');
      expect(message.threadId, '');
      expect(message.senderId, '');
      expect(message.content, '');
      expect(message.isRead, isFalse);
      expect(message.sending, isNull);
      expect(message.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('makeChatMessage preserves fixture values', () {
      final message = makeChatMessage(sending: true);
      expect(message.id, 'message-1');
      expect(message.threadId, 'thread-1');
      expect(message.senderId, 'user-1');
      expect(message.content, 'Hello');
      expect(message.isRead, isFalse);
      expect(message.sending, isTrue);
    });
  });

  group('SupportThread', () {
    test('has constructor fields', () {
      final thread = SupportThread(id: 'thread-2', userId: 'user-2', status: 'closed');
      expect(thread.id, 'thread-2');
      expect(thread.userId, 'user-2');
      expect(thread.status, 'closed');
    });
  });

  group('PaginatedResult', () {
    test('holds objects, hasMore and nextPageToken', () {
      final result = PaginatedResult<String>(objects: <String>['a'], hasMore: true, nextPageToken: 't');
      expect(result.objects, <String>['a']);
      expect(result.hasMore, isTrue);
      expect(result.nextPageToken, 't');
    });
  });
}
