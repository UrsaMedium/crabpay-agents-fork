import 'package:crabpay/views/custom_ui_elements/dialogs/generic_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';

Future<bool?> showOnDatabaseItemDelete(BuildContext context) {
  return showAppGenericDialog(
    context: context,
    title: context.l10n.deleteConfirmation,
    message: context.l10n.deleteItemWarning,
    optionBuilder: () => {context.l10n.delete: true, context.l10n.cancel: false},
  ).then((onValue) => onValue ?? false);
}
