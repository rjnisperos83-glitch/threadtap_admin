import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/admin_orders_provider.dart';
import 'providers/admin_products_provider.dart';
import 'providers/admin_session_provider.dart';
import 'screens/auth/seller_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(_SetupError(message: '$e'));
    return;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminSessionProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductsProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
      ],
      child: const ThreadTapAdminApp(),
    ),
  );
}

class ThreadTapAdminApp extends StatelessWidget {
  const ThreadTapAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThreadTap Seller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SellerGate(),
    );
  }
}

class _SetupError extends StatelessWidget {
  const _SetupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Firebase is not set up yet.\n\nRun "flutterfire configure" in the '
              'threadtap_admin folder (same Firebase project as the shopper app), '
              'then restart.\n\n$message',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
