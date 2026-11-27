import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/password_forgot_view/driver/password_forgot_view_cubit.dart';
import 'package:material_ui/material_ui.dart';

class MaterialPasswordForgotView extends StatelessWidget {
  final PasswordForgotViewLayout layout;
  final TextEditingController emailControler;
  final bool isSubmitting;
  final String? emailError;
  final VoidCallback onSendResetLinkPressed;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onCorrectingCredentials;

  const MaterialPasswordForgotView({
    super.key,
    required this.layout,
    required this.emailControler,
    required this.isSubmitting,
    this.emailError,
    required this.onSendResetLinkPressed,
    required this.onBackButtonPressed,
    required this.onCorrectingCredentials,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius inputBorderRadius = BorderRadius.all(
      Radius.circular(layout.inputCornerRadius),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBackButtonPressed,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: layout.contentPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.contentWidth),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  context.l10n.resetPassword,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: layout.titleFontSize,
                    fontWeight: FontWeight.w900,
                    color: context.appColorScheme.primary,
                  ),
                ),
                SizedBox(height: layout.titleSpacing),
                Text(
                  context.l10n.resetInstructionsEmail,
                  style: TextStyle(fontSize: layout.subtitleFontSize),
                ),
                SizedBox(height: layout.sectionSpacing),
                TextField(
                  controller: emailControler,
                  autocorrect: false,
                  keyboardType: .emailAddress,
                  onChanged: (_) => onCorrectingCredentials(),
                  decoration: InputDecoration(
                    filled: true,
                    label: Text(context.l10n.email),
                    labelStyle: TextStyle(fontSize: layout.subtitleFontSize),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: emailError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                      ),
                      borderRadius: inputBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: emailError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                      ),
                      borderRadius: inputBorderRadius,
                    ),
                  ),
                ),
                SizedBox(height: layout.sectionSpacing),
                ElevatedButton(
                  onPressed: isSubmitting ? null : onSendResetLinkPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColorScheme.primary,
                    foregroundColor: context.appColorScheme.onPrimary,
                    minimumSize: Size(double.infinity, layout.buttonMinHeight),
                    padding: layout.buttonPadding,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: layout.loadingIndicatorSize,
                          height: layout.loadingIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: layout.loadingIndicatorStrokeWidth,
                          ),
                        )
                      : Text(
                          context.l10n.sendResetLink,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: layout.buttonFontSize,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
