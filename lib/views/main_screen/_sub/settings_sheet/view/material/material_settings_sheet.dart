import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/core/global_language_driver.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class MaterialSettingsSheet extends StatelessWidget {
  final Function(bool) onGraphicsToggled;
  final Function(bool) onLangChange;
  const MaterialSettingsSheet({
    super.key,
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
    return Wrap(
      children: [
        Material(
          borderRadius: BorderRadius.vertical(top: .circular(24)),
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
              height: 200,
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
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
                          borderRadius: .circular(27),
                          border: .all(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(context.l10n.highGraphics),
                              Switch(
                                value: highGraphics,
                                onChanged: (value) => onGraphicsToggled(value),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(context.l10n.turnOnRussian),
                              Switch(
                                value: isRu,
                                onChanged: null, //(value) => onLangChange(value),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1,
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
    );
  }
}
