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
  double zoom = 1;
  bool systemMap = false;
  bool labels = true;
  bool detail = true;
  bool cinematic = true;

  @override void dispose() { clock.dispose(); super.dispose(); }
  GalaxyWorld? get current => selected == null ? null : widget.worlds.cast<GalaxyWorld?>().firstWhere((w) => w!.kind == selected, orElse: () => null);
  void select(GalaxyWorld w) => setState(() => selected = selected == w.kind ? null : w.kind);
  void visit() { final w = current; if (w != null) widget.onWorldTap?.call(w); }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final chosen = current;
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { setState(() => selected = null); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: GestureDetector(
          onScaleUpdate: (d) => setState(() {
            if (d.pointerCount > 1) {
              zoom = (zoom * d.scale).clamp(.66, 1.70).toDouble();
            } else {
              orbit += d.focalPointDelta.dx / math.max(220.0, size.width);
            }
          }),
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _DeepSpacePainter(clock.value, detail, cinematic)),
              CustomPaint(painter: _GalaxyDustPainter(clock.value, cinematic)),
              Transform.scale(
                scale: zoom,
                child: CustomPaint(painter: _OrbitArchitecturePainter(clock.value, orbit, systemMap, detail)),
              ),
              _WorldOrbit(
                worlds: widget.worlds,
                phase: clock.value,
                orbit: orbit,
                selected: selected,
                hovered: hovered,
                labels: labels,
                detail: detail,
                cinematic: cinematic,
                compact: compact,
                onTap: select,
                onHover: (w) => setState(() => hovered = w?.kind),
              ),
              _Header(systemMap: systemMap, compact: compact, cinematic: cinematic),
              Positioned(right: compact ? 10 : 26, top: compact ? 70 : 26, child: _Controls(
                map: systemMap,
                labels: labels,
                detail: detail,
                cinematic: cinematic,
                onIn: () => setState(() => zoom = (zoom + .1).clamp(.66, 1.70).toDouble()),
                onOut: () => setState(() => zoom = (zoom - .1).clamp(.66, 1.70).toDouble()),
                onMap: () => setState(() => systemMap = !systemMap),
                onLabels: () => setState(() => labels = !labels),
                onDetail: () => setState(() => detail = !detail),
                onCinematic: () => setState(() => cinematic = !cinematic),
                onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; hovered = null; systemMap = false; detail = true; cinematic = true; }),
              )),
              Positioned(left: compact ? 12 : 30, top: compact ? 112 : 92, child: _Telemetry(phase: clock.value, selected: chosen, hovered: hovered, map: systemMap, zoom: zoom, cinematic: cinematic)),
              if (chosen != null)
                _FloatingVisitPanel(world: chosen, compact: compact, phase: clock.value, orbit: orbit, count: widget.worlds.length, index: widget.worlds.indexOf(chosen), onVisit: visit, onClose: () => setState(() => selected = null))
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
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 16; i++) { final r = m * (.12 + i * .030); p.color = Colors.white.withValues(alpha: map ? .045 : .022 + (i % 3) * .006); p.strokeWidth = i == 7 ? 1.1 : .42; c.drawOval(Rect.fromCenter(center: center, width: r * 2.4, height: r * (.31 + (i % 5) * .065) * 2), p); }
    if (detail) { for (var i = 0; i < 13; i++) { final r = m * (.15 + i * .035); p.color = Colors.white.withValues(alpha: map ? .025 : .014); p.strokeWidth = .34; c.drawOval(Rect.fromCenter(center: center, width: r * 2.7, height: r * .28), p); } }
    for (var i = 0; i < 40; i++) { final a = phase * math.pi * 2 * (.22 + i % 5 * .045) + orbit * .5 + i * math.pi * 2 / 40; final r = m * (.15 + (i % 8) * .027); final q = Offset(center.dx + math.cos(a) * r * 1.20, center.dy + math.sin(a) * r * .43); c.drawCircle(q, 1.0 + (i % 3) * .45, Paint()..color = Colors.white.withValues(alpha: .095)); }
  }
  @override bool shouldRepaint(covariant _OrbitArchitecturePainter old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind; final double phase; final int index; final bool selected, hovered, labels, detail, cinematic; final String title;
  _NodePainter(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cinematic, this.title);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2); final r = s.width * .30; final rect = Rect.fromCircle(center: center, radius: r);
    c.drawCircle(center, r * (hovered ? 1.95 : 1.62), Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: selected ? .24 : hovered ? .16 : .06), Colors.transparent]).createShader(rect.inflate(r)));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.04, colors: [const Color(0xFFB5BFCA), _tone(kind), const Color(0xFF03040A)]).createShader(rect));
    final dark = Paint()..shader = RadialGradient(center: const Alignment(.70, .62), radius: .92, colors: [Colors.transparent, Colors.black.withValues(alpha: .72)]).createShader(rect); c.drawCircle(center, r, dark);
    final surface = Paint()..style = PaintingStyle.stroke;
    final contourCount = cinematic ? 9 : 5;
    for (var j = 0; j < contourCount; j++) {
      final rr = r * (.42 + j * .055); final path = Path();
      for (var k = 0; k <= 26; k++) { final a = k / 26 * math.pi * 2; final wave = math.sin(a * (2 + j % 3) + index * .8) * r * .025 + math.cos(a * 5 + j) * r * .014; final q = Offset(center.dx + math.cos(a) * (rr + wave), center.dy + math.sin(a) * (rr + wave) * .60); if (k == 0) { path.moveTo(q.dx, q.dy); } else { path.lineTo(q.dx, q.dy); } }
      surface.color = Colors.white.withValues(alpha: .055 - j * .003); surface.strokeWidth = .55; c.drawPath(path, surface);
    }
    final details = cinematic ? 38 : 18;
    for (var i = 0; i < details; i++) { final a = i * 2.399 + index * .73; final rr = r * (.30 + ((i * 17) % 54) / 100); final q = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .63); final cr = .7 + (i % 3) * .45; c.drawCircle(q, cr, Paint()..color = Colors.white.withValues(alpha: .055 + (i % 4) * .012)); }
    final cloudCount = cinematic ? 7 : 3;
    for (var i = 0; i < cloudCount; i++) { final a = phase * math.pi * 2 * (.16 + i * .025) + index * .4 + i; final rr = r * (.68 + (i % 2) * .08); final q = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .34); c.drawArc(Rect.fromCenter(center: q, width: r * .78, height: r * .20), a, 1.0, false, Paint()..color = Colors.white.withValues(alpha: .035)..style = PaintingStyle.stroke..strokeWidth = 1.2); }
    if (selected) { c.drawCircle(center, r * 1.22, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1.0); c.drawCircle(center, r * 1.32, Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = .6); }
    if (labels) { final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: selected ? .82 : hovered ? .72 : .42), fontSize: math.max(6, s.width * .025), letterSpacing: 1.2)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.2); tp.paint(c, Offset(center.dx - tp.width / 2, center.dy + r * 1.38)); }
  }
  @override bool shouldRepaint(covariant _NodePainter old) => old.kind != kind || old.phase != phase || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.cinematic != cinematic || old.title != title;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase; final bool detail, cinematic;
  _DeepSpacePainter(this.phase, this.detail, this.cinematic);
  @override void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height);
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107));
    final base = Paint()..shader = RadialGradient(colors: [const Color(0xFF39224F).withValues(alpha: .22), const Color(0xFF17234A).withValues(alpha: .10), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(s.width * .48, s.height * .48), radius: m * .82));
    c.drawCircle(Offset(s.width * .48, s.height * .48), m * .82, base);

    final veil = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final veilLayers = cinematic ? 9 : 6;
    for (var i = 0; i < veilLayers; i++) {
      final path = Path();
      final y0 = s.height * (.16 + i * .085);
      path.moveTo(-m * .10, y0);
      path.cubicTo(s.width * .18, y0 - m * (.15 + i * .012), s.width * .38, y0 + m * (.18 + i * .010), s.width * .62, y0 - m * (.05 + i * .008));
      path.cubicTo(s.width * .80, y0 - m * (.13 + i * .012), s.width * 1.02, y0 + m * (.11 + i * .010), s.width * 1.12, y0 - m * .02);
      final alpha = .045 - i * .0025;
      veil.color = (i.isEven ? const Color(0xFF6A4C86) : const Color(0xFF405F91)).withValues(alpha: alpha);
      veil.strokeWidth = m * (.085 + (i % 3) * .018);
      c.drawPath(path, veil);
    }

    final transparentWindows = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final path = Path();
      final y0 = s.height * (.24 + i * .14);
      path.moveTo(-m * .08, y0);
      path.cubicTo(s.width * .25, y0 + m * .10, s.width * .44, y0 - m * .12, s.width * .72, y0 + m * .04);
      path.cubicTo(s.width * .88, y0 + m * .11, s.width * 1.02, y0 - m * .08, s.width * 1.10, y0);
      transparentWindows.color = (i % 2 == 0 ? const Color(0xFF7C5A99) : const Color(0xFF5876A3)).withValues(alpha: .018);
      transparentWindows.strokeWidth = m * .045;
      c.drawPath(path, transparentWindows);
    }

    final stars = cinematic ? 190 : 90;
    for (var i = 0; i < stars; i++) {
      final x = _noise(i * 2.13) * s.width; final y = _noise(i * 4.71 + 3) * s.height;
      final tw = .55 + .45 * math.sin(phase * math.pi * 2 * (1 + i % 3) + i);
      final r = .22 + (i % 3) * .14;
      c.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: (.022 + (i % 5) * .006) * tw));
    }

    if (detail) {
      final p = Paint()..style = PaintingStyle.stroke;
      for (var i = 0; i < 5; i++) { final rr = m * (.34 + i * .09); p.color = (i.isEven ? const Color(0xFF66467F) : const Color(0xFF3E5D8D)).withValues(alpha: .018); p.strokeWidth = 12 + i * 5; c.drawOval(Rect.fromCenter(center: Offset(s.width * .50, s.height * .50), width: rr * 2.0, height: rr * .40), p); }
    }
    final vignette = Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .48)]).createShader(Rect.fromLTWH(-m * .2, -m * .2, s.width + m * .4, s.height + m * .4));
    c.drawRect(Offset.zero & s, vignette);
  }
  double _noise(double x) => (math.sin(x * 12.9898) * 43758.5453).abs() % 1.0;
  @override bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.detail != detail || old.cinematic != cinematic;
}

