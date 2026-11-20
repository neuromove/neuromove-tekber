import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.id,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.suffix,
    this.enabled = true,
  });
  final String id, label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextFormField(
            key: ValueKey('profile-$id'),
            controller: controller,
            enabled: enabled,
            readOnly: onTap != null,
            onTap: onTap,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(suffixIcon: suffix, errorMaxLines: 3),
          ),
        ),
      ],
    ),
  );
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 16),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class ProfileRadioGroup extends StatelessWidget {
  const ProfileRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String value;
  final Map<String, String> options;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => RadioGroup<String>(
    groupValue: value,
    onChanged: (value) {
      if (value != null) onChanged?.call(value);
    },
    child: Column(
      children: [
        for (final option in options.entries)
          RadioListTile<String>(
            value: option.key,
            title: Text(option.value),
            contentPadding: EdgeInsets.zero,
            enabled: onChanged != null,
            activeColor: AppColors.primary,
          ),
      ],
    ),
  );
}

class ProfileCheckbox extends StatelessWidget {
  const ProfileCheckbox({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool?>? onChanged;
  @override
  Widget build(BuildContext context) => CheckboxListTile(
    title: Text(label),
    value: selected,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    activeColor: AppColors.primary,
  );
}