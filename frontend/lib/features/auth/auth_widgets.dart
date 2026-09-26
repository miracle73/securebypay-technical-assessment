import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// A tappable segment inside [LinkText]. A null [onTap] renders the link style only.
class Link {
  const Link(this.label, [this.onTap]);

  final String label;
  final VoidCallback? onTap;
}

/// Body copy with inline links, e.g. "Already have an account? **Login**".
/// [parts] may contain plain [String]s and [Link]s.
class LinkText extends StatefulWidget {
  const LinkText(this.parts, {super.key});

  final List<Object> parts;

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TextSpan _span(Object part) {
    if (part is! Link) return TextSpan(text: '$part');

    TapGestureRecognizer? recognizer;
    if (part.onTap != null) {
      recognizer = TapGestureRecognizer()..onTap = part.onTap;
      _recognizers.add(recognizer);
    }
    return TextSpan(
      text: part.label,
      style: AppText.link,
      recognizer: recognizer,
      mouseCursor: recognizer == null ? null : SystemMouseCursors.click,
    );
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Text.rich(TextSpan(style: AppText.body, children: widget.parts.map(_span).toList()));
  }
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 393),
      child: const LinkText([
        'By clicking on create account you agree to our ',
        Link('privacy policy'),
        ' and ',
        Link('terms of use'),
      ]),
    );
  }
}

/// Shown above the submit button when the API rejects a request.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.error});

  final ApiException error;

  @override
  Widget build(BuildContext context) {
    final style = AppText.body.copyWith(color: AppColors.error);
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
                Text(error.message, style: style),
                for (final detail in error.details) Text('• $detail', style: style.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
