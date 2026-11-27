import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_layout.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key, required this.client});
  final SupabaseClient client;

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false, obscure = true, saved = false;
  String? error;

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || saved || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (widget.client.auth.currentUser == null) {
        throw const AuthException('Recovery session missing');
      }
      await widget.client.auth.updateUser(
        UserAttributes(password: password.text),
      );
      if (!mounted) return;
      password.clear();
      confirmation.clear();
      setState(() => saved = true);
    } on AuthException catch (e) {
      if (mounted) {
        setState(
          () => error = switch (e.code) {
            'weak_password' => 'Kata sandi belum memenuhi aturan keamanan server. Gunakan kata sandi yang lebih kuat.',
            'same_password' =>
              'Gunakan kata sandi yang berbeda dari sebelumnya.',
            _ => 'Kata sandi belum dapat diperbarui. Periksa koneksi; jika tautan kedaluwarsa, keluar dan minta tautan baru.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              error = 'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> leave() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Belum dapat keluar. Periksa koneksi lalu coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: AuthLayout(
      title: saved ? 'Kata sandi diperbarui' : 'Buat kata sandi baru',
      description: saved
          ? 'Kata sandi berhasil disimpan. Gunakan kata sandi baru saat masuk kembali.'
          : 'Tautan terverifikasi. Masukkan kata sandi baru untuk akun Anda.',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!saved) ...[
              TextFormField(
                key: const ValueKey('recovery-password'),
                controller: password,
                enabled: !busy,
                obscureText: obscure,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Kata sandi baru',
                  helperText: 'Gunakan minimal 8 karakter.',
                  helperMaxLines: 3,
                  suffixIcon: IconButton(
                    tooltip: obscure
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: busy
                        ? null
                        : () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 8
                    ? 'Gunakan minimal 8 karakter'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('recovery-confirmation'),
                controller: confirmation,
                enabled: !busy,
                obscureText: obscure,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => save(),
                decoration: const InputDecoration(
                  labelText: 'Ulangi kata sandi baru',
                ),
                validator: (value) =>
                    value == null || value.isEmpty || value != password.text
                    ? 'Kedua kata sandi harus sama'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            if (error != null) ...[
              AuthFeedback(message: error!, isError: true),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: busy
                  ? null
                  : saved
                  ? leave
                  : save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: busy
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(saved ? 'Masuk kembali' : 'Simpan kata sandi'),
            ),
            if (!saved) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy ? null : leave,
                child: const Text('Batalkan dan keluar'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
