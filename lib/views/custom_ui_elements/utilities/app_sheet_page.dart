import 'package:crabpay/views/custom_ui_elements/widgets/material_bottom_sheet_page_gorouter_interface.dart';
import 'package:flutter/widgets.dart';

/// Builds the modal bottom sheet page used by the platform-agnostic routes.
///
/// Routes stay free of any design system import; the actual Material page is
/// resolved here so it can be swapped for another design system later.
Page<T> buildAppSheetPage<T>({
  LocalKey? key,
  required Widget child,
  bool showDragHandle = false,
  bool useSafeArea = false,
  bool isScrollControlled = true,
}) {
  return BottomSheetPage<T>(
    key: key,
    child: child,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    isScrollControlled: isScrollControlled,
  );
}
