import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The Inspectly mark: a shield outline with a check, drawn as vectors so it
/// stays crisp at every size.
class InspectlyLogo extends StatelessWidget {
  const InspectlyLogo({super.key, this.size = 40, this.color});

  final double size;

  /// Solid color (e.g. white on photos). Null uses the brand blue gradient.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.86,
      height: size,
      child: CustomPaint(painter: _ShieldPainter(color)),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter(this.color);
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.12;
    final shield = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.92, h * 0.2)
      ..lineTo(w * 0.92, h * 0.47)
      ..cubicTo(w * 0.92, h * 0.72, w * 0.74, h * 0.87, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.26, h * 0.87, w * 0.08, h * 0.72, w * 0.08, h * 0.47)
      ..lineTo(w * 0.08, h * 0.2)
      ..close();
    final check = Path()
      ..moveTo(w * 0.3, h * 0.5)
      ..lineTo(w * 0.45, h * 0.63)
      ..lineTo(w * 0.71, h * 0.37);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    if (color != null) {
      paint.color = color!;
    } else {
      paint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2F8CFF), Color(0xFF0B4FCF)],
      ).createShader(Offset.zero & size);
    }
    canvas.drawPath(shield, paint);
    canvas.drawPath(check, paint..strokeWidth = stroke * 0.95);
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.color != color;
}

class InspectlyWordmark extends StatelessWidget {
  const InspectlyWordmark({super.key, this.fontSize = 28, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Inspectly',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color ?? context.palette.textPrimary,
      ),
    );
  }
}
