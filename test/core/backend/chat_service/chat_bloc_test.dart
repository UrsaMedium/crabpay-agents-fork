import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_bloc.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_event.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/chat_bloc/chat_state.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/support_thread_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockAuthInnerInterface authInterface;
  late StreamController<AppAuthUser> authController;
  late MockInnerChatHandler chatHandler;
  late SupportThread thread;

  setUp(() {
    authInterface = MockAuthInnerInterface();
    authController = StreamController<AppAuthUser>.broadcast();
    addTearDown(authController.close);
    when(() => authInterface.userStream).thenAnswer((_) => authController.stream);
    chatHandler = MockInnerChatHandler();
    thread = makeSupportThread();
    registerTestFallbackValues();
  });

  void stubMessagesStream(StreamController<List<ChatMessage>> controller) {
    addTearDown(controller.close);
    when(() => chatHandler.subscribeToMessages(threadId: any(named: 'threadId'))).thenAnswer((_) => controller.stream);
  }

  group('ChatBloc', () {
    blocTest<ChatBloc, ChatState>(
      'getOrCreateThread success emits loading, threadInitialized, then subscribed',
      build: () => ChatBloc(chatHandler: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThread(userId: 'user-1')).thenAnswer((_) async => thread);
        stubMessagesStream(StreamController<List<ChatMessage>>.broadcast());
      },
      act: (bloc) => bloc.add(ChatEventInitializeThread(userId: 'user-1')),
      expect: () => [
        const ChatState(status: ChatStates.loading),
        ChatState(status: ChatStates.threadInitialized, activeThread: thread),
        ChatState(status: ChatStates.unsubscribed, activeThread: thread),
        ChatState(status: ChatStates.subscribed, activeThread: thread, isSubscribed: true),
      ],
      verify: (bloc) => expect(bloc.state.status, ChatStates.subscribed),
    );

    blocTest<ChatBloc, ChatState>(
      'getOrCreateThread null emits error state',
      build: () => ChatBloc(chatHandler: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThread(userId: 'user-1')).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(ChatEventInitializeThread(userId: 'user-1')),
      expect: () => [
        const ChatState(status: ChatStates.loading),
        const ChatState(status: ChatStates.error, errorMessage: 'Could not initialize chat thread.'),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'getOrCreateThread error rethrows after emitting error state',
      build: () => ChatBloc(chatHandler: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThread(userId: 'user-1')).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(ChatEventInitializeThread(userId: 'user-1')),
      expect: () => [
        const ChatState(status: ChatStates.loading),
        isA<ChatState>().having((s) => s.status, 'status', ChatStates.error),
      ],
      errors: () => [isA<Exception>()],
    );

    test('MessagesUpdated emits messagesUpdated state', () async {
      final messagesController = StreamController<List<ChatMessage>>.broadcast();
      stubMessagesStream(messagesController);
      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventSubscribeToMessages(threadId: thread.id));
      await pumpEventQueue();

      final messages = [makeChatMessage()];
      messagesController.add(messages);
      await pumpEventQueue();

      expect(bloc.state.status, ChatStates.messagesUpdated);
      expect(bloc.state.messages, messages);
      expect(bloc.state.isSubscribed, isTrue);
    });

    test('SendMessage emits loading then messageSent', () async {
      when(
        () => chatHandler.sendMessage(
          threadId: 'thread-1',
          senderId: 'user-1',
          content: 'Hello',
        ),
      ).thenAnswer((_) async {});

      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventSendMessage(content: 'Hello', senderId: 'user-1', threadId: thread.id));
      await pumpEventQueue();

      expect(bloc.state.status, ChatStates.messageSent);
      verify(
        () => chatHandler.sendMessage(
          threadId: thread.id,
          senderId: 'user-1',
          content: 'Hello',
        ),
      ).called(1);
    });

    blocTest<ChatBloc, ChatState>(
      'SendMessage handler error emits messageSentFailed and rethrows',
      build: () => ChatBloc(chatHandler: chatHandler, authInterface: authInterface),
      setUp: () {
        when(
          () => chatHandler.sendMessage(
            threadId: thread.id,
            senderId: 'user-1',
            content: 'Hello',
          ),
        ).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(ChatEventSendMessage(content: 'Hello', senderId: 'user-1', threadId: thread.id)),
      expect: () => [
        const ChatState(status: ChatStates.loading),
        const ChatState(status: ChatStates.messageSentFailed, errorMessage: 'Failed to send message'),
      ],
      errors: () => [isA<Exception>()],
    );

    test('SendShadowMessage emits loading then shadowMessageSent', () async {
      when(() => chatHandler.getOrCreateThread(userId: 'user-1')).thenAnswer((_) async => thread);
      when(
        () => chatHandler.sendShadowMessage(
          threadId: thread.id,
          senderId: 'user-1',
          content: 'Hello',
          shadowContent: 'shh',
        ),
      ).thenAnswer((_) async {});

      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventSendShadowMessage(content: 'Hello', senderId: 'user-1', shadowContent: 'shh'));
      await pumpEventQueue();

      expect(bloc.state.status, ChatStates.shadowMessageSent);
      verify(
        () => chatHandler.sendShadowMessage(
          threadId: thread.id,
          senderId: 'user-1',
          content: 'Hello',
          shadowContent: 'shh',
        ),
      ).called(1);
    });

    blocTest<ChatBloc, ChatState>(
      'SendShadowMessage handler error emits shadowMessageSentFailed and rethrows',
      build: () => ChatBloc(chatHandler: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThread(userId: any(named: 'userId'))).thenAnswer((_) async => thread);
        when(
          () => chatHandler.sendShadowMessage(
            threadId: thread.id,
            senderId: 'user-1',
            content: 'Hello',
            shadowContent: 'shh',
          ),
        ).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(ChatEventSendShadowMessage(content: 'Hello', senderId: 'user-1', shadowContent: 'shh')),
      expect: () => [
        const ChatState(status: ChatStates.loading),
        isA<ChatState>().having((s) => s.status, 'status', ChatStates.shadowMessageSentFailed).having((s) => s.errorMessage, 'errorMessage', contains('boom')),
      ],
      errors: () => [isA<Exception>()],
    );

    test('markMessagesAsRead is not wired to any event in ChatBloc', () async {
      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      expect(
        () => bloc.add(ChatEventMarkAsRead()),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('ChatEventMarkAsRead'))),
      );
    });

    test('Unsubscribe emits unsubscribed state and calls handler', () async {
      when(() => chatHandler.unsubscribeFromMessages()).thenAnswer((_) {});

      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventUnsubscribe());
      await pumpEventQueue();

      expect(bloc.state.status, ChatStates.unsubscribed);
      expect(bloc.state.isSubscribed, isFalse);
      verify(() => chatHandler.unsubscribeFromMessages()).called(1);
    });

    test('auth user change flushes state and unsubscribes', () async {
      when(() => chatHandler.unsubscribeFromMessages()).thenAnswer((_) {});

      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      final statuses = <ChatState>[];
      bloc.stream.listen(statuses.add);

      authController.add(makeAuthUser());
      await pumpEventQueue();

      expect(statuses, anyElement(isA<ChatState>().having((s) => s.status, 'status', ChatStates.flushed)));
      expect(bloc.state.activeThread, isNull);
      verify(() => chatHandler.unsubscribeFromMessages()).called(1);
    });

    test('close cancels the messages subscription and ignores later stream events', () async {
      final messagesController = StreamController<List<ChatMessage>>.broadcast();
      stubMessagesStream(messagesController);
      final bloc = ChatBloc(chatHandler: chatHandler, authInterface: authInterface);

      final statuses = <ChatState>[];
      final streamSub = bloc.stream.listen(statuses.add);
      addTearDown(streamSub.cancel);

      bloc.add(ChatEventSubscribeToMessages(threadId: thread.id));
      await pumpEventQueue();

      // Both injected streams have listeners while the bloc is alive.
      expect(messagesController.hasListener, isTrue);
      expect(authController.hasListener, isTrue);

      final statusAtClose = bloc.state;
      final emittedBeforeClose = statuses.length;
      await bloc.close();

      // Observable proof: both subscriptions are gone and post-close emits are ignored.
      expect(messagesController.hasListener, isFalse);
      expect(authController.hasListener, isFalse);
      messagesController.add([makeChatMessage(content: 'after close')]);
      authController.add(makeAuthUser(id: 'user-after-close'));
      await pumpEventQueue();
      expect(statuses, hasLength(emittedBeforeClose));
      expect(bloc.state, statusAtClose);
    });
  });
}
