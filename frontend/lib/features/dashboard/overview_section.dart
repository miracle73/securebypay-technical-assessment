import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

final _naira = NumberFormat.currency(symbol: 'N', decimalDigits: 2);

/// Balance card + three stat cards.
/// Wide: a single row. Medium: balance above a row of stats.
/// Narrow: balance above three compact stat cards.
class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, required this.overview});

  final Overview overview;

  static const _wideBreakpoint = 1000.0;
  static const _compactBreakpoint = 520.0;

  List<_Stat> get _stats => [
        _Stat(Icons.local_shipping_outlined, AppColors.shipmentBg, AppColors.shipmentFg, 'Total Shipment',
            overview.totalShipments),
        _Stat(Icons.arrow_upward, AppColors.exportBg, AppColors.success, 'Total Exports', overview.totalExports),
        _Stat(Icons.arrow_downward, AppColors.importBg, AppColors.delayedFg, 'Total Import', overview.totalImports),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Overview', style: AppText.h2)),
        const _PeriodDropdown(),
      ]),
      const SizedBox(height: AppSpacing.lg),
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final balance = BalanceCard(balance: overview.balance);

        if (width >= _wideBreakpoint) {
          return _EqualHeightRow(gap: AppSpacing.lg, flexes: const [
            448,
            207,
            207,
            207
          ], children: [
            balance,
            for (final s in _stats) _StatCard(stat: s),
          ]);
        }

        final compact = width < _compactBreakpoint;
        return Column(children: [
          balance,
          SizedBox(height: compact ? 12 : AppSpacing.md),
          _EqualHeightRow(
            gap: compact ? AppSpacing.sm : AppSpacing.md,
            children: [for (final s in _stats) _StatCard(stat: s, compact: compact)],
          ),
        ]);
      }),
    ]);
  }
}

class _EqualHeightRow extends StatelessWidget {
  const _EqualHeightRow({required this.children, required this.gap, this.flexes});

  final List<Widget> children;
  final double gap;
  final List<int>? flexes;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(flex: flexes?[i] ?? 1, child: children[i]),
        ],
      ]),
    );
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
        const SizedBox(width: AppSpacing.xs),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Balance', style: AppText.caption.copyWith(color: Colors.white70)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _naira.format(balance),
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Text(
                'Fund Wallet',
                style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Stat {
  const _Stat(this.icon, this.iconBg, this.iconFg, this.label, this.value);

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final int value;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required _Stat stat, this.compact = false}) : _stat = stat;

  final _Stat _stat;

  /// Icon stacked over the label, for narrow phone columns.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = _stat;
    final avatar = CircleAvatar(
      radius: compact ? 14 : 20,
      backgroundColor: s.iconBg,
      child: Icon(s.icon, size: compact ? 15 : 20, color: s.iconFg),
    );
    final label = Text(
      s.label,
      maxLines: 2,
      style: AppText.caption.copyWith(fontSize: compact ? 11 : null, color: AppColors.gray800),
    );

    return Container(
      padding: EdgeInsets.all(compact ? 10 : AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (compact) ...[avatar, const SizedBox(height: AppSpacing.sm), label, const Spacer()] else
          Row(children: [avatar, const SizedBox(width: AppSpacing.sm), Flexible(child: label)]),
        SizedBox(height: compact ? 6 : 12),
        _TrendValue(value: s.value, compact: compact),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Text.rich(TextSpan(
            style: AppText.caption.copyWith(fontSize: 10),
            children: const [
              TextSpan(text: 'Vs last month: '),
              TextSpan(text: '4', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          )),
        ],
      ]),
    );
  }
}

class _TrendValue extends StatelessWidget {
  const _TrendValue({required this.value, required this.compact});

  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
      Text(
        '$value',
        style: GoogleFonts.manrope(fontSize: compact ? 20 : 24, fontWeight: FontWeight.w500, color: AppColors.gray800),
      ),
      SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
      Icon(Icons.arrow_upward, size: compact ? 10 : 12, color: AppColors.success),
      Flexible(
        child: Text('90%', style: AppText.caption.copyWith(fontSize: compact ? 10 : null, color: AppColors.success)),
      ),
    ]);
  }
}
