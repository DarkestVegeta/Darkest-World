import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});

  @override
  State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String name;
  final String description;
  final List<GamePlatformGroup> groups;
  _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> {
  int? selected;

  late final List<_TerritoryData> territories = [
    _TerritoryData('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [
        GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]),
        GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130]),
      ]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [
        GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]),
        GamePlatform('DS', [20]), GamePlatform('3DS', [37]),
      ]),
    ]),
    _TerritoryData('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [
        GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23]),
      ]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'PlayStation generations.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [
        GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]),
        GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167]),
      ]),
    ]),
    _TerritoryData('XBOX', 'Xbox generations.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [
        GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169]),
      ]),
    ]),
  ];

  void enter(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GamePlatformPage(territory: territories[index].name, groups: territories[index].groups),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010307),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final diameter = math.min(constraints.maxWidth * .78, constraints.maxHeight * .78);

          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GameSpacePainter())),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 14 : 28),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
                      const SizedBox(width: 10),
                      const Text('GAME-WORLD', style: TextStyle(fontSize: 16, letterSpacing: 4)),
                      const Spacer(),
                      const Text('WORLD', style: TextStyle(fontSize: 8, letterSpacing: 3, color: Colors.white30)),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: GestureDetector(
                    onTapUp: (details) {
                      final hit = _hit(details.localPosition, diameter);
                      if (hit != null) setState(() => selected = selected == hit ? null : hit);
                    },
                    child: CustomPaint(
                      painter: _GamePlanetPainter(selected: selected),
                      child: Stack(
                        children: [
                          _label('NINTENDO', .29, .30, 0, diameter),
                          _label('SEGA', .71, .30, 1, diameter),
                          _label('PLAYSTATION', .29, .70, 2, diameter),
                          _label('XBOX', .71, .70, 3, diameter),
                          Center(
                            child: Opacity(
                              opacity: selected == null ? 1 : .18,
                              child: const Text('GAME-WORLD', style: TextStyle(fontSize: 12, letterSpacing: 5, color: Colors.white54)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (selected != null)
                Positioned(
                  left: compact ? 14 : 30,
                  right: compact ? 14 : 30,
                  bottom: compact ? 45 : 58,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxWidth: 620),
                      decoration: BoxDecoration(
                        color: const Color(0xE6090913),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x337F70B0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(territories[selected!].name, style: const TextStyle(fontSize: 13, letterSpacing: 3)),
                              const SizedBox(height: 5),
                              Text(territories[selected!].description, style: const TextStyle(fontSize: 9, color: Colors.white38)),
                            ],
                          )),
                          TextButton(onPressed: () => enter(selected!), child: const Text('ENTER')),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: compact ? 16 : 30,
                bottom: compact ? 18 : 26,
                child: Text(
                  selected == null ? 'SELECT A REGION' : 'SELECTED REGION  •  ENTER TO OPEN',
                  style: const TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white24),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text, double x, double y, int index, double diameter) {
    final alpha = selected == null || selected == index ? .70 : .16;
    return Positioned(
      left: diameter * x - 72,
      top: diameter * y - 25,
      width: 144,
      child: IgnorePointer(
        child: Center(child: Text(text, style: TextStyle(
          fontSize: selected == index ? 11 : 9,
          letterSpacing: 2.4,
          color: Colors.white.withValues(alpha: alpha),
        ))),
      ),
    );
  }

  int? _hit(Offset point, double diameter) {
    final origin = Offset(diameter / 2, diameter / 2);
    final radius = diameter * .49;
    const centers = [Offset(-.29, -.25), Offset(.29, -.25), Offset(-.29, .26), Offset(.29, .26)];
    for (var index = 0; index < 4; index++) {
      final center = origin + Offset(centers[index].dx * radius, centers[index].dy * radius);
      if ((point - center).distance < radius * .30) return index;
    }
    return null;
  }
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;
  const _GamePlanetPainter({required this.selected});

  static const centers = [
    Offset(-.29, -.25), Offset(.29, -.25), Offset(-.29, .26), Offset(.29, .26),
  ];
  static const terrain = [
    Color(0xFF8270A8), Color(0xFF59799C), Color(0xFF756C8F), Color(0xFF557D73),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .47;
    final sphere = Rect.fromCircle(center: origin, radius: radius);

    canvas.drawCircle(
      origin,
      radius * 1.16,
      Paint()..shader = const RadialGradient(colors: [Color(0x335F6E9A), Color(0x115F6E9A), Colors.transparent])
          .createShader(Rect.fromCircle(center: origin, radius: radius * 1.16)),
    );
    canvas.drawCircle(
      origin,
      radius,
      Paint()..shader = const RadialGradient(
        center: Alignment(-.38, -.45),
        radius: 1.08,
        colors: [Color(0xFF8B98AE), Color(0xFF45566C), Color(0xFF182331), Color(0xFF05070C)],
        stops: [.0, .38, .70, 1],
      ).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    final random = math.Random(442);

    for (var index = 0; index < 4; index++) {
      final center = origin + Offset(centers[index].dx * radius, centers[index].dy * radius);
      final color = terrain[index];
      final active = selected == null ? .17 : (selected == index ? .42 : .035);

      for (var n = 0; n < 11; n++) {
        final x = center.dx + (random.nextDouble() - .5) * radius * .42;
        final y = center.dy + (random.nextDouble() - .5) * radius * .32;
        final w = radius * (.12 + random.nextDouble() * .25);
        final h = radius * (.045 + random.nextDouble() * .10);
        final path = Path();
        for (var p = 0; p <= 8; p++) {
          final a = p / 8 * math.pi * 2;
          final wobble = .78 + random.nextDouble() * .34;
          final point = Offset(x + math.cos(a) * w * .5 * wobble, y + math.sin(a) * h * .5 * wobble);
          if (p == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, Paint()..color = color.withValues(alpha: active));
      }

      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * .48, height: radius * .26),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected == index ? 2.0 : 1.0
          ..color = color.withValues(alpha: selected == index ? .72 : .20),
      );
    }

    for (var i = 0; i < 24; i++) {
      final p = Offset(
        origin.dx + (random.nextDouble() * 2 - 1) * radius * .75,
        origin.dy + (random.nextDouble() * 2 - 1) * radius * .68,
      );
      canvas.drawCircle(p, radius * (.006 + random.nextDouble() * .018), Paint()..color = Colors.white.withValues(alpha: .035));
    }
    canvas.restore();

    canvas.drawCircle(
      origin + Offset(radius * .40, radius * .10),
      radius * .82,
      Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .58)])
          .createShader(Rect.fromCircle(center: origin + Offset(radius * .40, radius * .10), radius: radius * .82)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: radius * 1.012),
      math.pi * .66,
      math.pi * .78,
      false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = Colors.white.withValues(alpha: .20),
    );
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _GameSpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = const RadialGradient(
        center: Alignment(0, -.08), radius: 1.1,
        colors: [Color(0xFF15162A), Color(0xFF060710), Color(0xFF010205)],
      ).createShader(Offset.zero & size),
    );
    final random = math.Random(711);
    for (var index = 0; index < 220; index++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .2 + random.nextDouble() * .7,
        Paint()..color = Colors.white.withValues(alpha: .04 + random.nextDouble() * .10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => false;
}
