import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/auth_scope.dart';
import 'dashboard_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// "Company Growth" card with a Year/Month/Week toggle.
class GrowthChartCard extends StatefulWidget {
  const GrowthChartCard({super.key});

  @override
  State<GrowthChartCard> createState() => _GrowthChartCardState();
}

class _GrowthChartCardState extends State<GrowthChartCard> {
  late final _repository = DashboardRepository(AuthScope.read(context).api);
  GrowthPeriod _period = GrowthPeriod.year;
  late Future<List<double>> _points = _repository.growth(_period);

  @override
  Widget build(BuildContext context) {
    final mobile = Breakpoints.isMobile(MediaQuery.sizeOf(context).width);
    return Container(
      padding: EdgeInsets.all(mobile ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Text('Company Growth', style: AppText.h2.copyWith(fontSize: 16)),
            _SegmentedToggle(
              selected: _period,
              onChanged: (p) => setState(() {
                _period = p;
                _points = _repository.growth(p);
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: mobile ? 200 : 260,
          child: FutureBuilder(
            future: _points,
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('Could not load chart', style: AppText.body));
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return _Chart(points: snap.data!);
            },
          ),
        ),
      ]),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    final axis = AppText.caption.copyWith(fontSize: 10, color: AppColors.gray400);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1000,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 200,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray200, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 200,
              reservedSize: narrow ? 34 : 40,
              getTitlesWidget: (v, _) => Text(v.toInt() == 1000 ? '1,000' : '${v.toInt()}', style: axis),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (v, _) => narrow && points.length > 8 && v.toInt().isOdd
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${v.toInt() + 1}', style: axis),
                    ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i])],
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary.withValues(alpha: 0.18), AppColors.primary.withValues(alpha: 0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.selected, required this.onChanged});

  final GrowthPeriod selected;
  final ValueChanged<GrowthPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final o in GrowthPeriod.values)
          GestureDetector(
            onTap: () => onChanged(o),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                decoration: BoxDecoration(
                  color: o == selected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_label(o),
                    style: AppText.bodySmall
                        .copyWith(fontSize: 13, color: o == selected ? AppColors.gray800 : AppColors.gray500)),
              ),
            ),
          ),
      ]),
    );
  }
}

String _label(GrowthPeriod p) => '${p.name[0].toUpperCase()}${p.name.substring(1)}';
