import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'darkest_world_universe.dart';

class DarkestGalaxyV3 extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestGalaxyV3({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestGalaxyV3> createState() => _DarkestGalaxyV3State();
}

class _DarkestGalaxyV3State extends State<DarkestGalaxyV3> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 42))..repeat();
  GalaxyWorldKind? selected;
  double yaw = 0, zoom = 1;
  Offset? last;
  bool labels = true, mapMode = false;
  @override void dispose() { clock.dispose(); super.dispose(); }
  GalaxyWorld? get current { for (final w in widget.worlds) { if (w.kind == selected) return w; } return null; }
  void reset() => setState(() { yaw = 0; zoom = 1; selected = null; });
  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context), compact = size.width < 780;
    return Scaffold(backgroundColor: const Color(0xFF020207), body: GestureDetector(
      onScaleStart: (d) => last = d.focalPoint,
      onScaleUpdate: (d) { if (d.pointerCount > 1) { setState(() => zoom = (zoom * d.scale).clamp(.62, 1.55)); } else if (last != null) { setState(() => yaw += (d.focalPoint.dx - last!.dx) / math.max(260, size.width) * 1.8); last = d.focalPoint; } },
      onScaleEnd: (_) => last = null,
      child: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _DeepSpacePainter(clock.value, yaw, selected != null, mapMode)),
        Transform.scale(scale: zoom, child: CustomPaint(painter: _SystemPainter(clock.value, yaw, mapMode))),
        _WorldNodes(worlds: widget.worlds, phase: clock.value, yaw: yaw, selected: selected, labels: labels, compact: compact, onTap: (w) => setState(() => selected = selected == w.kind ? null : w.kind)),
        Positioned(left: compact ? 16 : 32, top: compact ? 16 : 28, child: _Header(compact: compact, mapMode: mapMode)),
        Positioned(right: compact ? 12 : 30, top: compact ? 16 : 28, child: _Controls(zoom: zoom, labels: labels, mapMode: mapMode, onIn: () => setState(() => zoom = (zoom + .1).clamp(.62, 1.55)), onOut: () => setState(() => zoom = (zoom - .1).clamp(.62, 1.55)), onLabels: () => setState(() => labels = !labels), onMode: () => setState(() => mapMode = !mapMode), onReset: reset)),
        Positioned(left: compact ? 12 : 30, bottom: compact ? 12 : 28, child: _Telemetry(phase: clock.value, compact: compact, selected: current, mapMode: mapMode)),
        if (current != null) Positioned(left: compact ? 12 : 30, right: compact ? 12 : 30, bottom: compact ? 86 : 92, child: _SelectedWorld(world: current!, compact: compact, phase: clock.value, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
        if (current == null) Positioned(bottom: compact ? 18 : 30, left: 0, right: 0, child: const Center(child: _Hint())),
      ])),
    ));
  }
}

class _Header extends StatelessWidget {
  final bool compact, mapMode;
  const _Header({required this.compact, required this.mapMode});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300)),
    const SizedBox(height: 7), Text(mapMode ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 2.5)),
    const SizedBox(height: 5), Text(compact ? '9 WORLD NODES' : '09 WORLD NODES  •  LIVE ORBITAL FIELD', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.8)),
  ]);
}

class _Controls extends StatelessWidget {
  final double zoom; final bool labels, mapMode; final VoidCallback onIn, onOut, onLabels, onMode, onReset;
  const _Controls({required this.zoom, required this.labels, required this.mapMode, required this.onIn, required this.onOut, required this.onLabels, required this.onMode, required this.onReset});
  Widget b(IconData icon, VoidCallback fn, {bool active = false}) => InkWell(onTap: fn, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: active ? const Color(0x22100D1C) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 12, color: active ? Colors.white70 : Colors.white38)));
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xD90A0912), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x223F3A55))), child: Row(mainAxisSize: MainAxisSize.min, children: [b(Icons.remove, onOut), Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text('${(zoom * 100).round()}%', style: const TextStyle(color: Colors.white54, fontSize: 7, letterSpacing: 1))), b(Icons.add, onIn), const SizedBox(width: 3), b(Icons.grid_view_rounded, onMode, active: mapMode), b(labels ? Icons.title : Icons.title_outlined, onLabels, active: labels), b(Icons.refresh, onReset)]));
}

