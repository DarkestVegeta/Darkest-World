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
  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? hovered;
  GalaxyWorldKind? selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 760;
      final size = Size(box.maxWidth, box.maxHeight);
      return Stack(fit: StackFit.expand, children: [
        const RepaintBoundary(child: CustomPaint(painter: _UniversePainter())),
        Positioned.fill(child: _PlanetField(
          worlds: widget.worlds,
          size: size,
          compact: compact,
          hovered: hovered,
          selected: selected,
          onHover: (k) => setState(() => hovered = k),
          onSelect: (w) => setState(() => selected = w.kind),
        )),
        Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const _UniverseTitle()),
        if (!compact) Positioned(right: 34, top: 30, child: Text(
          'DARKest WORLD / UNIVERSE',
          style: TextStyle(fontSize: 7, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .20)),
        )),
        if (selected != null) _SelectionLayer(
          world: _findWorld(selected!),
          compact: compact,
          onClose: () => setState(() => selected = null),
          onEnter: () {
            final world = _findWorld(selected!);
            if (world != null) widget.onWorldTap?.call(world);
          },
        ),
      ]);
    });
  }

  GalaxyWorld? _findWorld(GalaxyWorldKind kind) {
    for (final world in widget.worlds) {
      if (world.kind == kind) return world;
    }
    return null;
  }
}

class _PlanetField extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final Size size;
  final bool compact;
  final GalaxyWorldKind? hovered;
  final GalaxyWorldKind? selected;
  final ValueChanged<GalaxyWorldKind?> onHover;
  final ValueChanged<GalaxyWorld> onSelect;

  const _PlanetField({required this.worlds, required this.size, required this.compact, required this.hovered, required this.selected, required this.onHover, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final base = math.min(size.width, size.height);
    final positions = <GalaxyWorldKind, Offset>{
      GalaxyWorldKind.vegeta: Offset(size.width * .50, size.height * .51),
      GalaxyWorldKind.identity: Offset(size.width * .17, size.height * .30),
      GalaxyWorldKind.game: Offset(size.width * .79, size.height * .29),
      GalaxyWorldKind.cinema: Offset(size.width * .82, size.height * .71),
      GalaxyWorldKind.creation: Offset(size.width * .20, size.height * .73),
      GalaxyWorldKind.music: Offset(size.width * .53, size.height * .85),
      GalaxyWorldKind.family: Offset(size.width * .50, size.height * .15),
      GalaxyWorldKind.archive: Offset(size.width * .075, size.height * .53),
      GalaxyWorldKind.comingSoon: Offset(size.width * .925, size.height * .53),
    };
    final sizes = <GalaxyWorldKind, double>{
      GalaxyWorldKind.vegeta: base * (compact ? .29 : .33),
      GalaxyWorldKind.identity: base * (compact ? .125 : .145),
      GalaxyWorldKind.game: base * (compact ? .135 : .155),
      GalaxyWorldKind.cinema: base * (compact ? .115 : .13),
      GalaxyWorldKind.creation: base * (compact ? .115 : .13),
      GalaxyWorldKind.music: base * (compact ? .095 : .11),
      GalaxyWorldKind.family: base * (compact ? .085 : .10),
      GalaxyWorldKind.archive: base * (compact ? .06 : .07),
      GalaxyWorldKind.comingSoon: base * (compact ? .055 : .065),
    };

    return Stack(clipBehavior: Clip.none, children: [
      for (final world in worlds)
        if (positions.containsKey(world.kind)) Positioned(
          left: positions[world.kind]!.dx - sizes[world.kind]! / 2,
          top: positions[world.kind]!.dy - sizes[world.kind]! / 2,
          child: _PlanetInteraction(
            world: world,
            size: sizes[world.kind]!,
            central: world.kind == GalaxyWorldKind.vegeta,
            active: hovered == world.kind || selected == world.kind,
            onHover: (inside) => onHover(inside ? world.kind : null),
            onTap: () => onSelect(world),
          ),
        ),
    ]);
  }
}

