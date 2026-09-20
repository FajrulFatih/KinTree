import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/error_message.dart';
import '../../providers/supabase_providers.dart';
import '../widgets/async_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      showAppSnack('Berhasil masuk');
    } catch (e) {
      showAppSnack(friendlyError(e), success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.account_tree_rounded,
                          color: AppColors.page, size: 38),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('KinTree',
                      textAlign: TextAlign.center,
                      style: AppTheme.serif(size: 38, weight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Silsilah keluarga, tetap hidup.',
                      textAlign: TextAlign.center,
                      style: AppTheme.sans(
                          size: 15, color: AppColors.inkSoft)),
                  const SizedBox(height: 36),
                  _Label('Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'budi@keluarga.id'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Email tidak valid'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _Label('Kata Sandi'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.inkFaint,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  AsyncButton(onPressed: _login, label: 'Masuk'),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text.rich(TextSpan(
                        text: 'Belum punya akun? ',
                        style: AppTheme.sans(
                            size: 14, color: AppColors.inkSoft),
                        children: [
                          TextSpan(
                            text: 'Daftar',
                            style: AppTheme.sans(
                                size: 14,
                                weight: FontWeight.w600,
                                color: AppColors.brand),
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Label kecil di atas field (gaya v2).
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTheme.sans(
            size: 13, weight: FontWeight.w600, color: AppColors.inkSoft));
  }
}
