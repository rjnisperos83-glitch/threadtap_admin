import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/admin_orders_provider.dart';
import '../../services/admin_order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tt_app_bar.dart';
import '../../widgets/tt_button.dart';
import 'order_detail_sheet.dart';

/// Live order queue. Any status change here reaches the shopper app
/// instantly through the shared `orders` collection.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _tabs = [
    ('To Pack', OrderStatus.toPack),
    ('To Handover', OrderStatus.toHandover),
    ('Shipped', OrderStatus.shipped),
    ('Delivered', OrderStatus.delivered),
    ('Cancelled', OrderStatus.cancelled),
  ];

  @override
  Widget build(BuildContext context) {
    final o = context.watch<AdminOrdersProvider>();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: TtAppBar(title: 'Orders', subtitle: '${o.orders.length} total'),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                tabs: [
                  for (final t in _tabs)
                    Tab(text: '${t.$1} (${o.byStatus(t.$2).length})'),
                ],
              ),
            ),
            Expanded(
              child: o.loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        for (final t in _tabs) _OrderList(status: t.$2, orders: o.byStatus(t.$2)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.status, required this.orders});

  final String status;
  final List<AppOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(icon: Icons.inbox_outlined, title: 'Nothing here');
    }
    return LayoutBuilder(builder: (context, box) {
      final pad = Responsive.hPad(box.maxWidth);
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final AppOrder order;

  String get _actionLabel {
    switch (order.status) {
      case OrderStatus.toPack:
        return 'Ready Handover';
      case OrderStatus.toHandover:
        return 'Mark Shipped';
      case OrderStatus.shipped:
        return 'Mark Delivered';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = OrderStatus.color(order.status);
    final actionable = OrderStatus.flow.contains(order.status) &&
        order.status != OrderStatus.delivered;

    return SoftCard(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => OrderDetailSheet(order: order),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('#${order.orderNo}',
                    style: AppTheme.serif(size: 16, color: AppColors.primary)),
              ),
              Text(dateTimeLabel(order.createdAt),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(order.address,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(OrderStatus.adminLabel(order.status), color: color, filled: true),
              StatusChip(order.paymentLabel, color: AppColors.orchid),
              if (order.paymentStatus == 'unpaid')
                const StatusChip('Awaiting payment', color: AppColors.warning),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Text('${order.itemCount} item(s)',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const Spacer(),
              Text(peso(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          if (actionable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TtButton(
                    label: _actionLabel,
                    height: 42,
                    onPressed: () => AdminOrderService.advance(order),
                  ),
                ),
                if (order.status == OrderStatus.toPack) ...[
                  const SizedBox(width: 10),
                  TtButton(
                    label: 'Cancel',
                    style: TtButtonStyle.outlined,
                    height: 42,
                    expand: false,
                    onPressed: () => AdminOrderService.cancel(order),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