class _PlanetInteraction extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool central;
  final bool active;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _PlanetInteraction({required this.world, required this.size, required this.central, required this.active, required this.onHover, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(width: size + 112, height: size + 78, child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _PlanetPainter(
                kind: world.kind,
                seed: world.kind.index * 1783 + 91,
                active: active,
                central: central,
              ),
            ),
            Positioned(
              top: size + 9,
              left: -28,
              right: -28,
              child: Text(
                world.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: central ? 11 : 8,
                  letterSpacing: central ? 3.6 : 2.3,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: active || central ? .82 : .48),
                  shadows: const [Shadow(color: Colors.black, blurRadius: 14)],
                ),
              ),
            ),
            if (active) Positioned(
              top: size + 25,
              left: -28,
              right: -28,
              child: Text(
                'OPEN',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 6, letterSpacing: 2.5, color: Colors.white.withValues(alpha: .30)),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class _UniverseTitle extends StatelessWidget {
  const _UniverseTitle();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('DARKESTWORLD', style: TextStyle(fontSize: 14, letterSpacing: 5.5, color: Colors.white.withValues(alpha: .78))),
      const SizedBox(height: 5),
      Text('THE WORLDS BEYOND', style: TextStyle(fontSize: 7, letterSpacing: 3.2, color: Colors.white.withValues(alpha: .25))),
    ],
  ));
}

