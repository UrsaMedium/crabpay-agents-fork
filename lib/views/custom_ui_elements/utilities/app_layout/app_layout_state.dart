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

  /// Height of the in-app top bar, derived from the capped width.
  final double appBarHeight;

  /// Distance from the top screen edge to the top edge of the in-app bar,
  /// including the platform safe area.
  final double appBarTopPadding;

  /// Height of the in-app bottom navigation bar, derived from the capped width.
  final double navBarHeight;

  /// Distance from the bottom screen edge to the bottom edge of the in-app
  /// navigation bar, including the platform safe area.
  final double navBarBottomPadding;

  /// Top padding a page needs so its content clears both the system status bar
  /// and the in-app top bar.
  final double pageTopPadding;

  /// Bottom padding a page needs so its content clears both the in-app
  /// navigation bar and the system navigation bar.
  final double pageBottomPadding;

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
    required this.appBarHeight,
    required this.appBarTopPadding,
    required this.navBarHeight,
    required this.navBarBottomPadding,
    required this.pageTopPadding,
    required this.pageBottomPadding,
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
    final double safeTopPadding = topPadding > 0 ? topPadding : 0.0;
    final double safeBottomPadding = bottomPadding > 0 ? bottomPadding : 0.0;

    final double appBarHeight = safeWidth * config.appBarHeightCoeff;
    final double appBarTopPadding = safeTopPadding + safeWidth * config.appBarTopPaddingCoeff;
    final double navBarHeight = safeWidth * config.navBarHeightCoeff;
    final double navBarBottomPadding = safeBottomPadding + safeWidth * config.navBarBottomPaddingCoeff;

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
      topPadding: safeTopPadding,
      bottomPadding: safeBottomPadding,
      appBarHeight: appBarHeight,
      appBarTopPadding: appBarTopPadding,
      navBarHeight: navBarHeight,
      navBarBottomPadding: navBarBottomPadding,
      pageTopPadding: appBarTopPadding + appBarHeight,
      pageBottomPadding: navBarBottomPadding + navBarHeight,
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

  /// Screen edge padding combined with the in-app bar and platform safe area
  /// insets, so page content never slides under the bars.
  EdgeInsets get pageSafePadding {
    return EdgeInsets.fromLTRB(screenEdgePadding, pageTopPadding, screenEdgePadding, pageBottomPadding);
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
    appBarHeight,
    appBarTopPadding,
    navBarHeight,
    navBarBottomPadding,
    pageTopPadding,
    pageBottomPadding,
  ];
}
