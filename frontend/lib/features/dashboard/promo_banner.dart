import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/tokens.dart';

/// "KEEP UP WITH YOUR BUSINESS NEEDS" hero carousel with page dots.
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const _slides = 3;
  final _controller = PageController(initialPage: 1);
  int _page = 1; // the design shows the middle dot active

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LayoutBuilder(builder: (context, c) {
        // Height scales with width (245 at the 1141px design width), within limits.
        final h = (c.maxWidth * 245 / 1141).clamp(160.0, 245.0);
        return SizedBox(
          height: h,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, __) => _Slide(height: h, width: c.maxWidth),
          ),
        );
      }),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _slides; i++)
            GestureDetector(
              onTap: () => _controller.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? AppColors.navy : AppColors.neutral300,
                ),
              ),
            ),
        ],
      ),
    ]);
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final narrow = width < 560;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: ColoredBox(
        color: AppColors.navy,
        child: Stack(children: [
          Positioned(
              right: width * 0.02,
              top: -10,
              bottom: -10,
              child: Opacity(
                opacity: narrow ? 0.35 : 1,
                child: Image.asset('assets/images/boxes.png', fit: BoxFit.contain),
              ),
            ),
          Positioned(
            left: narrow ? 20 : 35.6,
            right: narrow ? 20 : width * 0.45,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'KEEP UP WITH YOUR BUSINESS NEEDS',
                style: GoogleFonts.dmSans(
                  fontSize: narrow ? 26 : 42.5,
                  height: 1.04,
                  letterSpacing: -0.85,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
