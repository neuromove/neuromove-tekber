import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/models.dart';
import '../../shared/services/assessment_engine.dart';
import '../../shared/state/app_state.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final schedule = state.schedule;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Checklist 7 Hari'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Katalog 12 aktivitas',
            onPressed: () => _showCatalog(context),
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
        children: [
          _ProgressHeader(schedule: schedule),
          const SizedBox(height: 14),
          for (var day = 0; day < 7; day++) ...[
            _DayChecklist(
              day: _days[day],
              activities: schedule.activitiesForDay(day),
              onChanged: (id) =>
                  ref.read(appStateProvider.notifier).toggleExercise(id),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              AppStrings.disclaimer,
              style: TextStyle(fontSize: 12, color: AppColors.inkBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showCatalog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text(
              'Katalog 12 Aktivitas',
              style: TextStyle(
                fontSize: 22,
                color: AppColors.dark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (final activity in activityCatalog)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.primary,
                ),
                title: Text(activity.title),
                subtitle: Text(
                  'Aman: ${activity.safeDuration} • Awas: ${activity.alertDuration}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.schedule});
  final WeeklySchedule schedule;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                schedule.zone.label,
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColors.dark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${(schedule.progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: schedule.progress),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              semanticsLabel: 'Progres aktivitas mingguan',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${schedule.completedCount} dari ${schedule.activities.length} aktivitas selesai',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(schedule.reason, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

class _DayChecklist extends StatelessWidget {
  const _DayChecklist({
    required this.day,
    required this.activities,
    required this.onChanged,
  });

  final String day;
  final List<ExerciseActivity> activities;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFD7DCF5)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.dark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text('Tidak ada latihan. Ikuti arahan tenaga kesehatan.'),
          )
        else
          for (final activity in activities)
            CheckboxListTile(
              value: activity.completed,
              onChanged: (_) => onChanged(activity.id),
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: AppColors.primary,
              title: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${activity.duration} • ${activity.reason}',
                style: const TextStyle(fontSize: 11),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
      ],
    ),
  );
}
