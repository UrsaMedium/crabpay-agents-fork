import 'package:crabpay/views/custom_ui_elements/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';

Future<bool?> showOnLoginDialog(BuildContext context) {
  return showAppGenericDialog(
    context: context,
    title: context.l10n.verificationNeeded,
    message: context.l10n.lookForVerificationLink,
    optionBuilder: () => {context.l10n.sendAgain: true, context.l10n.ok: false},
  ).then((onValue) => onValue ?? false);
}
