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
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  GalaxyWorldKind? selected;
  double orbit = 0;
  double zoom = 1;
  bool systemMap = false;
  bool labels = true;
  @override void dispose() { clock.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    GalaxyWorld? current;
    for (final world in widget.worlds) { if (world.kind == selected) current = world; }
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: GestureDetector(
        onScaleUpdate: (d) {
          if (d.pointerCount > 1) { setState(() => zoom = (zoom * d.scale).clamp(.72, 1.48).toDouble()); }
          else { setState(() => orbit += d.focalPointDelta.dx / math.max(220.0, size.width)); }
        },
        child: AnimatedBuilder(
          animation: clock,
          builder: (_, __) => Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _DeepSpacePainter(clock.value, systemMap)),
            Transform.scale(scale: zoom, child: CustomPaint(painter: _OrbitalPainter(clock.value, orbit, systemMap))),
            _WorldOrbit(worlds: widget.worlds, phase: clock.value, orbit: orbit, selected: selected, labels: labels, compact: compact, onTap: (w) => setState(() => selected = selected == w.kind ? null : w.kind)),
            Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: _Header(systemMap: systemMap, compact: compact)),
            Positioned(right: compact ? 12 : 30, top: compact ? 16 : 28, child: _Controls(zoom: zoom, map: systemMap, labels: labels, onIn: () => setState(() => zoom = (zoom + .1).clamp(.72, 1.48).toDouble()), onOut: () => setState(() => zoom = (zoom - .1).clamp(.72, 1.48).toDouble()), onMap: () => setState(() => systemMap = !systemMap), onLabels: () => setState(() => labels = !labels), onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; systemMap = false; }))),
            Positioned(left: compact ? 12 : 30, top: compact ? 82 : 92, child: _Telemetry(phase: clock.value, selected: current, map: systemMap)),
            if (current != null) Positioned(left: compact ? 12 : 30, right: compact ? 12 : 30, bottom: compact ? 12 : 28, child: _WorldPanel(world: current!, phase: clock.value, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!)))
            else const Positioned(left: 0, right: 0, bottom: 24, child: Center(child: _Hint())),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool systemMap, compact;
  const _Header({required this.systemMap, required this.compact});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300)),
    const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5),
    Text(compact ? '09 WORLD NODES' : '09 WORLD NODES  •  PROCEDURAL DEEP SPACE', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]);
}

class _Controls extends StatelessWidget {
  final double zoom; final bool map, labels; final VoidCallback onIn, onOut, onMap, onLabels, onReset;
  const _Controls({required this.zoom, required this.map, required this.labels, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onReset});
  Widget _b(IconData icon, VoidCallback action, bool active) => InkWell(onTap: action, child: Padding(padding: const EdgeInsets.all(7), child: Icon(icon, size: 12, color: active ? Colors.white70 : Colors.white38)));
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xD9090911), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x223F3A55))), child: Row(mainAxisSize: MainAxisSize.min, children: [_b(Icons.remove, onOut, false), Text('${(zoom * 100).round()}%', style: const TextStyle(color: Colors.white54, fontSize: 7)), _b(Icons.add, onIn, false), _b(Icons.grid_view_rounded, onMap, map), _b(labels ? Icons.title : Icons.title_outlined, onLabels, labels), _b(Icons.refresh, onReset, false)]));
}

