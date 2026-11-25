import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/models.dart';
import '../../shared/services/assessment_engine.dart';
import '../../shared/state/app_state.dart';

class ScheduleDraftScreen extends ConsumerStatefulWidget {
  const ScheduleDraftScreen({super.key});

  @override
  ConsumerState<ScheduleDraftScreen> createState() =>
      _ScheduleDraftScreenState();
}

class _ScheduleDraftScreenState extends ConsumerState<ScheduleDraftScreen> {
  int selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final schedule = state.schedule;
    final activities = schedule.activitiesForDay(selectedDay);
    final noteTop = activities.isEmpty
        ? 485.0
        : 323.0 + (activities.length * 81);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 402;
          return SingleChildScrollView(
            child: SizedBox(
              width: constraints.maxWidth,
              height: 874 * scale,
              child: FittedBox(
                alignment: Alignment.topLeft,
                fit: BoxFit.fitWidth,
                child: SizedBox(
                  width: 402,
                  height: 874,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Colors.white),
                      ),
                      Positioned(
                        left: 32,
                        top: 136,
                        width: 28,
                        height: 28,
                        child: IconButton(
                          tooltip: 'Kembali ke hasil asesmen',
                          padding: EdgeInsets.zero,
                          iconSize: 21,
                          onPressed: () => context.go('/assessment'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const Positioned(
                        left: 63,
                        top: 134,
                        child: Text(
                          'Draf jadwal',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 63,
                        top: 167,
                        width: 300,
                        child: Text(
                          '${_honorific(state.profile)} ${_profileName(state.profile)} · ${schedule.zone.label.toLowerCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF796C5C),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 194,
                        width: 342,
                        height: 55,
                        child: _DraftStatusCard(
                          approved: state.scheduleApproved,
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 263,
                        width: 342,
                        height: 46,
                        child: _DaySelector(
                          selected: selectedDay,
                          schedule: schedule,
                          onSelected: (day) =>
                              setState(() => selectedDay = day),
                        ),
                      ),
                      for (var index = 0; index < activities.length; index++)
                        Positioned(
                          left: 32,
                          top: 323 + (index * 81),
                          width: 342,
                          height: 67,
                          child: _DraftActivityCard(
                            activity: activities[index],
                            onEdit: () =>
                                _showActivityActions(activities[index]),
                          ),
                        ),
                      if (activities.isEmpty)
                        const Positioned(
                          left: 32,
                          top: 323,
                          width: 342,
                          height: 148,
                          child: _EmptyDayCard(),
                        ),
                      Positioned(
                        left: 32,
                        top: noteTop,
                        width: 342,
                        height: 63,
                        child: _ScheduleNote(schedule: schedule),
                      ),
                      Positioned(
                        left: 32,
                        top: noteTop + 77,
                        width: 342,
                        height: 50,
                        child: FilledButton(
                          onPressed: activities.isEmpty
                              ? null
                              : () async {
                                  await ref
                                      .read(appStateProvider.notifier)
                                      .approveSchedule();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Jadwal disetujui dan siap dilihat lansia.',
                                      ),
                                    ),
                                  );
                                  context.go('/schedule');
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4D55DF),
                            disabledBackgroundColor: const Color(0xFFC8CCEC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Setujui dan kirim ke lansia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: noteTop + 142,
                        width: 342,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(appStateProvider.notifier)
                                .resetScheduleDraft();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Draf disusun ulang dari rekomendasi awal.',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFFB9BFD2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Susun ulang'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showActivityActions(ExerciseActivity activity) async {
    final action = await showModalBottomSheet<_DraftAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('Ganti aktivitas'),
              subtitle: const Text(
                'Pilih aktivitas lain yang aman untuk zona ini',
              ),
              onTap: () => Navigator.pop(context, _DraftAction.replace),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Pindah hari'),
              subtitle: const Text(
                'Pertahankan durasi dan intensitas aktivitas',
              ),
              onTap: () => Navigator.pop(context, _DraftAction.move),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == _DraftAction.replace) await _replaceActivity(activity);
    if (action == _DraftAction.move) await _moveActivity(activity);
  }

  Future<void> _replaceActivity(ExerciseActivity activity) async {
    final state = ref.read(appStateProvider);
    final occupied = {
      for (final item in state.schedule.activitiesForDay(activity.dayIndex))
        if (item.id != activity.id) item.title,
    };
    final options = activityCatalog
        .where(
          (item) =>
              (state.schedule.zone == RiskZone.safe || item.suitableForAlert) &&
              !occupied.contains(item.title) &&
              item.title != activity.title,
        )
        .toList();
    final selected = await showModalBottomSheet<ActivityDefinition>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Text(
                  'Ganti aktivitas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final duration = state.schedule.zone == RiskZone.safe
                        ? option.safeDuration
                        : option.alertDuration;
                    return ListTile(
                      title: Text(option.title),
                      subtitle: Text(
                        '$duration · sesuai ${state.schedule.zone.label.toLowerCase()}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    final changed = await ref
        .read(appStateProvider.notifier)
        .replaceScheduleActivity(activity.id, selected.id);
    if (!mounted || changed) return;
    _showEditError();
  }

  Future<void> _moveActivity(ExerciseActivity activity) async {
    final schedule = ref.read(appStateProvider).schedule;
    final target = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pindah ke hari',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var day = 0; day < _days.length; day++)
                    ChoiceChip(
                      label: Text(_days[day]),
                      selected: day == activity.dayIndex,
                      onSelected:
                          day == activity.dayIndex ||
                              schedule.activitiesForDay(day).length >= 3 ||
                              schedule
                                  .activitiesForDay(day)
                                  .any((item) => item.title == activity.title)
                          ? null
                          : (_) => Navigator.pop(context, day),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (target == null || !mounted) return;
    final changed = await ref
        .read(appStateProvider.notifier)
        .moveScheduleActivity(activity.id, target);
    if (!mounted) return;
    if (changed) {
      setState(() => selectedDay = target);
    } else {
      _showEditError();
    }
  }

  void _showEditError() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Perubahan tidak dapat diterapkan pada hari itu.'),
    ),
  );
}

enum _DraftAction { replace, move }

class _DraftStatusCard extends StatelessWidget {
  const _DraftStatusCard({required this.approved});

  final bool approved;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: approved ? const Color(0xFFEAF8ED) : const Color(0xFFFFF5E5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            approved ? Icons.check_circle_outline : Icons.edit_outlined,
            size: 18,
            color: approved ? const Color(0xFF287D2B) : const Color(0xFFA85B00),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              approved
                  ? 'Sudah dikirim. Lansia dapat melihat jadwal ini.'
                  : 'Belum dikirim. Lansia belum bisa melihat jadwal ini.',
              style: TextStyle(
                fontSize: 12,
                height: 1.25,
                color: approved
                    ? const Color(0xFF236428)
                    : const Color(0xFF7D3D00),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selected,
    required this.schedule,
    required this.onSelected,
  });

  final int selected;
  final WeeklySchedule schedule;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (var day = 0; day < _days.length; day++)
        Semantics(
          button: true,
          selected: selected == day,
          label:
              '${_days[day]}, ${schedule.activitiesForDay(day).length} aktivitas',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelected(day),
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 46,
              decoration: BoxDecoration(
                color: selected == day
                    ? const Color(0xFF4D55DF)
                    : schedule.activitiesForDay(day).isEmpty
                    ? const Color(0xFFF0EEE8)
                    : const Color(0xFFF0F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[day],
                    style: TextStyle(
                      fontSize: 12,
                      color: selected == day
                          ? Colors.white
                          : const Color(0xFF111093),
                    ),
                  ),
                  Text(
                    schedule.activitiesForDay(day).isEmpty
                        ? '—'
                        : '${schedule.activitiesForDay(day).length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: selected == day
                          ? Colors.white
                          : const Color(0xFF3530B7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class _DraftActivityCard extends StatelessWidget {
  const _DraftActivityCard({required this.activity, required this.onEdit});

  final ExerciseActivity activity;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFDDD8D0)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sentenceCase(activity.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _activityMeta(activity),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF796C5C),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit ${activity.title}',
            onPressed: onEdit,
            icon: const Icon(
              Icons.more_vert,
              size: 21,
              color: Color(0xFF8E8E86),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF7F7FB),
      border: Border.all(color: const Color(0xFFDDDFF0)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Center(
      child: Text(
        'Hari pemulihan\nTidak ada aktivitas terjadwal',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Color(0xFF5F6180)),
      ),
    ),
  );
}

class _ScheduleNote extends StatelessWidget {
  const _ScheduleNote({required this.schedule});

  final WeeklySchedule schedule;

  @override
  Widget build(BuildContext context) {
    final emptyDays = [
      for (var day = 0; day < _days.length; day++)
        if (schedule.activitiesForDay(day).isEmpty) _longDays[day],
    ];
    final text = emptyDays.isEmpty
        ? 'Setiap hari memiliki sesi ringan. Waktu latihan dapat disesuaikan bersama lansia.'
        : '${_joinDays(emptyDays)} dikosongkan sebagai hari pemulihan. Sesi dapat diatur sore hari.';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 19,
              color: Color(0xFF3035AD),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Color(0xFF111093),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _longDays = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

String _honorific(ElderlyProfile profile) =>
    profile.gender == 'P' ? 'Ibu' : 'Bapak';

String _profileName(ElderlyProfile profile) =>
    profile.name.trim().isEmpty ? 'Lansia' : profile.name.trim();

String _sentenceCase(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}

String _activityMeta(ExerciseActivity activity) {
  final duration = activity.duration.toLowerCase();
  if (activity.title.toLowerCase().contains('jalan')) {
    return '$duration · intensitas ringan';
  }
  if (activity.title.toLowerCase().contains('peregangan')) {
    return '$duration · 2 set';
  }
  if (activity.title.toLowerCase().contains('keseimbangan')) {
    return '$duration · 3 set';
  }
  return '$duration · intensitas disesuaikan';
}

String _joinDays(List<String> days) => switch (days.length) {
  0 => '',
  1 => days.first,
  2 => '${days.first} dan ${days.last}',
  _ => '${days.sublist(0, days.length - 1).join(', ')}, dan ${days.last}',
};
