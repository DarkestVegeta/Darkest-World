import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'falling_star_easter_egg.dart';

/// Lightweight, asset-free animated background for the Darkest-World home.
class LivingWorldScene extends StatefulWidget {
  final Widget child;

  const LivingWorldScene({super.key, required this.child});

  @override
  State<LivingWorldScene> createState() => _LivingWorldSceneState();
}

class _LivingWorldSceneState extends State<LivingWorldScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _LivingWorldPainter(animation: _controller),
          ),
        ),
        widget.child,
        const FallingStarEasterEgg(),
      ],
    );
  }
}

class _LivingWorldPainter extends CustomPainter {
  final Animation<double> animation;

  _LivingWorldPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width * 0.72, size.height * 0.50);
    final radius = shortest * 0.27;

    _paintSpace(canvas, size, t);
    _paintWorldGlow(canvas, center, radius);
    _paintWorld(canvas, center, radius, t);
    _paintOrbit(canvas, center, radius, t);
  }

  void _paintSpace(Canvas canvas, Size size, double t) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03030B), Color(0xFF09051A), Color(0xFF020208)],
        ).createShader(rect),
    );

    final starPaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 90; i++) {
      final x = ((i * 73.0) % 997) / 997 * size.width;
      final baseY = ((i * 137.0) % 991) / 991 * size.height;
      final drift = math.sin(t * math.pi * 2 + i * 0.71) * 2.5;
      final pulse = 0.35 +
          0.65 * ((math.sin(t * math.pi * 4 + i * 1.37) + 1) / 2);
      starPaint.color = Colors.white.withValues(alpha: 0.10 + pulse * 0.28);
      canvas.drawCircle(Offset(x, baseY + drift), i % 7 == 0 ? 1.4 : 0.7, starPaint);
    }
  }

  void _paintWorldGlow(Canvas canvas, Offset center, double radius) {
    final glowRect = Rect.fromCircle(center: center, radius: radius * 1.65);
    canvas.drawCircle(
      center,
      radius * 1.65,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF6B4CFF).withValues(alpha: 0.20),
            const Color(0xFF2B8CFF).withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(glowRect),
    );
  }

  void _paintWorld(Canvas canvas, Offset center, double radius, double t) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final worldRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 1.0,
          colors: [Color(0xFF264E9B), Color(0xFF102A61), Color(0xFF050B22)],
        ).createShader(worldRect),
    );

    final landPaint = Paint()
      ..color = const Color(0xFF553E75).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;

    final shift = math.sin(t * math.pi * 2) * radius * 0.16;
    final land = Path()
      ..moveTo(center.dx - radius * 0.92 + shift, center.dy - radius * 0.10)
      ..cubicTo(
        center.dx - radius * 0.60 + shift,
        center.dy - radius * 0.55,
        center.dx - radius * 0.20 + shift,
        center.dy - radius * 0.35,
        center.dx - radius * 0.05 + shift,
        center.dy - radius * 0.05,
      )
      ..cubicTo(
        center.dx - radius * 0.25 + shift,
        center.dy + radius * 0.22,
        center.dx - radius * 0.58 + shift,
        center.dy + radius * 0.34,
        center.dx - radius * 0.92 + shift,
        center.dy + radius * 0.20,
      )
      ..close();
    canvas.drawPath(land, landPaint);

    final secondLand = Path()
      ..moveTo(center.dx + radius * 0.02 + shift, center.dy - radius * 0.70)
      ..cubicTo(
        center.dx + radius * 0.45 + shift,
        center.dy - radius * 0.58,
        center.dx + radius * 0.85 + shift,
        center.dy - radius * 0.28,
        center.dx + radius * 0.92 + shift,
        center.dy + radius * 0.08,
      )
      ..cubicTo(
        center.dx + radius * 0.48 + shift,
        center.dy + radius * 0.03,
        center.dx + radius * 0.28 + shift,
        center.dy - radius * 0.22,
        center.dx + radius * 0.02 + shift,
        center.dy - radius * 0.70,
      )
      ..close();
    canvas.drawPath(secondLand, landPaint);

    final lightPaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 18; i++) {
      final angle = i * 0.91 + t * math.pi * 2;
      final x = center.dx + math.cos(angle) * radius * (0.35 + (i % 4) * 0.11);
      final y = center.dy + math.sin(angle * 1.13) * radius * 0.60;
      final opacity = 0.10 + (math.sin(t * math.pi * 4 + i) + 1) * 0.08;
      lightPaint.color = const Color(0xFFB8A6FF).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 2.0 : 1.0, lightPaint);
    }

    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.025;
    final cloudShift = math.sin(t * math.pi * 2 * 1.7) * radius * 0.10;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + cloudShift, center.dy - radius * 0.28),
        width: radius * 1.55,
        height: radius * 0.32,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - cloudShift * 0.7, center.dy + radius * 0.34),
        width: radius * 1.25,
        height: radius * 0.25,
      ),
      cloudPaint,
    );

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF8EA8FF).withValues(alpha: 0.55),
    );
  }

  void _paintOrbit(Canvas canvas, Offset center, double radius, double t) {
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8C78FF).withValues(alpha: 0.20);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.55,
        height: radius * 0.82,
      ),
      orbit,
    );

    final angle = t * math.pi * 2;
    final x = math.cos(angle) * radius * 1.275;
    final y = math.sin(angle) * radius * 0.41;
    canvas.drawCircle(
      Offset(x, y),
      4,
      Paint()..color = const Color(0xFFB99CFF).withValues(alpha: 0.85),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LivingWorldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
