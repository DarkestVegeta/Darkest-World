import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  final session = GalaxyNavigationSession.instance;
  GalaxyWorldKind? selected;
  GalaxyWorldKind? hovered;
  GalaxyRenderState get render => session.renderState;

  @override
  void initState() { super.initState(); session.addListener(_sessionChanged); }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final compact = MediaQuery.sizeOf(context).width < 760;
    if (render.compact != compact) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) session.updateRenderState(render.copyWith(compact: compact)); });
  }
  @override
  void dispose() { session.removeListener(_sessionChanged); clock.dispose(); super.dispose(); }
  void _sessionChanged() { if (mounted) setState(() {}); }
  void _update(GalaxyRenderState next) => session.updateRenderState(next);
  GalaxyWorld? get current { if (selected == null) return null; for (final world in widget.worlds) { if (world.kind == selected) return world; } return null; }
  void _select(GalaxyWorld world) { final next = selected == world.kind ? null : world.kind; setState(() => selected = next); if (next == null) { session.clearSelection(); } else { session.select(next); } }
  void _visit() { final world = current; if (world != null) widget.onWorldTap?.call(world); }
  void _clear() { if (selected == null) return; setState(() => selected = null); session.clearSelection(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final state = render;
    final chosen = current;
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const <ShortcutActivator, Intent>{ SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(), SingleActivator(LogicalKeyboardKey.escape): DismissIntent() },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { _visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { _clear(); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020207),
        body: GestureDetector(
          onScaleUpdate: (details) { if (details.pointerCount > 1) { _update(state.copyWith(zoom: (state.zoom * details.scale).clamp(.72, 1.55).toDouble())); } else { _update(state.copyWith(orbit: state.orbit + details.focalPointDelta.dx / math.max(260, size.width))); } },
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _SpacePainter(clock.value, state.cinematic)),
              Transform.scale(scale: state.zoom, child: CustomPaint(painter: _OrbitPainter(clock.value, state.orbit, state.systemMap, state.detail))),
              _GalaxyNodes(worlds: widget.worlds, phase: clock.value, orbit: state.orbit, selected: selected, hovered: hovered, labels: state.labels, detail: state.detail, cinematic: state.cinematic, compact: compact, onSelect: _select, onHover: (world) => setState(() => hovered = world?.kind)),
              Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: _Header(map: state.systemMap, cinematic: state.cinematic)),
              Positioned(right: compact ? 10 : 26, top: compact ? 68 : 26, child: _Controls(
                state: state,
                onZoomIn: () => _update(state.copyWith(zoom: (state.zoom + .1).clamp(.72, 1.55).toDouble())),
                onZoomOut: () => _update(state.copyWith(zoom: (state.zoom - .1).clamp(.72, 1.55).toDouble())),
                onMap: () => _update(state.copyWith(systemMap: !state.systemMap)),
                onLabels: () => _update(state.copyWith(labels: !state.labels)),
                onDetail: () => _update(state.copyWith(detail: !state.detail)),
                onCinematic: () => _update(state.copyWith(cinematic: !state.cinematic)),
                onReset: () { session.resetRenderState(compact: compact); setState(() { selected = null; hovered = null; }); },
              )),
              Positioned(left: compact ? 16 : 34, top: compact ? 98 : 96, child: _Telemetry(phase: clock.value, state: state, selected: chosen, hovered: hovered)),
              if (chosen != null) Positioned(left: compact ? 16 : 34, right: compact ? 16 : 34, bottom: compact ? 18 : 28, child: _VisitPanel(world: chosen, index: widget.worlds.indexOf(chosen), count: widget.worlds.length, onVisit: _visit, onClose: _clear)) else const Positioned(left: 0, right: 0, bottom: 20, child: Center(child: _Hint())),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GalaxyNodes extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected, hovered; final bool labels, detail, cinematic, compact; final ValueChanged<GalaxyWorld> onSelect; final ValueChanged<GalaxyWorld?> onHover;
  const _GalaxyNodes({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.onSelect, required this.onHover});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth, height = constraints.maxHeight, minSide = math.min(width, height);
    final center = Offset(width * .52, height * .52), radius = minSide * (compact ? .25 : .29);
    final nodes = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final world = worlds[i], angle = i / math.max(1, worlds.length) * math.pi * 2 + orbit * .9;
      final depth = (math.sin(angle) + 1) / 2;
      final nodeRadius = minSide * (.035 + depth * .025 + (selected == world.kind ? .016 : 0) + (hovered == world.kind ? .009 : 0));
      final nodeSize = nodeRadius * 3.0, x = center.dx + math.cos(angle) * radius * 1.62, y = center.dy + math.sin(angle) * radius * .72;
      nodes.add(Positioned(left: x - nodeSize / 2, top: y - nodeSize / 2, width: nodeSize, height: nodeSize, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(world), onExit: (_) => onHover(null), child: GestureDetector(onTap: () => onSelect(world), child: CustomPaint(painter: _NodePainter(world, phase, i, selected == world.kind, hovered == world.kind, labels, detail, cinematic))))));
    }
    return Stack(children: nodes);
  });
}

