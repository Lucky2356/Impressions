import 'package:flutter/material.dart';

/// Мини-график (sparkline) — плавная линия с мягкой заливкой под ней.
/// Рисуется локально через CustomPainter, без внешних библиотек и сети.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 44,
    this.strokeWidth = 2.5,
    this.fill = true,
  });

  final List<double> values;
  final Color color;
  final double height;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    final pad = strokeWidth + 1;

    Offset pointAt(int i) {
      final x = size.width * (i / (values.length - 1));
      final norm = (values[i] - minV) / range;
      final y = size.height - pad - norm * (size.height - pad * 2);
      return Offset(x, y);
    }

    // Гладкая кривая через контрольные точки (Catmull-Rom → Bezier).
    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 0; i < values.length - 1; i++) {
      final p0 = pointAt(i == 0 ? 0 : i - 1);
      final p1 = pointAt(i);
      final p2 = pointAt(i + 1);
      final p3 = pointAt(i + 2 >= values.length ? values.length - 1 : i + 2);
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size);
      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}
