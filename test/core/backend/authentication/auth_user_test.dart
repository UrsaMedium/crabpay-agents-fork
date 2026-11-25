import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_exceptions.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('AppAuthUser', () {
    test('AppAuthUser.empty is empty', () {
      expect(AppAuthUser.empty.isEmpty, isTrue);
    });

    test('a fixture user is not empty', () {
      expect(makeAuthUser().isNotEmpty, isTrue);
    });

    test('is equal to another user with the same field values', () {
      final a = makeAuthUser();
      final b = makeAuthUser();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when any field differs from a default fixture user', () {
      final base = makeAuthUser();
      final variants = <AppAuthUser>[
        makeAuthUser(id: 'user-2'),
        makeAuthUser(email: null),
        makeAuthUser(email: 'other@example.com'),
        makeAuthUser(isEmailVerified: false),
        makeAuthUser(isAnonymous: true),
        makeAuthUser(isAdmin: true),
        makeAuthUser(isLimbo: true),
      ];
      for (final variant in variants) {
        expect(variant, isNot(equals(base)));
      }
    });

    test('toString contains id, email and flags', () {
      final user = makeAuthUser();
      final description = user.toString();
      expect(description, contains('user-1'));
      expect(description, contains('user@example.com'));
      expect(description, contains('isAnonymous'));
      expect(description, contains('isAdmin'));
      expect(description, contains('isLimbo'));
    });
  });

  group('auth exceptions', () {
    test('all exception classes instantiate as Exceptions', () {
      expect(UserNotFoundException(), isA<Exception>());
      expect(WrongPasswordException(), isA<Exception>());
      expect(EmailAlreadyTakenException(), isA<Exception>());
      expect(GenericAuthException(), isA<Exception>());
      expect(NoUserSignInException(), isA<Exception>());
      expect(AuthExceptions(), isA<Exception>());
      expect(WeakPasswordAuthException(), isA<Exception>());
      expect(InvalidEmailAuthException(), isA<Exception>());
      expect(EmailVerificationNeeded(), isA<Exception>());
    });
  });
}
