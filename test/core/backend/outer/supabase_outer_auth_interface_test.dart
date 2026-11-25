import 'dart:async';

import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_exceptions.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/authentication/auth_outer_circle/supabase_outer_auth_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/platform_channel_mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerTestFallbackValues();
    registerFakeLogger();
  });

  tearDownAll(() {
    unregisterFakeLogger();
  });

  group('SupabaseOuterAuthInterface', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockGoTrue;
    late SupabaseOuterAuthInterface authInterface;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockGoTrue = MockGoTrueClient();
      when(() => mockSupabase.auth).thenReturn(mockGoTrue);
      authInterface = SupabaseOuterAuthInterface(supabaseClient: mockSupabase, retryOptions: noRetry);
    });

    MockUser stubUser() {
      final user = MockUser();
      when(() => user.id).thenReturn('user-1');
      when(() => user.email).thenReturn('user@example.com');
      when(() => user.appMetadata).thenReturn({'role': 'admin'});
      when(() => user.emailConfirmedAt).thenReturn('2026-01-15T10:30:00Z');
      when(() => user.userMetadata).thenReturn(null);
      when(() => user.isAnonymous).thenReturn(false);
      return user;
    }

    void stubAuthStateStream(StreamController<AuthState> controller) {
      addTearDown(controller.close);
      when(() => mockGoTrue.onAuthStateChange).thenAnswer((_) => controller.stream);
    }

    test('userStream maps signed-in auth states to AppAuthUser', () async {
      final authStates = StreamController<AuthState>.broadcast();
      stubAuthStateStream(authStates);
      final user = stubUser();
      final session = MockSession();
      when(() => session.user).thenReturn(user);

      final emitted = <AppAuthUser>[];
      final sub = authInterface.userStream.listen(emitted.add);
      addTearDown(sub.cancel);

      authStates.add(AuthState(AuthChangeEvent.signedIn, session));
      await pumpEventQueue();

      expect(emitted, hasLength(1));
      expect(emitted.single.id, 'user-1');
      expect(emitted.single.email, 'user@example.com');
      expect(emitted.single.isAdmin, isTrue);
      expect(emitted.single.isEmailVerified, isTrue);
    });

    test('userStream falls back to currentUser on an initialSession without a session', () async {
      final authStates = StreamController<AuthState>.broadcast();
      stubAuthStateStream(authStates);
      final user = stubUser();
      when(() => mockGoTrue.currentUser).thenReturn(user);

      final emitted = <AppAuthUser>[];
      final sub = authInterface.userStream.listen(emitted.add);
      addTearDown(sub.cancel);

      authStates.add(const AuthState(AuthChangeEvent.initialSession, null));
      await pumpEventQueue();

      expect(emitted, hasLength(1));
      expect(emitted.single.id, 'user-1');
      verifyNever(() => mockGoTrue.signInAnonymously());
    });

    test('getUser returns null when currentUser is null', () async {
      when(() => mockGoTrue.currentUser).thenReturn(null);
      expect(await authInterface.getUser(), isNull);
    });

    test('getUser maps an admin + email-verified Supabase user', () async {
      final user = stubUser();
      when(() => mockGoTrue.currentUser).thenReturn(user);
      final authUser = await authInterface.getUser();
      expect(authUser, isNotNull);
      expect(authUser!.id, 'user-1');
      expect(authUser.email, 'user@example.com');
      expect(authUser.isAdmin, isTrue);
      expect(authUser.isEmailVerified, isTrue);
      expect(authUser.isAnonymous, isFalse);
      expect(authUser.isLimbo, isFalse);
    });

    test('signInAnonymously maps AuthException messages to typed exceptions', () async {
      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('The password is too weak');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<WeakPasswordAuthException>()));

      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('Email already in use');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<EmailAlreadyTakenException>()));

      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('invalid login');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<WrongPasswordException>()));

      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('The credentials are incorrect');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<WrongPasswordException>()));

      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('user not found');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<UserNotFoundException>()));

      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async {
        throw AuthException('some unrelated error');
      });
      await expectLater(authInterface.signInAnonymously(), throwsA(isA<GenericAuthException>()));
    });

    test('signInAnonymously returns the mapped user on success', () async {
      final user = stubUser();
      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async => AuthResponse(user: user));
      final authUser = await authInterface.signInAnonymously();
      expect(authUser, isNotNull);
      expect(authUser!.id, 'user-1');
    });

    test('logIn calls signInWithPassword and returns the mapped user', () async {
      final user = stubUser();
      when(() => mockGoTrue.signInWithPassword(email: 'a@example.com', password: 'pw')).thenAnswer((_) async => AuthResponse(user: user));
      when(() => mockGoTrue.currentUser).thenReturn(user);
      final authUser = await authInterface.logIn(email: 'a@example.com', password: 'pw');
      verify(() => mockGoTrue.signInWithPassword(email: 'a@example.com', password: 'pw')).called(1);
      expect(authUser.id, 'user-1');
    });

    test('createUser signs up when no user and calls signUp', () async {
      final user = stubUser();
      when(() => mockGoTrue.currentUser).thenReturn(null);
      when(() => mockGoTrue.signInAnonymously()).thenAnswer((_) async => AuthResponse(user: null));
      when(() => mockGoTrue.signUp(email: 'a@example.com', password: 'pw')).thenAnswer((_) async => AuthResponse(session: MockSession(), user: user));
      when(() => mockGoTrue.currentUser).thenReturn(user);
      final authUser = await authInterface.createUser(email: 'a@example.com', password: 'pw');
      verify(() => mockGoTrue.signUp(email: 'a@example.com', password: 'pw')).called(1);
      expect(authUser.id, 'user-1');
    });

    test('createUser upgrades an anonymous user via updateUser', () async {
      final anonymousUser = MockUser();
      when(() => anonymousUser.id).thenReturn('anon-1');
      when(() => anonymousUser.isAnonymous).thenReturn(true);
      final upgradedUserJson = <String, dynamic>{
        'id': 'user-1',
        'email': 'a@example.com',
        'app_metadata': <String, dynamic>{'role': 'admin'},
        'email_confirmed_at': '2026-01-15T10:30:00Z',
      };
      var currentUserCall = 0;
      when(() => mockGoTrue.currentUser).thenAnswer((_) {
        currentUserCall++;
        return currentUserCall == 1 ? anonymousUser : User.fromJson(upgradedUserJson)!;
      });
      when(
        () => mockGoTrue.updateUser(UserAttributes(email: 'a@example.com', password: 'pw')),
      ).thenAnswer((_) async => UserResponse.fromJson(upgradedUserJson));

      final authUser = await authInterface.createUser(email: 'a@example.com', password: 'pw');

      expect(authUser.id, 'user-1');
      expect(authUser.isAnonymous, isFalse);
      verify(() => mockGoTrue.updateUser(UserAttributes(email: 'a@example.com', password: 'pw'))).called(1);
      verifyNever(() => mockGoTrue.signUp(email: 'a@example.com', password: 'pw'));
    });

    test('logOut calls signOut', () async {
      when(() => mockGoTrue.signOut()).thenAnswer((_) async {});
      await expectLater(authInterface.logOut(), completes);
      verify(() => mockGoTrue.signOut()).called(1);
    });

    test('sendPasswordReset calls resetPasswordForEmail', () async {
      when(() => mockGoTrue.resetPasswordForEmail('to@example.com')).thenAnswer((_) async {});
      await expectLater(authInterface.sendPasswordReset(toEmail: 'to@example.com'), completes);
      verify(() => mockGoTrue.resetPasswordForEmail('to@example.com')).called(1);
    });
  });
}
