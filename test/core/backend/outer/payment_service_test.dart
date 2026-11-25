import 'dart:convert';

import 'package:crabpay/core/backend/pyament_services/payment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('createPaymentLink POSTs amount and cartItemIds and returns paymentUrl', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode({'paymentUrl': 'https://pay.test/1'}), 200);
    });
    addTearDown(client.close);
    final handler = PaymentOuterHandler(httpClient: client, paymentUrl: 'https://example.test/pay');

    final url = await handler.createPaymentLink(cartItemIds: ['cart-item-1'], totalAmount: 12.5);

    expect(url, 'https://pay.test/1');
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url, Uri.parse('https://example.test/pay'));
    expect(captured!.headers['Content-Type'], 'application/json');
    expect(
      captured!.body,
      jsonEncode({
        'amount': '12.50',
        'cartItemIds': ['cart-item-1'],
      }),
    );
  });

  test('createPaymentLink formats a whole amount as 100.00 in the request body', () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode({'paymentUrl': 'https://pay.test/1'}), 200);
    });
    addTearDown(client.close);
    final handler = PaymentOuterHandler(httpClient: client, paymentUrl: 'https://example.test/pay');

    final url = await handler.createPaymentLink(cartItemIds: ['cart-item-1'], totalAmount: 100);

    expect(url, 'https://pay.test/1');
    expect(captured, isNotNull);
    expect(captured!.method, 'POST');
    expect(captured!.url, Uri.parse('https://example.test/pay'));
    expect(captured!.headers['Content-Type'], 'application/json');
    expect(
      captured!.body,
      jsonEncode({
        'amount': '100.00',
        'cartItemIds': ['cart-item-1'],
      }),
    );
  });

  test('createPaymentLink wraps a non-200 response in an Exception containing the body', () async {
    final client = MockClient((request) async => http.Response('server exploded', 400));
    addTearDown(client.close);
    final handler = PaymentOuterHandler(httpClient: client, paymentUrl: 'https://example.test/pay');

    await expectLater(
      handler.createPaymentLink(cartItemIds: ['cart-item-1'], totalAmount: 12.5),
      throwsA(
        isA<Exception>().having((e) => '$e', 'message', contains('server exploded')),
      ),
    );
  });

  test('createPaymentLink wraps client errors in an Exception', () async {
    final client = MockClient((request) async => throw Exception('network down'));
    addTearDown(client.close);
    final handler = PaymentOuterHandler(httpClient: client, paymentUrl: 'https://example.test/pay');

    await expectLater(
      handler.createPaymentLink(cartItemIds: ['cart-item-1'], totalAmount: 12.5),
      throwsA(
        isA<Exception>().having((e) => '$e', 'message', contains('network down')),
      ),
    );
  });
}
