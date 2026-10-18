import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_orders_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/admin_nav.dart';
import '../../utils/responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../orders/admin_orders_screen.dart';
import '../products/admin_products_screen.dart';
import '../profile/store_profile_screen.dart';
import '../store/store_settings_screen.dart';

/// Dashboard | Products | Orders | Store | Profile
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const _pages = <Widget>[
    DashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    StoreSettingsScreen(),
    StoreProfileScreen(),
  ];
  static const _labels = ['Dashboard', 'Products', 'Orders', 'Store', 'Profile'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.receipt_long_outlined,
    Icons.storefront_outlined,
    Icons.person_outline,
  ];
  static const _selectedIcons = [
    Icons.dashboard,
    Icons.inventory_2,
    Icons.receipt_long,
    Icons.storefront,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    adminTab.value = 0;
  }

  Widget _icon(int i, bool selected, int pendingOrders) {
    final icon = Icon(selected ? _selectedIcons[i] : _icons[i]);
    if (i == 2 && pendingOrders > 0) {
      return Badge(
          backgroundColor: AppColors.orchid, label: Text('$pendingOrders'), child: icon);
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final pending = context
        .select<AdminOrdersProvider, int>((o) => o.toPackCount + o.toHandoverCount);

    return ValueListenableBuilder<int>(
      valueListenable: adminTab,
      builder: (context, index, _) {
        final body = IndexedStack(index: index, children: _pages);
        return LayoutBuilder(builder: (context, box) {
          if (box.maxWidth >= Responsive.navRailMin) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: (i) => adminTab.value = i,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.white,
                    indicatorColor: AppColors.tint,
                    selectedIconTheme: const IconThemeData(color: AppColors.primary),
                    selectedLabelTextStyle: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                    destinations: [
                      for (var i = 0; i < _labels.length; i++)
                        NavigationRailDestination(
                          icon: _icon(i, false, pending),
                          selectedIcon: _icon(i, true, pending),
                          label: Text(_labels[i]),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            );
          }
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => adminTab.value = i,
              destinations: [
                for (var i = 0; i < _labels.length; i++)
                  NavigationDestination(
                    icon: _icon(i, false, pending),
                    selectedIcon: _icon(i, true, pending),
                    label: _labels[i],
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}
