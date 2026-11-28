import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/support_thread_model.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/data_models/chat_message_model.dart';
import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_inner_circle/admin_inner_chat_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';

class AdminOuterChatHandlerWithSupabase implements AdminInnerChatHandler {
  final SupabaseClient _client;
  final RetryOptions retryer;

  AdminOuterChatHandlerWithSupabase({SupabaseClient? client, RetryOptions? retryOptions})
    : _client = client ?? Supabase.instance.client,
      retryer = retryOptions ?? const RetryOptions(maxAttempts: 3, delayFactor: Duration(microseconds: 500));

  @override
  Future<SupportThread?> getOrCreateThreadAdmin({
    required String userId,
  }) async {
    try {
      return await retryer.retry(() async {
        final existing = await _client.from('support_threads').select().eq('user_id', userId).maybeSingle();

        if (existing != null) {
          return SupportThread(
            id: existing['id'] as String,
            userId: existing['user_id'] as String,
            status: existing['status'] as String,
          );
        }

        final created = await _client.from('support_threads').insert({'user_id': userId, 'status': 'open'}).select().single();

        return SupportThread(
          id: created['id'] as String,
          userId: created['user_id'] as String,
          status: created['status'] as String,
        );
      });
    } catch (e) {
      debugPrint('Failed to get or create support thread: $e');
      Fluttertoast.showToast(msg: 'failedToGetOrCreate');
      rethrow;
    }
  }

  @override
  Future<void> markMessagesAsReadAdmin({required String threadId}) async {
    try {
      // Mark all messages in this thread NOT sent by the current user as read
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return;

      await _client.from('chat_messages').update({'is_read': true}).eq('thread_id', threadId).neq('sender_id', currentUserId);
    } catch (e) {
      debugPrint('Failed to mark messages as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessageAdmin({
    required String threadId,
    required String senderId,
    required String content,
  }) async {
    try {
      await retryer.retry(() async {
        await _client.from('chat_messages').insert({
          'thread_id': threadId,
          'sender_id': senderId,
          'content': content,
        });
      });
    } catch (e) {
      debugPrint('Failed to send message: $e');
      Fluttertoast.showToast(msg: 'failedToSendMessagePlease');
      rethrow;
    }
  }

  @override
  Stream<List<ChatMessage>> subscribeToMessagesAdmin({
    required String threadId,
  }) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .order('created_at', ascending: true)
        .map((
          List<Map<String, dynamic>> data,
        ) {
          return data
              .map(
                (json) => ChatMessage(
                  id: json['id'] as String,
                  threadId: json['thread_id'] as String,
                  senderId: json['sender_id'] as String,
                  content: json['content'] as String,
                  isRead: json['is_read'] as bool? ?? false,
                  createdAt: DateTime.parse(json['created_at'] as String),
                ),
              )
              .toList();
        });
  }

  @override
  Future<List<SupportThread>> getAllThreadsAdmin() async {
    try {
      final fetchedAllThreads = await retryer.retry(() {
        return _client.from('support_threads').select();
      });
      List<SupportThread> allThreads = [];
      for (var thread in fetchedAllThreads) {
        allThreads.add(
          SupportThread(
            id: thread['id'] as String,
            userId: thread['user_id'] as String,
            status: thread['status'] as String,
          ),
        );
      }
      return allThreads;
    } catch (e) {
      debugPrint('Failed to fetch all threads: $e');
      Fluttertoast.showToast(msg: 'failedToFetchAllThreads');
      rethrow;
    }
  }
}

// await _client.auth.refreshSession();
