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
  double orbit = 0, zoom = 1;
  bool systemMap = false, labels = true, detail = true, cinematic = true;
  bool grid = false, autoOrbit = true;

  @override void dispose() { clock.dispose(); super.dispose(); }
  GalaxyWorld? get current => selected == null ? null : widget.worlds.cast<GalaxyWorld?>().firstWhere((w) => w!.kind == selected, orElse: () => null);
  void visit() { final w = current; if (w != null) widget.onWorldTap?.call(w); }
  void select(GalaxyWorld w) => setState(() => selected = selected == w.kind ? null : w.kind);
  void next(int dir) {
    if (widget.worlds.isEmpty) return;
    final i = selected == null ? 0 : widget.worlds.indexWhere((w) => w.kind == selected);
    final n = (i < 0 ? 0 : (i + dir + widget.worlds.length) % widget.worlds.length);
    setState(() => selected = widget.worlds[n].kind);
  }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context), compact = size.width < 760, chosen = current;
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.space): DirectionalFocusIntent(TraversalDirection.down),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { setState(() => selected = null); return null; }),
        NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: (_) { next(1); return null; }),
        PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: (_) { next(-1); return null; }),
        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: (_) { setState(() => systemMap = !systemMap); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: GestureDetector(
          onScaleUpdate: (d) => setState(() {
            if (d.pointerCount > 1) zoom = (zoom * d.scale).clamp(.66, 1.70).toDouble();
            else orbit += d.focalPointDelta.dx / math.max(220.0, size.width);
          }),
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _DeepSpacePainter(clock.value, detail, cinematic, grid)),
              Transform.scale(scale: zoom, child: CustomPaint(painter: _OrbitArchitecturePainter(clock.value, orbit, systemMap, detail, cinematic, grid))),
              _WorldOrbit(
                worlds: widget.worlds, phase: clock.value, orbit: orbit, selected: selected, hovered: hovered,
                labels: labels, detail: detail, cinematic: cinematic, compact: compact, autoOrbit: autoOrbit,
                onTap: select, onHover: (w) => setState(() => hovered = w?.kind),
              ),
              _Header(systemMap: systemMap, compact: compact, cinematic: cinematic, selected: chosen),
              Positioned(right: compact ? 10 : 26, top: compact ? 70 : 26, child: _Controls(
                map: systemMap, labels: labels, detail: detail, cinematic: cinematic, grid: grid, autoOrbit: autoOrbit,
                onIn: () => setState(() => zoom = (zoom + .1).clamp(.66, 1.70).toDouble()),
                onOut: () => setState(() => zoom = (zoom - .1).clamp(.66, 1.70).toDouble()),
                onMap: () => setState(() => systemMap = !systemMap),
                onLabels: () => setState(() => labels = !labels),
                onDetail: () => setState(() => detail = !detail),
                onCinematic: () => setState(() => cinematic = !cinematic),
                onGrid: () => setState(() => grid = !grid),
                onAuto: () => setState(() => autoOrbit = !autoOrbit),
                onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; hovered = null; systemMap = false; detail = true; cinematic = true; grid = false; autoOrbit = true; }),
              )),
              Positioned(left: compact ? 12 : 30, top: compact ? 112 : 92, child: _Telemetry(
                phase: clock.value, selected: chosen, hovered: hovered, map: systemMap, zoom: zoom, cinematic: cinematic, count: widget.worlds.length,
              )),
              if (chosen != null)
                _FloatingVisitPanel(
                  world: chosen, compact: compact, orbit: orbit, count: widget.worlds.length, index: widget.worlds.indexOf(chosen),
                  onVisit: visit, onClose: () => setState(() => selected = null), onPrev: () => next(-1), onNext: () => next(1),
                )
              else const Positioned(left: 0, right: 0, bottom: 22, child: Center(child: _Hint())),
              Positioned(left: compact ? 12 : 30, bottom: compact ? 55 : 34, child: _Legend(cinematic: cinematic, systemMap: systemMap)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool systemMap, compact, cinematic; final GalaxyWorld? selected;
  const _Header({required this.systemMap, required this.compact, required this.cinematic, required this.selected});
  @override Widget build(BuildContext context) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)),
    const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5),
    Text(selected == null ? (cinematic ? '09 WORLD NODES  •  DEEP SPACE' : '09 WORLD NODES  •  PERFORMANCE MODE') : 'FOCUS  •  ${selected!.title.toUpperCase()}', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]));
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail, cinematic, grid, autoOrbit;
  final VoidCallback onIn, onOut, onMap, onLabels, onDetail, onCinematic, onGrid, onAuto, onReset;
  const _Controls({required this.map, required this.labels, required this.detail, required this.cinematic, required this.grid, required this.autoOrbit, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onCinematic, required this.onGrid, required this.onAuto, required this.onReset});
  @override Widget build(BuildContext context) => Wrap(spacing: 4, runSpacing: 4, children: [
    _Btn('+', onIn), _Btn('−', onOut), _Btn(map ? 'ORBIT' : 'MAP', onMap), _Btn(labels ? 'LABELS' : 'CLEAN', onLabels), _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail), _Btn(cinematic ? 'CINEMATIC' : 'EFFICIENT', onCinematic), _Btn(grid ? 'GRID ON' : 'GRID', onGrid), _Btn(autoOrbit ? 'AUTO' : 'STILL', onAuto), _Btn('RESET', onReset),
  ]);
}
class _Btn extends StatelessWidget { final String text; final VoidCallback onTap; const _Btn(this.text, this.onTap); @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .62), border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.1)))); }

