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
            _Header(systemMap: systemMap, compact: compact),
            Positioned(right: compact ? 12 : 30, top: compact ? 16 : 28, child: _Controls(zoom: zoom, map: systemMap, labels: labels, onIn: () => setState(() => zoom = (zoom + .1).clamp(.72, 1.48).toDouble()), onOut: () => setState(() => zoom = (zoom - .1).clamp(.72, 1.48).toDouble()), onMap: () => setState(() => systemMap = !systemMap), onLabels: () => setState(() => labels = !labels), onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; systemMap = false; }))),
            Positioned(left: compact ? 12 : 30, top: compact ? 82 : 92, child: _Telemetry(phase: clock.value, selected: current, map: systemMap)),
            if (current != null) Positioned(left: compact ? 12 : 30, right: compact ? 12 : 30, bottom: compact ? 12 : 28, child: _WorldPanel(world: current, phase: clock.value, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!)))
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
  @override Widget build(BuildContext context) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300)),
    const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5),
    Text(compact ? '09 WORLD NODES' : '09 WORLD NODES  •  PROCEDURAL DEEP SPACE', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]));
}

class _Controls extends StatelessWidget {
  final double zoom; final bool map, labels; final VoidCallback onIn, onOut, onMap, onLabels, onReset;
  const _Controls({required this.zoom, required this.map, required this.labels, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onReset});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    _Btn('+', onIn), _Btn('−', onOut), _Btn(map ? 'ORBIT' : 'MAP', onMap), _Btn(labels ? 'LABELS' : 'CLEAN', onLabels), _Btn('RESET', onReset),
  ]);
}
class _Btn extends StatelessWidget { final String text; final VoidCallback onTap; const _Btn(this.text, this.onTap); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 6), child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: Colors.black45, border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.2))))); }

class _Telemetry extends StatelessWidget { final double phase; final GalaxyWorld? selected; final bool map; const _Telemetry({required this.phase, required this.selected, required this.map}); @override Widget build(BuildContext context) => Text('${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}  •  ${((phase * 360).round() % 360).toString().padLeft(3, '0')}°', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)); }

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected; final bool labels, compact; final ValueChanged<GalaxyWorld> onTap;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.labels, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _PlanetPainter(worlds, phase, orbit, selected, labels, compact, onTap));
}

class _PlanetPainter extends CustomPainter {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected; final bool labels, compact; final ValueChanged<GalaxyWorld> onTap;
  _PlanetPainter(this.worlds, this.phase, this.orbit, this.selected, this.labels, this.compact, this.onTap);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, size.height * .52);
    final base = math.min(size.width, size.height) * (compact ? .16 : .19);
    for (var i = 0; i < worlds.length; i++) {
      final angle = i / math.max(1, worlds.length) * math.pi * 2 + orbit * .9;
      final depth = math.sin(angle) * .5 + .5;
      final radius = math.min(size.width, size.height) * (.12 + i * .008);
      final p = center + Offset(math.cos(angle) * radius * 1.55, math.sin(angle) * radius * .62);
      final scale = .72 + depth * .42 + (selected == worlds[i].kind ? .24 : 0);
      _planet(canvas, p, base * scale, worlds[i], phase, i, selected == worlds[i].kind);
      if (labels) _label(canvas, p, base * scale, worlds[i], selected == worlds[i].kind);
    }
  }
  void _planet(Canvas c, Offset p, double r, GalaxyWorld w, double t, int index, bool active) {
    final rect = Rect.fromCircle(center: p, radius: r);
    final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: active ? .22 : .10), Colors.transparent]).createShader(rect.inflate(r * .45)); c.drawCircle(p, r * 1.35, glow);
    final base = Paint()..shader = RadialGradient(center: const Alignment(-.35, -.4), radius: 1, colors: [const Color(0xFF5A6C87), _tone(w.kind), const Color(0xFF02030A)]).createShader(rect); c.drawCircle(p, r, base);
    c.save(); c.clipPath(Path()..addOval(rect));
    for (var k = 0; k < 12; k++) { final a = (k * 2.37 + index) % (math.pi * 2); final rr = r * (.35 + (k % 4) * .12); final q = p + Offset(math.cos(a) * rr, math.sin(a) * rr * .55); final lp = Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = Colors.white.withValues(alpha: .035 + (k % 3) * .012); c.drawOval(Rect.fromCenter(center: q, width: r * (.35 + k % 3 * .16), height: r * (.18 + k % 4 * .12)), lp); }
    final land = Paint()..style = PaintingStyle.fill..color = Colors.white.withValues(alpha: .065);
    for (var n = 0; n < 13; n++) { final a = n * .91 + index * .7; final rr = r * (.18 + (n % 5) * .12); final q = p + Offset(math.cos(a) * rr, math.sin(a) * rr * .65); c.drawOval(Rect.fromCenter(center: q, width: r * (.18 + (n % 4) * .08), height: r * (.10 + (n % 3) * .07)), land); }
    final cloud = Paint()..style = PaintingStyle.stroke..strokeWidth = r * .035..color = Colors.white.withValues(alpha: .07); for (var b = 0; b < 5; b++) { final y = p.dy - r * .62 + b * r * .31; c.drawArc(Rect.fromCenter(center: Offset(p.dx, y), width: r * 1.75, height: r * .48), .1 + t * 2 + b, 1.7, false, cloud); }
    c.restore();
    final rim = Paint()..style = PaintingStyle.stroke..strokeWidth = r * .028..color = Colors.white.withValues(alpha: active ? .42 : .16); c.drawCircle(p, r, rim);
  }
  Color _tone(GalaxyWorldKind k) { switch (k) { case GalaxyWorldKind.game: return const Color(0xFF254A55); case GalaxyWorldKind.identity: return const Color(0xFF49375B); case GalaxyWorldKind.cinema: return const Color(0xFF443D63); case GalaxyWorldKind.creation: return const Color(0xFF315A50); case GalaxyWorldKind.music: return const Color(0xFF53385A); case GalaxyWorldKind.family: return const Color(0xFF4B4058); case GalaxyWorldKind.archive: return const Color(0xFF4D4A39); case GalaxyWorldKind.comingSoon: return const Color(0xFF343A4D); case GalaxyWorldKind.vegeta: return const Color(0xFF523D66); } }
  void _label(Canvas c, Offset p, double r, GalaxyWorld w, bool active) { final tp = TextPainter(text: TextSpan(text: w.title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: active ? .8 : .32), fontSize: active ? 9 : 7, letterSpacing: 1.5)), textDirection: TextDirection.ltr)..layout(maxWidth: 150); tp.paint(c, p + Offset(-tp.width / 2, r + 8)); }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.phase != phase || old.orbit != orbit || old.selected != selected || old.labels != labels || old.worlds != worlds || old.compact != compact;
  @override bool hitTest(Offset position) => true;
}

