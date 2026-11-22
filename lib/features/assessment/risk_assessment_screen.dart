import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/models.dart';
import '../../shared/state/app_state.dart';
import '../../shared/widgets/widgets.dart';

class RiskAssessmentScreen extends ConsumerWidget {
  const RiskAssessmentScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final assessment = state.assessment;
    final ready =
        state.hasSavedProfile &&
        (state.profile.canAssess || state.profile.hardGate);
    final color = switch (assessment.zone) {
      RiskZone.safe => AppColors.successPale,
      RiskZone.alert => AppColors.warning,
      RiskZone.referral => AppColors.dangerPale,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asesmen Risiko'),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!ready) ...[
                const Text(
                  'Lengkapi profil dan hasil asesmen terlebih dahulu. Zona risiko belum dapat ditampilkan.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Lengkapi profil'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        assessment.zone.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skor ${assessment.score} dari 30',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Rincian Skor',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.inkBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final factor in assessment.factors)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${factor.label} ${factor.value}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.inkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '+${factor.points}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.inkBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const _CutoffTable(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.dark,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        assessment.requiresReferral
                            ? 'Latihan ditahan. Lanjut ke rujukan.'
                            : '${assessment.eligibleActivityCount} dari 12 aktivitas lolos filter.\n${assessment.zone.shortLabel}: intensitas disesuaikan.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  assessment.reason,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        AppStrings.disclaimer,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                          assessment.requiresReferral
                              ? '/referral'
                              : '/schedule-draft',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const SizedBox.square(
                          dimension: 32,
                          child: RobotAsset(),
                        ),
                        label: Text(
                          assessment.requiresReferral
                              ? 'Lihat langkah rujukan'
                              : 'Lihat jadwal latihan 7 hari',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CutoffTable extends StatelessWidget {
  const _CutoffTable();
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final zone in RiskZone.values)
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  zone.shortLabel.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.dark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${zone.minimum}–${zone.maximum}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.dark),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
