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
  void initState() {
    super.initState();
    session.addListener(_sessionChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncCompact(MediaQuery.sizeOf(context).width < 760);
  }

  @override
  void dispose() {
    session.removeListener(_sessionChanged);
    clock.dispose();
    super.dispose();
  }

  void _sessionChanged() {
    if (mounted) setState(() {});
  }

  void _updateRender(GalaxyRenderState next) {
    session.updateRenderState(next);
  }

  void _syncCompact(bool compact) {
    if (render.compact == compact) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || render.compact == compact) return;
      _updateRender(render.copyWith(compact: compact));
    });
  }

  GalaxyWorld? get current => selected == null ? null : widget.worlds.cast<GalaxyWorld?>().firstWhere((w) => w!.kind == selected, orElse: () => null);

  void select(GalaxyWorld w) {
    final next = selected == w.kind ? null : w.kind;
    setState(() => selected = next);
    if (next == null) {
      session.clearSelection();
    } else {
      session.select(next);
    }
  }

  void clearSelection() {
    if (selected == null) return;
    setState(() => selected = null);
    session.clearSelection();
  }

  void visit() {
    final w = current;
    if (w != null) widget.onWorldTap?.call(w);
  }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final chosen = current;
    final state = render;
    if (state.compact != compact) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncCompact(compact));
    }
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { clearSelection(); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: GestureDetector(
          onScaleUpdate: (d) {
            if (d.pointerCount > 1) {
              _updateRender(state.copyWith(zoom: (state.zoom * d.scale).clamp(.66, 1.70).toDouble()));
            } else {
              _updateRender(state.copyWith(orbit: state.orbit + d.focalPointDelta.dx / math.max(220.0, size.width)));
            }
          },
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _DeepSpacePainter(clock.value, state.detail, state.cinematic)),
              CustomPaint(painter: _GalaxyDustPainter(clock.value, state.cinematic)),
              Transform.scale(
                scale: state.zoom,
                child: CustomPaint(painter: _OrbitArchitecturePainter(clock.value, state.orbit, state.systemMap, state.detail)),
              ),
              _WorldOrbit(
                worlds: widget.worlds,
                phase: clock.value,
                orbit: state.orbit,
                selected: selected,
                hovered: hovered,
                labels: state.labels,
                detail: state.detail,
                cinematic: state.cinematic,
                compact: state.compact,
                onTap: select,
                onHover: (w) => setState(() => hovered = w?.kind),
              ),
              _Header(systemMap: state.systemMap, compact: state.compact, cinematic: state.cinematic),
              Positioned(right: state.compact ? 10 : 26, top: state.compact ? 70 : 26, child: _Controls(
                map: state.systemMap,
                labels: state.labels,
                detail: state.detail,
                cinematic: state.cinematic,
                onIn: () => _updateRender(state.copyWith(zoom: (state.zoom + .1).clamp(.66, 1.70).toDouble())),
                onOut: () => _updateRender(state.copyWith(zoom: (state.zoom - .1).clamp(.66, 1.70).toDouble())),
                onMap: () => _updateRender(state.copyWith(systemMap: !state.systemMap)),
                onLabels: () => _updateRender(state.copyWith(labels: !state.labels)),
                onDetail: () => _updateRender(state.copyWith(detail: !state.detail)),
                onCinematic: () => _updateRender(state.copyWith(cinematic: !state.cinematic)),
                onReset: () {
                  session.resetRenderState(compact: state.compact);
                  setState(() { selected = null; hovered = null; });
                },
              )),
              Positioned(left: state.compact ? 12 : 30, top: state.compact ? 112 : 92, child: _Telemetry(phase: clock.value, selected: chosen, hovered: hovered, map: state.systemMap, zoom: state.zoom, cinematic: state.cinematic)),
              if (chosen != null)
                _FloatingVisitPanel(world: chosen, compact: state.compact, phase: clock.value, orbit: state.orbit, count: widget.worlds.length, index: widget.worlds.indexOf(chosen), onVisit: visit, onClose: clearSelection)
              else const Positioned(left: 0, right: 0, bottom: 22, child: Center(child: _Hint())),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool systemMap, compact, cinematic;
  const _Header({required this.systemMap, required this.compact, required this.cinematic});
  @override Widget build(BuildContext context) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)),
    const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5),
    Text(cinematic ? '09 WORLD NODES  •  DEEP SPACE' : '09 WORLD NODES  •  PERFORMANCE MODE', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]));
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail, cinematic;
  final VoidCallback onIn, onOut, onMap, onLabels, onDetail, onCinematic, onReset;
  const _Controls({required this.map, required this.labels, required this.detail, required this.cinematic, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onCinematic, required this.onReset});
  @override Widget build(BuildContext context) => Wrap(spacing: 4, children: [
    _Btn('+', onIn), _Btn('−', onOut), _Btn(map ? 'ORBIT' : 'MAP', onMap), _Btn(labels ? 'LABELS' : 'CLEAN', onLabels), _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail), _Btn(cinematic ? 'CINEMATIC' : 'EFFICIENT', onCinematic), _Btn('RESET', onReset),
  ]);
}

class _Btn extends StatelessWidget {
  final String text; final VoidCallback onTap;
  const _Btn(this.text, this.onTap);
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .62), border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.1))));
}

