import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/primary_button.dart';
import 'auth_layout.dart';
import 'auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Only Nigeria is offered, matching the "+234" in the design.
  static const _dialCode = '+234';

  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  ApiException? _error;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Strip a leading 0 from local-format numbers (0801... -> 801...).
      final national = _phone.text.replaceAll(RegExp(r'[\s-]'), '').replaceFirst(RegExp(r'^0'), '');
      await AuthScope.read(context).register(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        phone: '$_dialCode$national',
        password: _password.text,
      );
      // The router redirects to /dashboard once the session is set.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create an account',
      subtitle: LinkText(parts: [
        'Sign up for Myafrimall and gain unlimited access to shipping to over 300 countries from Nigeria. Do you already have an account? ',
        ('Login', () => context.go('/login')),
      ]),
      panelTitle: 'Seamlessly Delivering to Over 300 Countries from Nigeria!',
      panelBody:
          'Access global markets with our quick shipping from Nigeria! Fast delivery and easy customs to 300+ countries.',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NameRow(first: _first, last: _last, enabled: !_loading),
              const SizedBox(height: AppSpacing.xl),
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
                label: 'Phone Number',
                hint: '8012345678',
                controller: _phone,
                enabled: !_loading,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                validator: Validators.phone,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_dialCode, style: AppText.input.copyWith(color: AppColors.neutral400)),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.neutral400),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: 'Password',
                hint: 'Enter Password',
                controller: _password,
                enabled: !_loading,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.newPassword,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_error != null) ...[
                FormErrorBanner(error: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              PrimaryButton(
                label: 'Create account',
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

/// First/last name side by side; stacked on narrow phones.
class _NameRow extends StatelessWidget {
  const _NameRow({required this.first, required this.last, required this.enabled});

  final TextEditingController first;
  final TextEditingController last;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final firstField = LabeledField(
      label: 'First name',
      hint: 'John',
      controller: first,
      enabled: enabled,
      autofillHints: const [AutofillHints.givenName],
      validator: (v) => Validators.required(v, 'First name'),
    );
    final lastField = LabeledField(
      label: 'Last name',
      hint: 'Doe',
      controller: last,
      enabled: enabled,
      autofillHints: const [AutofillHints.familyName],
      validator: (v) => Validators.required(v, 'Last name'),
    );
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 380) {
        return Column(children: [firstField, const SizedBox(height: AppSpacing.xl), lastField]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: firstField),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: lastField),
      ]);
    });
  }
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 393),
      child: const LinkText(parts: [
        'By clicking on create account you agree to our ',
        ('privacy policy', null),
        ' and ',
        ('terms of use', null),
      ]),
    );
  }
}
