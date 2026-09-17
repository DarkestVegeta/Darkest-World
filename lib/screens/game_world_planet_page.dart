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
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(compact ? 18 : 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GAME-WORLD',
                  style: TextStyle(
                    color: Color(0xE8E8EDF1),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'GAME PLANET  /  SELECTED WORLD',
                  style: TextStyle(
                    color: Color(0x779DA7B6),
                    fontSize: 7,
                    letterSpacing: 2.5,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'CLICK PLANET  ·  ENTER GAME WORLD',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .52),
                      fontSize: compact ? 7 : 8,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Text(
                      '‹  GAME PLANET',
                      style: TextStyle(
                        color: Color(0xAFCBD2D9),
                        fontSize: 7,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'GAME WORLD',
                  style: TextStyle(
                    color: Color(0xE8E8EDF1),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'TOP-DOWN WORLD ATLAS',
                  style: TextStyle(
                    color: Color(0x779DA7B6),
                    fontSize: 7,
                    letterSpacing: 2.5,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'NINTENDO   ·   SEGA   ·   PLAYSTATION   ·   XBOX',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .42),
                      fontSize: compact ? 5 : 6,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
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
            Color(0xFF8797A1),
            Color(0xFF4C626D),
            Color(0xFF263640),
            Color(0xFF080D14),
          ],
          stops: [.05, .36, .70, 1],
        ).createShader(sphere),
    );

    final land = Paint()..color = const Color(0xB56C796C);
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .012
      ..color = const Color(0x6C9AA99B);

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
      ..color = const Color(0x477F969A);
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
    canvas.restore();

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .012
        ..color = const Color(0xA2AABBC2),
    );

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .012
      ..color = const Color(0x704D547F);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.055),
      phase * math.pi * 2,
      math.pi * .82,
      false,
      arc,
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

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(size.width * .015), Radius.circular(size.width * .035)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF172A30), Color(0xFF0A171B), Color(0xFF050A0D)],
        ).createShader(rect),
    );

    final water = Paint()..color = const Color(0xFF0B252B);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .82,
        height: size.height * .82,
      ),
      water,
    );

    _drawIsland(canvas, size, center, -0.30, 0.02, .34, .25, 1);
    _drawIsland(canvas, size, center, 0.25, -.08, .28, .31, 2);
    _drawIsland(canvas, size, center, .05, .32, .40, .17, 3);
    _drawIsland(canvas, size, center, -.47, .30, .17, .14, 4);

    _drawWaterLines(canvas, size, center);
    _drawWorldRoutes(canvas, size, center);
    _drawLandmarks(canvas, size, center);

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xC6000204)],
        stops: const [.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .006
      ..color = const Color(0x4F91A1A4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(size.width * .015), Radius.circular(size.width * .035)),
      edge,
    );
  }

  void _drawIsland(Canvas canvas, Size size, Offset center, double dx, double dy, double w, double h, int seed) {
    final islandCenter = Offset(
      center.dx + dx * size.width,
      center.dy + dy * size.height,
    );
    final islandSize = Size(size.width * w, size.height * h);
    final random = math.Random(seed * 97);
    final points = <Offset>[];
    const count = 22;
    for (var i = 0; i < count; i++) {
      final a = math.pi * 2 * i / count;
      final radius = .78 + random.nextDouble() * .22;
      points.add(Offset(
        islandCenter.dx + math.cos(a) * islandSize.width * .5 * radius,
        islandCenter.dy + math.sin(a) * islandSize.height * .5 * radius,
      ));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(
      path.shift(const Offset(0, 5)),
      Paint()..color = const Color(0x77000608),
    );
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF435C4A),
    );

    final inner = path.shift(const Offset(0, -2));
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .004
        ..color = const Color(0x5B8A9A7A),
    );

    final hill = Paint()..color = const Color(0xFF30463A);
    for (var i = 0; i < 7; i++) {
      final p = Offset(
        islandCenter.dx + (random.nextDouble() - .5) * islandSize.width * .65,
        islandCenter.dy + (random.nextDouble() - .5) * islandSize.height * .55,
      );
      canvas.drawCircle(p, size.width * (.008 + random.nextDouble() * .012), hill);
    }
  }

  void _drawWaterLines(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0015
      ..color = const Color(0x355B8E95);
    for (var i = -4; i <= 4; i++) {
      final path = Path();
      for (var j = 0; j <= 8; j++) {
        final x = center.dx + (j - 4) * size.width * .11;
        final y = center.dy + i * size.height * .065 + math.sin(j * .9 + i + phase * math.pi * 2) * 4;
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawWorldRoutes(Canvas canvas, Size size, Offset center) {
    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .004
      ..color = const Color(0x8F9A9B72);
    final paths = [
      [Offset(-.43, .06), Offset(-.18, .00), Offset(.02, .08), Offset(.28, -.04), Offset(.42, -.12)],
      [Offset(-.28, .24), Offset(-.08, .15), Offset(.12, .23), Offset(.32, .18)],
      [Offset(-.02, -.28), Offset(.04, -.10), Offset(.12, .10), Offset(.06, .32)],
    ];
    for (final points in paths) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = Offset(center.dx + points[i].dx * size.width, center.dy + points[i].dy * size.height);
        if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, route);
    }
  }

  void _drawLandmarks(Canvas canvas, Size size, Offset center) {
    final positions = [
      Offset(-.26, .01), Offset(.06, -.02), Offset(.25, -.10), Offset(.08, .24), Offset(-.10, .31), Offset(-.39, .05),
    ];
    final building = Paint()..color = const Color(0xB5A2A29A);
    final shadow = Paint()..color = const Color(0x66000304);
    for (var i = 0; i < positions.length; i++) {
      final p = Offset(center.dx + positions[i].dx * size.width, center.dy + positions[i].dy * size.height);
      final w = size.width * (.018 + (i % 3) * .006);
      final h = w * (1.0 + (i % 2) * .7);
      canvas.drawRect(Rect.fromLTWH(p.dx - w / 2 + 3, p.dy - h / 2 + 3, w, h), shadow);
      canvas.drawRect(Rect.fromLTWH(p.dx - w / 2, p.dy - h / 2, w, h), building);
    }
  }

  @override
  bool shouldRepaint(covariant _GameWorldPainter oldDelegate) => oldDelegate.phase != phase;
}
