import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldArchiveStage extends StatefulWidget {
  const DarkestWorldArchiveStage({super.key});
  @override State<DarkestWorldArchiveStage> createState() => _DarkestWorldArchiveStageState();
}
class _DarkestWorldArchiveStageState extends State<DarkestWorldArchiveStage> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 96))..repeat();
  final session = GalaxyNavigationSession.instance;
  @override void initState() { super.initState(); session.addListener(_changed); }
  @override void dispose() { session.removeListener(_changed); clock.dispose(); super.dispose(); }
  void _changed() { if (mounted) setState(() {}); }
  @override Widget build(BuildContext context) {
    final nav = session.contentNavigation;
    if (nav == null || nav.source != 'archive') return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 760;
    return IgnorePointer(child: AnimatedBuilder(animation: clock, builder: (_, __) => CustomPaint(painter: _ArchiveStagePainter(clock.value, compact, nav.current.title, nav.previous?.title, nav.next?.title, nav.related.length), size: Size.infinite)));
  }
}
class _ArchiveStagePainter extends CustomPainter {
  final double phase; final bool compact; final String title; final String? previous; final String? next; final int relatedCount;
  const _ArchiveStagePainter(this.phase, this.compact, this.title, this.previous, this.next, this.relatedCount);
  @override void paint(Canvas c, Size s) {
    final shortest = math.min(s.width, s.height);
    final center = Offset(s.width * .5, s.height * (compact ? .47 : .49));
    final core = shortest * (compact ? .205 : .235);
    final t = phase * math.pi * 2;
    _drawDepthField(c, s, t); _drawVaultRings(c, center, core, t); _drawArchiveCore(c, center, core, t); _drawCasePedestal(c, s, center, core, t); _drawSelectionBrackets(c, center, core, t); _drawTelemetry(c, s, center, core); _drawTitle(c, center, core); _drawScanline(c, s, phase);
  }
  void _drawDepthField(Canvas c, Size s, double t) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = RadialGradient(center: const Alignment(0, -.05), radius: 1.18, colors: const [Color(0x120F1630), Color(0x06131A31), Color(0x3D000005)]).createShader(rect));
    final rng = math.Random(21107);
    for (var i = 0; i < 260; i++) { final depth = .22 + rng.nextDouble() * .78; final x = rng.nextDouble() * s.width; final y = rng.nextDouble() * s.height; final drift = math.sin(t * (.35 + depth) + i) * (1.2 + depth * 2.8); final radius = .25 + depth * 1.05; c.drawCircle(Offset(x + drift, y), radius, Paint()..color = Colors.white.withValues(alpha: .018 + depth * .055)); }
    final haze = Rect.fromCenter(center: Offset(s.width * .5, s.height * .47), width: s.width * .82, height: s.height * .68);
    c.drawOval(haze, Paint()..shader = RadialGradient(colors: const [Color(0x0C8B78A8), Color(0x00000000)]).createShader(haze));
  }
  void _drawVaultRings(Canvas c, Offset center, double core, double t) {
    for (var i = 0; i < 6; i++) { final scale = 1.18 + i * .255; final width = core * (2.35 + i * .27); final height = core * (.58 + i * .045); final phaseOffset = (i.isEven ? 1 : -1) * t * (.018 + i * .002); c.save(); c.translate(center.dx, center.dy); c.rotate(phaseOffset); c.translate(-center.dx, -center.dy); c.drawOval(Rect.fromCenter(center: center, width: width * scale, height: height * scale), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 0 ? 1.1 : .55..color = Color.lerp(const Color(0x238E7FA7), const Color(0x086A8BA4), i / 6)!); c.restore(); }
    final sweepRect = Rect.fromCenter(center: center, width: core * 5.6, height: core * 1.75);
    c.drawArc(sweepRect, t, .72, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeCap = StrokeCap.round..color = const Color(0x5C9F8FBC));
    c.drawArc(sweepRect, t + math.pi, .22, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x30799FB2));
  }
  void _drawArchiveCore(Canvas c, Offset center, double r, double t) {
    final halo = Rect.fromCircle(center: center, radius: r * 1.62);
    c.drawCircle(center, r * 1.62, Paint()..shader = RadialGradient(colors: const [Color(0x2C8875AA), Color(0x0B273047), Colors.transparent], stops: const [.0, .48, 1]).createShader(halo));
    final sphere = Rect.fromCircle(center: center, radius: r);
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.36, -.52), radius: 1.08, colors: const [Color(0xFFD1C4D9), Color(0xFF766C82), Color(0xFF34313E), Color(0xFF090A0F)], stops: const [.0, .28, .67, 1]).createShader(sphere));
    c.save(); c.clipPath(Path()..addOval(sphere));
    for (var i = 0; i < 16; i++) { final y = center.dy - r * .76 + i * r * .102; final wave = math.sin(t * .6 + i * .72) * r * .014; c.drawLine(Offset(center.dx - r * .95, y + wave), Offset(center.dx + r * .95, y - wave), Paint()..strokeWidth = i % 4 == 0 ? .9 : .45..color = const Color(0x245B5369)); }
    for (var i = 0; i < 20; i++) { final a = i * math.pi * 2 / 20 + t * .035; final latitude = math.sin(i * 1.71) * r * .58; final x = center.dx + math.cos(a) * r * .78; final y = center.dy + math.sin(a) * r * .62; c.drawCircle(Offset(x, y), r * (.008 + (i % 4) * .003), Paint()..color = const Color(0x4A9E91A9)); c.drawLine(Offset(center.dx + math.cos(a) * r * .82, center.dy + latitude * .2), Offset(x, y), Paint()..strokeWidth = .35..color = const Color(0x1F9E91A9)); }
    final lightSweep = Rect.fromCenter(center: Offset(center.dx - r * .26, center.dy - r * .32), width: r * 1.05, height: r * .75);
    c.drawOval(lightSweep, Paint()..shader = RadialGradient(colors: const [Color(0x4CD8D0DF), Color(0x00000000)]).createShader(lightSweep)); c.restore();
    c.drawCircle(center, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.25..color = const Color(0x7ABDB1C9));
    c.drawCircle(center, r * 1.045, Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0x349D8CB8));
    for (var i = 0; i < 3; i++) { final rr = r * (1.12 + i * .075); c.drawArc(Rect.fromCircle(center: center, radius: rr), t * (i.isEven ? .35 : -.28) + i, .78, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = Color(0x3A9B8AB7)); }
  }
  void _drawCasePedestal(Canvas c, Size s, Offset center, double r, double t) {
    if (compact) return; final y = center.dy + r * 1.55; final left = center.dx - r * 2.05; final right = center.dx + r * 2.05; final top = y - r * .12; final bottom = y + r * .42;
    final front = Path()..moveTo(left, top)..lineTo(right, top)..lineTo(right - r * .24, bottom)..lineTo(left + r * .24, bottom)..close();
    c.drawPath(front, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Color(0x351A1B26), Color(0x1507070B)]).createShader(Rect.fromLTRB(left, top, right, bottom)));
    c.drawPath(front, Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x315C536A));
    for (var i = 0; i < 9; i++) { final x = left + (right - left) * (i + .5) / 9; c.drawLine(Offset(x, top + 3), Offset(x - r * .06, bottom - 4), Paint()..strokeWidth = .45..color = const Color(0x183E3A48)); }
    final glowX = center.dx + math.sin(t) * r * .45; c.drawLine(Offset(glowX - r * .7, bottom + 2), Offset(glowX + r * .7, bottom + 2), Paint()..strokeWidth = 1.0..color = const Color(0x4D8E80AA));
  }
  void _drawSelectionBrackets(Canvas c, Offset center, double r, double t) {
    final rr = r * 1.34; final pulse = .75 + math.sin(t * 1.5) * .12; final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.square..color = Color(0x66B8A9C5).withValues(alpha: pulse);
    const arc = .34; for (var i = 0; i < 4; i++) { final start = i * math.pi / 2 + .08; c.drawArc(Rect.fromCircle(center: center, radius: rr), start, arc, false, p); }
    final marker = r * .105; for (var i = 0; i < 4; i++) { final a = i * math.pi / 2 + .25; final p0 = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr); final p1 = Offset(center.dx + math.cos(a) * (rr + marker), center.dy + math.sin(a) * (rr + marker)); c.drawLine(p0, p1, p); }
  }
  void _drawTelemetry(Canvas c, Size s, Offset center, double r) {
    if (compact) return; final y = center.dy - r * 1.52; final left = center.dx - r * 2.2; final right = center.dx + r * 2.2;
    c.drawLine(Offset(left, y), Offset(right, y), Paint()..strokeWidth = .55..color = const Color(0x273E4352));
    _text(c, 'ARCHIVE WORLD', Offset(left, y - 18), 7, const Color(0x8EA99BB7), 2.5); _text(c, 'PHYSICAL MEDIA / DEPTH STAGE', Offset(left, y - 6), 5, const Color(0x557F8797), 1.8); _text(c, 'RELATED ${relatedCount.toString().padLeft(2, '0')}', Offset(right - 74, y - 18), 6, const Color(0x687F8797), 2.0); _text(c, 'VOLUME LOCK  /  STABLE', Offset(right - 124, y - 6), 5, const Color(0x4F7F8797), 1.6);
  }
  void _drawTitle(Canvas c, Offset center, double r) {
    final current = _short(title); final previousText = previous == null ? '—' : _short(previous!); final nextText = next == null ? '—' : _short(next!); final titleY = center.dy + r * (compact ? 1.08 : 1.12);
    _centerText(c, current, Offset(center.dx, titleY), compact ? 8.5 : 10.5, const Color(0xD8F1ECF4), compact ? 2.4 : 3.2); _centerText(c, 'CURRENT  /  ARCHIVE CORE', Offset(center.dx, titleY + (compact ? 15 : 19)), 5.5, const Color(0x607F7A88), 2.0);
    if (!compact) { _text(c, 'PREVIOUS', Offset(center.dx - r * 2.0, titleY + 3), 5, const Color(0x4F8D8497), 1.7); _text(c, previousText, Offset(center.dx - r * 2.0, titleY + 14), 6, const Color(0x789A92A3), 1.0); _text(c, 'NEXT', Offset(center.dx + r * 1.63, titleY + 3), 5, const Color(0x4F8D8497), 1.7); _text(c, nextText, Offset(center.dx + r * 1.63, titleY + 14), 6, const Color(0x789A92A3), 1.0); }
  }
  void _drawScanline(Canvas c, Size s, double p) { final y = (p * s.height * 1.25) % (s.height + 30) - 15; c.drawRect(Rect.fromLTWH(0, y, s.width, 1), Paint()..color = const Color(0x0A8FAFC0)); }
  void _text(Canvas c, String text, Offset offset, double size, Color color, double spacing) { final tp = TextPainter(text: TextSpan(text: text.toUpperCase(), style: TextStyle(color: color, fontSize: size, letterSpacing: spacing, fontWeight: FontWeight.w400)), textDirection: TextDirection.ltr)..layout(); tp.paint(c, offset); }
  void _centerText(Canvas c, String text, Offset center, double size, Color color, double spacing) { final tp = TextPainter(text: TextSpan(text: text.toUpperCase(), style: TextStyle(color: color, fontSize: size, letterSpacing: spacing, fontWeight: FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: sMaxWidth(center.dx)); tp.paint(c, Offset(center.dx - tp.width / 2, center.dy)); }
  double sMaxWidth(double x) => math.max(120, x * 1.8);
  String _short(String value) { final clean = value.trim(); if (clean.length <= 34) return clean; return '${clean.substring(0, 31)}...'; }
  @override bool shouldRepaint(covariant _ArchiveStagePainter old) => old.phase != phase || old.compact != compact || old.title != title || old.previous != previous || old.next != next || old.relatedCount != relatedCount;
}
