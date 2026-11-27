import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the profile sheet needs, derived once per layout sync.
@immutable
class ProfileSheetLayout extends Equatable {
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

  /// Padding around the sheet content, including the bottom safe area.
  final EdgeInsets contentPadding;

  /// Font size of section titles and labels.
  final double titleFontSize;

  /// Font size of the user email subtitle.
  final double emailFontSize;

  /// Font size of the sign-out button label.
  final double buttonFontSize;

  /// Minimum height of the sign-out button (>= 48 px for tap target ergonomics).
  final double signOutButtonMinHeight;

  /// Horizontal gap between the icon and label inside the sign-out button.
  final double buttonIconSpacing;

  /// Horizontal/vertical gap between elements in a row.
  final double rowSpacing;

  /// Height reserved for the divider, matching the surrounding spacing.
  final double dividerHeight;

  /// Thickness of the divider line.
  final double dividerThickness;

  const ProfileSheetLayout({
    required this.sheetWidth,
    required this.sheetMinHeight,
    required this.topCornerRadius,
    required this.borderCornerRadius,
    required this.contentPadding,
    required this.titleFontSize,
    required this.emailFontSize,
    required this.buttonFontSize,
    required this.signOutButtonMinHeight,
    required this.buttonIconSpacing,
    required this.rowSpacing,
    required this.dividerHeight,
    required this.dividerThickness,
  });

  factory ProfileSheetLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double cornerRadius = math.max(0.0, layout.cornerRadius);

    return ProfileSheetLayout(
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
      titleFontSize: layout.mediumFontSize,
      emailFontSize: layout.smallFontSize,
      buttonFontSize: layout.mediumFontSize,
      signOutButtonMinHeight: math.max(48.0, padding * 3),
      buttonIconSpacing: padding / 2,
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
    titleFontSize,
    emailFontSize,
    buttonFontSize,
    signOutButtonMinHeight,
    buttonIconSpacing,
    rowSpacing,
    dividerHeight,
    dividerThickness,
  ];
}

@immutable
class ProfileSheetState extends Equatable {
  final ProfileSheetLayout layout;

  const ProfileSheetState({required this.layout});

  /// Builds the state with every derived layout value from [layout].
  factory ProfileSheetState.fromLayout(AppLayoutState layout) =>
      ProfileSheetState(layout: ProfileSheetLayout.fromAppLayout(layout));

  ProfileSheetState copyWith({ProfileSheetLayout? layout}) => ProfileSheetState(layout: layout ?? this.layout);

  @override
  List<Object?> get props => [layout];
}

class ProfileSheetCubit extends Cubit<ProfileSheetState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  ProfileSheetCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(ProfileSheetState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: ProfileSheetLayout.fromAppLayout(layout)),
  );

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
