import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/support_thread_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/currencies_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_fields_model.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/data_models/product_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/pending_order_model.dart';
import 'package:retry/retry.dart';

/// Retry options that fail fast so error-path tests do not wait for backoff.
const RetryOptions noRetry = RetryOptions(maxAttempts: 1, delayFactor: Duration.zero);

/// Fixed timestamp used across fixtures to keep assertions deterministic.
final DateTime testDate = DateTime.utc(2026, 1, 15, 10, 30);

AppAuthUser makeAuthUser({
  String id = 'user-1',
  String? email = 'user@example.com',
  bool isEmailVerified = true,
  bool isAnonymous = false,
  bool isAdmin = false,
  bool isLimbo = false,
}) {
  return AppAuthUser(
    id: id,
    email: email,
    isEmailVerified: isEmailVerified,
    isAnonymous: isAnonymous,
    isAdmin: isAdmin,
    isLimbo: isLimbo,
  );
}

Product makeProduct({
  String id = 'product-1',
  String name = 'Product One',
  String image = 'https://example.com/product.png',
  String description = 'A product description',
  String currencies = 'rub',
  String category = 'games',
}) {
  return Product(
    id: id,
    name: name,
    image: image,
    description: description,
    currencies: currencies,
    category: category,
  );
}

ProductField makeProductField({
  String id = 'field-1',
  String productId = 'product-1',
  int order = 0,
  String fieldName = 'Region',
  String handler = 'dropdown',
  bool isPriceImage = false,
  Map<String, double>? priceImages,
  List<String>? expectedData,
}) {
  return ProductField(
    id: id,
    productId: productId,
    order: order,
    fieldName: fieldName,
    handler: handler,
    isPriceImage: isPriceImage,
    priceImages: priceImages,
    expectedData: expectedData,
  );
}

Currencies makeCurrencies({
  String id = 'currency-1',
  String name = 'Rubles',
  String mainCurrency = 'rub',
  double rub = 1,
  double usd = 0.011,
}) {
  return Currencies(
    id: id,
    name: name,
    mainCurrency: mainCurrency,
    rub: rub,
    usd: usd,
  );
}

CartItem makeCartItem({
  String id = 'cart-item-1',
  String userId = 'user-1',
  String userName = 'User One',
  String productId = 'product-1',
  String productName = 'Product One',
  Map<String, String> purchaseData = const {'Region': 'EU'},
  String currency = 'rub',
  double checkoutPrice = 100,
  String status = 'pending',
  String? comment,
  String? paymentId,
  String? paymentLink,
  DateTime? createdAt,
  DateTime? statusChangedAt,
}) {
  return CartItem(
    id: id,
    userId: userId,
    userName: userName,
    productId: productId,
    productName: productName,
    purchaseData: purchaseData,
    currency: currency,
    checkoutPrice: checkoutPrice,
    status: status,
    comment: comment,
    paymentId: paymentId,
    paymentLink: paymentLink,
    createdAt: createdAt ?? testDate,
    statusChangedAt: statusChangedAt,
  );
}

PendingOrder makePendingOrder({
  String paymentId = 'payment-1',
  String userId = 'user-1',
  String paymentLink = 'https://example.com/pay',
  List<CartItem>? cartItems,
  double totalPrice = 100,
}) {
  return PendingOrder(
    paymentId: paymentId,
    userId: userId,
    paymentLink: paymentLink,
    cartItems: cartItems ?? <CartItem>[makeCartItem()],
    totalPrice: totalPrice,
  );
}

ChatMessage makeChatMessage({
  String id = 'message-1',
  String threadId = 'thread-1',
  String senderId = 'user-1',
  String content = 'Hello',
  bool isRead = false,
  DateTime? createdAt,
  bool? sending,
}) {
  return ChatMessage(
    id: id,
    threadId: threadId,
    senderId: senderId,
    content: content,
    isRead: isRead,
    createdAt: createdAt ?? testDate,
    sending: sending,
  );
}

SupportThread makeSupportThread({
  String id = 'thread-1',
  String userId = 'user-1',
  String status = 'open',
}) {
  return SupportThread(id: id, userId: userId, status: status);
}
