import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order.dart';

class AdminOrderService {
  AdminOrderService._();

  static final _col = FirebaseFirestore.instance.collection('orders');

  static Stream<List<AppOrder>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(AppOrder.fromDoc).toList());

  /// Moves the order to the next step. The shopper app sees this instantly.
  static Future<void> advance(AppOrder order) async {
    final flow = OrderStatus.flow;
    final i = flow.indexOf(order.status);
    if (i < 0 || i >= flow.length - 1) return;
    await setStatus(order.id, flow[i + 1]);
  }

  static Future<void> setStatus(String id, String status) => _col.doc(id).update({
        'status': status,
        if (status == OrderStatus.delivered) 'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

  static Future<void> markPaid(String id) => _col.doc(id).update({
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Cancels and restocks in one transaction.
  static Future<void> cancel(AppOrder order) async {
    final db = FirebaseFirestore.instance;
    await db.runTransaction((tx) async {
      final ref = db.collection('orders').doc(order.id);
      final snaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final i in order.items) {
        snaps[i.productId] = await tx.get(db.collection('products').doc(i.productId));
      }
      for (final i in order.items) {
        final s = snaps[i.productId]!;
        if (!s.exists) continue;
        final d = s.data()!;
        tx.update(s.reference, {
          'stock': ((d['stock'] as num?)?.toInt() ?? 0) + i.qty,
        });
      }
      tx.update(ref, {
        'status': OrderStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
