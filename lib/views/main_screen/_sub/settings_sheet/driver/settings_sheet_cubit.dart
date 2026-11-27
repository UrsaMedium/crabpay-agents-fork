import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the settings sheet needs, derived once per layout sync.
@immutable
class SettingsSheetLayout extends Equatable {
  /// Capped sheet width, so the sheet never grows wider than the app layout.
  final double sheetWidth;

  /// Minimum sheet height, derived from the capped width plus the bottom safe
  /// area so the content always has room to breathe.
  final double sheetMinHeight;

  /// Corner radius of the sheet itself.
  final double topCornerRadius;

  /// Corner radius of the inner highlight border, kept concentric with
  /// [topCornerRadius].
  final double borderCornerRadius;

  /// Padding around the setting rows, including the bottom safe area.
  final EdgeInsets contentPadding;

  /// Font size of the setting row labels.
  final double labelFontSize;

  /// Vertical gap between setting rows.
  final double rowSpacing;

  /// Height reserved for the divider, matching the surrounding spacing.
  final double dividerHeight;

  /// Thickness of the divider line.
  final double dividerThickness;

  const SettingsSheetLayout({
    required this.sheetWidth,
    required this.sheetMinHeight,
    required this.topCornerRadius,
    required this.borderCornerRadius,
    required this.contentPadding,
    required this.labelFontSize,
    required this.rowSpacing,
    required this.dividerHeight,
    required this.dividerThickness,
  });

  factory SettingsSheetLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double cornerRadius = math.max(0.0, layout.cornerRadius);

    return SettingsSheetLayout(
      sheetWidth: width,
      sheetMinHeight: width * 0.5 + bottomPadding,
      topCornerRadius: cornerRadius,
      borderCornerRadius: cornerRadius,
      contentPadding: EdgeInsets.fromLTRB(
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding + bottomPadding,
      ),
      labelFontSize: layout.mediumFontSize,
      rowSpacing: padding / 2,
      dividerHeight: screenEdgePadding,
      dividerThickness: 1.0,
    );
  }

  @override
  List<Object?> get props => [
    sheetWidth,
    sheetMinHeight,
    topCornerRadius,
    borderCornerRadius,
    contentPadding,
    labelFontSize,
    rowSpacing,
    dividerHeight,
    dividerThickness,
  ];
}

@immutable
class SettingsSheetState extends Equatable {
  final SettingsSheetLayout layout;

  const SettingsSheetState({required this.layout});

  /// Builds the state with every derived layout value from [layout].
  factory SettingsSheetState.fromLayout(AppLayoutState layout) =>
      SettingsSheetState(layout: SettingsSheetLayout.fromAppLayout(layout));

  SettingsSheetState copyWith({SettingsSheetLayout? layout}) => SettingsSheetState(layout: layout ?? this.layout);

  @override
  List<Object?> get props => [layout];
}

class SettingsSheetCubit extends Cubit<SettingsSheetState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  SettingsSheetCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(SettingsSheetState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: SettingsSheetLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
