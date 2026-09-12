import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPage extends StatefulWidget {
  const GameWorldPage({super.key});
  @override State<GameWorldPage> createState() => _GameWorldPageState();
}

class _GameWorldData {
  static const nintendo = [
    GamePlatformGroup('HOME CONSOLES', 'Generations of Nintendo hardware.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
    GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
  ];
  static const sega = [
    GamePlatformGroup('CONSOLES', 'Sega hardware generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
    GamePlatformGroup('PORTABLE', 'Sega handheld history.', [GamePlatform('Game Gear', [35])]),
  ];
  static const playstation = [
    GamePlatformGroup('PLAYSTATION GENERATIONS', 'Main PlayStation generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])]),
  ];
  static const xbox = [
    GamePlatformGroup('XBOX GENERATIONS', 'Microsoft console generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])]),
  ];
}

class _Territory {
  final String name; final String description; final Color accent; final List<GamePlatformGroup> platforms;
  const _Territory(this.name, this.description, this.accent, this.platforms);
}

class _GameWorldPageState extends State<GameWorldPage> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(seconds: 48))..repeat();
  int? selected;

  static const territories = [
    _Territory('NINTENDO', 'A broad, older region of forests, ridges, coastlines and layered terrain.', Color(0xFF8174B7), _GameWorldData.nintendo),
    _Territory('SEGA', 'A weathered eastern region of dry plateaus, valleys and dense urban traces.', Color(0xFF537CA9), _GameWorldData.sega),
    _Territory('PLAYSTATION', 'A darker western region of cliffs, fog belts, ruins and industrial scars.', Color(0xFF746A92), _GameWorldData.playstation),
    _Territory('XBOX', 'A colder northern frontier with broad plains, rocky shelves and distant structures.', Color(0xFF4D817D), _GameWorldData.xbox),
  ];

  @override void dispose() { _motion.dispose(); super.dispose(); }

  void _openTerritory(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[index].name, groups: territories[index].platforms)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        return Stack(fit: StackFit.expand, children: [
          Positioned.fill(child: AnimatedBuilder(animation: _motion, builder: (_, __) => CustomPaint(painter: _GameSpacePainter(_motion.value)))),
          SafeArea(child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 30, compact ? 14 : 24, compact ? 14 : 30, 0),
            child: Row(children: [
              _BackButton(onTap: () => Navigator.of(context).pop()), const SizedBox(width: 12),
              const Text('GAME-WORLD', style: TextStyle(fontSize: 17, letterSpacing: 4.5, fontWeight: FontWeight.w400)), const Spacer(),
              Text('PLANETARY VIEW', style: TextStyle(fontSize: 8, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .28))),
            ]),
          )),
          Center(child: _GamePlanetStage(compact: compact, territories: territories, selected: selected, animation: _motion, onSelect: (value) => setState(() => selected = selected == value ? null : value))),
          if (selected != null) Positioned(left: compact ? 18 : 34, right: compact ? 18 : null, bottom: compact ? 18 : 34, width: compact ? null : 310, child: _TerritoryPanel(territory: territories[selected!], onClose: () => setState(() => selected = null), onOpen: () => _openTerritory(selected!))),
          Positioned(right: compact ? 18 : 30, bottom: compact ? 18 : 28, child: Text('ONE WORLD  ·  FOUR TERRITORIES', style: TextStyle(fontSize: 8, letterSpacing: 2.5, color: Colors.white.withValues(alpha: .20)))),
        ]);
      }),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap; const _BackButton({required this.onTap});
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.black.withValues(alpha: .30), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .10))), child: const Icon(Icons.arrow_back_ios_new, size: 14))));
}

class _GamePlanetStage extends StatelessWidget {
  final bool compact; final List<_Territory> territories; final int? selected; final Animation<double> animation; final ValueChanged<int> onSelect;
  const _GamePlanetStage({required this.compact, required this.territories, required this.selected, required this.animation, required this.onSelect});
  @override Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final diameter = math.min(screen.width * (compact ? .94 : .68), screen.height * (compact ? .68 : .78));
    return SizedBox(width: diameter, height: diameter, child: AnimatedBuilder(animation: animation, builder: (_, __) => Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: _PlanetSurfacePainter(animation.value, selected: selected)),
      for (var i = 0; i < territories.length; i++) _TerritoryHitRegion(territory: territories[i], index: i, selected: selected == i, muted: selected != null && selected != i, diameter: diameter, onTap: () => onSelect(i)),
    ])));
  }
}

