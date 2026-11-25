import 'dart:async';

import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/connection_monitor_cubit.dart';
import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockInnerConnectionMonitor monitor;
  late StreamController<ServerConnectionStatus> statusController;
  final List<ConnectionMonitorCubit> createdCubits = <ConnectionMonitorCubit>[];

  setUp(() {
    monitor = MockInnerConnectionMonitor();
    statusController = StreamController<ServerConnectionStatus>.broadcast();
  });

  tearDown(() async {
    for (final cubit in createdCubits) {
      if (!cubit.isClosed) {
        await cubit.close();
      }
    }
    createdCubits.clear();
    await statusController.close();
  });

  ConnectionMonitorCubit buildCubit({ServerConnectionStatus current = ServerConnectionStatus.initial}) {
    // Stubs must be registered before the cubit is constructed.
    when(() => monitor.currentStatus).thenReturn(current);
    when(() => monitor.statusStream).thenAnswer((_) => statusController.stream);
    final cubit = ConnectionMonitorCubit(connectionMonitor: monitor);
    createdCubits.add(cubit);
    return cubit;
  }

  test('initial state matches currentStatus', () {
    final cubit = buildCubit(current: ServerConnectionStatus.online);
    expect(cubit.state.status, ServerConnectionStatus.online);
  });

  test('isOnline is true only when status is online', () {
    expect(buildCubit(current: ServerConnectionStatus.initial).state.isOnline, isFalse);
    expect(buildCubit(current: ServerConnectionStatus.connecting).state.isOnline, isFalse);
    expect(buildCubit(current: ServerConnectionStatus.online).state.isOnline, isTrue);
    expect(buildCubit(current: ServerConnectionStatus.offline).state.isOnline, isFalse);
  });

  test('emitting statuses on the stream updates the state', () async {
    final cubit = buildCubit(current: ServerConnectionStatus.initial);
    expect(cubit.state.status, ServerConnectionStatus.initial);

    statusController.add(ServerConnectionStatus.connecting);
    await pumpEventQueue();
    expect(cubit.state.status, ServerConnectionStatus.connecting);
    expect(cubit.state.isOnline, isFalse);

    statusController.add(ServerConnectionStatus.online);
    await pumpEventQueue();
    expect(cubit.state.status, ServerConnectionStatus.online);
    expect(cubit.state.isOnline, isTrue);

    statusController.add(ServerConnectionStatus.offline);
    await pumpEventQueue();
    expect(cubit.state.status, ServerConnectionStatus.offline);
    expect(cubit.state.isOnline, isFalse);
  });

  test('close() cancels the status subscription', () async {
    final cubit = buildCubit(current: ServerConnectionStatus.initial);
    expect(statusController.hasListener, isTrue);

    await cubit.close();

    expect(cubit.isClosed, isTrue);
    expect(statusController.hasListener, isFalse);
  });
}