class _GalaxyDustPainter extends CustomPainter {
  final double phase; final bool cinematic;
  _GalaxyDustPainter(this.phase, this.cinematic);
  @override void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height); final center = Offset(s.width * .50, s.height * .50); final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; final count = cinematic ? 72 : 38;
    for (var i = 0; i < count; i++) {
      final a = i * .73 + phase * math.pi * 2 * .045; final rr = m * (.16 + (i % 21) * .021);
      final q = Offset(center.dx + math.cos(a) * rr * 1.75, center.dy + math.sin(a) * rr * .48);
      p.color = (i.isEven ? const Color(0xFF74558D) : const Color(0xFF526F9D)).withValues(alpha: .014 + (i % 4) * .004);
      p.strokeWidth = 2.0 + (i % 3) * 1.2;
      c.drawLine(q, q + Offset(math.cos(a + 1.2) * m * .035, math.sin(a + 1.2) * m * .010), p);
    }
  }
  @override bool shouldRepaint(covariant _GalaxyDustPainter old) => old.phase != phase || old.cinematic != cinematic;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double phase, orbit; final int count, index; final VoidCallback onVisit, onClose;
  const _FloatingVisitPanel({required this.world, required this.compact, required this.phase, required this.orbit, required this.count, required this.index, required this.onVisit, required this.onClose});
  @override Widget build(BuildContext context) {
    final w = compact ? 230.0 : 285.0;
    final a = index / math.max(1, count) * math.pi * 2 + orbit * .9;
    return LayoutBuilder(builder: (_, c) {
      final minSide = math.min(c.maxWidth, c.maxHeight); final rr = minSide * (compact ? .255 : .285); final x = c.maxWidth * .52 + math.cos(a) * rr * 1.62; final y = c.maxHeight * .52 + math.sin(a) * rr * .72;
      final left = (x + 46).clamp(12.0, c.maxWidth - w - 12); final top = (y - 58).clamp(compact ? 150.0 : 110.0, c.maxHeight - 170.0);
      return AnimatedPositioned(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic, left: left, top: top, child: Material(color: Colors.transparent, child: Container(width: w, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xE8080910), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 15))))]),
        const SizedBox(height: 7), Text(world.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1.35)),
        const SizedBox(height: 11), Row(children: [Expanded(child: InkWell(onTap: onVisit, child: Container(padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center, color: Colors.white10, child: const Text('VISIT PLANET  →', style: TextStyle(color: Colors.white, fontSize: 7, letterSpacing: 1.5)))), const SizedBox(width: 7), const Text('ENTER', style: TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.2))]),
      ]))));
    });
  }
}

class _Hint extends StatelessWidget {
  const _Hint();
  @override Widget build(BuildContext context) => const Text('DRAG  •  ORBIT     PINCH / + −  •  ZOOM     CLICK A WORLD  •  INSPECT', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5));
}

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
