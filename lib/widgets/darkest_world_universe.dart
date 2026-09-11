import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind {
  vegeta,
  game,
  music,
  identity,
  family,
  cinema,
  creation,
  archive,
  comingSoon,
}

class GalaxyWorld {
  final String title;
  final String description;
  final GalaxyWorldKind kind;

  const GalaxyWorld(this.title, this.description, this.kind);
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;

  const DarkestWorldUniverse({
    super.key,
    required this.worlds,
    this.onWorldTap,
  });

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 80),
  )..repeat();

  GalaxyWorldKind? hovered;
  GalaxyWorldKind? selected;

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 760;
        final wide = box.maxWidth >= 1200;
        final sceneW = box.maxWidth;
        final sceneH = box.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(painter: _UniversePainter(_motion)),
            ),
            _SceneGlow(width: sceneW, height: sceneH),
            Positioned.fill(
              child: _UniverseMap(
                worlds: widget.worlds,
                compact: compact,
                wide: wide,
                hovered: hovered,
                selected: selected,
                onHover: (kind) => setState(() => hovered = kind),
                onSelect: (world) => setState(() => selected = world.kind),
                onEnter: widget.onWorldTap,
              ),
            ),
            Positioned(
              left: compact ? 18 : 34,
              top: compact ? 18 : 28,
              child: const _UniverseTitle(),
            ),
            if (!compact)
              Positioned(
                right: 34,
                top: 28,
                child: _UniverseHint(active: hovered != null),
              ),
            if (selected != null)
              _SelectionLayer(
                world: _findWorld(selected!),
                compact: compact,
                onClose: () => setState(() => selected = null),
                onEnter: () {
                  final world = _findWorld(selected!);
                  if (world != null) widget.onWorldTap?.call(world);
                },
              ),
          ],
        );
      },
    );
  }

  GalaxyWorld? _findWorld(GalaxyWorldKind kind) {
    for (final world in widget.worlds) {
      if (world.kind == kind) return world;
    }
    return null;
  }
}

class _UniverseMap extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final bool compact;
  final bool wide;
  final GalaxyWorldKind? hovered;
  final GalaxyWorldKind? selected;
  final ValueChanged<GalaxyWorldKind?> onHover;
  final ValueChanged<GalaxyWorld> onSelect;
  final ValueChanged<GalaxyWorld>? onEnter;

  const _UniverseMap({
    required this.worlds,
    required this.compact,
    required this.wide,
    required this.hovered,
    required this.selected,
    required this.onHover,
    required this.onSelect,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = math.min(size.width, size.height);
    final planetScale = compact ? .82 : wide ? 1.0 : .92;

    final center = Offset(size.width * .51, size.height * .52);
    final placements = <GalaxyWorldKind, Offset>{
      GalaxyWorldKind.vegeta: center,
      GalaxyWorldKind.identity: Offset(size.width * .18, size.height * .33),
      GalaxyWorldKind.game: Offset(size.width * .78, size.height * .29),
      GalaxyWorldKind.cinema: Offset(size.width * .82, size.height * .69),
      GalaxyWorldKind.creation: Offset(size.width * .22, size.height * .72),
      GalaxyWorldKind.music: Offset(size.width * .52, size.height * .84),
      GalaxyWorldKind.family: Offset(size.width * .50, size.height * .17),
      GalaxyWorldKind.archive: Offset(size.width * .09, size.height * .53),
      GalaxyWorldKind.comingSoon: Offset(size.width * .91, size.height * .50),
    };

    final mainSizes = <GalaxyWorldKind, double>{
      GalaxyWorldKind.vegeta: base * (compact ? .28 : .34),
      GalaxyWorldKind.identity: base * (compact ? .115 : .14),
      GalaxyWorldKind.game: base * (compact ? .125 : .15),
      GalaxyWorldKind.cinema: base * (compact ? .105 : .13),
      GalaxyWorldKind.creation: base * (compact ? .105 : .13),
      GalaxyWorldKind.music: base * (compact ? .09 : .115),
      GalaxyWorldKind.family: base * (compact ? .085 : .10),
      GalaxyWorldKind.archive: base * (compact ? .06 : .07),
      GalaxyWorldKind.comingSoon: base * (compact ? .055 : .065),
    };

    final visible = worlds
        .where((w) => placements.containsKey(w.kind))
        .toList(growable: false);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _OrbitPainter(center: center, compact: compact),
            ),
          ),
        ),
        for (final world in visible)
          Positioned(
            left: placements[world.kind]!.dx - mainSizes[world.kind]! / 2,
            top: placements[world.kind]!.dy - mainSizes[world.kind]! / 2,
            child: _PlanetInteraction(
              world: world,
              size: mainSizes[world.kind]! * planetScale,
              central: world.kind == GalaxyWorldKind.vegeta,
              active: hovered == world.kind || selected == world.kind,
              onHover: (inside) => onHover(inside ? world.kind : null),
              onTap: () => onSelect(world),
              onEnter: () => onEnter?.call(world),
            ),
          ),
      ],
    );
  }
}

