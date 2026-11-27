import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/profile_sheet/driver/profile_sheet_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/profile_sheet/view/material/material_profile_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileSheetDriver extends StatefulWidget {
  const ProfileSheetDriver({super.key});

  @override
  State<ProfileSheetDriver> createState() => _ProfileSheetDriverState();
}

class _ProfileSheetDriverState extends State<ProfileSheetDriver> {
  late final ProfileSheetCubit _profileSheetCubit;

  @override
  void initState() {
    _profileSheetCubit = ProfileSheetCubit(
      layoutCubit: context.read<AppLayoutCubit>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _profileSheetCubit.close();
    super.dispose();
  }

  void _onSignOutPressed(BuildContext context) {
    context.read<AuthBloc>().add(AuthEventLogOut());
    if (context.canPop()) {
      context.pop();
    }
  }

  void _onAdminPressed(BuildContext context) {
    context.push(AppRoutes.adminTools.path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileSheetCubit,
      child: Builder(
        builder: (context) {
          final layout = context.select<ProfileSheetCubit, ProfileSheetLayout>(
            (cubit) => cubit.state.layout,
          );
          final user = context.select<AuthBloc, AppAuthUser>(
            (bloc) => bloc.state.currentUser,
          );
          return MaterialProfileSheet(
            layout: layout,
            user: user,
            onSignOutPressed: () => _onSignOutPressed(context),
            onAdminPressed: () => _onAdminPressed(context),
            isAdmin: user.isAdmin,
          );
        },
      ),
    );
  }
}
