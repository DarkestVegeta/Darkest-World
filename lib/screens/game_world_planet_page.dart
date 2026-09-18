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
                duration: const Duration(milliseconds: 850),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _insideWorld
                    ? _GameWorldView(
                        key: const ValueKey('world'),
                        phase: _clock.value,
                        onBack: _leaveWorld,
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
  final VoidCallback onBack;

  const _GameWorldView({super.key, required this.phase, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: LayoutBuilder(
            builder: (context, box) {
              final width = math.min(
                box.maxWidth * (compact ? .94 : .82),
                box.maxHeight * (compact ? .72 : .82),
              );
              return SizedBox(
                width: width,
                height: width * .72,
                child: CustomPaint(
                  painter: _GameWorldPainter(phase),
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
  const _GameWorldPainter(this.phase);

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

    _drawOceanContours(canvas, size, center);
    _drawMainLandmass(canvas, size, center);
    _drawSecondaryIslands(canvas, size, center);
    _drawCoastalDepth(canvas, size, center);
    _drawTerrainContours(canvas, size, center);
    _drawElevationRidges(canvas, size, center);
    _drawTerrainShadows(canvas, size, center);
    _drawWaterReflections(canvas, size, center);
    _drawWorldRoutes(canvas, size, center);
    _drawLandmarks(canvas, size, center);

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
    final path = Path()
      ..moveTo(
        center.dx + points.first.dx * size.width,
        center.dy + points.first.dy * size.height,
      );
    for (var i = 1; i < points.length; i++) {
      path.lineTo(
        center.dx + points[i].dx * size.width,
        center.dy + points[i].dy * size.height,
      );
    }
    path.close();
    return path;
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

  void _drawSecondaryIslands(Canvas canvas, Size size, Offset center) {
    final islands = [
      [Offset(.47, -.31), .13, .09, 1],
      [Offset(.39, .38), .14, .10, 2],
      [Offset(-.47, .30), .11, .075, 3],
      [Offset(-.42, -.27), .085, .065, 4],
      [Offset(.03, .46), .10, .06, 5],
    ];

    for (final data in islands) {
      final p = data[0] as Offset;
      final w = data[1] as double;
      final h = data[2] as double;
      final seed = data[3] as int;
      final c = Offset(
        center.dx + p.dx * size.width,
        center.dy + p.dy * size.height,
      );
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
        path.shift(Offset(0, size.height * .012)),
        Paint()..color = const Color(0x77000305),
      );
      canvas.drawPath(path, Paint()..color = const Color(0xFF46544A));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .004
          ..color = const Color(0x668E947F),
      );
    }
  }

  void _drawOceanContours(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0013
      ..color = const Color(0x385B8991);
    for (var ring = 0; ring < 5; ring++) {
      final rect = Rect.fromCenter(
        center: center.translate(
          math.sin(phase * math.pi * 2 + ring) * size.width * .003,
          0,
        ),
        width: size.width * (.30 + ring * .12),
        height: size.height * (.22 + ring * .11),
      );
      canvas.drawOval(rect, paint);
    }
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