class _PlanetInteraction extends StatefulWidget {
  final GalaxyWorld world;
  final double size;
  final bool central;
  final bool active;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final VoidCallback onEnter;

  const _PlanetInteraction({
    required this.world,
    required this.size,
    required this.central,
    required this.active,
    required this.onHover,
    required this.onTap,
    required this.onEnter,
  });

  @override
  State<_PlanetInteraction> createState() => _PlanetInteractionState();
}

class _PlanetInteractionState extends State<_PlanetInteraction> {
  @override
  Widget build(BuildContext context) {
    final grow = widget.active ? 1.075 : 1.0;
    final menu = widget.active ? _menuFor(widget.world.kind) : const <String>[];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: SizedBox(
        width: widget.size + 170,
        height: widget.size + 150,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            AnimatedScale(
              scale: grow,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: GestureDetector(
                onTap: widget.onTap,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _PlanetPainter(
                      kind: widget.world.kind,
                      seed: widget.world.kind.index * 73 + 19,
                      central: widget.central,
                      active: widget.active,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.active)
              Positioned(
                top: -8,
                left: 0,
                right: 0,
                child: _PlanetLabel(
                  title: widget.world.title,
                  central: widget.central,
                ),
              ),
            if (widget.active)
              Positioned.fill(
                child: IgnorePointer(
                  child: _FloatingMoons(
                    labels: menu,
                    compact: widget.size < 95,
                  ),
                ),
              ),
            if (widget.active)
              Positioned(
                top: widget.size + 12,
                left: 0,
                right: 0,
                child: _EnterHint(onTap: widget.onEnter),
              ),
          ],
        ),
      ),
    );
  }
}

List<String> _menuFor(GalaxyWorldKind kind) {
  switch (kind) {
    case GalaxyWorldKind.game:
      return ['Collection', 'Played Games', 'Marathons', 'Challenges', 'Statistics'];
    case GalaxyWorldKind.cinema:
      return ['Movies', 'Series', 'Favorites', 'Watchlist'];
    case GalaxyWorldKind.identity:
      return ['Identity', 'Personas', 'History', 'Favorites', 'Milestones'];
    case GalaxyWorldKind.creation:
      return ['Artwork', 'Wallpapers', 'Posters', 'Projects'];
    case GalaxyWorldKind.music:
      return ['Albums', 'Soundtracks', 'Playlists'];
    case GalaxyWorldKind.family:
      return ['Personas', 'Stories', 'Archive'];
    case GalaxyWorldKind.vegeta:
      return ['Overview', 'World', 'Archive'];
    case GalaxyWorldKind.archive:
      return ['Archive', 'Saved'];
    case GalaxyWorldKind.comingSoon:
      return ['Coming Soon'];
  }
}

class _FloatingMoons extends StatelessWidget {
  final List<String> labels;
  final bool compact;

  const _FloatingMoons({required this.labels, required this.compact});

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 72.0 : 102.0;
    final moon = compact ? 22.0 : 27.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < labels.length; i++)
          Transform.translate(
            offset: _moonOffset(i, labels.length, radius),
            child: Container(
              width: moon,
              height: moon,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0C0A15),
                border: Border.all(color: const Color(0xFFBBA9E6).withValues(alpha: .30)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8062B7).withValues(alpha: .16),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Tooltip(
                message: labels[i],
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: compact ? 7 : 8,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: .65),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Offset _moonOffset(int index, int count, double radius) {
    final angle = -math.pi / 2 + (math.pi * 2 / count) * index;
    return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }
}