class _UniversePainter extends CustomPainter {
  const _UniversePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.08),
      radius: 1.18,
      colors: [Color(0xFF17142A), Color(0xFF080812), Color(0xFF010106)],
    ).createShader(rect));

    final random = math.Random(4817);
    final stars = Paint();
    for (var i = 0; i < 360; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      stars.color = Colors.white.withValues(alpha: .018 + random.nextDouble() * .085);
      canvas.drawCircle(p, .20 + random.nextDouble() * .58, stars);
    }

    final haze = Rect.fromCenter(
      center: Offset(size.width * .50, size.height * .50),
      width: size.width * .90,
      height: size.height * .76,
    );
    canvas.drawOval(haze, Paint()..shader = RadialGradient(
      colors: [
        const Color(0xFF6C5798).withValues(alpha: .075),
        const Color(0xFF405D83).withValues(alpha: .028),
        Colors.transparent,
      ],
    ).createShader(haze));
  }

  @override
  bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final GalaxyWorldKind kind;
  final int seed;
  final bool active;
  final bool central;

  const _PlanetPainter({required this.kind, required this.seed, required this.active, required this.central});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = size.center(Offset.zero);
    final palette = _palette(kind);
    final planetRect = Rect.fromCircle(center: center, radius: r * .965);

    // Very restrained atmosphere: this is a planet in space, not a glowing icon.
    canvas.drawCircle(
      center,
      r * (active ? 1.055 : 1.025),
      Paint()..shader = RadialGradient(
        colors: [
          palette.glow.withValues(alpha: active ? .15 : .055),
          palette.glow.withValues(alpha: .018),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * (active ? 1.055 : 1.025))),
    );

    // Base sphere and broad natural lighting.
    canvas.drawCircle(
      center,
      r * .965,
      Paint()..shader = RadialGradient(
        center: const Alignment(-.34, -.38),
        radius: 1.03,
        colors: [palette.light, palette.base, palette.shadow],
        stops: const [0, .54, 1],
      ).createShader(planetRect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(planetRect));
    final random = math.Random(seed);

    _landMasses(canvas, center, r, random, palette);
    _terrain(canvas, center, r, random, palette);
    _craters(canvas, center, r, random, palette);
    _cloudBelts(canvas, center, r, random, palette);
    _terminatorDetail(canvas, center, r, palette);
    _specularLight(canvas, center, r, palette);
    canvas.restore();

    // Thin atmospheric rim catches the light around the sphere.
    canvas.drawArc(
      planetRect.deflate(r * .006),
      math.pi * .67,
      math.pi * 1.13,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, r * .014)
        ..color = palette.glow.withValues(alpha: active ? .28 : .13),
    );
    canvas.drawArc(
      planetRect.deflate(r * .012),
      -math.pi * .95,
      math.pi * .52,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(.7, r * .008)
        ..color = Colors.white.withValues(alpha: .075),
    );
  }

  void _landMasses(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final count = switch (kind) {
      GalaxyWorldKind.game => 8,
      GalaxyWorldKind.identity => 7,
      GalaxyWorldKind.cinema => 5,
      GalaxyWorldKind.creation => 9,
      GalaxyWorldKind.music => 4,
      GalaxyWorldKind.family => 6,
      GalaxyWorldKind.archive => 10,
      GalaxyWorldKind.comingSoon => 4,
      GalaxyWorldKind.vegeta => 7,
    };

    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = r * (.12 + random.nextDouble() * .58);
      final point = center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      final rx = r * (.075 + random.nextDouble() * .17);
      final ry = r * (.045 + random.nextDouble() * .12);
      final rotation = random.nextDouble() * math.pi;
      final path = _organicIsland(point, rx, ry, rotation, random);
      paint.color = p.land.withValues(alpha: .10 + random.nextDouble() * .12);
      canvas.drawPath(path, paint);

      // A very soft shoreline, enough to give depth without becoming a map.
      final inner = _organicIsland(point, rx * .78, ry * .72, rotation, random);
      paint.color = p.coast.withValues(alpha: .025 + random.nextDouble() * .035);
      canvas.drawPath(inner, paint);
    }
  }

  Path _organicIsland(Offset center, double rx, double ry, double rotation, math.Random random) {
    final path = Path();
    const points = 13;
    for (var i = 0; i <= points; i++) {
      final a = math.pi * 2 * i / points;
      final wobble = .72 + random.nextDouble() * .48;
      final x = math.cos(a) * rx * wobble;
      final y = math.sin(a) * ry * wobble;
      final c = math.cos(rotation);
      final s = math.sin(rotation);
      final px = center.dx + x * c - y * s;
      final py = center.dy + x * s + y * c;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  void _terrain(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final paint = Paint();
    final count = kind == GalaxyWorldKind.archive ? 110 : 78;
    for (var i = 0; i < count; i++) {
      final a = random.nextDouble() * math.pi * 2;
      final d = math.sqrt(random.nextDouble()) * r * .88;
      final point = center + Offset(math.cos(a) * d, math.sin(a) * d);
      final rx = r * (.008 + random.nextDouble() * .045);
      final ry = rx * (.35 + random.nextDouble() * 1.25);
      paint.color = (i.isEven ? p.terrainLight : p.terrainDark).withValues(alpha: .018 + random.nextDouble() * .055);
      canvas.drawOval(Rect.fromCenter(center: point, width: rx * 2.4, height: ry * 2.4), paint);
    }

    // Large geological streaks are deliberately curved and sparse.
    final bands = kind == GalaxyWorldKind.vegeta ? 4 : 3;
    for (var i = 0; i < bands; i++) {
      final y = center.dy + (i - (bands - 1) / 2) * r * .30;
      final path = Path()..moveTo(center.dx - r * 1.12, y);
      for (var j = 1; j <= 12; j++) {
        final x = center.dx - r * 1.12 + r * 2.24 * j / 12;
        final yy = y + math.sin(j * .82 + i * 2.3) * r * (.018 + random.nextDouble() * .025);
        path.lineTo(x, yy);
      }
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * (.008 + random.nextDouble() * .010)
        ..color = p.band.withValues(alpha: .025 + random.nextDouble() * .035));
    }
  }

  void _craters(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final count = switch (kind) {
      GalaxyWorldKind.vegeta => 20,
      GalaxyWorldKind.archive => 28,
      GalaxyWorldKind.family => 17,
      GalaxyWorldKind.music => 8,
      GalaxyWorldKind.creation => 9,
      _ => 13,
    };

    for (var i = 0; i < count; i++) {
      final point = Offset(
        center.dx + (random.nextDouble() * 2 - 1) * r * .82,
        center.dy + (random.nextDouble() * 2 - 1) * r * .82,
      );
      if ((point - center).distance > r * .88) continue;
      final rr = r * (.006 + random.nextDouble() * .026);
      canvas.drawCircle(point, rr, Paint()..color = Colors.black.withValues(alpha: .025 + random.nextDouble() * .055));
      canvas.drawArc(
        Rect.fromCircle(center: point - Offset(rr * .12, rr * .13), radius: rr * .72),
        math.pi * 1.05,
        math.pi * .90,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(.35, rr * .13)
          ..color = p.highlight.withValues(alpha: .055),
      );
    }
  }

  void _cloudBelts(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final cloudCount = switch (kind) {
      GalaxyWorldKind.music => 2,
      GalaxyWorldKind.archive => 1,
      _ => 3,
    };
    final paint = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < cloudCount; i++) {
      final y = center.dy + (i - (cloudCount - 1) / 2) * r * .27 + random.nextDouble() * r * .07;
      final left = center.dx - r * .82;
      final right = center.dx + r * .78;
      final path = Path()..moveTo(left, y);
      for (var j = 1; j <= 10; j++) {
        final x = left + (right - left) * j / 10;
        final yy = y + math.sin(j * 1.15 + i * 1.8) * r * (.014 + random.nextDouble() * .012);
        path.lineTo(x, yy);
      }
      paint
        ..strokeWidth = math.max(.55, r * .008)
        ..color = p.cloud.withValues(alpha: .025 + random.nextDouble() * .035);
      canvas.drawPath(path, paint);
    }
  }

  void _terminatorDetail(Canvas canvas, Offset center, double r, _PlanetPalette p) {
    // Soft night-side falloff. The offset makes the sphere read as lit from one side.
    final nightCenter = center + Offset(r * .39, r * .25);
    canvas.drawCircle(
      nightCenter,
      r * .72,
      Paint()..shader = RadialGradient(
        center: const Alignment(-.16, -.18),
        radius: .92,
        colors: [Colors.transparent, Colors.black.withValues(alpha: .075), Colors.black.withValues(alpha: .34)],
        stops: const [0, .48, 1],
      ).createShader(Rect.fromCircle(center: nightCenter, radius: r * .72)),
    );
  }

  void _specularLight(Canvas canvas, Offset center, double r, _PlanetPalette p) {
    final light = center + Offset(-r * .30, -r * .34);
    final rr = r * .58;
    canvas.drawCircle(
      light,
      rr,
      Paint()..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: .070),
          p.highlight.withValues(alpha: .022),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: light, radius: rr)),
    );
  }

  _PlanetPalette _palette(GalaxyWorldKind k) {
    switch (k) {
      case GalaxyWorldKind.vegeta:
        return const _PlanetPalette(Color(0xFF514C70), Color(0xFF211D34), Color(0xFF030208), Color(0xFF716B91), Color(0xFFA99BCB), Color(0xFF6E6590), Color(0xFF856BC0), Color(0xFFD4CBEB), Color(0xFFD0C8DE), Color(0xFF3B354F), Color(0xFF171328));
      case GalaxyWorldKind.game:
        return const _PlanetPalette(Color(0xFF4B7890), Color(0xFF163648), Color(0xFF031018), Color(0xFF466F4C), Color(0xFF8CA48D), Color(0xFF47778B), Color(0xFF5D9BBC), Color(0xFFD0E9E6), Color(0xFFC5E1DF), Color(0xFF244536), Color(0xFF102B31));
      case GalaxyWorldKind.music:
        return const _PlanetPalette(Color(0xFF594572), Color(0xFF261A33), Color(0xFF06040A), Color(0xFF77547C), Color(0xFFAA83AD), Color(0xFF76517E), Color(0xFF9360B5), Color(0xFFE0BFE4), Color(0xFFD9B9DE), Color(0xFF4A294E), Color(0xFF1D1027));
      case GalaxyWorldKind.identity:
        return const _PlanetPalette(Color(0xFF466F84), Color(0xFF172D3A), Color(0xFF02090E), Color(0xFF4E6F6C), Color(0xFF8FAAA0), Color(0xFF3F6575), Color(0xFF5C91A9), Color(0xFFC5DFDC), Color(0xFFC2D9D4), Color(0xFF294B49), Color(0xFF10262C));
      case GalaxyWorldKind.family:
        return const _PlanetPalette(Color(0xFF705B4D), Color(0xFF30231F), Color(0xFF080504), Color(0xFF735A48), Color(0xFFA78A70), Color(0xFF60483C), Color(0xFFA87858), Color(0xFFE3C5A6), Color(0xFFDCC9B8), Color(0xFF47362E), Color(0xFF201714));
      case GalaxyWorldKind.cinema:
        return const _PlanetPalette(Color(0xFF66768B), Color(0xFF293541), Color(0xFF05080C), Color(0xFF626C76), Color(0xFFA9B3BD), Color(0xFF586879), Color(0xFF819BB8), Color(0xFFD9E4ED), Color(0xFFD6E0E7), Color(0xFF353D47), Color(0xFF171D24));
      case GalaxyWorldKind.creation:
        return const _PlanetPalette(Color(0xFF805A75), Color(0xFF38263A), Color(0xFF09060B), Color(0xFF855B7D), Color(0xFFC29CB9), Color(0xFF875F82), Color(0xFFC16EA7), Color(0xFFF0CEE5), Color(0xFFE7CEDF), Color(0xFF513448), Color(0xFF211525));
      case GalaxyWorldKind.archive:
        return const _PlanetPalette(Color(0xFF50535D), Color(0xFF1E2026), Color(0xFF030306), Color(0xFF53545B), Color(0xFF85868D), Color(0xFF4A4C54), Color(0xFF777C8A), Color(0xFFC9CBD0), Color(0xFFC3C6CA), Color(0xFF33343A), Color(0xFF15161B));
      case GalaxyWorldKind.comingSoon:
        return const _PlanetPalette(Color(0xFF405764), Color(0xFF17252C), Color(0xFF020609), Color(0xFF405A61), Color(0xFF70888A), Color(0xFF3A515B), Color(0xFF5F8791), Color(0xFFC2D9D7), Color(0xFFBCD0CF), Color(0xFF293E44), Color(0xFF111D22));
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) {
    return oldDelegate.active != active || oldDelegate.kind != kind;
  }
}