class _WorldNodes extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, yaw; final GalaxyWorldKind? selected; final bool labels, compact; final ValueChanged<GalaxyWorld> onTap;
  const _WorldNodes({required this.worlds, required this.phase, required this.yaw, required this.selected, required this.labels, required this.compact, required this.onTap});
  static const seeds = <GalaxyWorldKind, int>{GalaxyWorldKind.vegeta: 11, GalaxyWorldKind.game: 23, GalaxyWorldKind.identity: 37, GalaxyWorldKind.cinema: 49, GalaxyWorldKind.creation: 61, GalaxyWorldKind.music: 73, GalaxyWorldKind.family: 89, GalaxyWorldKind.archive: 101, GalaxyWorldKind.comingSoon: 127};
  @override Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context), center = Offset(s.width * .5, s.height * .51), rx = math.min(s.width, s.height) * (compact ? .32 : .37), ry = math.min(s.width, s.height) * (compact ? .24 : .29);
    final nodes = <Widget>[];
    for (var i = 0; i < worlds.length; i++) { final w = worlds[i], a = i * math.pi * 2 / math.max(1, worlds.length) + phase * .10 + yaw, z = .52 + .48 * ((math.sin(a) + 1) / 2), p = Offset(center.dx + math.cos(a) * rx, center.dy + math.sin(a) * ry), base = compact ? 66.0 : 96.0, size = selected == w.kind ? base * 1.34 : base * (.72 + z * .38), opacity = selected == null || selected == w.kind ? 1.0 : .16;
      nodes.add(Positioned(left: p.dx - size / 2, top: p.dy - size / 2, width: size, child: Opacity(opacity: opacity, child: GestureDetector(onTap: () => onTap(w), child: Column(children: [CustomPaint(size: Size(size, size), painter: _Planet(seed: seeds[w.kind]!, phase: phase, selected: selected == w.kind, kind: w.kind, depth: z)), if (labels) Padding(padding: const EdgeInsets.only(top: 5), child: Text(w.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: selected == w.kind ? .9 : .42), fontSize: selected == w.kind ? 9 : 6.5, letterSpacing: 1.8)))]))));
    }
    return Stack(fit: StackFit.expand, children: nodes);
  }
}

