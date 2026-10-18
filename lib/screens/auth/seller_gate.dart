import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_session_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/tt_logo.dart';
import '../shell/admin_shell.dart';
import 'seller_login_screen.dart';

class SellerGate extends StatelessWidget {
  const SellerGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        if (snap.data == null) return const SellerLoginScreen();
        return Consumer<AdminSessionProvider>(
          builder: (context, s, _) {
            if (s.profile.isEmpty) return const _Splash();
            if (!s.authorized) {
              return _NotAuthorized(email: s.email);
            }
            return const AdminShell();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: const Center(child: TtLogo(size: 100, light: true, tagline: 'SELLER PORTAL')),
      ),
    );
  }
}

class _NotAuthorized extends StatelessWidget {
  const _NotAuthorized({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 56, color: AppColors.danger),
              const SizedBox(height: 16),
              Text('$email is not a seller account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                'Ask an existing admin to set your role to "admin" in Firestore, '
                'under users/{your uid}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
