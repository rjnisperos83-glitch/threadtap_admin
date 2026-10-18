import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../services/admin_order_service.dart';

class AdminOrdersProvider extends ChangeNotifier {
  AdminOrdersProvider() {
    _sub = AdminOrderService.watchAll().listen((list) {
      orders = list;
      loading = false;
      notifyListeners();
    }, onError: (Object e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  StreamSubscription? _sub;
  List<AppOrder> orders = [];
  bool loading = true;
  String? error;

  List<AppOrder> byStatus(String status) =>
      orders.where((o) => o.status == status).toList();

  int get toPackCount => byStatus(OrderStatus.toPack).length;
  int get toHandoverCount => byStatus(OrderStatus.toHandover).length;
  int get shippedCount => byStatus(OrderStatus.shipped).length;

  double get grossSalesToday {
    final now = DateTime.now();
    return orders
        .where((o) =>
            o.status != OrderStatus.cancelled &&
            o.createdAt != null &&
            o.createdAt!.year == now.year &&
            o.createdAt!.month == now.month &&
            o.createdAt!.day == now.day)
        .fold(0.0, (s, o) => s + o.total);
  }

  double get grossSalesAllTime => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (s, o) => s + o.total);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
