import 'package:crabpay/core/local_storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocalStorage.init();
  });

  group('AppLocalStorage.tempUser', () {
    test('creates a temp user with a non-empty id and derived email', () {
      final user = AppLocalStorage.tempUser;
      expect(user.id, isNotEmpty);
      expect(user.email, 'tempUser_id=${user.id}');
      expect(user.isAnonymous, isTrue);
      expect(user.isLimbo, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isEmailVerified, isFalse);
    });
  });

  group('AppLocalStorage defaults', () {
    test('starts with no payment cart item ids', () {
      expect(AppLocalStorage.getCartItemIdsOnPayment(), isEmpty);
    });

    test('starts with an empty payment link', () {
      expect(AppLocalStorage.getPaymentLink(), '');
    });
  });

  group('AppLocalStorage round-trip', () {
    test('saves and reads cart item ids on payment', () async {
      await AppLocalStorage.saveCartItemsOnPayment(<String>['a', 'b']);
      expect(AppLocalStorage.getCartItemIdsOnPayment(), <String>['a', 'b']);
    });

    test('saves and reads the payment link', () async {
      await AppLocalStorage.savePaymentLink('https://example.com/pay');
      expect(AppLocalStorage.getPaymentLink(), 'https://example.com/pay');
    });
  });
}
