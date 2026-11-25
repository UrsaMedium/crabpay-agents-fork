import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_states.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_exceptions.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(registerTestFallbackValues);

  group('AuthBloc', () {
    late StreamController<AppAuthUser> userController;
    late MockAuthInnerInterface authInterface;

    AuthBloc buildAuthBloc(MockAuthInnerInterface authInterface) {
      final bloc = AuthBloc(authInterface);
      addTearDown(bloc.close);
      return bloc;
    }

    test('initial state is AuthStateLoading', () {
      final bloc = buildAuthBloc(MockAuthInnerInterface());
      expect(bloc.state, isA<AuthStateLoading>());
    });

    test('close() cancels the user stream subscription', () async {
      userController = StreamController<AppAuthUser>.broadcast();
      addTearDown(userController.close);
      final authInterface = MockAuthInnerInterface();
      when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
      when(() => authInterface.initialize()).thenAnswer((_) async {});
      final bloc = buildAuthBloc(authInterface);

      bloc.add(AuthEventInitialize());
      await pumpEventQueue();
      expect(userController.hasListener, isTrue);
      await bloc.close();

      // A broadcast controller's add() never throws, so assert the observable
      // effect of close(): the bloc no longer listens to the user stream.
      expect(userController.hasListener, isFalse);
    });

    blocTest(
      'Initialize emits AuthStateLoggedIn when a non-empty user is streamed',
      build: () {
        final authInterface = MockAuthInnerInterface();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        when(() => authInterface.initialize()).thenAnswer((_) async {});
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
        userController.add(makeAuthUser());
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedIn>().having((s) => s.currentUser, 'currentUser', makeAuthUser()),
      ],
    );

    blocTest(
      'Initialize emits AuthStateLoggedOut with the anonymous user when signInAnonymously returns a user',
      build: () {
        final authInterface = MockAuthInnerInterface();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        when(() => authInterface.initialize()).thenAnswer((_) async {});
        when(() => authInterface.signInAnonymously()).thenAnswer((_) async => makeAuthUser(isAnonymous: true));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
        userController.add(AppAuthUser.empty);
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.currentUser, 'currentUser', makeAuthUser(isAnonymous: true)).having((s) => s.reason, 'reason', 'Anon session'),
      ],
    );

    blocTest(
      'Initialize emits AuthStateLoggedOut when signInAnonymously returns null',
      build: () {
        final authInterface = MockAuthInnerInterface();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        when(() => authInterface.initialize()).thenAnswer((_) async {});
        when(() => authInterface.signInAnonymously()).thenAnswer((_) async => null);
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
        userController.add(AppAuthUser.empty);
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.currentUser, 'currentUser', AppAuthUser.empty).having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<Exception>()),
      ],
    );

    blocTest(
      'OnStreamUserChanged emits AuthStateLoggedIn for a non-empty user',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventOnStreamUserChanged(makeAuthUser())),
      expect: () => [isA<AuthStateLoggedIn>().having((s) => s.currentUser, 'currentUser', makeAuthUser())],
    );

    blocTest(
      'OnStreamUserChanged emits AuthStateLoggedOut for an anonymous user',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventOnStreamUserChanged(makeAuthUser(isAnonymous: true))),
      expect: () => [isA<AuthStateLoggedOut>().having((s) => s.currentUser, 'currentUser', makeAuthUser(isAnonymous: true))],
    );

    blocTest(
      'OnStreamUserChanged signs the user in anonymously and emits AuthStateLoggedOut with the anonymous user',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.signInAnonymously()).thenAnswer((_) async => makeAuthUser(isAnonymous: true));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventOnStreamUserChanged(AppAuthUser.empty)),
      expect: () => [
        isA<AuthStateLoggedOut>().having((s) => s.currentUser, 'currentUser', makeAuthUser(isAnonymous: true)).having((s) => s.reason, 'reason', 'Anon session'),
      ],
    );

    blocTest(
      'OnStreamUserChanged emits AuthStateLoggedOut when signInAnonymously returns null',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.signInAnonymously()).thenAnswer((_) async => null);
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventOnStreamUserChanged(AppAuthUser.empty)),
      expect: () => [
        isA<AuthStateLoggedOut>().having((s) => s.currentUser, 'currentUser', AppAuthUser.empty).having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<Exception>()),
      ],
    );

    blocTest(
      'LogIn success emits AuthStateLoggedIn once the user streams',
      build: () {
        authInterface = MockAuthInnerInterface();
        userController = StreamController<AppAuthUser>.broadcast();
        addTearDown(userController.close);
        when(() => authInterface.userStream).thenAnswer((_) => userController.stream);
        when(() => authInterface.initialize()).thenAnswer((_) async {});
        when(() => authInterface.logIn(email: 'user@example.com', password: 'pw')).thenAnswer((_) async => makeAuthUser());
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
        bloc.add(AuthEventLogIn(email: 'user@example.com', password: 'pw'));
        await pumpEventQueue();
        userController.add(makeAuthUser());
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedIn>().having((s) => s.currentUser, 'currentUser', makeAuthUser()),
      ],
      verify: (bloc) {
        verify(() => authInterface.logIn(email: 'user@example.com', password: 'pw')).called(1);
      },
    );

    blocTest(
      'LogIn WrongPasswordException emits AuthStateLoggedOut with the exception',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.logIn(email: 'user@example.com', password: 'pw')).thenThrow(WrongPasswordException());
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventLogIn(email: 'user@example.com', password: 'pw')),
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<WrongPasswordException>()),
      ],
      errors: () => contains(isA<WrongPasswordException>()),
    );

    blocTest(
      'Register success calls createUser and sendEmailVerification',
      build: () {
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.createUser(email: 'user@example.com', password: 'pw')).thenAnswer((_) async => makeAuthUser());
        when(() => authInterface.sendEmailVerification()).thenAnswer((_) async {});
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventRegister(email: 'user@example.com', password: 'pw')),
      expect: () => [isA<AuthStateLoading>()],
      verify: (bloc) {
        verify(() => authInterface.createUser(email: 'user@example.com', password: 'pw')).called(1);
        verify(() => authInterface.sendEmailVerification()).called(1);
      },
    );

    blocTest(
      'Register EmailAlreadyTakenException emits AuthStateLoggedOut with the exception',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.createUser(email: 'user@example.com', password: 'pw')).thenThrow(EmailAlreadyTakenException());
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventRegister(email: 'user@example.com', password: 'pw')),
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<EmailAlreadyTakenException>()),
      ],
    );

    blocTest(
      'ForgotPassword calls sendPasswordReset with the given email',
      build: () {
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.sendPasswordReset(toEmail: 'user@example.com')).thenAnswer((_) async {});
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventForgotPassword(email: 'user@example.com')),
      expect: () => [isA<AuthStateLoading>()],
      verify: (bloc) {
        verify(() => authInterface.sendPasswordReset(toEmail: 'user@example.com')).called(1);
      },
    );

    blocTest(
      'LogOut calls logOut and emits AuthStateLoading',
      build: () {
        authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.logOut()).thenAnswer((_) async {});
        return buildAuthBloc(authInterface);
      },
      act: (bloc) => bloc.add(AuthEventLogOut()),
      expect: () => [isA<AuthStateLoading>()],
      verify: (bloc) {
        verify(() => authInterface.logOut()).called(1);
      },
    );

    blocTest(
      'Initialize emits AuthStateLoggedOut when initialize() throws',
      build: () {
        // AuthEventInitialize calls initialize(), not getUser(); the latter
        // cannot make this event fail even if it throws.
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.initialize()).thenThrow(Exception('init failed'));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<Exception>()).having((s) => s.reason, 'reason', contains('Bloody Authentication Failure')),
      ],
    );

    blocTest(
      'Initialize ignores a throwing getUser() because the bloc never calls it',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.initialize()).thenAnswer((_) async {});
        when(() => authInterface.getUser()).thenThrow(Exception('getUser failed'));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventInitialize());
        await pumpEventQueue();
      },
      expect: () => [isA<AuthStateLoading>()],
      verify: (bloc) {
        verifyNever(() => authInterface.getUser());
      },
    );

    blocTest(
      'LogOut emits AuthStateLoggedOut when logOut() throws',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.logOut()).thenThrow(Exception('logout failed'));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventLogOut());
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<Exception>()).having((s) => s.reason, 'reason', contains('Log Out Failure')),
      ],
    );

    blocTest(
      'ForgotPassword emits AuthStateLoggedOut when sendPasswordReset throws',
      build: () {
        final authInterface = MockAuthInnerInterface();
        when(() => authInterface.userStream).thenAnswer((_) => const Stream.empty());
        when(() => authInterface.sendPasswordReset(toEmail: 'user@example.com')).thenThrow(Exception('reset failed'));
        return buildAuthBloc(authInterface);
      },
      act: (bloc) async {
        bloc.add(AuthEventForgotPassword(email: 'user@example.com'));
        await pumpEventQueue();
      },
      expect: () => [
        isA<AuthStateLoading>(),
        isA<AuthStateLoggedOut>().having((s) => s.bloodyAuthException, 'bloodyAuthException', isA<Exception>()).having((s) => s.reason, 'reason', contains('Password Reset')),
      ],
    );
  });
}
