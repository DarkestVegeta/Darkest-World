import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Site-wide cinematic optics layer: restrained lens bloom, dust depth,
/// atmospheric bands and moving light without masking interactive content.
class DarkestWorldCinematicOptics extends StatefulWidget {
  const DarkestWorldCinematicOptics({super.key});
  @override
  State<DarkestWorldCinematicOptics> createState() => _DarkestWorldCinematicOpticsState();
}

class _DarkestWorldCinematicOpticsState extends State<DarkestWorldCinematicOptics>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 96),
  )..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (_, __) => CustomPaint(
          painter: _CinematicOpticsPainter(_clock.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CinematicOpticsPainter extends CustomPainter {
  final double phase;
  const _CinematicOpticsPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final short = math.min(size.width, size.height);
    final center = Offset(size.width * .5, size.height * .48);

    // Deep photographic falloff keeps the layer cinematic instead of looking
    // like a UI filter.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -.05),
          radius: 1.18,
          colors: const [
            Colors.transparent,
            Colors.transparent,
            Color(0x12000000),
            Color(0x5A000000),
          ],
          stops: const [.30, .60, .82, 1],
        ).createShader(rect),
    );

    // Broad atmospheric light bands add depth behind existing worlds.
    for (var i = 0; i < 4; i++) {
      final drift = math.sin(phase * math.pi * 2 + i * 1.7) * size.width * .08;
      final band = Rect.fromCenter(
        center: Offset(center.dx + drift, size.height * (.19 + i * .22)),
        width: size.width * (1.05 + i * .12),
        height: short * (.11 + i * .012),
      );
      canvas.drawOval(
        band,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0x180F1730).withValues(alpha: .24 - i * .035),
              Colors.transparent,
            ],
          ).createShader(band),
      );
    }

    // Deterministic depth dust. Far points stay tiny; near points drift more.
    final rng = math.Random(90317);
    for (var i = 0; i < 620; i++) {
      final depth = rng.nextDouble();
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final drift = math.sin(phase * math.pi * 2 * (.18 + depth * .72) + i * .41) *
          (depth * 2.8 + .3);
      final twinkle = .45 + .55 * math.sin(phase * math.pi * 2 * (.35 + depth) + i * .83);
      final radius = .12 + depth * 1.15;
      final alpha = (.012 + depth * .075) * twinkle.clamp(.25, 1.0);
      canvas.drawCircle(
        Offset(baseX + drift, baseY),
        radius,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    // Slow anamorphic-style light sweep. It is intentionally very faint.
    final sweepX = -size.width * .30 + (size.width * 1.60 * phase);
    final sweep = Rect.fromLTWH(sweepX, 0, size.width * .18, size.height);
    canvas.drawRect(
      sweep,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [Colors.transparent, Color(0x061C2A45), Colors.transparent],
        ).createShader(sweep),
    );

    // Central optical bloom is only visible when the scene beneath is dark.
    final pulse = .72 + .28 * math.sin(phase * math.pi * 2);
    final bloomRadius = short * (.18 + pulse * .018);
    final bloom = Rect.fromCircle(center: center, radius: bloomRadius);
    canvas.drawCircle(
      center,
      bloomRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x0C9A8AB5).withValues(alpha: pulse),
            const Color(0x031A2740).withValues(alpha: pulse),
            Colors.transparent,
          ],
          stops: const [0, .34, 1],
        ).createShader(bloom),
    );

    // Fine corner registration marks make the whole site feel like one visual
    // instrument while remaining far below the HUD contrast.
    final mark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0x149AA7BA);
    const inset = 22.0;
    const arm = 42.0;
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + arm, inset), mark);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset, inset + 18), mark);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - arm, inset), mark);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + 18), mark);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + arm, size.height - inset), mark);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - 18), mark);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - arm, size.height - inset), mark);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - 18), mark);
  }

  @override
  bool shouldRepaint(covariant _CinematicOpticsPainter oldDelegate) => oldDelegate.phase != phase;
}
