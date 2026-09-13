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
  GalaxyWorldKind? selected, hovered;
  double orbit = 0, orbitVelocity = 0, zoom = 1, focusBlend = 0, targetOrbit = 0;
  bool systemMap = false, labels = true, detail = true, cinematic = false, paused = false;
  bool reducedMotion = false, focus = false, radar = true, routes = true, overview = false, atmosphere = true;

  GalaxyWorld? get current {
    for (final world in widget.worlds) {
      if (world.kind == selected) return world;
    }
    return null;
  }

  @override void initState() { super.initState(); clock.addListener(_tick); }
  void _tick() {
    if (!mounted || paused) return;
    var changed = false;
    if (orbitVelocity.abs() > .00012 && !focus) { orbit += orbitVelocity; orbitVelocity *= .965; changed = true; }
    if (focus && selected != null) {
      orbit += _short(targetOrbit - orbit) * .045;
      changed = true;
    }
    final wanted = focus && selected != null ? 1.0 : 0.0;
    if ((focusBlend - wanted).abs() > .006) { focusBlend += (wanted - focusBlend) * .13; changed = true; }
    if (changed) setState(() {});
  }
  @override void dispose() { clock.removeListener(_tick); clock.dispose(); super.dispose(); }
  void _pause(bool value) { setState(() => paused = value); if (value) clock.stop(); else clock.repeat(); }
  void _select(GalaxyWorld world) {
    if (selected == world.kind) { setState(() { selected = null; focus = false; }); return; }
    final index = widget.worlds.indexOf(world);
    setState(() { selected = world.kind; focus = true; orbitVelocity = 0; targetOrbit = _targetFor(index); });
  }
  void _focus() {
    if (widget.worlds.isEmpty) return;
    if (selected == null) { _index(0); return; }
    setState(() => focus = !focus);
    if (focus) targetOrbit = _targetFor(widget.worlds.indexWhere((w) => w.kind == selected));
  }
  double _targetFor(int index) => -.25 * math.pi - (index / math.max(1, widget.worlds.length)) * math.pi * 2;
  void _move(int delta) {
    if (widget.worlds.isEmpty) return;
    final old = current;
    final i = old == null ? 0 : widget.worlds.indexOf(old);
    final n = (i + delta) % widget.worlds.length;
    _index(n < 0 ? n + widget.worlds.length : n);
  }
  GalaxyWorld? _near(int delta) {
    if (widget.worlds.isEmpty) return null;
    final i = current == null ? 0 : widget.worlds.indexOf(current!);
    final n = (i + delta) % widget.worlds.length;
    return widget.worlds[n < 0 ? n + widget.worlds.length : n];
  }
  void _index(int i) {
    if (i < 0 || i >= widget.worlds.length) return;
    setState(() { selected = widget.worlds[i].kind; focus = true; orbitVelocity = 0; targetOrbit = _targetFor(i); });
  }
  void _reset() {
    setState(() { orbit = 0; orbitVelocity = 0; targetOrbit = 0; zoom = 1; focusBlend = 0; selected = null; hovered = null; systemMap = false; labels = true; detail = true; cinematic = false; reducedMotion = false; focus = false; radar = true; routes = true; overview = false; atmosphere = true; });
    if (paused) _pause(false);
  }
  Map<ShortcutActivator, Intent> _shortcuts() => {
    const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
    const SingleActivator(LogicalKeyboardKey.keyP): const _P(), const SingleActivator(LogicalKeyboardKey.keyL): const _L(),
    const SingleActivator(LogicalKeyboardKey.keyM): const _M(), const SingleActivator(LogicalKeyboardKey.keyD): const _D(),
    const SingleActivator(LogicalKeyboardKey.keyC): const _C(), const SingleActivator(LogicalKeyboardKey.keyR): const _R(),
    const SingleActivator(LogicalKeyboardKey.keyJ): const _Prev(), const SingleActivator(LogicalKeyboardKey.keyK): const _Next(),
    const SingleActivator(LogicalKeyboardKey.keyF): const _F(), const SingleActivator(LogicalKeyboardKey.keyO): const _O(),
    const SingleActivator(LogicalKeyboardKey.keyN): const _N(), const SingleActivator(LogicalKeyboardKey.keyT): const _T(),
    const SingleActivator(LogicalKeyboardKey.keyA): const _A(), const SingleActivator(LogicalKeyboardKey.arrowLeft): const _Prev(),
    const SingleActivator(LogicalKeyboardKey.arrowRight): const _Next(), const SingleActivator(LogicalKeyboardKey.digit1): const _S(0),
    const SingleActivator(LogicalKeyboardKey.digit2): const _S(1), const SingleActivator(LogicalKeyboardKey.digit3): const _S(2),
    const SingleActivator(LogicalKeyboardKey.digit4): const _S(3), const SingleActivator(LogicalKeyboardKey.digit5): const _S(4),
    const SingleActivator(LogicalKeyboardKey.digit6): const _S(5), const SingleActivator(LogicalKeyboardKey.digit7): const _S(6),
    const SingleActivator(LogicalKeyboardKey.digit8): const _S(7), const SingleActivator(LogicalKeyboardKey.digit9): const _S(8),
  };
  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context), dpr = MediaQuery.devicePixelRatioOf(context);
    final compact = size.width < 760, low = size.width < 1000 || dpr > 2;
    final quality = low ? 0 : (cinematic && !compact ? 2 : 1), cine = quality == 2 && !reducedMotion, chosen = current;
    return FocusableActionDetector(
      autofocus: true, shortcuts: _shortcuts(),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { if (chosen != null) widget.onWorldTap?.call(chosen); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { setState(() { selected = null; focus = false; }); return null; }),
        _P: CallbackAction<_P>(onInvoke: (_) { _pause(!paused); return null; }), _L: CallbackAction<_L>(onInvoke: (_) { setState(() => labels = !labels); return null; }),
        _M: CallbackAction<_M>(onInvoke: (_) { setState(() => systemMap = !systemMap); return null; }), _D: CallbackAction<_D>(onInvoke: (_) { setState(() => detail = !detail); return null; }),
        _C: CallbackAction<_C>(onInvoke: (_) { setState(() => cinematic = !cinematic); return null; }), _R: CallbackAction<_R>(onInvoke: (_) { _reset(); return null; }),
        _Prev: CallbackAction<_Prev>(onInvoke: (_) { _move(-1); return null; }), _Next: CallbackAction<_Next>(onInvoke: (_) { _move(1); return null; }),
        _F: CallbackAction<_F>(onInvoke: (_) { _focus(); return null; }), _O: CallbackAction<_O>(onInvoke: (_) { setState(() => overview = !overview); return null; }),
        _N: CallbackAction<_N>(onInvoke: (_) { setState(() => radar = !radar); return null; }), _T: CallbackAction<_T>(onInvoke: (_) { setState(() => routes = !routes); return null; }),
        _A: CallbackAction<_A>(onInvoke: (_) { setState(() => atmosphere = !atmosphere); return null; }), _S: CallbackAction<_S>(onInvoke: (intent) { _index(intent.index); return null; }),
      },
      child: Scaffold(backgroundColor: const Color(0xFF010107), body: Listener(
        onPointerSignal: (event) { if (event is PointerScrollEvent) setState(() => zoom = (zoom - event.scrollDelta.dy * .00065).clamp(.62, 1.85).toDouble()); },
        child: GestureDetector(
          onDoubleTap: () { selected == null ? _reset() : _focus(); }, onScaleStart: (_) => orbitVelocity = 0,
          onScaleUpdate: (details) { if (details.pointerCount > 1) setState(() => zoom = (zoom * details.scale).clamp(.62, 1.85).toDouble()); else if (!reducedMotion && !focus) setState(() { final v = details.focalPointDelta.dx / math.max(220, size.width); orbit += v; orbitVelocity = v; }); },
          child: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
            RepaintBoundary(child: CustomPaint(painter: _Space(clock.value, cine, reducedMotion, quality))),
            if (!reducedMotion) RepaintBoundary(child: CustomPaint(painter: _Dust(clock.value, cine, quality))),
            Transform.scale(scale: zoom, child: RepaintBoundary(child: CustomPaint(painter: _Architecture(clock.value, orbit, systemMap, detail, cine, routes, focusBlend)))),
            _Orbit(worlds: widget.worlds, phase: clock.value, orbit: orbit, selected: selected, hovered: hovered, labels: labels, detail: detail, cinematic: cine, compact: compact, map: systemMap, focus: focus, blend: focusBlend, routes: routes, atmosphere: atmosphere, quality: quality, onTap: _select, onHover: (w) => setState(() => hovered = w?.kind)),
            _Header(map: systemMap, compact: compact, cine: cine, paused: paused, low: low, focus: focus, overview: overview),
            Positioned(right: compact ? 10 : 26, top: compact ? 70 : 26, child: _Controls(map: systemMap, labels: labels, detail: detail, cine: cine, paused: paused, focus: focus, radar: radar, routes: routes, atmosphere: atmosphere, overview: overview, reduced: reducedMotion, onZoomIn: () => setState(() => zoom = (zoom + .1).clamp(.62, 1.85).toDouble()), onZoomOut: () => setState(() => zoom = (zoom - .1).clamp(.62, 1.85).toDouble()), onMap: () => setState(() => systemMap = !systemMap), onLabels: () => setState(() => labels = !labels), onDetail: () => setState(() => detail = !detail), onCine: () => setState(() => cinematic = !cinematic), onPause: () => _pause(!paused), onFocus: _focus, onRadar: () => setState(() => radar = !radar), onRoutes: () => setState(() => routes = !routes), onAtmosphere: () => setState(() => atmosphere = !atmosphere), onOverview: () => setState(() => overview = !overview), onReduced: () => setState(() => reducedMotion = !reducedMotion), onReset: _reset)),
            Positioned(left: compact ? 12 : 30, top: compact ? 112 : 92, child: _Telemetry(phase: clock.value, selected: chosen, hovered: hovered, map: systemMap, zoom: zoom, cine: cine, paused: paused, low: low, focus: focus, count: widget.worlds.length, quality: quality)),
            if (radar && !compact) Positioned(left: 26, bottom: 26, child: _Radar(worlds: widget.worlds, selected: selected, orbit: orbit, phase: clock.value, focus: focus, onSelect: _index)),
            if (overview && !compact) Positioned(left: 26, top: 170, child: _Ledger(worlds: widget.worlds, selected: selected, onSelect: _index)),
            if (chosen != null) _Panel(world: chosen, compact: compact, count: widget.worlds.length, index: widget.worlds.indexOf(chosen), previous: _near(-1), next: _near(1), onPrevious: () => _move(-1), onNext: () => _move(1), onVisit: () => widget.onWorldTap?.call(chosen), onClose: () => setState(() { selected = null; focus = false; }))
            else const Positioned(left: 0, right: 0, bottom: 22, child: Center(child: _Hint())),
          ])),
        ),
      )),
    );
  }
}

