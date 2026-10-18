import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Firestore: orders/{id}
class OrderStatus {
  OrderStatus._();

  static const toPack = 'to_pack';
  static const toHandover = 'to_handover';
  static const shipped = 'shipped';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const flow = [toPack, toHandover, shipped, delivered];

  /// Shopper-facing wording.
  static String customerLabel(String s) {
    switch (s) {
      case toPack:
        return 'Preparing';
      case toHandover:
        return 'Ready for pickup';
      case shipped:
        return 'On the way';
      case delivered:
        return 'Delivered';
      default:
        return 'Cancelled';
    }
  }

  /// Merchant-facing wording.
  static String adminLabel(String s) {
    switch (s) {
      case toPack:
        return 'To Pack';
      case toHandover:
        return 'To Handover';
      case shipped:
        return 'Shipped';
      case delivered:
        return 'Delivered';
      default:
        return 'Cancelled';
    }
  }

  static Color color(String s) {
    switch (s) {
      case toPack:
        return AppColors.warning;
      case toHandover:
        return AppColors.orchid;
      case shipped:
        return AppColors.plum;
      case delivered:
        return AppColors.success;
      default:
        return AppColors.danger;
    }
  }
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.size,
    required this.qty,
    required this.price,
  });

  final String productId;
  final String name;
  final String size;
  final int qty;
  final double price;

  double get total => price * qty;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'size': size,
        'qty': qty,
        'price': price,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: (m['productId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        size: (m['size'] ?? '') as String,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
        price: (m['price'] as num?)?.toDouble() ?? 0,
      );
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String orderNo;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String phone;
  final String address;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double total;

  /// gcash | maya | card | cod
  final String paymentMethod;

  /// unpaid | paid | cod
  final String paymentStatus;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get itemCount => items.fold(0, (s, i) => s + i.qty);

  String get paymentLabel {
    switch (paymentMethod) {
      case 'gcash':
        return 'GCash';
      case 'maya':
        return 'Maya';
      case 'card':
        return 'Card';
      default:
        return 'Cash on Delivery';
    }
  }

  factory AppOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return AppOrder(
      id: d.id,
      orderNo: (m['orderNo'] ?? d.id) as String,
      userId: (m['userId'] ?? '') as String,
      customerName: (m['customerName'] ?? '') as String,
      customerEmail: (m['customerEmail'] ?? '') as String,
      phone: (m['phone'] ?? '') as String,
      address: (m['address'] ?? '') as String,
      items: ((m['items'] ?? const []) as List)
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
      shipping: (m['shipping'] as num?)?.toDouble() ?? 0,
      total: (m['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: (m['paymentMethod'] ?? 'cod') as String,
      paymentStatus: (m['paymentStatus'] ?? 'cod') as String,
      status: (m['status'] ?? OrderStatus.toPack) as String,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
