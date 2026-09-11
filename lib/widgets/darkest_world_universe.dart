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
        if (!compact) Positioned(right: 34, top: 28, child: Text(
          'SELECT A WORLD',
          style: TextStyle(fontSize: 8, letterSpacing: 3, color: Colors.white.withValues(alpha: .28)),
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
    for (final world in widget.worlds) { if (world.kind == kind) return world; }
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
      GalaxyWorldKind.identity: Offset(size.width * .18, size.height * .31),
      GalaxyWorldKind.game: Offset(size.width * .78, size.height * .29),
      GalaxyWorldKind.cinema: Offset(size.width * .82, size.height * .70),
      GalaxyWorldKind.creation: Offset(size.width * .22, size.height * .72),
      GalaxyWorldKind.music: Offset(size.width * .52, size.height * .84),
      GalaxyWorldKind.family: Offset(size.width * .50, size.height * .16),
      GalaxyWorldKind.archive: Offset(size.width * .08, size.height * .53),
      GalaxyWorldKind.comingSoon: Offset(size.width * .92, size.height * .51),
    };
    final sizes = <GalaxyWorldKind, double>{
      GalaxyWorldKind.vegeta: base * (compact ? .29 : .34),
      GalaxyWorldKind.identity: base * (compact ? .13 : .15),
      GalaxyWorldKind.game: base * (compact ? .14 : .16),
      GalaxyWorldKind.cinema: base * (compact ? .115 : .135),
      GalaxyWorldKind.creation: base * (compact ? .115 : .135),
      GalaxyWorldKind.music: base * (compact ? .095 : .115),
      GalaxyWorldKind.family: base * (compact ? .09 : .105),
      GalaxyWorldKind.archive: base * (compact ? .065 : .075),
      GalaxyWorldKind.comingSoon: base * (compact ? .06 : .07),
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
        child: SizedBox(width: size + 110, height: size + 76, child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Transform.scale(
              scale: active ? 1.02 : 1,
              child: CustomPaint(
                size: Size.square(size),
                painter: _PlanetPainter(
                  kind: world.kind,
                  seed: world.kind.index * 911 + 47,
                  active: active,
                  central: central,
                ),
              ),
            ),
            Positioned(top: size + 9, left: -24, right: -24, child: Text(world.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: central ? 12 : 9, letterSpacing: central ? 3.8 : 2.4, color: Colors.white.withValues(alpha: active || central ? .9 : .58), shadows: const [Shadow(color: Colors.black, blurRadius: 16)]))),
            if (active) Positioned(top: size + 27, left: -30, right: -30, child: Text('ENTER WORLD', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Colors.white.withValues(alpha: .32)))),
          ],
        )),
      ),
    );
  }
}

class _UniverseTitle extends StatelessWidget {
  const _UniverseTitle();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('DARKESTWORLD', style: TextStyle(fontSize: 15, letterSpacing: 6, color: Colors.white.withValues(alpha: .86))),
    const SizedBox(height: 6),
    Text('THE WORLDS BEYOND', style: TextStyle(fontSize: 8, letterSpacing: 3.4, color: Colors.white.withValues(alpha: .30))),
  ]));
}

