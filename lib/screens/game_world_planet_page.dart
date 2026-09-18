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

    // A restrained atmospheric halo: soft enough to feel like a planet,
    // not a glowing UI object.
    canvas.drawCircle(
      c,
      r * 1.18,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x3D625D93),
            Color(0x183D426E),
            Colors.transparent,
          ],
          stops: const [.58, .78, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.18)),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Base sphere volume.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.46, -.48),
          radius: 1.02,
          colors: [
            Color(0xFF73758B),
            Color(0xFF555970),
            Color(0xFF34394F),
            Color(0xFF171B2C),
            Color(0xFF050710),
          ],
          stops: [.02, .22, .48, .76, 1],
        ).createShader(sphere),
    );

    // Broad surface regions give the planet material variation without
    // becoming a literal Earth texture.
    final regions = <Path>[
      _planetRegion(sphere, [
        Offset(.13,.32), Offset(.22,.22), Offset(.38,.25), Offset(.47,.37),
        Offset(.39,.47), Offset(.25,.43), Offset(.15,.38),
      ]),
      _planetRegion(sphere, [
        Offset(.51,.16), Offset(.67,.18), Offset(.79,.30), Offset(.72,.43),
        Offset(.58,.39), Offset(.53,.29),
      ]),
      _planetRegion(sphere, [
        Offset(.32,.55), Offset(.46,.50), Offset(.57,.60), Offset(.53,.75),
        Offset(.39,.81), Offset(.27,.68),
      ]),
      _planetRegion(sphere, [
        Offset(.63,.53), Offset(.80,.52), Offset(.87,.65), Offset(.77,.77),
        Offset(.63,.70),
      ]),
    ];

    final land = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xB8A09AA4),
          Color(0x866D6B7B),
          Color(0x4C46495E),
        ],
      ).createShader(sphere);

    for (final path in regions) {
      canvas.drawPath(path, land);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .006
          ..color = const Color(0x2ECCC7D0),
      );
    }

    // Surface relief is broad and soft, like reflected terrain rather than
    // map lines.
    final relief = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.38, -.48),
        radius: .82,
        colors: const [
          Color(0x24FFFFFF),
          Color(0x0EFFFFFF),
          Colors.transparent,
        ],
        stops: const [0, .48, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, relief);

    for (var i = 0; i < 9; i++) {
      final y = sphere.top + sphere.height * (.16 + i * .082);
      final path = Path()..moveTo(sphere.left - r * .05, y);
      for (var j = 1; j <= 9; j++) {
        final x = sphere.left + sphere.width * j / 9;
        final wave = math.sin(i * 1.31 + j * .77 + phase * math.pi * 2) * r * .009;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .0035
          ..color = const Color(0x1A9A9DB4),
      );
    }

    // Controlled night-side falloff establishes the light direction and
    // gives the sphere a stronger three-dimensional terminator.
    final night = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.50, -.42),
        radius: 1.08,
        colors: [
          Colors.transparent,
          Color(0x1200050D),
          Color(0x6500040B),
          Color(0xE9000207),
        ],
        stops: [.42, .58, .78, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, night);

    // A subtle cool dawn band sits just inside the lit limb.
    final dawn = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0x183F5A78),
          Colors.transparent,
          Color(0x120B0E20),
        ],
        stops: [.0, .48, 1],
      ).createShader(sphere);
    canvas.drawCircle(c, r, dawn);

    // Soft cloud/atmospheric bands, deliberately sparse.
    for (var i = 0; i < 4; i++) {
      final y = sphere.top + sphere.height * (.27 + i * .14);
      final path = Path()..moveTo(sphere.left - r * .07, y);
      for (var j = 1; j <= 7; j++) {
        final x = sphere.left + sphere.width * j / 7;
        final wave = math.sin(i * 1.8 + j * .95 + phase * math.pi * 2) * r * .012;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .014
          ..color = const Color(0x142F3C62),
      );
    }

    canvas.restore();

    // Physical edge: brighter on the lit upper-left limb, nearly absent on
    // the night side.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .018
      ..color = const Color(0x706F7199);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.006),
      math.pi * 1.02,
      math.pi * .72,
      false,
      rim,
    );

    final violetRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .012
      ..color = const Color(0x805C4E89);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.045),
      phase * math.pi * 2 + math.pi * .25,
      math.pi * .64,
      false,
      violetRim,
    );
  }

  Path _planetRegion(Rect sphere, List<Offset> points) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(
        sphere.left + points[i].dx * sphere.width,
        sphere.top + points[i].dy * sphere.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else if (i == points.length - 1) {
        final prev = Offset(
          sphere.left + points[i - 1].dx * sphere.width,
          sphere.top + points[i - 1].dy * sphere.height,
        );
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        path.quadraticBezierTo(p.dx, p.dy, p.dx, p.dy);
      } else {
        final prev = Offset(
          sphere.left + points[i - 1].dx * sphere.width,
          sphere.top + points[i - 1].dy * sphere.height,
        );
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) =>
      oldDelegate.phase != phase;
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
    _drawWorldShadowField(canvas, size, c, yaw);

    final islands = <_WorldIsland>[
      _WorldIsland(
        x: 0,
        d: 0.02,
        scale: 1.0,
        height: .17,
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
      _WorldIsland(x: -.56, d: -.34, scale: .42, height: .105, seed: 11, points: const [
        Offset(-.52, -.12), Offset(-.25, -.36), Offset(.10, -.31),
        Offset(.40, -.12), Offset(.48, .12), Offset(.20, .33),
        Offset(-.18, .30), Offset(-.46, .17),
      ]),
      _WorldIsland(x: .57, d: -.28, scale: .34, height: .095, seed: 19, points: const [
        Offset(-.50, -.10), Offset(-.20, -.34), Offset(.22, -.28),
        Offset(.46, -.02), Offset(.35, .25), Offset(.02, .35),
        Offset(-.34, .25),
      ]),
      _WorldIsland(x: -.54, d: .42, scale: .31, height: .070, seed: 23, points: const [
        Offset(-.46, -.10), Offset(-.12, -.30), Offset(.31, -.20),
        Offset(.43, .08), Offset(.20, .29), Offset(-.28, .26),
      ]),
      _WorldIsland(x: .50, d: .47, scale: .27, height: .064, seed: 31, points: const [
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

    _drawWorldAtmosphereGlow(canvas, size, c, yaw);
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

    // Orbit changes both azimuth and apparent camera pitch. At the side
    // angles the far land compresses and the exposed cliff faces become
    // visibly taller, so the world reads as a volume rather than a map.
    final orbit = sy.abs();
    final pitch = .34 + orbit * .17;
    final depthScale = (1.0 - rd * perspective).clamp(.66, 1.30);
    final px = c.dx + rx * size.width * (.46 + orbit * .035) * depthScale;
    final py = c.dy
        + rd * size.height * pitch * depthScale
        - h * size.height * (1.10 + orbit * .24) * depthScale;
    return Offset(px, py);
  }

  void _drawOcean(Canvas canvas, Size size, Offset c, double yaw) {
    final deep = Paint()
      ..shader = RadialGradient(
        center: Alignment(.0, -.12),
        radius: 1.0,
        colors: const [
          Color(0xFF18343D),
          Color(0xFF0B2029),
          Color(0xFF040B11),
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
      ..strokeWidth = size.width * (island.main ? .006 : .004)
      ..color = const Color(0x70465A4B);
    canvas.drawPath(topPath, shelf);

    _drawIslandTerrain(canvas, size, c, island, yaw, topPath);
  }

  void _drawRaisedTerrainVolume(
    Canvas canvas,
    Size size,
    Offset c,
    _WorldIsland island,
    double yaw,
    Offset localCenter,
    double radiusX,
    double radiusD,
    double lift,
  ) {
    final top = <Offset>[];
    final bottom = <Offset>[];
    const steps = 10;
    for (var i = 0; i < steps; i++) {
      final a = (math.pi * 2 * i) / steps;
      final wobble = 1 + .08 * math.sin(a * 3 + island.seed);
      final lx = localCenter.dx + math.cos(a) * radiusX * wobble;
      final ld = localCenter.dy + math.sin(a) * radiusD * wobble;
      top.add(_project(
        size, c,
        island.x + lx * island.scale,
        island.d + ld * island.scale,
        island.height + lift,
        yaw,
        perspective: .24,
      ));
      bottom.add(_project(
        size, c,
        island.x + lx * island.scale,
        island.d + ld * island.scale,
        island.height + lift * .20,
        yaw,
        perspective: .24,
      ));
    }

    final face = Path();
    for (var i = 0; i < steps; i++) {
      final n = (i + 1) % steps;
      final p = top[i];
      final q = top[n];
      final depth = _depthOf(
        island,
        yaw,
      ) + math.sin((i + .5) * math.pi * 2 / steps) * .08;
      if (depth > -.03) {
        face.moveTo(p.dx, p.dy);
        face.lineTo(q.dx, q.dy);
        face.lineTo(bottom[n].dx, bottom[n].dy);
        face.lineTo(bottom[i].dx, bottom[i].dy);
        face.close();
      }
    }
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x554B5D4D),
            Color(0x8A17231F),
            Color(0xA5080F0E),
          ],
        ).createShader(face.getBounds()),
    );

    final plateau = Path()..moveTo(top.first.dx, top.first.dy);
    for (var i = 1; i < top.length; i++) {
      plateau.lineTo(top[i].dx, top[i].dy);
    }
    plateau.close();
    canvas.drawPath(
      plateau,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.45),
          radius: 1,
          colors: const [
            Color(0x806C7B68),
            Color(0x4A48594C),
            Color(0x17304338),
          ],
        ).createShader(plateau.getBounds()),
    );
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

    final terrain = island.main
        ? const [
            _TerrainMass(-.18, -.10, .24, .11, .085),
            _TerrainMass(.12, -.04, .19, .09, .070),
            _TerrainMass(.20, .16, .16, .075, .055),
            _TerrainMass(-.12, .20, .15, .065, .045),
          ]
        : const [
            _TerrainMass(0, 0, .18, .07, .040),
            _TerrainMass(.10, .10, .11, .05, .030),
          ];

    if (island.main) {
      _drawRaisedTerrainVolume(canvas, size, c, island, yaw,
          const Offset(-.16, -.08), .24, .18, .095);
      _drawRaisedTerrainVolume(canvas, size, c, island, yaw,
          const Offset(.15, .11), .18, .14, .072);
    } else {
      _drawRaisedTerrainVolume(canvas, size, c, island, yaw,
          const Offset(0, 0), .19, .15, .045);
    }

    final maxCount = island.main ? 2 : 1;
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
      final h = size.height * t.h * .65;
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
              Color(0x87687965),
              Color(0x3D394A3E),
              Color(0x10202D27),
            ],
          ).createShader(hill.getBounds()),
      );
    }

    // The raised terrain volumes above provide the island's main elevation.
    // Terrain depth is carried by actual raised volumes above; no contour-map overlay.
    canvas.restore();
  }

  void _drawWorldShadowField(Canvas canvas, Size size, Offset c, double yaw) {
    final shadow = Paint()
      ..shader = RadialGradient(
        center: Alignment(math.sin(yaw) * .10, .12),
        radius: .82,
        colors: const [
          Color(0x4201070A),
          Color(0x1D01070A),
          Colors.transparent,
        ],
        stops: const [.0, .48, 1],
      ).createShader(Offset.zero & size);
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(math.sin(yaw) * size.width * .02, size.height * .10),
        width: size.width * .82,
        height: size.height * .40,
      ),
      shadow,
    );
  }

  void _drawWorldAtmosphereGlow(Canvas canvas, Size size, Offset c, double yaw) {
    final glow = Paint()
      ..shader = RadialGradient(
        center: Alignment(-.18 + math.sin(yaw) * .12, -.30),
        radius: .72,
        colors: const [
          Color(0x163D6872),
          Color(0x092D5662),
          Colors.transparent,
        ],
        stops: const [.0, .52, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);
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