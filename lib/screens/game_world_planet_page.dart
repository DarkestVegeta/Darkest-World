import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

/// DARKest-World visual contract:
/// - Game World is the purple/blue living planet reference.
/// - Entering it reveals a large floating-island atlas.
/// - Islands are intentionally abstract: platform identity through landscape,
///   architecture and atmosphere, never famous game characters/scenes.
/// - This screen is the buildable 2D/3D-look layer; content comes from data.
class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});

  @override
  State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  )..repeat();

  bool _insideWorld = false;
  int? _selectedIsland;

  static const _islands = <_GameIsland>[
    _GameIsland('NINTENDO LAND', 'Forests · valleys · old stone · layered coast', .17, -.10, 1.00, 7, _nintendo),
    _GameIsland('SEGA REALM', 'Weathered ridges · dry plateaus · deep valleys', .48, -.18, .92, 19, _sega),
    _GameIsland('PLAYSTATION GALAXY', 'Cliffs · mist · ruins · crystalline terrain', -.47, .25, .88, 31, _playstation),
    _GameIsland('XBOX TERRITORY', 'Cold frontier · mineral shelves · distant lights', .35, .40, .82, 43, _xbox),
    _GameIsland('PC DIMENSION', 'Dark highlands · strange geometry · open expanses', -.30, -.43, .76, 59, _pc),
  ];

  static const _nintendo = <GamePlatformGroup>[
    GamePlatformGroup('HOME CONSOLES', 'Nintendo console generations.', [
      GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]),
      GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]),
      GamePlatform('Switch', [130]),
    ]),
    GamePlatformGroup('HANDHELD', 'Portable generations.', [
      GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]),
      GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37]),
    ]),
  ];

  static const _sega = <GamePlatformGroup>[
    GamePlatformGroup('CONSOLES', 'Sega hardware generations.', [
      GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]),
      GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23]),
    ]),
    GamePlatformGroup('PORTABLE', 'Sega handheld history.', [
      GamePlatform('Game Gear', [35]),
    ]),
  ];

  static const _playstation = <GamePlatformGroup>[
    GamePlatformGroup('PLAYSTATION GENERATIONS', 'Main PlayStation generations.', [
      GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]),
      GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]),
      GamePlatform('PlayStation 5', [167]),
    ]),
  ];

  static const _xbox = <GamePlatformGroup>[
    GamePlatformGroup('XBOX GENERATIONS', 'Microsoft console generations.', [
      GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]),
      GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169]),
    ]),
  ];

  static const _pc = <GamePlatformGroup>[
    GamePlatformGroup('PC ARCHIVE', 'PC platforms and eras.', [
      GamePlatform('Windows', []), GamePlatform('DOS', []), GamePlatform('Linux', []),
    ]),
  ];

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _enterWorld() => setState(() {
        _insideWorld = true;
        _selectedIsland = null;
      });

  void _leaveWorld() => setState(() {
        _insideWorld = false;
        _selectedIsland = null;
      });

  void _openIsland(int index) {
    final island = _islands[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePlatformPage(
          territory: island.name,
          groups: island.groups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _DeepSpacePainter(_clock.value)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: .88, end: 1).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _insideWorld
                  ? _IslandAtlas(
                      key: const ValueKey('game-world-atlas'),
                      phase: _clock.value,
                      selected: _selectedIsland,
                      islands: _islands,
                      onSelect: (i) => setState(() => _selectedIsland = _selectedIsland == i ? null : i),
                      onOpen: _openIsland,
                      onBack: _leaveWorld,
                    )
                  : _GamePlanetView(
                      key: const ValueKey('game-world-planet'),
                      phase: _clock.value,
                      onEnter: _enterWorld,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameIsland {
  final String name;
  final String subtitle;
  final double x;
  final double d;
  final double scale;
  final int seed;
  final List<GamePlatformGroup> groups;

  const _GameIsland(
    this.name,
    this.subtitle,
    this.x,
    this.d,
    this.scale,
    this.seed,
    this.groups,
  );
}

class _GamePlanetView extends StatelessWidget {
  final double phase;
  final VoidCallback onEnter;

  const _GamePlanetView({super.key, required this.phase, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final diameter = math.min(size.width * (compact ? .78 : .50), size.height * .68);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: compact ? 20 : 30,
          left: compact ? 18 : 34,
          child: const _WorldHeader(title: 'GAME WORLD', eyebrow: 'LIVING WORLD · ORBITAL ARCHIVE'),
        ),
        Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onEnter,
              child: SizedBox.square(
                dimension: diameter,
                child: CustomPaint(painter: _GamePlanetPainter(phase)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: compact ? 30 : 42,
          child: Column(
            children: [
              const Text(
                'GAME WORLD',
                style: TextStyle(fontSize: 18, letterSpacing: 5.2, color: Colors.white),
              ),
              const SizedBox(height: 7),
              Text(
                'ENTER THE WORLD',
                style: TextStyle(fontSize: 7, letterSpacing: 3.2, color: Colors.white.withValues(alpha: .42)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IslandAtlas extends StatelessWidget {
  final double phase;
  final int? selected;
  final List<_GameIsland> islands;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onOpen;
  final VoidCallback onBack;

  const _IslandAtlas({
    super.key,
    required this.phase,
    required this.selected,
    required this.islands,
    required this.onSelect,
    required this.onOpen,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 850;
    final sceneW = math.min(size.width * (compact ? .98 : .94), 1500.0);
    final sceneH = math.min(size.height * (compact ? .76 : .82), 860.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 30, compact ? 12 : 24, compact ? 14 : 30, 0),
            child: Row(
              children: [
                _BackButton(onTap: onBack),
                const SizedBox(width: 12),
                const _WorldHeader(title: 'GAME WORLD', eyebrow: 'ISLAND ATLAS · SELECT A REALM'),
                const Spacer(),
                if (!compact)
                  Text(
                    '5 WORLDS · NO ICONIC SCENES',
                    style: TextStyle(fontSize: 7, letterSpacing: 2.2, color: Colors.white.withValues(alpha: .28)),
                  ),
              ],
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: sceneW,
              height: sceneH,
              child: CustomPaint(
                painter: _IslandAtlasPainter(phase, selected, islands),
              ),
            ),
          ),
        ),
        // Large transparent hit zones keep the painter free of UI concerns.
        Center(
          child: SizedBox(
            width: sceneW,
            height: sceneH,
            child: LayoutBuilder(
              builder: (_, box) => Stack(
                children: [
                  for (var i = 0; i < islands.length; i++)
                    Positioned(
                      left: box.maxWidth * _islandScreenPosition(i).dx - box.maxWidth * .14,
                      top: box.maxHeight * _islandScreenPosition(i).dy - box.maxHeight * .13,
                      width: box.maxWidth * .28,
                      height: box.maxHeight * .26,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onSelect(i),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (selected != null)
          Positioned(
            left: compact ? 14 : 30,
            right: compact ? 14 : null,
            bottom: compact ? 14 : 30,
            width: compact ? null : 350,
            child: _IslandPanel(
              island: islands[selected!],
              onClose: () => onSelect(selected!),
              onOpen: () => onOpen(selected!),
            ),
          ),
        Positioned(
          right: compact ? 16 : 30,
          bottom: compact ? 18 : 30,
          child: Text(
            'DRAG / EXPLORE · SELECT / ENTER',
            style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Colors.white.withValues(alpha: .22)),
          ),
        ),
      ],
    );
  }

  Offset _islandScreenPosition(int i) {
    const positions = [
      Offset(.50, .43),
      Offset(.76, .31),
      Offset(.25, .64),
      Offset(.70, .70),
      Offset(.27, .28),
    ];
    return positions[i];
  }
}

class _IslandAtlasPainter extends CustomPainter {
  final double phase;
  final int? selected;
  final List<_GameIsland> islands;

  const _IslandAtlasPainter(this.phase, this.selected, this.islands);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.20),
          radius: 1.05,
          colors: [Color(0xFF203D45), Color(0xFF0B1B25), Color(0xFF02060B)],
        ).createShader(rect),
    );

    _drawCloudOcean(canvas, size, c, phase);
    _drawDistantMountains(canvas, size, c);

    final ordered = [...List.generate(islands.length, (i) => i)]
      ..sort((a, b) => islands[b].d.compareTo(islands[a].d));

    for (final i in ordered) {
      _drawIsland(canvas, size, c, islands[i], i, selected == i);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0x1C9E9CFF), const Color(0x071D5060), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: size.shortestSide * .58));
    canvas.drawRect(rect, glow);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, const Color(0xCC010307)],
          stops: const [.55, 1],
        ).createShader(rect),
    );
  }

  void _drawCloudOcean(Canvas canvas, Size size, Offset c, double phase) {
    final ocean = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF274E55), Color(0xFF0B2832), Color(0xFF06131B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, ocean);

    final mist = Paint()..color = const Color(0x20D8E8EA);
    for (var i = 0; i < 10; i++) {
      final x = size.width * (.08 + i * .105);
      final y = size.height * (.18 + math.sin(phase * math.pi * 2 + i) * .025);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: size.width * .18, height: size.height * .08),
        mist,
      );
    }

    final lines = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .001
      ..color = const Color(0x182F7781);
    for (var i = 0; i < 9; i++) {
      final y = size.height * (.20 + i * .075);
      canvas.drawLine(Offset(size.width * .05, y), Offset(size.width * .95, y + math.sin(i + phase * 6) * 5), lines);
    }
  }

  void _drawDistantMountains(Canvas canvas, Size size, Offset c) {
    final path = Path()..moveTo(0, size.height * .28);
    for (var i = 0; i <= 12; i++) {
      final x = size.width * i / 12;
      final y = size.height * (.22 + .055 * math.sin(i * 1.7));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height * .43);
    path.lineTo(0, size.height * .43);
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0x38111F25));
  }

  void _drawIsland(Canvas canvas, Size size, Offset c, _GameIsland island, int index, bool active) {
    final center = Offset(
      c.dx + island.x * size.width * .48,
      c.dy + island.d * size.height * .40,
    );
    final w = size.width * .30 * island.scale;
    final h = size.height * .20 * island.scale;
    final points = <Offset>[];
    final random = math.Random(island.seed);

    for (var i = 0; i < 18; i++) {
      final a = i / 18 * math.pi * 2;
      final wobble = .88 + random.nextDouble() * .14 + math.sin(a * 3 + island.seed) * .035;
      points.add(center + Offset(math.cos(a) * w * .5 * wobble, math.sin(a) * h * .5 * wobble));
    }

    final top = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      top.lineTo(p.dx, p.dy);
    }
    top.close();

    // Deep floating body: broad enough to read as a real island, not an icon.
    final body = top.shift(Offset(0, h * .28));
    canvas.drawPath(body, Paint()..color = const Color(0xD0061013));
    canvas.drawPath(
      Path.combine(PathOperation.difference, body, top),
      Paint()..color = const Color(0xA51B2928),
    );

    final terrainColors = _terrainPalette(index);
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: terrainColors,
        ).createShader(top.getBounds()),
    );

    // Layered relief — abstract terrain only.
    for (var layer = 0; layer < 5; layer++) {
      final shrink = 1 - layer * .105;
      final inner = Path();
      for (var i = 0; i < points.length; i++) {
        final p = center + (points[i] - center) * shrink;
        if (i == 0) {
          inner.moveTo(p.dx, p.dy);
        } else {
          inner.lineTo(p.dx, p.dy);
        }
      }
      inner.close();
      canvas.drawPath(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * (active ? .0024 : .0015)
          ..color = Colors.white.withValues(alpha: active ? .16 : .07),
      );
    }

    // Terrain masses, ridges and abstract structures.
    final terrain = Paint()..color = Colors.white.withValues(alpha: .10);
    for (var i = 0; i < 7; i++) {
      final a = i * 1.73 + island.seed;
      final p = center + Offset(math.cos(a) * w * .22, math.sin(a * 1.2) * h * .18);
      canvas.drawOval(
        Rect.fromCenter(center: p, width: w * (.10 + (i % 3) * .025), height: h * (.10 + (i % 2) * .025)),
        terrain,
      );
    }

    final ridge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .0022
      ..color = Colors.white.withValues(alpha: .075);
    for (var i = 0; i < 4; i++) {
      final p = Path()..moveTo(center.dx - w * .25, center.dy + (i - 1.5) * h * .08);
      p.cubicTo(
        center.dx - w * .06, center.dy - h * .14 + i * 5,
        center.dx + w * .10, center.dy + h * .12,
        center.dx + w * .28, center.dy - h * .03 + i * 4,
      );
      canvas.drawPath(p, ridge);
    }

    // Platform identity is atmospheric/architectural, not a famous game.
    _drawIdentityMarker(canvas, center, w, h, index, phase);

    final label = TextPainter(
      text: TextSpan(
        text: island.name,
        style: TextStyle(
          color: Colors.white.withValues(alpha: active ? .98 : .68),
          fontSize: math.max(8, size.width * .009),
          letterSpacing: 2.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w * 1.7);
    label.paint(canvas, Offset(center.dx - label.width / 2, center.dy + h * .63));

    if (active) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w * 1.10, height: h * 1.18),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .003
          ..color = Colors.white.withValues(alpha: .20),
      );
    }
  }

  List<Color> _terrainPalette(int index) {
    switch (index) {
      case 0:
        return const [Color(0xFF607A62), Color(0xFF385443), Color(0xFF233A34)];
      case 1:
        return const [Color(0xFF82745F), Color(0xFF564B43), Color(0xFF28302D)];
      case 2:
        return const [Color(0xFF667181), Color(0xFF424C5D), Color(0xFF242C3A)];
      case 3:
        return const [Color(0xFF4E706C), Color(0xFF294D50), Color(0xFF162A33)];
      default:
        return const [Color(0xFF5C6371), Color(0xFF393E50), Color(0xFF202435)];
    }
  }

  void _drawIdentityMarker(Canvas canvas, Offset center, double w, double h, int index, double phase) {
    final accent = [
      const Color(0xFFB7D3A8),
      const Color(0xFFD2A76E),
      const Color(0xFFA7B8D8),
      const Color(0xFF75B7A8),
      const Color(0xFF9E8FD0),
    ][index];
    final p = center + Offset(
      math.sin(phase * math.pi * 2 + index) * w * .025,
      -h * .10,
    );

    final glow = Paint()
      ..shader = RadialGradient(colors: [accent.withValues(alpha: .22), Colors.transparent])
          .createShader(Rect.fromCircle(center: p, radius: w * .16));
    canvas.drawCircle(p, w * .16, glow);
    canvas.drawCircle(p, w * .035, Paint()..color = accent.withValues(alpha: .72));

    if (index == 3) {
      canvas.drawRect(Rect.fromCenter(center: p, width: w * .09, height: h * .13), Paint()..color = accent.withValues(alpha: .16));
    } else if (index == 1) {
      canvas.drawPath(
        Path()
          ..moveTo(p.dx - w * .06, p.dy + h * .05)
          ..lineTo(p.dx, p.dy - h * .08)
          ..lineTo(p.dx + w * .06, p.dy + h * .05),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = accent.withValues(alpha: .30),
      );
    } else {
      canvas.drawCircle(p, w * .075, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = accent.withValues(alpha: .25));
    }
  }

  @override
  bool shouldRepaint(covariant _IslandAtlasPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.selected != selected;
}