class _Telemetry extends StatelessWidget {
  final double phase, zoom; final GalaxyWorld? selected; final GalaxyWorldKind? hovered; final bool map, cinematic; final int count;
  const _Telemetry({required this.phase, required this.selected, required this.hovered, required this.map, required this.zoom, required this.cinematic, required this.count});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)),
    const SizedBox(height: 4),
    Text('AZ ${(phase * 360).round() % 360}°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)),
    const SizedBox(height: 3),
    Text('${count.toString().padLeft(2, '0')} NODES  •  ${cinematic ? 'CINEMATIC' : 'EFFICIENT'}  •  ${selected == null ? 'FREE ROAM' : 'FOCUS LOCK'}', style: const TextStyle(color: Colors.white10, fontSize: 5.5, letterSpacing: 1.2)),
  ]);
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected, hovered; final bool labels, detail, cinematic, compact, autoOrbit; final ValueChanged<GalaxyWorld> onTap; final ValueChanged<GalaxyWorld?> onHover;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.autoOrbit, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => Stack(children: [
    CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _CentralSystemPainter(phase, orbit, detail, cinematic, autoOrbit)),
    for (var i = 0; i < worlds.length; i++) _WorldNode(world: worlds[i], index: i, count: worlds.length, phase: phase, orbit: orbit, selected: selected == worlds[i].kind, hovered: hovered == worlds[i].kind, labels: labels, detail: detail, cinematic: cinematic, compact: compact, autoOrbit: autoOrbit, onTap: () => onTap(worlds[i]), onHover: (v) => onHover(v ? worlds[i] : null)),
  ]));
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, orbit; final bool selected, hovered, labels, detail, cinematic, compact, autoOrbit; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _WorldNode({required this.world, required this.index, required this.count, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.cinematic, required this.compact, required this.autoOrbit, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final m = math.min(c.maxWidth, c.maxHeight), base = index / math.max(1, count) * math.pi * 2;
    final a = base + orbit * .9 + (autoOrbit ? phase * math.pi * 2 * .025 : 0);
    final rr = m * (compact ? .255 : .285);
    final x = c.maxWidth * .52 + math.cos(a) * rr * 1.62, y = c.maxHeight * .52 + math.sin(a) * rr * .72;
    final d = (math.sin(a) + 1) / 2, r = m * (.041 + d * .024 + (selected ? .019 : 0) + (hovered ? .011 : 0)), sz = r * 3.45;
    return Positioned(left: x - sz / 2, top: y - sz / 2, width: sz, height: sz, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(true), onExit: (_) => onHover(false), child: GestureDetector(onTap: onTap, child: CustomPaint(painter: _NodePainter(world.kind, phase, index, selected, hovered, labels, detail, cinematic, world.title, autoOrbit)))));
  });
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit; final bool detail, cinematic, autoOrbit;
  _CentralSystemPainter(this.phase, this.orbit, this.detail, this.cinematic, this.autoOrbit);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52), m = math.min(s.width, s.height), p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < (cinematic ? 20 : 13); i++) { final r = m * (.075 + i * .032), pulse = 1 + math.sin(phase * math.pi * 2 + i) * .004; p.color = Colors.white.withValues(alpha: .012 + (i % 4) * .007); p.strokeWidth = i % 6 == 0 ? 1 : .38; c.drawOval(Rect.fromCenter(center: center, width: r * 2.55 * pulse, height: r * (.25 + (i % 6) * .035) * 2), p); }
    final glow = m * (cinematic ? .22 : .17); c.drawCircle(center, glow, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .28), const Color(0xFF76538F).withValues(alpha: .14), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glow)));
    c.drawCircle(center, m * .055, Paint()..shader = RadialGradient(colors: [Colors.white70, const Color(0xFF72508A), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .055)));
    final markers = cinematic ? 42 : 20;
    for (var i = 0; i < markers; i++) { final a = phase * math.pi * 2 * (.15 + (i % 5) * .025) + orbit * .45 + i * math.pi * 2 / markers, r = m * (.11 + (i % 11) * .018), q = Offset(center.dx + math.cos(a) * r * 1.35, center.dy + math.sin(a) * r * .46); c.drawCircle(q, .5 + (i % 3) * .3, Paint()..color = Colors.white.withValues(alpha: .035 + (i % 4) * .012)); }
    if (detail) for (var i = 0; i < (cinematic ? 12 : 7); i++) { final a = phase * 3.6 + i * math.pi / 6, r = m * (.065 + (i % 4) * .014), q = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r * .58); c.drawLine(center, q, Paint()..color = Colors.white.withValues(alpha: .022)..strokeWidth = .75); }
  }
  @override bool shouldRepaint(covariant _CentralSystemPainter o) => o.phase != phase || o.orbit != orbit || o.detail != detail || o.cinematic != cinematic || o.autoOrbit != autoOrbit;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit; final bool map, detail, cinematic, grid;
  _OrbitArchitecturePainter(this.phase, this.orbit, this.map, this.detail, this.cinematic, this.grid);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52), m = math.min(s.width, s.height), p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 16; i++) { final r = m * (.12 + i * .03), wobble = 1 + math.sin(phase * 2 * math.pi + i) * .002; p.color = Colors.white.withValues(alpha: map ? .045 : .022 + (i % 3) * .006); p.strokeWidth = i == 7 ? 1.1 : .42; c.drawOval(Rect.fromCenter(center: center, width: r * 2.4 * wobble, height: r * (.31 + (i % 5) * .065) * 2), p); }
    if (detail) for (var i = 0; i < (cinematic ? 13 : 8); i++) { final r = m * (.15 + i * .035); p.color = Colors.white.withValues(alpha: map ? .025 : .014); p.strokeWidth = .34; c.drawOval(Rect.fromCenter(center: center, width: r * 2.7, height: r * .28), p); }
    if (grid) {
      p.color = Colors.white.withValues(alpha: .018); p.strokeWidth = .45;
      for (var i = -5; i <= 5; i++) { final x = s.width * .5 + i * m * .12; c.drawLine(Offset(x, 0), Offset(x + m * .25, s.height), p); final y = s.height * .5 + i * m * .08; c.drawLine(Offset(0, y), Offset(s.width, y - m * .16), p); }
    }
  }
  @override bool shouldRepaint(covariant _OrbitArchitecturePainter o) => o.phase != phase || o.orbit != orbit || o.map != map || o.detail != detail || o.cinematic != cinematic || o.grid != grid;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind; final double phase; final int index; final bool selected, hovered, labels, detail, cinematic, autoOrbit; final String title;
  _NodePainter(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cinematic, this.title, this.autoOrbit);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2), r = s.width * .30, rect = Rect.fromCircle(center: center, radius: r), pulse = 1 + math.sin(phase * math.pi * 2 * 1.7 + index) * .025;
    c.drawCircle(center, r * (hovered ? 2.0 : 1.62) * pulse, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: selected ? .24 : hovered ? .16 : .06), Colors.transparent]).createShader(rect.inflate(r)));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.04, colors: [const Color(0xFFB5BFCA), _tone(kind), const Color(0xFF03040A)]).createShader(rect));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(.70, .62), radius: .92, colors: [Colors.transparent, Colors.black.withValues(alpha: .72)]).createShader(rect));
    final surface = Paint()..style = PaintingStyle.stroke;
    if (detail) for (var j = 0; j < (cinematic ? 7 : 4); j++) { final rr = r * (.43 + j * .065); final path = Path(); for (var k = 0; k <= 26; k++) { final a = k / 26 * math.pi * 2, wave = math.sin(a * (2 + j % 3) + index * .8) * r * .025; final q = Offset(center.dx + math.cos(a) * (rr + wave), center.dy + math.sin(a) * (rr + wave) * .60); k == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy); } surface.color = Colors.white.withValues(alpha: .045 - j * .003); surface.strokeWidth = .5; c.drawPath(path, surface); }
    if (selected) {
      c.drawCircle(center, r * 1.22, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1);
      c.drawCircle(center, r * 1.34, Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = .55);
      final sweep = phase * math.pi * 2 * .7 + index;
      c.drawArc(Rect.fromCircle(center: center, radius: r * 1.48), sweep, .9, false, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1.1);
    }
    if (labels) { final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: selected ? .86 : hovered ? .72 : .42), fontSize: math.max(6, s.width * .025), letterSpacing: 1.2)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.2); tp.paint(c, Offset(center.dx - tp.width / 2, center.dy + r * 1.38)); }
  }
  @override bool shouldRepaint(covariant _NodePainter o) => o.kind != kind || o.phase != phase || o.index != index || o.selected != selected || o.hovered != hovered || o.labels != labels || o.detail != detail || o.cinematic != cinematic || o.title != title || o.autoOrbit != autoOrbit;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase; final bool detail, cinematic, grid;
  _DeepSpacePainter(this.phase, this.detail, this.cinematic, this.grid);
  @override void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height);
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107));
    final center = Offset(s.width * .50, s.height * .49);
    c.drawCircle(center, m * .86, Paint()..shader = RadialGradient(center: const Alignment(-.05, -.08), radius: 1, colors: [const Color(0xFF342049).withValues(alpha: .23), const Color(0xFF17264D).withValues(alpha: .12), const Color(0xFF090A18).withValues(alpha: .035), Colors.transparent], stops: const [0, .38, .68, 1]).createShader(Rect.fromCircle(center: center, radius: m * .86)));

    // ONE natural, asymmetrical astrophotography filament. It is deliberately not mirrored.
    final path = Path()..moveTo(-m * .20, s.height * .74);
    path.cubicTo(s.width * .00, s.height * .69, s.width * .08, s.height * .59, s.width * .20, s.height * .55);
    path.cubicTo(s.width * .29, s.height * .52, s.width * .30, s.height * .30, s.width * .43, s.height * .27);
    path.cubicTo(s.width * .55, s.height * .23, s.width * .57, s.height * .44, s.width * .68, s.height * .50);
    path.cubicTo(s.width * .78, s.height * .56, s.width * .80, s.height * .43, s.width * .90, s.height * .39);
    path.cubicTo(s.width * .99, s.height * .35, s.width * 1.05, s.height * .49, s.width * 1.19, s.height * .41);

    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * (cinematic ? .20 : .15)..color = const Color(0xFF526AA0).withValues(alpha: cinematic ? .032 : .024));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * (cinematic ? .125 : .095)..shader = LinearGradient(colors: [Colors.transparent, const Color(0xFF536E9E).withValues(alpha: .022), const Color(0xFF75538D).withValues(alpha: .105), const Color(0xFF536E9E).withValues(alpha: .060), const Color(0xFF536E9E).withValues(alpha: .018), Colors.transparent], stops: const [0, .18, .42, .61, .82, 1]).createShader(Rect.fromLTWH(0, 0, s.width, s.height)));
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * (cinematic ? .045 : .032)..color = const Color(0xFF8A6AA1).withValues(alpha: cinematic ? .040 : .029));

    // Motion stays inside the same filament; visually there is still only one cloud.
    final drift = math.sin(phase * math.pi * 2);
    final shimmer = Path()..moveTo(-m * .11, s.height * (.71 + drift * .005));
    shimmer.cubicTo(s.width * .13, s.height * (.57 + drift * .004), s.width * .32, s.height * (.30 + drift * .004), s.width * .44, s.height * (.27 + drift * .004));
    shimmer.cubicTo(s.width * .60, s.height * (.27 + drift * .004), s.width * .74, s.height * (.52 + drift * .004), s.width * 1.08, s.height * (.41 + drift * .004));
    c.drawPath(shimmer, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * .009..color = const Color(0xFF9A7AB0).withValues(alpha: .015 + .006 * drift));

    final stars = cinematic ? 105 : 58;
    for (var i = 0; i < stars; i++) { final x = _noise(i * 2.13) * s.width, y = _noise(i * 4.71 + 3) * s.height, tw = .55 + .45 * math.sin(phase * math.pi * 2 * (1 + i % 3) + i), r = .22 + (i % 3) * .14; c.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: (.016 + (i % 5) * .0035) * tw)); }
    if (detail) { final p = Paint()..style = PaintingStyle.stroke; for (var i = 0; i < 3; i++) { final rr = m * (.40 + i * .10); p.color = (i.isEven ? const Color(0xFF66467F) : const Color(0xFF3E5D8D)).withValues(alpha: .012); p.strokeWidth = 9 + i * 4; c.drawOval(Rect.fromCenter(center: center, width: rr * 2, height: rr * .36), p); } }
    if (grid) { final p = Paint()..color = Colors.white.withValues(alpha: .009)..style = PaintingStyle.stroke..strokeWidth = .4; for (var i = 0; i < 10; i++) { final x = s.width * i / 9; c.drawLine(Offset(x, 0), Offset(x, s.height), p); final y = s.height * i / 9; c.drawLine(Offset(0, y), Offset(s.width, y), p); } }
    c.drawRect(Offset.zero & s, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .50)]).createShader(Rect.fromLTWH(-m * .2, -m * .2, s.width + m * .4, s.height + m * .4)));
  }
  double _noise(double x) => (math.sin(x * 12.9898) * 43758.5453).abs() % 1.0;
  @override bool shouldRepaint(covariant _DeepSpacePainter o) => o.phase != phase || o.detail != detail || o.cinematic != cinematic || o.grid != grid;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double orbit; final int count, index; final VoidCallback onVisit, onClose, onPrev, onNext;
  const _FloatingVisitPanel({required this.world, required this.compact, required this.orbit, required this.count, required this.index, required this.onVisit, required this.onClose, required this.onPrev, required this.onNext});
  @override Widget build(BuildContext context) {
    final w = compact ? 238.0 : 300.0;
    return LayoutBuilder(builder: (_, c) {
      final m = math.min(c.maxWidth, c.maxHeight), a = index / math.max(1, count) * math.pi * 2 + orbit * .9, rr = m * (compact ? .255 : .285);
      final x = c.maxWidth * .52 + math.cos(a) * rr * 1.62, y = c.maxHeight * .52 + math.sin(a) * rr * .72;
      final left = (x + 46).clamp(12.0, c.maxWidth - w - 12), top = (y - 58).clamp(compact ? 150.0 : 110.0, c.maxHeight - 170.0);
      return AnimatedPositioned(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic, left: left, top: top, child: Material(color: Colors.transparent, child: Container(width: w, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xE8080910), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 15))))]),
        const SizedBox(height: 7),
        Text(world.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1.35)),
        const SizedBox(height: 11),
        Row(children: [Expanded(child: InkWell(onTap: onVisit, child: Container(padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center, color: Colors.white10, child: const Text('VISIT PLANET  →', style: TextStyle(color: Colors.white, fontSize: 7, letterSpacing: 1.5)))), const SizedBox(width: 6), _MiniBtn('‹', onPrev), const SizedBox(width: 4), _MiniBtn('›', onNext)]),
        const SizedBox(height: 8),
        Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}  •  PREV / CURRENT / NEXT', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.05)),
      ]))));
    });
  }
}
class _MiniBtn extends StatelessWidget { final String text; final VoidCallback onTap; const _MiniBtn(this.text, this.onTap); @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)))); }
class _Legend extends StatelessWidget { final bool cinematic, systemMap; const _Legend({required this.cinematic, required this.systemMap}); @override Widget build(BuildContext context) => Row(children: [Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white38)), const SizedBox(width: 7), Text(systemMap ? 'MAP / STRUCTURE' : 'ORBIT / WORLD NODES', style: const TextStyle(color: Colors.white18, fontSize: 5.5, letterSpacing: 1.25)), const SizedBox(width: 14), Text(cinematic ? 'CINEMATIC DEPTH' : 'LOWER LOAD', style: const TextStyle(color: Colors.white12, fontSize: 5.5, letterSpacing: 1.25))]); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => const Text('DRAG • ORBIT    PINCH / + − • ZOOM    ← → • WORLD    ENTER • VISIT    ESC • CLOSE', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.35)); }

Color _tone(GalaxyWorldKind kind) { switch (kind) { case GalaxyWorldKind.vegeta: return const Color(0xFF4C536B); case GalaxyWorldKind.game: return const Color(0xFF425B66); case GalaxyWorldKind.identity: return const Color(0xFF554A66); case GalaxyWorldKind.cinema: return const Color(0xFF614F62); case GalaxyWorldKind.creation: return const Color(0xFF50635F); case GalaxyWorldKind.music: return const Color(0xFF5D4D67); case GalaxyWorldKind.family: return const Color(0xFF5D6254); case GalaxyWorldKind.archive: return const Color(0xFF5B5960); case GalaxyWorldKind.comingSoon: return const Color(0xFF4D5560); } }
