import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/models.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'growth_chart.dart';
import 'overview_section.dart';
import 'promo_banner.dart';
import 'shipment_card.dart';
import 'side_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<(Overview, List<Shipment>)> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<(Overview, List<Shipment>)> _load() async {
    final auth = AuthScope.read(context);
    try {
      final results = await Future.wait([
        auth.api.get('/dashboard/overview'),
        auth.api.get('/dashboard/shipments?limit=3'),
      ]);
      return (
        Overview.fromJson(results[0] as Map<String, dynamic>),
        (results[1] as List).map((e) => Shipment.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } on ApiException catch (e) {
      // Expired/invalid token: drop the session; the router sends us to /login.
      if (e.isUnauthorized) await auth.logout();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = Breakpoints.isDesktop(width);
    final pad = Breakpoints.isMobile(width) ? AppSpacing.md : 26.5;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      drawer: desktop ? null : const Drawer(child: SideNav()),
      body: Row(
        children: [
          if (desktop) const SizedBox(width: 240, child: SideNav()),
          Expanded(
            child: Column(
              children: [
                TopBar(showMenu: !desktop),
                Expanded(
                  child: FutureBuilder(
                    future: _data,
                    builder: (context, snap) => ListView(
                      padding: EdgeInsets.fromLTRB(pad, 19, pad, 40),
                      children: [
                        const PromoBanner(),
                        const SizedBox(height: 30),
                        if (snap.hasError)
                          _ErrorState(
                            message: snap.error.toString(),
                            onRetry: () => setState(() => _data = _load()),
                          )
                        else if (!snap.hasData)
                          const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          OverviewSection(overview: snap.data!.$1),
                          const SizedBox(height: 40),
                          _SectionHeader(
                            title: 'Recent shipment',
                            trailing: OutlinedButton(onPressed: () {}, child: const Text('See All')),
                          ),
                          const SizedBox(height: 24),
                          const GrowthChartCard(),
                          const SizedBox(height: 8),
                          for (final s in snap.data!.$2) ...[
                            ShipmentCard(shipment: s),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.showMenu});

  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 26.5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Open menu',
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite & Earn', style: AppText.h2.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Text(
                    'Keep track of your addresses,  location updates. Edit, Delete, Update and see all your saved addresses',
                    style: AppText.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title, style: AppText.h2)),
      if (trailing != null) trailing!,
    ]);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        const Icon(Icons.cloud_off, size: 40, color: AppColors.gray400),
        const SizedBox(height: 12),
        Text(message, style: AppText.body, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ]),
    );
  }
}