class _Planet extends CustomPainter {
  final int seed; final double phase, depth; final bool selected; final GalaxyWorldKind kind;
  const _Planet({required this.seed, required this.phase, required this.selected, required this.kind, required this.depth});
  @override void paint(Canvas c, Size s) {
    final rnd = math.Random(seed * 911), p = Offset(s.width * .48, s.height * .45), r = s.shortestSide * .43, accent = kind == GalaxyWorldKind.game ? const Color(0xFF6D7890) : kind == GalaxyWorldKind.vegeta ? const Color(0xFF8E6EAA) : const Color(0xFF66717D), sphere = Rect.fromCircle(center: p, radius: r);
    c.drawCircle(p, r * 1.28, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: selected ? .25 : .13), Colors.transparent]).createShader(Rect.fromCircle(center: p, radius: r * 1.35)));
    c.drawCircle(p, r * 1.02, Paint()..shader = const RadialGradient(center: Alignment(-.52, -.55), radius: 1.05, colors: [Color(0xFFE1D9CB), Color(0xFF8A8D88), Color(0xFF45484B), Color(0xFF0B0D12), Color(0xFF020308)], stops: [0, .12, .34, .72, 1]).createShader(sphere));
    c.save(); c.clipPath(Path()..addOval(sphere));
    final landColors = [accent.withValues(alpha: .40), const Color(0xFF8E8068).withValues(alpha: .27), const Color(0xFF596B63).withValues(alpha: .22)];
    for (var k = 0; k < 6; k++) { final a = k * 1.17 + seed * .07, center = p + Offset(math.cos(a) * r * (.28 + k % 2 * .12), math.sin(a) * r * .25), w = r * (.60 + rnd.nextDouble() * .38), h = r * (.22 + rnd.nextDouble() * .22), path = _land(center, w, h, a * .3, seed + k * 19, 22); c.drawPath(path, Paint()..color = landColors[k % landColors.length]); for (var q = 1; q <= 5; q++) c.drawPath(_land(center, w * (1 - q * .12), h * (1 - q * .12), a * .3, seed + k * 19 + q, 18), Paint()..style = PaintingStyle.stroke..strokeWidth = r * .006..color = Colors.white.withValues(alpha: .012 + (5 - q) * .004)); }
    for (var i = 0; i < 150; i++) { final x = p.dx + (rnd.nextDouble() * 2 - 1) * r, y = p.dy + (rnd.nextDouble() * 2 - 1) * r; if ((Offset(x, y) - p).distance < r) c.drawCircle(Offset(x, y), .3 + rnd.nextDouble() * 1.1, Paint()..color = Colors.white.withValues(alpha: .006 + rnd.nextDouble() * .026)); }
    for (var k = 0; k < 4; k++) { final yy = p.dy - r * .5 + k * r * .29 + math.sin(phase * math.pi * 2 + k) * r * .035; c.drawArc(Rect.fromCenter(center: Offset(p.dx, yy), width: r * 1.7, height: r * .20), math.pi * .08, math.pi * .84, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .045..color = Colors.white.withValues(alpha: .035)); }
    c.restore();
    final shadow = p + Offset(r * .56, r * .10); c.drawCircle(shadow, r * .93, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .84)]).createShader(Rect.fromCircle(center: shadow, radius: r * .93)));
    c.drawArc(Rect.fromCircle(center: p, radius: r * 1.012), math.pi * .60, math.pi * .87, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = Colors.white.withValues(alpha: selected ? .34 : .20));
    if (kind == GalaxyWorldKind.game) c.drawOval(Rect.fromCenter(center: p, width: r * 1.85, height: r * .52), Paint()..style = PaintingStyle.stroke..strokeWidth = r * .008..color = accent.withValues(alpha: .14));
    if (selected) c.drawCircle(p, r * 1.15, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .20 + depth * .12));
  }
  Path _land(Offset c, double w, double h, double rot, int local, int n) { final r = math.Random(local * 17), pts = <Offset>[]; for (var i = 0; i < n; i++) { final a = i * math.pi * 2 / n, wave = math.sin(a * 2 + local) * .12 + math.sin(a * 3.4 + local * .2) * .07, rr = .78 + wave + r.nextDouble() * .10, x = math.cos(a) * w * .5 * rr, y = math.sin(a) * h * .5 * rr; pts.add(Offset(c.dx + x * math.cos(rot) - y * math.sin(rot), c.dy + x * math.sin(rot) + y * math.cos(rot))); } final p = Path()..moveTo(pts[0].dx, pts[0].dy); for (var i = 0; i < n; i++) { final a = pts[i], b = pts[(i + 1) % n]; p.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2); } return p..close(); }
  @override bool shouldRepaint(covariant _Planet old) => old.phase != phase || old.selected != selected || old.depth != depth;
}

