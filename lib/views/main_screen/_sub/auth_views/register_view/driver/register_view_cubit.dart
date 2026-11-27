import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the register view needs, derived once per layout sync.
@immutable
class RegisterViewLayout extends Equatable {
  /// Capped content width for wide web viewports.
  final double contentWidth;

  /// Outer padding around the scrollable form, including the bottom safe area.
  final EdgeInsets contentPadding;

  final double titleFontSize;
  final double subtitleFontSize;
  final double buttonFontSize;
  final double dividerLabelFontSize;

  final double titleSpacing;
  final double sectionSpacing;
  final double fieldSpacing;
  final double submitTopSpacing;
  final double dividerSpacing;

  final double inputCornerRadius;
  final double buttonMinHeight;
  final EdgeInsets buttonPadding;
  final double dividerThickness;
  final EdgeInsets dividerTextPadding;
  final double dividerLabelMaxWidth;

  const RegisterViewLayout({
    required this.contentWidth,
    required this.contentPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.buttonFontSize,
    required this.dividerLabelFontSize,
    required this.titleSpacing,
    required this.sectionSpacing,
    required this.fieldSpacing,
    required this.submitTopSpacing,
    required this.dividerSpacing,
    required this.inputCornerRadius,
    required this.buttonMinHeight,
    required this.buttonPadding,
    required this.dividerThickness,
    required this.dividerTextPadding,
    required this.dividerLabelMaxWidth,
  });

  factory RegisterViewLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double contentWidth = math.max(0.0, width - screenEdgePadding * 2);

    return RegisterViewLayout(
      contentWidth: contentWidth,
      contentPadding: EdgeInsets.fromLTRB(
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding + bottomPadding,
      ),
      titleFontSize: layout.largeFontSize,
      subtitleFontSize: layout.mediumFontSize,
      buttonFontSize: layout.mediumFontSize,
      dividerLabelFontSize: layout.smallFontSize,
      titleSpacing: padding,
      sectionSpacing: screenEdgePadding * 2,
      fieldSpacing: screenEdgePadding,
      submitTopSpacing: screenEdgePadding * 3,
      dividerSpacing: padding * 1.5,
      inputCornerRadius: 999.0,
      buttonMinHeight: math.max(48.0, layout.appBarHeight),
      buttonPadding: EdgeInsets.symmetric(
        horizontal: screenEdgePadding,
        vertical: padding,
      ),
      dividerThickness: 1.0,
      dividerTextPadding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding / 2,
      ),
      dividerLabelMaxWidth: contentWidth * 0.7,
    );
  }

  @override
  List<Object?> get props => [
    contentWidth,
    contentPadding,
    titleFontSize,
    subtitleFontSize,
    buttonFontSize,
    dividerLabelFontSize,
    titleSpacing,
    sectionSpacing,
    fieldSpacing,
    submitTopSpacing,
    dividerSpacing,
    inputCornerRadius,
    buttonMinHeight,
    buttonPadding,
    dividerThickness,
    dividerTextPadding,
    dividerLabelMaxWidth,
  ];
}

@immutable
class RegisterViewState extends Equatable {
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final RegisterViewLayout layout;

  const RegisterViewState({
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    required this.layout,
  });

  factory RegisterViewState.fromLayout(AppLayoutState layout) => RegisterViewState(
    layout: RegisterViewLayout.fromAppLayout(layout),
  );

  RegisterViewState copyWith({
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    RegisterViewLayout? layout,
  }) => RegisterViewState(
    emailError: emailError ?? this.emailError,
    passwordError: passwordError ?? this.passwordError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    layout: layout ?? this.layout,
  );

  @override
  List<Object?> get props => [
    emailError,
    passwordError,
    isSubmitting,
    layout,
  ];
}

class RegisterViewCubit extends Cubit<RegisterViewState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  RegisterViewCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(RegisterViewState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: RegisterViewLayout.fromAppLayout(layout)),
  );

  void validateAndSubmit({
    required String email,
    required String password,
    required Function(String email, String password) onValid,
  }) {
    String? emailErr;
    String? passwordErr;

    if (email.isEmpty || !email.contains('@')) {
      emailErr = 'Email is not alid';
    }
    if (password.isEmpty || password.length < 6) {
      passwordErr = 'Password is not valid';
    }
    if (emailErr != null || passwordErr != null) {
      emit(
        RegisterViewState(
          emailError: emailErr,
          passwordError: passwordErr,
          layout: state.layout,
        ),
      );
    } else {
      emit(
        RegisterViewState(
          isSubmitting: true,
          layout: state.layout,
        ),
      );
      onValid(email, password);
    }
  }

  void setErrors({String? emailError, String? passwordError}) {
    emit(
      RegisterViewState(
        emailError: emailError,
        passwordError: passwordError,
        isSubmitting: false,
        layout: state.layout,
      ),
    );
  }

  void clearErrors() {
    emit(
      RegisterViewState(
        emailError: null,
        passwordError: null,
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
