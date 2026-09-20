import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_message.dart';
import '../../providers/supabase_providers.dart';
import '../widgets/async_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Pendaftaran berhasil. Cek email untuk verifikasi bila diminta.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final passOk = _password.text.length >= 6;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.heritage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_add_rounded,
                          color: AppColors.page, size: 34),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Buat akun baru',
                      textAlign: TextAlign.center,
                      style: AppTheme.serif(size: 24, weight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Setelah daftar, kamu bisa membuat grup keluarga atau bergabung lewat kode undangan.',
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(
                        size: 14, color: AppColors.inkSoft, height: 1.45),
                  ),
                  const SizedBox(height: 28),
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
                      hintText: 'rahasia123',
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        passOk
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: passOk ? AppColors.brand : AppColors.inkFaint,
                      ),
                      const SizedBox(width: 6),
                      Text('Minimal 6 karakter',
                          style: AppTheme.sans(
                              size: 12,
                              color: passOk
                                  ? AppColors.brand
                                  : AppColors.inkFaint)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AsyncButton(onPressed: _register, label: 'Daftar'),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text.rich(TextSpan(
                        text: 'Sudah punya akun? ',
                        style:
                            AppTheme.sans(size: 14, color: AppColors.inkSoft),
                        children: [
                          TextSpan(
                            text: 'Masuk',
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
