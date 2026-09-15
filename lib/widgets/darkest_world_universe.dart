import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_render_state.dart';
import '../screens/galaxy_navigation_session.dart';

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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 180))..repeat();
  int? focused;
  @override void dispose() { clock.dispose(); super.dispose(); }
  void tap(int i) { setState(() => focused = focused == i ? null : i); GalaxyNavigationSession.instance.selected = widget.worlds[i].kind.name; widget.onWorldTap?.call(widget.worlds[i]); }
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 820;
    return Scaffold(backgroundColor: const Color(0xFF010207), body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: _Space(clock.value)), CustomPaint(painter: _Orbital(clock.value)),
      SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 34), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('DARKESTWORLD', style: TextStyle(fontSize: 19, letterSpacing: 6.4, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6), const Text('THE WORLDS  /  CINEMATIC ATLAS', style: TextStyle(fontSize: 6.5, letterSpacing: 2.8, color: Color(0x66C0CFD5))),
        const Spacer(), Center(child: Text(compact ? 'TAP FOCUS  •  DOUBLE-TAP ENTER WORLD' : '1× CLICK FOCUS     2× CLICK ENTER WORLD', style: const TextStyle(fontSize: 6.5, letterSpacing: 2.1, color: Color(0x55FFFFFF)))),
      ]))),
      Center(child: LayoutBuilder(builder: (_, b) { final d = math.min(b.maxWidth * (compact ? .93 : .68), b.maxHeight * (compact ? .58 : .72)).toDouble(); return SizedBox.square(dimension: d, child: Stack(children: [
        for (var i = 0; i < widget.worlds.length; i++) _PlanetNode(world: widget.worlds[i], index: i, total: widget.worlds.length, diameter: d, phase: clock.value, selected: focused == i, onTap: () => tap(i), onOpen: () => widget.onWorldTap?.call(widget.worlds[i])),
        const Center(child: _Sun()),
      ])); })),
      if (focused != null) Positioned(left: compact ? 14 : 34, right: compact ? 14 : 34, bottom: compact ? 48 : 60, child: _WorldPanel(world: widget.worlds[focused!], index: focused!, close: () => setState(() => focused = null), open: () => widget.onWorldTap?.call(widget.worlds[focused!]))),
    ])));
  }
}

class _PlanetNode extends StatelessWidget {
  final GalaxyWorld world; final int index, total; final double diameter, phase; final bool selected; final VoidCallback onTap, onOpen;
  const _PlanetNode({required this.world, required this.index, required this.total, required this.diameter, required this.phase, required this.selected, required this.onTap, required this.onOpen});
  @override Widget build(BuildContext context) {
    final c = diameter / 2; final orbit = diameter * (.20 + (index % 4) * .075); final a = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + phase * math.pi * .12 * (index.isEven ? 1 : -1); final p = Offset(c + math.cos(a) * orbit, c + math.sin(a) * orbit); final d = (selected ? diameter * .15 : diameter * .10).clamp(54.0, 118.0).toDouble();
    return Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d + 30, child: GestureDetector(onTap: onTap, onDoubleTap: onOpen, child: CustomPaint(painter: _PlanetPainter(index: index, selected: selected, phase: phase, title: world.title))));
  }
}

class _PlanetPainter extends CustomPainter {
  final int index; final bool selected; final double phase; final String title;
  const _PlanetPainter({required this.index, required this.selected, required this.phase, required this.title});
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width / 2, s.width / 2), r = s.width * .30; final base = [const Color(0xFF8E7865), const Color(0xFF647C82), const Color(0xFF857E67), const Color(0xFF75677F), const Color(0xFF70877A), const Color(0xFF7D7063)][index % 6];
    x.drawCircle(c, r * 1.8, Paint()..shader = RadialGradient(colors: [const Color(0x5592B4C1).withValues(alpha: selected ? .25 : .07), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.8)));
    x.drawCircle(c, r, Paint()..shader = RadialGradient(center: const Alignment(-.42, -.5), colors: [base, base.withValues(alpha: .78), const Color(0xFF26313A), const Color(0xFF02050A)]).createShader(Rect.fromCircle(center: c, radius: r)));
    final detail = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x558FA2A9);
    for (var i = 1; i < 5; i++) x.drawArc(Rect.fromCircle(center: c, radius: r * i / 5), math.pi * (.2 + i * .06), math.pi * (1.2 + i * .1), false, detail);
    x.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.5 : .65..color = const Color(0x889FB5BD));
    if (selected) x.drawArc(Rect.fromCircle(center: c, radius: r * 1.32), phase * math.pi * 2, 1.4, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0xA0B7D0D8));
    final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: selected ? .95 : .62), fontSize: math.max(5.5, s.width * .065), letterSpacing: 1.3, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.8);
    tp.paint(x, Offset(c.dx - tp.width / 2, s.width * .72));
  }
  @override bool shouldRepaint(covariant _PlanetPainter o) => o.index != index || o.selected != selected || o.phase != phase || o.title != title;
}

class _Sun extends StatelessWidget { const _Sun(); @override Widget build(BuildContext c) => Container(width: 86, height: 86, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFFFFFFF), Color(0xFFD7C49F), Color(0xFF695845), Color(0x00000000)], stops: [0, .18, .45, 1]), boxShadow: [BoxShadow(color: Color(0x665F7480), blurRadius: 48, spreadRadius: 12)])); }
class _WorldPanel extends StatelessWidget { final GalaxyWorld world; final int index; final VoidCallback close, open; const _WorldPanel({required this.world, required this.index, required this.close, required this.open}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xF0070B11), border: Border.all(color: const Color(0x4B829DA8)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 40)]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WORLD ${(index + 1).toString().padLeft(2, '0')} / ATLAS NODE', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x62FFFFFF))), const SizedBox(height: 5), Text(world.title, style: const TextStyle(fontSize: 17, letterSpacing: 2.8)), const SizedBox(height: 4), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7.5, color: Color(0x8CC7D2D6), height: 1.35))])), TextButton(onPressed: close, child: const Text('×')), FilledButton(onPressed: open, child: const Text('ENTER WORLD'))])); }
class _Space extends CustomPainter { final double phase; const _Space(this.phase); @override void paint(Canvas x, Size s) { final r = Offset.zero & s; x.drawRect(r, Paint()..shader = const RadialGradient(colors: [Color(0xFF0A141D), Color(0xFF02060B), Color(0xFF010207)]).createShader(r)); final rnd = math.Random(912); for (var i = 0; i < 560; i++) { final p = Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height); x.drawCircle(p, .18 + rnd.nextDouble() * .62, Paint()..color = Colors.white.withValues(alpha: .018 + .075 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2))); } } @override bool shouldRepaint(covariant _Space o) => o.phase != phase; }
class _Orbital extends CustomPainter { final double phase; const _Orbital(this.phase); @override void paint(Canvas x, Size s) { final c = Offset(s.width * .5, s.height * .5); for (var i = 0; i < 5; i++) { final w = s.width * (.42 + i * .10); final h = s.height * (.18 + i * .04); x.drawOval(Rect.fromCenter(center: c, width: w, height: h), Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x1C8BA5AF)); } x.drawArc(Rect.fromCenter(center: c, width: s.width * .72, height: s.height * .40), phase * math.pi * 2, .75, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = const Color(0x527F9BA7)); } @override bool shouldRepaint(covariant _Orbital o) => o.phase != phase; }
