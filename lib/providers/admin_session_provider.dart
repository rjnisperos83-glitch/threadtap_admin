import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminSessionProvider extends ChangeNotifier {
  AdminSessionProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  StreamSubscription? _authSub;
  StreamSubscription? _docSub;
  User? user;
  Map<String, dynamic> profile = {};
  bool authorized = false;

  void _onAuth(User? u) {
    user = u;
    profile = {};
    authorized = false;
    _docSub?.cancel();
    if (u != null) {
      _docSub = FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .snapshots()
          .listen((s) {
        profile = s.data() ?? {};
        authorized = profile['role'] == 'admin';
        notifyListeners();
      });
    }
    notifyListeners();
  }

  String get displayName {
    final f = (profile['firstName'] ?? '') as String;
    final l = (profile['lastName'] ?? '') as String;
    final full = '$f $l'.trim();
    if (full.isNotEmpty) return full;
    return user?.email?.split('@').first ?? 'Seller';
  }

  String get email => user?.email ?? '';

  @override
  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    super.dispose();
  }
}
