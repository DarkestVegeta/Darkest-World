import 'dart:math' as math;

import 'package:flutter/material.dart';

class IdentityWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const IdentityWorldPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<IdentityWorldPage> createState() => _IdentityWorldPageState();
}

class _IdentityWorldPageState extends State<IdentityWorldPage> {
  int? selected;

  static const regions = <_IdentityRegion>[
    _IdentityRegion('DARKestVEGETA', 'The core identity behind the DarkestWorld universe.'),
    _IdentityRegion('STREAMING', 'The streamer identity, marathon concept and live presence.'),
    _IdentityRegion('COLLECTION', 'Personal interests, archives and the things that shape the world.'),
    _IdentityRegion('CREATIVE', 'Visual identity, concepts and the creative side of DarkestWorld.'),
  ];

  @override
  Widget build(BuildContext context) {
    final active = selected == null ? null : regions[selected!];
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _IdentitySpacePainter())),
          SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  left: 28,
                  top: 20,
                  child: Text('DARKEST-IDENTITY', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 4)),
                ),
                Positioned.fill(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = math.min(constraints.maxWidth * .68, constraints.maxHeight * .72);
                        return SizedBox(
                          width: size,
                          height: size,
                          child: GestureDetector(
                            onTapUp: (details) => _selectFromPoint(details.localPosition, size),
                            child: CustomPaint(
                              painter: _IdentityPlanetPainter(selected: selected),
                              foregroundPainter: _IdentityRegionPainter(regions.length, selected: selected),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (active != null)
                  Positioned(
                    left: 28,
                    bottom: 28,
                    child: _SelectionPanel(
                      region: active,
                      onClose: () => setState(() => selected = null),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectFromPoint(Offset point, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > size * .47) return;

    final angle = (math.atan2(dy, dx) + math.pi * 2) % (math.pi * 2);
    final index = ((angle / (math.pi * 2)) * regions.length).floor() % regions.length;
    setState(() => selected = selected == index ? null : index);
  }
}

class _IdentityRegion {
  final String title;
  final String description;
  const _IdentityRegion(this.title, this.description);
}

class _SelectionPanel extends StatelessWidget {
  final _IdentityRegion region;
  final VoidCallback onClose;
  const _SelectionPanel({required this.region, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF070A12).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF788DB5).withValues(alpha: .22)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(region.title, style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Text(region.description, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 12, height: 1.4)),
              const SizedBox(height: 12),
              Text('ENTER', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 10, letterSpacing: 3)),
            ]),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17, color: Colors.white54)),
        ],
      ),
    );
  }
}

class _IdentitySpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF0C1020), Color(0xFF03050B), Color(0xFF010207)]).createShader(Offset.zero & size));
    final random = math.Random(42);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 230; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final r = .35 + random.nextDouble() * 1.15;
      canvas.drawCircle(p, r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IdentityPlanetPainter extends CustomPainter {
  final int? selected;
  const _IdentityPlanetPainter({this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .46;
    canvas.drawCircle(center, radius * 1.07, Paint()..shader = RadialGradient(colors: [const Color(0xFF697FAE).withValues(alpha: .14), Colors.transparent], stops: const [.55, 1]).createShader(Rect.fromCircle(center: center, radius: radius * 1.07)));
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(-.25, -.28), radius: 1, colors: const [Color(0xFF465A82), Color(0xFF1B2740), Color(0xFF080D18), Color(0xFF02040A)], stops: [.0, .34, .72, 1]).createShader(Rect.fromCircle(center: center, radius: radius)));

    final terrain = Paint()..color = const Color(0xFF91A0BD).withValues(alpha: .12);
    for (var i = 0; i < 13; i++) {
      final a = i * .91;
      final p = Offset(center.dx + math.cos(a) * radius * .46, center.dy + math.sin(a) * radius * .36);
      canvas.drawOval(Rect.fromCenter(center: p, width: radius * (.18 + (i % 3) * .08), height: radius * (.08 + (i % 2) * .05)), terrain);
    }

    final shade = Paint()..shader = RadialGradient(center: const Alignment(-.2, -.15), radius: 1, colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .62)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shade);
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = const Color(0xFF9AAED0).withValues(alpha: .32));

    final divider = Paint()..color = Colors.white.withValues(alpha: .10)..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(center, Offset(center.dx + math.cos(a) * radius * .91, center.dy + math.sin(a) * radius * .91), divider);
    }
  }

  @override
  bool shouldRepaint(covariant _IdentityPlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _IdentityRegionPainter extends CustomPainter {
  final int count;
  final int? selected;
  const _IdentityRegionPainter(this.count, {this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .36;
    final labelPaint = Paint();
    for (var i = 0; i < count; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      final p = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      final active = selected == i;
      canvas.drawCircle(p, active ? 6 : 4, labelPaint..color = (active ? const Color(0xFFB9C8E5) : Colors.white).withValues(alpha: active ? .85 : .28));
    }
  }

  @override
  bool shouldRepaint(covariant _IdentityRegionPainter oldDelegate) => oldDelegate.selected != selected;
}
