import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

final naira = NumberFormat.currency(symbol: 'N', decimalDigits: 2);

/// Overview heading + balance card + three stat cards.
/// Desktop: one row (448px balance + 3 stats). Tablet: balance on its own row.
/// Mobile: balance full width, then three compact stat cards in one row.
class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, required this.overview});

  final Overview overview;

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatCard(icon: Icons.local_shipping_outlined, iconBg: const Color(0xFFFDEBD2), iconFg: const Color(0xFFC77700), label: 'Total Shipment', value: overview.totalShipments),
      StatCard(icon: Icons.arrow_upward, iconBg: const Color(0xFFD9FBD4), iconFg: AppColors.success, label: 'Total Exports', value: overview.totalExports),
      StatCard(icon: Icons.arrow_downward, iconBg: const Color(0xFFD6F4FB), iconFg: const Color(0xFF0E7490), label: 'Total Import', value: overview.totalImports),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Overview', style: AppText.h2)),
        const _PeriodDropdown(),
      ]),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, c) {
        final balance = BalanceCard(balance: overview.balance);
        if (c.maxWidth >= 1000) {
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(flex: 448, child: balance),
              for (final s in stats) ...[const SizedBox(width: 24), Expanded(flex: 207, child: s)],
            ]),
          );
        }
        final statRow = c.maxWidth >= 300
            ? IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: stats[i]),
                  ],
                ]),
              )
            : Column(children: [
                for (final s in stats) ...[s, const SizedBox(height: 12)],
              ]);
        // Phones get compact cards so all three stats fit on one row.
        if (c.maxWidth < 520) {
          return Column(children: [
            balance,
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: stats[i].compacted()),
                ],
              ]),
            ),
          ]);
        }
        return Column(children: [balance, const SizedBox(height: 16), statRow]);
      }),
    ]);
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('This Month', style: AppText.bodySmall.copyWith(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
      ]),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Balance', style: AppText.caption.copyWith(color: Colors.white70)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(naira.format(balance),
              style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Fund Wallet', style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ]),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.value,
    this.compact = false,
  });

  StatCard compacted() => StatCard(icon: icon, iconBg: iconBg, iconFg: iconFg, label: label, value: value, compact: true);

  /// Stacked icon-over-label layout for narrow phone columns.
  final bool compact;

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: iconBg, child: Icon(icon, size: 20, color: iconFg)),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: AppText.caption.copyWith(color: AppColors.gray800))),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text('$value', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_upward, size: 12, color: AppColors.success),
          Text('90%', style: AppText.caption.copyWith(color: AppColors.success)),
        ]),
        const SizedBox(height: 4),
        Text.rich(TextSpan(
          style: AppText.caption.copyWith(fontSize: 10),
          children: const [TextSpan(text: 'Vs last month: '), TextSpan(text: '4', style: TextStyle(fontWeight: FontWeight.w700))],
        )),
      ]),
    );
  }
}

extension on StatCard {
  Widget _buildCompact() => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 14, backgroundColor: iconBg, child: Icon(icon, size: 15, color: iconFg)),
          const SizedBox(height: 8),
          Text(label, style: AppText.caption.copyWith(fontSize: 11, color: AppColors.gray800), maxLines: 2),
          const Spacer(),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text('$value', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.gray800)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_upward, size: 10, color: AppColors.success),
            Flexible(child: Text('90%', style: AppText.caption.copyWith(fontSize: 10, color: AppColors.success))),
          ]),
        ]),
      );
}
