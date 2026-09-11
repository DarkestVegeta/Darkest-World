import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPage extends StatefulWidget {
  const GameWorldPage({super.key});

  @override
  State<GameWorldPage> createState() => _GameWorldPageState();
}

class _GameWorldStateData {
  static const nintendo = [
    GamePlatformGroup('HOME CONSOLES', 'Generations of Nintendo hardware.', [
      GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]),
      GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]),
      GamePlatform('Switch', [130]),
    ]),
    GamePlatformGroup('HANDHELD', 'Portable generations.', [
      GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]),
      GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]),
      GamePlatform('3DS', [37]),
    ]),
  ];

  static const sega = [
    GamePlatformGroup('CONSOLES', 'Sega hardware generations.', [
      GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]),
      GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23]),
    ]),
    GamePlatformGroup('PORTABLE', 'Sega handheld history.', [GamePlatform('Game Gear', [35])]),
  ];

  static const playstation = [
    GamePlatformGroup('PLAYSTATION GENERATIONS', 'Main PlayStation generations.', [
      GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]),
      GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]),
      GamePlatform('PlayStation 5', [167]),
    ]),
  ];

  static const xbox = [
    GamePlatformGroup('XBOX GENERATIONS', 'Microsoft console generations.', [
      GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]),
      GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169]),
    ]),
  ];
}

class _Territory {
  final String name;
  final String description;
  final int accent;
  final List<GamePlatformGroup> platforms;
  const _Territory(this.name, this.description, this.accent, this.platforms);
}

class _GameWorldPageState extends State<GameWorldPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 55),
  )..repeat();

  int? hovered;

  static const territories = [
    _Territory('NINTENDO', 'Forests, mountains, villages and strange old frontiers.', 0xFF8B73D6, _GameWorldStateData.nintendo),
    _Territory('SEGA', 'Energetic cities, deserts, arcades and unusual landscapes.', 0xFF4D82C4, _GameWorldStateData.sega),
    _Territory('PLAYSTATION', 'Fog, ruins, industry and darker unexplored territory.', 0xFF756A9E, _GameWorldStateData.playstation),
    _Territory('XBOX', 'A vast technological frontier beyond the old world.', 0xFF4F8A86, _GameWorldStateData.xbox),
  ];

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _openTerritory(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GamePlatformPage(
        territory: territories[index].name,
        groups: territories[index].platforms,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020307),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _motion,
                  builder: (_, __) => CustomPaint(
                    painter: _GameUniversePainter(_motion.value),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(compact ? 14 : 28, compact ? 14 : 22, compact ? 14 : 28, 0),
                  child: Row(
                    children: [
                      _BackButton(onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 12),
                      const Text(
                        'GAME-WORLD',
                        style: TextStyle(fontSize: 17, letterSpacing: 4.5, fontWeight: FontWeight.w400),
                      ),
                      const Spacer(),
                      Text(
                        'AERIAL VIEW',
                        style: TextStyle(fontSize: 8, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .30)),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: _WorldStage(
                  compact: compact,
                  territories: territories,
                  hovered: hovered,
                  onHover: (value) => setState(() => hovered = value),
                  onOpen: _openTerritory,
                  animation: _motion,
                ),
              ),
              Positioned(
                left: compact ? 18 : 30,
                bottom: compact ? 18 : 26,
                child: Text(
                  'THE WORLDS WHERE THE GAMES LIVE',
                  style: TextStyle(fontSize: 8, letterSpacing: 2.6, color: Colors.white.withValues(alpha: .22)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .28),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: .10)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 14),
        ),
      ),
    );
  }
}

class _WorldStage extends StatelessWidget {
  final bool compact;
  final List<_Territory> territories;
  final int? hovered;
  final ValueChanged<int?> onHover;
  final ValueChanged<int> onOpen;
  final Animation<double> animation;

  const _WorldStage({
    required this.compact,
    required this.territories,
    required this.hovered,
    required this.onHover,
    required this.onOpen,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = math.min(screen.width * (compact ? .98 : .90), 1280.0);
    final height = math.min(screen.height * (compact ? .72 : .76), 720.0);
    final center = Offset(width / 2, height / 2);
    final islandW = compact ? width * .38 : width * .31;
    final islandH = compact ? height * .34 : height * .39;
    final positions = [
      Offset(width * .25, height * .27),
      Offset(width * .75, height * .27),
      Offset(width * .25, height * .73),
      Offset(width * .75, height * .73),
    ];

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _OceanWorldPainter(animation.value),
            ),
          ),
          for (var i = 0; i < territories.length; i++)
            Positioned(
              left: positions[i].dx - islandW / 2,
              top: positions[i].dy - islandH / 2,
              child: _Island(
                territory: territories[i],
                width: islandW,
                height: islandH,
                hovered: hovered == i,
                onHover: (v) => onHover(v ? i : null),
                onTap: () => onOpen(i),
                seed: 40 + i * 91,
                animation: animation,
              ),
            ),
          Positioned(
            left: center.dx - (compact ? 62 : 78),
            top: center.dy - (compact ? 62 : 78),
            child: _CentralHub(
              compact: compact,
              hovered: hovered == null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CentralHub extends StatelessWidget {
  final bool compact;
  final bool hovered;
  const _CentralHub({required this.compact, required this.hovered});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 124.0 : 156.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: hovered ? 1 : .78,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _HubPainter()),
      ),
    );
  }
}

