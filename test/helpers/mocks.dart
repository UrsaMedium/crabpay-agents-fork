import 'dart:async';

import 'package:crabpay/core/app_services/app_lifecycle.dart';
import 'package:crabpay/core/backend/admin/admin_chat_service/admin_chat_inner_circle/admin_inner_chat_handler.dart';
import 'package:crabpay/core/backend/admin/admin_database/admin_db_inner_circle/admin_inner_database_handler.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_inner_interface.dart';
import 'package:crabpay/core/backend/chat_service/chat_inner_circle/inner_chat_handler.dart';
import 'package:crabpay/core/backend/connection_monitoring/inner_monitor/inner_connection_monitor.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/inner_database_handler.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/data_models/cart_item_model.dart';
import 'package:crabpay/core/backend/database/product_cart/cart_inner_circle/inner_cart_handler.dart';
import 'package:crabpay/core/backend/logger/logger_inner_handler/inner_logger_handler.dart';
import 'package:crabpay/core/backend/pyament_services/payment_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_fixtures.dart';

// ---------------------------------------------------------------------------
// Inner-circle handler mocks
// ---------------------------------------------------------------------------

class MockAuthInnerInterface extends Mock implements AuthInnerInterface {}

class MockInnerDatabaseHandler extends Mock implements InnerDatabaseHandler {}

class MockAdminInnerDatabaseHandler extends Mock implements AdminInnerDatabaseHandler {}

class MockInnerCartHandler extends Mock implements InnerCartHandler {}

class MockInnerChatHandler extends Mock implements InnerChatHandler {}

class MockAdminInnerChatHandler extends Mock implements AdminInnerChatHandler {}

class MockInnerConnectionMonitor extends Mock implements InnerConnectionMonitor {}

class MockInnerLoggerHandler extends Mock implements InnerLoggerHandler {}

class MockPaymentOuterHandler extends Mock implements PaymentOuterHandler {}

// ---------------------------------------------------------------------------
// External client mocks
// ---------------------------------------------------------------------------

class MockGraphQLClient extends Mock implements GraphQLClient {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockRealtimeClient extends Mock implements RealtimeClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

// ---------------------------------------------------------------------------
// Fakes that are cheaper than mocks
// ---------------------------------------------------------------------------

/// In-memory [AppLifecycleService] that never touches the Flutter binding.
class FakeAppLifecycleService implements AppLifecycleService {
  final StreamController<AppState> _controller = StreamController<AppState>.broadcast();

  @override
  Stream<AppState> get appStateStream => _controller.stream;

  void emit(AppState state) => _controller.add(state);

  @override
  void dispose() {
    _controller.close();
  }
}

/// No-op logger so outer handlers can run without Sentry.
class FakeInnerLoggerHandler implements InnerLoggerHandler {
  final List<String> breadcrumbs = <String>[];
  final List<Object> exceptions = <Object>[];

  @override
  Future<void> init() async {}

  @override
  void logInfo({required String message, Map<String, dynamic>? meta}) {}

  @override
  void logBreadcrumb({required String message, String? category, Map<String, dynamic>? data}) {
    breadcrumbs.add(message);
  }

  @override
  void recordException({required Object error, required StackTrace stackTrace}) {
    exceptions.add(error);
  }

  @override
  void setDiagnosticUser({required String id, String? email}) {}

  @override
  void clearDiagnosticUser() {}
}

// ---------------------------------------------------------------------------
// mocktail fallback values
// ---------------------------------------------------------------------------

void registerTestFallbackValues() {
  registerFallbackValue(makeAuthUser());
  registerFallbackValue(makeProduct());
  registerFallbackValue(makeProductField());
  registerFallbackValue(makeCurrencies());
  registerFallbackValue(makeCartItem());
  registerFallbackValue(makePendingOrder());
  registerFallbackValue(makeChatMessage());
  registerFallbackValue(makeSupportThread());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(<String, String>{});
  registerFallbackValue(<CartItem>[]);
  registerFallbackValue(StackTrace.empty);
  registerFallbackValue(const Duration(seconds: 1));
  registerFallbackValue(QueryOptions(document: gql('query { __typename }')));
  registerFallbackValue(MutationOptions(document: gql('mutation { __typename }')));
}
