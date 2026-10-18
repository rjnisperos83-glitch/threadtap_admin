import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class AdminProductsProvider extends ChangeNotifier {
  AdminProductsProvider() {
    _sub = ProductService.watchAll().listen((list) {
      products = list;
      loading = false;
      notifyListeners();
    }, onError: (Object e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  StreamSubscription? _sub;
  List<Product> products = [];
  bool loading = true;
  String? error;

  int get activeCount => products.where((p) => p.active).length;
  int get lowStockCount => products.where((p) => p.lowStock).length;
  int get outOfStockCount => products.where((p) => !p.inStock).length;
  int get draftCount => products.where((p) => !p.active).length;

  List<Product> filtered(String query, String tab) {
    var list = products;
    switch (tab) {
      case 'Active':
        list = list.where((p) => p.active && p.inStock).toList();
        break;
      case 'Low Stock':
        list = list.where((p) => p.lowStock).toList();
        break;
      case 'Draft / Inactive':
        list = list.where((p) => !p.active).toList();
        break;
    }
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
