import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_states.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/password_forgot_view/driver/password_forgot_view_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/password_forgot_view/material_password_forgot_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PasswordForgotViewDriver extends StatefulWidget {
  static final routeName = AppRoutes.resetPassword.name;
  const PasswordForgotViewDriver({super.key});

  @override
  State<PasswordForgotViewDriver> createState() => _PasswordForgotViewDriverState();
}

class _PasswordForgotViewDriverState extends State<PasswordForgotViewDriver> {
  late final TextEditingController _emailControler;
  late final PasswordForgotViewCubit _passwordForgotViewCubit;

  @override
  void initState() {
    _emailControler = TextEditingController();
    _passwordForgotViewCubit = PasswordForgotViewCubit(
      layoutCubit: context.read<AppLayoutCubit>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _passwordForgotViewCubit.close();
    _emailControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _passwordForgotViewCubit,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          //a state to know that the reset password email has benn sent
        },
        child: Builder(
          builder: (context) {
            final layout = context.select<PasswordForgotViewCubit, PasswordForgotViewLayout>(
              (cubit) => cubit.state.layout,
            );
            final isSubmitting = context.select<PasswordForgotViewCubit, bool>(
              (cubit) => cubit.state.isSubmitting,
            );
            final emailError = context.select<PasswordForgotViewCubit, String?>(
              (cubit) => cubit.state.emailError,
            );

            void onSendResetLinkPressed() {
              context.read<PasswordForgotViewCubit>().validateAndSubmit(
                email: _emailControler.text,
                onValid: (email) => context.read<AuthBloc>().add(
                  AuthEventForgotPassword(email: email),
                ),
              );
            }

            void onBackButtonPressed() {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              }
            }

            void onCorrectingCredentials() {
              context.read<PasswordForgotViewCubit>().clearErrors();
            }

            return MaterialPasswordForgotView(
              layout: layout,
              emailControler: _emailControler,
              isSubmitting: isSubmitting,
              emailError: emailError,
              onBackButtonPressed: onBackButtonPressed,
              onCorrectingCredentials: onCorrectingCredentials,
              onSendResetLinkPressed: onSendResetLinkPressed,
            );
          },
        ),
      ),
    );
  }
}