class _P extends Intent { const _P(); } class _L extends Intent { const _L(); } class _M extends Intent { const _M(); } class _D extends Intent { const _D(); } class _C extends Intent { const _C(); } class _R extends Intent { const _R(); } class _Prev extends Intent { const _Prev(); } class _Next extends Intent { const _Next(); } class _F extends Intent { const _F(); } class _O extends Intent { const _O(); } class _N extends Intent { const _N(); } class _T extends Intent { const _T(); } class _A extends Intent { const _A(); } class _S extends Intent { final int index; const _S(this.index); }

class _Header extends StatelessWidget {
  final bool map, compact, cine, paused, low, focus, overview;
  const _Header({required this.map, required this.compact, required this.cine, required this.paused, required this.low, required this.focus, required this.overview});
  @override Widget build(BuildContext c) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)), const SizedBox(height: 7), Text(map ? 'GALAXY / SYSTEM MAP' : overview ? 'GALAXY / WORLD INDEX' : focus ? 'GALAXY / TARGET LOCK' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)), const SizedBox(height: 5), Text(paused ? 'WORLD NODES • PAUSED' : cine ? 'WORLD NODES • CINEMATIC' : low ? 'WORLD NODES • EFFICIENT' : focus ? 'WORLD NODES • TARGET LOCK' : 'WORLD NODES • SAFE RENDER', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6))]));
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail, cine, paused, focus, radar, routes, atmosphere, overview, reduced;
  final VoidCallback onZoomIn, onZoomOut, onMap, onLabels, onDetail, onCine, onPause, onFocus, onRadar, onRoutes, onAtmosphere, onOverview, onReduced, onReset;
  const _Controls({required this.map, required this.labels, required this.detail, required this.cine, required this.paused, required this.focus, required this.radar, required this.routes, required this.atmosphere, required this.overview, required this.reduced, required this.onZoomIn, required this.onZoomOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onCine, required this.onPause, required this.onFocus, required this.onRadar, required this.onRoutes, required this.onAtmosphere, required this.onOverview, required this.onReduced, required this.onReset});
  @override Widget build(BuildContext c) => Wrap(spacing: 4, runSpacing: 4, children: [_B('+', onZoomIn), _B('−', onZoomOut), _B(map ? 'ORBIT' : 'MAP', onMap), _B(labels ? 'LABELS' : 'CLEAN', onLabels), _B(detail ? 'DETAIL' : 'MINIMAL', onDetail), _B(cine ? 'CINEMATIC' : 'SAFE', onCine), _B(focus ? 'FOCUS ON' : 'FOCUS', onFocus), _B(radar ? 'RADAR' : 'NO RADAR', onRadar), _B(routes ? 'ROUTES' : 'NO ROUTES', onRoutes), _B(atmosphere ? 'ATMOS' : 'NO ATMOS', onAtmosphere), _B(overview ? 'INDEX ON' : 'INDEX', onOverview), _B(paused ? 'PLAY' : 'PAUSE', onPause), _B(reduced ? 'MOTION OFF' : 'MOTION', onReduced), _B('RESET', onReset)]);
}
class _B extends StatelessWidget { final String text; final VoidCallback tap; const _B(this.text, this.tap); @override Widget build(BuildContext c) => Semantics(button: true, label: text, child: InkWell(onTap: tap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(.62), border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.1))))); }

