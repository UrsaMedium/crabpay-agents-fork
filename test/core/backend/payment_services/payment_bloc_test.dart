import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/pyament_services/payment_bloc/payment_bloc.dart';
import 'package:crabpay/core/backend/pyament_services/payment_bloc/payment_event.dart';
import 'package:crabpay/core/backend/pyament_services/payment_bloc/payment_state.dart';
import 'package:crabpay/core/local_storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/platform_channel_mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockPaymentOuterHandler paymentHandler;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppLocalStorage.init();
    mockUrlLauncherChannel();
  });

  group('PaymentBloc', () {
    blocTest<PaymentBloc, PaymentState>(
      'Pay emits PaymentStateLoading then PaymentStateUserAtProvider',
      setUp: () {
        paymentHandler = MockPaymentOuterHandler();
        when(
          () => paymentHandler.createPaymentLink(
            cartItemIds: any(named: 'cartItemIds'),
            totalAmount: any(named: 'totalAmount'),
          ),
        ).thenAnswer((_) async => 'https://pay.test/1');
      },
      build: () => PaymentBloc(paymentHandler),
      act: (bloc) => bloc.add(PaymentEventPay(provider: 'test', cartItems: [makeCartItem()])),
      expect: () => [isA<PaymentStateLoading>(), isA<PaymentStateUserAtProvider>()],
    );

    test('Pay sums checkoutPrice, collects ids and persists the created payment link', () async {
      const createdPaymentUrl = 'https://pay.test/handler-created';
      final handler = MockPaymentOuterHandler();
      when(
        () => handler.createPaymentLink(
          cartItemIds: any(named: 'cartItemIds'),
          totalAmount: any(named: 'totalAmount'),
        ),
      ).thenAnswer((_) async => createdPaymentUrl);

      final bloc = PaymentBloc(handler);
      addTearDown(bloc.close);

      final emitted = <PaymentState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);
      bloc.add(
        PaymentEventPay(
          provider: 'test',
          cartItems: [
            makeCartItem(id: 'cart-item-1', checkoutPrice: 100),
            makeCartItem(id: 'cart-item-2', checkoutPrice: 150),
          ],
        ),
      );
      await pumpEventQueue();

      verify(() => handler.createPaymentLink(cartItemIds: ['cart-item-1', 'cart-item-2'], totalAmount: 250)).called(1);
      expect(emitted, [isA<PaymentStateLoading>(), isA<PaymentStateUserAtProvider>()]);

      // savePaymentLink is fire-and-forget from the bloc's point of view.
      await pumpEventQueue();
      expect(AppLocalStorage.getPaymentLink(), contains(createdPaymentUrl));
    });

    blocTest<PaymentBloc, PaymentState>(
      'Pay with handler throwing rethrows after emitting PaymentStateLoading',
      setUp: () {
        paymentHandler = MockPaymentOuterHandler();
        when(
          () => paymentHandler.createPaymentLink(
            cartItemIds: any(named: 'cartItemIds'),
            totalAmount: any(named: 'totalAmount'),
          ),
        ).thenThrow(Exception('boom'));
      },
      build: () => PaymentBloc(paymentHandler),
      act: (bloc) => bloc.add(PaymentEventPay(provider: 'test', cartItems: [makeCartItem()])),
      expect: () => [PaymentStateLoading()],
      errors: () => [isA<Exception>()],
    );

    blocTest<PaymentBloc, PaymentState>(
      'Pay with launchUrl returning false throws',
      setUp: () {
        paymentHandler = MockPaymentOuterHandler();
        when(
          () => paymentHandler.createPaymentLink(
            cartItemIds: any(named: 'cartItemIds'),
            totalAmount: any(named: 'totalAmount'),
          ),
        ).thenAnswer((_) async => 'https://pay.test/1');
        mockUrlLauncherChannel(launchResult: false);
      },
      build: () => PaymentBloc(paymentHandler),
      act: (bloc) => bloc.add(PaymentEventPay(provider: 'test', cartItems: [makeCartItem()])),
      expect: () => [PaymentStateLoading()],
      errors: () => [isA<Exception>()],
    );

    blocTest<PaymentBloc, PaymentState>(
      'ReturnToProvider emits PaymentStateUserAtProvider',
      setUp: () {
        mockUrlLauncherChannel();
      },
      build: () => PaymentBloc(MockPaymentOuterHandler()),
      act: (bloc) => bloc.add(PaymentEventReturnToProvider(link: 'https://example.com/return')),
      expect: () => [isA<PaymentStateUserAtProvider>()],
    );
  });
}
