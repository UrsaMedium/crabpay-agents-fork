import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/login_view/driver/login_view_cubit.dart';
import 'package:material_ui/material_ui.dart';

class MaterialLoginView extends StatelessWidget {
  final LoginViewLayout layout;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onCorrectingCredentials;

  const MaterialLoginView({
    super.key,
    required this.layout,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
    required this.isSubmitting,
    required this.onSignIn,
    required this.onSignUp,
    required this.onForgotPassword,
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
                  context.l10n.pleaseSignIn,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: layout.titleFontSize,
                    fontWeight: FontWeight.w900,
                    color: context.appColorScheme.primary,
                  ),
                ),
                SizedBox(height: layout.titleSpacing),
                Text(
                  context.l10n.authorizationWillBeHappeningHere,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: layout.subtitleFontSize),
                ),
                SizedBox(height: layout.sectionSpacing),
                TextField(
                  controller: emailController,
                  keyboardType: .emailAddress,
                  onChanged: (_) => onCorrectingCredentials(),
                  decoration: InputDecoration(
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
                    labelText: context.l10n.email,
                    labelStyle: TextStyle(fontSize: layout.subtitleFontSize),
                    filled: true,
                  ),
                ),
                SizedBox(height: layout.fieldSpacing),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  onChanged: (_) => onCorrectingCredentials(),
                  decoration: InputDecoration(
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
                    labelText: context.l10n.password,
                    labelStyle: TextStyle(fontSize: layout.subtitleFontSize),
                    filled: true,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onForgotPassword,
                    style: TextButton.styleFrom(
                      minimumSize: Size(layout.minTapTarget, layout.minTapTarget),
                    ),
                    child: Text(
                      context.l10n.forgotPassword,
                      style: TextStyle(fontSize: layout.linkFontSize),
                    ),
                  ),
                ),
                SizedBox(height: layout.sectionSpacing),
                ElevatedButton(
                  onPressed: isSubmitting ? null : onSignIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, layout.buttonMinHeight),
                    padding: layout.buttonPadding,
                    backgroundColor: context.appColorScheme.primary,
                    foregroundColor: context.appColorScheme.onPrimary,
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
                          context.l10n.signIn,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: layout.buttonFontSize,
                          ),
                        ),
                ),
                SizedBox(height: layout.dividerSectionSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: layout.dividerThickness,
                        color: context.appColorScheme.outline,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: layout.dividerLabelMaxWidth),
                      child: Padding(
                        padding: layout.dividerTextPadding,
                        child: Text(
                          context.l10n.dontHaveAnAccount,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: layout.dividerLabelFontSize),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: layout.dividerThickness,
                        color: context.appColorScheme.outline,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout.fieldSpacing),
                ElevatedButton(
                  onPressed: onSignUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, layout.buttonMinHeight),
                    padding: layout.buttonPadding,
                  ),
                  child: Text(
                    context.l10n.signUp,
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
