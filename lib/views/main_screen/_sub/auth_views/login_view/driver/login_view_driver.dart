import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_states.dart';
import 'package:crabpay/core/backend/logger/logger_inner_handler/inner_logger_handler.dart';
import 'package:crabpay/core/utilities.dart';
import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/login_view/driver/login_view_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/login_view/material_login_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class LoginViewDriver extends StatefulWidget {
  const LoginViewDriver({super.key});

  @override
  State<LoginViewDriver> createState() => _LoginViewDriverState();
}

class _LoginViewDriverState extends State<LoginViewDriver> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final LoginViewCubit _loginViewCubit;

  @override
  void initState() {
    getIt<InnerLoggerHandler>().logBreadcrumb(
      message: 'LoginViewDriver initState',
    );
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loginViewCubit = LoginViewCubit(
      layoutCubit: context.read<AppLayoutCubit>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _loginViewCubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        getIt<InnerLoggerHandler>().logBreadcrumb(
          message: 'LoginViewDriver onPopInvokedWithResult',
          data: {'didPop': didPop, 'result': result},
        );
        if (didPop) {
          return;
        }
        !Navigator.of(context).canPop() ? context.go(AppRoutes.home.path) : context.pop();
      },
      child: BlocProvider.value(
        value: _loginViewCubit,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            getIt<InnerLoggerHandler>().logBreadcrumb(
              message: 'LoginViewDriver AuthState change',
              data: {'authState': authState},
            );
            if (authState is AuthStateLoggedIn) {
              context.push(AppRoutes.home.path);
            }
            if (authState is AuthStateLoggedOut) {
              if (authState.bloodyAuthException != null) {
                Fluttertoast.showToast(
                  msg: context.l10n.wrongCredentialsPleaseTryAgain,
                  toastLength: Toast.LENGTH_LONG,
                );
                context.read<LoginViewCubit>().setErrors(
                  emailError: 'Invalid email or password',
                  passwordError: 'Invalid email or password',
                );
              }
            }
          },
          child: Builder(
            builder: (context) {
              final layout = context.select<LoginViewCubit, LoginViewLayout>(
                (cubit) => cubit.state.layout,
              );
              final isSubmitting = context.select<LoginViewCubit, bool>(
                (cubit) => cubit.state.isSubmitting,
              );
              final emailError = context.select<LoginViewCubit, String?>(
                (cubit) => cubit.state.emailError,
              );
              final passwordError = context.select<LoginViewCubit, String?>(
                (cubit) => cubit.state.passwordError,
              );

              void onSignInPressed() {
                getIt<InnerLoggerHandler>().logBreadcrumb(
                  message: 'LoginViewDriver onSignInPressed',
                  data: {
                    'email': _emailController.text,
                    'password': _passwordController.text,
                  },
                );
                context.read<LoginViewCubit>().validateAndSubmit(
                  email: _emailController.text,
                  password: _passwordController.text,
                  onValid: (email, password) {
                    context.read<AuthBloc>().add(
                      AuthEventLogIn(email: email, password: password),
                    );
                  },
                );
              }

              void onBackButtonPressed() {
                getIt<InnerLoggerHandler>().logBreadcrumb(
                  message: 'LoginViewDriver onBackButtonPressed',
                );
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                }
              }

              void onCorrectingCredentials() {
                getIt<InnerLoggerHandler>().logBreadcrumb(
                  message: 'LoginViewDriver onCorrectingCredentials',
                );
                context.read<LoginViewCubit>().clearErrors();
              }

              void onSignUpPressed() {
                getIt<InnerLoggerHandler>().logBreadcrumb(
                  message: 'LoginViewDriver onSignUpPressed',
                );
                context.read<LoginViewCubit>().clearErrors();
                context.pushNamed(AppRoutes.register.name);
              }

              void onForgotPasswordPressed() {
                getIt<InnerLoggerHandler>().logBreadcrumb(
                  message: 'LoginViewDriver onForgotPasswordPressed',
                );
                context.read<LoginViewCubit>().clearErrors();
                context.pushNamed(AppRoutes.resetPassword.name);
              }

              if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
                // cupertino view
              }

              return MaterialLoginView(
                layout: layout,
                emailController: _emailController,
                passwordController: _passwordController,
                isSubmitting: isSubmitting,
                onForgotPassword: onForgotPasswordPressed,
                onSignIn: onSignInPressed,
                onSignUp: onSignUpPressed,
                passwordError: passwordError,
                emailError: emailError,
                onBackButtonPressed: onBackButtonPressed,
                onCorrectingCredentials: onCorrectingCredentials,
              );
            },
          ),
        ),
      ),
    );
  }
}
