import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/core/global_language_driver.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/app_layout/app_layout.dart';
import 'package:crabpay/views/main_screen/_sub/settings_sheet/driver/settings_sheet_cubit.dart';
import 'package:crabpay/views/main_screen/_sub/settings_sheet/view/material/material_settings_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsSheetDriver extends StatefulWidget {
  const SettingsSheetDriver({super.key});

  @override
  State<SettingsSheetDriver> createState() => _SettingsSheetDriverState();
}

class _SettingsSheetDriverState extends State<SettingsSheetDriver> {
  late final SettingsSheetCubit _settingsSheetCubit;

  @override
  void initState() {
    _settingsSheetCubit = SettingsSheetCubit(
      layoutCubit: context.read<AppLayoutCubit>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _settingsSheetCubit.close();
    super.dispose();
  }

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
    return BlocProvider.value(
      value: _settingsSheetCubit,
      child: Builder(
        builder: (context) {
          final layout = context.select<SettingsSheetCubit, SettingsSheetLayout>(
            (cubit) => cubit.state.layout,
          );
          return MaterialSettingsSheet(
            layout: layout,
            onGraphicsToggled: (toggle) => _onGraphicsToggled(context, toggle),
            onLangChange: (isRu) => _onLangChange(context, isRu),
          );
        },
      ),
    );
  }
}