class _Telemetry extends StatelessWidget {
  final double phase, zoom; final GalaxyWorld? selected; final GalaxyWorldKind? hovered; final bool map, cine, paused, low, focus; final int count, quality;
  const _Telemetry({required this.phase, required this.selected, required this.hovered, required this.map, required this.zoom, required this.cine, required this.paused, required this.low, required this.focus, required this.count, required this.quality});
  @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${map ? 'SYSTEM MAP' : focus ? 'TARGET LOCK' : 'DEEP ORBIT'} • ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)), const SizedBox(height: 4), Text('AZ ${(phase * 360).round() % 360}° • Z ${(zoom * 100).round()}% • ${hovered == null ? 'NO HOVER TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)), const SizedBox(height: 3), Text('${paused ? 'PAUSED' : cine ? 'CINEMATIC' : low ? 'EFFICIENT' : focus ? 'FOCUS' : 'SAFE'} • $count WORLDS • Q$quality', style: const TextStyle(color: Colors.white10, fontSize: 5.5, letterSpacing: 1.2))]);
}

class _Orbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit, blend; final GalaxyWorldKind? selected, hovered; final bool labels, detail, cinematic, compact, map, focus, routes, atmosphere; final int quality; final ValueChanged<GalaxyWorld> onTap; final ValueChanged<GalaxyWorld?> onHover;
  const _Orbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.map, required this.focus, required this.blend, required this.routes, required this.atmosphere, required this.quality, required this.onTap, required this.onHover});
  @override Widget build(BuildContext c) => LayoutBuilder(builder: (_, box) => Stack(children: [CustomPaint(size: Size(box.maxWidth, box.maxHeight), painter: _Core(phase, orbit, detail, cinematic, map, worlds.length, quality)), if (map && routes) CustomPaint(size: Size(box.maxWidth, box.maxHeight), painter: _Routes(worlds.length, phase, orbit, selected)), for (var i = 0; i < worlds.length; i++) _Node(world: worlds[i], index: i, count: worlds.length, phase: phase, orbit: orbit, selected: selected == worlds[i].kind, hovered: hovered == worlds[i].kind, any: selected != null, labels: labels, detail: detail, cine: cinematic, compact: compact, focus: focus, blend: blend, atmosphere: atmosphere, quality: quality, onTap: () => onTap(worlds[i]), onHover: (v) => onHover(v ? worlds[i] : null))]));
}
class _Node extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, orbit, blend; final bool selected, hovered, any, labels, detail, cine, compact, focus, atmosphere; final int quality; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _Node({required this.world, required this.index, required this.count, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.any, required this.labels, required this.detail, required this.cine, required this.compact, required this.focus, required this.blend, required this.atmosphere, required this.quality, required this.onTap, required this.onHover});
  @override Widget build(BuildContext c) => LayoutBuilder(builder: (_, box) { final m = math.min(box.maxWidth, box.maxHeight); final spacing = count <= 3 ? .36 : count <= 6 ? .32 : count <= 9 ? .285 : .255; final a = index / math.max(1, count) * math.pi * 2 + orbit * .9; final target = -math.pi * .25; final focusedAngle = a + _short(target - a) * .34 * blend; final rr = m * (compact ? spacing * .9 : spacing); final px = box.maxWidth * .52 + math.cos(focusedAngle) * rr * 1.62; final py = box.maxHeight * .52 + math.sin(focusedAngle) * rr * .72; final depth = (math.sin(focusedAngle) + 1) / 2; final r = m * (.041 + depth * .024 + (selected ? .022 : 0) + (hovered ? .011 : 0)); final sz = r * 3.45; return Positioned(left: px - sz / 2, top: py - sz / 2, width: sz, height: sz, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(true), onExit: (_) => onHover(false), child: Semantics(button: true, label: world.title, child: GestureDetector(onTap: onTap, child: Opacity(opacity: any && !selected ? .44 : 1, child: CustomPaint(painter: _Planet(world.kind, phase, index, selected, hovered, labels, detail, cine, world.title, atmosphere, quality))))))); });
}

