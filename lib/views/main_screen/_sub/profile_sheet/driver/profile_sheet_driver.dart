import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_events.dart';
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
    return MaterialProfileSheet(
      user: context.read<AuthBloc>().state.currentUser,
      onSignOutPressed: () => _onSignOutPressed(context),
      onAdminPressed: () => _onAdminPressed(context),
      isAdmin: context.read<AuthBloc>().state.currentUser.isAdmin,
    );
  }
}
