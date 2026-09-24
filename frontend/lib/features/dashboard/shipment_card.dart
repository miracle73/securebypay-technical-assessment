import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

final _amount = NumberFormat.currency(symbol: 'N', decimalDigits: 0);

/// Expandable shipment summary. Header row (tracking/sender/receiver) is
/// always visible; route, amount, status and actions show when expanded.
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({super.key, required this.shipment});

  final Shipment shipment;

  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    final mobile = Breakpoints.isMobile(MediaQuery.sizeOf(context).width);
    const divider = Divider(height: 32, color: AppColors.gray200);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: _Grid(mobile: mobile, children: [
              _Field('Tracking ID', Text(s.trackingId, style: AppText.bodySmall.copyWith(color: AppColors.primary, fontSize: 15))),
              _Field('Sender', _value(s.sender)),
              _Field('Receiver', _value(s.receiver)),
            ]),
          ),
          IconButton(
            tooltip: _expanded ? 'Collapse' : 'Expand',
            icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.gray800),
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
        ]),
        if (_expanded) ...[
          divider,
          _Grid(mobile: mobile, children: [
            _Field('Pick Up From', _flagged(s.pickUpFrom)),
            _Field('Delivery To', _flagged(s.deliveryTo)),
            _Field('Amount', _value(_amount.format(s.amount))),
            _Field('Status', StatusChip(status: s.status), alignEnd: !mobile),
          ]),
          divider,
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 12,
            spacing: 12,
            children: [
              _Field('Processing time', Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.timer_outlined, size: 18, color: AppColors.gray800),
                const SizedBox(width: 8),
                _value('${s.processingHours} hours'),
              ])),
              Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray800,
                    side: const BorderSide(color: AppColors.gray800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                  child: const Text('View More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                s.paid
                    ? FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          disabledBackgroundColor: AppColors.gray100,
                          disabledForegroundColor: AppColors.gray400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                        child: const Text('Paid', style: TextStyle(fontSize: 12)),
                      )
                    : FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                        child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
              ]),
            ],
          ),
        ],
      ]),
    );
  }

  Widget _value(String v) => Text(v, style: AppText.bodySmall.copyWith(fontSize: 15));

  Widget _flagged(String place) => Row(mainAxisSize: MainAxisSize.min, children: [
        const _NigeriaFlag(),
        const SizedBox(width: 8),
        Flexible(child: Text(place, style: AppText.bodySmall, overflow: TextOverflow.ellipsis)),
      ]);
}

/// Lays fields out in a row on wide screens, 2 columns on mobile.
class _Grid extends StatelessWidget {
  const _Grid({required this.children, required this.mobile});

  final List<Widget> children;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (!mobile) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final c in children) Expanded(child: c),
      ]);
    }
    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - 16) / 2;
      return Wrap(spacing: 16, runSpacing: 16, children: [for (final c in children) SizedBox(width: w, child: c)]);
    });
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.alignEnd = false});

  final String label;
  final Widget value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppText.caption.copyWith(fontSize: 11)),
        const SizedBox(height: 8),
        value,
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ShipmentStatus.inTransit => ('In-Transit', AppColors.transitBg, AppColors.transitFg),
      ShipmentStatus.delayed => ('Delayed', AppColors.delayedBg, AppColors.delayedFg),
      ShipmentStatus.delivered => ('Delivered', AppColors.deliveredBg, AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Text(label, style: AppText.caption.copyWith(fontSize: 11, color: fg)),
    );
  }
}

/// Green-white-green flag drawn with boxes (no image asset needed).
class _NigeriaFlag extends StatelessWidget {
  const _NigeriaFlag();

  @override
  Widget build(BuildContext context) {
    const g = Color(0xFF008751);
    return SizedBox(
      width: 14,
      height: 10,
      child: Row(children: [
        Expanded(child: ColoredBox(color: g)),
        Expanded(child: ColoredBox(color: Colors.white)),
        Expanded(child: ColoredBox(color: g)),
      ]),
    );
  }
}
