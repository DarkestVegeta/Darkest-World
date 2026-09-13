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
  GalaxyWorldKind? hovered;
  double orbit = 0;
  double zoom = 1;
  bool systemMap = false;
  bool labels = true;
  bool detail = true;

  @override void dispose() { clock.dispose(); super.dispose(); }
  GalaxyWorld? get current {
    for (final w in widget.worlds) { if (w.kind == selected) return w; }
    return null;
  }
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
              zoom = (zoom * d.scale).clamp(.68, 1.62).toDouble();
            } else {
              orbit += d.focalPointDelta.dx / math.max(220.0, size.width);
            }
          }),
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) => Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _DeepSpacePainter(clock.value, systemMap)),
              Transform.scale(scale: zoom, child: CustomPaint(painter: _OrbitArchitecturePainter(clock.value, orbit, systemMap))),
              _WorldOrbit(
                worlds: widget.worlds,
                phase: clock.value,
                orbit: orbit,
                selected: selected,
                hovered: hovered,
                labels: labels,
                detail: detail,
                compact: compact,
                onTap: select,
                onHover: (w) => setState(() => hovered = w?.kind),
              ),
              _Header(systemMap: systemMap, compact: compact),
              Positioned(right: compact ? 12 : 30, top: compact ? 16 : 28, child: _Controls(
                map: systemMap,
                labels: labels,
                detail: detail,
                onIn: () => setState(() => zoom = (zoom + .1).clamp(.68, 1.62).toDouble()),
                onOut: () => setState(() => zoom = (zoom - .1).clamp(.68, 1.62).toDouble()),
                onMap: () => setState(() => systemMap = !systemMap),
                onLabels: () => setState(() => labels = !labels),
                onDetail: () => setState(() => detail = !detail),
                onReset: () => setState(() { orbit = 0; zoom = 1; selected = null; hovered = null; systemMap = false; }),
              )),
              Positioned(left: compact ? 12 : 30, top: compact ? 82 : 92, child: _Telemetry(phase: clock.value, selected: chosen, hovered: hovered, map: systemMap, zoom: zoom)),
              if (chosen != null)
                _FloatingVisitPanel(world: chosen, compact: compact, phase: clock.value, orbit: orbit, count: widget.worlds.length, index: widget.worlds.indexOf(chosen), onVisit: visit, onClose: () => setState(() => selected = null))
              else const Positioned(left: 0, right: 0, bottom: 24, child: Center(child: _Hint())),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool systemMap, compact;
  const _Header({required this.systemMap, required this.compact});
  @override Widget build(BuildContext context) => Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)),
    const SizedBox(height: 7),
    Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5),
    Text(compact ? '09 WORLD NODES' : '09 WORLD NODES  •  PROCEDURAL DEEP SPACE', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]));
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail;
  final VoidCallback onIn, onOut, onMap, onLabels, onDetail, onReset;
  const _Controls({required this.map, required this.labels, required this.detail, required this.onIn, required this.onOut, required this.onMap, required this.onLabels, required this.onDetail, required this.onReset});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    _Btn('+', onIn), _Btn('−', onOut), _Btn(map ? 'ORBIT' : 'MAP', onMap), _Btn(labels ? 'LABELS' : 'CLEAN', onLabels), _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail), _Btn('RESET', onReset),
  ]);
}
class _Btn extends StatelessWidget {
  final String text; final VoidCallback onTap;
  const _Btn(this.text, this.onTap);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 5), child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: Colors.black54, border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.2)))));
}

