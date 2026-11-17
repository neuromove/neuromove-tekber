import 'package:file_picker/file_picker.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_assets.dart';

class AppEntrance extends StatefulWidget {
  const AppEntrance({super.key, required this.child, this.replayKey});
  final Widget child;
  final Object? replayKey;
  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final CurvedAnimation animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AppEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey &&
        !MediaQuery.disableAnimationsOf(context)) {
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    animation.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .018),
          end: Offset.zero,
        ).animate(animation),
        child: widget.child,
      ),
    );
  }
}

/// Keeps the design's logical bounds independent of the viewport constraints.
/// Scaling a constrained SizedBox alone clips the right side on narrow phones.
class DesignScale extends StatelessWidget {
  const DesignScale({
    super.key,
    required this.scale,
    required this.child,
    this.alignment = Alignment.topLeft,
    this.designWidth = 402,
  });
  final double scale, designWidth;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => OverflowBox(
      alignment: alignment,
      minWidth: designWidth,
      maxWidth: designWidth,
      minHeight: constraints.maxHeight / scale,
      maxHeight: constraints.maxHeight / scale,
      child: Transform.scale(scale: scale, alignment: alignment, child: child),
    ),
  );
}

class AssetView extends StatelessWidget {
  const AssetView(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.opacity = 1,
  });
  final String asset;
  final double? width, height;
  final BoxFit fit;
  final double opacity;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .92, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220),
    curve: Curves.easeOut,
    builder: (context, entryOpacity, child) =>
        Opacity(opacity: opacity * entryOpacity, child: child),
    child: asset.endsWith('.svg')
        ? ClipRect(
            child: SvgPicture.asset(
              asset,
              width: width,
              height: height,
              fit: fit,
            ),
          )
        : ClipRect(
            child: Image.asset(asset, width: width, height: height, fit: fit),
          ),
  );
}

class CroppedAssetView extends StatelessWidget {
  const CroppedAssetView(
    this.asset, {
    super.key,
    required this.leftFactor,
    required this.topFactor,
    required this.widthFactor,
    required this.heightFactor,
    this.opacity = 1,
  });

  final String asset;
  final double leftFactor, topFactor, widthFactor, heightFactor, opacity;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned(
            left: constraints.maxWidth * leftFactor,
            top: constraints.maxHeight * topFactor,
            width: constraints.maxWidth * widthFactor,
            height: constraints.maxHeight * heightFactor,
            child: Opacity(
              opacity: opacity,
              child: Image.asset(asset, fit: BoxFit.fill),
            ),
          ),
        ],
      ),
    ),
  );
}

class RobotAsset extends StatelessWidget {
  const RobotAsset({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      for (final dy in [-1.0, 4.0])
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, dy),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: const ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(0x40000000),
                  BlendMode.srcIn,
                ),
                child: _RobotCrop(),
              ),
            ),
          ),
        ),
      const Positioned.fill(child: _RobotCrop()),
    ],
  );
}

class _RobotCrop extends StatelessWidget {
  const _RobotCrop();
  @override
  Widget build(BuildContext context) => const CroppedAssetView(
    AppAssets.robot,
    leftFactor: -.8116,
    topFactor: -.3411,
    widthFactor: 2.5117,
    heightFactor: 1.91,
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 251,
    this.height = 73,
    this.loading = false,
    this.backgroundColor = AppColors.secondaryAlt,
    this.radius = 15,
    this.borderWidth = 3,
    this.borderColor = AppColors.primary,
    this.fontSize = 16,
  });
  final String label;
  final VoidCallback? onPressed;
  final double width, height;
  final bool loading;
  final Color backgroundColor;
  final Color borderColor;
  final double radius, borderWidth, fontSize;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0,
              ),
            ),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 251,
    this.height = 73,
    this.borderWidth = 3,
  });
  final String label;
  final VoidCallback? onPressed;
  final double width, height, borderWidth;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dark,
        side: BorderSide(color: AppColors.primary, width: borderWidth),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

