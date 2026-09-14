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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 90))..repeat();
  final session = GalaxyNavigationSession.instance;
  GalaxyWorldKind? selected;
  GalaxyWorldKind? hovered;
  GalaxyRenderState get render => session.renderState;

  @override
  void initState() { super.initState(); session.addListener(_changed); }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final compact = MediaQuery.sizeOf(context).width < 760;
    if (render.compact != compact) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) session.updateRenderState(render.copyWith(compact: compact)); });
  }
  @override
  void dispose() { session.removeListener(_changed); clock.dispose(); super.dispose(); }
  void _changed() { if (mounted) setState(() {}); }
  void _select(GalaxyWorld world) { setState(() => selected = world.kind); session.select(world.kind); }
  void _open(GalaxyWorld world) { session.visit(world.kind); widget.onWorldTap?.call(world); }
  void _clear() { setState(() { selected = null; hovered = null; }); session.clearSelection(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final state = render;
    GalaxyWorld? current;
    for (final world in widget.worlds) { if (world.kind == selected) { current = world; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF02010A),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _GalaxyBackground(clock.value)),
          CustomPaint(painter: _GalaxySystemPainter(clock.value, state.zoom)),
          _WorldNodes(worlds: widget.worlds, phase: clock.value, zoom: state.zoom, selected: selected, hovered: hovered, compact: compact, onSelect: _select, onOpen: _open, onHover: (w) => setState(() => hovered = w?.kind)),
          Positioned(left: compact ? 18 : 34, top: compact ? 18 : 30, child: const _GalaxyTitle()),
          Positioned(right: compact ? 18 : 34, top: compact ? 18 : 30, child: _MinimalControls(
            onReset: () { session.resetRenderState(compact: compact); _clear(); },
            onZoomIn: () => session.updateRenderState(state.copyWith(zoom: (state.zoom + .08).clamp(.82, 1.35).toDouble())),
            onZoomOut: () => session.updateRenderState(state.copyWith(zoom: (state.zoom - .08).clamp(.82, 1.35).toDouble())),
          )),
          if (current != null) Positioned(left: compact ? 18 : 34, right: compact ? 18 : 34, bottom: compact ? 18 : 30, child: _WorldInfo(world: current, index: widget.worlds.indexOf(current), count: widget.worlds.length, onClose: _clear)),
          if (current == null) Positioned(left: 0, right: 0, bottom: compact ? 18 : 30, child: const Center(child: _InteractionHint())),
        ]),
      ),
    );
  }
}

class _WorldNodes extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final double phase, zoom;
  final GalaxyWorldKind? selected, hovered;
  final bool compact;
  final ValueChanged<GalaxyWorld> onSelect, onOpen;
  final ValueChanged<GalaxyWorld?> onHover;
  const _WorldNodes({required this.worlds, required this.phase, required this.zoom, required this.selected, required this.hovered, required this.compact, required this.onSelect, required this.onOpen, required this.onHover});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final w = box.maxWidth, h = box.maxHeight, m = math.min(w, h);
    final center = Offset(w * .50, h * .51);
    final orbitW = m * (compact ? .28 : .32) * zoom;
    final orbitH = m * (compact ? .20 : .235) * zoom;
    final nodes = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final world = worlds[i];
      final a = -math.pi / 2 + i * math.pi * 2 / worlds.length + phase * math.pi * .08;
      final p = Offset(center.dx + math.cos(a) * orbitW, center.dy + math.sin(a) * orbitH);
      final depth = (math.sin(a) + 1) / 2;
      final diameter = m * (.055 + depth * .025 + (selected == world.kind ? .018 : 0));
      nodes.add(Positioned(
        left: p.dx - diameter / 2, top: p.dy - diameter / 2, width: diameter, height: diameter,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => onHover(world), onExit: (_) => onHover(null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(world),
            onDoubleTap: () => onOpen(world),
            child: _WorldOrb(index: i, selected: selected == world.kind, hovered: hovered == world.kind, depth: depth),
          ),
        ),
      ));
    }
    return Stack(children: nodes);
  });
}

class _WorldOrb extends StatelessWidget {
  final int index; final bool selected, hovered; final double depth;
  const _WorldOrb({required this.index, required this.selected, required this.hovered, required this.depth});
  @override Widget build(BuildContext context) => CustomPaint(painter: _OrbPainter(index, selected, hovered, depth));
}

class _GalaxyTitle extends StatelessWidget {
  const _GalaxyTitle();
  @override Widget build(BuildContext context) => IgnorePointer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
    Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5.5, fontWeight: FontWeight.w500)),
    SizedBox(height: 8), Text('GALAXY', style: TextStyle(color: Color(0x78FFFFFF), fontSize: 7, letterSpacing: 3.2)),
  ]));
}

