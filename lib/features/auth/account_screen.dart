import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/state/cloud_account.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) {
    final client = ref.watch(supabaseClientProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Akun NeuroMove')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              ref.watch(accountNameProvider) ?? 'Mode lokal',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectableText(
              client?.auth.currentUser?.email ?? 'Belum menggunakan Supabase',
            ),
            const SizedBox(height: 24),
            Text(
              client == null
                  ? 'Mode lokal tanpa autentikasi Supabase. Data kesehatan, jadwal, dan progres tersimpan pada perangkat ini.'
                  : 'Autentikasi menggunakan Supabase. Data kesehatan, jadwal, dan progres masih lokal per akun pada perangkat ini. Tidak ada pengiriman ke caregiver lain atau sinkronisasi otomatis.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Insight ML bersifat opsional. Sebagian data kesehatan dikirim ke neuromove-api.onrender.com hanya setelah persetujuan terpisah. Ini bukan sinkronisasi cloud; gunakan data uji karena kebijakan retensi layanan belum diverifikasi.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Data mode lokal sebelumnya tetap tersimpan terpisah dan tidak diunggah ke akun secara otomatis.',
            ),
            const SizedBox(height: 24),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (client != null)
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () async {
                        setState(() {
                          busy = true;
                          error = null;
                        });
                        try {
                          await client.auth.signOut(scope: SignOutScope.local);
                        } catch (_) {
                          if (mounted) {
                            setState(
                              () => error = 'Belum dapat keluar. Periksa koneksi dan coba lagi.',
                            );
                          }
                        } finally {
                          if (mounted) setState(() => busy = false);
                        }
                      },
                child: Text(busy ? 'Keluar…' : 'Keluar dari akun'),
              ),
          ],
        ),
      ),
    );
  }
}
