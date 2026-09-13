import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;
  const GalaxyWorld({required this.kind, required this.title, required this.description});
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  GalaxyWorldKind? selected;
  double orbit = 0;
  double zoom = 1;
  bool systemMap = false;
  bool labels = true;

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    GalaxyWorld? current;
    for (final world in widget.worlds) {
      if (world.kind == selected) current = world;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: GestureDetector(
        onScaleUpdate: (details) {
          if (details.pointerCount > 1) {
            setState(() => zoom = (zoom * details.scale).clamp(.72, 1.48).toDouble());
          } else {
            setState(() => orbit += details.focalPointDelta.dx / math.max(220.0, size.width));
          }
        },
        child: AnimatedBuilder(
          animation: clock,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _DeepSpacePainter(clock.value, orbit, systemMap)),
                Transform.scale(
                  scale: zoom,
                  child: CustomPaint(painter: _OrbitalArchitecturePainter(clock.value, orbit, systemMap)),
                ),
                _WorldOrbit(
                  worlds: widget.worlds,
                  phase: clock.value,
                  orbit: orbit,
                  selected: selected,
                  labels: labels,
                  compact: compact,
                  onTap: (world) => setState(() => selected = selected == world.kind ? null : world.kind),
                ),
                Positioned(
                  left: compact ? 16 : 34,
                  top: compact ? 16 : 28,
                  child: _GalaxyHeader(systemMap: systemMap, compact: compact),
                ),
                Positioned(
                  right: compact ? 12 : 30,
                  top: compact ? 16 : 28,
                  child: _GalaxyControls(
                    zoom: zoom,
                    systemMap: systemMap,
                    labels: labels,
                    onZoomIn: () => setState(() => zoom = (zoom + .1).clamp(.72, 1.48).toDouble()),
                    onZoomOut: () => setState(() => zoom = (zoom - .1).clamp(.72, 1.48).toDouble()),
                    onMode: () => setState(() => systemMap = !systemMap),
                    onLabels: () => setState(() => labels = !labels),
                    onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; systemMap = false; }),
                  ),
                ),
                Positioned(
                  left: compact ? 12 : 30,
                  top: compact ? 82 : 92,
                  child: _Telemetry(phase: clock.value, systemMap: systemMap, selected: current, compact: compact),
                ),
                if (current != null)
                  Positioned(
                    left: compact ? 12 : 30,
                    right: compact ? 12 : 30,
                    bottom: compact ? 12 : 28,
                    child: _WorldDetail(
                      world: current,
                      phase: clock.value,
                      compact: compact,
                      onClose: () => setState(() => selected = null),
                      onEnter: () => widget.onWorldTap?.call(current!),
                    ),
                  )
                else
                  Positioned(left: 0, right: 0, bottom: compact ? 16 : 28, child: const Center(child: _OrbitHint())),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GalaxyHeader extends StatelessWidget {
  final bool systemMap;
  final bool compact;
  const _GalaxyHeader({required this.systemMap, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5.2, fontWeight: FontWeight.w300)),
      const SizedBox(height: 7),
      Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.8)),
      const SizedBox(height: 5),
      Text(compact ? '09 WORLD NODES' : '09 WORLD NODES  •  PROCEDURAL DEEP SPACE', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
    ]);
  }
}

class _GalaxyControls extends StatelessWidget {
  final double zoom;
  final bool systemMap;
  final bool labels;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMode;
  final VoidCallback onLabels;
  final VoidCallback onReset;
  const _GalaxyControls({required this.zoom, required this.systemMap, required this.labels, required this.onZoomIn, required this.onZoomOut, required this.onMode, required this.onLabels, required this.onReset});

  Widget _button(IconData icon, VoidCallback action, {bool active = false}) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: active ? const Color(0x251A132A) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 12, color: active ? Colors.white70 : Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xD9090911), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x223F3A55))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _button(Icons.remove, onZoomOut),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text('${(zoom * 100).round()}%', style: const TextStyle(color: Colors.white54, fontSize: 7))),
        _button(Icons.add, onZoomIn),
        const SizedBox(width: 3),
        _button(Icons.grid_view_rounded, onMode, active: systemMap),
        _button(labels ? Icons.title : Icons.title_outlined, onLabels, active: labels),
        _button(Icons.refresh, onReset),
      ]),
    );
  }
}

class _Telemetry extends StatelessWidget {
  final double phase;
  final bool systemMap;
  final GalaxyWorld? selected;
  final bool compact;
  const _Telemetry({required this.phase, required this.systemMap, required this.selected, required this.compact});