class _SystemPainter extends CustomPainter {
  final double phase, yaw; final bool mapMode;
  const _SystemPainter(this.phase, this.yaw, this.mapMode);
  @override void paint(Canvas c, Size s) { final center = Offset(s.width * .5, s.height * .51), min = math.min(s.width, s.height), rnd = math.Random(4041); c.drawCircle(center, min * .20, Paint()..shader = const RadialGradient(colors: [Color(0xA8E6DCC9), Color(0x445D5272), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: min * .20))); c.drawCircle(center, min * .025, Paint()..color = const Color(0xCCEEE4D3)); for (var i = 0; i < 10; i++) { final wobble = math.sin(phase * math.pi * 2 + i) * .012, rect = Rect.fromCenter(center: center, width: min * (.27 + i * .082 + wobble), height: min * (.17 + i * .058)); c.drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = i == 0 ? 1 : .35..color = Color.fromRGBO(142,132,166, mapMode ? .16 : .09)); } for (var i = 0; i < 40; i++) { final a = phase * math.pi * 2 * (i.isEven ? .015 : -.010) + i * .71 + yaw, rr = min * (.18 + (i % 9) * .085), p = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .62); c.drawCircle(p, 1 + (i % 4) * .45, Paint()..color = Colors.white.withValues(alpha: .08)); } if (mapMode) { final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = const Color(0x123F3A55); for (var i = 1; i < 8; i++) c.drawCircle(center, min * i / 8, grid); } for (var i = 0; i < 80; i++) { final x = rnd.nextDouble() * s.width, y = rnd.nextDouble() * s.height; c.drawCircle(Offset(x, y), .15 + rnd.nextDouble() * .45, Paint()..color = Colors.white.withValues(alpha: .012)); } }
  @override bool shouldRepaint(covariant _SystemPainter old) => old.phase != phase || old.yaw != yaw || old.mapMode != mapMode;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase, yaw; final bool focused, mapMode;
  const _DeepSpacePainter(this.phase, this.yaw, this.focused, this.mapMode);
  @override void paint(Canvas c, Size s) { final rect = Offset.zero & s, center = Offset(s.width * .5, s.height * .5); c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.18, colors: [Color(0xFF302844), Color(0xFF0B0A13), Color(0xFF010104)]).createShader(rect)); c.drawCircle(center, s.shortestSide * .72, Paint()..shader = RadialGradient(colors: [Color.fromRGBO(113,99,151, focused ? .18 : .11), const Color(0x087F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: s.shortestSide * .72))); final r = math.Random(713); for (var i = 0; i < 1050; i++) { final layer = i % 5, speed = .002 + layer * .004, x = (r.nextDouble() * s.width + phase * s.width * speed + yaw * s.width * (.03 + layer * .012)) % s.width, y = r.nextDouble() * s.height, a = .012 + layer * .009 + .018 * (.5 + .5 * math.sin(phase * math.pi * 2 + i)); c.drawCircle(Offset(x, y), .1 + r.nextDouble() * (layer == 4 ? 1.0 : .55), Paint()..color = Colors.white.withValues(alpha: a)); } c.drawRect(rect, Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0x68000000)]).createShader(Rect.fromCenter(center: center, width: s.width * 1.12, height: s.height * 1.12))); }
  @override bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.yaw != yaw || old.focused != focused || old.mapMode != mapMode;
}

class _Telemetry extends StatelessWidget { final double phase; final bool compact, mapMode; final GalaxyWorld? selected; const _Telemetry({required this.phase, required this.compact, required this.selected, required this.mapMode}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: const Color(0xAA07070D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x183F3A55))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.radio_button_checked, size: 9, color: Color(0x887F70B0)), const SizedBox(width: 7), Text(selected == null ? 'SYSTEM STABLE' : 'NODE LOCK  •  ${selected!.title}', style: const TextStyle(color: Colors.white38, fontSize: 6.5, letterSpacing: 1.5)), if (!compact) ...[const SizedBox(width: 14), Text('${(phase * 360).round() % 360}°', style: const TextStyle(color: Colors.white24, fontSize: 6.5)), const SizedBox(width: 12), Text(mapMode ? 'MAP' : 'ORBIT', style: const TextStyle(color: Colors.white24, fontSize: 6.5))]])); }

class _SelectedWorld extends StatelessWidget { final GalaxyWorld world; final bool compact; final double phase; final VoidCallback onClose, onEnter; const _SelectedWorld({required this.world, required this.compact, required this.phase, required this.onClose, required this.onEnter}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xF20A0912), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 26)]), child: Row(children: [Container(width: 4, height: 48, decoration: BoxDecoration(color: const Color(0x667F70B0), borderRadius: BorderRadius.circular(4))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 2.8)), const SizedBox(height: 4), Text(world.description, maxLines: compact ? 1 : 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 7.5)), const SizedBox(height: 7), Text('NODE ONLINE  •  ORBIT ${((phase + world.kind.index * .071) * 360).round() % 360}°', style: const TextStyle(color: Colors.white24, fontSize: 5.8, letterSpacing: 1.5))])), if (!compact) TextButton(onPressed: onClose, child: const Text('CLOSE', style: TextStyle(fontSize: 8))), FilledButton(onPressed: onEnter, child: const Text('ENTER', style: TextStyle(fontSize: 9)))])); }

class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: const Color(0x88070710), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x223F3A55))), child: const Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD', style: TextStyle(color: Colors.white38, fontSize: 6.5, letterSpacing: 1.7))); }
