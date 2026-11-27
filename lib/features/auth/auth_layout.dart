import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/widgets.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.illustrated = false,
  });
  final String title, description;
  final Widget child;
  final bool illustrated;

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  final scroll = ScrollController(keepScrollOffset: false);

  @override
  void didUpdateWidget(covariant AuthLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && scroll.hasClients) {
      scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.lavender),
    );
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          fillColor: AppColors.surfaceBlue,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: outline,
          disabledBorder: outline,
          focusedBorder: outline.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
          errorMaxLines: 3,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showArt =
                  widget.illustrated &&
                  constraints.maxHeight > 700 &&
                  MediaQuery.viewInsetsOf(context).bottom == 0 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 20;
              return SingleChildScrollView(
                controller: scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AppEntrance(
                      replayKey: widget.title,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _AuthBrand(),
                          SizedBox(height: showArt ? 16 : 32),
                          if (showArt) ...[
                            const _WelcomeArt(),
                            const SizedBox(height: 20),
                          ],
                          Semantics(
                            header: true,
                            liveRegion: true,
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          widget.child,
                          const SizedBox(height: 24),
                          const _LocalDataNote(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'NeuroMove',
    image: true,
    child: ExcludeSemantics(
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/brand/neuromove_mark.svg',
            width: 44,
            height: 44,
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'NeuroMove',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'Langkah kecil,\nlebih aktif.',
          style: TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      const SizedBox(width: 8),
      ExcludeSemantics(
        child: SizedBox(
          width: 112,
          height: 116,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.paleBlue,
              shape: BoxShape.circle,
            ),
            child: const CroppedAssetView(
              AppAssets.loginPeople,
              leftFactor: -.1769,
              topFactor: -.1704,
              widthFactor: 1.4462,
              heightFactor: 1.2111,
            ),
          ),
        ),
      ),
    ],
  );
}

class AuthFeedback extends StatelessWidget {
  const AuthFeedback({super.key, required this.message, this.isError = false});
  final String message;
  final bool isError;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError ? colors.errorContainer : AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 22,
                color: isError ? colors.onErrorContainer : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isError ? colors.onErrorContainer : AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalDataNote extends StatelessWidget {
  const _LocalDataNote();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(color: AppColors.lavender),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(
            Icons.phone_android_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Data kesehatan tersimpan di perangkat ini.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
          IconButton(
            tooltip: 'Informasi penyimpanan data',
            icon: const Icon(Icons.info_outline, size: 22),
            onPressed: () {
              FocusScope.of(context).unfocus();
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                useSafeArea: true,
                isScrollControlled: true,
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.sizeOf(context).height * .9,
                ),
                builder: (context) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tentang penyimpanan data',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Email dan nama akun menggunakan Supabase. Profil kesehatan, asesmen, jadwal, dan progres disimpan lokal per akun; belum disinkronkan ke cloud atau dibagikan kepada caregiver lain.\n\nInsight ML opsional mengirim usia, jenis kelamin, ukuran tubuh, dan data aktivitas/kondisi terpilih ke neuromove-api.onrender.com hanya setelah persetujuan terpisah. Model berbasis data sintetis, bukan penentu dosis latihan.\n\nData kesehatan lokal belum dienkripsi. Keluar dari akun tidak menghapus data lokal. Gunakan data uji, bukan data kesehatan nyata.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Mengerti'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