class _MinimalControls extends StatelessWidget {
  final VoidCallback onReset, onZoomIn, onZoomOut;
  const _MinimalControls({required this.onReset, required this.onZoomIn, required this.onZoomOut});
  @override Widget build(BuildContext context) => Row(children: [
    _Control('+', onZoomIn), const SizedBox(width: 5), _Control('−', onZoomOut), const SizedBox(width: 5), _Control('RESET', onReset),
  ]);
}
class _Control extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _Control(this.label, this.onTap);
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: const Color(0x4A05050C), border: Border.all(color: const Color(0x22FFFFFF))), child: Text(label, style: const TextStyle(color: Color(0x70FFFFFF), fontSize: 6, letterSpacing: 1.4))));
}

class _WorldInfo extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final VoidCallback onClose;
  const _WorldInfo({required this.world, required this.index, required this.count, required this.onClose});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 15, 12, 15),
    decoration: BoxDecoration(color: const Color(0xC9070710), border: Border.all(color: const Color(0x28FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]),
    child: Row(children: [
      Container(width: 3, height: 42, color: const Color(0x667D5AA2)), const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5.5, letterSpacing: 1.6)),
        const SizedBox(height: 4), Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2.6)),
        const SizedBox(height: 4), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x68FFFFFF), fontSize: 7.5)),
      ])),
      InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(8), child: Text('×', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 18)))),
    ]),
  );
}

class _InteractionHint extends StatelessWidget {
  const _InteractionHint();
  @override Widget build(BuildContext context) => const Text('CLICK TO FOCUS   •   DOUBLE-CLICK TO ENTER', style: TextStyle(color: Color(0x45FFFFFF), fontSize: 6.5, letterSpacing: 1.8));
}

class _GalaxyBackground extends CustomPainter {
  final double phase;
  const _GalaxyBackground(this.phase);
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF05030C), Color(0xFF02020A), Color(0xFF090414)]).createShader(rect));
    final random = math.Random(7719);
    for (var i = 0; i < 420; i++) {
      final a = .035 + random.nextDouble() * .22;
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .2 + random.nextDouble() * .8, Paint()..color = Colors.white.withValues(alpha: a));
    }
    final c = Offset(size.width * .50, size.height * .51);
    final glow = math.min(size.width, size.height) * .44;
    canvas.drawCircle(c, glow, Paint()..shader = RadialGradient(colors: [const Color(0xFF67457A).withValues(alpha: .08), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: glow)));
  }
  @override bool shouldRepaint(covariant _GalaxyBackground old) => old.phase != phase;
}

class _GalaxySystemPainter extends CustomPainter {
  final double phase, zoom;
  const _GalaxySystemPainter(this.phase, this.zoom);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .50, size.height * .51), m = math.min(size.width, size.height);
    final ow = m * .32 * zoom, oh = m * .235 * zoom;
    final orbit = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x1FFFFFFF);
    canvas.drawOval(Rect.fromCenter(center: center, width: ow * 2, height: oh * 2), orbit);
    final inner = Paint()..style = PaintingStyle.stroke..strokeWidth = .35..color = const Color(0x0FFFFFFF);
    canvas.drawOval(Rect.fromCenter(center: center, width: ow * 1.45, height: oh * 1.45), inner);
    canvas.drawOval(Rect.fromCenter(center: center, width: ow * .68, height: oh * .68), inner);
    final core = m * .055;
    canvas.drawCircle(center, core * 2.6, Paint()..shader = RadialGradient(colors: [const Color(0xFFA77BC8).withValues(alpha: .13), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: core * 2.6)));
    canvas.drawCircle(center, core, Paint()..shader = const RadialGradient(colors: [Color(0xFFD7CBE3), Color(0xFF755A86), Color(0xFF15101B)]).createShader(Rect.fromCircle(center: center, radius: core)));
    canvas.drawCircle(center, core * .82, Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x70FFFFFF));
    final sweep = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x35FFFFFF);
    canvas.drawArc(Rect.fromCenter(center: center, width: ow * 1.9, height: oh * 1.9), phase * math.pi * 2, math.pi * .55, false, sweep);
  }
  @override bool shouldRepaint(covariant _GalaxySystemPainter old) => old.phase != phase || old.zoom != zoom;
}

class _OrbPainter extends CustomPainter {
  final int index; final bool selected, hovered; final double depth;
  _OrbPainter(this.index, this.selected, this.hovered, this.depth);
  @override void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = math.min(size.width, size.height) * .32;
    final halo = r * (selected ? 2.0 : hovered ? 1.55 : 1.25);
    canvas.drawCircle(c, halo, Paint()..shader = RadialGradient(colors: [const Color(0xFF9A78B0).withValues(alpha: selected ? .23 : .13), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: halo)));
    final body = Paint()..shader = const RadialGradient(center: Alignment(-.3, -.35), radius: 1.0, colors: [Color(0xFFE6DFEA), Color(0xFF7D668A), Color(0xFF17121D)]).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, body);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * .74), math.pi * .1, math.pi * .95, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .10..color = const Color(0x55100C14));
    if (selected || hovered) canvas.drawCircle(c, r * 1.18, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.5 : .8..color = const Color(0x99FFFFFF));
  }
  @override bool shouldRepaint(covariant _OrbPainter old) => old.index != index || old.selected != selected || old.hovered != hovered || old.depth != depth;
}
