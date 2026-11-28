import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_bloc/auth_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_bloc.dart';
import 'package:crabpay/core/backend/database/general_db/db_inner_circle/database_bloc/database_event.dart';
import 'package:crabpay/core/app_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminToolsView extends StatefulWidget {
  const AdminToolsView({super.key});

  @override
  State<AdminToolsView> createState() => _AdminToolsViewState();
}

class _AdminToolsViewState extends State<AdminToolsView> {
  AppAuthUser? user;
  @override
  Widget build(BuildContext context) {
    // final currentUser = context.read<AuthBloc>().state.currentUser;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        !Navigator.of(context).canPop() ? context.go(AppRoutes.home.path) : context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<DatabaseBloc>().add(
                        DatabaseEventFetchAllProducts(),
                      );
                    },
                    child: Text(context.l10n.fetchData),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(AppRoutes.addCompleteProduct.name),
                    child: Text(context.l10n.addCompleteProduct),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(AppRoutes.deleting.name),
                    child: Text(context.l10n.deleteInstancesFromDb),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(AppRoutes.addFeaturedProduct.name),
                    child: Text(context.l10n.addFeaturedProduct),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(AppRoutes.chooseThread.name),
                    child: Text(context.l10n.answerToUsers),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          user = context.read<AuthBloc>().state.currentUser;
                          setState(() {});
                        },
                        child: Text(context.l10n.hey),
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.userInfoDebug(
                      user?.id ?? '',
                      user?.email ?? '',
                      user?.isEmailVerified.toString() ?? '',
                      user?.isAnonymous.toString() ?? '',
                      user?.isAdmin.toString() ?? '',
                      user?.isLimbo.toString() ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
