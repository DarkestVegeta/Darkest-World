import 'dart:math' as math;
import 'package:flutter/gestures.dart';
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
  int? selected;
  double orbit = 0, zoom = 1;
  bool autoOrbit = true, map = false, labels = true;

  @override void dispose() { clock.dispose(); super.dispose(); }
  void select(int index) { if (index < 0 || index >= widget.worlds.length) return; setState(() => selected = selected == index ? null : index); }
  void move(int delta) { if (widget.worlds.isEmpty) return; final current = selected ?? 0; select((current + delta + widget.worlds.length) % widget.worlds.length); }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _Prev(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _Next(),
        SingleActivator(LogicalKeyboardKey.keyM): _Map(),
        SingleActivator(LogicalKeyboardKey.keyL): _Labels(),
        SingleActivator(LogicalKeyboardKey.space): _Orbit(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      actions: <Type, Action<Intent>>{
        _Prev: CallbackAction<_Prev>(onInvoke: (_) { move(-1); return null; }),
        _Next: CallbackAction<_Next>(onInvoke: (_) { move(1); return null; }),
        _Map: CallbackAction<_Map>(onInvoke: (_) { setState(() => map = !map); return null; }),
        _Labels: CallbackAction<_Labels>(onInvoke: (_) { setState(() => labels = !labels); return null; }),
        _Orbit: CallbackAction<_Orbit>(onInvoke: (_) { setState(() => autoOrbit = !autoOrbit); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { setState(() => selected = null); return null; }),
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) setState(() => zoom = (zoom - event.scrollDelta.dy * .00065).clamp(.65, 1.7).toDouble());
        },
        child: GestureDetector(
          onPanUpdate: (details) { if (!map && !autoOrbit) setState(() => orbit += details.delta.dx / math.max(220, size.width)); },
          onDoubleTap: () => setState(() { zoom = 1; orbit = 0; selected = null; }),
          child: AnimatedBuilder(animation: clock, builder: (_, __) {
            final phase = autoOrbit ? clock.value * math.pi * 2 : orbit;
            return Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _SpacePainter(clock.value)),
              if (map) _MapView(worlds: widget.worlds, selected: selected, onSelect: select),
              if (!map) _OrbitView(worlds: widget.worlds, phase: phase, selected: selected, labels: labels, onSelect: select),
              Positioned(left: 20, bottom: 18, child: _Hud(worlds: widget.worlds.length, selected: selected, zoom: zoom, map: map, orbit: autoOrbit)),
              Positioned(right: 20, bottom: 18, child: Row(children: [_Button(label: autoOrbit ? 'ORBIT ON' : 'ORBIT OFF', onTap: () => setState(() => autoOrbit = !autoOrbit)), const SizedBox(width: 5), _Button(label: map ? 'PLANET' : 'MAP', onTap: () => setState(() => map = !map)), const SizedBox(width: 5), _Button(label: '−', onTap: () => setState(() => zoom = math.max(.65, zoom - .1))), const SizedBox(width: 3), _Button(label: '+', onTap: () => setState(() => zoom = math.min(1.7, zoom + .1)))])),
            ]);
          }),
        ),
      ),
    );
  }
}

class _Prev extends Intent { const _Prev(); }
class _Next extends Intent { const _Next(); }
class _Map extends Intent { const _Map(); }
class _Labels extends Intent { const _Labels(); }
class _Orbit extends Intent { const _Orbit(); }

class _SpacePainter extends CustomPainter {
  final double t; const _SpacePainter(this.t);
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF171326), Color(0xFF07070F), Color(0xFF010106)]).createShader(Offset.zero & size));
    final random = math.Random(412);
    for (var i = 0; i < 150; i++) {
      final x = (random.nextDouble() * size.width + t * 12) % size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), .2 + random.nextDouble() * .45, Paint()..color = const Color(0x18FFFFFF));
    }
  }
  @override bool shouldRepaint(covariant _SpacePainter old) => old.t != t;
}

