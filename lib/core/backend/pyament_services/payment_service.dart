import 'dart:convert';
import 'package:crabpay/core/backend/pyament_services/payment_server_conf.dart';
import 'package:http/http.dart' as http;

class PaymentOuterHandler {
  final String _vpsPaymentUrl;
  final http.Client? _httpClient;

  PaymentOuterHandler({http.Client? httpClient, String? paymentUrl}) : _httpClient = httpClient, _vpsPaymentUrl = paymentUrl ?? linkToThePaymentServer;

  Future<http.Response> _post(Uri url, {required Map<String, String> headers, required String body}) {
    final client = _httpClient;
    if (client != null) return client.post(url, headers: headers, body: body);
    return http.post(url, headers: headers, body: body);
  }

  Future<String> createPaymentLink({
    required List<String> cartItemIds,
    required double totalAmount,
  }) async {
    try {
      final response = await _post(
        Uri.parse(_vpsPaymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': totalAmount.toStringAsFixed(2),
          'cartItemIds': cartItemIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['paymentUrl'];
      } else {
        throw Exception('Server returned an error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate payment link: $e');
    }
  }
}
