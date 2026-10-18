import 'package:flutter/material.dart';

import '../../services/store_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/tt_app_bar.dart';

/// Store-wide settings. Anything toggled here (like Vacation Mode) is read
/// live by the shopper app's checkout flow via settings/store.
class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  @override
  void initState() {
    super.initState();
    StoreService.ensureDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TtAppBar(title: 'Store Settings'),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: StoreService.watch(),
        builder: (context, snap) {
          final data = snap.data ?? {};
          final vacation = (data['vacationMode'] ?? false) as bool;
          final autoReply = (data['autoReply'] ?? true) as bool;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: MaxWidth(
              maxWidth: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: vacation
                          ? AppColors.warning.withValues(alpha: .12)
                          : AppColors.success.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(vacation ? Icons.bedtime_outlined : Icons.check_circle_outline,
                            color: vacation ? AppColors.warning : AppColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            vacation
                                ? 'Store Visibility: On Break — shoppers cannot check out'
                                : 'Store Visibility: Live — accepting orders',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SettingsGroup(title: 'Store Management', children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.beach_access_outlined,
                          color: AppColors.primary),
                      title: const Text('Vacation Mode'),
                      subtitle:
                          const Text('Temporarily pause incoming orders'),
                      value: vacation,
                      onChanged: (v) => StoreService.update({'vacationMode': v}),
                    ),
                    SwitchListTile(
                      secondary:
                          const Icon(Icons.forum_outlined, color: AppColors.primary),
                      title: const Text('Auto-reply to customer messages'),
                      subtitle: const Text('Instant greeting & fulfillment timeline'),
                      value: autoReply,
                      onChanged: (v) => StoreService.update({'autoReply': v}),
                    ),
                  ]),
                  const SizedBox(height: 22),
                  SettingsGroup(title: 'Checkout Rules', children: [
                    SettingsTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Free shipping threshold',
                      subtitle: '₱${(data['freeShippingThreshold'] ?? 2000)}',
                      onTap: () => _editNumber(
                          context, 'freeShippingThreshold', 'Free shipping threshold (₱)'),
                    ),
                    SettingsTile(
                      icon: Icons.payments_outlined,
                      title: 'Standard shipping fee',
                      subtitle: '₱${(data['standardShipping'] ?? 50)}',
                      onTap: () => _editNumber(
                          context, 'standardShipping', 'Standard shipping fee (₱)'),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editNumber(BuildContext context, String field, String label) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    final n = num.tryParse(value ?? '');
    if (n != null) await StoreService.update({field: n});
  }
}
