import 'dart:async';

import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:crabpay/core/backend/supabase/supabase_variable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionMonitorToSupabaseAtRegred implements InnerConnectionMonitor {
  final StreamController<ServerConnectionStatus> _connectionController = StreamController<ServerConnectionStatus>.broadcast();

  StreamSubscription? _appLifecycleSub;
  final AppLifecycleService _appLifecycleService;
  final SupabaseClient? _supabaseClient;

  ConnectionMonitorToSupabaseAtRegred({
    required AppLifecycleService appLifecycleService,
    SupabaseClient? supabaseClient,
  }) : _appLifecycleService = appLifecycleService,
       _supabaseClient = supabaseClient {
    _initSocketListenersOnce();
    _initAppLifecycleService();
  }

  SupabaseClient get _client => _supabaseClient ?? supabase;

  void _initAppLifecycleService() {
    _appLifecycleSub = _appLifecycleService.appStateStream.listen((state) {
      if (state == AppState.active) {
        _pingServerHealth();
      }
    });
  }

  void _initSocketListenersOnce() {
    _client.realtime.onOpen(() {
      if (!_connectionController.isClosed) {
        _connectionController.add(ServerConnectionStatus.online);
      }
    });

    _client.realtime.onClose((event) {
      if (!_connectionController.isClosed) {
        _connectionController.add(ServerConnectionStatus.offline);
      }
    });

    _client.realtime.onError((error) {
      if (!_connectionController.isClosed) {
        _connectionController.add(ServerConnectionStatus.offline);
      }
    });
  }

  Future<void> _pingServerHealth() async {
    try {
      await _client.from('cartItem').select('id').limit(1).timeout(const Duration(seconds: 4));

      if (!_connectionController.isClosed) {
        _connectionController.add(ServerConnectionStatus.online);
      }
    } catch (_) {
      if (!_connectionController.isClosed) {
        _connectionController.add(ServerConnectionStatus.offline);
      }
    }
  }

  @override
  Stream<ServerConnectionStatus> get statusStream => _connectionController.stream;

  @override
  ServerConnectionStatus get currentStatus => _client.realtime.isConnected ? ServerConnectionStatus.online : ServerConnectionStatus.offline;

  @override
  void dispose() {
    _appLifecycleSub?.cancel();
    _connectionController.close();
  }
}