class SelectablePill extends StatelessWidget {
  const SelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.expanded = false,
  });
  final String label;
  final bool selected, expanded;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final pill = InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 160),
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.white,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
    return expanded ? Expanded(child: pill) : pill;
  }
}

class UploadField extends StatelessWidget {
  const UploadField({
    super.key,
    required this.label,
    required this.onSelected,
    this.fileName,
  });
  final String label;
  final String? fileName;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result != null) onSelected(result.files.single.name);
    },
    child: Container(
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AssetView(
            AppAssets.upload,
            width: 38,
            height: 32,
            opacity: .55,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              fileName ?? label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    ),
  );
}

class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
  });
  final String title, value, status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF8698E6)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 13,
            height: 1.1,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 27,
            height: 1.15,
            color: Color(0xFF326C33),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          status,
          style: const TextStyle(
            fontSize: 13,
            height: 1.1,
            color: Color(0xFF326C33),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    ),
  );
}

class ClinicalInfoRow extends StatelessWidget {
  const ClinicalInfoRow({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    height: 49,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F1F1),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 18))),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}

class RiskStatusCard extends StatelessWidget {
  const RiskStatusCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 124,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.successPale,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        const AssetView(AppAssets.riskHeart, width: 48, height: 48),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Resiko Stabil',
                style: TextStyle(
                  fontSize: 17,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Kondisi anda dalam keadaan baik',
                style: TextStyle(fontSize: 9, height: 1.2),
              ),
            ],
          ),
        ),
        const Text(
          '80',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        const Text('/100', style: TextStyle(fontSize: 11)),
      ],
    ),
  );
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.title,
    required this.duration,
    required this.imageAsset,
    required this.completed,
    required this.onChanged,
  });
  final String title, duration, imageAsset;
  final bool completed;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180),
    decoration: BoxDecoration(
      color: completed ? const Color(0xFFF2FFF2) : const Color(0xFFDEFFDE),
      border: Border.all(color: const Color(0xFF427E7F)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 96,
            child: ClipRect(
              child: Stack(
                children: [
                  const Positioned(
                    left: 0,
                    top: 6,
                    width: 85,
                    height: 85,
                    child: AssetView('assets/figma/515_124_imgEllipse16.svg'),
                  ),
                  _ExerciseImage(
                    asset: imageAsset,
                    opacity: completed ? .6 : 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealInk,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.tealInk,
                  ),
                ),
                if (completed)
                  const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 12, color: AppColors.tealInk),
                  ),
              ],
            ),
          ),
          Checkbox(
            value: completed,
            onChanged: (value) => onChanged(value ?? false),
            semanticLabel: 'Tandai $title selesai',
            activeColor: AppColors.primary,
          ),
        ],
      ),
    ),
  );
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.asset, required this.opacity});
  final String asset;
  final double opacity;
  @override
  Widget build(BuildContext context) {
    if (asset == AppAssets.aerobic) {
      return Positioned(
        left: 40,
        top: 9,
        width: 46,
        height: 92,
        child: CroppedAssetView(
          asset,
          leftFactor: -1.4878,
          topFactor: -.2202,
          widthFactor: 2.878,
          heightFactor: 1.3671,
          opacity: opacity,
        ),
      );
    }
    if (asset == AppAssets.jogging) {
      return Positioned(
        left: 12,
        top: -3,
        width: 105,
        height: 100,
        child: AssetView(asset, fit: BoxFit.cover, opacity: opacity),
      );
    }
    return Positioned(
      left: 22,
      top: 5,
      width: 77,
      height: 95,
      child: CroppedAssetView(
        asset,
        leftFactor: -.5705,
        topFactor: -.1824,
        widthFactor: 1.7099,
        heightFactor: 1.3228,
        opacity: opacity,
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 85});
  final double progress, size;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: progress.clamp(0, 1)),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) => SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: AssetView('assets/figma/515_124_imgEllipse13.svg'),
          ),
          Positioned.fill(
            child: Transform.flip(
              flipX: true,
              child: Transform.rotate(
                angle: -1.5707963267948966,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 11,
                  strokeAlign: -1,
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Text(
            '${(value * 100).floor()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
  );
}

class WeekSelector extends StatelessWidget {
  const WeekSelector({super.key, this.selected = 2});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const days = [
      ('20', 'Sen'),
      ('21', 'Sel'),
      ('22', 'Rab'),
      ('23', 'Kam'),
      ('24', 'Jum'),
      ('25', 'Sab'),
      ('26', 'Min'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < days.length; i++)
          Container(
            width: 43,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: i == selected ? const Color(0xFF8698E6) : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Text(
                    days[i].$1,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
                Text(days[i].$2, style: const TextStyle(fontSize: 12)),
                Text(
                  i == selected ? '..' : '.',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AiSuggestionChip extends StatelessWidget {
  const AiSuggestionChip({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: onTap,
    label: SizedBox(
      width: 220,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF396163)),
      ),
    ),
    backgroundColor: const Color(0xFFF4F6FF),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  );
}

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.status = 'Normal',
  });
  final String title, value, status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 42,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(status, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}

class NeuroMoveBottomNavigation extends StatelessWidget {
  const NeuroMoveBottomNavigation({super.key, required this.currentIndex});
  final int currentIndex;
  @override
  Widget build(BuildContext context) {
    const routes = ['/home', '/schedule', '/report', '/caregiver'];
    const labels = ['Beranda', 'Jadwal', 'Laporan', 'Caregiver'];
    const assets = [
      AppAssets.navHome,
      AppAssets.navSchedule,
      AppAssets.navReport,
      AppAssets.navCaregiver,
    ];
    return Material(
      color: AppColors.primaryAlt,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == currentIndex,
                  button: true,
                  child: InkWell(
                    onTap: () {
                      final shell = StatefulNavigationShell.maybeOf(context);
                      if (shell != null) {
                        shell.goBranch(i);
                      } else {
                        context.go(routes[i]);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: _NavigationAsset(index: i, asset: assets[i]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'AtkinsonHyperlegible',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: i == currentIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            width: 34,
                            height: 2,
                            color: i == currentIndex
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationAsset extends StatelessWidget {
  const _NavigationAsset({required this.index, required this.asset});
  final int index;
  final String asset;

  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return CroppedAssetView(
        asset,
        leftFactor: -.9109,
        topFactor: -.2298,
        widthFactor: 2.8216,
        heightFactor: 1.5391,
      );
    }
    if (index == 3) {
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 12.5,
            top: 0,
            width: 38,
            height: 37,
            child: AssetView(asset, fit: BoxFit.cover),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: 30,
            height: 37,
            child: AssetView(asset, fit: BoxFit.cover),
          ),
          Positioned(
            left: 4,
            top: 0,
            width: 40,
            height: 44,
            child: AssetView(asset, fit: BoxFit.cover),
          ),
        ],
      );
    }
    return AssetView(asset, fit: BoxFit.cover);
  }
}

class ComplianceChart extends StatelessWidget {
  const ComplianceChart({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CompliancePainter(),
    child: const SizedBox(height: 210, width: double.infinity),
  );
}

class _CompliancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    final line = Paint()
      ..color = const Color(0xFF287D2B)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dots = Paint()..color = AppColors.success;
    final points = [
      Offset(20, 92),
      Offset(size.width * .34, 50),
      Offset(size.width * .58, 122),
      Offset(size.width - 24, 76),
    ];
    canvas.drawLine(
      Offset(8, size.height - 28),
      Offset(size.width - 8, size.height - 28),
      axis,
    );
    canvas.drawLine(Offset(20, size.height - 20), const Offset(20, 24), axis);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);
    for (final point in points) {
      canvas.drawCircle(point, 7, dots);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FigmaPreviewFrame extends StatelessWidget {
  const FigmaPreviewFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      ClipRRect(borderRadius: BorderRadius.circular(38), child: child);
}
