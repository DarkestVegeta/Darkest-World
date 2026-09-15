import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestWorldArtbox extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final double phase;
  final bool compact;
  const DarkestWorldArtbox({super.key, required this.imageUrl, required this.title, required this.phase, this.compact = false});
  @override State<DarkestWorldArtbox> createState() => _DarkestWorldArtboxState();
}

class _DarkestWorldArtboxState extends State<DarkestWorldArtbox> {
  Offset _pointer = Offset.zero;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final double w = box.maxWidth;
    final double h = box.maxHeight;
    final double px = (_pointer.dx / math.max(1.0, w) - .5).clamp(-.5, .5).toDouble();
    final double py = (_pointer.dy / math.max(1.0, h) - .5).clamp(-.5, .5).toDouble();
    final double tiltX = py * -.065;
    final double tiltY = px * .085 + math.sin(widget.phase * math.pi * 2) * .009;
    final double caseWidth = w * (widget.compact ? .64 : .58);
    final double artWidth = w * (widget.compact ? .73 : .67);
    return MouseRegion(
      onHover: (e) => setState(() => _pointer = e.localPosition),
      onExit: (_) => setState(() => _pointer = Offset.zero),
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(child: CustomPaint(painter: _ArtboxEnvironmentPainter(widget.phase))),
        Positioned(left: w * .15, right: w * .15, bottom: h * .11, height: h * .12, child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.black.withValues(alpha: .54), boxShadow: const [BoxShadow(blurRadius: 34, spreadRadius: 5, color: Colors.black)]))),
        Positioned(left: w * .18, right: w * .18, bottom: h * .045, height: h * .18, child: IgnorePointer(child: Opacity(opacity: .13, child: Transform.scale(scaleY: -.28, child: _image())))),
        Transform(alignment: Alignment.center, transform: Matrix4.identity()..setEntry(3, 2, .0013)..rotateX(tiltX)..rotateY(tiltY), child: Stack(alignment: Alignment.center, children: [
          Container(width: caseWidth, height: h * .78, decoration: BoxDecoration(color: const Color(0x0EFFFFFF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x287F70B0)), boxShadow: [BoxShadow(color: const Color(0xFF3F315F).withValues(alpha: .25), blurRadius: 42, spreadRadius: 3)])),
          SizedBox(width: artWidth, height: h * .82, child: _image()),
          Positioned(right: 0, top: h * .08, bottom: h * .08, width: 7, child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x309789AE), borderRadius: BorderRadius.circular(3)))),
        ])),
        Positioned(top: 10, left: 10, child: _badge('ARTBOX / 3D')),
        Positioned(top: 10, right: 10, child: _badge('TRANSPARENT')),
        Positioned(bottom: 10, left: 10, child: _badge(widget.imageUrl == null ? 'SOURCE PENDING' : 'FULL CASE PRESERVED')),
        Positioned(bottom: 10, right: 10, child: _badge('PARALLAX ACTIVE')),
        if (widget.imageUrl == null) Center(child: Text(widget.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, letterSpacing: 2, color: Color(0x668F82A9)))),
      ]),
  });

  Widget _image() => widget.imageUrl == null
      ? const SizedBox.shrink()
      : Image.network(widget.imageUrl!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(widget.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: Color(0x557F8AA2)))));

  Widget _badge(String text) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xCC05060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x667F8AA2)))));
}

class _ArtboxEnvironmentPainter extends CustomPainter {
  final double phase;
  const _ArtboxEnvironmentPainter(this.phase);
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()..shader = const RadialGradient(center: Alignment(0, -.18), radius: 1.12, colors: [Color(0xFF241D34), Color(0xFF0A0A12), Color(0xFF010207)]).createShader(r));
    final center = Offset(s.width * .5, s.height * .47);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x1C8C7DA8);
    for (var i = 0; i < 6; i++) { final ww = s.width * (.28 + i * .105); c.drawOval(Rect.fromCenter(center: center, width: ww, height: ww * .22), p); }
    final sweep = (phase * math.pi * 2) % (math.pi * 2);
    c.drawArc(Rect.fromCenter(center: center, width: s.width * .84, height: s.width * .26), sweep, .58, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.15..color = const Color(0x5A8C82A5));
    final rnd = math.Random(2246);
    for (var i = 0; i < 260; i++) { final x = rnd.nextDouble() * s.width; final y = rnd.nextDouble() * s.height; final d = .2 + rnd.nextDouble(); c.drawCircle(Offset(x, y), .2 + d * .75, Paint()..color = Colors.white.withValues(alpha: .018 + d * .12)); }
    final scan = (phase * s.height * 1.2) % (s.height + 100) - 50;
    c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x127F70B0));
    c.drawCircle(center, s.width * .12, Paint()..shader = const RadialGradient(colors: [Color(0x267F70B0), Color(0x00000000)]).createShader(Rect.fromCircle(center: center, radius: s.width * .12)));
    c.drawRect(r, Paint()..shader = RadialGradient(center: Alignment.center, radius: 1.12, colors: [const Color(0x00000000), const Color(0xA8000000)]).createShader(r));
  }
  @override bool shouldRepaint(covariant _ArtboxEnvironmentPainter old) => old.phase != phase;
}
