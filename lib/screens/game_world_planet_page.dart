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

  const _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> {
  int? selected;

  static const territories = <_TerritoryData>[
    _TerritoryData(
      'NINTENDO',
      'Forests, mountains, villages and old frontiers.',
      [
        GamePlatformGroup('HOME CONSOLES', 'Nintendo home generations.', [
          GamePlatform('NES', [18]),
          GamePlatform('SNES', [19]),
          GamePlatform('N64', [4]),
          GamePlatform('GameCube', [21]),
          GamePlatform('Wii', [5]),
          GamePlatform('Wii U', [41]),
          GamePlatform('Switch', [130]),
        ]),
        GamePlatformGroup('HANDHELD', 'Portable generations.', [
          GamePlatform('Game Boy', [33]),
          GamePlatform('Game Boy Color', [22]),
          GamePlatform('Game Boy Advance', [24]),
          GamePlatform('DS', [20]),
          GamePlatform('3DS', [37]),
        ]),
      ],
    ),
    _TerritoryData(
      'SEGA',
      'Dry plains, strange cities and arcade country.',
      [
        GamePlatformGroup('CONSOLES', 'Sega generations.', [
          GamePlatform('Master System', [64]),
          GamePlatform('Mega Drive', [29]),
          GamePlatform('Saturn', [32]),
          GamePlatform('Dreamcast', [23]),
        ]),
        GamePlatformGroup('PORTABLE', 'Sega handheld.', [
          GamePlatform('Game Gear', [35]),
        ]),
      ],
    ),
    _TerritoryData(
      'PLAYSTATION',
      'Fog, ruins, industry and darker unexplored ground.',
      [
        GamePlatformGroup('GENERATIONS', 'Main PlayStation generations.', [
          GamePlatform('PlayStation', [7]),
          GamePlatform('PlayStation 2', [8]),
          GamePlatform('PlayStation 3', [9]),
          GamePlatform('PlayStation 4', [48]),
          GamePlatform('PlayStation 5', [167]),
        ]),
      ],
    ),
    _TerritoryData(
      'XBOX',
      'A vast frontier beyond the older territories.',
      [
        GamePlatformGroup('GENERATIONS', 'Xbox generations.', [
          GamePlatform('Xbox', [11]),
          GamePlatform('Xbox 360', [12]),
          GamePlatform('Xbox One', [49]),
          GamePlatform('Xbox Series', [169]),
        ]),
      ],
    ),
  ];

  void openTerritory(int index) {
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
        builder: (context, box) {
          final compact = box.maxWidth < 760;
          final diameter = math.min(
            box.maxWidth * (compact ? 0.86 : 0.62),
            box.maxHeight * (compact ? 0.66 : 0.76),
          );

          return Stack(
            children: [
              const Positioned.fill(
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
                      Text(
                        'TERRITORIES',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 2.5,
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTapUp: (details) {
                    final hit = _hit(details.localPosition, diameter);
                    if (hit != null) {
                      setState(() => selected = selected == hit ? null : hit);
                    }
                  },
                  child: SizedBox(
                    width: diameter,
                    height: diameter,
                    child: CustomPaint(
                      painter: _GamePlanetPainter(
                        selected: selected,
                        diameter: diameter,
                      ),
                      child: Stack(
                        children: [
                          _label('NINTENDO', 0.29, 0.30, 0, diameter),
                          _label('SEGA', 0.70, 0.30, 1, diameter),
                          _label('PLAYSTATION', 0.30, 0.70, 2, diameter),
                          _label('XBOX', 0.70, 0.70, 3, diameter),
                          Center(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: selected == null ? 1 : 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'GAME',
                                      style: TextStyle(
                                        fontSize: compact ? 15 : 20,
                                        letterSpacing: 7,
                                        color: Colors.white.withValues(alpha: 0.70),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'WORLD',
                                      style: TextStyle(
                                        fontSize: 8,
                                        letterSpacing: 5,
                                        color: Colors.white.withValues(alpha: 0.28),
                                      ),
                                    ),
                                  ],
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
                  bottom: compact ? 52 : 62,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxWidth: 620),
                      decoration: BoxDecoration(
                        color: const Color(0xE6090913),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x227F70B0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  territories[selected!].name,
                                  style: const TextStyle(fontSize: 13, letterSpacing: 3),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  territories[selected!].description,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white.withValues(alpha: 0.40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => openTerritory(selected!),
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
                      ? 'SELECT A TERRITORY'
                      : 'SELECTED TERRITORY • ENTER TO OPEN',
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.4,
                    color: Colors.white.withValues(alpha: 0.22),
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
    return Positioned(
      left: diameter * x - 65,
      top: diameter * y - 25,
      width: 130,
      child: IgnorePointer(
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: selected == index ? 11 : 9,
              letterSpacing: 2.4,
              color: Colors.white.withValues(
                alpha: selected != null && selected != index ? 0.18 : 0.66,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int? _hit(Offset point, double diameter) {
    final center = Offset(diameter / 2, diameter / 2);
    final radius = diameter * 0.49;
    const regions = <Offset>[
      Offset(-0.31, -0.25),
      Offset(0.31, -0.24),
      Offset(-0.30, 0.27),
      Offset(0.29, 0.27),
    ];

    for (var i = 0; i < regions.length; i++) {
      final target = center + Offset(regions[i].dx * radius, regions[i].dy * radius);
      if ((point - target).distance < radius * 0.28) {
        return i;
      }
    }
    return null;
  }
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;
  final double diameter;

  const _GamePlanetPainter({required this.selected, required this.diameter});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = diameter * 0.49;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius * 1.05,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x226679A5), Colors.transparent],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius * 1.08),
        ),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.34, -0.38),
          radius: 1.05,
          colors: [Color(0xFF2B3B50), Color(0xFF172538), Color(0xFF070D16)],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    const regions = <Offset>[
      Offset(-0.31, -0.25),
      Offset(0.31, -0.24),
      Offset(-0.30, 0.27),
      Offset(0.29, 0.27),
    ];
    const colors = <int>[0xFF8B73D6, 0xFF4D82C4, 0xFF756A9E, 0xFF4F8A86];

    for (var i = 0; i < regions.length; i++) {
      final regionCenter = center + Offset(regions[i].dx * radius, regions[i].dy * radius);
      final shape = Rect.fromCenter(
        center: regionCenter,
        width: radius * 0.62,
        height: radius * 0.48,
      );
      final active = selected == i;
      final alpha = selected == null ? 0.07 : active ? 0.25 : 0.015;

      canvas.drawOval(
        shape,
        Paint()..color = Color(colors[i]).withValues(alpha: alpha),
      );

      if (selected == null || active) {
        canvas.drawOval(
          shape,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = active ? 2 : 1
            ..color = Color(colors[i]).withValues(alpha: active ? 0.60 : 0.20),
        );
      }
    }

    canvas.restore();

    canvas.drawCircle(
      center + Offset(radius * 0.38, radius * 0.08),
      radius * 0.80,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.34)],
        ).createShader(
          Rect.fromCircle(
            center: center + Offset(radius * 0.38, radius * 0.08),
            radius: radius * 0.80,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _GameSpacePainter extends CustomPainter {
  const _GameSpacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF15162A), Color(0xFF060710), Color(0xFF010205)],
        ).createShader(Offset.zero & size),
    );

    final random = math.Random(711);
    final paint = Paint();
    for (var i = 0; i < 240; i++) {
      paint.color = Colors.white.withValues(alpha: 0.04 + random.nextDouble() * 0.12);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.2 + random.nextDouble() * 0.7,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => false;
}
