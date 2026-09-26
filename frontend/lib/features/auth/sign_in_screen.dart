import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/auth_scope.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/primary_button.dart';
import 'auth_layout.dart';
import 'auth_widgets.dart';
import 'validators.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  ApiException? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthScope.read(context).login(email: _email.text.trim(), password: _password.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign in to your account',
      subtitle: LinkText([
        'Log in to Myafrimall to enjoy seamless shipping to over 300 countries right from Nigeria. Don’t have an account yet? ',
        Link('Sign Up', () => context.go('/signup')),
      ]),
      panelTitle: 'Effortlessly Track Your Shipments from Nigeria!',
      panelBody: 'Monitor your shipments from Nigeria! Enjoy swift delivery and seamless customs processing',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(
                label: 'Email',
                hint: 'user@example.com',
                controller: _email,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: 'Password',
                hint: 'Enter Password',
                controller: _password,
                enabled: !_loading,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) => Validators.required(v, 'Password'),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset is not available in this demo.')),
                ),
                child: Text('Forgot Password?', style: AppText.link),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_error != null) ...[
                FormErrorBanner(error: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              PrimaryButton(
                label: 'Login',
                loading: _loading,
                onPressed: _submit,
                expand: MediaQuery.sizeOf(context).width < Breakpoints.tablet,
              ),
              const SizedBox(height: AppSpacing.lg),
              const TermsText(),
            ],
          ),
        ),
      ),
    );
  }
}
