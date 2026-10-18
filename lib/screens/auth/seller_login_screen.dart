import 'package:flutter/material.dart';

import '../../services/admin_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/tt_button.dart';
import '../../widgets/tt_logo.dart';
import '../../widgets/tt_text_field.dart';

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({super.key});

  @override
  State<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<SellerLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await AdminAuthService.signIn(_email.text, _password.text);
    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
      // On success, SellerGate swaps to AdminShell automatically.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: MaxWidth(
              maxWidth: 440,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: .12),
                        blurRadius: 34,
                        offset: const Offset(0, 16)),
                  ],
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: TtLogo(size: 72, tagline: null)),
                      const SizedBox(height: 16),
                      Center(
                          child:
                              Text('Seller Portal', style: AppTheme.serif(size: 24))),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text('Manage your store, inventory, and orders.',
                            style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(height: 26),
                      TtTextField(
                        label: 'Email address',
                        hint: 'seller@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                      ),
                      TtTextField(
                        label: 'Password',
                        controller: _password,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Password is required' : null,
                        onSubmitted: (_) => _submit(),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            onChanged: (v) => setState(() => _remember = v ?? true),
                          ),
                          const Text('Keep me logged in'),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              if (_email.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Enter your email above first')),
                                );
                                return;
                              }
                              await AdminAuthService.sendPasswordReset(_email.text);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reset link sent')),
                                );
                              }
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TtButton(
                        label: 'Login as Seller',
                        icon: Icons.arrow_forward_rounded,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Seller accounts are created by an existing admin.\n'
                          'See the setup guide for how to promote an account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
