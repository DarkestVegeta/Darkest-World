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
  Offset pointer = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final px = ((pointer.dx / math.max(1, w)) - .5).clamp(-.5, .5).toDouble();
        final py = ((pointer.dy / math.max(1, h)) - .5).clamp(-.5, .5).toDouble();
        return MouseRegion(
          onHover: (event) => setState(() => pointer = event.localPosition),
          onExit: (_) => setState(() => pointer = Offset.zero),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _EnvironmentPainter(widget.phase))),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0012)
                  ..rotateX(py * -.06)
                  ..rotateY(px * .08 + math.sin(widget.phase * math.pi * 2) * .008),
                child: _Case(width: w * (widget.compact ? .72 : .64), height: h * .78, imageUrl: widget.imageUrl, title: widget.title),
              ),
              Positioned(top: 10, left: 10, child: _Badge('ARTBOX / 3D')),
              Positioned(top: 10, right: 10, child: _Badge(widget.imageUrl == null ? 'SOURCE PENDING' : 'FULL CASE')),
            ],
          ),
        );
      },
    );
  }
}

class _Case extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final String title;
  const _Case({required this.width, required this.height, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final content = imageUrl == null
        ? Center(child: Text(title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, letterSpacing: 1.4, color: Color(0x778F82A9))))
        : Image.network(imageUrl!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(title.toUpperCase(), textAlign: TextAlign.center)));
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xE60A0B14),
        border: Border.all(color: const Color(0x667F70B0)),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 38, offset: Offset(12, 20))],
      ),
      child: Stack(children: [
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: const Color(0x1EFFFFFF))))),
        Center(child: content),
        Positioned(right: 2, top: 8, bottom: 8, width: 5, child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x2A9B8EB0), borderRadius: BorderRadius.circular(2)))),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xCC05060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.7, color: Color(0x667F8AA2)))));
}

class _EnvironmentPainter extends CustomPainter {
  final double phase;
  const _EnvironmentPainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.15), radius: 1.15, colors: [Color(0xFF241D34), Color(0xFF0A0A12), Color(0xFF010207)]).createShader(rect));
    final center = Offset(size.width * .5, size.height * .48);
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x1C8C7DA8);
    for (var i = 0; i < 6; i++) {
      final width = size.width * (.3 + i * .1);
      canvas.drawOval(Rect.fromCenter(center: center, width: width, height: width * .2), ring);
    }
    final sweep = (phase * math.pi * 2) % (math.pi * 2);
    canvas.drawArc(Rect.fromCenter(center: center, width: size.width * .82, height: size.width * .25), sweep, .65, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x4A8C82A5));
    final random = math.Random(2246);
    for (var i = 0; i < 180; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(p, .25 + random.nextDouble() * .65, Paint()..color = Colors.white.withValues(alpha: .025 + random.nextDouble() * .08));
    }
    final scan = (phase * size.height * 1.2) % (size.height + 100) - 50;
    canvas.drawRect(Rect.fromLTWH(0, scan, size.width, 1), Paint()..color = const Color(0x127F70B0));
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment.center, radius: 1.1, colors: [Color(0x00000000), Color(0xA8000000)]).createShader(rect));
  }
  @override
  bool shouldRepaint(covariant _EnvironmentPainter oldDelegate) => oldDelegate.phase != phase;
}
