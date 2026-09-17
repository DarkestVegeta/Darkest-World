import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;
  const GalaxyWorld({required this.kind, required this.title, required this.description});
}

/// Game-only visual core.
/// The CreateWorld references define the visual language; the island composition
/// is a strong structural guide, not a literal copy.
class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse>
    with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();
  bool worldOpen = false;

  GalaxyWorld get gameWorld => widget.worlds.firstWhere(
        (w) => w.kind == GalaxyWorldKind.game,
        orElse: () => const GalaxyWorld(
          kind: GalaxyWorldKind.game,
          title: 'Game World',
          description: 'The Game World',
        ),
      );

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  void enterWorld() {
    setState(() => worldOpen = true);
    GalaxyNavigationSession.instance.selected = GalaxyWorldKind.game.name;
    widget.onWorldTap?.call(gameWorld);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DeepSpacePainter(clock)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: worldOpen
                ? _GameWorldView(key: const ValueKey('game-world'), clock: clock)
                : _GamePlanetView(
                    key: const ValueKey('game-planet'),
                    clock: clock,
                    onEnter: enterWorld,
                  ),
          ),
          if (worldOpen)
            Positioned(
              top: 28,
              left: 28,
              child: _BackButton(onTap: () => setState(() => worldOpen = false)),
            ),
        ],
      ),
    );
  }
}

class _GamePlanetView extends StatelessWidget {
  final Animation<double> clock;
  final VoidCallback onEnter;
  const _GamePlanetView({super.key, required this.clock, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, box) {
          final size = math.min(box.maxWidth, box.maxHeight) * .55;
          return GestureDetector(
            onTap: onEnter,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(size: Size.square(size), painter: _PlanetAtmosphere(clock)),
                  CustomPaint(size: Size.square(size), painter: _GamePlanetPainter(clock)),
                  Positioned(
                    bottom: size * .08,
                    child: Text(
                      'GAME',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .86),
                        fontSize: math.max(13, size * .035),
                        letterSpacing: math.max(4, size * .012),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameWorldView extends StatelessWidget {
  final Animation<double> clock;
  const _GameWorldView({super.key, required this.clock});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Center(
          child: SizedBox(
            width: w * .92,
            height: h * .82,
            child: CustomPaint(
              painter: _IslandGameWorldPainter(clock),
            ),
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x66101722),
            border: Border.all(color: const Color(0x335C6F87)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'GAME PLANET',
            style: TextStyle(color: Colors.white.withValues(alpha: .72), fontSize: 11, letterSpacing: 1.8),
          ),
        ),
      );
}

class _DeepSpacePainter extends CustomPainter {
  final Animation<double> clock;
  _DeepSpacePainter(this.clock) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -.05),
        radius: 1.15,
        colors: [Color(0xFF10182A), Color(0xFF070B15), Color(0xFF020309)],
      ).createShader(r);
    canvas.drawRect(r, bg);

    final star = Paint()..style = PaintingStyle.fill;
    final random = math.Random(9127);
    for (var i = 0; i < 170; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final pulse = .16 + .10 * math.sin(clock.value * math.pi * 2 + i);
      star.color = Colors.white.withValues(alpha: pulse);
      canvas.drawCircle(Offset(x, y), .45 + random.nextDouble() * .65, star);
    }
  }

  @override
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => false;
}

class _PlanetAtmosphere extends CustomPainter {
  final Animation<double> clock;
  _PlanetAtmosphere(this.clock) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * .315;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x443E69A8),
          const Color(0x222B3F75),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r * 1.28));
    canvas.drawCircle(c, r * 1.28, glow);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0x7C718CC4);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.035), -.75, 2.3, false, rim);
  }

  @override
  bool shouldRepaint(covariant _PlanetAtmosphere oldDelegate) => true;
}

class _GamePlanetPainter extends CustomPainter {
  final Animation<double> clock;
  _GamePlanetPainter(this.clock) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * .315;
    final surface = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.42, -.48),
        radius: .82,
        colors: [Color(0xFF66728A), Color(0xFF29344A), Color(0xFF111827), Color(0xFF04070D)],
        stops: [0, .36, .73, 1],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, surface);

    final land = Paint()..style = PaintingStyle.fill;
    final random = math.Random(4207);
    for (var i = 0; i < 28; i++) {
      final a = random.nextDouble() * math.pi * 2;
      final rr = math.sqrt(random.nextDouble()) * r * .78;
      final p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr * .72);
      final rw = 3 + random.nextDouble() * 15;
      land.color = const Color(0xFF4C566A).withValues(alpha: .25 + random.nextDouble() * .22);
      canvas.drawOval(Rect.fromCenter(center: p, width: rw, height: rw * .55), land);
    }

    final night = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.62, .55),
        colors: [const Color(0x99000000), const Color(0x22000000), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, night);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x6694A7C4);
    canvas.drawCircle(c, r, edge);
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => true;
}

