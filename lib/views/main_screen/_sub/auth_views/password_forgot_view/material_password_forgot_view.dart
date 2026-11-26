import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:material_ui/material_ui.dart';
import 'package:crabpay/core/extensions/l10n_extension.dart';

class MaterialPasswordForgotView extends StatelessWidget {
  final TextEditingController emailControler;
  final bool isSubmitting;
  final String? emailError;
  final VoidCallback onSendResetLinkPressed;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onCorrectingCredentials;
  const MaterialPasswordForgotView({
    super.key,
    required this.emailControler,
    required this.isSubmitting,
    this.emailError,
    required this.onSendResetLinkPressed,
    required this.onBackButtonPressed,
    required this.onCorrectingCredentials,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            onBackButtonPressed();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(
              context.l10n.resetPassword,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: context.appColorScheme.primary,
              ),
            ),
            Container(height: 10),
            Text(
              context.l10n.resetInstructionsEmail,
            ),
            Container(height: 40),
            TextField(
              controller: emailControler,
              autocorrect: false,
              keyboardType: .emailAddress,
              onChanged: (_) => onCorrectingCredentials(),
              decoration: InputDecoration(
                filled: true,
                label: Text(context.l10n.email),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: emailError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: emailError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
              ),
            ),
            Container(height: 40),
            ElevatedButton(
              onPressed: isSubmitting ? null : onSendResetLinkPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColorScheme.primary,
                foregroundColor: context.appColorScheme.onPrimary,
                minimumSize: Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? CircularProgressIndicator()
                  : Text(
                      context.l10n.sendResetLink,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
