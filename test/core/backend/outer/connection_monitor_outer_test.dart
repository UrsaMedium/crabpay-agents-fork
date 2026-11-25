import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:crabpay/core/backend/connection_monitoring/outer_monitor/connection_monitor_to_supabase_at_regred.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(() {});
    registerFallbackValue((dynamic _) {});
  });

  group('ConnectionMonitorToSupabaseAtRegred', () {
    late MockSupabaseClient mockSupabase;
    late MockRealtimeClient mockRealtime;
    late ConnectionMonitorToSupabaseAtRegred monitor;
    void Function()? onOpenCallback;
    void Function(dynamic)? onCloseCallback;
    void Function(dynamic)? onErrorCallback;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockRealtime = MockRealtimeClient();
      when(() => mockSupabase.realtime).thenReturn(mockRealtime);
      when(() => mockRealtime.onOpen(any())).thenAnswer((invocation) {
        onOpenCallback = invocation.positionalArguments.first as void Function();
      });
      when(() => mockRealtime.onClose(any())).thenAnswer((invocation) {
        onCloseCallback = invocation.positionalArguments.first as void Function(dynamic);
      });
      when(() => mockRealtime.onError(any())).thenAnswer((invocation) {
        onErrorCallback = invocation.positionalArguments.first as void Function(dynamic);
      });
      when(() => mockRealtime.isConnected).thenReturn(true);
      final lifecycle = FakeAppLifecycleService();
      addTearDown(lifecycle.dispose);
      monitor = ConnectionMonitorToSupabaseAtRegred(
        appLifecycleService: lifecycle,
        supabaseClient: mockSupabase,
      );
    });

    tearDown(() {
      monitor.dispose();
    });

    test('currentStatus is online when realtime is connected', () {
      expect(monitor.currentStatus, ServerConnectionStatus.online);
    });

    test('currentStatus is offline when realtime is not connected', () {
      when(() => mockRealtime.isConnected).thenReturn(false);
      expect(monitor.currentStatus, ServerConnectionStatus.offline);
    });

    test('statusStream emits online/offline when realtime callbacks fire', () async {
      final statuses = <ServerConnectionStatus>[];
      final sub = monitor.statusStream.listen(statuses.add);
      addTearDown(sub.cancel);

      expect(onOpenCallback, isNotNull);
      expect(onCloseCallback, isNotNull);
      expect(onErrorCallback, isNotNull);

      onOpenCallback!();
      await pumpEventQueue();
      expect(statuses, [ServerConnectionStatus.online]);

      onCloseCallback!('closed');
      await pumpEventQueue();
      expect(statuses, [ServerConnectionStatus.online, ServerConnectionStatus.offline]);

      onErrorCallback!('socket error');
      await pumpEventQueue();
      expect(statuses, [ServerConnectionStatus.online, ServerConnectionStatus.offline, ServerConnectionStatus.offline]);

      verify(() => mockRealtime.onOpen(any())).called(1);
      verify(() => mockRealtime.onClose(any())).called(1);
      verify(() => mockRealtime.onError(any())).called(1);
    });

    test('dispose closes the stream and cancels the lifecycle subscription without throwing', () async {
      var done = false;
      monitor.statusStream.listen(null, onDone: () => done = true);
      monitor.dispose();
      await pumpEventQueue();
      expect(done, isTrue);
    });
  });
}