class _Telemetry extends StatelessWidget {
  final double phase, zoom; final GalaxyWorld? selected; final GalaxyWorldKind? hovered; final bool map, cinematic;
  const _Telemetry({required this.phase, required this.selected, required this.hovered, required this.map, required this.zoom, required this.cinematic});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)),
    const SizedBox(height: 4),
    Text('AZ ${(phase * 360).round() % 360}°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)),
    const SizedBox(height: 3),
    Text(cinematic ? 'RENDER / CINEMATIC' : 'RENDER / EFFICIENT', style: const TextStyle(color: Colors.white10, fontSize: 5.5, letterSpacing: 1.2)),
  ]);
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected, hovered; final bool labels, detail, cinematic, compact; final ValueChanged<GalaxyWorld> onTap; final ValueChanged<GalaxyWorld?> onHover;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => Stack(children: [
    CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _CentralSystemPainter(phase, orbit, detail, cinematic)),
    for (var i = 0; i < worlds.length; i++) _WorldNode(world: worlds[i], index: i, count: worlds.length, phase: phase, orbit: orbit, selected: selected == worlds[i].kind, hovered: hovered == worlds[i].kind, labels: labels, detail: detail, cinematic: cinematic, compact: compact, onTap: () => onTap(worlds[i]), onHover: (v) => onHover(v ? worlds[i] : null)),
  ]));
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, orbit; final bool selected, hovered, labels, detail, cinematic, compact; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _WorldNode({required this.world, required this.index, required this.count, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final minSide = math.min(c.maxWidth, c.maxHeight);
    final angle = index / math.max(1, count) * math.pi * 2 + orbit * .9;
    final rr = minSide * (compact ? .255 : .285);
    final x = c.maxWidth * .52 + math.cos(angle) * rr * 1.62;
    final y = c.maxHeight * .52 + math.sin(angle) * rr * .72;
    final depth = (math.sin(angle) + 1) / 2;
    final radius = minSide * (.041 + depth * .024 + (selected ? .019 : 0) + (hovered ? .011 : 0));
    final size = radius * 3.45;
    return Positioned(left: x - size / 2, top: y - size / 2, width: size, height: size, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(true), onExit: (_) => onHover(false), child: GestureDetector(onTap: onTap, child: CustomPaint(painter: _NodePainter(world.kind, phase, index, selected, hovered, labels, detail, cinematic, world.title)))));
  });
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit; final bool detail, cinematic;
  _CentralSystemPainter(this.phase, this.orbit, this.detail, this.cinematic);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke;
    final bands = cinematic ? 20 : 13;
    for (var i = 0; i < bands; i++) { final r = m * (.075 + i * .032); p.color = Colors.white.withValues(alpha: .012 + (i % 4) * .007); p.strokeWidth = i % 6 == 0 ? 1.0 : .38; final tilt = .25 + (i % 6) * .035; c.drawOval(Rect.fromCenter(center: center, width: r * 2.55, height: r * tilt * 2), p); }
    final markers = cinematic ? 52 : 28;
    for (var i = 0; i < markers; i++) { final a = phase * math.pi * 2 * (.18 + (i % 7) * .032) + orbit * .45 + i * math.pi * 2 / markers; final r = m * (.12 + (i % 13) * .022); final q = Offset(center.dx + math.cos(a) * r * 1.34, center.dy + math.sin(a) * r * .46); c.drawCircle(q, .65 + (i % 3) * .42, Paint()..color = Colors.white.withValues(alpha: .075 + (i % 4) * .018)); }
    final glowRadius = m * (cinematic ? .22 : .17);
    final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .28), const Color(0xFF76538F).withValues(alpha: .14), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    c.drawCircle(center, glowRadius, glow);
    c.drawCircle(center, m * .055, Paint()..shader = RadialGradient(colors: [Colors.white70, const Color(0xFF72508A), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .055)));
    if (detail) { for (var i = 0; i < (cinematic ? 12 : 7); i++) { final a = phase * 3.6 + i * math.pi / 6; final r = m * (.065 + (i % 4) * .014); final q = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r * .58); c.drawLine(center, q, Paint()..color = Colors.white.withValues(alpha: .022)..strokeWidth = .75); } }
  }
  @override bool shouldRepaint(covariant _CentralSystemPainter old) => old.phase != phase || old.orbit != orbit || old.detail != detail || old.cinematic != cinematic;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit; final bool map, detail;
  _OrbitArchitecturePainter(this.phase, this.orbit, this.map, this.detail);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height);
    final p = Paint()..style = PaintingStyle.stroke;
    final rings = map ? 8 : 5;
    for (var i = 0; i < rings; i++) {
      final r = m * (.19 + i * .075);
      p.color = Colors.white.withValues(alpha: map ? .035 : .018);
      p.strokeWidth = i == 0 ? 1.1 : .5;
      c.drawOval(Rect.fromCenter(center: center, width: r * 2.1, height: r * .56), p);
    }
    if (detail) {
      final rays = map ? 24 : 12;
      for (var i = 0; i < rays; i++) {
        final a = phase * math.pi * 2 * .08 + orbit + i * math.pi * 2 / rays;
        final inner = m * .16;
        final outer = m * (map ? .49 : .38);
        final from = Offset(center.dx + math.cos(a) * inner * 1.3, center.dy + math.sin(a) * inner * .36);
        final to = Offset(center.dx + math.cos(a) * outer * 1.3, center.dy + math.sin(a) * outer * .36);
        c.drawLine(from, to, Paint()..color = Colors.white.withValues(alpha: map ? .018 : .009)..strokeWidth = .5);
      }
    }
  }
  @override bool shouldRepaint(covariant _OrbitArchitecturePainter old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail;
}
