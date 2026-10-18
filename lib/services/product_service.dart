import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

/// Anything written here is picked up instantly by the ThreadTap shopper
/// app, which listens to the same `products` collection.
class ProductService {
  ProductService._();

  static final _col = FirebaseFirestore.instance.collection('products');

  static Stream<List<Product>> watchAll() =>
      _col.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(Product.fromDoc).toList());

  static Future<void> add(Product p) => _col.add({
        ...p.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  static Future<void> delete(String id) => _col.doc(id).delete();

  static Future<void> setActive(String id, bool active) =>
      _col.doc(id).update({'active': active});

  static Future<void> adjustStock(String id, int delta) =>
      _col.doc(id).update({'stock': FieldValue.increment(delta)});
}