class _UniversePainter extends CustomPainter {
  const _UniversePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.18, colors: [Color(0xFF151226), Color(0xFF070711), Color(0xFF010106)]).createShader(rect));
    final random = math.Random(4817);
    final stars = Paint();
    for (var i = 0; i < 420; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      stars.color = Colors.white.withValues(alpha: .018 + random.nextDouble() * .12);
      canvas.drawCircle(p, .25 + random.nextDouble() * .65, stars);
    }
    final glowRect = Rect.fromCenter(center: Offset(size.width * .5, size.height * .5), width: size.width * .95, height: size.height * .80);
    canvas.drawOval(glowRect, Paint()..shader = RadialGradient(colors: [const Color(0xFF694D9A).withValues(alpha: .10), const Color(0xFF395D87).withValues(alpha: .035), Colors.transparent]).createShader(glowRect));
  }
  @override bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
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
    final rect = Offset.zero & size;
    final p = _palette(kind);

    if (active || central) {
      canvas.drawCircle(center, r * 1.09, Paint()..shader = RadialGradient(colors: [p.glow.withValues(alpha: active ? .16 : .10), p.glow.withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: r * 1.09)));
    }

    canvas.drawCircle(center, r * .985, Paint()..shader = RadialGradient(center: const Alignment(-.34, -.38), radius: 1.02, colors: [p.light, p.base, p.shadow], stops: const [0, .58, 1]).createShader(rect));

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r * .985)));
    final random = math.Random(seed);
    _surface(canvas, center, r, random, p);
    _craters(canvas, center, r, random, p);
    _clouds(canvas, center, r, random, p);
    _highlight(canvas, center, r, p);
    canvas.restore();

    canvas.drawArc(Rect.fromCircle(center: center, radius: r * .966), math.pi * .72, math.pi * 1.08, false, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1, r * .018)..color = p.glow.withValues(alpha: active ? .28 : .14));
    canvas.drawArc(Rect.fromCircle(center: center, radius: r * .985), -math.pi * .94, math.pi * .62, false, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(.8, r * .010)..color = Colors.white.withValues(alpha: .10));

    final night = center + Offset(r * .34, r * .22);
    canvas.drawCircle(night, r * .72, Paint()..shader = RadialGradient(center: const Alignment(-.18, -.18), radius: .92, colors: [Colors.transparent, Colors.black.withValues(alpha: .08), Colors.black.withValues(alpha: .38)], stops: const [0, .48, 1]).createShader(Rect.fromCircle(center: night, radius: r * .72)));
  }

  void _surface(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final paint = Paint();
    final count = switch (kind) {
      GalaxyWorldKind.game || GalaxyWorldKind.identity || GalaxyWorldKind.cinema => 115,
      GalaxyWorldKind.music || GalaxyWorldKind.creation => 90,
      _ => 130,
    };

    // Quiet, natural planetary variation. No named-world continents or Game-World lands here.
    for (var i = 0; i < count; i++) {
      final a = random.nextDouble() * math.pi * 2;
      final d = math.sqrt(random.nextDouble()) * r * .86;
      final point = center + Offset(math.cos(a) * d, math.sin(a) * d);
      final rx = r * (.012 + random.nextDouble() * .065);
      final ry = rx * (.45 + random.nextDouble() * .95);
      final opacity = .025 + random.nextDouble() * .065;
      paint.color = (i.isEven ? p.land : p.highlight).withValues(alpha: opacity);
      canvas.drawOval(Rect.fromCenter(center: point, width: rx * 2.2, height: ry * 2.2), paint);
    }

    // A few broad, irregular mineral bands make the surface feel spherical rather than flat.
    for (var i = 0; i < 7; i++) {
      final y = center.dy + (i - 3) * r * .19 + (random.nextDouble() - .5) * r * .12;
      final path = Path()..moveTo(center.dx - r * 1.1, y);
      for (var j = 1; j <= 9; j++) {
        final x = center.dx - r * 1.1 + (r * 2.2) * j / 9;
        path.lineTo(x, y + math.sin(j * 1.37 + i) * r * (.025 + random.nextDouble() * .025));
      }
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = r * (.012 + random.nextDouble() * .018)..color = p.band.withValues(alpha: .035 + random.nextDouble() * .045));
    }
  }

  void _craters(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final count = switch (kind) {
      GalaxyWorldKind.family || GalaxyWorldKind.archive || GalaxyWorldKind.vegeta => 26,
      GalaxyWorldKind.music || GalaxyWorldKind.creation => 13,
      _ => 20,
    };
    for (var i = 0; i < count; i++) {
      final point = Offset(center.dx + (random.nextDouble() * 2 - 1) * r * .82, center.dy + (random.nextDouble() * 2 - 1) * r * .82);
      if ((point - center).distance > r * .90) continue;
      final rr = r * (.008 + random.nextDouble() * .035);
      canvas.drawCircle(point, rr, Paint()..color = Colors.black.withValues(alpha: .035 + random.nextDouble() * .07));
      canvas.drawCircle(point - Offset(rr * .22, rr * .20), rr * .72, Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(.35, rr * .14)..color = p.highlight.withValues(alpha: .065));
    }
  }

  void _clouds(Canvas canvas, Offset center, double r, math.Random random, _PlanetPalette p) {
    final paint = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 4; i++) {
      final y = center.dy + (i - 1.5) * r * .25 + random.nextDouble() * r * .08;
      final left = center.dx - r * .80;
      final right = center.dx + r * .62;
      final path = Path()..moveTo(left, y);
      for (var j = 1; j <= 8; j++) {
        final x = left + (right - left) * j / 8;
        path.lineTo(x, y + math.sin(j * 1.7 + i) * r * (.022 + random.nextDouble() * .016));
      }
      paint..strokeWidth = math.max(.6, r * .010)..color = p.cloud.withValues(alpha: .035 + random.nextDouble() * .045);
      canvas.drawPath(path, paint);
    }
  }

  void _highlight(Canvas canvas, Offset center, double r, _PlanetPalette p) {
    final light = center + Offset(-r * .30, -r * .34);
    final rr = r * .62;
    canvas.drawCircle(light, rr, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .075), p.highlight.withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: light, radius: rr)));
  }

  _PlanetPalette _palette(GalaxyWorldKind k) {
    switch (k) {
      case GalaxyWorldKind.vegeta: return const _PlanetPalette(Color(0xFF514A72), Color(0xFF19172C), Color(0xFF020208), Color(0xFF7770A1), Color(0xFFB7A8E5), Color(0xFF6B5E9B), Color(0xFF9272D2), Color(0xFFD6CCF2), Color(0xFFD9D3EE));
      case GalaxyWorldKind.game: return const _PlanetPalette(Color(0xFF4B7E9B), Color(0xFF12344B), Color(0xFF03101A), Color(0xFF3E704F), Color(0xFF8DB5A2), Color(0xFF3B718C), Color(0xFF5C9EC1), Color(0xFFB6E3E8), Color(0xFFE0F2F1));
      case GalaxyWorldKind.music: return const _PlanetPalette(Color(0xFF5B467D), Color(0xFF241632), Color(0xFF06030C), Color(0xFF8A4D9A), Color(0xFFBE82CE), Color(0xFFA25BC0), Color(0xFFA263D0), Color(0xFFE0B5EE), Color(0xFFE0C6EB));
      case GalaxyWorldKind.identity: return const _PlanetPalette(Color(0xFF3E6E8C), Color(0xFF122A3A), Color(0xFF020A11), Color(0xFF496C70), Color(0xFF8AB0A7), Color(0xFF355D7C), Color(0xFF548DAD), Color(0xFFB2D8D9), Color(0xFFD9E8E4));
      case GalaxyWorldKind.family: return const _PlanetPalette(Color(0xFF725B4D), Color(0xFF30221F), Color(0xFF090504), Color(0xFF765D4B), Color(0xFFA58A72), Color(0xFF59453C), Color(0xFFB17A57), Color(0xFFE0C0A2), Color(0xFFD6C5B6));
      case GalaxyWorldKind.cinema: return const _PlanetPalette(Color(0xFF66758D), Color(0xFF26313F), Color(0xFF05080C), Color(0xFF5C6470), Color(0xFFA8B2C0), Color(0xFF526377), Color(0xFF8FA5C2), Color(0xFFD8E2ED), Color(0xFFE3E9EF));
      case GalaxyWorldKind.creation: return const _PlanetPalette(Color(0xFF875B7A), Color(0xFF35223A), Color(0xFF09050C), Color(0xFF8E5A86), Color(0xFFC89BC3), Color(0xFF9E668F), Color(0xFFD178C1), Color(0xFFF0C8E6), Color(0xFFE8D7E6));
      case GalaxyWorldKind.archive: return const _PlanetPalette(Color(0xFF4B4E58), Color(0xFF1C1D23), Color(0xFF030306), Color(0xFF4B4B52), Color(0xFF777A83), Color(0xFF41434C), Color(0xFF7D7E8A), Color(0xFFC5C6CC), Color(0xFFC5C6CC));
      case GalaxyWorldKind.comingSoon: return const _PlanetPalette(Color(0xFF3D5362), Color(0xFF15222A), Color(0xFF020609), Color(0xFF36515B), Color(0xFF69838A), Color(0xFF304651), Color(0xFF5B8993), Color(0xFFB3D2D3), Color(0xFFD2E2E0));
    }
  }
  @override bool shouldRepaint(covariant _PlanetPainter oldDelegate) => oldDelegate.active != active || oldDelegate.kind != kind;
}

class _PlanetPalette {
  final Color light, base, shadow, land, coast, band, glow, highlight, cloud;
  const _PlanetPalette(this.light, this.base, this.shadow, this.land, this.coast, this.band, this.glow, this.highlight, this.cloud);
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
    return Positioned(left: compact ? 14 : 34, right: compact ? 14 : 34, bottom: compact ? 14 : 28,
      child: Material(color: Colors.transparent, child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        padding: EdgeInsets.fromLTRB(compact ? 18 : 24, 15, 10, 15),
        decoration: BoxDecoration(color: const Color(0xFF07070E).withValues(alpha: .94), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBA9E6).withValues(alpha: .16)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .60), blurRadius: 32, offset: const Offset(0, 12))]),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(world!.title, style: const TextStyle(fontSize: 12, letterSpacing: 3)),
            const SizedBox(height: 6),
            Text(world!.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.4, color: Colors.white.withValues(alpha: .44))),
          ])),
          const SizedBox(width: 12),
          TextButton(onPressed: onEnter, child: const Text('ENTER')),
          IconButton(onPressed: onClose, icon: Icon(Icons.close, size: 17, color: Colors.white.withValues(alpha: .45))),
        ]),
      )));
  }
}