double _short(double v) { while (v > math.pi) v -= math.pi * 2; while (v < -math.pi) v += math.pi * 2; return v; }

class _Core extends CustomPainter {
  final double phase, orbit; final bool detail, cine, map; final int count, quality;
  _Core(this.phase, this.orbit, this.detail, this.cine, this.map, this.count, this.quality);
  @override void paint(Canvas c, Size s) { final o = Offset(s.width * .52, s.height * .52), m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke; final n = quality == 0 ? 5 : cine ? 14 : 8; for (var i = 0; i < n; i++) { final r = m * (.075 + i * .036); p.color = Colors.white.withOpacity(.010 + (i % 4) * .005); p.strokeWidth = i % 5 == 0 ? .8 : .32; c.drawOval(Rect.fromCenter(center: o, width: r * 2.55, height: r * (.25 + (i % 6) * .035) * 2), p); } if (map) { final q = Paint()..color = Colors.white.withOpacity(.035)..style = PaintingStyle.stroke..strokeWidth = .8; final path = Path(); for (var i = 0; i < math.max(3, count); i++) { final a = i / math.max(3, count) * math.pi * 2 + orbit * .9, r = m * (.19 + i * .018), z = Offset(o.dx + math.cos(a) * r * 1.8, o.dy + math.sin(a) * r * .78); if (i == 0) path.moveTo(z.dx, z.dy); else path.lineTo(z.dx, z.dy); } path.close(); c.drawPath(path, q); } final g = m * (cine ? .22 : .15), pulse = .92 + math.sin(phase * math.pi * 2) * .08; c.drawCircle(o, g, Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(.22 * pulse), const Color(0xFF76538F).withOpacity(.11), Colors.transparent]).createShader(Rect.fromCircle(center: o, radius: g))); c.drawCircle(o, m * .055, Paint()..shader = RadialGradient(colors: [Colors.white70, const Color(0xFF72508A), Colors.transparent]).createShader(Rect.fromCircle(center: o, radius: m * .055))); }
  @override bool shouldRepaint(covariant _Core old) => old.phase != phase || old.orbit != orbit || old.detail != detail || old.cine != cine || old.map != map || old.count != count || old.quality != quality;
}

