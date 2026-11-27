import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the password-forgot view needs, derived once per layout sync.
@immutable
class PasswordForgotViewLayout extends Equatable {
  /// Capped content width for wide web viewports.
  final double contentWidth;

  /// Outer padding around the scrollable form, including the bottom safe area.
  final EdgeInsets contentPadding;

  final double titleFontSize;
  final double subtitleFontSize;
  final double buttonFontSize;

  final double titleSpacing;
  final double sectionSpacing;

  final double inputCornerRadius;
  final double buttonMinHeight;
  final EdgeInsets buttonPadding;
  final double loadingIndicatorSize;
  final double loadingIndicatorStrokeWidth;

  const PasswordForgotViewLayout({
    required this.contentWidth,
    required this.contentPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.buttonFontSize,
    required this.titleSpacing,
    required this.sectionSpacing,
    required this.inputCornerRadius,
    required this.buttonMinHeight,
    required this.buttonPadding,
    required this.loadingIndicatorSize,
    required this.loadingIndicatorStrokeWidth,
  });

  factory PasswordForgotViewLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);

    return PasswordForgotViewLayout(
      contentWidth: math.max(0.0, width - screenEdgePadding * 2),
      contentPadding: EdgeInsets.fromLTRB(
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding + bottomPadding,
      ),
      titleFontSize: layout.largeFontSize,
      subtitleFontSize: layout.mediumFontSize,
      buttonFontSize: layout.mediumFontSize,
      titleSpacing: padding,
      sectionSpacing: screenEdgePadding * 2,
      inputCornerRadius: 999.0,
      buttonMinHeight: math.max(48.0, layout.appBarHeight),
      buttonPadding: EdgeInsets.symmetric(
        horizontal: screenEdgePadding,
        vertical: padding,
      ),
      loadingIndicatorSize: layout.bigFontSize,
      loadingIndicatorStrokeWidth: 2.0,
    );
  }

  @override
  List<Object?> get props => [
    contentWidth,
    contentPadding,
    titleFontSize,
    subtitleFontSize,
    buttonFontSize,
    titleSpacing,
    sectionSpacing,
    inputCornerRadius,
    buttonMinHeight,
    buttonPadding,
    loadingIndicatorSize,
    loadingIndicatorStrokeWidth,
  ];
}

@immutable
class PasswordForgotViewState extends Equatable {
  final String? emailError;
  final bool isSubmitting;
  final PasswordForgotViewLayout layout;

  const PasswordForgotViewState({
    this.emailError,
    this.isSubmitting = false,
    required this.layout,
  });

  factory PasswordForgotViewState.fromLayout(AppLayoutState layout) => PasswordForgotViewState(
    layout: PasswordForgotViewLayout.fromAppLayout(layout),
  );

  PasswordForgotViewState copyWith({
    String? emailError,
    bool? isSubmitting,
    PasswordForgotViewLayout? layout,
  }) => PasswordForgotViewState(
    emailError: emailError ?? this.emailError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    layout: layout ?? this.layout,
  );

  @override
  List<Object?> get props => [
    emailError,
    isSubmitting,
    layout,
  ];
}

class PasswordForgotViewCubit extends Cubit<PasswordForgotViewState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  PasswordForgotViewCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(PasswordForgotViewState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: PasswordForgotViewLayout.fromAppLayout(layout)),
  );

  void validateAndSubmit({
    required String email,
    required Function(String email) onValid,
  }) {
    String? emailErr;

    if (email.isEmpty || !email.contains('@')) {
      emailErr = 'Email is not valid';
    }
    if (emailErr != null) {
      emit(
        PasswordForgotViewState(
          emailError: emailErr,
          layout: state.layout,
        ),
      );
    } else {
      emit(
        PasswordForgotViewState(
          isSubmitting: true,
          layout: state.layout,
        ),
      );
      onValid(email);
    }
  }

  void clearErrors() {
    emit(
      PasswordForgotViewState(
        emailError: null,
        isSubmitting: false,
        layout: state.layout,
      ),
    );
  }

  @override
  Future<void> close() {
    _layoutSubscription.cancel();
    return super.close();
  }
}