class _IslandGameWorldPainter extends CustomPainter {
  final Animation<double> clock;
  _IslandGameWorldPainter(this.clock) : super(repaint: clock);

  Path island(Size s, List<Offset> points) {
    final p = Path()..moveTo(points.first.dx * s.width, points.first.dy * s.height);
    for (var i = 1; i < points.length; i++) {
      p.lineTo(points[i].dx * s.width, points[i].dy * s.height);
    }
    return p..close();
  }

  void drawIsland(Canvas c, Size s, List<Offset> points, Color base, double scale) {
    final path = island(s, points);
    final bounds = path.getBounds();
    final shadow = Paint()..color = const Color(0x66000000);
    c.save();
    c.translate(0, 12 * scale);
    c.drawPath(path, shadow);
    c.restore();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [base.withValues(alpha: .98), base.withValues(alpha: .70), const Color(0xFF151C29)],
      ).createShader(bounds);
    c.drawPath(path, fill);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * scale
      ..color = const Color(0x665F7898);
    c.drawPath(path, rim);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size;
    final haze = Paint()
      ..shader = const RadialGradient(colors: [Color(0x222D4875), Color(0x00000000)]).createShader(
        Rect.fromCenter(center: Offset(s.width * .52, s.height * .48), width: s.width * .9, height: s.height * .9),
      );
    canvas.drawRect(Offset.zero & s, haze);

    // Strong island/world composition: large main landmass with smaller separated
    // platform islands around it. The forms are deliberately original but follow
    // the reference's readable top-down island hierarchy.
    drawIsland(canvas, s, [
      const Offset(.20, .40), const Offset(.28, .28), const Offset(.42, .23),
      const Offset(.57, .27), const Offset(.66, .39), const Offset(.63, .56),
      const Offset(.53, .66), const Offset(.37, .69), const Offset(.25, .60),
    ], const Color(0xFF53616A), 1.0);

    drawIsland(canvas, s, [
      const Offset(.66, .19), const Offset(.77, .14), const Offset(.87, .20),
      const Offset(.84, .31), const Offset(.73, .33),
    ], const Color(0xFF42515B), .75);

    drawIsland(canvas, s, [
      const Offset(.08, .23), const Offset(.17, .17), const Offset(.25, .21),
      const Offset(.24, .31), const Offset(.13, .34),
    ], const Color(0xFF46545E), .72);

    drawIsland(canvas, s, [
      const Offset(.70, .62), const Offset(.82, .59), const Offset(.91, .66),
      const Offset(.86, .77), const Offset(.74, .76),
    ], const Color(0xFF3D4A55), .70);

    drawIsland(canvas, s, [
      const Offset(.20, .72), const Offset(.30, .74), const Offset(.35, .82),
      const Offset(.27, .88), const Offset(.16, .83),
    ], const Color(0xFF3C4B55), .66);

    // restrained internal terrain accents
    final detail = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x447C91A2);
    final main = Rect.fromLTWH(s.width * .28, s.height * .34, s.width * .30, s.height * .25);
    canvas.drawOval(main, detail);
    canvas.drawArc(main.deflate(18), -.4, 1.7, false, detail);
    canvas.drawLine(Offset(s.width * .34, s.height * .53), Offset(s.width * .50, s.height * .40), detail);

    final nodes = [
      Offset(.35, .43), Offset(.50, .50), Offset(.58, .37), Offset(.76, .24), Offset(.17, .26),
    ];
    final node = Paint()..color = const Color(0x8897A8C2);
    for (var i = 0; i < nodes.length; i++) {
      final p = Offset(nodes[i].dx * s.width, nodes[i].dy * s.height);
      canvas.drawCircle(p, 3.5 + math.sin(clock.value * math.pi * 2 + i) * .8, node);
    }

    final title = TextPainter(
      text: TextSpan(
        text: 'GAME WORLD',
        style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: math.max(13, s.width * .018), letterSpacing: 4.2, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset((s.width - title.width) / 2, s.height * .91));
  }

  @override
  bool shouldRepaint(covariant _IslandGameWorldPainter oldDelegate) => true;
}
