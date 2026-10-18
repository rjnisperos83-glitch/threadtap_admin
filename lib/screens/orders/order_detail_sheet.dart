import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/admin_order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tt_button.dart';

class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({super.key, required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      minChildSize: .5,
      maxChildSize: .95,
      builder: (context, scroll) => MaxWidth(
        maxWidth: 640,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration:
                    BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Order #${order.orderNo}', style: AppTheme.serif(size: 22))),
                StatusChip(OrderStatus.adminLabel(order.status),
                    color: OrderStatus.color(order.status), filled: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateTimeLabel(order.createdAt), style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            const Text('Customer', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(order.customerEmail, style: const TextStyle(color: AppColors.muted)),
                  Text(order.phone, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Text(order.address, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SoftCard(
              child: Column(
                children: [
                  for (final i in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('Size ${i.size} × ${i.qty}',
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Text(peso(i.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  const Divider(height: 22),
                  _row('Subtotal', peso(order.subtotal)),
                  _row('Shipping', order.shipping == 0 ? 'FREE' : peso(order.shipping)),
                  _row('Total', peso(order.total), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Payment', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                StatusChip(order.paymentLabel, color: AppColors.orchid),
              ],
            ),
            const SizedBox(height: 8),
            if (order.paymentStatus == 'unpaid')
              TtButton(
                label: 'Mark as Paid',
                style: TtButtonStyle.tonal,
                icon: Icons.check_circle_outline,
                onPressed: () => AdminOrderService.markPaid(order.id),
              )
            else
              StatusChip(
                  order.paymentStatus == 'paid' ? 'Paid' : 'Pay on delivery',
                  color: AppColors.success),
            const SizedBox(height: 22),
            if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
              const Text('Update Status', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in OrderStatus.flow)
                    ChoiceChip(
                      label: Text(OrderStatus.adminLabel(s)),
                      selected: order.status == s,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                          color: order.status == s ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700),
                      onSelected: (_) => AdminOrderService.setStatus(order.id, s),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TtButton(
                label: 'Cancel Order & Restock',
                style: TtButtonStyle.outlined,
                onPressed: () => AdminOrderService.cancel(order),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) {
    final s = TextStyle(
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        color: bold ? AppColors.primary : AppColors.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l, style: s), Text(v, style: s)],
      ),
    );
  }
}
