import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  GalaxyWorldKind? hovered;
  double orbit = 0;
  double orbitVelocity = 0;
  double zoom = 1;
  bool systemMap = false;
  bool labels = true;
  bool detail = true;
  bool cinematic = false;
  bool paused = false;
  bool reducedMotion = false;
  bool focus = false;

  GalaxyWorld? get current {
    final kind = selected;
    if (kind == null) return null;
    for (final world in widget.worlds) { if (world.kind == kind) return world; }
    return null;
  }

  @override void initState() { super.initState(); clock.addListener(_tick); }
  void _tick() {
    if (!mounted) return;
    if (paused) {
      if (orbitVelocity.abs() > 0.0004) setState(() { orbit += orbitVelocity; orbitVelocity *= .90; });
      return;
    }
  }
  @override void dispose() { clock.removeListener(_tick); clock.dispose(); super.dispose(); }

  void _setPaused(bool value) {
    setState(() => paused = value);
    if (value) { clock.stop(); } else { clock.repeat(); }
  }
  void _select(GalaxyWorld world) {
    setState(() { selected = selected == world.kind ? null : world.kind; orbitVelocity = 0; focus = selected != null; });
  }
  void _visit() { final world = current; if (world != null) widget.onWorldTap?.call(world); }
  void _reset() {
    setState(() { orbit = 0; orbitVelocity = 0; zoom = 1; selected = null; hovered = null; systemMap = false; labels = true; detail = true; cinematic = false; reducedMotion = false; focus = false; });
    if (paused) _setPaused(false);
  }
  void _moveSelection(int direction) {
    if (widget.worlds.isEmpty) return;
    final oldIndex = current == null ? 0 : widget.worlds.indexOf(current!);
    final next = (oldIndex + direction) % widget.worlds.length;
    final index = next < 0 ? next + widget.worlds.length : next;
    setState(() { selected = widget.worlds[index].kind; focus = true; });
  }
  GalaxyWorld? _neighbor(int direction) {
    if (widget.worlds.isEmpty) return null;
    final index = current == null ? 0 : widget.worlds.indexOf(current!);
    final next = (index + direction) % widget.worlds.length;
    return widget.worlds[next < 0 ? next + widget.worlds.length : next];
  }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final compact = size.width < 760;
    final lowPower = size.width < 1000 || dpr > 2.0;
    final effectiveCinematic = cinematic && !lowPower && !compact && !reducedMotion;
    final renderDetail = detail && !reducedMotion;
    final chosen = current;

    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.keyP): _PauseIntent(),
        SingleActivator(LogicalKeyboardKey.keyL): _LabelsIntent(),
        SingleActivator(LogicalKeyboardKey.keyM): _MapIntent(),
        SingleActivator(LogicalKeyboardKey.keyD): _DetailIntent(),
        SingleActivator(LogicalKeyboardKey.keyC): _CinemaIntent(),
        SingleActivator(LogicalKeyboardKey.keyR): _ResetIntent(),
        SingleActivator(LogicalKeyboardKey.keyJ): _PreviousIntent(),
        SingleActivator(LogicalKeyboardKey.keyK): _NextIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): _FocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _PreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _NextIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { _visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { setState(() { selected = null; focus = false; }); return null; }),
        _PauseIntent: CallbackAction<_PauseIntent>(onInvoke: (_) { _setPaused(!paused); return null; }),
        _LabelsIntent: CallbackAction<_LabelsIntent>(onInvoke: (_) { setState(() => labels = !labels); return null; }),
        _MapIntent: CallbackAction<_MapIntent>(onInvoke: (_) { setState(() => systemMap = !systemMap); return null; }),
        _DetailIntent: CallbackAction<_DetailIntent>(onInvoke: (_) { setState(() => detail = !detail); return null; }),
        _CinemaIntent: CallbackAction<_CinemaIntent>(onInvoke: (_) { setState(() => cinematic = !cinematic); return null; }),
        _ResetIntent: CallbackAction<_ResetIntent>(onInvoke: (_) { _reset(); return null; }),
        _PreviousIntent: CallbackAction<_PreviousIntent>(onInvoke: (_) { _moveSelection(-1); return null; }),
        _NextIntent: CallbackAction<_NextIntent>(onInvoke: (_) { _moveSelection(1); return null; }),
        _FocusIntent: CallbackAction<_FocusIntent>(onInvoke: (_) { setState(() => focus = !focus); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: GestureDetector(
          onScaleStart: (_) => orbitVelocity = 0,
          onScaleUpdate: (d) {
            if (d.pointerCount > 1) {
              setState(() => zoom = (zoom * d.scale).clamp(.66, 1.70).toDouble());
            } else if (!reducedMotion) {
              setState(() { final delta = d.focalPointDelta.dx / math.max(220.0, size.width); orbit += delta; orbitVelocity = delta; });
            }
          },
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              RepaintBoundary(child: CustomPaint(painter: _DeepSpacePainter(clock.value, renderDetail, effectiveCinematic, reducedMotion))),
              if (!reducedMotion) RepaintBoundary(child: CustomPaint(painter: _GalaxyDustPainter(clock.value, effectiveCinematic))),
              Transform.scale(scale: zoom, child: RepaintBoundary(child: CustomPaint(painter: _OrbitArchitecturePainter(clock.value, orbit, systemMap, renderDetail, effectiveCinematic)))),
              _WorldOrbit(worlds: widget.worlds, phase: clock.value, orbit: orbit, selected: selected, hovered: hovered, labels: labels, detail: renderDetail, cinematic: effectiveCinematic, compact: compact, systemMap: systemMap, focus: focus, onTap: _select, onHover: (w) => setState(() => hovered = w?.kind)),
              _Header(systemMap: systemMap, compact: compact, cinematic: effectiveCinematic, paused: paused, lowPower: lowPower, focus: focus),
              Positioned(right: compact ? 10 : 26, top: compact ? 70 : 26, child: _Controls(map: systemMap, labels: labels, detail: detail, cinematic: effectiveCinematic, paused: paused, reducedMotion: reducedMotion, focus: focus, onIn: () => setState(() => zoom = (zoom + .1).clamp(.66, 1.70).toDouble()), onOut: () => setState(() => zoom = (zoom - .1).clamp(.66, 1.70).toDouble()), onMap: () => setState(() => systemMap = !systemMap), onLabels: () => setState(() => labels = !labels), onDetail: () => setState(() => detail = !detail), onCinematic: () => setState(() => cinematic = !cinematic), onPause: () => _setPaused(!paused), onReducedMotion: () => setState(() => reducedMotion = !reducedMotion), onFocus: () => setState(() => focus = !focus), onReset: _reset)),
              Positioned(left: compact ? 12 : 30, top: compact ? 112 : 92, child: _Telemetry(phase: clock.value, selected: chosen, hovered: hovered, map: systemMap, zoom: zoom, cinematic: effectiveCinematic, paused: paused, lowPower: lowPower, focus: focus)),
              if (chosen != null) _FloatingVisitPanel(world: chosen, compact: compact, phase: clock.value, orbit: orbit, count: widget.worlds.length, index: widget.worlds.indexOf(chosen), previous: _neighbor(-1), next: _neighbor(1), onPrevious: () => _moveSelection(-1), onNext: () => _moveSelection(1), onVisit: _visit, onClose: () => setState(() { selected = null; focus = false; }))
              else const Positioned(left: 0, right: 0, bottom: 22, child: Center(child: _Hint())),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PauseIntent extends Intent { const _PauseIntent(); }
class _LabelsIntent extends Intent { const _LabelsIntent(); }
class _MapIntent extends Intent { const _MapIntent(); }
class _DetailIntent extends Intent { const _DetailIntent(); }
class _CinemaIntent extends Intent { const _CinemaIntent(); }
class _ResetIntent extends Intent { const _ResetIntent(); }
class _PreviousIntent extends Intent { const _PreviousIntent(); }
class _NextIntent extends Intent { const _NextIntent(); }
class _FocusIntent extends Intent { const _FocusIntent(); }

class _Header extends StatelessWidget {
  final bool systemMap, compact, cinematic, paused, lowPower, focus;
  const _Header({required this.systemMap, required this.compact, required this.cinematic, required this.paused, required this.lowPower, required this.focus});
  @override Widget build(BuildContext context) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)), const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : focus ? 'GALAXY / TARGET FOCUS' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)), const SizedBox(height: 5),
    Text(paused ? 'WORLD NODES  •  PAUSED' : cinematic ? 'WORLD NODES  •  CINEMATIC' : lowPower ? 'WORLD NODES  •  EFFICIENT' : focus ? 'WORLD NODES  •  TARGET LOCK' : 'WORLD NODES  •  SAFE RENDER', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]));
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail, cinematic, paused, reducedMotion, focus;
  final VoidCallback onIn, onOut, onMap, onLabels, onDetail, onCinematic, onPause, onReducedMotion, onFocus, onReset;
  const _Controls({required this.map, required this.labels, required this.detail, required this.cinematic, required this.paused, required this.reducedMotion, required this.focus, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onCinematic, required this.onPause, required this.onReducedMotion, required this.onFocus, required this.onReset});
  @override Widget build(BuildContext context) => Wrap(spacing: 4, runSpacing: 4, children: [
    _Btn('+', onIn), _Btn('−', onOut), _Btn(map ? 'ORBIT' : 'MAP', onMap), _Btn(labels ? 'LABELS' : 'CLEAN', onLabels),
    _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail), _Btn(cinematic ? 'CINEMATIC' : 'SAFE', onCinematic), _Btn(focus ? 'FOCUS ON' : 'FOCUS', onFocus), _Btn(paused ? 'PLAY' : 'PAUSE', onPause),
    _Btn(reducedMotion ? 'MOTION OFF' : 'MOTION', onReducedMotion), _Btn('RESET', onReset),
  ]);
}

