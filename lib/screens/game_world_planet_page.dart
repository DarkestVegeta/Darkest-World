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
    // Scale hierarchy follows the reference-world feeling: one dominant landmass,
    // several substantial neighboring continents, and distant land fading into haze.
    _GameIsland('NINTENDO LAND', 'Forests · valleys · old stone · layered coast', -.18, .04, 1.28, 7, _nintendo),
    _GameIsland('SEGA REALM', 'Weathered ridges · dry plateaus · deep valleys', .34, -.22, .88, 19, _sega),
    _GameIsland('PLAYSTATION GALAXY', 'Cliffs · mist · ruins · crystalline terrain', -.42, .30, .92, 31, _playstation),
    _GameIsland('XBOX TERRITORY', 'Cold frontier · mineral shelves · distant lights', .28, .42, .76, 43, _xbox),
    _GameIsland('PC DIMENSION', 'Dark highlands · strange geometry · open expanses', .02, -.42, .70, 59, _pc),
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
    final diameter = math.min(size.width * (compact ? .88 : .72), size.height * .84);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: compact ? 20 : 30,
          left: compact ? 18 : 34,
          child: const _WorldHeader(title: 'GAME WORLD', eyebrow: 'LIVING WORLD · GAME ARCHIVE'),
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
    final sceneW = math.min(size.width * (compact ? 1.00 : .98), 1700.0);
    final sceneH = math.min(size.height * (compact ? .82 : .90), 980.0);

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
                      left: box.maxWidth * _islandScreenPosition(i).dx - box.maxWidth * _islandHitWidth(i) / 2,
                      top: box.maxHeight * _islandScreenPosition(i).dy - box.maxHeight * _islandHitHeight(i) / 2,
                      width: box.maxWidth * _islandHitWidth(i),
                      height: box.maxHeight * _islandHitHeight(i),
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
            'SELECT ISLAND · ENTER REALM',
            style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Colors.white.withValues(alpha: .22)),
          ),
        ),
      ],
    );
  }

  Offset _islandScreenPosition(int i) {
    const positions = [
      Offset(.41, .47),
      Offset(.67, .36),
      Offset(.29, .62),
      Offset(.66, .68),
      Offset(.49, .29),
    ];
    return positions[i];
  }

  double _islandHitWidth(int i) => .52 * islands[i].scale * (.92 + (islands[i].d + .50) * .34);

  double _islandHitHeight(int i) => .38 * islands[i].scale * (.92 + (islands[i].d + .50) * .34);
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
          colors: [Color(0xFF172C3D), Color(0xFF0A1525), Color(0xFF02040B)],
        ).createShader(rect),
    );

    _drawCloudOcean(canvas, size, c, phase);
    _drawDistantMountains(canvas, size, c);

    final ordered = [...List.generate(islands.length, (i) => i)]
      ..sort((a, b) => islands[b].d.compareTo(islands[a].d));

    for (final i in ordered) {
      _drawIsland(canvas, size, c, islands[i], i, selected == i);
    }

    // Multi-distance atmospheric veil: distant land fades, foreground stays readable.
    for (var layer = 0; layer < 5; layer++) {
      final t = layer / 4;
      final veil = Paint()
        ..shader = RadialGradient(
          center: Alignment(0, -.10 + t * .15),
          radius: .95,
          colors: [
            const Color(0x00000000),
            Color.fromARGB((10 + layer * 5), 88, 91, 128),
            const Color(0x0002060B),
          ],
          stops: const [.48, .78, 1],
        ).createShader(rect);
      canvas.drawRect(rect, veil);
    }
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0x209E9CFF), const Color(0x061D5060), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: size.shortestSide * .62));
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
        colors: const [Color(0xFF172E45), Color(0xFF0B1B31), Color(0xFF050A16)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, ocean);

    final mist = Paint()..color = const Color(0x20D8E8EA);
    for (var i = 0; i < 8; i++) {
      final x = size.width * (.05 + i * .105);
      final y = size.height * (.16 + math.sin(phase * math.pi * 2 + i) * .018);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: size.width * .18, height: size.height * .08),
        mist,
      );
    }

    final lines = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .001
      ..color = const Color(0x121E4C68);
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
    // Reference-faithful world plates: large, irregular natural landmasses.
    final center = Offset(
      c.dx + island.x * size.width * .50,
      c.dy + island.d * size.height * .39,
    );
    final depthScale = .92 + (island.d + .50) * .34;
    final w = size.width * .52 * island.scale * depthScale;
    final h = size.height * .38 * island.scale * depthScale;
    final random = math.Random(island.seed * 97 + 11);
    final points = <Offset>[];

    // Multi-frequency coastline noise avoids the old UI/blob silhouette.
    for (var i = 0; i < 30; i++) {
      final a = i / 30 * math.pi * 2;
      final n = .72 +
          random.nextDouble() * .28 +
          math.sin(a * 2.3 + island.seed) * .10 +
          math.sin(a * 5.1 + island.seed * .7) * .055 +
          math.sin(a * 9.7 + island.seed * .31) * .028;
      final asym = 1 + math.sin(a * 1.7 + island.seed) * .055;
      points.add(center + Offset(
        math.cos(a) * w * .5 * n * asym,
        math.sin(a) * h * .5 * n,
      ));
    }

    Path closed(List<Offset> ps) {
      final p = Path()..moveTo(ps.first.dx, ps.first.dy);
      for (final q in ps.skip(1)) p.lineTo(q.dx, q.dy);
      p.close();
      return p;
    }

    final top = closed(points);

    // Thick broken underside and visible cliff strata.
    final body = top.shift(Offset(-w * .018, h * .30));
    canvas.drawPath(body, Paint()..color = const Color(0xEE050C12));
    for (var layer = 0; layer < 7; layer++) {
      final t = layer / 7;
      final shifted = top.shift(Offset(-w * (.008 + t * .012), h * (.07 + t * .25)));
      canvas.drawPath(
        shifted,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, size.width * (.0045 - t * .00045))
          ..color = Color.lerp(const Color(0xAA42504E), const Color(0x00141B1D), t)!,
      );
    }

    final bounds = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-.75, -1),
          end: Alignment(.85, .9),
          colors: _terrainPalette(index),
        ).createShader(bounds),
    );

    // Dark water-facing coastal shelf.
    final shore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, size.width * .006)
      ..color = const Color(0x5B9EB8B0);
    final coast = closed([
      for (final p in points) center + (p - center) * .965,
    ]);
    canvas.drawPath(coast, shore);

    // Large terrain regions: plateaus, valleys and mountain masses.
    for (var region = 0; region < 9; region++) {
      final a = region * 2.21 + island.seed * .8;
      final rp = center + Offset(
        math.cos(a) * w * (.05 + (region % 4) * .085),
        math.sin(a * 1.19) * h * (.04 + (region % 3) * .075),
      );
      final rw = w * (.09 + (region % 3) * .045);
      final rh = h * (.07 + (region % 4) * .028);
      final path = Path();
      for (var k = 0; k < 12; k++) {
        final aa = k / 12 * math.pi * 2;
        final nn = .78 + .18 * math.sin(aa * 3 + region);
        final q = rp + Offset(math.cos(aa) * rw * nn, math.sin(aa) * rh * nn);
        if (k == 0) path.moveTo(q.dx, q.dy); else path.lineTo(q.dx, q.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = Colors.white.withValues(alpha: .025 + (region % 3) * .012),
      );
    }

    // Terrain is read through broad natural relief rather than map-like contour lines.
    // This keeps the image closer to a cinematic aerial environment than a strategy map.

    // Mountain chains with irregular massing and directional shadow, not triangular game icons.
    for (var m = 0; m < 9; m++) {
      final mx = center.dx + (-.38 + m * .092) * w;
      final base = center.dy + h * (.12 + (m % 3) * .025);
      final peak = base - h * (.13 + ((island.seed + m) % 5) * .036);
      final left = mx - w * (.065 + (m % 2) * .018);
      final right = mx + w * (.075 + ((m + 1) % 2) * .018);
      final mountain = Path()
        ..moveTo(left, base)
        ..quadraticBezierTo(mx - w * .018, peak + h * .035, mx, peak)
        ..quadraticBezierTo(mx + w * .028, peak + h * .045, right, base)
        ..close();
      canvas.drawPath(mountain, Paint()..color = Colors.white.withValues(alpha: .055 + (m % 2) * .018));
      canvas.drawPath(
        Path()..moveTo(mx, peak)..lineTo(right, base)..lineTo(mx + w * .02, base - h * .01),
        Paint()..color = Colors.black.withValues(alpha: .13),
      );
    }

    // Vegetation/rock clusters are sparse and scale-bearing rather than decorative icons.
    final vegetation = Paint()..color = const Color(0x3695AA91);
    for (var v = 0; v < 30; v++) {
      final a = v * 2.17 + island.seed;
      final rp = center + Offset(
        math.cos(a) * w * (.08 + (v % 6) * .055),
        math.sin(a * 1.37) * h * (.07 + (v % 5) * .045),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: rp,
          width: w * (.010 + (v % 4) * .008),
          height: h * (.015 + (v % 3) * .010),
        ),
        vegetation,
      );
    }

    // Directional environmental shadow makes the topography sit in the world.
    final shadow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.05, .65),
        radius: 1,
        colors: [Colors.black.withValues(alpha: .32), Colors.transparent],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + h * .24),
        width: w * 1.12,
        height: h * .60,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + h * .24), width: w * 1.12, height: h * .60),
      shadow,
    );

    // Atmospheric edge mist softens the distant shore without flattening the land.
    final mist = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0x401C4050)],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy - h * .05),
        width: w * 1.22,
        height: h * .92,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - h * .04), width: w * 1.18, height: h * .86),
      mist,
    );

    if (active) {
      _drawIdentityMarker(canvas, center, w, h, index, phase);

      final label = TextPainter(
        text: TextSpan(
          text: island.name,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .92),
            fontSize: math.max(8, size.width * .0085),
            letterSpacing: 2.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w * 1.5);
      label.paint(canvas, Offset(center.dx - label.width / 2, center.dy + h * .64));
      canvas.drawPath(
        top,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, size.width * .0028)
          ..color = Colors.white.withValues(alpha: .18),
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
    for (var i = 0; i < 190; i++) {
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
    final c=Offset(size.width/2,size.height/2);
    final r=size.shortestSide*.47;
    final sphere=Rect.fromCircle(center:c,radius:r);

    // Atmospheric volume: several restrained shells instead of a flat glow.
    for(var i=5;i>=0;i--){
      final rr=r*(1.03+i*.045);
      canvas.drawCircle(c,rr,Paint()..shader=RadialGradient(
        colors:[
          const Color(0x3C7568B8).withValues(alpha:.16-i*.018),
          const Color(0x183D83A1).withValues(alpha:.10-i*.012),
          Colors.transparent,
        ],
        stops:const[0,.58,1],
      ).createShader(Rect.fromCircle(center:c,radius:rr)));
    }

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Strong spherical light falloff.
    canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(
      center:Alignment(-.40,-.46),
      radius:1.02,
      colors:[
        Color(0xFF76679A),Color(0xFF43577D),Color(0xFF253855),
        Color(0xFF111B31),Color(0xFF030713),
      ],
      stops:[0,.19,.42,.72,1],
    ).createShader(sphere));

    // Large organic continental masses.
    final rnd=math.Random(4319);
    for(var i=0;i<18;i++){
      final a=rnd.nextDouble()*math.pi*2;
      final rr=math.sqrt(rnd.nextDouble())*r*.74;
      final p=c+Offset(math.cos(a)*rr,math.sin(a)*rr*.72);
      final w=r*(.08+rnd.nextDouble()*.25);
      final h=r*(.035+rnd.nextDouble()*.15);
      final land=Path();
      final n=11;
      for(var j=0;j<n;j++){
        final t=j*math.pi*2/n;
        final wob=.76+rnd.nextDouble()*.35;
        final q=Offset(math.cos(t)*w*.5*wob,math.sin(t)*h*.5*wob);
        if(j==0)land.moveTo(p.dx+q.dx,p.dy+q.dy);else land.lineTo(p.dx+q.dx,p.dy+q.dy);
      }
      land.close();
      final landColor=i%3==0?const Color(0x4B756B7B):const Color(0x43555D72);
      canvas.drawPath(land,Paint()..color=landColor);
      canvas.drawPath(land.shift(Offset(r*.008,r*.012)),Paint()..style=PaintingStyle.stroke..strokeWidth=r*.006..color=const Color(0x244B7B79));
    }

    // Surface relief: continental shelves, mountain belts and deep ocean basins.
    for(var i=0;i<11;i++){
      final y=c.dy-r*.56+i*r*.105;
      final p=Path()..moveTo(c.dx-r*.88,y);
      p.cubicTo(
        c.dx-r*.45,y-r*.055*math.sin(i+.8),
        c.dx-r*.08,y+r*.075*math.cos(i*.7),
        c.dx+r*.36,y-r*.05*math.sin(i*1.4),
      );
      p.cubicTo(c.dx+r*.55,y-r*.025,c.dx+r*.72,y+r*.025,c.dx+r*.88,y);
      canvas.drawPath(p,Paint()
        ..style=PaintingStyle.stroke
        ..strokeWidth=r*(.004+i*.0005)
        ..color=const Color(0x1F8AA6B0));
    }
    // A restrained night-side city shimmer gives scale without turning the planet into a starfield.
    for(var i=0;i<8;i++){
      final a=(i*2.31)+.4;
      final rr=r*(.30+(i%4)*.10);
      final p=c+Offset(math.cos(a)*rr,math.sin(a)*rr*.64);
      canvas.drawCircle(p,r*.006,Paint()..color=const Color(0x357D8ED0));
    }

    // Subtle surface lights: sparse, not a star field pasted on the planet.
    for(var i=0;i<16;i++){
      final a=rnd.nextDouble()*math.pi*2;
      final rr=math.sqrt(rnd.nextDouble())*r*.78;
      final p=c+Offset(math.cos(a)*rr,math.sin(a)*rr*.75);
      canvas.drawCircle(p,r*.008+rnd.nextDouble()*r*.012,Paint()..color=const Color(0x258F83C6));
    }

    // Spherical shadow and terminator.
    canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(
      center:Alignment(.54,.25),
      radius:1.0,
      colors:[Colors.transparent,Color(0x13020A14),Color(0xE900020A)],
      stops:[.42,.67,1],
    ).createShader(sphere));

    canvas.restore();

    // Fine atmospheric limb: broken, directional and volumetric rather than a neon ring.
    canvas.drawArc(
      Rect.fromCircle(center:c,radius:r*1.018),math.pi*1.03,math.pi*.88,false,
      Paint()..style=PaintingStyle.stroke..strokeWidth=r*.012..color=const Color(0x7E9185D5),
    );
    canvas.drawArc(
      Rect.fromCircle(center:c,radius:r*1.035),math.pi*1.22,math.pi*.34,false,
      Paint()..style=PaintingStyle.stroke..strokeWidth=r*.006..color=const Color(0x4C6E9DB7),
    );
    canvas.drawArc(
      Rect.fromCircle(center:c,radius:r*1.045),phase*math.pi*2+.3,math.pi*.42,false,
      Paint()..style=PaintingStyle.stroke..strokeWidth=r*.009..color=const Color(0x555CB9C4),
    );
  }

  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>oldDelegate.phase!=phase;
}