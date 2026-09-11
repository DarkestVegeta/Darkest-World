import 'dart:math' as math;
import 'package:flutter/material.dart';

class CreationWorldPage extends StatefulWidget {
  const CreationWorldPage({super.key});

  @override
  State<CreationWorldPage> createState() => _CreationWorldPageState();
}

class _CreationWorldPageState extends State<CreationWorldPage> {
  int? _selected;
  int? _hovered;

  static const _regions = <_CreationRegion>[
    _CreationRegion('ART', 'Visual work, designs and the things created by hand.'),
    _CreationRegion('WORLDS', 'DarkestWorld itself, its places, ideas and experiences.'),
    _CreationRegion('PROJECTS', 'Larger builds, concepts and projects taking shape over time.'),
    _CreationRegion('EXPERIMENTS', 'Ideas, tests and strange concepts that may become something more.'),
    _CreationRegion('CREATE YOUR WORLD', 'A viewer-facing world-building experience. This belongs to the audience, not to the core of Creation.'),
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
            onHover: (event) => _updateHover(event.localPosition, center, size),
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
                    onTapDown: (details) => _selectAt(details.localPosition, size),
                    child: CustomPaint(
                      painter: _CreationPlanetPainter(
                        regions: _regions,
                        selected: _selected,
                        hovered: _hovered,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 26,
                  child: _Header(),
                ),
                if (_selected != null)
                  Positioned(
                    left: 28,
                    bottom: 28,
                    child: _SelectionPanel(
                      region: _regions[_selected!],
                      onClose: () => setState(() => _selected = null),
                    ),
                  ),
                Positioned(
                  right: 28,
                  bottom: 28,
                  child: const Text(
                    'CREATION-WORLD',
                    style: TextStyle(
                      color: Color(0x99D8D5EA),
                      fontSize: 11,
                      letterSpacing: 3.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateHover(Offset position, Offset center, double size) {
    final local = position - Offset(center.dx - size / 2, center.dy - size / 2);
    final next = _regionAt(local, size);
    if (next != _hovered) setState(() => _hovered = next);
  }

  void _selectAt(Offset local, double size) {
    final next = _regionAt(local, size);
    if (next != null) setState(() => _selected = _selected == next ? null : next);
  }

  int? _regionAt(Offset local, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = (local.dx - center.dx) / (size / 2);
    final dy = (local.dy - center.dy) / (size / 2);
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > 1) return null;
    final angle = math.atan2(dy, dx);
    final normalized = (angle + math.pi * 2) % (math.pi * 2);
    final sectors = <double>[
      -math.pi * .82,
      -math.pi * .28,
      math.pi * .22,
      math.pi * .72,
      math.pi * 1.12,
    ];
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < sectors.length; i++) {
      final target = (sectors[i] + math.pi * 2) % (math.pi * 2);
      var difference = (normalized - target).abs();
      difference = math.min(difference, math.pi * 2 - difference);
      if (difference < bestDistance) {
        bestDistance = difference;
        best = i;
      }
    }
    return distance < .94 && bestDistance < .42 ? best : null;
  }
}

class _CreationRegion {
  final String title;
  final String description;
  const _CreationRegion(this.title, this.description);
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CREATION', style: TextStyle(color: Color(0xFFE5E1F0), fontSize: 18, letterSpacing: 5, fontWeight: FontWeight.w600)),
          SizedBox(height: 7),
          Text('ART • WORLDS • PROJECTS • EXPERIMENTS', style: TextStyle(color: Color(0x887F7895), fontSize: 9, letterSpacing: 2.2)),
        ],
      );
}

class _SelectionPanel extends StatelessWidget {
  final _CreationRegion region;
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
    final paint = Paint()..color = const Color(0xFF010105);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(31);
    final stars = Paint()..color = const Color(0x559C96B0);
    for (var i = 0; i < 230; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = .35 + random.nextDouble() * 1.15;
      canvas.drawCircle(Offset(x, y), r, stars);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreationPlanetPainter extends CustomPainter {
  final List<_CreationRegion> regions;
  final int? selected;
  final int? hovered;

  _CreationPlanetPainter({required this.regions, this.selected, this.hovered});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .47;

    final halo = Paint()..shader = RadialGradient(colors: [const Color(0x332F2948), const Color(0x00110F1D)]).createShader(Rect.fromCircle(center: center, radius: radius * 1.16));
    canvas.drawCircle(center, radius * 1.16, halo);

    final sphere = Paint()..shader = RadialGradient(center: const Alignment(-.34, -.28), radius: 1.08, colors: const [Color(0xFF65607A), Color(0xFF343143), Color(0xFF171621), Color(0xFF08080E)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sphere);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final terrain = Paint()..style = PaintingStyle.fill;
    final blobs = <Offset>[const Offset(-.32, -.22), const Offset(.24, -.30), const Offset(.37, .18), const Offset(-.24, .34), const Offset(.02, .04)];
    for (var i = 0; i < blobs.length; i++) {
      terrain.color = Color.fromARGB(55, 145, 137, 164);
      final p = center + Offset(blobs[i].dx * radius, blobs[i].dy * radius);
      canvas.drawOval(Rect.fromCenter(center: p, width: radius * (.55 + i * .035), height: radius * (.24 + (i % 2) * .08)), terrain);
    }

    final divider = Paint()..color = const Color(0x334E485D)..strokeWidth = 1.2;
    canvas.drawLine(center + Offset(-radius, radius * .08), center + Offset(radius, -radius * .18), divider);
    canvas.drawLine(center + Offset(-radius * .18, -radius), center + Offset(radius * .22, radius), divider);

    final positions = <Offset>[
      center + Offset(-radius * .34, -radius * .35),
      center + Offset(radius * .34, -radius * .30),
      center + Offset(radius * .34, radius * .30),
      center + Offset(-radius * .30, radius * .32),
      center + Offset(radius * .02, radius * .02),
    ];

    for (var i = 0; i < regions.length; i++) {
      final active = selected == i || hovered == i;
      final dim = selected != null && selected != i;
      final textColor = dim ? const Color(0x447E788E) : const Color(0xD8E2DEEA);
      final glow = Paint()..color = active ? const Color(0x334E456C) : const Color(0x00101010);
      canvas.drawCircle(positions[i], radius * (active ? .105 : .075), glow);
      final tp = TextPainter(text: TextSpan(text: regions[i].title, style: TextStyle(color: textColor, fontSize: i == 4 ? 8 : 10, letterSpacing: i == 4 ? 1.0 : 2.0, fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout(maxWidth: radius * .42);
      tp.paint(canvas, positions[i] - Offset(tp.width / 2, tp.height / 2));
    }

    final shadow = Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0x00000000), Color(0xAA000000)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shadow);
    canvas.restore();

    final edge = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = const Color(0x775E5870);
    canvas.drawCircle(center, radius, edge);
    final rim = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = const Color(0x223B3551);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius + 2), math.pi * 1.08, math.pi * .82, false, rim);
  }

  @override
  bool shouldRepaint(covariant _CreationPlanetPainter oldDelegate) => selected != oldDelegate.selected || hovered != oldDelegate.hovered;
}
