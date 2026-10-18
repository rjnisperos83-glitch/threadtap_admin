import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_products_provider.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tt_app_bar.dart';
import '../../widgets/tt_button.dart';
import 'product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _tab = 'All';
  String _query = '';

  static const _tabs = ['All', 'Active', 'Low Stock', 'Draft / Inactive'];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProductsProvider>();
    final items = p.filtered(_query, _tab);

    return Scaffold(
      appBar: TtAppBar(title: 'Products', subtitle: '${p.products.length} SKUs'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add New Product'),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
      ),
      body: LayoutBuilder(builder: (context, box) {
        final pad = Responsive.hPad(box.maxWidth);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search by SKU, title or category...',
                  prefixIcon: Icon(Icons.search, color: AppColors.orchid),
                ),
              ),
            ),
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _tabs[i];
                  final on = t == _tab;
                  final count = switch (t) {
                    'Active' => p.activeCount,
                    'Low Stock' => p.lowStockCount,
                    'Draft / Inactive' => p.draftCount,
                    _ => p.products.length,
                  };
                  return ChoiceChip(
                    label: Text('$t ($count)'),
                    selected: on,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                        color: on ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w700),
                    onSelected: (_) => setState(() => _tab = t),
                  );
                },
              ),
            ),
            Expanded(
              child: p.loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products found',
                          message: 'Try a different filter or add your first product.')
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(pad, 4, pad, 96),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ProductRow(product: items[i]),
                        ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductFormScreen(existing: product))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64, height: 78, child: ProductImage(product: product, radius: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${product.sku.isEmpty ? product.id.substring(0, 6) : product.sku}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.serif(size: 16)),
                Text(product.category,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(peso(product.price),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    if (!product.active)
                      const StatusChip('Draft', color: AppColors.muted)
                    else if (!product.inStock)
                      const StatusChip('Out of stock', color: AppColors.danger)
                    else if (product.lowStock)
                      StatusChip('${product.stock} units left', color: AppColors.warning)
                    else
                      StatusChip('In stock (${product.stock})', color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: product.active,
                onChanged: (v) => ProductService.setActive(product.id, v),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StockBtn(
                      icon: Icons.remove,
                      onTap: product.stock > 0
                          ? () => ProductService.adjustStock(product.id, -1)
                          : null),
                  SizedBox(
                      width: 26,
                      child: Text('${product.stock}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800))),
                  _StockBtn(
                      icon: Icons.add,
                      onTap: () => ProductService.adjustStock(product.id, 1)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockBtn extends StatelessWidget {
  const _StockBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 15, color: onTap == null ? AppColors.lilac : AppColors.primary),
        ),
      );
}
