import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_navigation_session.dart';

class DarkestWorldDetailChamberOverlay extends StatefulWidget {
  const DarkestWorldDetailChamberOverlay({super.key});
  @override State<DarkestWorldDetailChamberOverlay> createState() => _DetailChamberOverlayState();
}

class _DetailChamberOverlayState extends State<DarkestWorldDetailChamberOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 96))..repeat();
  @override void initState() { super.initState(); GalaxyNavigationSession.instance.addListener(_changed); }
  void _changed() { if (mounted) setState(() {}); }
  @override void dispose() { GalaxyNavigationSession.instance.removeListener(_changed); _clock.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final state = GalaxyNavigationSession.instance.contentNavigation;
    if (state == null) return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 900;
    return IgnorePointer(child: AnimatedBuilder(
      animation: _clock,
      builder: (_, __) => Positioned.fill(child: CustomPaint(
        painter: _DetailChamberPainter(_clock.value),
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 10 : 30, compact ? 72 : 92, compact ? 10 : 30, compact ? 72 : 98),
          child: Align(alignment: Alignment.bottomCenter, child: Container(
            constraints: const BoxConstraints(maxWidth: 1500),
            padding: EdgeInsets.all(compact ? 10 : 14),
            decoration: BoxDecoration(
              color: const Color(0xD9080912),
              border: Border.all(color: const Color(0x447F70B0)),
              boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 34, spreadRadius: 1)],
            ),
            child: compact ? _Compact(state: state, phase: _clock.value) : _Wide(state: state, phase: _clock.value),
          )),
        ),
      )),
    ));
  }
}

class _Wide extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final double phase;
  const _Wide({required this.state, required this.phase});
  @override Widget build(BuildContext context) => Column(children: [
    Row(children: [
      const _Label('DETAIL COMMAND LAYER'),
      const SizedBox(width: 12),
      Expanded(child: Text(state.current.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.w300))),
      _Status(value: state.source.toUpperCase()),
      const SizedBox(width: 8),
      _Status(value: state.entryLabel),
    ]),
    const SizedBox(height: 12),
    SizedBox(height: 72, child: Row(children: [
      Expanded(child: _Node(label: 'PREVIOUS', value: state.previous?.title ?? '—', active: state.previous != null)),
      const _Connector(),
      Expanded(flex: 2, child: _Node(label: 'CURRENT', value: state.current.title, active: true, strong: true)),
      const _Connector(),
      Expanded(child: _Node(label: 'NEXT', value: state.next?.title ?? '—', active: state.next != null)),
      const SizedBox(width: 18),
      SizedBox(width: 150, child: _RelationTelemetry(state: state)),
    ])),
    const SizedBox(height: 10),
    _ArchiveSignalRail(state: state, phase: phase),
  ]);
}

class _Compact extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final double phase;
  const _Compact({required this.state, required this.phase});
  @override Widget build(BuildContext context) => Column(children: [
    Row(children: [const _Label('DETAIL'), const SizedBox(width: 8), Expanded(child: Text(state.current.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, letterSpacing: 1.6))), _Status(value: '${state.related.length} REL')]),
    const SizedBox(height: 9),
    Row(children: [
      Expanded(child: _Node(label: 'PREV', value: state.previous?.title ?? '—', active: state.previous != null)),
      const SizedBox(width: 5),
      Expanded(flex: 2, child: _Node(label: 'CURRENT', value: state.current.title, active: true, strong: true)),
      const SizedBox(width: 5),
      Expanded(child: _Node(label: 'NEXT', value: state.next?.title ?? '—', active: state.next != null)),
    ]),
    const SizedBox(height: 7),
    _ArchiveSignalRail(state: state, phase: phase, compact: true),
  ]);
}