class _Btn extends StatelessWidget {
  final String text; final VoidCallback onTap;
  const _Btn(this.text, this.onTap);
  @override Widget build(BuildContext context) => Semantics(button: true, label: text, child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(.62), border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.1)))));
}

class _Telemetry extends StatelessWidget {
  final double phase, zoom; final GalaxyWorld? selected; final GalaxyWorldKind? hovered; final bool map, cinematic, paused, lowPower, focus;
  const _Telemetry({required this.phase, required this.selected, required this.hovered, required this.map, required this.zoom, required this.cinematic, required this.paused, required this.lowPower, required this.focus});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('${map ? 'SYSTEM MAP' : focus ? 'TARGET FOCUS' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)), const SizedBox(height: 4),
    Text('AZ ${(phase * 360).round() % 360}°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)), const SizedBox(height: 3),
    Text(paused ? 'RENDER / PAUSED' : cinematic ? 'RENDER / CINEMATIC' : lowPower ? 'RENDER / EFFICIENT' : focus ? 'RENDER / FOCUS' : 'RENDER / SAFE', style: const TextStyle(color: Colors.white10, fontSize: 5.5, letterSpacing: 1.2)),
  ]);
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected, hovered; final bool labels, detail, cinematic, compact, systemMap, focus; final ValueChanged<GalaxyWorld> onTap; final ValueChanged<GalaxyWorld?> onHover;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.systemMap, required this.focus, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => Stack(children: [
    CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _CentralSystemPainter(phase, orbit, detail, cinematic, systemMap, worlds.length)),
    if (systemMap) CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _RoutePainter(worlds.length, phase, orbit, selected)),
    for (var i = 0; i < worlds.length; i++) _WorldNode(world: worlds[i], index: i, count: worlds.length, phase: phase, orbit: orbit, selected: selected == worlds[i].kind, hovered: hovered == worlds[i].kind, anySelected: selected != null, labels: labels, detail: detail, cinematic: cinematic, compact: compact, focus: focus, onTap: () => onTap(worlds[i]), onHover: (v) => onHover(v ? worlds[i] : null)),
  ]));
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, orbit; final bool selected, hovered, anySelected, labels, detail, cinematic, compact, focus; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _WorldNode({required this.world, required this.index, required this.count, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.anySelected, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.focus, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final minSide = math.min(c.maxWidth, c.maxHeight);
    final spacing = count <= 3 ? .36 : count <= 6 ? .32 : count <= 9 ? .285 : .255;
    final angle = index / math.max(1, count) * math.pi * 2 + orbit * .9;
    final rr = minSide * (compact ? spacing * .90 : spacing);
    final targetAngle = -math.pi * .25;
    final focusOffset = focus && selected ? _shortAngle(targetAngle - angle) * .18 : 0.0;
    final finalAngle = angle + focusOffset;
    final x = c.maxWidth * .52 + math.cos(finalAngle) * rr * 1.62; final y = c.maxHeight * .52 + math.sin(finalAngle) * rr * .72; final depth = (math.sin(finalAngle) + 1) / 2;
    final radius = minSide * (.041 + depth * .024 + (selected ? .022 : 0) + (hovered ? .011 : 0)); final size = radius * 3.45;
    return Positioned(left: x - size / 2, top: y - size / 2, width: size, height: size, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(true), onExit: (_) => onHover(false), child: Semantics(button: true, label: world.title, child: GestureDetector(onTap: onTap, child: Opacity(opacity: anySelected && !selected ? .48 : 1, child: CustomPaint(painter: _NodePainter(world.kind, phase, index, selected, hovered, labels, detail, cinematic, world.title)))))));
  });
  double _shortAngle(double value) { while (value > math.pi) value -= math.pi * 2; while (value < -math.pi) value += math.pi * 2; return value; }
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit; final bool detail, cinematic, map; final int count;
  _CentralSystemPainter(this.phase, this.orbit, this.detail, this.cinematic, this.map, this.count);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke;
    final bands = cinematic ? 12 : 7;
    for (var i = 0; i < bands; i++) { final r = m * (.075 + i * .036); p.color = Colors.white.withOpacity(.010 + (i % 4) * .005); p.strokeWidth = i % 5 == 0 ? .8 : .32; final tilt = .25 + (i % 6) * .035; c.drawOval(Rect.fromCenter(center: center, width: r * 2.55, height: r * tilt * 2), p); }
    if (map) { final route = Paint()..color = Colors.white.withOpacity(.035)..style = PaintingStyle.stroke..strokeWidth = .8; final path = Path(); for (var i = 0; i < math.max(3, count); i++) { final a = i / math.max(3, count) * math.pi * 2 + orbit * .9; final r = m * .19 + i * m * .018; final q = Offset(center.dx + math.cos(a) * r * 1.8, center.dy + math.sin(a) * r * .78); if (i == 0) path.moveTo(q.dx, q.dy); else path.lineTo(q.dx, q.dy); } path.close(); c.drawPath(path, route); }
    final markers = cinematic ? 24 : 10;
    for (var i = 0; i < markers; i++) { final a = phase * math.pi * 2 * (.18 + (i % 7) * .032) + orbit * .45 + i * math.pi * 2 / markers; final r = m * (.12 + (i % 13) * .022); final q = Offset(center.dx + math.cos(a) * r * 1.34, center.dy + math.sin(a) * r * .46); c.drawCircle(q, .55 + (i % 3) * .3, Paint()..color = Colors.white.withOpacity(.055 + (i % 4) * .01)); }
    final glowRadius = m * (cinematic ? .19 : .14); final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(.20), const Color(0xFF76538F).withOpacity(.10), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glowRadius)); c.drawCircle(center, glowRadius, glow); c.drawCircle(center, m * .055, Paint()..shader = RadialGradient(colors: [Colors.white70, const Color(0xFF72508A), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .055)));
    if (detail) for (var i = 0; i < (cinematic ? 7 : 4); i++) { final a = phase * 3.6 + i * math.pi / 6; final r = m * (.065 + (i % 4) * .014); final q = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r * .58); c.drawLine(center, q, Paint()..color = Colors.white.withOpacity(.018)..strokeWidth = .6); }
  }
  @override bool shouldRepaint(covariant _CentralSystemPainter old) => old.phase != phase || old.orbit != orbit || old.detail != detail || old.cinematic != cinematic || old.map != map || old.count != count;
}

