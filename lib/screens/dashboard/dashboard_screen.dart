import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_orders_provider.dart';
import '../../providers/admin_products_provider.dart';
import '../../providers/admin_session_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/tt_app_bar.dart';
import '../../widgets/tt_button.dart';
import '../orders/order_detail_sheet.dart';
import '../products/product_form_screen.dart';
import '../../utils/admin_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AdminSessionProvider>();
    final products = context.watch<AdminProductsProvider>();
    final orders = context.watch<AdminOrdersProvider>();

    final pendingPack = orders.byStatus('to_pack');

    return Scaffold(
      appBar: TtAppBar(
        title: 'ThreadTap',
        subtitle: 'MERCHANT',
        actions: [
          TtIconAction(
            icon: Icons.notifications_none_rounded,
            showDot: pendingPack.isNotEmpty,
            onTap: () => DefaultTabController.of(context),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, box) {
        final pad = Responsive.hPad(box.maxWidth);
        final wide = box.maxWidth >= 720;
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 18, pad, 24),
          children: [
            Text('Welcome back, ${session.displayName.split(' ').first}',
                style: AppTheme.serif(size: 22)),
            const SizedBox(height: 4),
            const Text('Here is how your store is doing today.',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                    label: "Today's Sales",
                    value: peso(orders.grossSalesToday, decimals: false),
                    icon: Icons.trending_up,
                    color: AppColors.success),
                _StatCard(
                    label: 'Live Products',
                    value: '${products.activeCount}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary),
                _StatCard(
                    label: 'Pending Orders',
                    value: '${orders.toPackCount + orders.toHandoverCount}',
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.warning),
                _StatCard(
                    label: 'Low / Out of Stock',
                    value: '${products.lowStockCount + products.outOfStockCount}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.danger),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader('Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_box_outlined,
                    label: 'Add Product',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProductFormScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'View Orders',
                    onTap: () => adminTab.value = 2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.storefront_outlined,
                    label: 'Store Settings',
                    onTap: () => adminTab.value = 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader('Orders To Pack',
                action: pendingPack.isEmpty ? null : 'View All',
                onAction: () => adminTab.value = 2),
            const SizedBox(height: 12),
            if (pendingPack.isEmpty)
              const EmptyState(
                  icon: Icons.task_alt, title: 'All caught up', message: 'No orders waiting to be packed.')
            else
              for (final o in pendingPack.take(3)) ...[
                SoftCard(
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    builder: (_) => OrderDetailSheet(order: o),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          backgroundColor: AppColors.tint,
                          child: Icon(Icons.inventory_2_outlined, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#${o.orderNo}  ·  ${o.customerName}',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('${o.itemCount} item(s) · ${peso(o.total)}',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ],
      ),
    );
  }
}
