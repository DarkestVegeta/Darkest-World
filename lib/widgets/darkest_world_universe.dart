import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind { vegeta, game, music, identity, family, cinema, creation, archive, comingSoon }

class GalaxyWorld {
  final String title;
  final String description;
  final GalaxyWorldKind kind;
  const GalaxyWorld(this.title, this.description, this.kind);
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? selected;
  GalaxyWorld? find(GalaxyWorldKind kind) {
    for (final world in widget.worlds) { if (world.kind == kind) return world; }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 760;
      final current = selected == null ? null : find(selected!);
      return Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: CustomPaint(painter: _UniversePainter())),
        _PlanetField(worlds: widget.worlds, selected: selected, compact: compact, onSelect: (world) => setState(() => selected = selected == world.kind ? null : world.kind)),
        Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const _UniverseTitle()),
        if (current != null) _SelectionPanel(world: current, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current)),
      ]);
    });
  }
}

class _PlanetField extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind? selected;
  final bool compact;
  final ValueChanged<GalaxyWorld> onSelect;
  const _PlanetField({required this.worlds, required this.selected, required this.compact, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = math.min(size.width, size.height);
    const positions = <GalaxyWorldKind, Offset>{
      GalaxyWorldKind.vegeta: Offset(.50, .52), GalaxyWorldKind.game: Offset(.78, .25),
      GalaxyWorldKind.identity: Offset(.18, .34), GalaxyWorldKind.cinema: Offset(.87, .59),
      GalaxyWorldKind.creation: Offset(.20, .72), GalaxyWorldKind.music: Offset(.61, .82),
      GalaxyWorldKind.family: Offset(.39, .15), GalaxyWorldKind.archive: Offset(.065, .56),
      GalaxyWorldKind.comingSoon: Offset(.965, .79),
    };
    const scales = <GalaxyWorldKind, double>{
      GalaxyWorldKind.vegeta: 1.0, GalaxyWorldKind.game: .96, GalaxyWorldKind.identity: .88,
      GalaxyWorldKind.cinema: .79, GalaxyWorldKind.creation: .82, GalaxyWorldKind.music: .68,
      GalaxyWorldKind.family: .64, GalaxyWorldKind.archive: .53, GalaxyWorldKind.comingSoon: .48,
    };
    final sorted = worlds.where((w) => positions.containsKey(w.kind)).toList()
      ..sort((a, b) => scales[a.kind]!.compareTo(scales[b.kind]!));
    return Stack(clipBehavior: Clip.none, children: [
      for (final world in sorted)
        Positioned(
          left: size.width * positions[world.kind]!.dx - _planetSize(base, world.kind, compact) / 2,
          top: size.height * positions[world.kind]!.dy - _planetSize(base, world.kind, compact) / 2,
          child: _Planet(world: world, size: _planetSize(base, world.kind, compact), muted: selected != null && selected != world.kind, onTap: () => onSelect(world)),
        ),
    ]);
  }

  double _planetSize(double base, GalaxyWorldKind kind, bool compact) {
    final factors = <GalaxyWorldKind, double>{GalaxyWorldKind.vegeta: .30, GalaxyWorldKind.game: .155, GalaxyWorldKind.identity: .145, GalaxyWorldKind.cinema: .13, GalaxyWorldKind.creation: .13, GalaxyWorldKind.music: .11, GalaxyWorldKind.family: .10, GalaxyWorldKind.archive: .07, GalaxyWorldKind.comingSoon: .065};
    final factor = factors[kind] ?? .1;
    return base * factor * (kind == GalaxyWorldKind.vegeta ? 1 : compact ? .92 : 1);
  }
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;
  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});
  @override
  Widget build(BuildContext context) => Opacity(opacity: muted ? .35 : 1, child: GestureDetector(onTap: onTap, child: SizedBox(width: size, height: size + 36, child: Column(children: [Expanded(child: CustomPaint(painter: _PlanetPainter(seed: world.kind.index * 977 + 7))), const SizedBox(height: 6), Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8, letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3.2 : 2.1, color: Colors.white.withValues(alpha: .72))) ]))));
}

class _SelectionPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final VoidCallback onClose; final VoidCallback onEnter;
  const _SelectionPanel({required this.world, required this.compact, required this.onClose, required this.onEnter});
  @override
  Widget build(BuildContext context) => Positioned(left: compact ? 14 : 30, right: compact ? 14 : 30, bottom: compact ? 16 : 26, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xE6090913), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title, style: const TextStyle(fontSize: 13, letterSpacing: 3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .40)))])), TextButton(onPressed: onEnter, child: const Text('ENTER')), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 16))])))));
}

class _UniverseTitle extends StatelessWidget { const _UniverseTitle(); @override Widget build(BuildContext context) => IgnorePointer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKESTWORLD', style: TextStyle(fontSize: 14, letterSpacing: 5.5, color: Colors.white.withValues(alpha: .78))), const SizedBox(height: 5), Text('THE WORLDS BEYOND', style: TextStyle(fontSize: 7, letterSpacing: 3.2, color: Colors.white.withValues(alpha: .25)))])); }

class _UniversePainter extends CustomPainter {
  const _UniversePainter();
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.15, colors: [Color(0xFF171426), Color(0xFF070710), Color(0xFF010105)]).createShader(rect));
    final random = math.Random(4817);
    final star = Paint();
    for (var i = 0; i < 380; i++) { star.color = Colors.white.withValues(alpha: .012 + random.nextDouble() * .065); canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .12 + random.nextDouble() * .5, star); }
  }
  @override bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final int seed;
  const _PlanetPainter({required this.seed});
  @override void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .47;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius * 1.06, Paint()..shader = const RadialGradient(colors: [Color(0x306C5A92), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.08)));
    canvas.drawCircle(center, radius, Paint()..shader = const RadialGradient(center: Alignment(-.38, -.40), radius: 1.02, colors: [Color(0xFF59627C), Color(0xFF272A43), Color(0xFF070812)]).createShader(rect));
    canvas.save(); canvas.clipPath(Path()..addOval(rect));
    final random = math.Random(seed);
    for (var i = 0; i < 18; i++) { final a = random.nextDouble() * math.pi * 2; final d = math.sqrt(random.nextDouble()) * radius * .72; final p = center + Offset(math.cos(a) * d, math.sin(a) * d); final w = radius * (.05 + random.nextDouble() * .16); canvas.drawOval(Rect.fromCenter(center: p, width: w, height: w * (.45 + random.nextDouble())), Paint()..color = const Color(0xFFB2A6AE).withValues(alpha: .04 + random.nextDouble() * .07)); }
    canvas.drawCircle(center + Offset(radius * .38, radius * .08), radius * .80, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .36)]).createShader(Rect.fromCircle(center: center + Offset(radius * .38, radius * .08), radius: radius * .80)));
    canvas.restore();
    canvas.drawArc(rect, math.pi * 1.05, math.pi * .82, false, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1, radius * .008)..color = Colors.white.withValues(alpha: .08));
  }
  @override bool shouldRepaint(covariant _PlanetPainter oldDelegate) => false;
}