class _Routes extends CustomPainter {
  final int count; final double phase, orbit; final GalaxyWorldKind? selected; _Routes(this.count, this.phase, this.orbit, this.selected);
  @override void paint(Canvas c, Size s) { if (count < 2) return; final m = math.min(s.width, s.height), o = Offset(s.width * .52, s.height * .52), rr = m * (count <= 3 ? .36 : count <= 6 ? .32 : count <= 9 ? .285 : .255); final pts = <Offset>[]; for (var i = 0; i < count; i++) { final a = i / count * math.pi * 2 + orbit * .9; pts.add(Offset(o.dx + math.cos(a) * rr * 1.62, o.dy + math.sin(a) * rr * .72)); } final p = Paint()..style = PaintingStyle.stroke..strokeWidth = selected == null ? .5 : .8..color = Colors.white.withOpacity(selected == null ? .018 : .04); for (var i = 0; i < count; i++) c.drawLine(pts[i], pts[(i + 1) % count], p); final pulse = (math.sin(phase * math.pi * 2) + 1) / 2; for (var i = 0; i < count; i += 2) c.drawCircle(pts[i], 1.2 + pulse * 1.2, Paint()..color = Colors.white.withOpacity(.06 + pulse * .05)); }
  @override bool shouldRepaint(covariant _Routes old) => old.count != count || old.phase != phase || old.orbit != orbit || old.selected != selected;
}