class _Telemetry extends StatelessWidget {
  final double phase; final GalaxyWorld? selected; final bool map;
  const _Telemetry({required this.phase, required this.selected, required this.map});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xB7080810), border: Border.all(color: const Color(0x202F2A3A)), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(map ? 'SYSTEM MAP' : 'DEEP ORBIT', style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 4), Text(selected?.title ?? 'ALL NODES', style: const TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1.1)), const SizedBox(height: 3), Text('ORBIT ${((phase * 360) % 360).round().toString().padLeft(3, '0')}°', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.1))]));
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected; final bool labels, compact; final ValueChanged<GalaxyWorld> onTap;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.labels, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context), base = math.min(s.width, s.height), center = Offset(s.width * .5, s.height * .52);
    final rx = base * (compact ? .34 : .40), ry = base * (compact ? .25 : .30), children = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final world = worlds[i];
      final angle = -math.pi / 2 + i * math.pi * 2 / math.max(1, worlds.length) + orbit + phase * .12;
      final depth = .35 + .65 * ((math.sin(angle) + 1) / 2);
      final p = Offset(center.dx + math.cos(angle) * rx, center.dy + math.sin(angle) * ry);
      final baseSize = compact ? 74.0 : 112.0;
      final size = selected == world.kind ? baseSize * 1.55 : baseSize * (.68 + depth * .38);
      children.add(Positioned(left: p.dx - size / 2, top: p.dy - size / 2, width: size, child: Opacity(opacity: selected == null || selected == world.kind ? 1 : .14, child: GestureDetector(onTap: () => onTap(world), child: Column(children: [CustomPaint(size: Size.square(size), painter: _PlanetPainter(seed: 31 + i * 71, phase: phase, depth: depth, active: selected == world.kind, kind: world.kind)), if (labels) Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: selected == world.kind ? .88 : .38), fontSize: selected == world.kind ? 9 : 6.2, letterSpacing: 1.7))])))));
    }
    return Stack(fit: StackFit.expand, children: children);
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed; final double phase, depth; final bool active; final GalaxyWorldKind kind;
  const _PlanetPainter({required this.seed, required this.phase, required this.depth, required this.active, required this.kind});
  @override void paint(Canvas c, Size s) {
    final r = math.Random(seed), center = Offset(s.width * .48, s.height * .45), radius = s.shortestSide * .42, sphere = Rect.fromCircle(center: center, radius: radius), accent = _accent();
    c.drawCircle(center, radius * 1.34, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: active ? .24 : .09), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.34)));
    c.drawCircle(center + Offset(radius * .025, radius * .025), radius * 1.025, Paint()..shader = RadialGradient(center: const Alignment(-.52, -.58), radius: 1.12, colors: const [Color(0xFFE6E1D6), Color(0xFFAAA9A1), Color(0xFF626762), Color(0xFF25282C), Color(0xFF05060A)], stops: const [0, .16, .38, .70, 1]).createShader(sphere));
    c.save(); c.clipPath(Path()..addOval(sphere));
    for (var region = 0; region < 12; region++) {
      final a = region * 2.17 + seed * .071, p = center + Offset(math.cos(a) * radius * (.24 + (region % 3) * .12), math.sin(a) * radius * (.25 + (region % 2) * .11));
      final w = radius * (.22 + r.nextDouble() * .30), h = radius * (.12 + r.nextDouble() * .19), blob = _blob(p, w, h, a * .42, seed + region * 19, 34);
      c.drawPath(blob, Paint()..color = accent.withValues(alpha: .12 + (region % 4) * .035));
      for (var contour = 1; contour <= 5; contour++) { c.drawPath(_blob(p, w * (1 - contour * .12), h * (1 - contour * .12), a * .42, seed + region * 19 + contour, 28), Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .006..color = Colors.white.withValues(alpha: .012 + (6 - contour) * .003)); }
    }
    for (var i = 0; i < 9; i++) { final y = center.dy - radius * .68 + i * radius * .17; c.drawArc(Rect.fromCenter(center: Offset(center.dx + math.sin(seed * .2 + i) * radius * .1, y), width: radius * 1.65, height: radius * .16), .05, 2.55, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .007..color = Colors.black.withValues(alpha: .045)); }
    for (var i = 0; i < 230; i++) { final x = center.dx + (r.nextDouble() * 2 - 1) * radius, y = center.dy + (r.nextDouble() * 2 - 1) * radius, p = Offset(x, y); if ((p - center).distance < radius) { final rr = radius * (.003 + r.nextDouble() * .012); c.drawCircle(p, rr, Paint()..color = Colors.white.withValues(alpha: .006 + r.nextDouble() * .018)); if (i % 17 == 0) c.drawCircle(p, rr * 2.4, Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = Colors.black.withValues(alpha: .025)); } }
    for (var band = 0; band < 11; band++) { final y = center.dy - radius * .72 + band * radius * .145 + math.sin(phase * math.pi * 2 + band + seed) * radius * .025; c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.86, height: radius * .14), .02, math.pi * .93, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * (.018 + (band % 3) * .005)..color = Colors.white.withValues(alpha: .018)); }
    c.restore();
    final night = center + Offset(radius * .44, radius * .04);
    c.drawCircle(night, radius * .98, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .78)]).createShader(Rect.fromCircle(center: night, radius: radius * .98)));
    c.drawArc(sphere.inflate(radius * .02), math.pi * .57, math.pi * .9, false, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .018..color = Colors.white.withValues(alpha: active ? .38 : .16));
    if (seed % 3 != 1) { final a = phase * math.pi * 2 + seed, p = center + Offset(math.cos(a) * radius * 1.72, math.sin(a) * radius * .50); c.drawCircle(p, radius * .033, Paint()..color = Colors.white.withValues(alpha: .17)); }
    if (active) { c.drawCircle(center, radius * 1.13, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.25..color = Colors.white.withValues(alpha: .30 + depth * .10)); c.drawCircle(center, radius * 1.18, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = accent.withValues(alpha: .28)); }
  }
  Color _accent() { switch (kind) { case GalaxyWorldKind.game: return const Color(0xFF77899C); case GalaxyWorldKind.vegeta: return const Color(0xFF8C70A7); case GalaxyWorldKind.music: return const Color(0xFF607E83); case GalaxyWorldKind.cinema: return const Color(0xFF8B7564); case GalaxyWorldKind.creation: return const Color(0xFF687F70); case GalaxyWorldKind.family: return const Color(0xFF7D6E80); case GalaxyWorldKind.archive: return const Color(0xFF7C776A); case GalaxyWorldKind.comingSoon: return const Color(0xFF62677B); case GalaxyWorldKind.identity: return const Color(0xFF77727E); } }
  Path _blob(Offset center, double width, double height, double rotation, int localSeed, int points) { final random = math.Random(localSeed * 17 + 5), path = Path(); for (var i = 0; i < points; i++) { final a = i * math.pi * 2 / points, wobble = .80 + math.sin(a * 2.2 + localSeed) * .11 + math.sin(a * 4.7 + localSeed * .3) * .06 + random.nextDouble() * .035, x = math.cos(a) * width * wobble, y = math.sin(a) * height * wobble, p = center + Offset(x * math.cos(rotation) - y * math.sin(rotation), x * math.sin(rotation) + y * math.cos(rotation)); if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy); } path.close(); return path; }
  @override bool shouldRepaint(covariant _PlanetPainter oldDelegate) => oldDelegate.seed != seed || oldDelegate.phase != phase || oldDelegate.depth != depth || oldDelegate.active != active || oldDelegate.kind != kind;
}

