import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Game Planet -> Game World is intentionally kept in one lightweight screen.
/// Rendering is procedural so the visual target can be pushed without loading
/// large texture packs into the GTX 950 / 2 GB VRAM baseline.
class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});

  @override
  State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  )..repeat();

  bool _insideWorld = false;
  double _worldAngle = 0;
  double _dragStartAngle = 0;
  double _dragStartX = 0;

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _enterWorld() => setState(() => _insideWorld = true);
  void _leaveWorld() => setState(() => _insideWorld = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _DeepSpacePainter(_clock.value)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1100),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: .965, end: 1).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: _insideWorld
                    ? _GameWorldView(
                        key: const ValueKey('world'),
                        phase: _clock.value,
                        angle: _worldAngle,
                        onBack: _leaveWorld,
                        onDragStart: (x) {
                          _dragStartX = x;
                          _dragStartAngle = _worldAngle;
                        },
                        onDragUpdate: (x) {
                          setState(() => _worldAngle = (_dragStartAngle + (x - _dragStartX) / 420).clamp(-1.0, 1.0));
                        },
                      )
                    : _GamePlanetView(
                        key: const ValueKey('planet'),
                        phase: _clock.value,
                        onEnter: _enterWorld,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GamePlanetView extends StatelessWidget {
  final double phase;
  final VoidCallback onEnter;

  const _GamePlanetView({super.key, required this.phase, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: LayoutBuilder(
            builder: (context, box) {
              final diameter = math.min(
                box.maxWidth * (compact ? .82 : .54),
                box.maxHeight * (compact ? .60 : .76),
              );
              return GestureDetector(
                onTap: onEnter,
                child: SizedBox.square(
                  dimension: diameter,
                  child: CustomPaint(
                    painter: _GamePlanetPainter(phase),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GameWorldView extends StatelessWidget {
  final double phase;
  final double angle;
  final VoidCallback onBack;
  final ValueChanged<double> onDragStart;
  final ValueChanged<double> onDragUpdate;

  const _GameWorldView({super.key, required this.phase, required this.angle, required this.onBack, required this.onDragStart, required this.onDragUpdate});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: InkWell(
                onTap: onBack,
                child: const Text(
                  '‹',
                  style: TextStyle(
                    color: Color(0xAFCBD2D9),
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: LayoutBuilder(
            builder: (context, box) {
              final width = math.min(
                box.maxWidth * (compact ? .94 : .82),
                box.maxHeight * (compact ? .72 : .82),
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) => onDragStart(d.globalPosition.dx),
                onHorizontalDragUpdate: (d) => onDragUpdate(d.globalPosition.dx),
                child: SizedBox(
                  width: width,
                  height: width * .72,
                  child: CustomPaint(painter: _GameWorldPainter(phase, angle)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeepSpacePainter extends CustomPainter {
  final double phase;
  const _DeepSpacePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.08),
          radius: 1.05,
          colors: [Color(0xFF101322), Color(0xFF050710), Color(0xFF020308)],
        ).createShader(rect),
    );

    final random = math.Random(719);
    for (var i = 0; i < 180; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = .35 + .65 * math.sin(phase * math.pi * 2 + i * .71).abs();
      canvas.drawCircle(
        Offset(x, y),
        .35 + random.nextDouble() * .85,
        Paint()..color = Colors.white.withValues(alpha: .035 + .055 * twinkle),
      );
    }

    final haze = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x332C2855),
          const Color(0x102C2855),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .47),
        width: size.width * .95,
        height: size.height * .7,
      ));
    canvas.drawRect(rect, haze);
  }

  @override
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.angle != angle;
}

class _GamePlanetPainter extends CustomPainter {
  final double phase;
  const _GamePlanetPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .39;
    final sphere = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c,
      r * 1.16,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x554E477D),
            const Color(0x203A3B69),
            Colors.transparent,
          ],
          stops: const [.65, .82, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.16)),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.43, -.48),
          radius: 1.0,
          colors: [
            Color(0xFF74758F),
            Color(0xFF414563),
            Color(0xFF20263F),
            Color(0xFF070A16),
          ],
          stops: [.05, .36, .70, 1],
        ).createShader(sphere),
    );

    final land = Paint()..color = const Color(0xB27B7188);
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .012
      ..color = const Color(0x6C9A94B2);

    final continents = <List<Offset>>[
      [Offset(.18, .31), Offset(.27, .23), Offset(.39, .27), Offset(.44, .39), Offset(.35, .47), Offset(.22, .43), Offset(.16, .36)],
      [Offset(.52, .18), Offset(.67, .20), Offset(.78, .31), Offset(.73, .43), Offset(.61, .40), Offset(.55, .31)],
      [Offset(.34, .56), Offset(.47, .52), Offset(.57, .60), Offset(.52, .76), Offset(.38, .80), Offset(.28, .68)],
      [Offset(.64, .54), Offset(.80, .52), Offset(.86, .66), Offset(.76, .77), Offset(.63, .70)],
    ];

    for (final points in continents) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(
          sphere.left + points[i].dx * sphere.width,
          sphere.top + points[i].dy * sphere.height,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, land);
      canvas.drawPath(path, coast);
    }

    final texture = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .004
      ..color = const Color(0x475E648D);
    for (var i = 0; i < 18; i++) {
      final y = sphere.top + sphere.height * (.16 + i * .038);
      final path = Path()..moveTo(sphere.left, y);
      for (var j = 1; j <= 6; j++) {
        final x = sphere.left + sphere.width * j / 6;
        final wave = math.sin(i * 1.7 + j * .8 + phase * math.pi * 2) * r * .012;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, texture);
    }

    final night = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-.1, -.9),
        end: Alignment(.95, .6),
        colors: [Colors.transparent, Color(0x6600050C), Color(0xDD000207)],
        stops: [.28, .62, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, night);
    _drawPlanetSurfaceMaterial(canvas, sphere, c, r, phase);
    _drawPlanetSurfaceZones(canvas, sphere, c, r);
    _drawPlanetAtmosphere(canvas, sphere, c, r, phase);
    canvas.restore();

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .012
        ..color = const Color(0xA29C9FBE),
    );

    final rimLight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .022
      ..color = const Color(0x6E8D86B4);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.012),
      math.pi * .92,
      math.pi * .72,
      false,
      rimLight,
    );

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .012
      ..color = const Color(0x805C4F86);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.055),
      phase * math.pi * 2,
      math.pi * .82,
      false,
      arc,
    );
  }

  void _drawPlanetSurfaceMaterial(Canvas canvas, Rect sphere, Offset c, double r, double phase) {
    final bands = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .010
      ..color = const Color(0x185C6385);

    for (var i = 0; i < 7; i++) {
      final y = sphere.top + sphere.height * (.18 + i * .105);
      final path = Path()..moveTo(sphere.left - r * .04, y);
      for (var j = 1; j <= 10; j++) {
        final x = sphere.left + sphere.width * j / 10;
        final wave = math.sin(i * .9 + j * .72 + phase * math.pi * 2) * r * .010;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, bands);
    }

    final dawn = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.58, -.20),
        radius: .72,
        colors: const [
          Color(0x223D4E70),
          Color(0x102D355A),
          Colors.transparent,
        ],
        stops: const [.0, .55, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, dawn);

    final terminator = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Colors.transparent,
          Color(0x14000004),
          Color(0x22000005),
        ],
        stops: const [.38, .72, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, terminator);
  }

  void _drawPlanetSurfaceZones(Canvas canvas, Rect sphere, Offset c, double r) {
    final north = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0x163A4568),
          Colors.transparent,
        ],
      ).createShader(sphere);
    canvas.drawRect(sphere, north);

    final equator = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .024
      ..color = const Color(0x0F9C9AB5);
    canvas.drawArc(
      Rect.fromCenter(
        center: c.translate(0, r * .03),
        width: r * 1.72,
        height: r * .68,
      ),
      math.pi * .06,
      math.pi * .88,
      false,
      equator,
    );

    final dusk = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.82, .30),
        radius: .72,
        colors: const [
          Color(0x16000612),
          Color(0x09000612),
          Colors.transparent,
        ],
      ).createShader(sphere);
    canvas.drawCircle(c, r, dusk);
  }

  void _drawPlanetAtmosphere(Canvas canvas, Rect sphere, Offset c, double r, double phase) {
    final cloud = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .018
      ..color = const Color(0x255E6790);
    for (var i = 0; i < 5; i++) {
      final y = sphere.top + sphere.height * (.25 + i * .13);
      final path = Path()..moveTo(sphere.left - r * .08, y);
      for (var j = 1; j <= 8; j++) {
        final x = sphere.left + sphere.width * j / 8;
        final wave = math.sin(i * 1.2 + j * .9 + phase * math.pi * 2) * r * .014;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, cloud);
    }

    final atmosphericEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .035
      ..color = const Color(0x2D6D6E9A);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.025),
      math.pi * 1.05,
      math.pi * .78,
      false,
      atmosphericEdge,
    );
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.phase != phase;
}