class _PlanetLabel extends StatelessWidget {
  final String title;
  final bool central;

  const _PlanetLabel({required this.title, required this.central});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: central ? 12 : 9,
              letterSpacing: central ? 3.4 : 2.4,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: .92),
              shadows: const [Shadow(color: Colors.black, blurRadius: 18)],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: central ? 32 : 20,
            height: 1,
            color: const Color(0xFFBBA9E6).withValues(alpha: .42),
          ),
        ],
      ),
    );
  }
}

class _EnterHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EnterHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          'ENTER WORLD',
          style: TextStyle(
            fontSize: 7,
            letterSpacing: 2.7,
            color: Colors.white.withValues(alpha: .38),
          ),
        ),
      ),
    );
  }
}

class _SelectionLayer extends StatelessWidget {
  final GalaxyWorld? world;
  final bool compact;
  final VoidCallback onClose;
  final VoidCallback onEnter;

  const _SelectionLayer({
    required this.world,
    required this.compact,
    required this.onClose,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    if (world == null) return const SizedBox.shrink();
    return Positioned(
      left: compact ? 16 : 34,
      right: compact ? 16 : 34,
      bottom: compact ? 16 : 28,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: EdgeInsets.fromLTRB(compact ? 18 : 24, 16, 12, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF080710).withValues(alpha: .94),
            border: Border.all(color: const Color(0xFFBBA9E6).withValues(alpha: .18)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .55),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      world!.title,
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      world!.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: .46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onEnter,
                child: const Text('ENTER'),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close,
                  size: 17,
                  color: Colors.white.withValues(alpha: .46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UniverseTitle extends StatelessWidget {
  const _UniverseTitle();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DARKEST-WORLD',
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 5.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'EXPLORE YOUR UNIVERSE',
            style: TextStyle(
              fontSize: 7,
              letterSpacing: 3.4,
              color: Colors.white.withValues(alpha: .30),
            ),
          ),
        ],
      ),
    );
  }
}

class _UniverseHint extends StatelessWidget {
  final bool active;
  const _UniverseHint({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 0 : 1,
      duration: const Duration(milliseconds: 180),
      child: Text(
        'MOVE THROUGH THE WORLDS',
        style: TextStyle(
          fontSize: 7,
          letterSpacing: 2.8,
          color: Colors.white.withValues(alpha: .24),
        ),
      ),
    );
  }
}

