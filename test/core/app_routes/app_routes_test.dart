import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes', () {
    test('every route has a non-empty path and name', () {
      for (final route in AppRoutes.values) {
        expect(route.path, isNotEmpty, reason: 'route ${route.name} has an empty path');
        expect(route.name, isNotEmpty, reason: 'route ${route.path} has an empty name');
      }
    });

    test('all names are unique', () {
      final names = AppRoutes.values.map((route) => route.name).toList();
      expect(names.length, AppRoutes.values.length);
      expect(names.toSet().length, names.length);
    });

    test('all paths are unique', () {
      final paths = AppRoutes.values.map((route) => route.path).toList();
      expect(paths.length, AppRoutes.values.length);
      expect(paths.toSet().length, paths.length);
    });
  });
}