class _ArchiveSignalRail extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final double phase;
  final bool compact;
  const _ArchiveSignalRail({required this.state, required this.phase, this.compact = false});
  @override Widget build(BuildContext context) {
    final origin = state.originId != null;
    final relation = state.related.length;
    final continuity = (state.previous != null ? 1 : 0) + (state.next != null ? 1 : 0);
    return Container(
      height: compact ? 27 : 32,
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 9),
      decoration: BoxDecoration(
        color: const Color(0x090D101B),
        border: Border.all(color: const Color(0x223C4660)),
      ),
      child: Row(children: [
        _SignalMark(label: 'ORIGIN', value: origin ? 'LOCKED' : 'OPEN', active: origin, phase: phase),
        _RailDivider(),
        _SignalMark(label: 'CHAIN', value: '$continuity/2', active: continuity > 0, phase: phase + .17),
        _RailDivider(),
        _SignalMark(label: 'REL', value: relation.toString().padLeft(2, '0'), active: relation > 0, phase: phase + .34),
        if (!compact) ...[
          _RailDivider(),
          Expanded(child: Row(children: [
            const Text('ARCHIVE SIGNAL', style: TextStyle(fontSize: 5, letterSpacing: 1.7, color: Color(0x557F90A4))),
            const SizedBox(width: 9),
            Expanded(child: _SignalLine(phase: phase)),
            const SizedBox(width: 8),
            Text(state.current.type.name.toUpperCase(), style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x668F9DB0))),
          ])),
        ],
      ]),
    );
  }
}

class _SignalMark extends StatelessWidget {
  final String label, value;
  final bool active;
  final double phase;
  const _SignalMark({required this.label, required this.value, required this.active, required this.phase});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    _PulseDot(active: active, phase: phase),
    const SizedBox(width: 5),
    Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1.4, color: Color(0x447F90A4))),
      const SizedBox(height: 1),
      Text(value, style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: active ? const Color(0x998F9DB0) : const Color(0x447F8795))),
    ]),
  ]);
}

class _PulseDot extends StatelessWidget {
  final bool active;
  final double phase;
  const _PulseDot({required this.active, required this.phase});
  @override Widget build(BuildContext context) {
    final glow = active ? .35 + .25 * math.sin(phase * math.pi * 2).abs() : .15;
    return Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(143, 130, 185, glow), boxShadow: active ? [BoxShadow(color: Color.fromRGBO(143, 130, 185, glow * .6), blurRadius: 5)] : null));
  }
}

class _RailDivider extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width: 1, height: 15, margin: const EdgeInsets.symmetric(horizontal: 10), color: const Color(0x223C4660));
}

class _SignalLine extends StatelessWidget {
  final double phase;
  const _SignalLine({required this.phase});
  @override Widget build(BuildContext context) => SizedBox(height: 8, child: CustomPaint(painter: _SignalLinePainter(phase)));
}

class _SignalLinePainter extends CustomPainter {
  final double phase;
  const _SignalLinePainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final y = s.height * .5;
    c.drawLine(Offset.zero.translate(0, y), Offset(s.width, y), Paint()..color = const Color(0x243F4B64)..strokeWidth = .7);
    final x = (phase * s.width) % (s.width + 26) - 13;
    c.drawLine(Offset(x, y), Offset(math.min(s.width, x + 26), y), Paint()..color = const Color(0x668F82B9)..strokeWidth = 1.1);
    for (var i = 1; i < 12; i++) {
      final px = s.width * i / 12;
      c.drawCircle(Offset(px, y), i % 4 == 0 ? 1.2 : .7, Paint()..color = const Color(0x3D8F9DB0));
    }
  }
  @override bool shouldRepaint(covariant _SignalLinePainter old) => old.phase != phase;
}

class _Node extends StatelessWidget {
  final String label, value; final bool active, strong;
  const _Node({required this.label, required this.value, required this.active, this.strong = false});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
    decoration: BoxDecoration(color: active ? const Color(0x140E1020) : const Color(0x09090C13), border: Border.all(color: active ? const Color(0x397F70B0) : const Color(0x182C3342))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label, style: TextStyle(fontSize: 5, letterSpacing: 1.8, color: active ? const Color(0x778F9DB0) : const Color(0x3D7F8795))),
      const SizedBox(height: 5),
      Text(value.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: strong ? 8 : 6.5, letterSpacing: strong ? 1.3 : .9, color: active ? const Color(0xC8FFFFFF) : const Color(0x557F8795), fontWeight: strong ? FontWeight.w400 : FontWeight.w300)),
    ]),
  );
}

