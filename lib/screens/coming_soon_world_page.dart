import 'dart:math' as math;
import 'package:flutter/material.dart';

class ComingSoonWorldPage extends StatefulWidget {
  const ComingSoonWorldPage({super.key});

  @override
  State<ComingSoonWorldPage> createState() => _ComingSoonWorldPageState();
}

class _ComingSoonWorldPageState extends State<ComingSoonWorldPage> {
  int? _selected;
  int? _hovered;

  static const _regions = <_FutureRegion>[
    _FutureRegion('NEXT WORLDS', 'Worlds that are planned but not yet opened.'),
    _FutureRegion('NEW FEATURES', 'New systems and experiences that will be added over time.'),
    _FutureRegion('EXPANSION', 'Larger parts of DarkestWorld waiting for their place in the galaxy.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight) * .74;
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * .48);
          return MouseRegion(
            onHover: (event) => _setHover(event.localPosition, center, size),
            onExit: (_) => setState(() => _hovered = null),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _SpacePainter())),
                Positioned(
                  left: center.dx - size / 2,
                  top: center.dy - size / 2,
                  width: size,
                  height: size,
                  child: GestureDetector(
                    onTapDown: (details) => _select(details.localPosition, size),
                    child: CustomPaint(painter: _FuturePlanetPainter(regions: _regions, selected: _selected, hovered: _hovered)),
                  ),
                ),
                const Positioned(left: 28, top: 26, child: _Header()),
                if (_selected != null)
                  Positioned(left: 28, bottom: 28, child: _SelectionPanel(region: _regions[_selected!], onClose: () => setState(() => _selected = null))),
                const Positioned(
                  right: 28,
                  bottom: 28,
                  child: Text('COMING SOON', style: TextStyle(color: Color(0x99D8D5EA), fontSize: 11, letterSpacing: 3.2)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _setHover(Offset position, Offset center, double size) {
    final local = position - Offset(center.dx - size / 2, center.dy - size / 2);
    final next = _regionAt(local, size);
    if (next != _hovered) setState(() => _hovered = next);
  }

  void _select(Offset local, double size) {
    final next = _regionAt(local, size);
    if (next != null) setState(() => _selected = _selected == next ? null : next);
  }

  int? _regionAt(Offset local, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = (local.dx - center.dx) / (size / 2);
    final dy = (local.dy - center.dy) / (size / 2);
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > 1) return null;
    final angle = (math.atan2(dy, dx) + math.pi * 2) % (math.pi * 2);
    const targets = <double>[-math.pi * .85, math.pi * .05, math.pi * .85];
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < targets.length; i++) {
      var difference = (angle - ((targets[i] + math.pi * 2) % (math.pi * 2))).abs();
      difference = math.min(difference, math.pi * 2 - difference);
      if (difference < bestDistance) {
        bestDistance = difference;
        best = i;
      }
    }
    return distance < .94 && bestDistance < .55 ? best : null;
  }
}

class _FutureRegion {
  final String title;
  final String description;
  const _FutureRegion(this.title, this.description);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMING SOON', style: TextStyle(color: Color(0xFFE5E1F0), fontSize: 18, letterSpacing: 5, fontWeight: FontWeight.w600)),
          SizedBox(height: 7),
          Text('NOT YET OPEN • STILL BECOMING', style: TextStyle(color: Color(0x887F7895), fontSize: 9, letterSpacing: 2.2)),
        ],
      );
}

class _SelectionPanel extends StatelessWidget {
  final _FutureRegion region;
  final VoidCallback onClose;
  const _SelectionPanel({required this.region, required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
        width: 390,
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
        decoration: BoxDecoration(
          color: const Color(0xE6090911),
          border: Border.all(color: const Color(0x555D5675)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(region.title, style: const TextStyle(color: Color(0xFFE8E4F1), fontSize: 14, letterSpacing: 2.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(region.description, style: const TextStyle(color: Color(0xAAABA5B9), fontSize: 11, height: 1.35)),
                ],
              ),
            ),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17, color: Color(0x887F7895))),
          ],
        ),
      );
}

class _SpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010105));
    final random = math.Random(91);
    final stars = Paint()..color = const Color(0x559C96B0);
    for (var i = 0; i < 230; i++) {
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .35 + random.nextDouble() * 1.15, stars);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FuturePlanetPainter extends CustomPainter {
  final List<_FutureRegion> regions;
  final int? selected;
  final int? hovered;

  _FuturePlanetPainter({required this.regions, this.selected, this.hovered});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .47;
    canvas.drawCircle(center, radius * 1.16, Paint()..shader = RadialGradient(colors: const [Color(0x332E2940), Color(0x00110F1D)]).createShader(Rect.fromCircle(center: center, radius: radius * 1.16)));
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(-.34, -.28), radius: 1.08, colors: const [Color(0xFF605A70), Color(0xFF322E3B), Color(0xFF17151D), Color(0xFF08080D)]).createShader(Rect.fromCircle(center: center, radius: radius)));

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    final terrain = Paint()..color = const Color(0x354D485A);
    final blobs = <Offset>[const Offset(-.32, -.24), const Offset(.27, -.28), const Offset(.34, .18), const Offset(-.28, .31), const Offset(.03, .03)];
    for (var i = 0; i < blobs.length; i++) {
      final p = center + Offset(blobs[i].dx * radius, blobs[i].dy * radius);
      canvas.drawOval(Rect.fromCenter(center: p, width: radius * (.52 + i * .04), height: radius * (.22 + (i % 2) * .08)), terrain);
    }

    final divider = Paint()..color = const Color(0x334E485D)..strokeWidth = 1.2;
    canvas.drawLine(center + Offset(-radius, radius * .04), center + Offset(radius, -radius * .15), divider);
    canvas.drawLine(center + Offset(-radius * .18, -radius), center + Offset(radius * .22, radius), divider);

    final positions = <Offset>[
      center + Offset(-radius * .34, -radius * .30),
      center + Offset(radius * .35, -radius * .03),
      center + Offset(-radius * .05, radius * .34),
    ];
    for (var i = 0; i < regions.length; i++) {
      final active = selected == i || hovered == i;
      final dim = selected != null && selected != i;
      final textColor = dim ? const Color(0x447E788E) : const Color(0xD8E2DEEA);
      canvas.drawCircle(positions[i], radius * (active ? .11 : .075), Paint()..color = active ? const Color(0x334E456C) : const Color(0x00101010));
      final tp = TextPainter(text: TextSpan(text: regions[i].title, style: TextStyle(color: textColor, fontSize: 9.5, letterSpacing: 1.5, fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout(maxWidth: radius * .43);
      tp.paint(canvas, positions[i] - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(center, radius, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0x00000000), Color(0xAA000000)]).createShader(Rect.fromCircle(center: center, radius: radius)));
    canvas.restore();
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = const Color(0x775E5870));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius + 2), math.pi * 1.08, math.pi * .82, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = const Color(0x223B3551));
  }

  @override
  bool shouldRepaint(covariant _FuturePlanetPainter oldDelegate) => selected != oldDelegate.selected || hovered != oldDelegate.hovered;
}
