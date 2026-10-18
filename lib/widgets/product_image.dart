import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';

/// Renders a product photo from base64 (Firestore) or a URL, with a soft
/// placeholder when there is no image.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  final Product product;
  final BoxFit fit;
  final double radius;

  static final Map<String, Uint8List> _cache = {};

  Widget _placeholder() => Container(
        color: AppColors.tint,
        alignment: Alignment.center,
        child: const Icon(Icons.checkroom, size: 40, color: AppColors.lilac),
      );

  Widget _content() {
    final data = product.imageData;
    if (data != null && data.isNotEmpty) {
      final key = '${product.id}:${data.length}';
      final bytes = _cache.putIfAbsent(key, () => base64Decode(data));
      return Image.memory(
        bytes,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final url = product.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: const Color(0xFFF3EFF6),
        child: SizedBox.expand(child: _content()),
      ),
    );
  }
}