class _Island extends StatefulWidget {
  final _Territory territory;
  final double width;
  final double height;
  final bool hovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final int seed;
  final Animation<double> animation;

  const _Island({
    required this.territory,
    required this.width,
    required this.height,
    required this.hovered,
    required this.onHover,
    required this.onTap,
    required this.seed,
    required this.animation,
  });

  @override
  State<_Island> createState() => _IslandState();
}

class _IslandState extends State<_Island> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.hovered ? 1.035 : 1,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: widget.width,
            height: widget.height + 55,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IslandPainter(
                      accent: Color(widget.territory.accent),
                      seed: widget.seed,
                      highlighted: widget.hovered,
                      animation: widget.animation.value,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: widget.hovered ? 1 : .58,
                    child: Column(
                      children: [
                        Text(
                          widget.territory.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.hovered ? 12 : 10,
                            letterSpacing: 3.4,
                            color: Colors.white.withValues(alpha: widget.hovered ? .92 : .62),
                            fontWeight: FontWeight.w500,
                            shadows: const [Shadow(color: Colors.black, blurRadius: 12)],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'PLATFORM TERRITORY',
                          style: TextStyle(fontSize: 7, letterSpacing: 2.1, color: Colors.white.withValues(alpha: .27)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.hovered)
                  Positioned(
                    top: 8,
                    left: widget.width * .18,
                    right: widget.width * .18,
                    child: _IslandMoons(accent: Color(widget.territory.accent)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IslandMoons extends StatelessWidget {
  final Color accent;
  const _IslandMoons({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _MoonLabel('COLLECTION'),
        _MoonLabel('PLATFORMS'),
        _MoonLabel('MARATHONS'),
        _MoonLabel('STATS'),
      ],
    );
  }
}

class _MoonLabel extends StatelessWidget {
  final String text;
  const _MoonLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .11)),
      ),
      child: Text(text, style: TextStyle(fontSize: 6, letterSpacing: 1.2, color: Colors.white.withValues(alpha: .58))),
    );
  }
}

class _GameUniversePainter extends CustomPainter {
  final double t;
  const _GameUniversePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, 0),
          radius: 1.15,
          colors: [Color(0xFF14152A), Color(0xFF060711), Color(0xFF010205)],
        ).createShader(rect),
    );

    final nebula = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    final centers = [
      Offset(size.width * .23, size.height * .28),
      Offset(size.width * .78, size.height * .24),
      Offset(size.width * .26, size.height * .78),
      Offset(size.width * .75, size.height * .74),
    ];
    for (var i = 0; i < centers.length; i++) {
      nebula.color = (i.isEven ? const Color(0xFF6C58A8) : const Color(0xFF3E6792)).withValues(alpha: .028);
      canvas.drawCircle(centers[i] + Offset(math.sin(t * math.pi * 2 + i) * 16, 0), 150, nebula);
    }

    final stars = math.Random(711);
    final starPaint = Paint();
    for (var i = 0; i < 230; i++) {
      final x = stars.nextDouble() * size.width;
      final y = stars.nextDouble() * size.height;
      starPaint.color = Colors.white.withValues(alpha: .08 + stars.nextDouble() * .22);
      canvas.drawCircle(Offset(x, y), .3 + stars.nextDouble() * .75, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GameUniversePainter oldDelegate) => oldDelegate.t != t;
}

class _OceanWorldPainter extends CustomPainter {
  final double t;
  const _OceanWorldPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .40;
    final rings = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF7B79B8).withValues(alpha: .055);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2.15, height: radius * .88), rings);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 1.70, height: radius * .62), rings..color = const Color(0xFF587A9A).withValues(alpha: .045));

    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = const Color(0xFFB5A6D8).withValues(alpha: .025);
    for (var i = 0; i < 4; i++) {
      final phase = t * math.pi * 2 + i;
      final y = center.dy + math.sin(phase) * radius * .16;
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 2.6, height: radius * .32), math.pi, math.pi, false, route);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanWorldPainter oldDelegate) => oldDelegate.t != t;
}

