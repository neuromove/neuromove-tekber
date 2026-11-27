import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/models/models.dart';
import '../../shared/state/app_state.dart';
import '../../shared/state/cloud_account.dart';
import '../../shared/widgets/widgets.dart';
import '../profile/activity_insight_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.referenceDate});
  final DateTime? referenceDate;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isUpdatingProgress = false;

  Future<void> _toggleExercise(String id) async {
    if (_isUpdatingProgress) return;
    setState(() => _isUpdatingProgress = true);
    try {
      await ref.read(appStateProvider.notifier).toggleExercise(id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progres latihan belum dapat disimpan.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final profile = state.profile;
    final assessment = state.assessment;
    final schedule = state.schedule;
    final hasAssessment =
        state.hasSavedProfile && (profile.canAssess || profile.hardGate);
    final hasSchedule = schedule.activities.isNotEmpty;
    final factors = {
      for (final factor in assessment.factors) factor.label: factor,
    };
    final hasBloodPressure =
        (int.tryParse(profile.systolic) ?? 0) > 0 &&
        (int.tryParse(profile.diastolic) ?? 0) > 0;
    final now = widget.referenceDate ?? DateTime.now();
    final activities = schedule.activitiesForDay(now.weekday - 1);
    final completed = activities.where((item) => item.completed).length;
    final nextActivity = activities
        .where((item) => !item.completed)
        .firstOrNull;
    final progressMessage = completed == activities.length
        ? 'Target hari ini selesai. Terima kasih sudah konsisten!'
        : '$completed dari ${activities.length} target hari ini selesai';
    final canExercise =
        hasSchedule && state.scheduleApproved && !assessment.requiresReferral;
    final name = state.hasSavedProfile && profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Selamat datang';
    final greeting = switch (now.hour) {
      >= 5 && < 11 => 'SELAMAT PAGI!',
      >= 11 && < 15 => 'SELAMAT SIANG!',
      >= 15 && < 18 => 'SELAMAT SORE!',
      _ => 'SELAMAT MALAM!',
    };

    return Scaffold(
      bottomNavigationBar: const NeuroMoveBottomNavigation(currentIndex: 0),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey('home-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'AtkinsonHyperlegible',
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(now),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (ref.watch(supabaseClientProvider) != null)
                          TextButton.icon(
                            onPressed: () => context.push('/account'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Akun'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(
                            state.hasSavedProfile
                                ? 'Edit profil'
                                : 'Lengkapi profil',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AssetView(AppAssets.doctor, width: 100, height: 150),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!hasAssessment)
              _HomeNotice(
                title: 'Mulai dari profil kesehatan',
                message:
                    'Isi profil dan asesmen untuk melihat zona, jadwal, serta target latihan Anda.',
                action: 'Isi profil kesehatan',
                onPressed: () => context.push('/profile'),
              )
            else ...[
              if (assessment.requiresReferral)
                _HomeNotice(
                  title: 'Latihan ditahan',
                  message: assessment.reason,
                  action: 'Lihat langkah rujukan',
                  onPressed: () => context.push('/referral'),
                )
              else if (!hasSchedule)
                _HomeNotice(
                  title: 'Belum ada jadwal latihan',
                  message:
                      'Buka modul jadwal untuk melihat rencana latihan Anda.',
                  action: 'Buka jadwal',
                  onPressed: () => context.go('/schedule'),
                )
              else if (!state.scheduleApproved)
                _HomeNotice(
                  title: 'Jadwal masih berupa draf',
                  message:
                      'Tinjau aktivitas bersama caregiver sebelum memulai latihan.',
                  action: 'Tinjau draf jadwal',
                  onPressed: () => context.push('/schedule-draft'),
                ),
              if (canExercise) ...[
                _TodayTargetCard(
                  activities: activities,
                  isUpdatingProgress: _isUpdatingProgress,
                  onChanged: _toggleExercise,
                ),
                if (activities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: Text(
                      progressMessage,
                      key: ValueKey(progressMessage),
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Prediksi Kesehatan anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/assessment'),
                    child: const Text('Detail'),
                  ),
                ],
              ),
              _PredictionCard(assessment: assessment),
            ],
            if (state.hasSavedProfile) ...[
              const SizedBox(height: 24),
              const Text(
                'Kondisi anda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _MetricPair(
                first: _HomeMetricCard.fromAssessment(
                  title: 'MMSE',
                  factor: profile.mmse == null ? null : factors['MMSE'],
                ),
                second: _HomeMetricCard.fromAssessment(
                  title: 'GDS',
                  factor: profile.gds == null ? null : factors['GDS-15'],
                ),
              ),
              const SizedBox(height: 12),
              _MetricPair(
                first: _HomeMetricCard.fromAssessment(
                  title: 'TEKANAN DARAH',
                  factor: hasBloodPressure ? factors['Tensi'] : null,
                ),
                second: _HomeMetricCard(
                  title: 'KEPATUHAN',
                  value: hasSchedule
                      ? '${(schedule.progress * 100).round()}%'
                      : null,
                  status: hasSchedule
                      ? '${schedule.completedCount}/${schedule.activities.length} selesai'
                      : 'Belum ada jadwal',
                ),
              ),
            ],
            if (hasAssessment) ...[
              const SizedBox(height: 20),
              _RecommendationCard(
                message: assessment.requiresReferral
                    ? 'Latihan ditahan. Baca alasan rujukan dan diskusikan dengan tenaga kesehatan.'
                    : !hasSchedule
                    ? 'Belum ada jadwal latihan. Tanya tentang rencana latihan Anda.'
                    : !state.scheduleApproved
                    ? 'Jadwal belum disetujui. Tanya tentang aktivitas dan alasan penyusunan draf.'
                    : nextActivity != null
                    ? 'Target berikutnya: ${nextActivity.title}, ${nextActivity.duration}.'
                    : activities.isNotEmpty
                    ? 'Semua target hari ini selesai. Lihat progres Anda bersama caregiver.'
                    : 'Hari ini tidak ada aktivitas terjadwal. Tanya tentang jadwal atau progres minggu ini.',
              ),
              if (state.activityInsight != null &&
                  !assessment.requiresReferral) ...[
                const SizedBox(height: 20),
                ActivityInsightCard(insight: state.activityInsight!),
                TextButton(
                  onPressed: () => context.push('/activity-insight'),
                  child: const Text('Tinjau input ML'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeNotice extends StatelessWidget {
  const _HomeNotice({
    required this.title,
    required this.message,
    required this.action,
    required this.onPressed,
  });
  final String title, message, action;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        FilledButton(onPressed: onPressed, child: Text(action)),
      ],
    ),
  );
}

class _TodayTargetCard extends StatelessWidget {
  const _TodayTargetCard({
    required this.activities,
    required this.isUpdatingProgress,
    required this.onChanged,
  });
  final List<ExerciseActivity> activities;
  final bool isUpdatingProgress;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.primary, width: .7),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Target Hari Ini',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () => context.go('/schedule'),
                child: const Text('Lihat Semua', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
        if (isUpdatingProgress) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: const Text('Memperbarui progres latihan…'),
          ),
          const SizedBox(height: 8),
        ],
        if (activities.isEmpty)
          const Text('Hari tanpa sesi latihan. Lihat jadwal mingguan.')
        else
          for (final activity in activities) ...[
            _TargetRow(
              activity: activity,
              onTap: isUpdatingProgress ? null : () => onChanged(activity.id),
            ),
            if (activity != activities.last) const SizedBox(height: 8),
          ],
      ],
    ),
  );
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({required this.activity, required this.onTap});
  final ExerciseActivity activity;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${activity.title}, ${activity.duration}',
    checked: activity.completed,
    child: Material(
      color: activity.completed ? AppColors.successPale : Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.primary, width: .5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AssetView(activity.imageAsset, width: 36, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      activity.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.tealInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                child: Icon(
                  activity.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  key: ValueKey(activity.completed),
                  color: const Color(0xFF326C33),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.assessment});
  final HealthAssessment assessment;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: switch (assessment.zone) {
        RiskZone.safe => AppColors.successPale,
        RiskZone.alert => const Color(0xFFFFE8C6),
        RiskZone.referral => AppColors.dangerPale,
      },
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AssetView(AppAssets.riskHeart, width: 48, height: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assessment.zone.label,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(switch (assessment.zone) {
                    RiskZone.safe => 'Kondisi dalam rentang aman',
                    RiskZone.alert => 'Perlu latihan lebih ringan',
                    RiskZone.referral => 'Latihan ditahan, perlu rujukan',
                  }, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                children: [
                  Text(
                    '${assessment.score}/30',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text('skor risiko', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.4),
              children: [
                const TextSpan(
                  text: 'AI Insight: ',
                  style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: assessment.reason),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MetricPair extends StatelessWidget {
  const _MetricPair({required this.first, required this.second});
  final Widget first, second;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    ),
  );
}

class _HomeMetricCard extends StatelessWidget {
  const _HomeMetricCard({
    required this.title,
    required this.status,
    this.value,
  });

  factory _HomeMetricCard.fromAssessment({
    required String title,
    required ScoreFactor? factor,
  }) {
    if (factor == null) {
      return _HomeMetricCard(title: title, status: 'Belum diisi');
    }
    return _HomeMetricCard(
      title: title,
      value: factor.value,
      status: factor.points == 0 ? 'baik' : 'pantau',
    );
  }

  final String title, status;
  final String? value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.secondary),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          value ?? '—',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            color: Color(0xFF326C33),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.tealInk),
        ),
      ],
    ),
  );
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.lavender,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push('/ai-chat'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi AI',
                    style: TextStyle(
                      fontSize: 19,
                      color: AppColors.dark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  const Text(
                    'Lihat Rekomendasi',
                    style: TextStyle(
                      color: AppColors.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(width: 72, height: 76, child: RobotAsset()),
          ],
        ),
      ),
    ),
  );
}
