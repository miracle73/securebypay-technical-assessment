import 'package:flutter/material.dart';

import '../../core/auth_scope.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Inline on desktop, inside a Drawer below it. Only Dashboard is routed for now.
class SideNav extends StatelessWidget {
  const SideNav({super.key, this.inDrawer = false});

  final bool inDrawer;

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
            padding: EdgeInsets.fromLTRB(inDrawer ? 16 : 30, inDrawer ? 32 : 133, inDrawer ? 16 : 30, 0),
            sliver: SliverList.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NavItem(
                icon: _items[i].$1,
                label: _items[i].$2,
                active: i == 0,
                onTap: inDrawer ? () => Navigator.of(context).pop() : null,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(inDrawer ? 32 : 46, 40, 16, inDrawer ? 32 : 56),
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
  const _NavItem({required this.icon, required this.label, required this.active, this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.gray800;
    return Material(
      color: active ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Icon(icon, size: 22, color: fg),
            const SizedBox(width: 10),
            Text(label,
                style:
                    AppText.bodySmall.copyWith(fontSize: 15, color: fg, fontWeight: active ? FontWeight.w600 : null)),
          ]),
        ),
      ),
    );
  }
}
