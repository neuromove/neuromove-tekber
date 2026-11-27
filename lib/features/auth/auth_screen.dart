import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import 'auth_layout.dart';

enum _AuthMode { login, register, recovery }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.client});
  final SupabaseClient client;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  _AuthMode mode = _AuthMode.login;
  bool busy = false, obscure = true, requestSent = false;
  bool get register => mode == _AuthMode.register;
  bool get recovery => mode == _AuthMode.recovery;
  String? error, notice;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || requestSent || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
      notice = null;
    });
    try {
      if (recovery) {
        await widget.client.auth.resetPasswordForEmail(
          email.text.trim(),
          redirectTo: SupabaseConfig.authRedirectUrl,
        );
        if (!mounted) return;
        setState(() {
          requestSent = true;
          notice = 'Jika email ini terdaftar, tautan pemulihan akan dikirim. Periksa kotak masuk dan spam. Buka tautan di perangkat yang sama dengan aplikasi ini.';
        });
      } else if (register) {
        final result = await widget.client.auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {'display_name': name.text.trim()},
          emailRedirectTo: SupabaseConfig.authRedirectUrl,
        );
        if (!mounted) return;
        if (result.session == null) {
          setState(() {
            notice = 'Periksa email untuk konfirmasi akun. Buka tautan pada perangkat yang sama agar kembali ke NeuroMove. Jika belum masuk otomatis, masuk dengan email dan kata sandi.';
            mode = _AuthMode.login;
          });
          password.clear();
        }
      } else {
        await widget.client.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(
        () => error = switch (e.code) {
          'email_not_confirmed' =>
            'Email belum dikonfirmasi. Periksa kotak masuk dan folder spam.',
          'over_email_send_rate_limit' || 'over_request_rate_limit' =>
            'Terlalu banyak percobaan. Tunggu sebelum mencoba kembali.',
          'user_already_exists' => 'Pendaftaran belum dapat diproses. Coba masuk atau periksa email konfirmasi.',
          'email_address_not_authorized' => 'Email belum dapat dikirim dengan konfigurasi aplikasi saat ini. Hubungi pengelola aplikasi.',
          _ =>
            recovery
                ? 'Permintaan pemulihan belum berhasil. Periksa email dan koneksi, lalu coba lagi.'
                : 'Permintaan akun gagal. Periksa email, kata sandi, dan koneksi, lalu coba lagi.',
        },
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Tidak dapat terhubung. Periksa koneksi dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    title: recovery
        ? 'Pulihkan akun'
        : register
        ? 'Buat akun Anda'
        : 'Selamat datang',
    description: recovery
        ? 'Masukkan email akun untuk menerima tautan pemulihan.'
        : register
        ? 'Mulai atur aktivitas harian Anda bersama NeuroMove.'
        : 'Lanjutkan aktivitas dan pantau progres Anda.',
    illustrated: mode == _AuthMode.login,
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (register) ...[
            TextFormField(
              key: const ValueKey('auth-name'),
              controller: name,
              enabled: !busy,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama akun',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Isi nama akun'
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: const ValueKey('auth-email'),
            controller: email,
            enabled: !busy && !requestSent,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            textInputAction: recovery
                ? TextInputAction.done
                : TextInputAction.next,
            onFieldSubmitted: recovery ? (_) => submit() : null,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (value) =>
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch(value?.trim() ?? '')
                ? 'Masukkan email yang valid'
                : null,
          ),
          if (!recovery) ...[
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('auth-password'),
              controller: password,
              enabled: !busy,
              obscureText: obscure,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: [
                register ? AutofillHints.newPassword : AutofillHints.password,
              ],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Kata sandi',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: register ? 'Gunakan minimal 8 karakter.' : null,
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
              validator: (value) => value == null || value.isEmpty
                  ? 'Isi kata sandi'
                  : register && value.length < 8
                  ? 'Gunakan minimal 8 karakter'
                  : null,
            ),
          ],
          if (mode == _AuthMode.login && SupabaseConfig.authRedirectUrl != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : () => changeMode(_AuthMode.recovery),
                child: const Text('Lupa kata sandi?'),
              ),
            ),
          const SizedBox(height: 8),
          if (error != null) AuthFeedback(message: error!, isError: true),
          if (notice != null) AuthFeedback(message: notice!),
          SizedBox(height: error != null || notice != null ? 16 : 8),
          FilledButton(
            onPressed: busy || requestSent ? null : submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    recovery
                        ? requestSent
                              ? 'Permintaan terkirim'
                              : 'Kirim tautan pemulihan'
                        : register
                        ? 'Daftar'
                        : 'Masuk',
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: busy
                ? null
                : () => changeMode(
                    mode == _AuthMode.login
                        ? _AuthMode.register
                        : _AuthMode.login,
                  ),
            child: Text(
              recovery
                  ? 'Kembali ke masuk'
                  : register
                  ? 'Sudah punya akun? Masuk'
                  : 'Belum punya akun? Daftar',
            ),
          ),
        ],
      ),
    ),
  );

  void changeMode(_AuthMode next) {
    FocusScope.of(context).unfocus();
    final savedEmail = email.text;
    form.currentState?.reset();
    email.text = savedEmail;
    setState(() {
      mode = next;
      requestSent = false;
      error = null;
      notice = null;
      password.clear();
      obscure = true;
    });
  }
}
