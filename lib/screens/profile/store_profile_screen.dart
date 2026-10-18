import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_orders_provider.dart';
import '../../providers/admin_products_provider.dart';
import '../../providers/admin_session_provider.dart';
import '../../services/admin_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/tt_app_bar.dart';
import '../../widgets/tt_button.dart';

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AdminSessionProvider>();
    final products = context.watch<AdminProductsProvider>();
    final orders = context.watch<AdminOrdersProvider>();

    return Scaffold(
      appBar: const TtAppBar(title: 'Store Profile', subtitle: 'MERCHANT'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MaxWidth(
          maxWidth: 720,
          child: Column(
            children: [
              SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('T', style: AppTheme.serif(size: 24, color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.displayName, style: AppTheme.serif(size: 18)),
                          Text(s.email, style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SoftCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _stat('Live SKUs', '${products.activeCount}'),
                    ),
                    Expanded(
                      child: _stat('All-time Sales', peso(orders.grossSalesAllTime, decimals: false)),
                    ),
                    Expanded(
                      child: _stat('Orders', '${orders.orders.length}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              TtButton(
                label: 'Log Out',
                icon: Icons.logout,
                style: TtButtonStyle.danger,
                onPressed: () => AdminAuthService.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
        ],
      );
}
