import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The Figma "Button / Primary": brand fill with a subtle top highlight,
/// 52px tall, 8px radius. Shows a spinner and ignores taps while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? 0.6 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Ink(
              height: 52,
              width: expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.alphaBlend(Colors.white.withValues(alpha: 0.16), AppColors.primary),
                    AppColors.primary,
                  ],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x1C000000), offset: Offset(0, 3), blurRadius: 3, spreadRadius: -1.5),
                  BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 3, spreadRadius: -0.5),
                ],
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading) ...[
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary50),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: AppText.button),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
