import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/widgets.dart';

class AssessmentWarningCard extends StatelessWidget {
  const AssessmentWarningCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 84,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      children: [
        AssetView(AppAssets.warning, width: 49, height: 49),
        SizedBox(width: 13),
        Expanded(
          child: Text(
            AppStrings.warning,
            style: TextStyle(color: AppColors.inkBlue, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
