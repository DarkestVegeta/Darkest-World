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

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? selected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final current = selected == null ? null : widget.worlds.where((w) => w.kind == selected).firstOrNull;
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GalaxyBackground(),
          _GalaxyPlanets(
            worlds: widget.worlds,
            compact: compact,
            selected: selected,
            onSelect: (world) => setState(() => selected = selected == world.kind ? null : world.kind),
          ),
          Positioned(
            left: compact ? 18 : 34,
            top: compact ? 18 : 28,
            child: const Text(
              'DARKESTWORLD',
              style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300),
            ),
          ),
          if (current != null)
            Positioned(
              right: compact ? 14 : 34,
              bottom: compact ? 14 : 34,
              width: compact ? 260 : 340,
              child: _SelectionPanel(
                world: current,
                onClose: () => setState(() => selected = null),
                onEnter: () => widget.onWorldTap?.call(current),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalaxyBackground extends StatelessWidget {
  const _GalaxyBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GalaxyBackgroundPainter());
}

class _GalaxyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010106));
    final random = math.Random(17);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: .32);
    for (var i = 0; i < 150; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final r = .35 + random.nextDouble() * 1.1;
      canvas.drawCircle(p, r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyBackgroundPainter oldDelegate) => false;
}

class _GalaxyPlanets extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final bool compact;
  final GalaxyWorldKind? selected;
  final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyPlanets({required this.worlds, required this.compact, required this.selected, required this.onSelect});

  static const positions = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .53),
    GalaxyWorldKind.game: Offset(.77, .25),
    GalaxyWorldKind.identity: Offset(.20, .34),
    GalaxyWorldKind.cinema: Offset(.84, .59),
    GalaxyWorldKind.creation: Offset(.22, .73),
    GalaxyWorldKind.music: Offset(.61, .81),
    GalaxyWorldKind.family: Offset(.39, .17),
    GalaxyWorldKind.archive: Offset(.09, .56),
    GalaxyWorldKind.comingSoon: Offset(.91, .80),
  };

  static const factors = <GalaxyWorldKind, double>{
    GalaxyWorldKind.vegeta: .30,
    GalaxyWorldKind.game: .16,
    GalaxyWorldKind.identity: .145,
    GalaxyWorldKind.cinema: .135,
    GalaxyWorldKind.creation: .13,
    GalaxyWorldKind.music: .115,
    GalaxyWorldKind.family: .105,
    GalaxyWorldKind.archive: .075,
    GalaxyWorldKind.comingSoon: .065,
  };

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final base = math.min(screen.width, screen.height);
    final visible = worlds.where((w) => positions.containsKey(w.kind)).toList();
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        for (final world in visible)
          Positioned(
            left: screen.width * positions[world.kind]!.dx,
            top: screen.height * positions[world.kind]!.dy,
            child: Transform.translate(
              offset: Offset(-_size(base, world.kind, compact) / 2, -_size(base, world.kind, compact) / 2),
              child: _Planet(
                world: world,
                size: _size(base, world.kind, compact),
                muted: selected != null && selected != world.kind,
                onTap: () => onSelect(world),
              ),
            ),
          ),
      ],
    );
  }

  double _size(double base, GalaxyWorldKind kind, bool compact) {
    final factor = factors[kind] ?? .1;
    return math.max(58, base * factor * (compact && kind != GalaxyWorldKind.vegeta ? .88 : 1));
  }
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;
  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final main = world.kind == GalaxyWorldKind.vegeta ? const Color(0xFF75628F) : const Color(0xFF52618A);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: muted ? .32 : 1,
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: main,
                  gradient: RadialGradient(
                    center: const Alignment(-.34, -.38),
                    radius: .9,
                    colors: [Colors.white.withValues(alpha: .7), main, const Color(0xFF090A16)],
                    stops: const [0, .32, 1],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: .28), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: main.withValues(alpha: .75), blurRadius: size * .18, spreadRadius: size * .025),
                    BoxShadow(color: Colors.black.withValues(alpha: .95), blurRadius: size * .1, offset: Offset(size * .06, size * .08)),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                world.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8, letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3 : 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _SelectionPanel({required this.world, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF090914).withValues(alpha: .94),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(world.description, style: TextStyle(color: Colors.white.withValues(alpha: .68))),
          const SizedBox(height: 14),
          Row(children: [
            TextButton(onPressed: onClose, child: const Text('Sluiten')),
            const Spacer(),
            ElevatedButton(onPressed: onEnter, child: const Text('Openen')),
          ]),
        ],
      ),
    ),
  );
}