class _RoutePainter extends CustomPainter {
  final int count; final double phase, orbit; final GalaxyWorldKind? selected;
  _RoutePainter(this.count, this.phase, this.orbit, this.selected);
  @override void paint(Canvas c, Size s) {
    if (count < 2) return;
    final m = math.min(s.width, s.height); final center = Offset(s.width * .52, s.height * .52); final rr = m * (count <= 3 ? .36 : count <= 6 ? .32 : .285);
    final points = <Offset>[];
    for (var i = 0; i < count; i++) { final a = i / count * math.pi * 2 + orbit * .9; points.add(Offset(center.dx + math.cos(a) * rr * 1.62, center.dy + math.sin(a) * rr * .72)); }
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = selected == null ? .5 : .75..color = Colors.white.withOpacity(selected == null ? .018 : .035);
    for (var i = 0; i < points.length; i++) { final next = points[(i + 1) % points.length]; c.drawLine(points[i], next, line); }
    final pulse = (math.sin(phase * math.pi * 2) + 1) / 2; final p = Paint()..color = Colors.white.withOpacity(.06 + pulse * .05);
    for (var i = 0; i < points.length; i++) { if (i % 2 == 0) c.drawCircle(points[i], 1.2 + pulse * 1.2, p); }
  }
  @override bool shouldRepaint(covariant _RoutePainter old) => old.count != count || old.phase != phase || old.orbit != orbit || old.selected != selected;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit; final bool map, detail, cinematic;
  _OrbitArchitecturePainter(this.phase, this.orbit, this.map, this.detail, this.cinematic);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke; final rings = cinematic ? 9 : 6;
    for (var i = 0; i < rings; i++) { final r = m * (.12 + i * .042); p.color = Colors.white.withOpacity(map ? .030 : .015 + (i % 3) * .004); p.strokeWidth = i == rings ~/ 2 ? .8 : .3; c.drawOval(Rect.fromCenter(center: center, width: r * 2.4, height: r * (.31 + (i % 5) * .065) * 2), p); }
    if (map) { final p2 = Paint()..color = const Color(0xFF76538F).withOpacity(.035)..style = PaintingStyle.stroke..strokeWidth = .7; c.drawOval(Rect.fromCenter(center: center, width: m * 1.10, height: m * .38), p2); }
    final markers = cinematic ? 22 : 9;
    for (var i = 0; i < markers; i++) { final a = phase * math.pi * 2 * (.22 + i % 5 * .045) + orbit * .5 + i * math.pi * 2 / markers; final r = m * (.15 + (i % 8) * .027); final q = Offset(center.dx + math.cos(a) * r * 1.20, center.dy + math.sin(a) * r * .43); c.drawCircle(q, .7 + (i % 2) * .3, Paint()..color = Colors.white.withOpacity(.055)); }
  }
  @override bool shouldRepaint(covariant _OrbitArchitecturePainter old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail || old.cinematic != cinematic;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind; final double phase; final int index; final bool selected, hovered, labels, detail, cinematic; final String title;
  _NodePainter(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cinematic, this.title);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2); final r = s.width * .30; final rect = Rect.fromCircle(center: center, radius: r);
    c.drawCircle(center, r * (hovered ? 1.85 : 1.58), Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(selected ? .20 : hovered ? .13 : .05), Colors.transparent]).createShader(rect.inflate(r)));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.04, colors: [const Color(0xFFB5BFCA), _tone(kind), const Color(0xFF03040A)]).createShader(rect));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(.70, .62), radius: .92, colors: [Colors.transparent, Colors.black.withOpacity(.72)]).createShader(rect));
    if (detail) { final contourCount = cinematic ? 5 : 3; final surface = Paint()..style = PaintingStyle.stroke; for (var j = 0; j < contourCount; j++) { final rr = r * (.42 + j * .055); final path = Path(); for (var k = 0; k <= 20; k++) { final a = k / 20 * math.pi * 2; final wave = math.sin(a * (2 + j % 3) + index * .8) * r * .025; final q = Offset(center.dx + math.cos(a) * (rr + wave), center.dy + math.sin(a) * (rr + wave) * .60); if (k == 0) path.moveTo(q.dx, q.dy); else path.lineTo(q.dx, q.dy); } surface.color = Colors.white.withOpacity(.045 - j * .004); surface.strokeWidth = .45; c.drawPath(path, surface); } }
    final dots = cinematic ? 14 : 7; for (var i = 0; i < dots; i++) { final a = i * 2.399 + index * .73; final rr = r * (.30 + ((i * 17) % 54) / 100); final q = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .63); c.drawCircle(q, .55 + (i % 3) * .3, Paint()..color = Colors.white.withOpacity(.045 + (i % 4) * .009)); }
    if (selected) { c.drawCircle(center, r * 1.22, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = .9); c.drawCircle(center, r * 1.32, Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = .5); }
    if (labels) { final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(selected ? .82 : hovered ? .72 : .42), fontSize: math.max(6, s.width * .025), letterSpacing: 1.2)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.2); tp.paint(c, Offset(center.dx - tp.width / 2, center.dy + r * 1.38)); }
  }
  @override bool shouldRepaint(covariant _NodePainter old) => old.kind != kind || old.phase != phase || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.cinematic != cinematic || old.title != title;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase; final bool detail, cinematic, reducedMotion;
  _DeepSpacePainter(this.phase, this.detail, this.cinematic, this.reducedMotion);
  @override void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height); c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107));
    final base = Paint()..shader = RadialGradient(colors: [const Color(0xFF39224F).withOpacity(.20), const Color(0xFF17234A).withOpacity(.09), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(s.width * .48, s.height * .48), radius: m * .82)); c.drawCircle(Offset(s.width * .48, s.height * .48), m * .82, base);
    final veil = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final veilLayers = cinematic ? 6 : 4;
    for (var i = 0; i < veilLayers; i++) { final path = Path(); final y0 = s.height * (.16 + i * .085); path.moveTo(-m * .10, y0); path.cubicTo(s.width * .18, y0 - m * (.15 + i * .012), s.width * .38, y0 + m * (.18 + i * .010), s.width * .62, y0 - m * (.05 + i * .008)); path.cubicTo(s.width * .80, y0 - m * (.13 + i * .012), s.width * 1.02, y0 + m * (.11 + i * .010), s.width * 1.12, y0 - m * .02); veil.color = (i.isEven ? const Color(0xFF6A4C86) : const Color(0xFF405F91)).withOpacity(.038 - i * .0025); veil.strokeWidth = m * (.070 + (i % 3) * .015); c.drawPath(path, veil); }
    final stars = cinematic ? 85 : 32;
    for (var i = 0; i < stars; i++) { final x = _noise(i * 2.13) * s.width; final y = _noise(i * 4.71 + 3) * s.height; final tw = reducedMotion ? 1.0 : .55 + .45 * math.sin(phase * math.pi * 2 * (1 + i % 3) + i); c.drawCircle(Offset(x, y), .20 + (i % 3) * .12, Paint()..color = Colors.white.withOpacity((.020 + (i % 5) * .005) * tw)); }
    final vignette = Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.48)]).createShader(Rect.fromLTWH(-m * .2, -m * .2, s.width + m * .4, s.height + m * .4)); c.drawRect(Offset.zero & s, vignette);
  }
  double _noise(double x) => (math.sin(x * 12.9898) * 43758.5453).abs() % 1.0;
  @override bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.detail != detail || old.cinematic != cinematic || old.reducedMotion != reducedMotion;
}

