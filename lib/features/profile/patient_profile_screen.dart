import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import 'profile_form_widgets.dart';
import '../../shared/models/models.dart';
import '../../shared/state/app_state.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  String gender = '', mobility = '';
  bool saving = false;
  final formKey = GlobalKey<FormState>();
  final diseases = <String>{'Alzheimer'};
  late ElderlyProfile profile;
  late final Map<String, TextEditingController> fields;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appStateProvider);
    profile = state.hasSavedProfile ? state.profile : ElderlyProfile.empty;
    gender = profile.gender;
    mobility = profile.mobility;
    diseases
      ..clear()
      ..addAll(profile.diseases);
    fields = {
      for (final e in {
        'name': profile.name,
        'place': profile.birthPlace,
        'date': profile.birthDate == null
            ? ''
            : DateFormat('dd/MM/yyyy').format(profile.birthDate!),
        'weight': profile.weight,
        'height': profile.height,
        'sys': profile.systolic,
        'dia': profile.diastolic,
        'other': profile.otherDisease,
      }.entries)
        e.key: TextEditingController(text: e.value),
    };
  }

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: profile.birthDate ?? DateTime(1956, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      profile = profile.copyWith(birthDate: date);
      fields['date']!.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Future<void> save() async {
    if (saving) return;
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama lengkap terlebih dahulu.')),
      );
      return;
    }
    final value = profile.copyWith(
      name: fields['name']!.text.trim(),
      birthPlace: fields['place']!.text,
      gender: gender,
      mobility: mobility,
      weight: fields['weight']!.text,
      height: fields['height']!.text,
      systolic: fields['sys']!.text,
      diastolic: fields['dia']!.text,
      diseases: {...diseases},
      otherDisease: fields['other']!.text,
    );
    setState(() => saving = true);
    try {
      await ref.read(appStateProvider.notifier).setProfile(value);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data gagal disimpan. Coba lagi.')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => saving = false);
    }
    if (mounted) {
      context.go(
        ref.read(appStateProvider).assessment.requiresReferral
            ? '/referral'
            : '/home',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profil Pasien'),
      leading: BackButton(
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      ),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Lengkapi Profil dulu yuk!',
                style: TextStyle(
                  fontSize: 26,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const ProfileSectionTitle('Biodata Pasien'),
              ProfileField(
                id: 'name',
                label: 'Nama Lengkap *',
                controller: fields['name']!,
                enabled: !saving,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama lengkap wajib diisi'
                    : null,
              ),
              field('place', 'Tempat Lahir (Opsional)'),
              ProfileField(
                id: 'date',
                label: 'Tanggal Lahir (Opsional)',
                controller: fields['date']!,
                onTap: pickDate,
                enabled: !saving,
                suffix: const Icon(Icons.calendar_month_outlined),
              ),
              const Text(
                'Jenis Kelamin',
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              ProfileRadioGroup(
                value: gender,
                options: const {'L': 'Laki-laki', 'P': 'Perempuan'},
                onChanged: saving
                    ? null
                    : (value) => setState(() => gender = value),
              ),
              field('weight', 'Berat Badan (kg)', numeric: true),
              field('height', 'Tinggi Badan (cm)', numeric: true),
              const ProfileSectionTitle('Tekanan Darah (mmHg)'),
              field('sys', 'Sistolik', numeric: true),
              field('dia', 'Diastolik', numeric: true),
              const ProfileSectionTitle('Riwayat Penyakit (Opsional)'),
              const Text('Boleh pilih lebih dari satu.'),
              for (final disease in const ['Hipertensi', 'Alzheimer'])
                ProfileCheckbox(
                  label: disease,
                  selected: diseases.contains(disease),
                  onChanged: saving ? null : (_) => _toggleDisease(disease),
                ),
              field('other', 'Penyakit Lainnya (Opsional)'),
              const ProfileSectionTitle('Status Mobilitas'),
              ProfileRadioGroup(
                value: mobility,
                options: const {
                  'Mandiri': 'Mandiri',
                  'Alat bantu': 'Alat bantu',
                  'Didampingi': 'Didampingi',
                },
                onChanged: saving
                    ? null
                    : (value) => setState(() => mobility = value),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: saving ? null : save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(16),
                ),
                child: saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Masuk Ke NeuroMove!',
                        textAlign: TextAlign.center,
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget field(String id, String label, {bool numeric = false}) => ProfileField(
    id: id,
    label: label,
    controller: fields[id]!,
    enabled: !saving,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true)
        : null,
  );

  void _toggleDisease(String disease) => setState(
    () => diseases.contains(disease)
        ? diseases.remove(disease)
        : diseases.add(disease),
  );
}