import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestWorldArchiveDepth extends StatefulWidget {
  const DarkestWorldArchiveDepth({super.key});
  @override State<DarkestWorldArchiveDepth> createState() => _DarkestWorldArchiveDepthState();
}

class _DarkestWorldArchiveDepthState extends State<DarkestWorldArchiveDepth> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 110))..repeat();
  @override void dispose() { _clock.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(animation: _clock, builder: (_, __) => CustomPaint(painter: _ArchiveDepthPainter(_clock.value), size: Size.infinite)));
}

class _ArchiveDepthPainter extends CustomPainter {
  final double phase;
  const _ArchiveDepthPainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height);
    final center = Offset(s.width * .5, s.height * .52);
    final rx = m * .38;
    final ry = m * .245;
    final rot = math.sin(phase * math.pi * 2) * .018;

    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rot);
    c.translate(-center.dx, -center.dy);

    for (var i = 0; i < 9; i++) {
      final f = 1.0 - i * .075;
      final rect = Rect.fromCenter(center: center, width: rx * 2 * f, height: ry * 2 * f);
      c.drawOval(rect, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .42 + i * .035
        ..color = const Color(0x167F70B0));
    }

    final sweep = phase * math.pi * 2;
    final sweepRect = Rect.fromCenter(center: center, width: rx * 2.05, height: ry * 2.05);
    c.drawArc(sweepRect, sweep, .52, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x508E7FB9));
    c.drawArc(sweepRect, sweep + math.pi, .23, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55
      ..color = const Color(0x2B9FB4C8));

    final depth = math.sin(phase * math.pi * 2) * .5 + .5;
    for (var i = 0; i < 14; i++) {
      final a = i * math.pi * 2 / 14 + phase * .17;
      final orbit = .62 + (i % 4) * .085;
      final p = Offset(center.dx + math.cos(a) * rx * orbit, center.dy + math.sin(a) * ry * orbit);
      final rr = .8 + (i % 3) * .55;
      c.drawCircle(p, rr, Paint()..color = const Color(0x4FCDD6E1).withValues(alpha: .14 + depth * .08));
    }
    c.restore();

    final edge = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x0F9BA9BC);
    const a = 28.0;
    c.drawLine(Offset(16, a), const Offset(16, 16), edge);
    c.drawLine(const Offset(16, 16), Offset(a, 16), edge);
    c.drawLine(Offset(s.width - 16, a), Offset(s.width - 16, 16), edge);
    c.drawLine(Offset(s.width - 16, 16), Offset(s.width - a, 16), edge);
    c.drawLine(Offset(16, s.height - a), Offset(16, s.height - 16), edge);
    c.drawLine(Offset(16, s.height - 16), Offset(a, s.height - 16), edge);
    c.drawLine(Offset(s.width - 16, s.height - a), Offset(s.width - 16, s.height - 16), edge);
    c.drawLine(Offset(s.width - 16, s.height - 16), Offset(s.width - a, s.height - 16), edge);

    final scan = (phase * s.height * 1.15) % (s.height + 90) - 45;
    c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x0B9AB0C5));
    c.drawRect(Rect.fromLTWH(0, scan - 9, s.width, 19), Paint()..shader = const LinearGradient(colors: [Colors.transparent, Color(0x041C4E6B), Colors.transparent]).createShader(Rect.fromLTWH(0, scan - 9, s.width, 19)));
  }
  @override bool shouldRepaint(covariant _ArchiveDepthPainter old) => old.phase != phase;
}
