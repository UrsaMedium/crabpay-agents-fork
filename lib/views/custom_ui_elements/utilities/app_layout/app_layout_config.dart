/// Tunable coefficients for [AppLayoutState].
///
/// Every metric is derived as `cappedWidth * coefficient`, so changing a value
/// here changes it consistently for every screen in the app.
class AppLayoutConfig {
  /// Lower bound applied to the resolved width, so very small windows still
  /// get a usable layout.
  final double minWidth;

  /// Width used for every calculation. Wider windows (web, tablets in
  /// landscape) are treated as if they were this wide.
  final double maxWidth;

  /// Width used before the platform reports real metrics (first frame).
  final double fallbackWidth;

  /// Inner content padding, e.g. inside cards and dialogs.
  final double standardPaddingCoeff;

  /// Page margin, e.g. between a page edge and its content.
  final double screenEdgePaddingCoeff;

  /// Corner radius of cards, sheets and buttons.
  final double cornerRadiusCoeff;

  final double tinyFontCoeff;
  final double smallFontCoeff;
  final double mediumFontCoeff;
  final double bigFontCoeff;
  final double largeFontCoeff;

  const AppLayoutConfig({
    this.minWidth = 128.0,
    this.maxWidth = 512.0,
    this.fallbackWidth = 390.0,
    this.standardPaddingCoeff = 0.02,
    this.screenEdgePaddingCoeff = 0.042,
    this.cornerRadiusCoeff = 0.05,
    this.tinyFontCoeff = 0.026,
    this.smallFontCoeff = 0.031,
    this.mediumFontCoeff = 0.036,
    this.bigFontCoeff = 0.045,
    this.largeFontCoeff = 0.056,
  });
}
