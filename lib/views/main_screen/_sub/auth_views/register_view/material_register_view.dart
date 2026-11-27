import 'package:crabpay/core/extensions/l10n_extension.dart';
import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/views/main_screen/_sub/auth_views/register_view/driver/register_view_cubit.dart';
import 'package:material_ui/material_ui.dart';

class MaterialRegisterView extends StatelessWidget {
  final RegisterViewLayout layout;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final VoidCallback onRegistering;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onCorrectingCredentials;

  const MaterialRegisterView({
    super.key,
    required this.layout,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
    required this.isSubmitting,
    required this.onRegistering,
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
                  context.l10n.createAccount,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: layout.titleFontSize,
                    fontWeight: FontWeight.w900,
                    color: context.appColorScheme.primaryFixedDim,
                  ),
                ),
                SizedBox(height: layout.titleSpacing),
                Text(
                  context.l10n.createAnAccountToShop,
                  style: TextStyle(fontSize: layout.subtitleFontSize),
                ),
                SizedBox(height: layout.sectionSpacing),
                TextField(
                  controller: emailController,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
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
                    label: Text(context.l10n.email),
                    labelStyle: TextStyle(fontSize: layout.subtitleFontSize),
                    filled: true,
                  ),
                ),
                SizedBox(height: layout.fieldSpacing),
                TextField(
                  controller: passwordController,
                  autocorrect: false,
                  obscureText: true,
                  onChanged: (_) => onCorrectingCredentials(),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: passwordError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                      ),
                      borderRadius: inputBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: passwordError != null ? context.appColorScheme.error : context.appColorScheme.primaryFixed,
                      ),
                      borderRadius: inputBorderRadius,
                    ),
                    label: Text(context.l10n.password),
                    labelStyle: TextStyle(fontSize: layout.subtitleFontSize),
                    filled: true,
                  ),
                ),
                SizedBox(height: layout.submitTopSpacing),
                ElevatedButton(
                  onPressed: onRegistering,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColorScheme.primary,
                    foregroundColor: context.appColorScheme.onPrimary,
                    minimumSize: Size(double.infinity, layout.buttonMinHeight),
                    padding: layout.buttonPadding,
                  ),
                  child: Text(
                    context.l10n.submit,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: layout.buttonFontSize,
                    ),
                  ),
                ),
                SizedBox(height: layout.dividerSpacing),
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
                          context.l10n.youHaveOneAlreadyThen,
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
                SizedBox(height: layout.dividerSpacing),
                ElevatedButton(
                  onPressed: onBackButtonPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, layout.buttonMinHeight),
                    padding: layout.buttonPadding,
                  ),
                  child: Text(
                    context.l10n.signIn,
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
