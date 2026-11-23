import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/state/app_state.dart';
import '../../shared/widgets/widgets.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, this.referenceDate});
  final DateTime? referenceDate;
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late int selectedDay;
  @override
  void initState() {
    super.initState();
    selectedDay = (widget.referenceDate ?? DateTime.now()).weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final schedule = state.schedule;
    final activities = schedule.activitiesForDay(selectedDay);
    final now = widget.referenceDate ?? DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final selectedDate = weekStart.add(Duration(days: selectedDay));
    return Scaffold(
      bottomNavigationBar: const NeuroMoveBottomNavigation(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey('schedule-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bagaimana kesehatan anda hari ini?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AssetView(
                    AppAssets.scheduleHeader,
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_days[selectedDay]}, ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var day = 0; day < 7; day++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Semantics(
                        selected: selectedDay == day,
                        button: true,
                        child: Material(
                          color: selectedDay == day
                              ? AppColors.secondary
                              : AppColors.surfaceBlue,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(() => selectedDay = day),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${weekStart.add(Duration(days: day)).day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedDay == day
                                          ? Colors.white
                                          : AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _shortDays[day],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: selectedDay == day
                                          ? Colors.white
                                          : AppColors.dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!state.hasSavedProfile ||
                (!state.profile.canAssess && !state.profile.hardGate)) ...[
              const Text(
                'Lengkapi profil kesehatan untuk melihat jadwal Anda.',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/profile'),
                child: const Text('Isi profil kesehatan'),
              ),
            ] else if (state.assessment.requiresReferral) ...[
              Text(state.assessment.reason),
              FilledButton(
                onPressed: () => context.push('/referral'),
                child: const Text('Lihat langkah rujukan'),
              ),
            ] else if (!state.scheduleApproved) ...[
              const Text(
                'Jadwal masih berupa draf. Tinjau bersama caregiver sebelum memulai latihan.',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/schedule-draft'),
                child: const Text('Tinjau draf jadwal'),
              ),
            ] else ...[
              Material(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => context.push('/checklist'),
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        ProgressRing(progress: schedule.progress, size: 72),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${schedule.completedCount} Dari ${schedule.activities.length} Selesai',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Buka checklist mingguan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Column(
                  key: ValueKey(selectedDay),
                  children: [
                    if (activities.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBlue,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Tidak ada aktivitas terjadwal. Lihat hari lain atau tinjau draf jadwal.',
                        ),
                      )
                    else
                      for (final activity in activities)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExerciseCard(
                            title: activity.title,
                            duration: activity.duration,
                            imageAsset: activity.imageAsset,
                            completed: activity.completed,
                            onChanged: (_) => ref
                                .read(appStateProvider.notifier)
                                .toggleExercise(activity.id),
                          ),
                        ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/ai-chat'),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Tanya AI tentang jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}

const _shortDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