class _GameWorldPainter extends CustomPainter {
  final double phase;
  final double angle;
  double get _currentAngle => angle;
  const _GameWorldPainter(this.phase, this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF152A35), Color(0xFF091821), Color(0xFF030910)],
        ).createShader(rect),
    );

    final ocean = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.05, -.12),
        radius: 1.0,
        colors: const [
          Color(0xFF173A42),
          Color(0xFF0C2930),
          Color(0xFF07161B),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, ocean);

    canvas.save();
    final yaw = math.sin(angle);
    final depth = .72 + .28 * math.cos(angle).abs();
    canvas.translate(center.dx + yaw * size.width * .035, center.dy);
    canvas.scale(depth, 1.0);
    canvas.translate(-center.dx, -center.dy);
    _drawOceanContours(canvas, size, center);
    _drawRotatedFarIslands(canvas, size, center, angle);
    _drawMainLandmassDepth(canvas, size, center, angle);
    _drawMainLandmass(canvas, size, center);
    _drawNearTerrainLayers(canvas, size, center, angle);
    _drawCoastalInlets(canvas, size, center);
    _drawCoastalShelves(canvas, size, center);
    _drawSecondaryIslands(canvas, size, center);
    _drawIslandMaterial(canvas, size, center);
    _drawCoastalDepth(canvas, size, center);
    _drawTerrainContours(canvas, size, center);
    _drawElevationRidges(canvas, size, center);
    _drawTerrainMasses(canvas, size, center);
    _drawTerrainHighlights(canvas, size, center);
    _drawTerrainShadows(canvas, size, center);
    _drawWaterReflections(canvas, size, center);
    _drawWorldRoutes(canvas, size, center);
    _drawLandmarks(canvas, size, center);
    _drawWorldMist(canvas, size, center);
    _drawWorldLightSweep(canvas, size, center);
    _drawWorldSurfaceFrame(canvas, size, center);
    canvas.restore();

    final atmosphere = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xB9000205)],
        stops: const [.57, 1],
      ).createShader(rect);
    canvas.drawRect(rect, atmosphere);

  }

  Path _landPath(Size size, Offset center) {
    final points = <Offset>[
      Offset(.03, -.31), Offset(.14, -.39), Offset(.29, -.35),
      Offset(.40, -.25), Offset(.43, -.11), Offset(.37, -.01),
      Offset(.45, .09), Offset(.39, .22), Offset(.27, .28),
      Offset(.17, .23), Offset(.08, .31), Offset(-.08, .33),
      Offset(-.19, .27), Offset(-.23, .16), Offset(-.34, .13),
      Offset(-.40, .02), Offset(-.34, -.09), Offset(-.25, -.13),
      Offset(-.23, -.25), Offset(-.13, -.34),
    ];
    final p = points.map((v) => Offset(
      center.dx + v.dx * size.width,
      center.dy + v.dy * size.height,
    )).toList();

    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 1; i < p.length; i++) {
      final prev = p[i - 1];
      final cur = p[i];
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    final last = p.last;
    final first = p.first;
    final mid = Offset((last.dx + first.dx) / 2, (last.dy + first.dy) / 2);
    path.quadraticBezierTo(last.dx, last.dy, mid.dx, mid.dy);
    path.quadraticBezierTo(first.dx, first.dy, first.dx, first.dy);
    path.close();
    return path;
  }

  void _drawRotatedFarIslands(Canvas canvas, Size size, Offset center, double angle) {
    final amount = math.sin(angle).abs();
    final dir = math.sin(angle).sign;
    final front = math.max(0.0, math.sin(angle));
    final back = math.max(0.0, -math.sin(angle));

    final islands = [
      (Offset(-.42, -.26), .050, .032, .72),
      (Offset(-.08, -.04), .075, .040, .88),
      (Offset(.30, .18), .060, .035, .78),
    ];

    for (var i = 0; i < islands.length; i++) {
      final item = islands[i];
      final reveal = .35 + amount * item.$4;
      final x = item.$1.dx + dir * (.055 + i * .012) * amount;
      final y = item.$1.dy + (front - back) * (.028 + i * .010);
      final c = Offset(center.dx + x * size.width, center.dy + y * size.height);
      final w = size.width * item.$2 * reveal;
      final h = size.height * item.$3 * reveal;

      final depth = size.height * (.014 + amount * (.010 + i * .004));
      final side = Path()
        ..moveTo(c.dx - w, c.dy)
        ..quadraticBezierTo(c.dx, c.dy - h, c.dx + w, c.dy - h * .10)
        ..quadraticBezierTo(c.dx + w * .35, c.dy + h, c.dx - w, c.dy);

      canvas.drawPath(
        side.shift(Offset(-dir * size.width * .010, depth)),
        Paint()..color = const Color(0x99000103),
      );

      final top = Path()
        ..moveTo(c.dx - w, c.dy - depth)
        ..quadraticBezierTo(c.dx, c.dy - h - depth, c.dx + w, c.dy - h * .10 - depth)
        ..quadraticBezierTo(c.dx + w * .35, c.dy + h - depth, c.dx - w, c.dy - depth);

      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF536258),
              Color(0xFF35463E),
              Color(0xFF202F2B),
            ],
          ).createShader(Rect.fromCenter(center: c, width: w * 2, height: h * 2)),
      );

      canvas.drawPath(
        top,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .0025
          ..color = const Color(0x66858C79),
      );
    }
  }

  void _drawMainLandmassDepth(Canvas canvas, Size size, Offset center, double angle) {
    final amount = math.sin(angle).abs();
    if (amount < .02) return;
    final base = _landPath(size, center);
    final dir = math.sin(angle).sign;
    final lift = size.height * (.016 + amount * .035);
    canvas.drawPath(base.shift(Offset(-dir * size.width * .014, lift)), Paint()..color=const Color(0x88000103));
    canvas.drawPath(base.shift(Offset(-dir * size.width * .007, lift*.35)), Paint()..style=PaintingStyle.stroke..strokeWidth=size.width*.012..color=const Color(0x304D756D));
  }

  void _drawNearTerrainLayers(Canvas canvas, Size size, Offset center, double angle) {
    final amount = math.sin(angle).abs();
    if (amount < .03) return;
    final dir = math.sin(angle).sign;
    final layers = [
      (Offset(-.11, -.12), .11, .050, .028),
      (Offset(.08, -.02), .095, .045, .024),
      (Offset(.01, .14), .13, .055, .032),
    ];

    for (var i = 0; i < layers.length; i++) {
      final item = layers[i];
      final p = Offset(
        center.dx + (item.$1.dx - dir * (.006 + amount * .010)) * size.width,
        center.dy + (item.$1.dy + amount * (.008 + i * .004)) * size.height,
      );
      final w = size.width * item.$2;
      final h = size.height * item.$3;
      final lift = size.height * (.008 + amount * (.016 + i * .006));

      final base = Path()
        ..moveTo(p.dx - w, p.dy)
        ..quadraticBezierTo(p.dx - w * .45, p.dy - h, p.dx + w, p.dy - h * .12)
        ..quadraticBezierTo(p.dx + w * .40, p.dy + h, p.dx - w, p.dy);

      canvas.drawPath(
        base.shift(Offset(-dir * size.width * (.012 + amount * .006), lift)),
        Paint()..color = const Color(0x88000103),
      );

      final top = base.shift(Offset(-dir * size.width * .004, -lift * .15));
      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0x657B7967),
              Color(0x453F5148),
              Color(0x2425312B),
            ],
          ).createShader(Rect.fromCenter(center: p, width: w * 2, height: h * 2)),
      );
    }
  }

  void _drawMainLandmass(Canvas canvas, Size size, Offset center) {
    final coast = _landPath(size, center);

    canvas.drawPath(
      coast.shift(Offset(0, size.height * .018)),
      Paint()..color = const Color(0x99000205),
    );

    canvas.drawPath(
      coast.shift(Offset(0, size.height * .006)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .030
        ..color = const Color(0x405F8C91),
    );

    canvas.drawPath(
      coast.shift(Offset(0, -size.height * .004)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .014
        ..color = const Color(0x527E866F),
    );

    canvas.drawPath(
      coast,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D6A63), Color(0xFF46534A), Color(0xFF283732)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      coast.shift(Offset(0, -size.height * .006)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .010
        ..color = const Color(0x4B9A9479),
    );

    final plateau = Path()
      ..moveTo(center.dx - size.width * .16, center.dy - size.height * .15)
      ..cubicTo(
        center.dx - size.width * .05, center.dy - size.height * .25,
        center.dx + size.width * .13, center.dy - size.height * .22,
        center.dx + size.width * .22, center.dy - size.height * .08,
      )
      ..cubicTo(
        center.dx + size.width * .12, center.dy + size.height * .03,
        center.dx - size.width * .03, center.dy + size.height * .03,
        center.dx - size.width * .16, center.dy - size.height * .15,
      );
    canvas.drawPath(plateau, Paint()..color = const Color(0x3D6D6652));
  }

  void _drawCoastalShelves(Canvas canvas, Size size, Offset center) {
    final main = _landPath(size, center);

    final shelfOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .030
      ..color = const Color(0x1F6BA0A0);
    final shelfMid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .015
      ..color = const Color(0x2D7A9A87);
    final sand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .007
      ..color = const Color(0x4A9C9679);

    canvas.drawPath(main.shift(Offset(0, size.height * .012)), shelfOuter);
    canvas.drawPath(main.shift(Offset(0, size.height * .006)), shelfMid);
    canvas.drawPath(main.shift(Offset(0, -size.height * .002)), sand);

    final coves = [
      Offset(-.34, -.01),
      Offset(-.22, -.22),
      Offset(.31, -.17),
      Offset(.38, .10),
      Offset(.14, .25),
    ];
    for (var i = 0; i < coves.length; i++) {
      final p = Offset(
        center.dx + coves[i].dx * size.width,
        center.dy + coves[i].dy * size.height,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: size.width * (.035 + i * .006),
          height: size.height * (.018 + i * .003),
        ),
        Paint()..color = const Color(0x183E8588),
      );
    }
  }

  void _drawSecondaryIslands(Canvas canvas, Size size, Offset center) {
    final angle = _currentAngle;
    final amount = math.sin(angle).abs();
    final dir = math.sin(angle).sign;
    final islands = [
      [Offset(.47, -.31), .13, .09, 1],
      [Offset(.39, .38), .14, .10, 2],
      [Offset(-.47, .30), .11, .075, 3],
      [Offset(-.42, -.27), .085, .065, 4],
      [Offset(.03, .46), .10, .06, 5],
    ];

    for (final data in islands) {
      final base = data[0] as Offset;
      final w = data[1] as double;
      final h = data[2] as double;
      final seed = data[3] as int;
      final x = base.dx + dir * amount * (.018 + seed * .002);
      final y = base.dy + math.sin(angle) * (.010 + seed * .002);
      final c = Offset(center.dx + x * size.width, center.dy + y * size.height);
      final depth = size.height * (.010 + amount * (.012 + seed * .001));
      final random = math.Random(seed * 173);
      final path = Path();
      const count = 18;
      for (var i = 0; i < count; i++) {
        final a = math.pi * 2 * i / count;
        final jitter = .82 + random.nextDouble() * .18;
        final point = Offset(
          c.dx + math.cos(a) * size.width * w * jitter,
          c.dy + math.sin(a) * size.height * h * jitter,
        );
        if (i == 0) path.moveTo(point.dx, point.dy);
        else path.lineTo(point.dx, point.dy);
      }
      path.close();

      canvas.drawPath(
        path.shift(Offset(-dir * size.width * (.006 + amount * .010), depth)),
        Paint()..color = const Color(0x88000305),
      );

      canvas.drawPath(
        path.shift(Offset(-dir * size.width * .003, -depth * .12)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF566257),
              Color(0xFF35463D),
              Color(0xFF26352F),
            ],
          ).createShader(Rect.fromCenter(
            center: c,
            width: size.width * w * 2.2,
            height: size.height * h * 2.2,
          )),
      );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .003
          ..color = const Color(0x668E947F),
      );
    }
  }

  void _drawIslandMaterial(Canvas canvas, Size size, Offset center) {
    final main = _landPath(size, center);
    canvas.save();
    canvas.clipPath(main);

    final light = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.42, -.45),
        radius: .95,
        colors: const [
          Color(0x3FBBB08B),
          Color(0x163D5147),
          Colors.transparent,
        ],
        stops: [.0, .48, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, light);

    final dark = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Colors.transparent,
          Color(0x1C000807),
          Color(0x4B000607),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, dark);

    final soil = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0022
      ..color = const Color(0x305D675B);

    for (var i = 0; i < 12; i++) {
      final y = center.dy - size.height * .25 + i * size.height * .043;
      final path = Path()..moveTo(center.dx - size.width * .40, y);
      for (var j = 1; j <= 9; j++) {
        final x = center.dx - size.width * .40 + j * size.width * .09;
        final wave = math.sin(i * .8 + j * 1.17) * size.height * .010;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, soil);
    }

    canvas.restore();
  }

  void _drawCoastalDepth(Canvas canvas, Size size, Offset center) {
    final coastGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .022
      ..color = const Color(0x304D8584);

    final innerCoast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .006
      ..color = const Color(0x668C9A82);

    final main = _landPath(size, center);
    canvas.drawPath(main.shift(Offset(0, size.height * .010)), coastGlow);
    canvas.drawPath(main.shift(Offset(0, -size.height * .003)), innerCoast);

    final shallow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .010
      ..color = const Color(0x244E9A9B);

    for (final offset in [
      Offset(-.02, .01),
      Offset(.01, -.012),
      Offset(.035, .018),
    ]) {
      canvas.drawPath(
        main.shift(Offset(size.width * offset.dx, size.height * offset.dy)),
        shallow,
      );
    }
  }

  void _drawElevationRidges(Canvas canvas, Size size, Offset center) {
    final ridge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .003
      ..color = const Color(0x3F8D8B78);

    final ridges = [
      [
        Offset(-.18, -.16), Offset(-.09, -.21), Offset(.01, -.18),
        Offset(.09, -.12), Offset(.17, -.15),
      ],
      [
        Offset(-.12, .03), Offset(-.03, -.02), Offset(.07, .01),
        Offset(.14, .07), Offset(.23, .05),
      ],
      [
        Offset(-.02, .18), Offset(.06, .14), Offset(.14, .17),
        Offset(.20, .23),
      ],
    ];

    for (final points in ridges) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(
          center.dx + points[i].dx * size.width,
          center.dy + points[i].dy * size.height,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.quadraticBezierTo(
            (path.getBounds().left + p.dx) / 2,
            p.dy,
            p.dx,
            p.dy,
          );
        }
      }
      canvas.drawPath(path, ridge);
    }

    final peak = Paint()..color = const Color(0x466D6B5C);
    for (final p in [
      Offset(-.08, -.12),
      Offset(.10, -.04),
      Offset(.04, .13),
    ]) {
      final point = Offset(
        center.dx + p.dx * size.width,
        center.dy + p.dy * size.height,
      );
      canvas.drawCircle(point, size.width * .012, peak);
      canvas.drawCircle(
        point.translate(size.width * .008, -size.height * .006),
        size.width * .006,
        Paint()..color = const Color(0x4C9B987F),
      );
    }
  }

  void _drawTerrainContours(Canvas canvas, Size size, Offset center) {
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0018
      ..color = const Color(0x465F7567);
    for (var i = 0; i < 7; i++) {
      final path = Path();
      final y = center.dy - size.height * .19 + i * size.height * .055;
      path.moveTo(center.dx - size.width * .25, y);
      for (var j = 1; j <= 7; j++) {
        final x = center.dx - size.width * .25 + j * size.width * .07;
        final wave = math.sin(j * .85 + i * .9) * size.height * .012;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, contour);
    }
  }

  void _drawTerrainShadows(Canvas canvas, Size size, Offset center) {
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .018
      ..color = const Color(0x26000608);

    for (final points in [
      [Offset(-.18, -.20), Offset(-.04, -.27), Offset(.12, -.20)],
      [Offset(-.16, .05), Offset(-.02, -.02), Offset(.13, .01), Offset(.24, -.05)],
      [Offset(-.10, .22), Offset(.02, .17), Offset(.16, .21)],
    ]) {
      final path=Path();
      for(var i=0;i<points.length;i++){
        final p=Offset(center.dx+points[i].dx*size.width,center.dy+points[i].dy*size.height);
        if(i==0) path.moveTo(p.dx,p.dy); else path.lineTo(p.dx,p.dy);
      }
      canvas.drawPath(path,shadow);
    }
  }

  void _drawWaterReflections(Canvas canvas, Size size, Offset center) {
    final reflection = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .0018
      ..color = const Color(0x315F9AA0);
    for (var i=0;i<12;i++) {
      final y=center.dy-size.height*.31+i*size.height*.052;
      final path=Path()..moveTo(center.dx-size.width*.43,y);
      for(var j=1;j<=9;j++){
        final x=center.dx-size.width*.43+j*size.width*.095;
        final wave=math.sin(j*.72+i*.65+phase*math.pi*2)*size.height*.006;
        path.lineTo(x,y+wave);
      }
      canvas.drawPath(path,reflection);
    }
  }

  void _drawTerrainMasses(Canvas canvas, Size size, Offset center) {
    final masses = [
      [Offset(-.09, -.12), .095, .052, 0.12],
      [Offset(.08, -.08), .082, .046, 0.08],
      [Offset(.02, .10), .115, .055, 0.10],
      [Offset(.16, .16), .072, .040, 0.06],
    ];

    for (final m in masses) {
      final p = m[0] as Offset;
      final w = m[1] as double;
      final h = m[2] as double;
      final lift = m[3] as double;
      final c = Offset(
        center.dx + p.dx * size.width,
        center.dy + p.dy * size.height - size.height * lift * .08,
      );

      final base = Paint()..color = const Color(0x2B111B17);
      canvas.drawOval(
        Rect.fromCenter(
          center: c.translate(size.width * .006, size.height * .010),
          width: size.width * w * 2.2,
          height: size.height * h * 2.2,
        ),
        base,
      );

      final face = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0x456F705E),
            Color(0x28484F43),
            Color(0x18222F2A),
          ],
        ).createShader(Rect.fromCenter(
          center: c,
          width: size.width * w * 2.2,
          height: size.height * h * 2.2,
        ));
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: size.width * w * 2.2,
          height: size.height * h * 2.2,
        ),
        face,
      );
    }
  }

  void _drawTerrainHighlights(Canvas canvas, Size size, Offset center) {
    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .004
      ..color = const Color(0x4B9A947B);

    for (final points in [
      [Offset(-.23, -.13), Offset(-.11, -.18), Offset(.02, -.14), Offset(.12, -.07)],
      [Offset(-.10, .08), Offset(.00, .04), Offset(.10, .08), Offset(.19, .15)],
      [Offset(-.18, .20), Offset(-.07, .24), Offset(.03, .20)],
    ]) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(
          center.dx + points[i].dx * size.width,
          center.dy + points[i].dy * size.height,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.quadraticBezierTo(
            (p.dx + path.getBounds().center.dx) / 2,
            p.dy,
            p.dx,
            p.dy,
          );
        }
      }
      canvas.drawPath(path, highlight);
    }
  }

  void _drawWorldRoutes(Canvas canvas, Size size, Offset center) {
    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .004
      ..color = const Color(0x8A9D9470);
    final paths = [
      [
        Offset(-.34, .01), Offset(-.18, -.05), Offset(-.04, -.12),
        Offset(.10, -.08), Offset(.23, .02), Offset(.36, .10),
      ],
      [
        Offset(-.13, .26), Offset(-.07, .13), Offset(.01, .03),
        Offset(.10, -.08), Offset(.18, -.20),
      ],
      [
        Offset(.08, .32), Offset(.15, .24), Offset(.24, .22),
        Offset(.37, .27),
      ],
    ];
    for (final points in paths) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(
          center.dx + points[i].dx * size.width,
          center.dy + points[i].dy * size.height,
        );
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, route);
    }
  }

  void _drawWorldMist(Canvas canvas, Size size, Offset center) {
    final mist = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.15, -.10),
        radius: .82,
        colors: const [
          Color(0x00000000),
          Color(0x123B5960),
          Color(0x25040B0F),
        ],
        stops: const [.35, .72, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, mist);

    final veil = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .010
      ..color = const Color(0x143F7276);
    for (var i = 0; i < 4; i++) {
      final y = center.dy - size.height * .28 + i * size.height * .18;
      final path = Path()..moveTo(-size.width * .05, y);
      for (var j = 1; j <= 8; j++) {
        final x = size.width * j / 8;
        final wave = math.sin(i * 1.4 + j * .72 + phase * math.pi * 2) *
            size.height * .018;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, veil);
    }
  }

  void _drawWorldLightSweep(Canvas canvas, Size size, Offset center) {
    final sweep = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-.85, -.55),
        end: const Alignment(.75, .55),
        colors: const [
          Color(0x101D3940),
          Color(0x082C4C50),
          Colors.transparent,
        ],
        stops: const [.0, .42, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, sweep);

    final horizon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .002
      ..color = const Color(0x263F777A);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -size.height * .01),
        width: size.width * .76,
        height: size.height * .58,
      ),
      horizon,
    );
  }

  void _drawWorldSurfaceFrame(Canvas canvas, Size size, Offset center) {
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0025
      ..color = const Color(0x244C7C80);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .006
      ..color = const Color(0x123B6468);

    final oval = Rect.fromCenter(
      center: center,
      width: size.width * .93,
      height: size.height * .91,
    );
    canvas.drawOval(oval, frame);
    canvas.drawOval(
      oval.deflate(size.width * .018),
      inner,
    );
  }

  void _drawLandmarks(Canvas canvas, Size size, Offset center) {
    final positions = [
      Offset(-.19, -.02), Offset(-.02, -.10), Offset(.15, -.07),
      Offset(.09, .16), Offset(-.05, .22), Offset(.25, .12),
      Offset(-.31, .02),
    ];
    final building = Paint()..color = const Color(0xB0AAA59A);
    final shadow = Paint()..color = const Color(0x66000304);
    for (var i = 0; i < positions.length; i++) {
      final p = Offset(
        center.dx + positions[i].dx * size.width,
        center.dy + positions[i].dy * size.height,
      );
      final w = size.width * (.014 + (i % 3) * .005);
      final h = w * (1.0 + (i % 2) * .75);
      canvas.drawRect(
        Rect.fromLTWH(p.dx - w / 2 + 3, p.dy - h / 2 + 3, w, h),
        shadow,
      );
      canvas.drawRect(
        Rect.fromLTWH(p.dx - w / 2, p.dy - h / 2, w, h),
        building,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameWorldPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
