import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/tt_app_bar.dart';
import '../../widgets/tt_button.dart';
import '../../widgets/tt_text_field.dart';

/// Add / Edit product. Saving here writes straight to Firestore, so the
/// ThreadTap shopper app (which listens to the same collection) updates
/// immediately - no manual sync step.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _sku = TextEditingController(text: widget.existing?.sku ?? '');
  late final _price = TextEditingController(
      text: widget.existing == null ? '' : widget.existing!.price.toStringAsFixed(0));
  late final _oldPrice = TextEditingController(
      text: widget.existing?.oldPrice == null
          ? ''
          : widget.existing!.oldPrice!.toStringAsFixed(0));
  late final _stock =
      TextEditingController(text: widget.existing?.stock.toString() ?? '0');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');

  late String _category = widget.existing?.category ?? kCategories.first;
  late Set<String> _sizes = {...(widget.existing?.sizes ?? const ['S', 'M', 'L'])};
  late bool _active = widget.existing?.active ?? true;
  String? _imageData; // base64, new pick
  String? _existingImageData;
  bool _saving = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _existingImageData = widget.existing?.imageData;
  }

  @override
  void dispose() {
    for (final c in [_name, _sku, _price, _oldPrice, _stock, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 900, imageQuality: 78);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 700 * 1024) {
      if (mounted) {
        showMessage(context, 'Please choose a smaller image (under ~700 KB).');
      }
      return;
    }
    setState(() {
      _imageData = base64Encode(bytes);
      _existingImageData = null;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_sizes.isEmpty) {
      showMessage(context, 'Select at least one size.');
      return;
    }
    setState(() => _saving = true);

    final price = double.tryParse(_price.text.trim()) ?? 0;
    final oldPrice = double.tryParse(_oldPrice.text.trim());
    final stock = int.tryParse(_stock.text.trim()) ?? 0;

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'category': _category,
      'price': price,
      'oldPrice': (oldPrice != null && oldPrice > price) ? oldPrice : null,
      'sku': _sku.text.trim(),
      'stock': stock,
      'active': _active,
      'sizes': _sizes.toList(),
      'description': _description.text.trim(),
      if (_imageData != null) 'imageData': _imageData,
    };

    try {
      if (isEditing) {
        await ProductService.update(widget.existing!.id, data);
      } else {
        await ProductService.add(Product(
          id: '',
          name: data['name'],
          category: data['category'],
          price: price,
          oldPrice: data['oldPrice'],
          sku: data['sku'],
          stock: stock,
          active: _active,
          sizes: _sizes.toList(),
          description: data['description'],
          imageData: _imageData,
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this product?'),
        content: const Text('This cannot be undone. It will disappear from the shopper app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) {
      await ProductService.delete(widget.existing!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TtAppBar(
        title: isEditing ? 'Edit Product' : 'Add New Product',
        actions: [
          if (isEditing)
            TtIconAction(icon: Icons.delete_outline, onTap: _delete, tooltip: 'Delete'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: MaxWidth(
            maxWidth: 720,
            child: TtButton(
              label: isEditing ? 'Save Changes' : 'Publish Product',
              icon: Icons.cloud_upload_outlined,
              loading: _saving,
              onPressed: _save,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MaxWidth(
          maxWidth: 720,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 160,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imageData != null
                          ? Image.memory(base64Decode(_imageData!), fit: BoxFit.cover)
                          : (_existingImageData != null
                              ? Image.memory(base64Decode(_existingImageData!),
                                  fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined,
                                        color: AppColors.orchid, size: 30),
                                    SizedBox(height: 8),
                                    Text('Add photo',
                                        style: TextStyle(color: AppColors.muted)),
                                  ],
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                TtTextField(
                  label: 'Product name',
                  controller: _name,
                  prefixIcon: Icons.checkroom_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TtTextField(
                        label: 'SKU (optional)',
                        controller: _sku,
                        prefixIcon: Icons.qr_code_2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: [
                          for (final c in kCategories)
                            DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _category = v ?? _category),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TtTextField(
                        label: 'Price (₱)',
                        controller: _price,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sell_outlined,
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          return (n == null || n <= 0) ? 'Enter a valid price' : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TtTextField(
                        label: 'Compare-at price (optional)',
                        controller: _oldPrice,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.local_offer_outlined,
                      ),
                    ),
                  ],
                ),
                TtTextField(
                  label: 'Stock quantity',
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.inventory_outlined,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n < 0) ? 'Enter a valid quantity' : null;
                  },
                ),
                const SizedBox(height: 6),
                const Text('Available sizes', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in kSizes)
                      FilterChip(
                        label: Text(s),
                        selected: _sizes.contains(s),
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: _sizes.contains(s) ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w700),
                        onSelected: (v) => setState(
                            () => v ? _sizes.add(s) : _sizes.remove(s)),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                TtTextField(
                  label: 'Description',
                  controller: _description,
                  maxLines: 4,
                  prefixIcon: Icons.notes,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Published (visible to shoppers)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Turn off to keep this as a draft'),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
