import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_inner_circle/chat_bloc/admin_chat_bloc.dart';
import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_inner_circle/chat_bloc/adminchat_event.dart';
import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_inner_circle/chat_bloc/admin_chat_state.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/support_thread_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockAuthInnerInterface authInterface;
  late StreamController<AppAuthUser> authController;
  late MockAdminInnerChatHandler chatHandler;
  late SupportThread thread;

  setUp(() {
    authInterface = MockAuthInnerInterface();
    authController = StreamController<AppAuthUser>.broadcast();
    addTearDown(authController.close);
    when(() => authInterface.userStream).thenAnswer((_) => authController.stream);
    chatHandler = MockAdminInnerChatHandler();
    thread = makeSupportThread();
    registerTestFallbackValues();
  });

  void stubMessagesStream(StreamController<List<ChatMessage>> controller) {
    addTearDown(controller.close);
    when(() => chatHandler.subscribeToMessagesAdmin(threadId: any(named: 'threadId'))).thenAnswer((_) => controller.stream);
  }

  group('ChatBlocAdmin', () {
    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'FetchAllThreadsAdmin success emits loading then fetchedAllThreads',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getAllThreadsAdmin()).thenAnswer((_) async => <SupportThread>[thread, makeSupportThread(id: 'thread-2')]);
      },
      act: (bloc) => bloc.add(ChatEventFetchAllThreadsAdmin()),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        isA<ChatStateAdmin>().having((s) => s.status, 'status', ChatStatesAdmin.fetchedAllThreads).having((s) => s.allThreads, 'allThreads', hasLength(2)),
      ],
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'FetchAllThreadsAdmin empty emits error',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getAllThreadsAdmin()).thenAnswer((_) async => <SupportThread>[]);
      },
      act: (bloc) => bloc.add(ChatEventFetchAllThreadsAdmin()),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        const ChatStateAdmin(status: ChatStatesAdmin.error),
      ],
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'FetchAllThreadsAdmin error rethrows after emitting error state',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getAllThreadsAdmin()).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(ChatEventFetchAllThreadsAdmin()),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        isA<ChatStateAdmin>().having((s) => s.status, 'status', ChatStatesAdmin.error),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'InitializeThreadAdmin success emits loading then threadInitialized',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenAnswer((_) async => thread);
        stubMessagesStream(StreamController<List<ChatMessage>>.broadcast());
      },
      act: (bloc) => bloc.add(ChatEventInitializeThreadAdmin(userId: 'user-1')),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        ChatStateAdmin(status: ChatStatesAdmin.threadInitialized, activeThread: thread),
      ],
      verify: (bloc) => expect(bloc.state.activeThread?.id, thread.id),
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'InitializeThreadAdmin null emits error state',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(ChatEventInitializeThreadAdmin(userId: 'user-1')),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        const ChatStateAdmin(status: ChatStatesAdmin.error, errorMessage: 'Could not initialize chat thread.'),
      ],
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'InitializeThreadAdmin error rethrows after emitting error state',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(ChatEventInitializeThreadAdmin(userId: 'user-1')),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.loading),
        isA<ChatStateAdmin>().having((s) => s.status, 'status', ChatStatesAdmin.error),
      ],
      errors: () => [isA<Exception>()],
    );

    test('MessagesUpdatedAdmin emits messagesUpdated and marks messages read', () async {
      when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenAnswer((_) async => thread);
      stubMessagesStream(StreamController<List<ChatMessage>>.broadcast());
      when(() => chatHandler.markMessagesAsReadAdmin(threadId: thread.id)).thenAnswer((_) async {});

      final bloc = ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventInitializeThreadAdmin(userId: 'user-1'));
      await pumpEventQueue();

      final messages = [makeChatMessage()];
      bloc.add(ChatEventMessagesUpdatedAdmin(messages: messages));
      await pumpEventQueue();

      expect(bloc.state.status, ChatStatesAdmin.messagesUpdated);
      expect(bloc.state.messages, messages);
      verify(() => chatHandler.markMessagesAsReadAdmin(threadId: thread.id)).called(1);
    });

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'SendMessageAdmin emits messageSent',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      setUp: () {
        when(
          () => chatHandler.sendMessageAdmin(
            threadId: thread.id,
            senderId: 'user-1',
            content: 'Hello',
          ),
        ).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(ChatEventSendMessageAdmin(content: 'Hello', senderId: 'user-1', threadId: thread.id)),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.messageSent),
      ],
    );

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'SendMessageAdmin handler error emits messageSendFailed and rethrows',
      setUp: () {
        when(
          () => chatHandler.sendMessageAdmin(
            threadId: thread.id,
            senderId: 'user-1',
            content: 'Hello',
          ),
        ).thenThrow(Exception('boom'));
      },
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      act: (bloc) => bloc.add(ChatEventSendMessageAdmin(content: 'Hello', senderId: 'user-1', threadId: thread.id)),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.messageSendFailed, errorMessage: 'Failed to send message'),
      ],
      errors: () => [isA<Exception>()],
    );

    test('MarkAsReadAdmin calls handler with activeThread id', () async {
      when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenAnswer((_) async => thread);
      stubMessagesStream(StreamController<List<ChatMessage>>.broadcast());
      when(() => chatHandler.markMessagesAsReadAdmin(threadId: thread.id)).thenAnswer((_) async {});

      final bloc = ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventInitializeThreadAdmin(userId: 'user-1'));
      await pumpEventQueue();

      bloc.add(ChatEventMarkAsReadAdmin());
      await pumpEventQueue();

      verify(() => chatHandler.markMessagesAsReadAdmin(threadId: thread.id)).called(1);
    });

    test('MarkAsReadAdmin without active thread does not call handler', () async {
      final bloc = ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      bloc.add(ChatEventMarkAsReadAdmin());
      await pumpEventQueue();

      verifyNever(() => chatHandler.markMessagesAsReadAdmin(threadId: any(named: 'threadId')));
    });

    blocTest<ChatBlocAdmin, ChatStateAdmin>(
      'FlushDataAdmin emits flushed',
      build: () => ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface),
      act: (bloc) => bloc.add(ChatEventFlushDataAdmin()),
      expect: () => [
        const ChatStateAdmin(status: ChatStatesAdmin.flushed),
      ],
    );

    test('auth user change flushes and reinitializes', () async {
      when(() => chatHandler.getOrCreateThreadAdmin(userId: 'user-1')).thenAnswer((_) async => thread);
      stubMessagesStream(StreamController<List<ChatMessage>>.broadcast());

      final bloc = ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface);
      addTearDown(bloc.close);

      final statuses = <ChatStateAdmin>[];
      bloc.stream.listen(statuses.add);

      authController.add(makeAuthUser());
      await pumpEventQueue();

      expect(statuses, anyElement(isA<ChatStateAdmin>().having((s) => s.status, 'status', ChatStatesAdmin.flushed)));
      expect(bloc.state.status, ChatStatesAdmin.threadInitialized);
      expect(bloc.state.activeThread?.id, thread.id);
    });

    test('close cancels the messages subscription and ignores later stream events', () async {
      final messagesController = StreamController<List<ChatMessage>>.broadcast();
      stubMessagesStream(messagesController);
      final bloc = ChatBlocAdmin(chatHandlerAdmin: chatHandler, authInterface: authInterface);

      final statuses = <ChatStateAdmin>[];
      final streamSub = bloc.stream.listen(statuses.add);
      addTearDown(streamSub.cancel);

      bloc.add(ChatEventSubscribeToMessagesAdmin(threadId: thread.id));
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