class _Architecture extends CustomPainter {
  final double phase, orbit, blend; final bool map, detail, cine, routes; _Architecture(this.phase, this.orbit, this.map, this.detail, this.cine, this.routes, this.blend);
  @override void paint(Canvas c, Size s) { final o = Offset(s.width * .52, s.height * .52), m = math.min(s.width, s.height), p = Paint()..style = PaintingStyle.stroke, n = cine ? 10 : 6; for (var i = 0; i < n; i++) { final r = m * (.12 + i * .042); p.color = Colors.white.withOpacity(map ? .030 : .015 + (i % 3) * .004); p.strokeWidth = i == n ~/ 2 ? .8 : .3; c.drawOval(Rect.fromCenter(center: o, width: r * 2.4, height: r * (.31 + (i % 5) * .065) * 2), p); } if (map && routes) c.drawOval(Rect.fromCenter(center: o, width: m * 1.10, height: m * .38), Paint()..color = const Color(0xFF76538F).withOpacity(.035 + blend * .025)..style = PaintingStyle.stroke..strokeWidth = .7); }
  @override bool shouldRepaint(covariant _Architecture old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail || old.cine != cine || old.routes != routes || old.blend != blend;
}

class _Planet extends CustomPainter {
  final GalaxyWorldKind kind; final double phase; final int index; final bool selected, hovered, labels, detail, cine; final String title; final bool atmosphere; final int quality;
  _Planet(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cine, this.title, this.atmosphere, this.quality);
  @override void paint(Canvas c, Size s) { final o = Offset(s.width / 2, s.height / 2), r = s.width * .30, rect = Rect.fromCircle(center: o, radius: r); if (atmosphere) c.drawCircle(o, r * (hovered ? 2 : selected ? 1.9 : 1.58), Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(selected ? .24 : hovered ? .14 : .045), Colors.transparent]).createShader(rect.inflate(r))); c.drawCircle(o, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.04, colors: [const Color(0xFFB5BFCA), _tone(kind), const Color(0xFF03040A)]).createShader(rect)); c.drawCircle(o, r, Paint()..shader = RadialGradient(center: const Alignment(.70, .62), radius: .92, colors: [Colors.transparent, Colors.black.withOpacity(.72)]).createShader(rect)); if (detail && quality > 0) { final n = cine ? 6 : 3, q = Paint()..style = PaintingStyle.stroke; for (var j = 0; j < n; j++) { final rr = r * (.42 + j * .055), path = Path(); for (var k = 0; k <= 20; k++) { final a = k / 20 * math.pi * 2, w = math.sin(a * (2 + j % 3) + index * .8) * r * .025, z = Offset(o.dx + math.cos(a) * (rr + w), o.dy + math.sin(a) * (rr + w) * .60); if (k == 0) path.moveTo(z.dx, z.dy); else path.lineTo(z.dx, z.dy); } q.color = Colors.white.withOpacity(.045 - j * .004); q.strokeWidth = .45; c.drawPath(path, q); } } if (selected) { final pulse = .88 + math.sin(phase * math.pi * 2) * .12; c.drawCircle(o, r * 1.22, Paint()..color = Colors.white.withOpacity(.30 * pulse)..style = PaintingStyle.stroke..strokeWidth = 1.1); c.drawCircle(o, r * 1.36, Paint()..color = Colors.white.withOpacity(.08 * pulse)..style = PaintingStyle.stroke..strokeWidth = .6); for (var i = 0; i < 3; i++) { final a = phase * math.pi * .5 + i * math.pi * 2 / 3; c.drawLine(o + Offset(math.cos(a) * r * 1.38, math.sin(a) * r * 1.38), o + Offset(math.cos(a) * r * 1.50, math.sin(a) * r * 1.50), Paint()..color = Colors.white30..strokeWidth = .8); } } if (labels) { final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(selected ? .88 : hovered ? .72 : .42), fontSize: math.max(6, s.width * .025), letterSpacing: 1.2)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.2); tp.paint(c, Offset(o.dx - tp.width / 2, o.dy + r * 1.38)); } }
  @override bool shouldRepaint(covariant _Planet old) => old.kind != kind || old.phase != phase || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.cine != cine || old.title != title || old.atmosphere != atmosphere || old.quality != quality;
}