class _IslandPanel extends StatelessWidget {
  final _GameIsland island;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _IslandPanel({required this.island, required this.onClose, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xEE070B12),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 34, offset: Offset(0, 16))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(island.name, style: const TextStyle(fontSize: 14, letterSpacing: 2.5))),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 16, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 2),
          Text(island.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.35)),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(onPressed: onClose, child: const Text('CLOSE')),
              const Spacer(),
              ElevatedButton(onPressed: onOpen, child: const Text('ENTER REALM')),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorldHeader extends StatelessWidget {
  final String title;
  final String eyebrow;

  const _WorldHeader({required this.title, required this.eyebrow});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, letterSpacing: 4.2, color: Colors.white)),
          const SizedBox(height: 4),
          Text(eyebrow, style: TextStyle(fontSize: 6.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: .32))),
        ],
      );
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .32),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .11)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
        ),
      );
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
          center: Alignment(0, -.1),
          radius: 1.1,
          colors: [Color(0xFF12152B), Color(0xFF050714), Color(0xFF010207)],
        ).createShader(rect),
    );

    final stars = math.Random(913);
    for (var i = 0; i < 320; i++) {
      final p = Offset(stars.nextDouble() * size.width, stars.nextDouble() * size.height);
      final pulse = .35 + .65 * math.sin(phase * math.pi * 2 + i * .41).abs();
      canvas.drawCircle(
        p,
        .25 + stars.nextDouble() * .75,
        Paint()..color = Colors.white.withValues(alpha: .025 + .07 * pulse),
      );
    }

    final nebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x2D7251A7),
          const Color(0x122D4D91),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * .52, size.height * .44),
        width: size.width * .95,
        height: size.height * .78,
      ));
    canvas.drawRect(rect, nebula);
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
    final r = size.shortestSide * .40;
    final sphere = Rect.fromCircle(center: c, radius: r);

    // Purple/blue living planet reference: luminous atmosphere, organic
    // continents and no literal Earth geography.
    canvas.drawCircle(
      c,
      r * 1.22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x668B6BFF).withValues(alpha: .34),
            const Color(0x333B8DCC),
            Colors.transparent,
          ],
          stops: const [0, .58, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.22)),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.42, -.48),
          radius: 1.05,
          colors: [
            Color(0xFF5C4A86),
            Color(0xFF30466F),
            Color(0xFF192A48),
            Color(0xFF090E1F),
            Color(0xFF02040C),
          ],
          stops: [.0, .22, .48, .76, 1],
        ).createShader(sphere),
    );

    final rnd = math.Random(2047);
    for (var i = 0; i < 34; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final rr = math.sqrt(rnd.nextDouble()) * r * .84;
      final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      final radius = r * (.018 + rnd.nextDouble() * .065);
      final accent = i.isEven ? const Color(0xFF8E65E9) : const Color(0xFF4ED6C8);
      canvas.drawCircle(
        p,
        radius,
        Paint()..color = accent.withValues(alpha: .10 + rnd.nextDouble() * .10),
      );
    }

    for (var i = 0; i < 8; i++) {
      final y = sphere.top + sphere.height * (.16 + i * .10);
      final p = Path()..moveTo(sphere.left, y);
      for (var j = 1; j <= 8; j++) {
        final x = sphere.left + sphere.width * j / 8;
        p.lineTo(x, y + math.sin(i * 1.2 + j * .9 + phase * 6) * r * .012);
      }
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .006
          ..color = const Color(0x204F8AD0),
      );
    }

    // Moving aurora-like atmospheric veins.
    for (var i = 0; i < 5; i++) {
      final p = Path()..moveTo(sphere.left - r * .05, c.dy + (i - 2) * r * .20);
      p.cubicTo(
        c.dx - r * .50,
        c.dy + math.sin(phase * 6 + i) * r * .10,
        c.dx + r * .15,
        c.dy + math.cos(phase * 5 + i) * r * .12,
        sphere.right + r * .05,
        c.dy + (i - 2) * r * .18,
      );
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .018
          ..color = (i.isEven ? const Color(0x405F48D6) : const Color(0x3046CFC2)),
      );
    }

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.45, -.45),
          radius: 1.1,
          colors: [Colors.transparent, Color(0x12000010), Color(0xE6000209)],
          stops: [.42, .65, 1],
        ).createShader(sphere),
    );

    canvas.restore();

    // Atmospheric limb.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.015),
      math.pi * 1.02,
      math.pi * .88,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .018
        ..color = const Color(0xA58E83E8),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.055),
      phase * math.pi * 2 + .2,
      math.pi * .55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .012
        ..color = const Color(0x7053C9D1),
    );
  }

  @override
  bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.phase != phase;
}
