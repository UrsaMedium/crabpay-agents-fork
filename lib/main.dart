import 'package:crabpay/core/app_routes/app_router.dart';
import 'package:crabpay/core/set_up/app_bootstrap.dart';
import 'package:crabpay/core/set_up/app_providers.dart';
import 'package:crabpay/views/app/view/material/material_crabpay_app.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  await AppBootstrap.init();
  runApp(const AppProviders(child: CrabPayApp()));
}

class CrabPayApp extends StatelessWidget {
  const CrabPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialCrabPayApp(routerConfig: appRouter);
  }
}
