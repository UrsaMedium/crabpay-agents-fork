import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_states.dart';
import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/register_view/driver/register_view_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/register_view/material_register_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class RegisterViewDriver extends StatefulWidget {
  static final routeName = AppRoutes.register.name;
  const RegisterViewDriver({super.key});

  @override
  State<RegisterViewDriver> createState() => _RegisterViewDriverState();
}

class _RegisterViewDriverState extends State<RegisterViewDriver> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final RegisterViewCubit _registerViewCubit;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _registerViewCubit = RegisterViewCubit(
      layoutCubit: context.read<AppLayoutCubit>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _registerViewCubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _registerViewCubit,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthStateLoggedIn) {
            context.go(AppRoutes.home.path);
          }
          if (authState is AuthStateLoggedOut) {
            Fluttertoast.showToast(
              msg: 'Registration failed: ${authState.bloodyAuthException.toString()}',
              toastLength: Toast.LENGTH_LONG,
            );
            context.read<RegisterViewCubit>().setErrors(
              emailError: 'Invalid email or password',
              passwordError: 'Invalid email or password',
            );
          }
        },
        child: Builder(
          builder: (context) {
            final layout = context.select<RegisterViewCubit, RegisterViewLayout>(
              (cubit) => cubit.state.layout,
            );
            final isSubmitting = context.select<RegisterViewCubit, bool>(
              (cubit) => cubit.state.isSubmitting,
            );
            final emailError = context.select<RegisterViewCubit, String?>(
              (cubit) => cubit.state.emailError,
            );

            void onRegistering() {
              context.read<RegisterViewCubit>().validateAndSubmit(
                email: _emailController.text,
                password: _passwordController.text,
                onValid: ((email, password) {
                  context.read<AuthBloc>().add(
                    AuthEventRegister(email: email, password: password),
                  );
                }),
              );
            }

            void onBackButtonPressed() {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              }
            }

            void onCorrectingCredentials() {
              context.read<RegisterViewCubit>().clearErrors();
            }

            return MaterialRegisterView(
              layout: layout,
              emailController: _emailController,
              passwordController: _passwordController,
              isSubmitting: isSubmitting,
              emailError: emailError,
              passwordError: emailError,
              onBackButtonPressed: onBackButtonPressed,
              onCorrectingCredentials: onCorrectingCredentials,
              onRegistering: onRegistering,
            );
          },
        ),
      ),
    );
  }
}