  @override
  Widget build(BuildContext context) {
    final node = selected?.title ?? 'ALL NODES';
    final orbitValue = ((phase * 360) % 360).round().toString().padLeft(3, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xB7080810), border: Border.all(color: const Color(0x202F2A3A)), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(systemMap ? 'SYSTEM MAP' : 'DEEP ORBIT', style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.8)),
        const SizedBox(height: 4),
        Text(node, style: const TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1.1)),
        const SizedBox(height: 3),
        Text(compact ? 'ORBIT $orbitValue°' : 'ORBIT $orbitValue°   •   LIVE PROCEDURAL FIELD', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.1)),
      ]),
    );
  }
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final double phase;
  final double orbit;
  final GalaxyWorldKind? selected;
  final bool labels;
  final bool compact;
  final ValueChanged<GalaxyWorld> onTap;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.labels, required this.compact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = math.min(size.width, size.height);
    final center = Offset(size.width * .5, size.height * .52);
    final rx = base * (compact ? .34 : .40);
    final ry = base * (compact ? .25 : .30);
    final children = <Widget>[];

    for (var i = 0; i < worlds.length; i++) {
      final world = worlds[i];
      final angle = -math.pi / 2 + i * math.pi * 2 / math.max(1, worlds.length) + orbit + phase * .12;
      final depth = (.35 + .65 * ((math.sin(angle) + 1) / 2));
      final position = Offset(center.dx + math.cos(angle) * rx, center.dy + math.sin(angle) * ry);
      final baseSize = compact ? 74.0 : 112.0;
      final selectedSize = selected == world.kind ? baseSize * 1.55 : baseSize * (.68 + depth * .38);
      final opacity = selected == null || selected == world.kind ? 1.0 : .14;
      children.add(Positioned(
        left: position.dx - selectedSize / 2,
        top: position.dy - selectedSize / 2,
        width: selectedSize,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () => onTap(world),
            child: Column(children: [
              CustomPaint(
                size: Size.square(selectedSize),
                painter: _PlanetPainter(seed: 31 + i * 71, phase: phase, depth: depth, active: selected == world.kind, kind: world.kind),
              ),
              if (labels)
                Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(selected == world.kind ? .88 : .38), fontSize: selected == world.kind ? 9 : 6.2, letterSpacing: 1.7)),
            ]),
          ),
        ),
      ));
    }
    return Stack(fit: StackFit.expand, children: children);
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed;
  final double phase;
  final double depth;
  final bool active;
  final GalaxyWorldKind kind;
  const _PlanetPainter({required this.seed, required this.phase, required this.depth, required this.active, required this.kind});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final center = Offset(size.width * .48, size.height * .45);
    final radius = size.shortestSide * .42;
    final sphere = Rect.fromCircle(center: center, radius: radius);
    final accent = _accent();

    canvas.drawCircle(center, radius * 1.34, Paint()..shader = RadialGradient(colors: [accent.withOpacity(active ? .24 : .09), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.34)));
    canvas.drawCircle(center + Offset(radius * .025, radius * .025), radius * 1.025, Paint()..shader = RadialGradient(center: const Alignment(-.52, -.58), radius: 1.12, colors: const [Color(0xFFE6E1D6), Color(0xFFAAA9A1), Color(0xFF626762), Color(0xFF25282C), Color(0xFF05060A)], stops: [0, .16, .38, .70, 1]).createShader(sphere));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    _continents(canvas, center, radius, random, accent);
    _terrainRidges(canvas, center, radius, random);
    _surfaceNoise(canvas, center, radius, random);
    _cloudBands(canvas, center, radius, phase);
    _polarHaze(canvas, center, radius, phase);
    canvas.restore();

    final night = center + Offset(radius * .44, radius * .04);
    canvas.drawCircle(night, radius * .98, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.78)]).createShader(Rect.fromCircle(center: night, radius: radius * .98)));
    canvas.drawArc(sphere.inflate(radius * .02), math.pi * .57, math.pi * .9, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .018..color = Colors.white.withOpacity(active ? .38 : .16));

    if (seed % 3 != 1) _moon(canvas, center, radius, phase, seed);
    if (active) {
      canvas.drawCircle(center, radius * 1.13, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.25..color = Colors.white.withOpacity(.30 + depth * .10));
      canvas.drawCircle(center, radius * 1.18, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = accent.withOpacity(.28));
    }
  }

  Color _accent() {
    switch (kind) {
      case GalaxyWorldKind.game: return const Color(0xFF77899C);
      case GalaxyWorldKind.vegeta: return const Color(0xFF8C70A7);
      case GalaxyWorldKind.music: return const Color(0xFF607E83);
      case GalaxyWorldKind.cinema: return const Color(0xFF8B7564);
      case GalaxyWorldKind.creation: return const Color(0xFF687F70);
      case GalaxyWorldKind.family: return const Color(0xFF7D6E80);
      case GalaxyWorldKind.archive: return const Color(0xFF7C776A);
      case GalaxyWorldKind.comingSoon: return const Color(0xFF62677B);
      case GalaxyWorldKind.identity: return const Color(0xFF77727E);
    }
  }

  void _continents(Canvas canvas, Offset center, double radius, math.Random random, Color accent) {
    final fills = [accent.withOpacity(.25), const Color(0xFF9C886D).withOpacity(.18), const Color(0xFF52675E).withOpacity(.17), const Color(0xFFB6A88D).withOpacity(.11)];
    for (var region = 0; region < 12; region++) {
      final angle = region * 2.17 + seed * .071;
      final position = center + Offset(math.cos(angle) * radius * (.24 + (region % 3) * .12), math.sin(angle) * radius * (.25 + (region % 2) * .11));
      final width = radius * (.22 + random.nextDouble() * .30);
      final height = radius * (.12 + random.nextDouble() * .19);
      final rotation = angle * .42;
      final blob = _blob(position, width, height, rotation, seed + region * 19, 34);
      canvas.drawPath(blob, Paint()..color = fills[region % fills.length]);
      for (var contour = 1; contour <= 5; contour++) {
        canvas.drawPath(_blob(position, width * (1 - contour * .12), height * (1 - contour * .12), rotation, seed + region * 19 + contour, 30), Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .006..color = Colors.white.withOpacity(.012 + (6 - contour) * .003));
      }
    }
  }

  void _terrainRidges(Canvas canvas, Offset center, double radius, math.Random random) {
    for (var i = 0; i < 9; i++) {
      final y = center.dy - radius * .68 + i * radius * .17;
      final shift = math.sin(seed * .2 + i) * radius * .10;
      final rect = Rect.fromCenter(center: Offset(center.dx + shift, y), width: radius * 1.65, height: radius * (.12 + random.nextDouble() * .10));
      canvas.drawArc(rect, .05 + i * .07, 2.55, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * (.006 + (i % 3) * .002)..color = Colors.black.withOpacity(.045));
    }
  }

  void _surfaceNoise(Canvas canvas, Offset center, double radius, math.Random random) {
    for (var i = 0; i < 230; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * radius;
      final y = center.dy + (random.nextDouble() * 2 - 1) * radius;
      final p = Offset(x, y);
      if ((p - center).distance < radius) {
        final impact = random.nextDouble();
        final r = radius * (.003 + impact * .012);
        canvas.drawCircle(p, r, Paint()..color = Colors.white.withOpacity(.006 + impact * .018));
        if (i % 17 == 0) canvas.drawCircle(p, r * 2.4, Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = Colors.black.withOpacity(.025));
      }
    }
  }

  void _cloudBands(Canvas canvas, Offset center, double radius, double phase) {
    for (var band = 0; band < 11; band++) {
      final y = center.dy - radius * .72 + band * radius * .145 + math.sin(phase * math.pi * 2 + band + seed) * radius * .025;
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.86, height: radius * .14), .02, math.pi * .93, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * (.018 + (band % 3) * .005)..color = Colors.white.withOpacity(.018));
    }
  }

  void _polarHaze(Canvas canvas, Offset center, double radius, double phase) {
    for (var i = 0; i < 4; i++) {
      final y = center.dy - radius * (.78 - i * .08) + math.sin(phase * math.pi * 2 + i) * radius * .01;
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: radius * (1.05 + i * .1), height: radius * .12), Paint()..color = Colors.white.withOpacity(.012));
    }
  }

  void _moon(Canvas canvas, Offset center, double radius, double phase, int localSeed) {
    final angle = phase * math.pi * 2 + localSeed;
    final position = center + Offset(math.cos(angle) * radius * 1.72, math.sin(angle) * radius * .50);
    canvas.drawCircle(position, radius * .033, Paint()..color = Colors.white.withOpacity(.17));
    canvas.drawCircle(position + Offset(radius * .01, radius * .008), radius * .018, Paint()..color = Colors.black.withOpacity(.18));
  }

  Path _blob(Offset center, double width, double height, double rotation, int localSeed, int points) {
    final random = math.Random(localSeed * 17 + 5);
    final path = Path();
    for (var i = 0; i < points; i++) {
      final angle = i * math.pi * 2 / points;
      final wobble = .80 + math.sin(angle * 2.2 + localSeed) * .11 + math.sin(angle * 4.7 + localSeed * .3) * .06 + random.nextDouble() * .035;
      final x = math.cos(angle) * width * wobble;
      final y = math.sin(angle) * height * wobble;
      final rotated = Offset(x * math.cos(rotation) - y * math.sin(rotation), x * math.sin(rotation) + y * math.cos(rotation));
      final point = center + rotated;
      if (i == 0) path.moveTo(point.dx, point.dy); else path.lineTo(point.dx, point.dy);
    }
    path.close();
    return path;
  }
}

