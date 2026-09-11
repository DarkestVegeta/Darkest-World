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
        Positioned.fill(child: _PlanetField(worlds: widget.worlds, selected: selected, compact: compact, onSelect: (world) => setState(() => selected = selected == world.kind ? null : world.kind))),
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

  static const positions = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .52), GalaxyWorldKind.game: Offset(.78, .25),
    GalaxyWorldKind.identity: Offset(.18, .34), GalaxyWorldKind.cinema: Offset(.87, .59),
    GalaxyWorldKind.creation: Offset(.20, .72), GalaxyWorldKind.music: Offset(.61, .82),
    GalaxyWorldKind.family: Offset(.39, .15), GalaxyWorldKind.archive: Offset(.065, .56),
    GalaxyWorldKind.comingSoon: Offset(.965, .79),
  };

  static const factors = <GalaxyWorldKind, double>{
    GalaxyWorldKind.vegeta: .30, GalaxyWorldKind.game: .155, GalaxyWorldKind.identity: .145,
    GalaxyWorldKind.cinema: .13, GalaxyWorldKind.creation: .13, GalaxyWorldKind.music: .11,
    GalaxyWorldKind.family: .10, GalaxyWorldKind.archive: .07, GalaxyWorldKind.comingSoon: .065,
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = math.min(size.width, size.height);
    return Stack(clipBehavior: Clip.none, children: [
      for (final world in worlds.where((w) => positions.containsKey(w.kind)))
        Positioned(
          left: size.width * positions[world.kind]!.dx - _planetSize(base, world.kind) / 2,
          top: size.height * positions[world.kind]!.dy - _planetSize(base, world.kind) / 2,
          child: _Planet(world: world, size: _planetSize(base, world.kind), muted: selected != null && selected != world.kind, onTap: () => onSelect(world)),
        ),
    ]);
  }

  double _planetSize(double base, GalaxyWorldKind kind) => base * (factors[kind] ?? .1) * (kind == GalaxyWorldKind.vegeta ? 1 : compact ? .92 : 1);
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;
  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = world.kind == GalaxyWorldKind.vegeta;
    final baseColor = dark ? const Color(0xFF76688F) : const Color(0xFF626B8C);
    return Opacity(
      opacity: muted ? .35 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(width: size, height: size + 34, child: Column(children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              gradient: RadialGradient(center: const Alignment(-.35, -.38), radius: .92, colors: [Colors.white.withValues(alpha: .58), baseColor, const Color(0xFF171625)], stops: const [0, .38, 1]),
              border: Border.all(color: Colors.white.withValues(alpha: .14), width: 1),
              boxShadow: [BoxShadow(color: baseColor.withValues(alpha: .65), blurRadius: size * .16, spreadRadius: size * .025), BoxShadow(color: Colors.black.withValues(alpha: .9), blurRadius: size * .08, offset: Offset(size * .055, size * .07))],
            ),
          ),
          const SizedBox(height: 5),
          Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: dark ? 11 : 8, letterSpacing: dark ? 3.2 : 2.1, color: Colors.white.withValues(alpha: .78))),
        ])),
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final VoidCallback onClose; final VoidCallback onEnter;
  const _SelectionPanel({required this.world, required this.compact, required this.onClose, required this.onEnter});
  @override
  Widget build(BuildContext context) => Positioned(left: compact ? 14 : 30, right: compact ? 14 : 30, bottom: compact ? 16 : 26, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xE6090913), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title, style: const TextStyle(fontSize: 13, letterSpacing: 3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .40)))])), TextButton(onPressed: onEnter, child: const Text('ENTER')), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 16))])))));
}

class _UniverseTitle extends StatelessWidget {
  const _UniverseTitle();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKESTWORLD', style: TextStyle(fontSize: 14, letterSpacing: 5.5, color: Colors.white.withValues(alpha: .78))), const SizedBox(height: 5), Text('THE WORLDS BEYOND', style: TextStyle(fontSize: 7, letterSpacing: 3.2, color: Colors.white.withValues(alpha: .25)))]));
}

class _UniversePainter extends CustomPainter {
  const _UniversePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.15, colors: [Color(0xFF171426), Color(0xFF070710), Color(0xFF010105)]).createShader(rect));
    final random = math.Random(4817);
    final star = Paint();
    for (var i = 0; i < 380; i++) { star.color = Colors.white.withValues(alpha: .012 + random.nextDouble() * .065); canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .12 + random.nextDouble() * .5, star); }
  }
  @override bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
}