class _OrbitalPainter extends CustomPainter {
  final double phase, orbit; final bool systemMap;
  const _OrbitalPainter(this.phase, this.orbit, this.systemMap);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .52), base = math.min(s.width, s.height), rotation = orbit * .18 + phase * .10;
    for (var i = 0; i < 13; i++) { final rx = base * (.13 + i * .032), ry = rx * (.55 + (i % 4) * .045); c.save(); c.translate(center.dx, center.dy); c.rotate(rotation + i * .11); c.translate(-center.dx, -center.dy); c.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 6 ? 1 : .45..color = Colors.white.withValues(alpha: (systemMap ? .055 : .028) + (i % 3) * .006)); c.restore(); }
    for (var i = 0; i < 28; i++) { final a = phase * math.pi * 2 * (.35 + (i % 5) * .12) + i * .77 + orbit, ring = base * (.16 + (i % 9) * .032); c.drawCircle(center + Offset(math.cos(a) * ring, math.sin(a) * ring * .56), systemMap ? 1.5 : 1, Paint()..color = Colors.white.withValues(alpha: .16)); }
    c.drawCircle(center, base * .08, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .12), const Color(0xFF5A3E72).withValues(alpha: .05), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: base * .08)));
  }
  @override bool shouldRepaint(covariant _OrbitalPainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.orbit != orbit || oldDelegate.systemMap != systemMap;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase; final bool systemMap;
  const _DeepSpacePainter(this.phase, this.systemMap);
  @override void paint(Canvas c, Size s) {
    final r = math.Random(8401), rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = RadialGradient(center: const Alignment(0, .08), radius: 1.05, colors: const [Color(0xFF15101D), Color(0xFF05050B), Color(0xFF010106)]).createShader(rect));
    for (var i = 0; i < 3; i++) { final p = Offset(s.width * (.24 + i * .28), s.height * (.36 + math.sin(phase * math.pi * 2 + i) * .08)); final rr = math.min(s.width, s.height) * (.32 + i * .08); c.drawCircle(p, rr, Paint()..shader = RadialGradient(colors: [const Color(0xFF6B4A7A).withValues(alpha: systemMap ? .035 : .022), Colors.transparent]).createShader(Rect.fromCircle(center: p, radius: rr))); }
    for (var i = 0; i < 1180; i++) { final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height, layer = i % 5, twinkle = .018 + ((math.sin(phase * math.pi * 2 * (.4 + layer * .12) + i) + 1) * .5) * .08; c.drawCircle(Offset(x, y), layer == 0 ? .65 : .35 + r.nextDouble() * .55, Paint()..color = Colors.white.withValues(alpha: twinkle)); }
    c.drawRect(rect, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .62)], stops: const [.55, 1]).createShader(rect));
  }
  @override bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.systemMap != systemMap;
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world; final double phase; final bool compact; final VoidCallback onClose, onEnter;
  const _WorldPanel({required this.world, required this.phase, required this.compact, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: EdgeInsets.all(compact ? 13 : 17), decoration: BoxDecoration(color: const Color(0xE8070710), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 2.2)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 8)), const SizedBox(height: 8), Text('WORLD NODE  •  PHASE ${((phase * 360) % 360).round()}°  •  PROCEDURAL', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.2))])), TextButton(onPressed: onClose, child: const Text('CLOSE')), FilledButton(onPressed: onEnter, child: const Text('ENTER'))]));
}
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0x9A07070E), borderRadius: BorderRadius.circular(10)), child: const Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD NODE', style: TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.5))); }