class _TerritoryHitRegion extends StatelessWidget {
  final _Territory territory; final int index; final bool selected; final bool muted; final double diameter; final VoidCallback onTap;
  const _TerritoryHitRegion({required this.territory, required this.index, required this.selected, required this.muted, required this.diameter, required this.onTap});
  static const centers = [Offset(.30, .34), Offset(.69, .35), Offset(.31, .65), Offset(.68, .66)];
  @override Widget build(BuildContext context) {
    final center = centers[index]; final size = diameter * .43;
    return Positioned(left: diameter * center.dx - size / 2, top: diameter * center.dy - size / 2, child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: AnimatedOpacity(opacity: muted ? .18 : 1, duration: const Duration(milliseconds: 280), child: AnimatedScale(scale: selected ? 1.08 : 1, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic, child: SizedBox(width: size, height: size, child: CustomPaint(painter: _TerritoryPainter(territory: territory, seed: 80 + index * 53, selected: selected))))))));
  }
}

class _PlanetSurfacePainter extends CustomPainter {
  final double t; final int? selected; const _PlanetSurfacePainter(this.t, {required this.selected});
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2); final r = size.shortestSide * .455; final sphere = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r * 1.18, Paint()..shader = RadialGradient(colors: [const Color(0xFF556C9A).withValues(alpha: .16), const Color(0xFF283B68).withValues(alpha: .07), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.18)));
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.42, -.54), radius: 1.08, colors: [Color(0xFF6D7280), Color(0xFF354050), Color(0xFF18222E), Color(0xFF080C14), Color(0xFF010308)], stops: [.02, .24, .52, .78, 1]).createShader(sphere));
    canvas.save(); canvas.clipPath(Path()..addOval(sphere));
    final rnd = math.Random(4107);
    for (var i = 0; i < 90; i++) { final a = rnd.nextDouble() * math.pi * 2; final rr = math.sqrt(rnd.nextDouble()) * r * .94; final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr); canvas.drawCircle(p, .5 + rnd.nextDouble() * 2.2, Paint()..color = Colors.white.withValues(alpha: .008 + rnd.nextDouble() * .026)); }
    for (var i = 0; i < 8; i++) { final y = c.dy - r * .76 + i * r * .19; canvas.drawArc(Rect.fromCenter(center: Offset(c.dx - r * .04, y), width: r * 1.72, height: r * .28), .10, math.pi * .80, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .009..color = Colors.white.withValues(alpha: .012)); }
    canvas.restore();
    final night = c + Offset(r * .43, r * .12); canvas.drawCircle(night, r * .91, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .72)]).createShader(Rect.fromCircle(center: night, radius: r * .91)));
    canvas.drawArc(sphere.inflate(r * .008), math.pi * .60, math.pi * .88, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .013..color = Colors.white.withValues(alpha: selected == null ? .20 : .28));
    canvas.drawArc(sphere.inflate(r * .045), math.pi * 1.00, math.pi * .44, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = const Color(0xFF8A7AB8).withValues(alpha: .12));
    if (selected != null) canvas.drawCircle(c, r * 1.045, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = Colors.white.withValues(alpha: .13));
  }
  @override bool shouldRepaint(covariant _PlanetSurfacePainter oldDelegate) => oldDelegate.t != t || oldDelegate.selected != selected;
}