class _GalaxyDustPainter extends CustomPainter {
  final double phase; final bool cinematic;
  _GalaxyDustPainter(this.phase, this.cinematic);
  @override void paint(Canvas c, Size s) { final m = math.min(s.width, s.height); final center = Offset(s.width * .50, s.height * .50); final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final count = cinematic ? 34 : 14; for (var i = 0; i < count; i++) { final a = i * .73 + phase * math.pi * 2 * .045; final rr = m * (.16 + (i % 21) * .021); final q = Offset(center.dx + math.cos(a) * rr * 1.75, center.dy + math.sin(a) * rr * .48); p.color = (i.isEven ? const Color(0xFF74558D) : const Color(0xFF526F9D)).withOpacity(.012 + (i % 4) * .003); p.strokeWidth = 1.5 + (i % 3) * .9; c.drawLine(q, q + Offset(math.cos(a + 1.2) * m * .035, math.sin(a + 1.2) * m * .010), p); } }
  @override bool shouldRepaint(covariant _GalaxyDustPainter old) => old.phase != phase || old.cinematic != cinematic;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double phase, orbit; final int count, index; final GalaxyWorld? previous, next; final VoidCallback onPrevious, onNext, onVisit, onClose;
  const _FloatingVisitPanel({required this.world, required this.compact, required this.phase, required this.orbit, required this.count, required this.index, required this.previous, required this.next, required this.onPrevious, required this.onNext, required this.onVisit, required this.onClose});
  @override Widget build(BuildContext context) {
    final w = compact ? 230.0 : 300.0; final a = index / math.max(1, count) * math.pi * 2 + orbit * .9;
    return LayoutBuilder(builder: (_, c) { final minSide = math.min(c.maxWidth, c.maxHeight); final spacing = count <= 3 ? .36 : count <= 6 ? .32 : count <= 9 ? .285 : .255; final rr = minSide * (compact ? spacing * .90 : spacing); final x = c.maxWidth * .52 + math.cos(a) * rr * 1.62; final y = c.maxHeight * .52 + math.sin(a) * rr * .72; final left = (x + 46).clamp(12.0, math.max(12.0, c.maxWidth - w - 12)); final top = (y - 58).clamp(compact ? 150.0 : 110.0, math.max(110.0, c.maxHeight - 185.0));
      return AnimatedPositioned(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, left: left, top: top, child: Material(color: Colors.transparent, child: Container(width: w, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xE8080910), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 15))))]), const SizedBox(height: 7),
        Text(world.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1.35)), const SizedBox(height: 11),
        Row(children: [Expanded(child: _PanelButton(label: '←  ${previous?.title.toUpperCase() ?? 'PREVIOUS'}', onTap: onPrevious)), const SizedBox(width: 5), Expanded(child: _PanelButton(label: 'VISIT  →', onTap: onVisit)), const SizedBox(width: 5), Expanded(child: _PanelButton(label: '${next?.title.toUpperCase() ?? 'NEXT'}  →', onTap: onNext))]),
        const SizedBox(height: 7), const Text('ENTER VISIT   •   F CLOSE   •   ESC CLOSE   •   ← / → OR J / K NAVIGATE', style: TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: .9)),
      ])));
    });
  }
}

class _PanelButton extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _PanelButton({required this.label, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4), color: Colors.white10, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 5.5, letterSpacing: .8))));
}

class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => const Text('DRAG  •  ORBIT     PINCH / + −  •  ZOOM     CLICK A WORLD  •  INSPECT     F  •  FOCUS     ← → / J K  •  NAVIGATE', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.2)); }

Color _tone(GalaxyWorldKind kind) {
  switch (kind) {
    case GalaxyWorldKind.vegeta: return const Color(0xFF4C536B);
    case GalaxyWorldKind.game: return const Color(0xFF425B66);
    case GalaxyWorldKind.identity: return const Color(0xFF554A66);
    case GalaxyWorldKind.cinema: return const Color(0xFF614F62);
    case GalaxyWorldKind.creation: return const Color(0xFF50635F);
    case GalaxyWorldKind.music: return const Color(0xFF5D4D67);
    case GalaxyWorldKind.family: return const Color(0xFF5D6254);
    case GalaxyWorldKind.archive: return const Color(0xFF5B5960);
    case GalaxyWorldKind.comingSoon: return const Color(0xFF4D5560);
  }
}
