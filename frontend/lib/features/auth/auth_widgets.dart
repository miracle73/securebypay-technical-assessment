import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Body text with one or more inline underlined links, e.g.
/// "Do you already have an account? **Login**".
class LinkText extends StatefulWidget {
  const LinkText({super.key, required this.parts});

  /// Plain strings render as body text; `(label, onTap)` records render as links.
  final List<Object> parts;

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    return Text.rich(TextSpan(
      style: AppText.body,
      children: [
        for (final p in widget.parts)
          if (p is (String, VoidCallback?))
            TextSpan(
              text: p.$1,
              style: AppText.link,
              recognizer: p.$2 == null
                  ? null
                  : (TapGestureRecognizer()..onTap = p.$2).also(_recognizers.add),
              mouseCursor: SystemMouseCursors.click,
            )
          else
            TextSpan(text: p.toString()),
      ],
    ));
  }
}

extension _Also<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}

/// Red banner shown above the submit button when the API rejects a request.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.error});

  final ApiException error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error.message, style: AppText.body.copyWith(color: AppColors.error)),
                for (final d in error.details)
                  Text('• $d', style: AppText.body.copyWith(color: AppColors.error, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Client-side validators mirroring the backend DTO rules so users see the
/// same constraints before the request is sent.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    return _email.hasMatch(v.trim()) ? null : 'Enter a valid email address';
  }

  static String? phone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{7,12}$').hasMatch(digits)) return 'Enter a valid phone number';
    return null;
  }

  static String? newPassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include at least one letter and one number';
    }
    return null;
  }
}
