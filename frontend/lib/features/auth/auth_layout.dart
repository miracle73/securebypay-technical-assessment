import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Split layout shared by Sign in / Sign up.
/// Desktop: form on the left, brand panel (world map + tagline) on the right,
/// matching the 700/740 split of the 1440px Figma frame.
/// Tablet/mobile: the panel is dropped and the form is centred.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.panelTitle,
    required this.panelBody,
  });

  final String title;
  final Widget subtitle;
  final Widget form;
  final String panelTitle;
  final String panelBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        final desktop = Breakpoints.isDesktop(c.maxWidth);
        final mobile = Breakpoints.isMobile(c.maxWidth);
        final formPane = _FormPane(
          title: title,
          subtitle: subtitle,
          form: form,
          horizontalPadding: mobile ? AppSpacing.md + 4 : (desktop ? 100 : 64),
        );
        if (!desktop) return formPane;
        return Row(children: [
          Expanded(flex: 700, child: formPane),
          Expanded(flex: 740, child: _BrandPanel(title: panelTitle, body: panelBody)),
        ]);
      }),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.horizontalPadding,
  });

  final String title;
  final Widget subtitle;
  final Widget form;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 536),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h1.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width < Breakpoints.tablet ? 26 : 32,
                  )),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(constraints: const BoxConstraints(maxWidth: 453), child: subtitle),
                  const SizedBox(height: 36),
                  form,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dotted world map, anchored to the top like the Figma frame.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/world_map.png', fit: BoxFit.fitWidth),
          ),
          Positioned(
            left: 69,
            right: 69,
            bottom: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 411),
                  child: Text(title,
                      style: GoogleFonts.dmSans(
                          fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4)),
                ),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 579),
                  child: Text(body,
                      style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white.withValues(alpha: 0.85), height: 1.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
