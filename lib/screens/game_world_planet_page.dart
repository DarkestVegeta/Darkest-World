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
    final facing = math.cos(angle).abs();
    final turn = math.sin(angle);
    final depthX = .66 + .34 * facing;
    final depthY = .72 + .28 * facing;
    final cameraShiftX = yaw * size.width * .125;
    final cameraShiftY = turn * size.height * .052;
    final shear = yaw * .090;

    // Lightweight orbital camera: horizontal drag changes yaw, compresses
    // the far side and shifts the near side so the land reads as a volume.
    canvas.translate(center.dx + cameraShiftX, center.dy + cameraShiftY);
    canvas.scale(depthX, depthY);
    canvas.skew(shear, 0);
    canvas.translate(-center.dx, -center.dy);
    _drawOceanContours(canvas, size, center);
    _drawOceanDepthBands(canvas, size, center, angle);
    _drawOrbitalWorldHorizon(canvas, size, center, angle);
    _drawRotatedFarIslands(canvas, size, center, angle);
    _drawOrbitalIslandShadowPlane(canvas, size, center, angle);
    _drawSecondaryIslands(canvas, size, center);
    _drawFarHorizonMist(canvas, size, center, angle);
    _drawMainLandmassDepth(canvas, size, center, angle);
    _drawOrbitalLandmassSilhouette(canvas, size, center, angle);
    _drawOrbitalLandFaces(canvas, size, center, angle);
    _drawMainLandmass(canvas, size, center);
    _drawOrbitalMainIslandFace(canvas, size, center, angle);
    _drawOrbitalTerrainVolumes(canvas, size, center, angle);
    _drawNearTerrainLayers(canvas, size, center, angle);
    _drawOrbitalTerrainParallax(canvas, size, center, angle);
    _drawCoastalInlets(canvas, size, center);
    _drawCoastalShelves(canvas, size, center);
    _drawIslandMaterial(canvas, size, center);
    _drawCoastalDepth(canvas, size, center);
    _drawTerrainContours(canvas, size, center);
    _drawElevationRidges(canvas, size, center);
    _drawTerrainMasses(canvas, size, center);
    _drawTerrainEdgeFaces(canvas, size, center, angle);
    _drawTerrainHighlights(canvas, size, center);
    _drawTerrainShadows(canvas, size, center);
    _drawRaisedCliffs(canvas, size, center, angle);
    _drawWaterReflections(canvas, size, center);
    _drawOrbitalShorelineDepth(canvas, size, center, angle);
    _drawSpatialOcclusion(canvas, size, center, angle);
    _drawSpatialDepthFog(canvas, size, center, angle);
    _drawWorldMist(canvas, size, center);
    _drawWorldLightSweep(canvas, size, center);
    _drawNearForeground(canvas, size, center, angle);
    _drawWorldForegroundShelf(canvas, size, center, angle);
    _drawOrbitalLightDirection(canvas, size, center, angle);

    // A restrained near/far atmosphere layer sells the camera height
    // without turning the world into a flat map or HUD.
    final nearGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment(yaw * .10, .92),
        radius: 1.15,
        colors: const [
          Color(0x1B3B6870),
          Color(0x09233B43),
          Colors.transparent,
        ],
        stops: const [.0, .48, 1],
      ).createShader(rect);
    canvas.drawRect(rect, nearGlow);

    // Curved horizon haze: the world should read as a place with a horizon,
    // not a flat board viewed from above.
    final horizonArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.010 + facing * .004)
      ..color = Color(0x223F7375).withValues(alpha: .55 + facing * .25);
    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(yaw * size.width * .025, size.height * .075),
        width: size.width * (.82 + facing * .08),
        height: size.height * (.42 + facing * .10),
      ),
      math.pi * .10,
      math.pi * .80,
      false,
      horizonArc,
    );

    _drawWorldAtmosphericDepth(canvas, size, center, angle);
    canvas.restore();

    final atmosphere = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xB9000205)],
        stops: const [.57, 1],
      ).createShader(rect);
    canvas.drawRect(rect, atmosphere);

  }

  void _drawWorldAtmosphericDepth(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final farSide = yaw >= 0 ? -1.0 : 1.0;
    final horizon = Paint()
      ..shader = LinearGradient(
        begin: Alignment(0, farSide),
        end: Alignment(0, -farSide),
        colors: const [
          Color(0x1B6D8580),
          Colors.transparent,
          Color(0x12030A0C),
        ],
        stops: const [.0, .42, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, horizon);

    // A soft lower-world falloff gives the scene a spherical-world reading
    // without adding a visible UI frame around it.
    final limb = Paint()
      ..shader = RadialGradient(
        center: Alignment(yaw * .28, -.08),
        radius: .72,
        colors: const [
          Colors.transparent,
          Color(0x14000608),
          Color(0x3A000306),
        ],
        stops: const [.46, .78, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, limb);
  }

  void _drawFarHorizonMist(Canvas canvas, Size size, Offset center, double angle) {
    final far = math.max(0.0, math.sin(angle));
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x3A6B8B8D).withValues(alpha: .18 + far * .12),
          Colors.transparent,
        ],
        stops: const [.0, .42],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawOrbitalLandFaces(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .035) return;

    final dir = yaw.sign;
    final main = _landPath(size, center);

    // Draw the exposed side before the normal landmass: the silhouette now
    // behaves like lifted terrain instead of a flat shape sliding on water.
    final lowerFace = Paint()..color = const Color(0x7A101A17);
    final lowerEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.006 + amount * .010)
      ..color = const Color(0x52627262);

    for (var i = 3; i >= 1; i--) {
      final t = i / 3;
      canvas.drawPath(
        main.shift(Offset(
          dir * size.width * (.008 + amount * .020) * t,
          size.height * (.012 + amount * .030) * t,
        )),
        Paint()..color = Color(0x2A101713).withValues(alpha: .42 + t * .12),
      );
    }

    canvas.drawPath(
      main.shift(Offset(
        dir * size.width * (.014 + amount * .024),
        size.height * (.018 + amount * .040),
      )),
      lowerFace,
    );
    canvas.drawPath(
      main.shift(Offset(
        dir * size.width * (.010 + amount * .014),
        size.height * (.012 + amount * .024),
      )),
      lowerEdge,
    );

    // Raised interior terrain gets the same orbital side-face treatment.
    final masses = [
      [Offset(-.09, -.12), .095, .052],
      [Offset(.08, -.08), .082, .046],
      [Offset(.02, .10), .115, .055],
      [Offset(.16, .16), .072, .040],
    ];

    for (var i = 0; i < masses.length; i++) {
      final m = masses[i];
      final p = m[0] as Offset;
      final w = m[1] as double;
      final h = m[2] as double;
      final c = Offset(
        center.dx + p.dx * size.width,
        center.dy + p.dy * size.height,
      );
      final oval = Path()
        ..moveTo(c.dx - size.width * w, c.dy)
        ..quadraticBezierTo(
          c.dx,
          c.dy - size.height * h,
          c.dx + size.width * w,
          c.dy - size.height * h * .10,
        )
        ..quadraticBezierTo(
          c.dx + size.width * w * .38,
          c.dy + size.height * h,
          c.dx - size.width * w,
          c.dy,
        )
        ..close();

      final sideShift = Offset(
        dir * size.width * (.008 + amount * (.010 + i * .002)),
        size.height * (.012 + amount * .012),
      );
      canvas.drawPath(oval.shift(sideShift), Paint()..color = const Color(0x5C17211C));
      canvas.drawPath(
        oval.shift(Offset(
          dir * size.width * (.004 + amount * .006),
          size.height * (.006 + amount * .006),
        )),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .003
          ..color = const Color(0x3F647064),
      );
    }
  }

  void _drawRaisedCliffs(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final near = yaw >= 0 ? 1.0 : -1.0;
    final main = _landPath(size, center);
    final cliff = Paint()..color = const Color(0x8A17211D);
    final rock = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .018
      ..color = const Color(0x554D5B50);

    // A broad lower face makes the main island read as lifted terrain.
    canvas.drawPath(
      main.shift(Offset(near * size.width * .010, size.height * .026)),
      cliff,
    );
    canvas.drawPath(
      main.shift(Offset(near * size.width * .004, size.height * .012)),
      rock,
    );
  }

  void _drawSpatialOcclusion(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final edge = yaw.abs();
    final side = yaw >= 0 ? 1.0 : -1.0;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: side > 0
            ? [Colors.transparent, const Color(0x16000608)]
            : [const Color(0x16000608), Colors.transparent],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    if (edge > .28) {
      final veil = Paint()..color = const Color(0x1802080B).withValues(alpha: edge * .22);
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(-side * size.width * .22, size.height * .01),
          width: size.width * .34,
          height: size.height * .52,
        ),
        veil,
      );
    }
  }

  void _drawWorldForegroundShelf(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();

    final shelf = Path()
      ..moveTo(center.dx - size.width * .46, center.dy + size.height * .27)
      ..cubicTo(
        center.dx - size.width * .28, center.dy + size.height * (.34 + amount * .03),
        center.dx + size.width * .16, center.dy + size.height * (.36 + amount * .02),
        center.dx + size.width * .48, center.dy + size.height * .25,
      )
      ..cubicTo(
        center.dx + size.width * .38, center.dy + size.height * .34,
        center.dx - size.width * .27, center.dy + size.height * .36,
        center.dx - size.width * .46, center.dy + size.height * .27,
      );

    canvas.drawPath(
      shelf.shift(Offset(-yaw * size.width * .018, size.height * .018)),
      Paint()..color = const Color(0x5A020A0D),
    );
    canvas.drawPath(
      shelf,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x2D48625C),
            Color(0x180F2729),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .004
      ..color = const Color(0x254C7B78);
    canvas.drawPath(shelf, edge);
  }

  void _drawNearForeground(Canvas canvas, Size size, Offset center, double angle) {
    final side = math.sin(angle);
    final alpha = .10 + side.abs() * .08;
    final foreground = Paint()
      ..shader = RadialGradient(
        center: Alignment(side * .62, .92),
        radius: 1.0,
        colors: [
          Color(0x264B7072).withValues(alpha: alpha),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, foreground);
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
    final facing = math.cos(angle).abs();

    final islands = [
      (Offset(-.42, -.26), .050, .032, .72),
      (Offset(-.08, -.04), .075, .040, .88),
      (Offset(.30, .18), .060, .035, .78),
    ];

    for (var i = 0; i < islands.length; i++) {
      final item = islands[i];
      // Far islands compress and retreat during an orbit instead of
      // behaving like cards sliding around.
      final reveal = .82 - amount * .48 + (1.0 - facing) * .02;
      final x = item.$1.dx + dir * (.055 + i * .012) * amount;
      final y = item.$1.dy + (front - back) * (.028 + i * .010);
      final c = Offset(center.dx + x * size.width, center.dy + y * size.height);
      final w = size.width * item.$2 * reveal;
      final h = size.height * item.$3 * reveal * (.84 + .16 * facing);

      final depth = size.height * (.018 + amount * (.022 + i * .006));
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



  void _drawOrbitalIslandShadowPlane(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    final dir = yaw.sign;

    // Soft contact shadows move sideways with the camera. This gives the
    // islands a common ground plane and makes the orbit easier to read.
    final shadow = Paint()
      ..shader = RadialGradient(
        center: Alignment(-dir * .30, .0),
        radius: .75,
        colors: const [
          Color(0x26000406),
          Color(0x12000406),
          Colors.transparent,
        ],
        stops: const [.0, .52, 1],
      ).createShader(Offset.zero & size);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + dir * amount * size.width * .035,
          center.dy + size.height * .155,
        ),
        width: size.width * (.72 + amount * .06),
        height: size.height * (.25 + amount * .025),
      ),
      shadow,
    );
  }

  void _drawOrbitalTerrainParallax(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .04) return;

    final dir = yaw.sign;
    final near = math.max(0.0, yaw);
    final far = math.max(0.0, -yaw);

    // Foreground terrain advances while the opposite side retreats. The
    // movement is deliberately small so the scene stays grounded.
    final features = [
      [Offset(-.08, -.12), .090, .045],
      [Offset(.10, -.07), .075, .040],
      [Offset(.03, .11), .105, .050],
      [Offset(.15, .16), .062, .035],
    ];

    for (var i = 0; i < features.length; i++) {
      final f = features[i];
      final p = f[0] as Offset;
      final w = f[1] as double;
      final h = f[2] as double;
      final frontFactor = .70 + near * .42 - far * .16;
      final c = Offset(
        center.dx + (p.dx - dir * amount * (.010 + i * .002)) * size.width,
        center.dy + (p.dy + amount * (.010 + i * .002)) * size.height,
      );

      final rx = size.width * w * frontFactor;
      final ry = size.height * h * (1.0 + near * .10);
      final lift = size.height * (.010 + amount * (.018 + i * .003));

      final path = Path()
        ..moveTo(c.dx - rx, c.dy)
        ..quadraticBezierTo(
          c.dx - rx * .38,
          c.dy - ry,
          c.dx + rx,
          c.dy - ry * .08,
        )
        ..quadraticBezierTo(
          c.dx + rx * .35,
          c.dy + ry,
          c.dx - rx,
          c.dy,
        )
        ..close();

      final lower = path.shift(
        Offset(-dir * size.width * (.004 + amount * .008), lift),
      );
      canvas.drawPath(
        lower,
        Paint()..color = const Color(0x3E050B09),
      );

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0x3A92937B),
              Color(0x243E5146),
              Color(0x15202D28),
            ],
          ).createShader(path.getBounds()),
      );
    }
  }

  void _drawOrbitalLightDirection(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    final dir = yaw.sign;

    // One broad moving light/shadow relationship ties water, island and
    // terrain together while the camera turns.
    final light = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-.85 - dir * amount * .35, -.75),
        end: Alignment(.80 - dir * amount * .10, .70),
        colors: const [
          Color(0x1B9EAA98),
          Color(0x080B1613),
          Color(0x24000405),
        ],
        stops: const [.0, .54, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(
      Offset.zero & size,
      light,
    );

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.003 + amount * .002)
      ..color = const Color(0x1C7B9A92);

    final arcRect = Rect.fromCenter(
      center: Offset(
        center.dx - dir * amount * size.width * .03,
        center.dy + size.height * .05,
      ),
      width: size.width * (.74 + amount * .06),
      height: size.height * (.40 + amount * .04),
    );
    canvas.drawArc(arcRect, math.pi * .18, math.pi * .64, false, rim);
  }

  void _drawOrbitalWorldHorizon(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    final horizonY = center.dy - size.height * (.255 - amount * .018);

    final horizon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.004 + amount * .002)
      ..color = const Color(0x285A8587);

    final arcRect = Rect.fromCenter(
      center: Offset(center.dx - yaw * size.width * .025, horizonY),
      width: size.width * (.86 - amount * .08),
      height: size.height * (.25 + amount * .035),
    );
    canvas.drawArc(arcRect, math.pi * .10, math.pi * .80, false, horizon);

    // A second, softer atmospheric rim gives the water plane a distant edge.
    final haze = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.022 + amount * .010)
      ..color = const Color(0x112C666B);
    canvas.drawArc(
      arcRect.shift(Offset(0, size.height * .018)),
      math.pi * .12,
      math.pi * .76,
      false,
      haze,
    );
  }

  void _drawOrbitalMainIslandFace(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .035) return;

    final dir = yaw.sign;
    final base = _landPath(size, center);
    final sideDepth = size.height * (.022 + amount * .082);
    final sideShift = Offset(
      -dir * size.width * (.014 + amount * .028),
      sideDepth,
    );

    // Draw the lower silhouette first so the top landmass remains dominant.
    final lower = base.shift(sideShift);
    canvas.drawPath(
      lower,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x6A38483F),
            Color(0x9A18241F),
            Color(0xC1080E0D),
          ],
        ).createShader(lower.getBounds()),
    );

    // A narrow shelf between top and side face makes the extrusion readable
    // without turning the island into a block.
    final shelf = base.shift(
      Offset(
        -dir * size.width * (.008 + amount * .016),
        sideDepth * .48,
      ),
    );
    canvas.drawPath(
      shelf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (.009 + amount * .007)
        ..color = const Color(0x3E6B7766),
    );

    // Near-side edge highlight changes sides as the world turns.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.003 + amount * .003)
      ..color = const Color(0x507B8875);
    canvas.drawPath(
      base.shift(
        Offset(
          -dir * size.width * (.004 + amount * .009),
          sideDepth * .08,
        ),
      ),
      edge,
    );
  }

  void _drawOrbitalShorelineDepth(
    Canvas canvas,
    Size size,
    Offset center,
    double angle,
  ) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .06) return;

    final dir = yaw.sign;
    final main = _landPath(size, center);

    // Dark coastal band on the turning side: this is a lighting/occlusion cue
    // for the 3D turn, not a decorative outline around the whole island.
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.014 + amount * .018)
      ..color = const Color(0x3A071313);

    canvas.drawPath(
      main.shift(
        Offset(
          -dir * size.width * (.010 + amount * .020),
          size.height * (.012 + amount * .018),
        ),
      ),
      band,
    );

    final waterEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * (.004 + amount * .002)
      ..color = const Color(0x42658D8C);
    canvas.drawPath(
      main.shift(
        Offset(
          -dir * size.width * (.004 + amount * .010),
          size.height * (.004 + amount * .008),
        ),
      ),
      waterEdge,
    );
  }

  void _drawMainLandmassDepth(Canvas canvas, Size size, Offset center, double angle) {
    final amount = math.sin(angle).abs();
    if (amount < .015) return;
    final base = _landPath(size, center);
    final dir = math.sin(angle).sign;
    final lift = size.height * (.022 + amount * .065);

    // Deep lower shelf: the island moves through space, rather than only
    // changing its colour when the camera orbits.
    canvas.drawPath(
      base.shift(Offset(-dir * size.width * (.018 + amount * .018), lift)),
      Paint()..color = const Color(0xB8000103),
    );

    // Broad exposed face with a restrained upper highlight.
    canvas.drawPath(
      base.shift(Offset(-dir * size.width * (.010 + amount * .010), lift * .50)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (.019 + amount * .014)
        ..color = const Color(0x50182522),
    );
    canvas.drawPath(
      base.shift(Offset(-dir * size.width * (.004 + amount * .004), lift * .12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (.008 + amount * .006)
        ..color = const Color(0x507A8775),
    );
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
      final nearScale = 1.0 + amount * (.16 + i * .025);
      final w = size.width * item.$2 * nearScale;
      final h = size.height * item.$3 * (1.0 + amount * .10);
      final lift = size.height * (.012 + amount * (.032 + i * .008));

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

  void _drawOrbitalLandmassSilhouette(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .025) return;

    final dir = yaw.sign;
    final coast = _landPath(size, center);

    // Extruded lower rim: the top remains the same landmass, while the
    // offset face becomes visible during orbit.
    final extrusionX = -dir * size.width * (.012 + amount * .045);
    final extrusionY = size.height * (.014 + amount * .038);

    final face = coast.shift(Offset(extrusionX, extrusionY));
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x8A25332E),
            Color(0xA0131E1B),
            Color(0xC20A1010),
          ],
        ).createShader(Offset.zero & size),
    );

    final shelf = coast.shift(
      Offset(extrusionX * .55, extrusionY * .52),
    );
    canvas.drawPath(
      shelf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (.012 + amount * .010)
        ..color = const Color(0x4C53665B),
    );
  }

  void _drawSecondaryIslands(Canvas canvas, Size size, Offset center) {
    final angle = _currentAngle;
    final amount = math.sin(angle).abs();
    final dir = math.sin(angle).sign;
    final facing = math.cos(angle).abs();
    final islands = [
      [Offset(.47, -.31), .13, .09, 1],
      [Offset(.39, .38), .14, .10, 2],
      [Offset(-.47, .30), .11, .075, 3],
      [Offset(-.42, -.27), .085, .065, 4],
      [Offset(.03, .46), .10, .06, 5],
    ];

    // Paint far islands first and near islands last. Their depth order
    // changes with the camera angle, so the orbit can reveal real overlap.
    final ordered = [...islands]..sort((a, b) {
      final ao = a[0] as Offset;
      final bo = b[0] as Offset;
      final ay = ao.dy + ao.dx * math.sin(angle) * .34;
      final by = bo.dy + bo.dx * math.sin(angle) * .34;
      return ay.compareTo(by);
    });

    for (final data in ordered) {
      final base = data[0] as Offset;
      final w = data[1] as double;
      final h = data[2] as double;
      final seed = data[3] as int;
      final x = base.dx + dir * amount * (.028 + seed * .003);
      final y = base.dy + math.sin(angle) * (.014 + seed * .002);
      final verticalDepth = (1.0 - ((y + .5).clamp(0.0, 1.0)));
      final depthFactor = .70 + .30 * verticalDepth;
      final orbitFactor = .82 + .18 * facing;
      final wDepth = w * depthFactor * orbitFactor;
      final hDepth = h * depthFactor * (.86 + .14 * facing);
      final c = Offset(center.dx + x * size.width, center.dy + y * size.height);
      final depth = size.height * (.014 + amount * (.024 + seed * .0015));
      final random = math.Random(seed * 173);
      final path = Path();
      const count = 18;
      for (var i = 0; i < count; i++) {
        final a = math.pi * 2 * i / count;
        final jitter = .82 + random.nextDouble() * .18;
        final point = Offset(
          c.dx + math.cos(a) * size.width * wDepth * jitter,
          c.dy + math.sin(a) * size.height * hDepth * jitter,
        );
        if (i == 0) path.moveTo(point.dx, point.dy);
        else path.lineTo(point.dx, point.dy);
      }
      path.close();

      final farFade = .72 + .28 * facing;
      canvas.drawPath(
        path.shift(Offset(-dir * size.width * (.006 + amount * .010), depth)),
        Paint()..color = const Color(0x88000305).withValues(alpha: .53 + .35 * farFade),
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
      [Offset(-.09, -.12), .095, .052, .12],
      [Offset(.08, -.08), .082, .046, .08],
      [Offset(.02, .10), .115, .055, .10],
      [Offset(.16, .16), .072, .040, .06],
    ];

    for (var i = 0; i < masses.length; i++) {
      final m = masses[i];
      final p = m[0] as Offset;
      final w = m[1] as double;
      final h = m[2] as double;
      final lift = m[3] as double;

      final c = Offset(
        center.dx + p.dx * size.width,
        center.dy + p.dy * size.height - size.height * lift * .08,
      );

      final shadow = Path()
        ..moveTo(c.dx - size.width * w, c.dy)
        ..quadraticBezierTo(
          c.dx,
          c.dy - size.height * h,
          c.dx + size.width * w,
          c.dy - size.height * h * .10,
        )
        ..quadraticBezierTo(
          c.dx + size.width * w * .38,
          c.dy + size.height * h,
          c.dx - size.width * w,
          c.dy,
        );

      // Each terrain mass gets a visible lower face instead of only a flat oval.
      canvas.drawPath(
        shadow.shift(Offset(size.width * .004, size.height * .012)),
        Paint()..color = const Color(0x50111B17),
      );

      final top = shadow.shift(Offset(0, -size.height * (.006 + i * .002)));
      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0x5A7D7C68),
              Color(0x394E584A),
              Color(0x1E27342D),
            ],
          ).createShader(Rect.fromCenter(
            center: c,
            width: size.width * w * 2.2,
            height: size.height * h * 2.2,
          )),
      );

      // Small upper shelf: gives the terrain a readable raised plateau.
      final shelf = top.shift(Offset(-size.width * .003, -size.height * .006));
      canvas.drawPath(
        shelf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * (.0035 + i * .0004)
          ..color = const Color(0x357E866F),
      );
    }
  }

  void _drawOrbitalTerrainVolumes(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .035) return;
    final dir = yaw.sign;

    final masses = [
      [Offset(-.09, -.12), .095, .052],
      [Offset(.08, -.08), .082, .046],
      [Offset(.02, .10), .115, .055],
      [Offset(.16, .16), .072, .040],
    ];

    for (var i = 0; i < masses.length; i++) {
      final m = masses[i];
      final p = m[0] as Offset;
      final w = m[1] as double;
      final h = m[2] as double;
      final c = Offset(
        center.dx + (p.dx - dir * amount * .012) * size.width,
        center.dy + (p.dy + amount * .010) * size.height,
      );
      final faceDepth = size.height * (.010 + amount * (.024 + i * .003));
      final face = Path()
        ..moveTo(c.dx - size.width * w, c.dy + size.height * h * .18)
        ..quadraticBezierTo(c.dx, c.dy + size.height * h * .12,
            c.dx + size.width * w, c.dy - size.height * h * .08)
        ..lineTo(c.dx + size.width * w - dir * size.width * amount * .012,
            c.dy - size.height * h * .08 + faceDepth)
        ..quadraticBezierTo(c.dx, c.dy + size.height * h * .12 + faceDepth,
            c.dx - size.width * w - dir * size.width * amount * .012,
            c.dy + size.height * h * .18 + faceDepth)
        ..close();

      canvas.drawPath(face, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x5A34443B), Color(0x8B18231F), Color(0xA00A1110)],
        ).createShader(face.getBounds()));
      canvas.drawPath(face, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (.0025 + amount * .002)
        ..color = const Color(0x3E58685A));
    }
  }

  void _drawTerrainEdgeFaces(Canvas canvas, Size size, Offset center, double angle) {
    final yaw = math.sin(angle);
    final amount = yaw.abs();
    if (amount < .04) return;

    final dir = yaw.sign;
    final face = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * (.010 + amount * .012)
      ..color = const Color(0x42202D28);

    final lower = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * (.004 + amount * .004)
      ..color = const Color(0x365D6A5D);

    // Interior plateaus expose a darker vertical lip as the world turns.
    final paths = [
      [Offset(-.20, -.12), Offset(-.08, -.18), Offset(.05, -.14)],
      [Offset(-.10, .04), Offset(.02, .00), Offset(.15, .05)],
      [Offset(-.07, .18), Offset(.04, .14), Offset(.14, .18)],
    ];

    for (final points in paths) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(
          center.dx + (points[i].dx - dir * amount * .010) * size.width,
          center.dy + (points[i].dy + amount * .008) * size.height,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path.shift(Offset(-dir * size.width * .006, size.height * (.010 + amount * .018))), face);
      canvas.drawPath(path.shift(Offset(-dir * size.width * .002, size.height * (.004 + amount * .008))), lower);
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

  void _drawSpatialDepthFog(Canvas canvas, Size size, Offset center, double angle) {
    final turn = math.sin(angle);
    final far = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x183C5660).withValues(alpha: .18 + math.max(0.0, -turn) * .10),
          Colors.transparent,
          const Color(0x10263D42).withValues(alpha: .12 + math.max(0.0, turn) * .08),
        ],
        stops: const [.0, .46, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, far);
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