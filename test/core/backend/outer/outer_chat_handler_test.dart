import 'dart:async';

import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/chat_service/chat_outer_circle/outer_chat_handler.dart';
import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockInnerConnectionMonitor monitor;
  late FakeAppLifecycleService lifecycle;
  late StreamController<ServerConnectionStatus> statusController;
  late OuterChatHandlerWithSupabase handler;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    supabase = MockSupabaseClient();
    monitor = MockInnerConnectionMonitor();
    lifecycle = FakeAppLifecycleService();
    statusController = StreamController<ServerConnectionStatus>.broadcast();

    // The handler subscribes to both streams in its constructor.
    when(() => monitor.statusStream).thenAnswer((_) => statusController.stream);

    handler = OuterChatHandlerWithSupabase(
      appLifecycleService: lifecycle,
      connectionMonitor: monitor,
      client: supabase,
      retryOptions: noRetry,
    );
  });

  tearDown(() async {
    handler.dispose();
    await statusController.close();
    lifecycle.dispose();
  });

  test('uses the injected SupabaseClient without initializing the singleton', () async {
    // Constructing with an injected client is enough: Supabase.instance is not
    // initialized in unit tests and would throw if it were touched.
    expect(handler, isA<OuterChatHandlerWithSupabase>());
    await pumpEventQueue();
  });

  test('stays disconnected while no thread is subscribed', () async {
    statusController.add(ServerConnectionStatus.online);
    lifecycle.emit(AppState.active);
    await pumpEventQueue();

    verifyNever(() => supabase.from(any()));
  });

  test('unsubscribeFromMessages is safe before any subscription', () async {
    expect(() => handler.unsubscribeFromMessages(), returnsNormally);
    await pumpEventQueue();
    verifyNever(() => supabase.from(any()));
  });
}
