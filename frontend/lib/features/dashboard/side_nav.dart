import 'package:flutter/material.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Left navigation. Rendered inline on desktop and inside a Drawer below
/// the desktop breakpoint. Only "Dashboard" is a real route in this build.
class SideNav extends StatelessWidget {
  const SideNav({super.key});

  static const _items = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.local_shipping_outlined, 'Shipments'),
    (Icons.language, 'Our Services'),
    (Icons.notifications_none, 'Notifications'),
    (Icons.credit_card, 'Wallet'),
    (Icons.my_location, 'My Addresses'),
    (Icons.monetization_on_outlined, 'Invite & Earn'),
    (Icons.handshake_outlined, 'Help Center'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(30, 133, 30, 0),
            sliver: SliverList.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NavItem(icon: _items[i].$1, label: _items[i].$2, active: i == 0),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(46, 40, 16, 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(user?.initials ?? '', style: AppText.button.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user == null ? '' : '${user.firstName}\n${user.lastName}',
                        style: AppText.bodySmall.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),
                  InkWell(
                    onTap: auth.logout,
                    child: Row(children: [
                      const Icon(Icons.logout, size: 22, color: AppColors.gray800),
                      const SizedBox(width: 10),
                      Text('Logout', style: AppText.bodySmall.copyWith(fontSize: 15)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.gray800;
    return Material(
      color: active ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Icon(icon, size: 22, color: fg),
            const SizedBox(width: 10),
            Text(label, style: AppText.bodySmall.copyWith(fontSize: 15, color: fg, fontWeight: active ? FontWeight.w600 : null)),
          ]),
        ),
      ),
    );
  }
}