class _Radar extends StatelessWidget {
  final List<GalaxyWorld> worlds; final GalaxyWorldKind? selected; final double orbit, phase; final bool focus; final ValueChanged<int> onSelect;
  const _Radar({required this.worlds, required this.selected, required this.orbit, required this.phase, required this.focus, required this.onSelect});
  @override Widget build(BuildContext c) => Container(width: 158, height: 158, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xB905060C), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24)]), child: Stack(children: [CustomPaint(size: const Size(138, 138), painter: _RadarPaint(worlds, selected, orbit, phase, focus)), for (var i = 0; i < worlds.length; i++) _radarHit(c, i)]));
  Widget _radarHit(BuildContext c, int i) { final a = i / math.max(1, worlds.length) * math.pi * 2 + orbit * .9, x = 69 + math.cos(a) * 48, y = 69 + math.sin(a) * 39; return Positioned(left: x - 11, top: y - 11, width: 22, height: 22, child: GestureDetector(onTap: () => onSelect(i), child: const SizedBox())); }
}
class _RadarPaint extends CustomPainter {
  final List<GalaxyWorld> worlds; final GalaxyWorldKind? selected; final double orbit, phase; final bool focus; _RadarPaint(this.worlds, this.selected, this.orbit, this.phase, this.focus);
  @override void paint(Canvas c, Size s) { final o = Offset(s.width / 2, s.height / 2), r = s.width * .38, p = Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = Colors.white12; for (var i = 1; i <= 3; i++) c.drawCircle(o, r * i / 3, p); c.drawLine(Offset(o.dx - r, o.dy), Offset(o.dx + r, o.dy), p); c.drawLine(Offset(o.dx, o.dy - r), Offset(o.dx, o.dy + r), p); c.drawCircle(o, 2.5, Paint()..color = Colors.white54); for (var i = 0; i < worlds.length; i++) { final q = i / math.max(1, worlds.length) * math.pi * 2 + orbit * .9, z = Offset(o.dx + math.cos(q) * r * .82, o.dy + math.sin(q) * r * .66), active = selected == worlds[i].kind; c.drawCircle(z, active ? 3.6 : 2, Paint()..color = Colors.white.withOpacity(active ? .95 : .28)); if (active && focus) c.drawCircle(z, 6, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = Colors.white38); } final t = TextPainter(text: const TextSpan(text: 'GALAXY RADAR', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.4)), textDirection: TextDirection.ltr)..layout(); t.paint(c, const Offset(10, 9)); }
  @override bool shouldRepaint(covariant _RadarPaint old) => old.worlds.length != worlds.length || old.selected != selected || old.orbit != orbit || old.phase != phase || old.focus != focus;
}

class _Ledger extends StatelessWidget { final List<GalaxyWorld> worlds; final GalaxyWorldKind? selected; final ValueChanged<int> onSelect; const _Ledger({required this.worlds, required this.selected, required this.onSelect}); @override Widget build(BuildContext c) => Container(width: 205, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xB9080910), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('WORLD INDEX', style: TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 2)), const SizedBox(height: 8), for (var i = 0; i < worlds.length; i++) InkWell(onTap: () => onSelect(i), child: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Colors.white20, fontSize: 6)), const SizedBox(width: 9), Expanded(child: Text(worlds[i].title.toUpperCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: selected == worlds[i].kind ? Colors.white : Colors.white38, fontSize: 7, letterSpacing: 1)),), if (selected == worlds[i].kind) const Text('TARGET', style: TextStyle(color: Colors.white54, fontSize: 5))])))])); }

