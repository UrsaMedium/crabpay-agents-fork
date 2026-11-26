import 'package:crabpay/l10n/app_localizations.dart';
import 'package:crabpay/views/app/view/material/material_app_theme.dart';
import 'package:crabpay/views/custom_ui_elements/widgets/global_loading_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';

class MaterialCrabPayApp extends StatelessWidget {
  final RouterConfig<Object> routerConfig;
  const MaterialCrabPayApp({super.key, required this.routerConfig});

  @override
  Widget build(BuildContext context) {
    final overlayKey = GlobalKey<OverlayState>();
    return SafeArea(
      top: false,
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp.router(
            showPerformanceOverlay: false,
            debugShowCheckedModeBanner: false,
            title: 'CrabPay Demo',
             theme: AppTheme.light(lightDynamic),
             darkTheme: AppTheme.dark(darkDynamic),
            routerConfig: routerConfig,
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              // ignore: deprecated_member_use
              return MaterialUiCompatibilityBridge(
                child: GlobalLoaderStack(
                  child: Overlay(
                    key: overlayKey,
                    initialEntries: [OverlayEntry(builder: (context) => child!)],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
