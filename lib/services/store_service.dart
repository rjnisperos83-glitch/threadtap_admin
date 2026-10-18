import 'package:cloud_firestore/cloud_firestore.dart';

/// settings/store - read by both apps. Vacation mode blocks new checkouts
/// in the shopper app instantly.
class StoreService {
  StoreService._();

  static final _doc = FirebaseFirestore.instance.collection('settings').doc('store');

  static Stream<Map<String, dynamic>> watch() =>
      _doc.snapshots().map((s) => s.data() ?? {});

  static Future<void> update(Map<String, dynamic> data) =>
      _doc.set(data, SetOptions(merge: true));

  static Future<void> ensureDefaults() async {
    final s = await _doc.get();
    if (!s.exists) {
      await _doc.set({
        'storeName': 'ThreadTap Official Store',
        'vacationMode': false,
        'autoReply': true,
        'freeShippingThreshold': 2000,
        'standardShipping': 50,
      });
    }
  }
}
