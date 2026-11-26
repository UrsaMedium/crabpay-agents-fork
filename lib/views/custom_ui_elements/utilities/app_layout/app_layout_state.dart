import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Precalculated layout metrics shared across the app.
///
/// The raw window width is intentionally not stored: only the capped [width]
/// matters, so resizing a desktop browser above [AppLayoutConfig.maxWidth]
/// does not produce new states.
class AppLayoutState extends Equatable {
  /// Capped width every other value is derived from.
  final double width;

  /// Inner content padding, e.g. inside cards and dialogs.
  final double standardPadding;

  /// Page margin, e.g. between a page edge and its content.
  final double screenEdgePadding;

  /// Base corner radius for cards, sheets and buttons.
  final double cornerRadius;

  final double tinyFontSize;
  final double smallFontSize;
  final double mediumFontSize;
  final double bigFontSize;
  final double largeFontSize;

  /// Safe area at the top of the screen (status bar, notch, dynamic island).
  final double topPadding;

  /// Safe area at the bottom of the screen (home indicator, navigation bar).
  final double bottomPadding;

  const AppLayoutState({
    required this.width,
    required this.standardPadding,
    required this.screenEdgePadding,
    required this.cornerRadius,
    required this.tinyFontSize,
    required this.smallFontSize,
    required this.mediumFontSize,
    required this.bigFontSize,
    required this.largeFontSize,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Builds a state from a raw width and the platform safe area insets.
  ///
  /// [rawWidth] is clamped to the range `minWidth..maxWidth` from
  /// [AppLayoutConfig] and negative insets are clamped to zero.
  factory AppLayoutState.fromMetrics({
    required double rawWidth,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
    AppLayoutConfig config = const AppLayoutConfig(),
  }) {
    final double safeWidth = rawWidth.isFinite ? rawWidth.clamp(config.minWidth, config.maxWidth).toDouble() : config.minWidth;

    return AppLayoutState(
      width: safeWidth,
      standardPadding: safeWidth * config.standardPaddingCoeff,
      screenEdgePadding: safeWidth * config.screenEdgePaddingCoeff,
      cornerRadius: safeWidth * config.cornerRadiusCoeff,
      tinyFontSize: safeWidth * config.tinyFontCoeff,
      smallFontSize: safeWidth * config.smallFontCoeff,
      mediumFontSize: safeWidth * config.mediumFontCoeff,
      bigFontSize: safeWidth * config.bigFontCoeff,
      largeFontSize: safeWidth * config.largeFontCoeff,
      topPadding: topPadding > 0 ? topPadding : 0.0,
      bottomPadding: bottomPadding > 0 ? bottomPadding : 0.0,
    );
  }

  /// Fallback state used before the platform reports real metrics.
  factory AppLayoutState.initial({AppLayoutConfig config = const AppLayoutConfig()}) {
    return AppLayoutState.fromMetrics(rawWidth: config.fallbackWidth, config: config);
  }

  EdgeInsets get standardEdgeInsets => EdgeInsets.all(standardPadding);

  EdgeInsets get horizontalEdgeInsets => EdgeInsets.symmetric(horizontal: screenEdgePadding);

  /// Screen edge padding combined with the platform safe area insets.
  EdgeInsets get screenSafePadding {
    return EdgeInsets.fromLTRB(screenEdgePadding, topPadding, screenEdgePadding, bottomPadding);
  }

  BorderRadius get borderRadius => BorderRadius.circular(cornerRadius);

  /// Corner radius for a child nested inside a rounded container with [inset]
  /// of padding, so both corners stay concentric.
  double innerCornerRadius([double? inset]) {
    final double safeRadius = (cornerRadius - (inset ?? standardPadding)).clamp(0.0, cornerRadius).toDouble();
    return safeRadius;
  }

  @override
  List<Object?> get props => [
    width,
    standardPadding,
    screenEdgePadding,
    cornerRadius,
    tinyFontSize,
    smallFontSize,
    mediumFontSize,
    bigFontSize,
    largeFontSize,
    topPadding,
    bottomPadding,
  ];
}
