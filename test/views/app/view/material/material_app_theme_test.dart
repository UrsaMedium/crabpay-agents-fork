import 'package:crabpay/views/app/view/material/material_app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme', () {
    test('light theme is light and uses Material 3', () {
      final ThemeData theme = AppTheme.light(null);
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });

    test('light theme accepts a dynamic seed color scheme', () {
      final ThemeData theme = AppTheme.light(ColorScheme.fromSeed(seedColor: Colors.green));
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });

    test('dark theme is dark and uses Material 3', () {
      final ThemeData theme = AppTheme.dark(null);
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
    });

    test('dark theme accepts a dynamic seed color scheme', () {
      final ThemeData theme = AppTheme.dark(ColorScheme.fromSeed(seedColor: Colors.green));
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
    });
  });
}