class _OrbitalArchitecturePainter extends CustomPainter {
  final double phase;
  final double orbit;
  final bool systemMap;
  const _OrbitalArchitecturePainter(this.phase, this.orbit, this.systemMap);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .52);
    final base = math.min(size.width, size.height);
    final rotation = orbit * .18 + phase * .10;
    for (var i = 0; i < 13; i++) {
      final rx = base * (.13 + i * .032);
      final ry = rx * (.55 + (i % 4) * .045);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation + i * .11);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 6 ? 1.0 : .45..color = Colors.white.withOpacity((systemMap ? .055 : .028) + (i % 3) * .006));
      canvas.restore();
    }
    for (var i = 0; i < 28; i++) {
      final angle = phase * math.pi * 2 * (.35 + (i % 5) * .12) + i * .77 + orbit;
      final ring = base * (.16 + (i % 9) * .032);
      final point = center + Offset(math.cos(angle) * ring, math.sin(angle) * ring * .56);
      canvas.drawCircle(point, systemMap ? 1.5 : 1.0, Paint()..color = Colors.white.withOpacity(.16));
    }
    canvas.drawCircle(center, base * .08, Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(.12), const Color(0xFF5A3E72).withOpacity(.05), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: base * .08)));
    canvas.drawCircle(center, base * .018, Paint()..color = Colors.white.withOpacity(.30));
  }

  @override
  bool shouldRepaint(covariant _OrbitalArchitecturePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.orbit != orbit || oldDelegate.systemMap != systemMap;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase;
  final double orbit;
  final bool systemMap;
  const _DeepSpacePainter(this.phase, this.orbit, this.systemMap);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(8401);
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = RadialGradient(center: const Alignment(0, .08), radius: 1.05, colors: [const Color(0xFF15101D), const Color(0xFF05050B), const Color(0xFF010106)]).createShader(rect));
    for (var i = 0; i < 3; i++) {
      final center = Offset(size.width * (.24 + i * .28), size.height * (.36 + math.sin(phase * math.pi * 2 + i) * .08));
      final radius = math.min(size.width, size.height) * (.32 + i * .08);
      canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(colors: [const Color(0xFF6B4A7A).withOpacity(systemMap ? .035 : .022), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius)));
    }
    for (var i = 0; i < 1180; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final layer = i % 5;
      final twinkle = .018 + ((math.sin(phase * math.pi * 2 * (.4 + layer * .12) + i) + 1) * .5) * .08;
      final radius = layer == 0 ? .65 : .35 + random.nextDouble() * .55;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.white.withOpacity(twinkle));
    }
    for (var i = 0; i < 90; i++) {
      final x = (random.nextDouble() * 1.2 - .1) * size.width;
      final y = (random.nextDouble() * 1.1 - .05) * size.height;
      canvas.drawCircle(Offset(x, y), .5 + random.nextDouble() * 1.2, Paint()..color = const Color(0xFF9A7CA7).withOpacity(.012));
    }
    canvas.drawRect(rect, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.62)], stops: const [.55, 1]).createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.orbit != orbit || oldDelegate.systemMap != systemMap;
}

class _WorldDetail extends StatelessWidget {
  final GalaxyWorld world;
  final double phase;
  final bool compact;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _WorldDetail({required this.world, required this.phase, required this.compact, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: BoxDecoration(color: const Color(0xE8070710), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.10)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 30, spreadRadius: 4)]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 2.2, fontWeight: FontWeight.w400)),
          const SizedBox(height: 5),
          Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 8, height: 1.45)),
          const SizedBox(height: 8),
          Text('WORLD NODE  •  PHASE ${((phase * 360) % 360).round()}°  •  PROCEDURAL', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.3)),
        ])),
        const SizedBox(width: 12),
        TextButton(onPressed: onClose, child: const Text('CLOSE', style: TextStyle(fontSize: 7, color: Colors.white38, letterSpacing: 1.4))),
        const SizedBox(width: 4),
        FilledButton(onPressed: onEnter, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF282033), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)), child: const Text('ENTER', style: TextStyle(fontSize: 7, letterSpacing: 1.5))),
      ]),
    );
  }
}

class _OrbitHint extends StatelessWidget {
  const _OrbitHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0x9A07070E), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x182F2A3A))),
      child: const Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD NODE', style: TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.5)),
    );
  }
}
