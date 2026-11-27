import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/core/global_language_driver.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/main_screen/_sub/settings_sheet/driver/settings_sheet_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class MaterialSettingsSheet extends StatelessWidget {
  final SettingsSheetLayout layout;
  final Function(bool) onGraphicsToggled;
  final Function(bool) onLangChange;
  const MaterialSettingsSheet({
    super.key,
    required this.layout,
    required this.onGraphicsToggled,
    required this.onLangChange,
  });

  @override
  Widget build(BuildContext context) {
    final highGraphics = context.select<GlobalGraphicBloc, bool>(
      (bloc) => bloc.state.highGraphics,
    );
    final isRu = context.select<GlobalLanguageCubit, bool>(
      (bloc) => bloc.state.isRu,
    );
    return Center(
      heightFactor: 1.0,
      child: SizedBox(
        width: layout.sheetWidth,
        child: Wrap(
          children: [
            Material(
              borderRadius: BorderRadius.vertical(top: .circular(layout.topCornerRadius)),
              clipBehavior: .antiAlias,
              color: Colors.transparent,
              child: BackdropFilter(
                enabled: highGraphics,
                filter: .blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.appColorScheme.surfaceContainer.withValues(
                      alpha: highGraphics ? .5 : .95,
                    ),
                  ),
                  constraints: BoxConstraints(minHeight: layout.sheetMinHeight),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: .topCenter,
                              end: .bottomCenter,
                              colors: [
                                context.appColorScheme.outline.withValues(alpha: .2),
                                context.appColorScheme.outline.withValues(alpha: .1),
                                Colors.transparent,
                                Colors.transparent,
                                context.appColorScheme.outline.withValues(alpha: .1),
                              ],
                            ).createShader(bounds),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: .vertical(top: .circular(layout.borderCornerRadius)),
                                border: .all(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: layout.contentPadding,
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.l10n.highGraphics,
                                      style: TextStyle(fontSize: layout.labelFontSize),
                                    ),
                                  ),
                                  Switch(
                                    value: highGraphics,
                                    onChanged: (value) => onGraphicsToggled(value),
                                  ),
                                ],
                              ),
                              SizedBox(height: layout.rowSpacing),
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.l10n.turnOnRussian,
                                      style: TextStyle(fontSize: layout.labelFontSize),
                                    ),
                                  ),
                                  Switch(
                                    value: isRu,
                                    onChanged: null, //(value) => onLangChange(value),
                                  ),
                                ],
                              ),
                              Divider(
                                height: layout.dividerHeight,
                                thickness: layout.dividerThickness,
                                color: context.appColorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
