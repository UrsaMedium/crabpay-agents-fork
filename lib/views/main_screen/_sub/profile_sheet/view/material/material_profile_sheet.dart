import 'package:crabpay/core/backend/authentication/auth_inner_circle/auth_user.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/main_screen/_sub/profile_sheet/driver/profile_sheet_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class MaterialProfileSheet extends StatelessWidget {
  final ProfileSheetLayout layout;
  final bool isAdmin;
  final VoidCallback onSignOutPressed;
  final VoidCallback onAdminPressed;
  final AppAuthUser user;
  const MaterialProfileSheet({
    super.key,
    required this.layout,
    required this.user,
    required this.onSignOutPressed,
    required this.isAdmin,
    required this.onAdminPressed,
  });

  @override
  Widget build(BuildContext context) {
    final highGraphics = context.select<GlobalGraphicBloc, bool>(
      (bloc) => bloc.state.highGraphics,
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
                      Padding(
                        padding: layout.contentPadding,
                        child: Column(
                          mainAxisSize: .min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.yourProfile,
                                        style: TextStyle(
                                          fontSize: layout.titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: context.appColorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        user.email ?? '',
                                        style: TextStyle(fontSize: layout.emailFontSize),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: layout.rowSpacing),
                                ElevatedButton(
                                  onPressed: onSignOutPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.appColorScheme.primary,
                                    foregroundColor: context.appColorScheme.onPrimary,
                                    minimumSize: Size(0, layout.signOutButtonMinHeight),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.logout_outlined),
                                      SizedBox(width: layout.buttonIconSpacing),
                                      Text(
                                        context.l10n.signOut,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: layout.buttonFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: layout.dividerHeight,
                              thickness: layout.dividerThickness,
                              color: context.appColorScheme.outline,
                            ),
                            if (isAdmin)
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.l10n.adminMenu,
                                      style: TextStyle(
                                        fontSize: layout.titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: context.appColorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => onAdminPressed(),
                                    icon: Icon(Icons.settings),
                                  ),
                                ],
                              ),
                          ],
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
