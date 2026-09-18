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
                          setState(() => _worldAngle = (_dragStartAngle + (x - _dragStartX) / 300).clamp(-1.35, 1.35));
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
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => oldDelegate.phase != phase;
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

    final land = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xC58D8796),
          Color(0x9E5E6178),
          Color(0x633A4058),
        ],
      ).createShader(sphere);
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .009
      ..color = const Color(0x4AABA5BD);

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

    // Soft surface relief keeps the continents visually seated on the sphere.
    final relief = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.38, -.36),
        radius: .86,
        colors: const [
          Color(0x1EFFFFFF),
          Color(0x0CFFFFFF),
          Colors.transparent,
        ],
        stops: const [.0, .48, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, relief);

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

    final physicalGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.48, -.44),
        radius: 1.0,
        colors: const [
          Color(0x1EAFB4D0),
          Color(0x0A6D7195),
          Colors.transparent,
        ],
        stops: const [.0, .58, 1],
      ).createShader(Rect.fromCircle(center: c, radius: r * 1.08));
    canvas.drawCircle(c, r * 1.03, physicalGlow);

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
  const _GameWorldPainter(this.phase, this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = Offset(size.width / 2, size.height / 2);

    // The world is built as a small 3D scene, not as a flat map:
    // x = left/right, d = depth, h = terrain height.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.35),
          radius: 1.05,
          colors: [
            Color(0xFF152C38),
            Color(0xFF0A1B25),
            Color(0xFF03090F),
          ],
        ).createShader(rect),
    );

    final yaw = angle;
    _drawOcean(canvas, size, c, yaw);

    final islands = <_WorldIsland>[
      _WorldIsland(
        x: 0,
        d: 0.02,
        scale: 1.0,
        height: .16,
        seed: 7,
        main: true,
        points: const [
          Offset(-.48, -.10), Offset(-.40, -.28), Offset(-.20, -.39),
          Offset(.02, -.34), Offset(.23, -.42), Offset(.43, -.27),
          Offset(.49, -.05), Offset(.38, .15), Offset(.43, .31),
          Offset(.22, .42), Offset(-.02, .38), Offset(-.18, .47),
          Offset(-.39, .32), Offset(-.50, .13),
        ],
      ),
      _WorldIsland(x: -.56, d: -.34, scale: .42, height: .10, seed: 11, points: const [
        Offset(-.52, -.12), Offset(-.25, -.36), Offset(.10, -.31),
        Offset(.40, -.12), Offset(.48, .12), Offset(.20, .33),
        Offset(-.18, .30), Offset(-.46, .17),
      ]),
      _WorldIsland(x: .57, d: -.28, scale: .34, height: .09, seed: 19, points: const [
        Offset(-.50, -.10), Offset(-.20, -.34), Offset(.22, -.28),
        Offset(.46, -.02), Offset(.35, .25), Offset(.02, .35),
        Offset(-.34, .25),
      ]),
      _WorldIsland(x: -.54, d: .42, scale: .31, height: .075, seed: 23, points: const [
        Offset(-.46, -.10), Offset(-.12, -.30), Offset(.31, -.20),
        Offset(.43, .08), Offset(.20, .29), Offset(-.28, .26),
      ]),
      _WorldIsland(x: .50, d: .47, scale: .27, height: .07, seed: 31, points: const [
        Offset(-.45, -.08), Offset(-.10, -.26), Offset(.32, -.16),
        Offset(.42, .10), Offset(.12, .27), Offset(-.30, .20),
      ]),
    ];

    // Back-to-front sorting is what makes the drag a camera orbit rather than
    // moving one picture sideways.
    final ordered = [...islands]
      ..sort((a, b) => _depthOf(b, yaw).compareTo(_depthOf(a, yaw)));

    for (final island in ordered) {
      _drawIsland(canvas, size, c, island, yaw);
    }

    _drawOceanAtmosphere(canvas, size, c, yaw);

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xB8000206)],
        stops: const [.56, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  double _depthOf(_WorldIsland island, double yaw) {
    return island.d * math.cos(yaw) + island.x * math.sin(yaw);
  }

  Offset _project(
    Size size,
    Offset c,
    double x,
    double d,
    double h,
    double yaw, {
    double perspective = .20,
  }) {
    final cy = math.cos(yaw);
    final sy = math.sin(yaw);
    final rx = x * cy - d * sy;
    final rd = x * sy + d * cy;

    final depthScale = (1.0 - rd * perspective).clamp(.72, 1.24);
    final px = c.dx + rx * size.width * .46 * depthScale;
    final py = c.dy + rd * size.height * .29 * depthScale - h * size.height * .92 * depthScale;
    return Offset(px, py);
  }

  void _drawOcean(Canvas canvas, Size size, Offset c, double yaw) {
    final deep = Paint()
      ..shader = RadialGradient(
        center: Alignment(.0, -.12),
        radius: 1.0,
        colors: const [
          Color(0xFF18404A),
          Color(0xFF0B2932),
          Color(0xFF06151C),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, deep);

    final horizon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0025
      ..color = const Color(0x355E8990);
    final path = Path()
      ..moveTo(0, size.height * .18)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * (.08 + math.sin(yaw) * .025),
        size.width,
        size.height * .18,
      );
    canvas.drawPath(path, horizon);

    // Long, sparse water planes follow the camera, giving scale without
    // turning the sea into contour-line wallpaper.
    final water = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0012
      ..color = const Color(0x214B7E86);
    for (var i = 0; i < 8; i++) {
      final d = -.72 + i * .19;
      final left = _project(size, c, -.95, d, 0, yaw);
      final right = _project(size, c, .95, d, 0, yaw);
      canvas.drawLine(left, right, water);
    }
  }

  void _drawIsland(
    Canvas canvas,
    Size size,
    Offset c,
    _WorldIsland island,
    double yaw,
  ) {
    final top = <Offset>[];
    for (final p in island.points) {
      top.add(_project(
        size,
        c,
        island.x + p.dx * island.scale,
        island.d + p.dy * island.scale,
        island.height,
        yaw,
      ));
    }

    // A thick island body is drawn below the top surface. Its visible face
    // changes with camera angle and naturally disappears on the far side.
    final bottom = <Offset>[];
    for (final p in island.points) {
      bottom.add(_project(
        size,
        c,
        island.x + p.dx * island.scale,
        island.d + p.dy * island.scale,
        0,
        yaw,
      ));
    }

    final centerDepth = _depthOf(island, yaw);
    final sideDark = Color.lerp(
      const Color(0xFF0A1110),
      const Color(0xFF25372E),
      (.35 + centerDepth * .35).clamp(.0, 1.0),
    )!;

    // Only connect edges that face the camera. This is the important
    // difference from a flat offset shadow.
    final face = Path();
    for (var i = 0; i < top.length; i++) {
      final next = (i + 1) % top.length;
      final a = top[i];
      final b = top[next];
      final pa = island.points[i];
      final pb = island.points[next];
      final ex = pb.dx - pa.dx;
      final ed = pb.dy - pa.dy;
      final facing = ex * math.sin(yaw) - ed * math.cos(yaw);
      if (facing > -.02) {
        face.moveTo(a.dx, a.dy);
        face.lineTo(b.dx, b.dy);
        face.lineTo(bottom[next].dx, bottom[next].dy);
        face.lineTo(bottom[i].dx, bottom[i].dy);
        face.close();
      }
    }
    canvas.drawPath(face, Paint()..color = sideDark);

    // A second, softer lower lip gives the rock/earth mass a little more
    // separation from the ocean.
    final lip = Path();
    for (var i = 0; i < top.length; i++) {
      final next = (i + 1) % top.length;
      if (i.isEven) {
        lip.moveTo(bottom[i].dx, bottom[i].dy);
        lip.lineTo(bottom[next].dx, bottom[next].dy);
      }
    }
    canvas.drawPath(
      lip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .006
        ..color = const Color(0x29111A17),
    );

    final topPath = Path()..moveTo(top.first.dx, top.first.dy);
    for (var i = 1; i < top.length; i++) {
      topPath.lineTo(top[i].dx, top[i].dy);
    }
    topPath.close();

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: island.main
            ? const [
                Color(0xFF6B7868),
                Color(0xFF465449),
                Color(0xFF27352E),
              ]
            : const [
                Color(0xFF59665A),
                Color(0xFF35453B),
                Color(0xFF222F29),
              ],
      ).createShader(topPath.getBounds());
    canvas.drawPath(topPath, topPaint);

    // Coastal shelf: a thin darker ring, not a decorative outline.
    final shelf = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (island.main ? .009 : .006)
      ..color = const Color(0x5A1C302D);
    canvas.drawPath(topPath, shelf);

    _drawIslandTerrain(canvas, size, c, island, yaw, topPath);
  }

  void _drawIslandTerrain(
    Canvas canvas,
    Size size,
    Offset c,
    _WorldIsland island,
    double yaw,
    Path topPath,
  ) {
    canvas.save();
    canvas.clipPath(topPath);

    final terrain = <_TerrainMass>[
      _TerrainMass(-.18, -.15, .17, .09, .055),
      _TerrainMass(.06, -.08, .14, .08, .045),
      _TerrainMass(.18, .10, .13, .10, .050),
      _TerrainMass(-.10, .18, .12, .07, .038),
    ];

    final maxCount = island.main ? 4 : 2;
    for (var i = 0; i < maxCount; i++) {
      final t = terrain[i];
      final localX = t.x * island.scale;
      final localD = t.d * island.scale;
      final center = _project(
        size,
        c,
        island.x + localX,
        island.d + localD,
        island.height + t.h,
        yaw,
      );

      final w = size.width * t.w * island.scale;
      final h = size.height * t.h * .42;
      final hill = Path()
        ..moveTo(center.dx - w, center.dy + h * .35)
        ..quadraticBezierTo(center.dx - w * .55, center.dy - h,
            center.dx, center.dy - h * 1.25)
        ..quadraticBezierTo(center.dx + w * .72, center.dy - h * .75,
            center.dx + w, center.dy + h * .25)
        ..quadraticBezierTo(center.dx + w * .25, center.dy + h * .72,
            center.dx - w, center.dy + h * .35)
        ..close();

      final shadow = hill.shift(Offset(0, h * .32));
      canvas.drawPath(shadow, Paint()..color = const Color(0x40101915));

      canvas.drawPath(
        hill,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.38, -.55),
            radius: 1,
            colors: const [
              Color(0x765E6D5B),
              Color(0x3D394A3E),
              Color(0x10202D27),
            ],
          ).createShader(hill.getBounds()),
      );
    }

    // A few natural ridge planes; no dense map-like contour system.
    if (island.main) {
      final ridge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .0028
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x426E7968);

      final ridgeSets = [
        [Offset(-.25, -.13), Offset(-.08, -.20), Offset(.10, -.15)],
        [Offset(-.16, .08), Offset(.02, .01), Offset(.19, .08)],
        [Offset(-.04, .23), Offset(.09, .18), Offset(.20, .22)],
      ];

      for (final set in ridgeSets) {
        final path = Path();
        for (var i = 0; i < set.length; i++) {
          final p = set[i];
          final q = _project(
            size,
            c,
            island.x + p.dx * island.scale,
            island.d + p.dy * island.scale,
            island.height + .012,
            yaw,
          );
          if (i == 0) {
            path.moveTo(q.dx, q.dy);
          } else {
            path.quadraticBezierTo(
              (q.dx + path.getBounds().center.dx) / 2,
              q.dy,
              q.dx,
              q.dy,
            );
          }
        }
        canvas.drawPath(path, ridge);
      }
    }

    canvas.restore();
  }

  void _drawOceanAtmosphere(Canvas canvas, Size size, Offset c, double yaw) {
    final far = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0x223E6970),
          Colors.transparent,
          Color(0x2402070B),
        ],
        stops: const [.0, .44, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, far);

    final mist = Paint()
      ..shader = RadialGradient(
        center: Alignment(math.sin(yaw) * .12, -.20),
        radius: .85,
        colors: const [
          Colors.transparent,
          Color(0x123C6870),
          Color(0x2B02070A),
        ],
        stops: const [.42, .76, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, mist);

    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .003
      ..color = const Color(0x244C858A);
    final arc = Rect.fromCenter(
      center: c.translate(math.sin(yaw) * size.width * .03, size.height * .08),
      width: size.width * .82,
      height: size.height * .38,
    );
    canvas.drawArc(arc, math.pi * .08, math.pi * .84, false, light);
  }

  @override
  bool shouldRepaint(covariant _GameWorldPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.angle != angle;
}

class _WorldIsland {
  final double x;
  final double d;
  final double scale;
  final double height;
  final int seed;
  final bool main;
  final List<Offset> points;

  const _WorldIsland({
    required this.x,
    required this.d,
    required this.scale,
    required this.height,
    required this.seed,
    required this.points,
    this.main = false,
  });
}

class _TerrainMass {
  final double x;
  final double d;
  final double w;
  final double h;
  final double lift;

  const _TerrainMass(this.x, this.d, this.w, this.h, this.lift);
}