class _Connector extends StatelessWidget { const _Connector(); @override Widget build(BuildContext context) => SizedBox(width: 24, child: CustomPaint(painter: _ConnectorPainter())); }
class _ConnectorPainter extends CustomPainter {
  @override void paint(Canvas c, Size s) { final y = s.height * .5; c.drawLine(Offset(1, y), Offset(s.width - 1, y), Paint()..color = const Color(0x397F70B0)..strokeWidth = .7); c.drawCircle(Offset(s.width * .5, y), 2, Paint()..color = const Color(0x778F82B9)); }
  @override bool shouldRepaint(covariant _ConnectorPainter old) => false;
}

class _RelationTelemetry extends StatelessWidget {
  final DarkestWorldNavigationState state;
  const _RelationTelemetry({required this.state});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('RELATION FIELD', style: TextStyle(fontSize: 5, letterSpacing: 1.8, color: Color(0x557F90A4))),
    const SizedBox(height: 5),
    Row(children: [
      SizedBox(width: 28, height: 28, child: CustomPaint(painter: _MiniRelationPainter(state.related.length))),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${state.related.length.toString().padLeft(2, '0')} CONNECTED', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.1)),
        const SizedBox(height: 3),
        Text(state.originId == null ? 'NO ORIGIN' : 'ORIGIN LOCKED', style: const TextStyle(fontSize: 5, letterSpacing: 1, color: Color(0x557F90A4))),
      ])),
    ]),
  ]);
}

class _MiniRelationPainter extends CustomPainter {
  final int count; const _MiniRelationPainter(this.count);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .5); final n = math.max(1, math.min(count, 7));
    c.drawCircle(center, 8, Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x557F70B0));
    for (var i = 0; i < n; i++) { final a = i * math.pi * 2 / n; final p = Offset(center.dx + math.cos(a) * 13, center.dy + math.sin(a) * 13); c.drawLine(center, p, Paint()..color = const Color(0x307F90A4)); c.drawCircle(p, 1.5, Paint()..color = const Color(0x6A8F82B9)); }
  }
  @override bool shouldRepaint(covariant _MiniRelationPainter old) => old.count != count;
}

class _Label extends StatelessWidget { final String value; const _Label(this.value); @override Widget build(BuildContext context) => Text(value, style: const TextStyle(fontSize: 5.5, letterSpacing: 2.2, color: Color(0x667F8EA2))); }
class _Status extends StatelessWidget { final String value; const _Status({required this.value}); @override Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xC906070D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), child: Text(value, style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x668F9DB0))))); }

class _DetailChamberPainter extends CustomPainter {
  final double phase; const _DetailChamberPainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final r = Offset.zero & s; final center = Offset(s.width * .5, s.height * .53); final m = math.min(s.width, s.height);
    for (var i = 0; i < 7; i++) { final f = .22 + i * .065; c.drawOval(Rect.fromCenter(center: center, width: m * f * 2.3, height: m * f * .72), Paint()..style = PaintingStyle.stroke..strokeWidth = .4..color = const Color(0x137F70B0)); }
    final a = phase * math.pi * 2; c.drawArc(Rect.fromCenter(center: center, width: m * .94, height: m * .32), a, .72, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..strokeCap = StrokeCap.round..color = const Color(0x3D8F82B9));
    final scan = (phase * s.height * 1.15) % (s.height + 80) - 40; c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x117F9AB0));
    for (var i = 0; i < 96; i++) { final seed = i * 13.77; final p = Offset((math.sin(seed) * .5 + .5) * s.width, (math.cos(seed * .71) * .5 + .5) * s.height); c.drawCircle(p, .3 + (i % 3) * .2, Paint()..color = const Color(0x287F90A4)); }
    c.drawRect(r, Paint()..shader = const RadialGradient(radius: 1.1, colors: [Color(0x00000000), Color(0x55000000)]).createShader(r));
  }
  @override bool shouldRepaint(covariant _DetailChamberPainter old) => old.phase != phase;
}
