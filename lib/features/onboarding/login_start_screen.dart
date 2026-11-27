import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/widgets.dart';

class LoginStartScreen extends StatelessWidget {
  const LoginStartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / 391;
        return SingleChildScrollView(
          child: SizedBox(
            height: mathMax(constraints.maxHeight, 874 * s),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.white),
                Positioned(
                  left: -4 * s,
                  width: 406.5 * s,
                  top: 430.45 * s,
                  height: 450.546 * s,
                  child: ClipRect(
                    child: SvgPicture.asset(
                      AppAssets.loginWave,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  left: 72.3 * s,
                  top: 537.3 * s,
                  width: 259.4 * s,
                  height: 30.4 * s,
                  child: const AssetView(
                    'assets/figma/506_67_imgEllipse14.svg',
                  ),
                ),
                Positioned(
                  left: 71 * s,
                  top: 264 * s,
                  width: 262 * s,
                  height: 297 * s,
                  child: const CroppedAssetView(
                    AppAssets.loginPeople,
                    leftFactor: -.1769,
                    topFactor: -.1704,
                    widthFactor: 1.4462,
                    heightFactor: 1.2111,
                  ),
                ),
                Positioned(
                  left: 97 * s,
                  top: 79 * s,
                  child: Text(
                    'Neuro',
                    style: TextStyle(
                      fontSize: 48 * s,
                      color: AppColors.primaryAlt,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 170 * s,
                  top: 115 * s,
                  child: Text(
                    'Move',
                    style: TextStyle(
                      fontSize: 48 * s,
                      color: AppColors.primaryAlt,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 184 * s,
                  child: const Text(
                    'Pendamping Olahraga\nDalam Menjaga Kesehatan Otak Lansia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF717FC2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 94 * s,
                  top: 647 * s,
                  width: 215 * s,
                  height: 42 * s,
                  child: _LoginButton(
                    label: 'Mulai',
                    onTap: () => context.go('/profile'),
                  ),
                ),
                Positioned(
                  left: 93 * s,
                  top: 699 * s,
                  width: 215 * s,
                  height: 42 * s,
                  child: _LoginButton(
                    label: 'Caregiver Login',
                    foreground: const Color(0xFF396163),
                    onTap: () => context.go('/caregiver'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

double mathMax(double a, double b) => a > b ? a : b;

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.onTap,
    this.foreground = AppColors.primaryAlt,
  });
  final String label;
  final Color foreground;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF0F9FF),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4.3,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
