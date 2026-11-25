import 'package:crabpay/views/main_screen/_sub/auth_views/login_view/login_view_driver.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/password_forgot_view/password_forgot_view_driver.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/register_view/register_view_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginViewCubit', () {
    test('reports invalid email for empty or non-mail input', () {
      final cubit = LoginViewCubit();
      addTearDown(cubit.close);
      var onValidCalled = false;
      cubit.validateAndSubmit(email: '', password: '123456', onValid: (_, _) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not alid');

      cubit.validateAndSubmit(email: 'no-at-sign', password: '123456', onValid: (_, _) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not alid');
      expect(onValidCalled, isFalse);
    });

    test('reports invalid password shorter than 6 chars', () {
      final cubit = LoginViewCubit();
      addTearDown(cubit.close);
      var onValidCalled = false;
      cubit.validateAndSubmit(
        email: 'user@example.com',
        password: '123',
        onValid: (_, _) => onValidCalled = true,
      );
      expect(cubit.state.passwordError, 'Password is not valid');
      expect(onValidCalled, isFalse);
    });

    test('calls onValid and sets isSubmitting for valid input', () {
      final cubit = LoginViewCubit();
      addTearDown(cubit.close);
      var validArgs = '';
      cubit.validateAndSubmit(
        email: 'user@example.com',
        password: '123456',
        onValid: (email, password) => validArgs = '$email/$password',
      );
      expect(validArgs, 'user@example.com/123456');
      expect(cubit.state.isSubmitting, true);
      expect(cubit.state.emailError, isNull);
      expect(cubit.state.passwordError, isNull);
    });

    test('setErrors stores messages and clearErrors resets them', () {
      final cubit = LoginViewCubit();
      addTearDown(cubit.close);
      cubit.setErrors(emailError: 'a', passwordError: 'b');
      expect(cubit.state.emailError, 'a');
      expect(cubit.state.passwordError, 'b');
      cubit.clearErrors();
      expect(cubit.state.emailError, isNull);
      expect(cubit.state.passwordError, isNull);
    });
  });

  group('RegisterViewCubit', () {
    test('reports invalid email for empty or non-mail input', () {
      final cubit = RegisterViewCubit();
      addTearDown(cubit.close);
      var onValidCalled = false;
      cubit.validateAndSubmit(email: '', password: '123456', onValid: (_, _) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not alid');
      expect(onValidCalled, isFalse);

      cubit.validateAndSubmit(email: 'no-at-sign', password: '123456', onValid: (_, _) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not alid');
      expect(onValidCalled, isFalse);
    });

    test('reports invalid password shorter than 6 chars', () {
      final cubit = RegisterViewCubit();
      addTearDown(cubit.close);
      var onValidCalled = false;
      cubit.validateAndSubmit(
        email: 'user@example.com',
        password: '12345',
        onValid: (_, _) => onValidCalled = true,
      );
      expect(cubit.state.passwordError, 'Password is not valid');
      expect(onValidCalled, isFalse);
    });

    test('calls onValid and sets isSubmitting for valid input', () {
      final cubit = RegisterViewCubit();
      addTearDown(cubit.close);
      var valid = false;
      cubit.validateAndSubmit(
        email: 'user@example.com',
        password: '123456',
        onValid: (email, password) => valid = true,
      );
      expect(valid, true);
      expect(cubit.state.isSubmitting, true);
    });

    test('setErrors stores messages and clearErrors resets them', () {
      final cubit = RegisterViewCubit();
      addTearDown(cubit.close);
      cubit.setErrors(emailError: 'a', passwordError: 'b');
      expect(cubit.state.emailError, 'a');
      expect(cubit.state.passwordError, 'b');
      cubit.clearErrors();
      expect(cubit.state.emailError, isNull);
      expect(cubit.state.passwordError, isNull);
    });
  });

  group('PasswordForgotViewCubit', () {
    test('reports invalid email for empty or non-mail input', () {
      final cubit = PasswordForgotViewCubit();
      addTearDown(cubit.close);
      var onValidCalled = false;
      cubit.validateAndSubmit(email: '', onValid: (_) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not valid');
      expect(onValidCalled, isFalse);

      cubit.validateAndSubmit(email: 'no-at-sign', onValid: (_) => onValidCalled = true);
      expect(cubit.state.emailError, 'Email is not valid');
      expect(onValidCalled, isFalse);
    });

    test('calls onValid and sets isSubmitting for valid input', () {
      final cubit = PasswordForgotViewCubit();
      addTearDown(cubit.close);
      var valid = false;
      cubit.validateAndSubmit(
        email: 'user@example.com',
        onValid: (email) => valid = true,
      );
      expect(valid, true);
      expect(cubit.state.isSubmitting, true);
    });

    test('clearErrors resets the error', () {
      final cubit = PasswordForgotViewCubit();
      addTearDown(cubit.close);
      cubit.validateAndSubmit(email: '', onValid: (_) {});
      expect(cubit.state.emailError, 'Email is not valid');
      cubit.clearErrors();
      expect(cubit.state.emailError, isNull);
    });
  });
}
