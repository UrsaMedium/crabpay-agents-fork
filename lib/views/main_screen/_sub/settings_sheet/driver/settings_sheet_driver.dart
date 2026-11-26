import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/core/global_language_driver.dart';
import 'package:crabpay/views/main_screen/_sub/settings_sheet/view/material/material_settings_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsSheetDriver extends StatefulWidget {
  const SettingsSheetDriver({super.key});

  @override
  State<SettingsSheetDriver> createState() => _SettingsSheetDriverState();
}

class _SettingsSheetDriverState extends State<SettingsSheetDriver> {
  void _onGraphicsToggled(BuildContext context, bool toggle) {
    if (toggle) {
      context.read<GlobalGraphicBloc>().add(GlobalGraphicEventSetHigh());
    } else {
      context.read<GlobalGraphicBloc>().add(GlobalGraphicEventSetLow());
    }
  }

  void _onLangChange(BuildContext context, bool isRu) {
    context.read<GlobalLanguageCubit>().setRuLang(isRu: isRu);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialSettingsSheet(
      onGraphicsToggled: (toggle) => _onGraphicsToggled(context, toggle),
      onLangChange: (isRu) => _onLangChange(context, isRu),
    );
  }
}
