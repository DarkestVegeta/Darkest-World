import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldWorldScan extends StatefulWidget {
  const DarkestWorldWorldScan({super.key});
  @override State<DarkestWorldWorldScan> createState() => _DarkestWorldWorldScanState();
}

class _DarkestWorldWorldScanState extends State<DarkestWorldWorldScan> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 84))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(animation: clock, builder: (_, __) {
    final session = GalaxyNavigationSession.instance;
    final selected = session.selected?.toString().toUpperCase() ?? 'UNSELECTED';
    final mapped = session.mapped.length.toString().padLeft(2, '0');
    final visits = session.visits.toString().padLeft(2, '0');
    return CustomPaint(painter: _WorldScanPainter(clock.value, selected, mapped, visits), size: Size.infinite);
  }));
}

class _WorldScanPainter extends CustomPainter {
  final double t; final String selected, mapped, visits;
  const _WorldScanPainter(this.t, this.selected, this.mapped, this.visits);
  @override void paint(Canvas x, Size s) {
    if (s.isEmpty) return;
    final c = Offset(s.width * .5, s.height * .52);
    final r = math.min(s.width, s.height) * .37;
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x1C9DB7C0);
    for (var i = 0; i < 9; i++) {
      final rr = r * (.22 + i * .095);
      x.drawOval(Rect.fromCenter(center: c, width: rr * 2.05, height: rr * .82), line);
    }
    for (var i = 0; i < 18; i++) {
      final a = i * math.pi * 2 / 18;
      x.drawLine(c, c + Offset(math.cos(a) * r, math.sin(a) * r), line);
    }
    final sweepRect = Rect.fromCircle(center: c, radius: r);
    x.drawArc(sweepRect, t * math.pi * 2, .72, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0x4A9FC0C9));
    x.drawArc(sweepRect, t * math.pi * 2 + math.pi, .28, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x2C789AA5));
    final glow = r * (.92 + .04 * math.sin(t * math.pi * 2));
    x.drawCircle(c, glow, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x1D87AAB5));
    x.drawCircle(c, r * .09, Paint()..shader = const RadialGradient(colors: [Color(0xE6EAF0F0), Color(0x557D9BA3), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * .22)));

    final rnd = math.Random(811);
    for (var i = 0; i < 110; i++) {
      final a = rnd.nextDouble() * math.pi * 2 + t * (i.isEven ? .08 : -.06);
      final rr = r * (.25 + rnd.nextDouble() * .7);
      final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr * .40);
      x.drawCircle(p, .6 + rnd.nextDouble() * 1.5, Paint()..color = const Color(0x557F9CA5));
    }

    final scanY = s.height * ((t * .72 + .14) % 1.0);
    x.drawRect(Rect.fromLTWH(0, scanY, s.width, 1), Paint()..color = const Color(0x132B91A5));
    _label(x, 'WORLD SCAN / CARTOGRAPHIC TELEMETRY', Offset(28, s.height - 72), 5.5, const Color(0x4DFFFFFF), 2.2);
    _label(x, 'MAPPED  $mapped     VISITS  $visits     TARGET  $selected', Offset(28, s.height - 56), 5, const Color(0x3EADC2C9), 1.55);
    _label(x, 'SPATIAL FIELD  /  LIVE', Offset(s.width - 148, 34), 4.5, const Color(0x32B9CBD1), 1.6);
    _label(x, '01', c + Offset(-5, r + 18), 4.5, const Color(0x45FFFFFF), 1.4);
  }
  void _label(Canvas x, String text, Offset p, double size, Color color, double spacing) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, letterSpacing: spacing)), textDirection: TextDirection.ltr)..layout(maxWidth: 360);
    tp.paint(x, p);
  }
  @override bool shouldRepaint(covariant _WorldScanPainter o) => o.t != t || o.selected != selected || o.mapped != mapped || o.visits != visits;
}