class _PlanetPalette {
  final Color light, base, shadow, land, coast, band, glow, highlight, cloud, terrainLight, terrainDark;
  const _PlanetPalette(this.light, this.base, this.shadow, this.land, this.coast, this.band, this.glow, this.highlight, this.cloud, this.terrainLight, this.terrainDark);
}

class _SelectionLayer extends StatelessWidget {
  final GalaxyWorld? world;
  final bool compact;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _SelectionLayer({required this.world, required this.compact, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    if (world == null) return const SizedBox.shrink();
    return Positioned(
      left: compact ? 16 : 34,
      bottom: compact ? 16 : 28,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: compact ? 250 : 330,
          padding: const EdgeInsets.fromLTRB(18, 15, 10, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF080810).withValues(alpha: .90),
            border: Border.all(color: const Color(0xFFB7A9D5).withValues(alpha: .13)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .50), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(world!.title, style: const TextStyle(fontSize: 11, letterSpacing: 2.8)),
              const SizedBox(height: 5),
              Text(world!.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, height: 1.35, color: Colors.white.withValues(alpha: .38))),
            ])),
            const SizedBox(width: 8),
            TextButton(onPressed: onEnter, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('ENTER', style: TextStyle(fontSize: 8, letterSpacing: 1.8))),
            IconButton(onPressed: onClose, padding: EdgeInsets.zero, constraints: const BoxConstraints.tightFor(width: 28, height: 28), icon: Icon(Icons.close, size: 15, color: Colors.white.withValues(alpha: .35))),
          ]),
        ),
      ),
    );
  }
}