class _Header extends StatelessWidget {
  final bool map, cinematic; const _Header({required this.map, required this.cinematic});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)), const SizedBox(height: 7), Text(map ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white54, fontSize: 7, letterSpacing: 2.6)), const SizedBox(height: 5), Text(cinematic ? '09 WORLD NODES  •  DEEP SPACE' : '09 WORLD NODES  •  PERFORMANCE MODE', style: const TextStyle(color: Colors.white30, fontSize: 6, letterSpacing: 1.6))]);
}
class _Controls extends StatelessWidget {
  final GalaxyRenderState state; final VoidCallback onZoomIn, onZoomOut, onMap, onLabels, onDetail, onCinematic, onReset;
  const _Controls({required this.state, required this.onZoomIn, required this.onZoomOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onCinematic, required this.onReset});
  @override Widget build(BuildContext context) => Wrap(spacing: 4, children: [_Button('+', onZoomIn), _Button('−', onZoomOut), _Button(state.systemMap ? 'ORBIT' : 'MAP', onMap), _Button(state.labels ? 'LABELS' : 'CLEAN', onLabels), _Button(state.detail ? 'DETAIL' : 'MINIMAL', onDetail), _Button(state.cinematic ? 'CINEMATIC' : 'EFFICIENT', onCinematic), _Button('RESET', onReset)]);
}
class _Button extends StatelessWidget {
  final String text; final VoidCallback onTap; const _Button(this.text, this.onTap);
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .72), border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 6, letterSpacing: 1.1))));
}
class _Telemetry extends StatelessWidget {
  final double phase; final GalaxyRenderState state; final GalaxyWorld? selected; final GalaxyWorldKind? hovered;
  const _Telemetry({required this.phase, required this.state, required this.selected, required this.hovered});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${state.systemMap ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title ?? 'SCANNING'}', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 1.5)), const SizedBox(height: 4), Text('AZ ${(phase * 360).round() % 360}°  •  Z ${(state.zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.1))]);
}
class _VisitPanel extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final VoidCallback onVisit, onClose;
  const _VisitPanel({required this.world, required this.index, required this.count, required this.onVisit, required this.onClose});
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .78), border: Border.all(color: Colors.white12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${index + 1} / $count', style: const TextStyle(color: Colors.white30, fontSize: 6, letterSpacing: 1.5)), const SizedBox(height: 4), Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2.5)), const SizedBox(height: 4), Text(world.description, style: const TextStyle(color: Colors.white54, fontSize: 8, letterSpacing: .7))]))),
    const SizedBox(width: 6), _Button('ENTER', onVisit), const SizedBox(width: 4), _Button('CLOSE', onClose),
  ]);
}
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => Text('SELECT A WORLD  •  DRAG TO ORBIT  •  SCROLL/CONTROLS TO ZOOM', style: const TextStyle(color: Colors.white30, fontSize: 6, letterSpacing: 1.5)); }
class _SpacePainter extends CustomPainter {
  final double phase; final bool cinematic; _SpacePainter(this.phase, this.cinematic);
  @override void paint(Canvas canvas, Size size) { canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF020207)); final random = math.Random(1207); final count = cinematic ? 230 : 130; for (var i = 0; i < count; i++) { final x = random.nextDouble() * size.width, y = random.nextDouble() * size.height, r = .25 + random.nextDouble() * (cinematic ? 1.15 : .8), a = .10 + random.nextDouble() * .35; canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: a)); } final center = Offset(size.width * .52, size.height * .52); final glow = math.min(size.width, size.height) * (cinematic ? .28 : .20); canvas.drawCircle(center, glow, Paint()..shader = RadialGradient(colors: [const Color(0xFF6D4C82).withValues(alpha: .13), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glow))); }
  @override bool shouldRepaint(covariant _SpacePainter old) => old.phase != phase || old.cinematic != cinematic;
}
class _OrbitPainter extends CustomPainter {
  final double phase, orbit; final bool map, detail; _OrbitPainter(this.phase, this.orbit, this.map, this.detail);
  @override void paint(Canvas canvas, Size size) { final center = Offset(size.width * .52, size.height * .52), m = math.min(size.width, size.height), paint = Paint()..style = PaintingStyle.stroke; for (var i = 0; i < 16; i++) { final r = m * (.10 + i * .031); paint.color = Colors.white.withValues(alpha: (map ? .032 : .017) + (detail && i % 4 == 0 ? .018 : 0)); paint.strokeWidth = i == 7 ? 1.0 : .38; canvas.drawOval(Rect.fromCenter(center: center, width: r * 2.45, height: r * .62), paint); } final glow = m * .06; canvas.drawCircle(center, glow, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .65), const Color(0xFF76538F).withValues(alpha: .35), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glow))); }
  @override bool shouldRepaint(covariant _OrbitPainter old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail;
}
class _NodePainter extends CustomPainter {
  final GalaxyWorld world; final double phase; final int index; final bool selected, hovered, labels, detail, cinematic;
  _NodePainter(this.world, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cinematic);
  @override void paint(Canvas canvas, Size size) { final center = Offset(size.width / 2, size.height / 2), radius = math.min(size.width, size.height) * .30; final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 2.0 : .8..color = (selected || hovered ? Colors.white70 : Colors.white24); canvas.drawCircle(center, radius, ring); final fill = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: selected ? .9 : .58), const Color(0xFF735080).withValues(alpha: .75), const Color(0xFF11101A)]).createShader(Rect.fromCircle(center: center, radius: radius)); canvas.drawCircle(center, radius * .72, fill); if (detail) { canvas.drawCircle(center, radius * .90, Paint()..style = PaintingStyle.stroke..strokeWidth = .35..color = Colors.white12); canvas.drawLine(Offset(center.dx - radius * .55, center.dy), Offset(center.dx + radius * .55, center.dy), Paint()..color = Colors.white10..strokeWidth = .4); } if (labels) { final tp = TextPainter(text: TextSpan(text: world.title, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: math.max(6, size.width * .055), letterSpacing: 1.0)), textDirection: TextDirection.ltr)..layout(maxWidth: size.width * 2.8); tp.paint(canvas, Offset(center.dx - tp.width / 2, size.height * .78)); } }
  @override bool shouldRepaint(covariant _NodePainter old) => old.phase != phase || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.cinematic != cinematic || old.world.title != world.title;
}
