import 'package:crabpay/core/backend/logger/logger_inner_handler/inner_logger_handler.dart';
import 'package:crabpay/core/utilities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

/// Prevents `MissingPluginException` from `Fluttertoast` in outer-handler
/// error paths.
void mockFlutterToastChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('PonnamKarthik/fluttertoast'),
    (MethodCall call) async => true,
  );
}

/// Lets `launchUrl` resolve inside unit tests without a real platform plugin.
void mockUrlLauncherChannel({bool launchResult = true}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/url_launcher'),
    (MethodCall call) async => launchResult,
  );
}

/// Registers a no-op logger in the global service locator. Outer handlers call
/// `getIt<InnerLoggerHandler>()` directly.
FakeInnerLoggerHandler registerFakeLogger() {
  final FakeInnerLoggerHandler logger = FakeInnerLoggerHandler();
  if (getIt.isRegistered<InnerLoggerHandler>()) {
    getIt.unregister<InnerLoggerHandler>();
  }
  getIt.registerSingleton<InnerLoggerHandler>(logger);
  return logger;
}

void unregisterFakeLogger() {
  if (getIt.isRegistered<InnerLoggerHandler>()) {
    getIt.unregister<InnerLoggerHandler>();
  }
}