class _Space extends CustomPainter { final double phase; final bool cine, reduced; final int quality; _Space(this.phase, this.cine, this.reduced, this.quality); @override void paint(Canvas c, Size s) { final m = math.min(s.width, s.height); c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107)); c.drawCircle(Offset(s.width * .48, s.height * .48), m * .82, Paint()..shader = RadialGradient(colors: [const Color(0xFF39224F).withOpacity(.20), const Color(0xFF17234A).withOpacity(.09), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(s.width * .48, s.height * .48), radius: m * .82))); final v = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; for (var i = 0; i < (quality == 0 ? 2 : cine ? 7 : 4); i++) { final y = s.height * (.16 + i * .085), path = Path()..moveTo(-m * .1, y)..cubicTo(s.width * .18, y - m * (.15 + i * .012), s.width * .38, y + m * (.18 + i * .01), s.width * .62, y - m * (.05 + i * .008))..cubicTo(s.width * .8, y - m * (.13 + i * .012), s.width * 1.02, y + m * (.11 + i * .01), s.width * 1.12, y - m * .02); v.color = (i.isEven ? const Color(0xFF6A4C86) : const Color(0xFF405F91)).withOpacity(.038 - i * .0025); v.strokeWidth = m * (.07 + (i % 3) * .015); c.drawPath(path, v); } for (var i = 0; i < (quality == 0 ? 18 : cine ? 110 : 38); i++) { final x = _noise(i * 2.13) * s.width, y = _noise(i * 4.71 + 3) * s.height, t = reduced ? 1 : .55 + .45 * math.sin(phase * math.pi * 2 * (1 + i % 3) + i); c.drawCircle(Offset(x, y), .2 + (i % 3) * .12, Paint()..color = Colors.white.withOpacity((.02 + (i % 5) * .005) * t)); } c.drawRect(Offset.zero & s, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.48)]).createShader(Rect.fromLTWH(-m * .2, -m * .2, s.width + m * .4, s.height + m * .4))); } double _noise(double x) => (math.sin(x * 12.9898) * 43758.5453).abs() % 1; @override bool shouldRepaint(covariant _Space old) => old.phase != phase || old.cine != cine || old.reduced != reduced || old.quality != quality; }
class _Dust extends CustomPainter { final double phase; final bool cine; final int quality; _Dust(this.phase, this.cine, this.quality); @override void paint(Canvas c, Size s) { final m = math.min(s.width, s.height), o = Offset(s.width * .5, s.height * .5), p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; for (var i = 0; i < (quality == 0 ? 6 : cine ? 44 : 16); i++) { final a = i * .73 + phase * math.pi * 2 * .045, r = m * (.16 + (i % 21) * .021), q = Offset(o.dx + math.cos(a) * r * 1.75, o.dy + math.sin(a) * r * .48); p.color = (i.isEven ? const Color(0xFF74558D) : const Color(0xFF526F9D)).withOpacity(.012 + (i % 4) * .003); p.strokeWidth = 1.5 + (i % 3) * .9; c.drawLine(q, q + Offset(math.cos(a + 1.2) * m * .035, math.sin(a + 1.2) * m * .01), p); } } @override bool shouldRepaint(covariant _Dust old) => old.phase != phase || old.cine != cine || old.quality != quality; }

class _Panel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final int count, index; final GalaxyWorld? previous, next; final VoidCallback onPrevious, onNext, onVisit, onClose;
  const _Panel({required this.world, required this.compact, required this.count, required this.index, required this.previous, required this.next, required this.onPrevious, required this.onNext, required this.onVisit, required this.onClose});
  @override Widget build(BuildContext c) { final w = compact ? 230.0 : 300.0; return Positioned(right: compact ? 12 : 30, bottom: compact ? 60 : 30, child: Material(color: Colors.transparent, child: Container(width: w, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xE8080910), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 15))))]), const SizedBox(height: 7), Text(world.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1.35)), const SizedBox(height: 11), Row(children: [Expanded(child: _PB('← ${previous?.title.toUpperCase() ?? 'PREVIOUS'}', onPrevious)), const SizedBox(width: 5), Expanded(child: _PB('VISIT →', onVisit)), const SizedBox(width: 5), Expanded(child: _PB('${next?.title.toUpperCase() ?? 'NEXT'} →', onNext))]), const SizedBox(height: 7), const Text('ENTER VISIT • F FOCUS • ESC CLOSE • ← → / J K NAVIGATE', style: TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: .9))])))); }
}
class _PB extends StatelessWidget { final String text; final VoidCallback tap; const _PB(this.text, this.tap); @override Widget build(BuildContext c) => InkWell(onTap: tap, child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4), color: Colors.white10, child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 5.5, letterSpacing: .8)))); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext c) => const Text('DRAG • ORBIT   WHEEL / PINCH • ZOOM   CLICK • INSPECT   F • FOCUS   N • RADAR   O • INDEX   ← → / J K • NAVIGATE', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.1)); }
Color _tone(GalaxyWorldKind k) { switch (k) { case GalaxyWorldKind.vegeta: return const Color(0xFF4C536B); case GalaxyWorldKind.game: return const Color(0xFF425B66); case GalaxyWorldKind.identity: return const Color(0xFF554A66); case GalaxyWorldKind.cinema: return const Color(0xFF614F62); case GalaxyWorldKind.creation: return const Color(0xFF50635F); case GalaxyWorldKind.music: return const Color(0xFF5D4D67); case GalaxyWorldKind.family: return const Color(0xFF5D6254); case GalaxyWorldKind.archive: return const Color(0xFF5B5960); case GalaxyWorldKind.comingSoon: return const Color(0xFF4D5560); } }
