import 'dart:async';
import 'dart:math' as math;

import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every layout value the login view needs, derived once per layout sync.
@immutable
class LoginViewLayout extends Equatable {
  /// Capped content width for wide web viewports.
  final double contentWidth;

  /// Outer padding around the scrollable form, including the bottom safe area.
  final EdgeInsets contentPadding;

  final double titleFontSize;
  final double subtitleFontSize;
  final double linkFontSize;
  final double buttonFontSize;
  final double dividerLabelFontSize;

  final double titleSpacing;
  final double sectionSpacing;
  final double fieldSpacing;
  final double dividerSectionSpacing;

  final double inputCornerRadius;
  final double buttonMinHeight;
  final EdgeInsets buttonPadding;
  final double minTapTarget;
  final double dividerThickness;
  final EdgeInsets dividerTextPadding;
  final double dividerLabelMaxWidth;
  final double loadingIndicatorSize;
  final double loadingIndicatorStrokeWidth;

  const LoginViewLayout({
    required this.contentWidth,
    required this.contentPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.linkFontSize,
    required this.buttonFontSize,
    required this.dividerLabelFontSize,
    required this.titleSpacing,
    required this.sectionSpacing,
    required this.fieldSpacing,
    required this.dividerSectionSpacing,
    required this.inputCornerRadius,
    required this.buttonMinHeight,
    required this.buttonPadding,
    required this.minTapTarget,
    required this.dividerThickness,
    required this.dividerTextPadding,
    required this.dividerLabelMaxWidth,
    required this.loadingIndicatorSize,
    required this.loadingIndicatorStrokeWidth,
  });

  factory LoginViewLayout.fromAppLayout(AppLayoutState layout) {
    final double width = math.max(0.0, layout.width);
    final double bottomPadding = math.max(0.0, layout.bottomPadding);
    final double screenEdgePadding = math.max(0.0, layout.screenEdgePadding);
    final double padding = math.max(0.0, layout.standardPadding);
    final double contentWidth = math.max(0.0, width - screenEdgePadding * 2);

    return LoginViewLayout(
      contentWidth: contentWidth,
      contentPadding: EdgeInsets.fromLTRB(
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding,
        screenEdgePadding + bottomPadding,
      ),
      titleFontSize: layout.largeFontSize,
      subtitleFontSize: layout.mediumFontSize,
      linkFontSize: layout.mediumFontSize,
      buttonFontSize: layout.mediumFontSize,
      dividerLabelFontSize: layout.smallFontSize,
      titleSpacing: padding,
      sectionSpacing: screenEdgePadding * 2,
      fieldSpacing: screenEdgePadding,
      dividerSectionSpacing: screenEdgePadding * 1.5,
      inputCornerRadius: 999.0,
      buttonMinHeight: math.max(48.0, layout.appBarHeight),
      buttonPadding: EdgeInsets.symmetric(
        horizontal: screenEdgePadding,
        vertical: padding,
      ),
      minTapTarget: 48.0,
      dividerThickness: 1.0,
      dividerTextPadding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding / 2,
      ),
      dividerLabelMaxWidth: contentWidth * 0.7,
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
    linkFontSize,
    buttonFontSize,
    dividerLabelFontSize,
    titleSpacing,
    sectionSpacing,
    fieldSpacing,
    dividerSectionSpacing,
    inputCornerRadius,
    buttonMinHeight,
    buttonPadding,
    minTapTarget,
    dividerThickness,
    dividerTextPadding,
    dividerLabelMaxWidth,
    loadingIndicatorSize,
    loadingIndicatorStrokeWidth,
  ];
}

@immutable
class LoginViewState extends Equatable {
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final LoginViewLayout layout;

  const LoginViewState({
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    required this.layout,
  });

  factory LoginViewState.fromLayout(AppLayoutState layout) => LoginViewState(
    layout: LoginViewLayout.fromAppLayout(layout),
  );

  LoginViewState copyWith({
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    LoginViewLayout? layout,
  }) => LoginViewState(
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

class LoginViewCubit extends Cubit<LoginViewState> {
  final AppLayoutCubit _appLayoutCubit;
  late final StreamSubscription _layoutSubscription;

  LoginViewCubit({required AppLayoutCubit layoutCubit})
    : _appLayoutCubit = layoutCubit,
      super(LoginViewState.fromLayout(layoutCubit.state)) {
    _layoutSubscription = _appLayoutCubit.stream.listen(
      (layoutState) => _syncLayout(layoutState),
    );
  }

  void _syncLayout(AppLayoutState layout) => emit(
    state.copyWith(layout: LoginViewLayout.fromAppLayout(layout)),
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
        LoginViewState(
          emailError: emailErr,
          passwordError: passwordErr,
          layout: state.layout,
        ),
      );
    } else {
      emit(
        LoginViewState(
          isSubmitting: true,
          layout: state.layout,
        ),
      );
      onValid(email, password);
    }
  }

  void setErrors({String? emailError, String? passwordError}) {
    emit(
      LoginViewState(
        emailError: emailError,
        passwordError: passwordError,
        isSubmitting: false,
        layout: state.layout,
      ),
    );
  }

  void clearErrors() {
    emit(
      LoginViewState(
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