class _OrbitView extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase; final int? selected; final bool labels; final ValueChanged<int> onSelect;
  const _OrbitView({required this.worlds, required this.phase, required this.selected, required this.labels, required this.onSelect});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, box) {
    final r = math.min(box.maxWidth, box.maxHeight) * .29;
    return Stack(children: [
      Center(child: CustomPaint(size: Size(r * 3.2, r * 1.2), painter: _OrbitPainter(r))),
      for (var i = 0; i < worlds.length; i++) _Node(world: worlds[i], index: i, count: worlds.length, phase: phase, radius: r, selected: selected == i, labels: labels, onTap: () => onSelect(i)),
    ]);
  });
}

class _Node extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final double phase, radius; final bool selected, labels; final VoidCallback onTap;
  const _Node({required this.world, required this.index, required this.count, required this.phase, required this.radius, required this.selected, required this.labels, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = phase + index / math.max(1, count) * math.pi * 2;
    final x = .5 + math.cos(angle) * .28;
    final y = .5 + math.sin(angle) * .20;
    final depth = (.5 + math.sin(angle) * .5).clamp(.0, 1.0);
    final size = 38 + depth * 22 + (selected ? 18 : 0);
    return Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF77718D), Color(0xFF211D32), Color(0xFF05060C)]), border: Border.all(color: selected ? const Color(0xCCFFFFFF) : const Color(0x445F5870)), boxShadow: selected ? const [BoxShadow(color: Color(0x555D4F79), blurRadius: 24)] : const [])),
      if (labels) Padding(padding: const EdgeInsets.only(top: 5), child: Text(world.title, style: TextStyle(color: selected ? Colors.white : const Color(0x99FFFFFF), fontSize: selected ? 8 : 6, letterSpacing: 1.4))),
    ])));
  }
}

class _OrbitPainter extends CustomPainter {
  final double radius; const _OrbitPainter(this.radius);
  @override void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x223F4A65);
    for (var i = 1; i <= 4; i++) canvas.drawOval(Rect.fromCenter(center: c, width: radius * i * .75, height: radius * i * .24), p);
  }
  @override bool shouldRepaint(covariant _OrbitPainter old) => old.radius != radius;
}

class _MapView extends StatelessWidget {
  final List<GalaxyWorld> worlds; final int? selected; final ValueChanged<int> onSelect;
  const _MapView({required this.worlds, required this.selected, required this.onSelect});
  @override Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: GridView.builder(padding: const EdgeInsets.all(60), shrinkWrap: true, itemCount: worlds.length, gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300, mainAxisExtent: 120, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (_, i) {
    final active = selected == i;
    return InkWell(onTap: () => onSelect(i), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? const Color(0x221A1D2A) : const Color(0x0AFFFFFF), border: Border.all(color: active ? const Color(0x88FFFFFF) : const Color(0x1AFFFFFF))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 6)), const SizedBox(height: 7), Text(worlds[i].title, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10, letterSpacing: 1.4)), const SizedBox(height: 5), Text(worlds[i].description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 6))]));
  })));
}

class _Hud extends StatelessWidget {
  final int worlds; final int? selected; final double zoom; final bool map, orbit;
  const _Hud({required this.worlds, required this.selected, required this.zoom, required this.map, required this.orbit});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x1AFFFFFF))), child: Text('${map ? 'MAP' : 'GALAXY'}  •  $worlds WORLDS  •  ZOOM ${(zoom * 100).round()}%  •  ${selected == null ? 'SCANNING' : 'TARGET ${selected! + 1}'}  •  ${orbit ? 'AUTO ORBIT' : 'MANUAL'}', style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 6, letterSpacing: 1.1)));
}

class _Button extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _Button({required this.label, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x2EFFFFFF))), child: Text(label, style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 6, letterSpacing: 1))));
}