class _SceneGlow extends StatelessWidget {
  final double width;
  final double height;
  const _SceneGlow({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: math.min(width * .72, 980),
          height: math.min(height * .62, 700),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF614B8C).withValues(alpha: .065),
                const Color(0xFF1D355D).withValues(alpha: .028),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UniversePainter extends CustomPainter {
  final Animation<double> animation;
  _UniversePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.10),
          radius: 1.15,
          colors: [Color(0xFF120D20), Color(0xFF05040A), Color(0xFF010105)],
          stops: [0, .55, 1],
        ).createShader(rect),
    );

    final random = math.Random(9021);
    final stars = Paint();
    for (var i = 0; i < 430; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final pulse = .55 + .45 * math.sin(animation.value * math.pi * 2 + i * .91);
      stars.color = Colors.white.withValues(
        alpha: (.015 + random.nextDouble() * .16) * pulse,
      );
      canvas.drawCircle(
        Offset(x, y),
        .25 + random.nextDouble() * .75,
        stars,
      );
    }

    final nebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5B3C83).withValues(alpha: .055),
          const Color(0xFF294D7B).withValues(alpha: .018),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(size.width * .52, size.height * .52),
          width: size.width * .82,
          height: size.height * .62,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .52, size.height * .52),
        width: size.width * .82,
        height: size.height * .62,
      ),
      nebula,
    );
  }

  @override
  bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  final Offset center;
  final bool compact;

  const _OrbitPainter({required this.center, required this.compact});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFF9273C3).withValues(alpha: .055);

    for (final factor in compact ? [.50, .72, .92] : [.38, .56, .74, .92]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * factor,
          height: size.height * factor * .42,
        ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final GalaxyWorldKind kind;
  final int seed;
  final bool central;
  final bool active;

  const _PlanetPainter({
    required this.kind,
    required this.seed,
    required this.central,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final rect = Offset.zero & size;
    final palette = _palette(kind);

    if (active) {
      canvas.drawCircle(
        c,
        r * 1.08,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
          ..color = palette.$3.withValues(alpha: central ? .26 : .18),
      );
    }

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.38, -.44),
          radius: 1.02,
          colors: [palette.$1, palette.$2, const Color(0xFF020207)],
          stops: const [0, .57, 1],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .985)));

    final random = math.Random(seed);
    final land = Paint();
    final landColor = palette.$3;
    final masses = central ? 10 : 6;

    for (var i = 0; i < masses; i++) {
      final cx = c.dx + (random.nextDouble() * 2 - 1) * r * .62;
      final cy = c.dy + (random.nextDouble() * 2 - 1) * r * .55;
      final rw = r * (.16 + random.nextDouble() * .24);
      final rh = r * (.10 + random.nextDouble() * .18);
      final path = Path();
      for (var n = 0; n < 12; n++) {
        final a = n / 12 * math.pi * 2;
        final wobble = .72 + random.nextDouble() * .45;
        final x = cx + math.cos(a) * rw * wobble;
        final y = cy + math.sin(a) * rh * wobble;
        if (n == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      land.color = landColor.withValues(alpha: .28 + random.nextDouble() * .22);
      canvas.drawPath(path, land);
    }

    final detail = Paint();
    for (var i = 0; i < (central ? 130 : 48); i++) {
      final x = c.dx + (random.nextDouble() * 2 - 1) * r * .82;
      final y = c.dy + (random.nextDouble() * 2 - 1) * r * .82;
      if ((Offset(x, y) - c).distance < r * .91) {
        detail.color = Colors.white.withValues(alpha: .012 + random.nextDouble() * .045);
        canvas.drawCircle(Offset(x, y), .4 + random.nextDouble() * 1.4, detail);
      }
    }

    if (kind == GalaxyWorldKind.music || kind == GalaxyWorldKind.creation) {
      final rings = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .018
        ..color = Colors.white.withValues(alpha: .055);
      for (var i = 0; i < 3; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + r * (.18 - i * .14)),
            width: r * (1.15 - i * .18),
            height: r * .26,
          ),
          rings,
        );
      }
    }

    canvas.restore();

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = central ? 1.5 : 1
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: .22),
          palette.$3.withValues(alpha: .55),
          Colors.transparent,
          Colors.white.withValues(alpha: .08),
        ],
      ).createShader(rect);
    canvas.drawCircle(c, r * .988, rim);

    final light = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.46, -.54),
        radius: .78,
        colors: [
          Colors.white.withValues(alpha: central ? .12 : .09),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(c, r * .96, light);
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.active != active;
}

(Color, Color, Color) _palette(GalaxyWorldKind kind) {
  switch (kind) {
    case GalaxyWorldKind.game:
      return (const Color(0xFF21406B), const Color(0xFF071323), const Color(0xFF6C83A9));
    case GalaxyWorldKind.cinema:
      return (const Color(0xFF5A294E), const Color(0xFF190A1B), const Color(0xFFB66B9A));
    case GalaxyWorldKind.creation:
      return (const Color(0xFF51336C), const Color(0xFF140D20), const Color(0xFF9E79C2));
    case GalaxyWorldKind.music:
      return (const Color(0xFF193E4B), const Color(0xFF07151B), const Color(0xFF6B9AA8));
    case GalaxyWorldKind.identity:
      return (const Color(0xFF4C3A68), const Color(0xFF110C19), const Color(0xFF927CB7));
    case GalaxyWorldKind.family:
      return (const Color(0xFF4D4933), const Color(0xFF131207), const Color(0xFF9A9367));
    case GalaxyWorldKind.vegeta:
      return (const Color(0xFF43306B), const Color(0xFF0B0814), const Color(0xFF9C79D0));
    case GalaxyWorldKind.archive:
      return (const Color(0xFF30323E), const Color(0xFF090A0F), const Color(0xFF727A91));
    case GalaxyWorldKind.comingSoon:
      return (const Color(0xFF242A3A), const Color(0xFF070A10), const Color(0xFF5E6B85));
  }
}