class _OrbitalPainter extends CustomPainter { final double phase, orbit; final bool map; _OrbitalPainter(this.phase, this.orbit, this.map); @override void paint(Canvas c, Size s) { final center = Offset(s.width * .52, s.height * .52); final p = Paint()..style = PaintingStyle.stroke; for (var i = 0; i < 13; i++) { p.color = Colors.white.withValues(alpha: .025 + (i % 3) * .01); p.strokeWidth = i == 6 ? 1.2 : .45; final rr = math.min(s.width, s.height) * (.12 + i * .025); c.drawOval(Rect.fromCenter(center: center, width: rr * 2, height: rr * (map ? .9 : .46)), p); } final core = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .22), Colors.white.withValues(alpha: .02), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: 90)); c.drawCircle(center, 90, core); for (var j = 0; j < 28; j++) { final a = phase * math.pi * 2 * (1 + j % 3) + orbit + j; final rr = math.min(s.width, s.height) * (.16 + (j % 12) * .025); c.drawCircle(center + Offset(math.cos(a) * rr, math.sin(a) * rr * (map ? .9 : .48)), 1.4 + (j % 3) * .5, Paint()..color = Colors.white.withValues(alpha: .18)); } }
  @override bool shouldRepaint(covariant _OrbitalPainter old) => old.phase != phase || old.orbit != orbit || old.map != map;
}

class _DeepSpacePainter extends CustomPainter { final double phase; final bool map; _DeepSpacePainter(this.phase, this.map); @override void paint(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107)); final rnd = math.Random(812); for (var i = 0; i < 1180; i++) { final z = rnd.nextDouble(); final x = rnd.nextDouble() * s.width; final y = rnd.nextDouble() * s.height; final twinkle = .025 + rnd.nextDouble() * .15 + math.sin(phase * math.pi * 2 * (1 + z * 3) + i) * .025; c.drawCircle(Offset(x, y), .25 + z * 1.15, Paint()..color = Colors.white.withValues(alpha: twinkle.clamp(.01, .22))); } final haze = Paint()..shader = RadialGradient(colors: [const Color(0xFF37245A).withValues(alpha: map ? .13 : .08), Colors.transparent]).createShader(Rect.fromCenter(center: Offset(s.width * .53, s.height * .52), width: s.width * .8, height: s.height * .8)); c.drawOval(Rect.fromCenter(center: Offset(s.width * .53, s.height * .52), width: s.width * .8, height: s.height * .8), haze); }
  @override bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.map != map;
}

class _WorldPanel extends StatelessWidget { final GalaxyWorld world; final double phase; final bool compact; final VoidCallback onClose, onEnter; const _WorldPanel({required this.world, required this.phase, required this.compact, required this.onClose, required this.onEnter}); @override Widget build(BuildContext context) => Container(padding: EdgeInsets.all(compact ? 14 : 18), decoration: BoxDecoration(color: const Color(0xDD060610), border: Border.all(color: Colors.white12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2)), const SizedBox(height: 5), Text(world.description, style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.4)), const SizedBox(height: 8), Text('LIVE ORBIT  ${(phase * 100).round()}%  •  PROCEDURAL WORLD', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.2))])), TextButton(onPressed: onEnter, child: const Text('ENTER')), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 16, color: Colors.white38))])); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => const Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)); }
