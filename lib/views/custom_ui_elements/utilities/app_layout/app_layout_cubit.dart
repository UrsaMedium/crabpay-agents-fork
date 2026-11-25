import 'dart:ui' show FlutterView, PlatformDispatcher, ViewPadding;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout_config.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Raw metrics read from the platform: logical window width plus the safe area
/// insets reported by Flutter.
typedef AppLayoutMetricsSnapshot = ({double width, double topPadding, double bottomPadding});

/// Global source of layout boundaries, paddings, corner radii and font sizes.
///
/// Listens to [WidgetsBindingObserver.didChangeMetrics], so it reacts to
/// browser resizes and device rotation on every platform without depending on
/// Material widgets.
class AppLayoutCubit extends Cubit<AppLayoutState> with WidgetsBindingObserver {
  final AppLayoutConfig config;
  final AppLayoutMetricsSnapshot? Function() _metricsReader;
  final bool _observeBinding;

  AppLayoutCubit({
    this.config = const AppLayoutConfig(),
    AppLayoutMetricsSnapshot? Function()? metricsReader,
    bool observeBinding = true,
  }) : _metricsReader = metricsReader ?? _readPlatformMetrics,
       _observeBinding = observeBinding,
       super(_resolveInitialState(config, metricsReader ?? _readPlatformMetrics)) {
    if (_observeBinding) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  /// Recalculates the state from explicit values, useful for tests and for
  /// container-scoped overrides.
  void updateMetrics({required double rawWidth, double topPadding = 0.0, double bottomPadding = 0.0}) {
    if (isClosed || !rawWidth.isFinite || rawWidth <= 0) return;

    emit(AppLayoutState.fromMetrics(rawWidth: rawWidth, topPadding: topPadding, bottomPadding: bottomPadding, config: config));
  }

  /// Reads the current platform metrics and emits them if they changed.
  void syncFromPlatform() {
    final AppLayoutMetricsSnapshot? metrics = _metricsReader();
    if (metrics == null) return;

    updateMetrics(rawWidth: metrics.width, topPadding: metrics.topPadding, bottomPadding: metrics.bottomPadding);
  }

  @override
  void didChangeMetrics() {
    syncFromPlatform();
  }

  @override
  Future<void> close() {
    if (_observeBinding) {
      WidgetsBinding.instance.removeObserver(this);
    }
    return super.close();
  }

  static AppLayoutState _resolveInitialState(AppLayoutConfig config, AppLayoutMetricsSnapshot? Function() reader) {
    final AppLayoutMetricsSnapshot? metrics = _readSafely(reader);
    if (metrics == null) return AppLayoutState.initial(config: config);

    return AppLayoutState.fromMetrics(
      rawWidth: metrics.width,
      topPadding: metrics.topPadding,
      bottomPadding: metrics.bottomPadding,
      config: config,
    );
  }

  static AppLayoutMetricsSnapshot? _readSafely(AppLayoutMetricsSnapshot? Function() reader) {
    try {
      return reader();
    } on FlutterError {
      // No binding initialized (pure Dart environment): fall back to defaults.
      return null;
    }
  }

  static AppLayoutMetricsSnapshot? _readPlatformMetrics() {
    final FlutterView? view = _currentView();
    if (view == null) return null;

    final double devicePixelRatio = view.devicePixelRatio;
    if (devicePixelRatio <= 0) return null;

    final double width = view.physicalSize.width / devicePixelRatio;
    if (!width.isFinite || width <= 0) return null;

    final ViewPadding padding = view.viewPadding;
    return (width: width, topPadding: padding.top / devicePixelRatio, bottomPadding: padding.bottom / devicePixelRatio);
  }

  static FlutterView? _currentView() {
    final PlatformDispatcher dispatcher = WidgetsBinding.instance.platformDispatcher;
    return dispatcher.implicitView ?? (dispatcher.views.isEmpty ? null : dispatcher.views.first);
  }
}
