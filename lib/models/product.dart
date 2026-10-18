import 'package:cloud_firestore/cloud_firestore.dart';

const kCategories = [
  'Tops',
  'Bottoms',
  'Outerwear',
  'Dresses',
  'Sleepwear/Loungewear',
  'Activewear',
];

const kSizes = ['XS', 'S', 'M', 'L', 'XL'];

/// Firestore: products/{id}
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.description = '',
    this.sku = '',
    this.stock = 0,
    this.active = true,
    this.rating = 0,
    this.reviews = 0,
    this.sold = 0,
    this.sizes = const ['S', 'M', 'L'],
    this.imageUrl,
    this.imageData,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String description;
  final String sku;
  final int stock;
  final bool active;
  final double rating;
  final int reviews;
  final int sold;
  final List<String> sizes;

  /// Either a web URL or a base64 JPEG (kept small so it fits in Firestore).
  final String? imageUrl;
  final String? imageData;
  final DateTime? createdAt;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
  int get discountPct =>
      hasDiscount ? (((oldPrice! - price) / oldPrice!) * 100).round() : 0;
  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Product(
      id: d.id,
      name: (m['name'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      price: (m['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (m['oldPrice'] as num?)?.toDouble(),
      description: (m['description'] ?? '') as String,
      sku: (m['sku'] ?? '') as String,
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      active: (m['active'] ?? true) as bool,
      rating: (m['rating'] as num?)?.toDouble() ?? 0,
      reviews: (m['reviews'] as num?)?.toInt() ?? 0,
      sold: (m['sold'] as num?)?.toInt() ?? 0,
      sizes: List<String>.from(m['sizes'] ?? const ['S', 'M', 'L']),
      imageUrl: m['imageUrl'] as String?,
      imageData: m['imageData'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'price': price,
        'oldPrice': oldPrice,
        'description': description,
        'sku': sku,
        'stock': stock,
        'active': active,
        'rating': rating,
        'reviews': reviews,
        'sold': sold,
        'sizes': sizes,
        'imageUrl': imageUrl,
        'imageData': imageData,
      };
}