class _HubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFB6A0FF).withValues(alpha: .24),
          const Color(0xFF655B9B).withValues(alpha: .10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r * 1.4));
    canvas.drawCircle(c, r * 1.35, glow);

    final orb = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.3, -.35),
        colors: [Color(0xFF4A436D), Color(0xFF141323), Color(0xFF03040A)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r * .70, orb);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFB2A2E5).withValues(alpha: .22);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 1.72, height: r * .58), ring);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 1.35, height: r * 1.02), ring..color = const Color(0xFF6E87B5).withValues(alpha: .12));

    final core = Paint()..color = Colors.white.withValues(alpha: .68);
    canvas.drawCircle(c, 2.1, core);
  }

  @override
  bool shouldRepaint(covariant _HubPainter oldDelegate) => false;
}

class _IslandPainter extends CustomPainter {
  final Color accent;
  final int seed;
  final bool highlighted;
  final double animation;

  _IslandPainter({
    required this.accent,
    required this.seed,
    required this.highlighted,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final center = Offset(size.width / 2, size.height * .48);
    final rx = size.width * .43;
    final ry = size.height * .38;

    final oceanShadow = Paint()
      ..color = accent.withValues(alpha: highlighted ? .12 : .075)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(0, 9), width: rx * 2.05, height: ry * 1.95), oceanShadow);

    final coast = _organicLandPath(center, rx, ry, random, 1.0);
    final coastPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF33423D).withValues(alpha: .98),
          accent.withValues(alpha: .58),
          const Color(0xFF111A1A),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(coast, coastPaint);

    final inner = _organicLandPath(center + const Offset(-3, -3), rx * .91, ry * .89, random, .8);
    canvas.drawPath(inner, Paint()..color = const Color(0xFF1A2925).withValues(alpha: .72));

    // Original terrain only: no logos, characters, copied landmarks or franchise assets.
    final terrain = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < 9; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * rx * .70;
      final y = center.dy + (random.nextDouble() * 2 - 1) * ry * .65;
      final w = 25 + random.nextDouble() * 75;
      final h = 8 + random.nextDouble() * 24;
      terrain.color = Colors.white.withValues(alpha: .035 + random.nextDouble() * .035);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h), terrain);
    }

    // Mountains.
    final mountain = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 5; i++) {
      final x = center.dx - rx * .65 + random.nextDouble() * rx * 1.3;
      final y = center.dy - ry * .50 + random.nextDouble() * ry * .75;
      final h = 12 + random.nextDouble() * 26;
      final w = 16 + random.nextDouble() * 30;
      final path = Path()
        ..moveTo(x - w, y)
        ..lineTo(x, y - h)
        ..lineTo(x + w, y)
        ..close();
      mountain.color = const Color(0xFF0B1415).withValues(alpha: .50);
      canvas.drawPath(path, mountain);
    }

    // Rivers / coast channels.
    final river = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF6E93A0).withValues(alpha: .25);
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startX = center.dx - rx * .55 + random.nextDouble() * rx * .2;
      path.moveTo(startX, center.dy - ry * .62);
      for (var p = 1; p <= 5; p++) {
        final px = startX + math.sin(p * 1.7 + seed) * 20 + p * 8;
        final py = center.dy - ry * .62 + p * ry * .25;
        path.lineTo(px, py);
      }
      canvas.drawPath(path, river);
    }

    // Small settlements as abstract lights, deliberately non-identifiable.
    final lights = Paint();
    for (var i = 0; i < 12; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * rx * .68;
      final y = center.dy + (random.nextDouble() * 2 - 1) * ry * .55;
      lights.color = Colors.white.withValues(alpha: highlighted ? .13 : .065);
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 1.4, lights);
    }

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 1.6 : 1
      ..color = accent.withValues(alpha: highlighted ? .48 : .18);
    canvas.drawPath(coast, rim);

    // Slow atmospheric light sweep.
    final sweepX = center.dx + math.sin(animation * math.pi * 2 + seed) * rx * .45;
    final sweep = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withValues(alpha: highlighted ? .055 : .018), Colors.transparent],
      ).createShader(Rect.fromLTWH(sweepX - 90, center.dy - ry, 180, ry * 2));
    canvas.drawPath(coast, sweep..style = PaintingStyle.fill);
  }

  Path _organicLandPath(Offset c, double rx, double ry, math.Random random, double variation) {
    final path = Path();
    const points = 18;
    for (var i = 0; i < points; i++) {
      final a = i / points * math.pi * 2;
      final wobble = .84 + random.nextDouble() * .24 * variation;
      final x = c.dx + math.cos(a) * rx * wobble;
      final y = c.dy + math.sin(a) * ry * wobble;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _IslandPainter oldDelegate) =>
      oldDelegate.highlighted != highlighted || oldDelegate.animation != animation;
}
