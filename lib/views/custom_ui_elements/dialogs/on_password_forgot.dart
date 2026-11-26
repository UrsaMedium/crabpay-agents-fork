import 'package:crabpay/views/custom_ui_elements/dialogs/generic_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';

Future<void> showOnPasswordResetDialog(BuildContext context) {
  return showAppGenericDialog(
    context: context,
    title: context.l10n.resetLinkSent,
    message: context.l10n.checkEmailSent,
    optionBuilder: () => {'OK': null},
  );
}
