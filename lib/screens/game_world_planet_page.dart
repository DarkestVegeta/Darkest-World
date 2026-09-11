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
    _TerritoryData(
      'NINTENDO',
      'Nintendo generations.',
      [
        GamePlatformGroup(
          'HOME CONSOLES',
          'Home generations.',
          [
            GamePlatform('NES', [18]),
            GamePlatform('SNES', [19]),
            GamePlatform('N64', [4]),
            GamePlatform('GameCube', [21]),
            GamePlatform('Wii', [5]),
            GamePlatform('Wii U', [41]),
            GamePlatform('Switch', [130]),
          ],
        ),
        GamePlatformGroup(
          'HANDHELD',
          'Portable generations.',
          [
            GamePlatform('Game Boy', [33]),
            GamePlatform('Game Boy Color', [22]),
            GamePlatform('Game Boy Advance', [24]),
            GamePlatform('DS', [20]),
            GamePlatform('3DS', [37]),
          ],
        ),
      ],
    ),
    _TerritoryData(
      'SEGA',
      'Sega generations.',
      [
        GamePlatformGroup(
          'CONSOLES',
          'Console generations.',
          [
            GamePlatform('Master System', [64]),
            GamePlatform('Mega Drive', [29]),
            GamePlatform('Saturn', [32]),
            GamePlatform('Dreamcast', [23]),
          ],
        ),
        GamePlatformGroup(
          'PORTABLE',
          'Portable generation.',
          [GamePlatform('Game Gear', [35])],
        ),
      ],
    ),
    _TerritoryData(
      'PLAYSTATION',
      'PlayStation generations.',
      [
        GamePlatformGroup(
          'GENERATIONS',
          'Main generations.',
          [
            GamePlatform('PlayStation', [7]),
            GamePlatform('PlayStation 2', [8]),
            GamePlatform('PlayStation 3', [9]),
            GamePlatform('PlayStation 4', [48]),
            GamePlatform('PlayStation 5', [167]),
          ],
        ),
      ],
    ),
    _TerritoryData(
      'XBOX',
      'Xbox generations.',
      [
        GamePlatformGroup(
          'GENERATIONS',
          'Main generations.',
          [
            GamePlatform('Xbox', [11]),
            GamePlatform('Xbox 360', [12]),
            GamePlatform('Xbox One', [49]),
            GamePlatform('Xbox Series', [169]),
          ],
        ),
      ],
    ),
  ];

  void enter(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePlatformPage(
          territory: territories[index].name,
          groups: territories[index].groups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010307),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final diameter = math.min(
            constraints.maxWidth * .70,
            constraints.maxHeight * .82,
          );

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _GameSpacePainter()),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 14 : 28),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'GAME-WORLD',
                        style: TextStyle(fontSize: 16, letterSpacing: 4),
                      ),
                      const Spacer(),
                      const Text(
                        'WORLD',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 3,
                          color: Colors.white30,
                        ),
                      ),
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
                      if (hit != null) {
                        setState(() => selected = selected == hit ? null : hit);
                      }
                    },
                    child: CustomPaint(
                      painter: _GamePlanetPainter(selected: selected),
                      child: Stack(
                        children: [
                          _label('NINTENDO', .30, .28, 0, diameter),
                          _label('SEGA', .70, .30, 1, diameter),
                          _label('PLAYSTATION', .29, .70, 2, diameter),
                          _label('XBOX', .71, .69, 3, diameter),
                          Center(
                            child: Opacity(
                              opacity: selected == null ? 1 : .22,
                              child: const Text(
                                'GAME-WORLD',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 5,
                                  color: Colors.white54,
                                ),
                              ),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  territories[selected!].name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  territories[selected!].description,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => enter(selected!),
                            child: const Text('ENTER'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: compact ? 16 : 30,
                bottom: compact ? 18 : 26,
                child: Text(
                  selected == null
                      ? 'SELECT A REGION'
                      : 'SELECTED REGION  •  ENTER TO OPEN',
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.4,
                    color: Colors.white24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text, double x, double y, int index, double diameter) {
    double alpha = .18;
    if (selected == null || selected == index) alpha = .68;

    return Positioned(
      left: diameter * x - 70,
      top: diameter * y - 25,
      width: 140,
      child: IgnorePointer(
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: selected == index ? 11 : 9,
              letterSpacing: 2.4,
              color: Colors.white.withValues(alpha: alpha),
            ),
          ),
        ),
      ),
    );
  }

  int? _hit(Offset point, double diameter) {
    final origin = Offset(diameter / 2, diameter / 2);
    final radius = diameter * .49;
    const centers = [
      Offset(-.30, -.25),
      Offset(.30, -.24),
      Offset(-.30, .27),
      Offset(.30, .27),
    ];

    for (var index = 0; index < 4; index++) {
      final center = origin +
          Offset(centers[index].dx * radius, centers[index].dy * radius);
      if ((point - center).distance < radius * .30) return index;
    }
    return null;
  }
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;

  const _GamePlanetPainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .47;
    final rect = Rect.fromCircle(center: origin, radius: radius);

    canvas.drawCircle(
      origin,
      radius * 1.10,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x335F6E9A), Colors.transparent],
        ).createShader(
          Rect.fromCircle(center: origin, radius: radius * 1.1),
        ),
    );

    canvas.drawCircle(
      origin,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.38, -.42),
          radius: 1.05,
          colors: [
            Color(0xFF667996),
            Color(0xFF26364B),
            Color(0xFF080D16),
          ],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final random = math.Random(442);
    const colors = [
      Color(0xFF806BB5),
      Color(0xFF5077A8),
      Color(0xFF756E9C),
      Color(0xFF4E817D),
    ];
    const centers = [
      Offset(-.30, -.25),
      Offset(.30, -.24),
      Offset(-.30, .27),
      Offset(.30, .27),
    ];

    for (var index = 0; index < 4; index++) {
      double alpha = .025;
      if (selected == null) alpha = .12;
      if (selected == index) alpha = .34;

      final center = origin +
          Offset(centers[index].dx * radius, centers[index].dy * radius);

      for (var n = 0; n < 7; n++) {
        final offset = Offset(
          (random.nextDouble() - .5) * radius * .34,
          (random.nextDouble() - .5) * radius * .28,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: center + offset,
            width: radius * (.22 + random.nextDouble() * .24),
            height: radius * (.08 + random.nextDouble() * .12),
          ),
          Paint()..color = colors[index].withValues(alpha: alpha),
        );
      }

      double borderAlpha = .18;
      if (selected == index) borderAlpha = .62;

      canvas.drawCircle(
        center,
        radius * .19,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected == index ? 2 : 1
          ..color = colors[index].withValues(alpha: borderAlpha),
      );
    }

    canvas.restore();

    canvas.drawCircle(
      origin + Offset(radius * .40, radius * .08),
      radius * .78,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: .48)],
        ).createShader(
          Rect.fromCircle(
            center: origin + Offset(radius * .40, radius * .08),
            radius: radius * .78,
          ),
        ),
    );

    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: radius * 1.01),
      math.pi * .68,
      math.pi * .72,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white24,
    );
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _GameSpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFF15162A),
            Color(0xFF060710),
            Color(0xFF010205),
          ],
        ).createShader(Offset.zero & size),
    );

    final random = math.Random(711);
    for (var index = 0; index < 220; index++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        .2 + random.nextDouble() * .7,
        Paint()
          ..color = Colors.white.withValues(
            alpha: .04 + random.nextDouble() * .10,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => false;
}