class _Telemetry extends StatelessWidget {
  final double phase, zoom; final GalaxyWorld? selected; final GalaxyWorldKind? hovered; final bool map;
  const _Telemetry({required this.phase, required this.selected, required this.hovered, required this.map, required this.zoom});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)),
    const SizedBox(height: 4),
    Text('AZ ${(phase * 360).round() % 360}'.padLeft(9, '0') + '°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)),
  ]);
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected, hovered; final bool labels, detail, compact; final ValueChanged<GalaxyWorld> onTap; final ValueChanged<GalaxyWorld?> onHover;
  const _WorldOrbit({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.compact, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => Stack(children: [
    CustomPaint(size: Size(c.maxWidth, c.maxHeight), painter: _CentralSystemPainter(phase, orbit, detail)),
    for (var i = 0; i < worlds.length; i++) _WorldNode(world: worlds[i], index: i, count: worlds.length, phase: phase, orbit: orbit, selected: selected == worlds[i].kind, hovered: hovered == worlds[i].kind, labels: labels, detail: detail, compact: compact, onTap: () => onTap(worlds[i]), onHover: (v) => onHover(v ? worlds[i] : null)),
  ]));
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, orbit; final bool selected, hovered, labels, detail, compact; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _WorldNode({required this.world, required this.index, required this.count, required this.phase, required this.orbit, required this.selected, required this.hovered, required this.labels, required this.detail, required this.compact, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final minSide = math.min(c.maxWidth, c.maxHeight);
    final angle = index / math.max(1, count) * math.pi * 2 + orbit * .9;
    final rr = minSide * (compact ? .27 : .30);
    final x = c.maxWidth * .52 + math.cos(angle) * rr * 1.5;
    final y = c.maxHeight * .52 + math.sin(angle) * rr * .62;
    final depth = (math.sin(angle) + 1) / 2;
    final radius = minSide * (.040 + depth * .022 + (selected ? .018 : 0) + (hovered ? .010 : 0));
    final size = radius * 3.15;
    return Positioned(left: x - size / 2, top: y - size / 2, width: size, height: size, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(true), onExit: (_) => onHover(false), child: GestureDetector(onTap: onTap, child: CustomPaint(painter: _NodePainter(world.kind, phase, index, selected, hovered, labels, detail, world.title)))));
  });
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit; final bool detail;
  _CentralSystemPainter(this.phase, this.orbit, this.detail);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 16; i++) { final r = m * (.11 + i * .029); p.color = Colors.white.withValues(alpha: .018 + (i % 4) * .008); p.strokeWidth = i == 7 ? 1.1 : .42; final tilt = .28 + (i % 5) * .045; c.drawOval(Rect.fromCenter(center: center, width: r * 2.4, height: r * tilt * 2), p); }
    for (var i = 0; i < 36; i++) { final a = phase * math.pi * 2 * (.22 + (i % 5) * .045) + orbit * .4 + i * math.pi * 2 / 36; final r = m * (.14 + (i % 9) * .023); final q = Offset(center.dx + math.cos(a) * r * 1.25, center.dy + math.sin(a) * r * .42); c.drawCircle(q, .7 + i % 3 * .45, Paint()..color = Colors.white.withValues(alpha: .10 + (i % 4) * .025)); }
    final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .24), const Color(0xFF6D4A8B).withValues(alpha: .12), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .19)); c.drawCircle(center, m * .19, glow);
    c.drawCircle(center, m * .052, Paint()..shader = RadialGradient(colors: [Colors.white54, const Color(0xFF6A4A82), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .052)));
    if (detail) { for (var i = 0; i < 8; i++) { final a = phase * 4 + i * math.pi / 4; final r = m * (.075 + (i % 3) * .012); final q = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r * .6); c.drawLine(center, q, Paint()..color = Colors.white.withValues(alpha: .025)..strokeWidth = .8); } }
  }
  @override bool shouldRepaint(covariant _CentralSystemPainter old) => old.phase != phase || old.orbit != orbit || old.detail != detail;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit; final bool map;
  _OrbitArchitecturePainter(this.phase, this.orbit, this.map);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52); final m = math.min(s.width, s.height); final p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 13; i++) { final r = m * (.13 + i * .027); p.color = Colors.white.withValues(alpha: map ? .050 : .030 + (i % 3) * .007); p.strokeWidth = i == 6 ? 1.2 : .45; c.drawOval(Rect.fromCenter(center: center, width: r * 2.35, height: r * (.34 + (i % 4) * .07) * 2), p); }
    for (var i = 0; i < 24; i++) { final a = phase * math.pi * 2 * (.25 + i % 4 * .06) + orbit * .5 + i * math.pi * 2 / 24; final r = m * (.15 + (i % 6) * .025); final q = Offset(center.dx + math.cos(a) * r * 1.17, center.dy + math.sin(a) * r * .42); c.drawCircle(q, 1.2 + (i % 3) * .5, Paint()..color = Colors.white.withValues(alpha: .13)); }
  }
  @override bool shouldRepaint(covariant _OrbitArchitecturePainter old) => old.phase != phase || old.orbit != orbit || old.map != map;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind; final double phase; final int index; final bool selected, hovered, labels, detail; final String title;
  _NodePainter(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.title);
  @override void paint(Canvas c, Size s) {
    final p = Offset(s.width / 2, s.height / 2); final r = s.width * .31; final rect = Rect.fromCircle(center: p, radius: r);
    c.drawCircle(p, r * (hovered ? 1.8 : 1.55), Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: selected ? .23 : hovered ? .14 : .07), Colors.transparent]).createShader(rect.inflate(r)));
    c.drawCircle(p, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.05, colors: [const Color(0xFF9AA7B8), _tone(kind), const Color(0xFF02030A)]).createShader(rect));
    c.save(); c.clipPath(Path()..addOval(rect));
    final terrain = Paint()..color = Colors.white.withValues(alpha: detail ? .085 : .045);
    for (var i = 0; i < 30; i++) { final a = i * 2.41 + index * .7; final rr = r * (.10 + (i % 8) * .105); final q = p + Offset(math.cos(a) * rr, math.sin(a) * rr * .68); c.drawOval(Rect.fromCenter(center: q, width: r * (.07 + (i % 5) * .085), height: r * (.04 + (i % 4) * .065)), terrain); }
    if (detail) { final ridge = Paint()..color = Colors.white.withValues(alpha: .10)..style = PaintingStyle.stroke..strokeWidth = .65; for (var i = 0; i < 7; i++) { final rr = r * (.22 + i * .10); c.drawArc(Rect.fromCircle(center: p + Offset(-r * .18, r * .08), radius: rr), .25 + i * .11, 1.2 + (i % 3) * .22, false, ridge); } }
    final clouds = Paint()..color = Colors.white.withValues(alpha: .075)..style = PaintingStyle.stroke..strokeWidth = r * .06; for (var i = 0; i < 4; i++) { final y = p.dy - r * .55 + i * r * .37; c.drawArc(Rect.fromCenter(center: Offset(p.dx, y), width: r * 1.8, height: r * .5), phase * 6 + i, 1.6, false, clouds); }
    c.restore();
    c.drawCircle(p, r, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .035..color = Colors.white.withValues(alpha: selected ? .68 : hovered ? .48 : .20));
    if (selected) { c.drawCircle(p, r * 1.23, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = Colors.white38); c.drawCircle(p, r * 1.36, Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = Colors.white12); }
    if (labels) { final tp = TextPainter(text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: selected ? .82 : hovered ? .58 : .35), fontSize: 7, letterSpacing: 1.2)), textDirection: TextDirection.ltr)..layout(maxWidth: 150); tp.paint(c, Offset(p.dx - tp.width / 2, r * 1.48)); }
  }
  Color _tone(GalaxyWorldKind k) { switch (k) { case GalaxyWorldKind.game: return const Color(0xFF244B54); case GalaxyWorldKind.identity: return const Color(0xFF4B385E); case GalaxyWorldKind.cinema: return const Color(0xFF484062); case GalaxyWorldKind.creation: return const Color(0xFF31584E); case GalaxyWorldKind.music: return const Color(0xFF55395A); case GalaxyWorldKind.family: return const Color(0xFF4B4058); case GalaxyWorldKind.archive: return const Color(0xFF4C4939); case GalaxyWorldKind.comingSoon: return const Color(0xFF353C4F); case GalaxyWorldKind.vegeta: return const Color(0xFF523D66); } }
  @override bool shouldRepaint(covariant _NodePainter old) => old.phase != phase || old.kind != kind || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.title != title;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase; final bool map;
  _DeepSpacePainter(this.phase, this.map);
  @override void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107));
    final rnd = math.Random(812);
    for (var i = 0; i < 1100; i++) { final z = rnd.nextDouble(); final a = (.025 + z * .14 + math.sin(phase * math.pi * 2 * (1 + z * 3) + i) * .018).clamp(.01, .18); c.drawCircle(Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height), .22 + z * 1.05, Paint()..color = Colors.white.withValues(alpha: a)); }
    final haze = Paint()..shader = RadialGradient(colors: [const Color(0xFF37245A).withValues(alpha: map ? .17 : .10), const Color(0xFF18213A).withValues(alpha: .035), Colors.transparent]).createShader(Rect.fromCenter(center: Offset(s.width * .53, s.height * .52), width: s.width * .95, height: s.height * .82));
    c.drawOval(Rect.fromCenter(center: Offset(s.width * .53, s.height * .52), width: s.width * .95, height: s.height * .82), haze);
    final dust = Paint()..style = PaintingStyle.stroke..strokeWidth = 1; for (var i = 0; i < 7; i++) { final y = s.height * (.12 + i * .13) + math.sin(phase * 4 + i) * 12; dust.color = const Color(0xFF6A5285).withValues(alpha: .025); c.drawArc(Rect.fromCenter(center: Offset(s.width * .55, y), width: s.width * 1.1, height: s.height * .32), 2.7, 1.1, false, dust); }
  }
  @override bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.map != map;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double phase, orbit; final int count, index; final VoidCallback onVisit, onClose;
  const _FloatingVisitPanel({required this.world, required this.compact, required this.phase, required this.orbit, required this.count, required this.index, required this.onVisit, required this.onClose});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final minSide = math.min(c.maxWidth, c.maxHeight); final angle = index / math.max(1, count) * math.pi * 2 + orbit * .9; final rr = minSide * (compact ? .27 : .30);
    final x = c.maxWidth * .52 + math.cos(angle) * rr * 1.5; final y = c.maxHeight * .52 + math.sin(angle) * rr * .62; final w = compact ? 190.0 : 230.0; final left = (x + (math.cos(angle) >= 0 ? 34 : -w - 34)).clamp(12.0, c.maxWidth - w - 12.0); final top = (y - 55).clamp(70.0, c.maxHeight - 125.0);
    return AnimatedPositioned(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, left: left, top: top, width: w, child: Material(color: Colors.transparent, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xEE080812), border: Border.all(color: Colors.white.withValues(alpha: .16)), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 16))))]),
      const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 8, height: 1.4)),
      const SizedBox(height: 12), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onVisit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF21172D), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 11), shape: const RoundedRectangleBorder()), child: const Text('VISIT PLANET  →', style: TextStyle(fontSize: 8, letterSpacing: 1.8)))),
      const SizedBox(height: 7), const Text('ENTER  •  VISIT        ESC  •  CLOSE', style: TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.1)),
    ]))));
  });
}

class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => const Text('DRAG TO ORBIT  •  SCROLL / PINCH TO ZOOM  •  HOVER / SELECT A WORLD', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.4)); }