class _TerritoryPainter extends CustomPainter {
  final _Territory territory; final int seed; final bool selected;
  const _TerritoryPainter({required this.territory, required this.seed, required this.selected});
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2); final rnd = math.Random(seed); final w = size.width * .88; final h = size.height * .62; final rotation = (seed % 7 - 3) * .08; final path = _land(c, w, h, rotation, seed);
    canvas.save(); canvas.clipPath(path);
    final base = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawRect(base, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [territory.accent.withValues(alpha: selected ? .46 : .31), const Color(0xFF7A715E).withValues(alpha: .30), const Color(0xFF263D3A).withValues(alpha: .28)]).createShader(base));
    for (var layer = 1; layer <= 6; layer++) { final scale = 1 - layer * .095; final inner = _land(c + Offset(-size.width * .008 * layer, size.height * .006 * layer), w * scale, h * scale, rotation, seed + layer * 17); canvas.drawPath(inner, Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * .006..color = Colors.white.withValues(alpha: selected ? .038 : .022)); }
    for (var i = 0; i < 24; i++) { final x = c.dx + (rnd.nextDouble() * 2 - 1) * w * .45; final y = c.dy + (rnd.nextDouble() * 2 - 1) * h * .45; canvas.drawCircle(Offset(x, y), .4 + rnd.nextDouble() * 1.7, Paint()..color = Colors.white.withValues(alpha: .015 + rnd.nextDouble() * .025)); }
    for (var i = 0; i < 4; i++) { canvas.drawArc(Rect.fromCenter(center: c + Offset(0, -h * .03 + i * 2), width: w * (.54 - i * .06), height: h * (.42 - i * .045)), .22, 1.65, false, Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * .008..color = Colors.white.withValues(alpha: selected ? .032 : .018)); }
    canvas.restore();
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * (selected ? .017 : .010)..color = territory.accent.withValues(alpha: selected ? .62 : .22));
    final label = TextPainter(text: TextSpan(text: territory.name, style: TextStyle(color: Colors.white.withValues(alpha: selected ? .95 : .58), fontSize: size.width * .075, letterSpacing: 2.2, fontWeight: FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: size.width);
    label.paint(canvas, Offset(c.dx - label.width / 2, c.dy + h * .57));
  }
  Path _land(Offset center, double width, double height, double rotation, int localSeed) {
    final random = math.Random(localSeed * 19); const n = 18; final points = <Offset>[];
    for (var i = 0; i < n; i++) { final a = i / n * math.pi * 2; final wave = math.sin(a * 2 + localSeed) * .09 + math.sin(a * 3.7 + localSeed * .17) * .07 + math.sin(a * 6.3) * .035; final radius = .84 + wave + random.nextDouble() * .07; final x = math.cos(a) * width * .5 * radius; final y = math.sin(a) * height * .5 * (.90 + .10 * math.sin(a * 2.3 + localSeed)); points.add(center + Offset(x * math.cos(rotation) - y * math.sin(rotation), x * math.sin(rotation) + y * math.cos(rotation))); }
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < n; i++) { final a = points[i]; final b = points[(i + 1) % n]; final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2); path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy); }
    return path..close();
  }
  @override bool shouldRepaint(covariant _TerritoryPainter oldDelegate) => oldDelegate.seed != seed || oldDelegate.selected != selected || oldDelegate.territory.accent != territory.accent;
}

class _GameSpacePainter extends CustomPainter {
  final double t; const _GameSpacePainter(this.t);
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size; canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.05), radius: 1.2, colors: [Color(0xFF161528), Color(0xFF070812), Color(0xFF010207)]).createShader(rect));
    final stars = math.Random(711);
    for (var i = 0; i < 260; i++) { final p = Offset(stars.nextDouble() * size.width, stars.nextDouble() * size.height); canvas.drawCircle(p, .25 + stars.nextDouble() * .7, Paint()..color = Colors.white.withValues(alpha: .025 + stars.nextDouble() * .11)); }
    final haze = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)..color = const Color(0xFF61518D).withValues(alpha: .035);
    canvas.drawCircle(Offset(size.width * (.5 + math.sin(t * math.pi * 2) * .025), size.height * .48), size.shortestSide * .43, haze);
  }
  @override bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => oldDelegate.t != t;
}

class _TerritoryPanel extends StatelessWidget {
  final _Territory territory; final VoidCallback onClose; final VoidCallback onOpen;
  const _TerritoryPanel({required this.territory, required this.onClose, required this.onOpen});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xE9161722), Color(0xE8050810)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .10)), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 15))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Expanded(child: Text(territory.name, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2.4))), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17, color: Colors.white54))]),
      const SizedBox(height: 2), Container(width: 44, height: 1, color: territory.accent.withValues(alpha: .65)), const SizedBox(height: 10),
      Text(territory.description, style: const TextStyle(color: Colors.white54, height: 1.4)), const SizedBox(height: 14),
      Row(children: [TextButton(onPressed: onClose, child: const Text('Sluiten')), const Spacer(), ElevatedButton(onPressed: onOpen, child: const Text('Gebied openen'))]),
    ]),
  );
}
