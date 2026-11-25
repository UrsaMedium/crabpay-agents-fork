import 'package:crabpay/core/set_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
