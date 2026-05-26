import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';

class ResourceMonitor extends StatelessWidget {
  final double gpuLoad;
  final double genTime;

  const ResourceMonitor({
    super.key,
    this.gpuLoad = 84,
    this.genTime = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resource Usage', style: AppStyles.heading3(fontSize: 14)),
        const SizedBox(height: 12),
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'GPU LOAD',
                value: '${gpuLoad.round()}%',
                valueColor: AppColors.accentPink,
                isUp: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: 'GEN TIME',
                value: '${genTime}s',
                valueColor: AppColors.accentGreen,
                isUp: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mini chart
        SizedBox(
          height: 60,
          child: CustomPaint(
            painter: _MiniChartPainter(),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isUp;

  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.caption()),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: AppStyles.heading2(fontSize: 20, color: valueColor),
              ),
              const SizedBox(width: 4),
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: valueColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPink
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentPink.withOpacity(0.3),
          AppColors.accentPink.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Generate wave-like data
    final random = Random(42);
    final points = <Offset>[];
    const count = 20;
    for (int i = 0; i < count; i++) {
      final x = size.width * i / (count - 1);
      final baseY = size.height * 0.4;
      final wave = sin(i * 0.8) * size.height * 0.25;
      final noise = (random.nextDouble() - 0.5) * size.height * 0.15;
      final y = (baseY + wave + noise).clamp(4.0, size.height - 4);
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i].dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // X-axis labels
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    final labels = ['10:00', '10:10', '10:20', '10:25'];
    for (int i = 0; i < labels.length; i++) {
      labelPaint.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      );
      labelPaint.layout();
      final x = size.width * i / (labels.length - 1) -
          (i == labels.length - 1 ? labelPaint.width : 0);
      labelPaint.paint(canvas, Offset(x.clamp(0, size.width - labelPaint.width), size.height - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
