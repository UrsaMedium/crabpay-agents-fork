import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_outer_circle/admin_outer_chat_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/platform_channel_mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFakeLogger();
  });
  tearDownAll(unregisterFakeLogger);

  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late AdminOuterChatHandlerWithSupabase handler;

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => supabase.auth).thenReturn(auth);
    handler = AdminOuterChatHandlerWithSupabase(client: supabase, retryOptions: noRetry);
  });

  test('constructs with an injected SupabaseClient', () {
    expect(handler, isA<AdminOuterChatHandlerWithSupabase>());
  });

  test('markMessagesAsReadAdmin returns early when there is no signed-in user', () async {
    when(() => auth.currentUser).thenReturn(null);

    await handler.markMessagesAsReadAdmin(threadId: 'thread-1');

    verifyNever(() => supabase.from(any()));
  });
}
