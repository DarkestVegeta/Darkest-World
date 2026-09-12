import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String name, description;
  final List<GamePlatformGroup> groups;
  _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> {
  int? selected;

  late final territories = <_TerritoryData>[
    _TerritoryData('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES',[18]),GamePlatform('SNES',[19]),GamePlatform('N64',[4]),GamePlatform('GameCube',[21]),GamePlatform('Wii',[5]),GamePlatform('Wii U',[41]),GamePlatform('Switch',[130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy',[33]),GamePlatform('Game Boy Color',[22]),GamePlatform('Game Boy Advance',[24]),GamePlatform('DS',[20]),GamePlatform('3DS',[37])]),
    ]),
    _TerritoryData('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System',[64]),GamePlatform('Mega Drive',[29]),GamePlatform('Saturn',[32]),GamePlatform('Dreamcast',[23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear',[35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'PlayStation generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation',[7]),GamePlatform('PlayStation 2',[8]),GamePlatform('PlayStation 3',[9]),GamePlatform('PlayStation 4',[48]),GamePlatform('PlayStation 5',[167])])]),
    _TerritoryData('XBOX', 'Xbox generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox',[11]),GamePlatform('Xbox 360',[12]),GamePlatform('Xbox One',[49]),GamePlatform('Xbox Series',[169])])]),
  ];

  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].name, groups: territories[i].groups)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010307),
    body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 760;
      final d = math.min(box.maxWidth * .86, box.maxHeight * .86);
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GameSpacePainter())),
        SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 28), child: Row(children: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
          const SizedBox(width: 10),
          const Text('GAME-WORLD', style: TextStyle(fontSize: 16, letterSpacing: 4)),
          const Spacer(),
          const Text('WORLD', style: TextStyle(fontSize: 8, letterSpacing: 3, color: Colors.white30)),
        ]))),
        Center(child: SizedBox(
          width: d, height: d,
          child: GestureDetector(
            onTapUp: (e) { final h = _hit(e.localPosition, d); if (h != null) setState(() => selected = selected == h ? null : h); },
            child: CustomPaint(
              painter: _GamePlanetPainter(selected: selected),
              child: Stack(children: [
                _label('NINTENDO', .25, .27, 0, d),
                _label('SEGA', .72, .25, 1, d),
                _label('PLAYSTATION', .30, .72, 2, d),
                _label('XBOX', .73, .70, 3, d),
                Center(child: Opacity(opacity: selected == null ? 1 : .14, child: const Text('GAME-WORLD', style: TextStyle(fontSize: 12, letterSpacing: 5, color: Colors.white54)))),
              ]),
            ),
          ),
        )),
        if (selected != null) Positioned(left: compact ? 14 : 30, right: compact ? 14 : 30, bottom: compact ? 45 : 58, child: Center(child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 620),
          decoration: BoxDecoration(color: const Color(0xE6090913), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x337F70B0)), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 10))]),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(territories[selected!].name, style: const TextStyle(fontSize: 13, letterSpacing: 3)),
              const SizedBox(height: 5),
              Text(territories[selected!].description, style: const TextStyle(fontSize: 9, color: Colors.white38)),
            ])),
            TextButton(onPressed: () => enter(selected!), child: const Text('ENTER')),
          ]),
        ))),
        Positioned(left: compact ? 16 : 30, bottom: compact ? 18 : 26, child: Text(selected == null ? 'SELECT A REGION' : 'SELECTED REGION  •  ENTER TO OPEN', style: const TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white24))),
      ]);
    }),
  );

  Widget _label(String text, double x, double y, int i, double d) {
    final a = selected == null || selected == i ? .72 : .10;
    return Positioned(left: d * x - 85, top: d * y - 22, width: 170, child: IgnorePointer(child: Center(child: Text(text, style: TextStyle(fontSize: selected == i ? 11 : 9, letterSpacing: 2.4, color: Colors.white.withValues(alpha: a))))));
  }

  int? _hit(Offset p, double d) {
    final o = Offset(d / 2, d / 2), r = d * .49;
    const centers = [Offset(-.25,-.25), Offset(.28,-.27), Offset(-.22,.27), Offset(.27,.25)];
    for (var i = 0; i < 4; i++) { final q = o + Offset(centers[i].dx * r, centers[i].dy * r); if ((p - q).distance < r * .34) return i; }
    return null;
  }
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;
  const _GamePlanetPainter({required this.selected});
  static const centers = [Offset(-.25,-.25), Offset(.28,-.27), Offset(-.22,.27), Offset(.27,.25)];
  static const sizes = [Offset(.58,.42), Offset(.48,.35), Offset(.62,.43), Offset(.50,.39)];
  static const colors = [Color(0xFF9175A9), Color(0xFF66829A), Color(0xFF786C98), Color(0xFF5D847A)];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .5), r = size.shortestSide * .47;
    final sphere = Rect.fromCircle(center: c, radius: r);
    final rnd = math.Random(442);

    canvas.drawCircle(c, r * 1.43, Paint()..shader = const RadialGradient(colors: [Color(0x50687A98), Color(0x1B687A98), Colors.transparent], stops: [0,.46,1]).createShader(Rect.fromCircle(center: c, radius: r * 1.43)));
    canvas.drawCircle(c, r * 1.035, Paint()..shader = const RadialGradient(center: Alignment(-.52,-.58), radius: 1.08, colors: [Color(0xFFE0D4C3),Color(0xFF918A88),Color(0xFF555660),Color(0xFF1C1F29),Color(0xFF04060B)], stops: [0,.14,.38,.71,1]).createShader(sphere));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Four large, irregular continental territories. They overlap the same landmass rather than reading as four separate islands.
    for (var i = 0; i < 4; i++) {
      final tc = c + Offset(centers[i].dx * r, centers[i].dy * r);
      final w = r * sizes[i].dx, h = r * sizes[i].dy;
      final active = selected == null ? .28 : selected == i ? .64 : .012;
      final path = _territory(tc, w, h, (i.isEven ? .18 : -.22) + (i < 2 ? .05 : -.05), 700 + i * 19);
      canvas.drawPath(path, Paint()..color = colors[i].withValues(alpha: active));
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = selected == i ? r * .012 : r * .006..color = colors[i].withValues(alpha: selected == i ? .84 : .16));

      // Terrain strata follow the territory itself, giving each region physical depth.
      for (var q = 1; q <= 7; q++) {
        final scale = 1 - q * .095;
        final inner = _territory(tc + Offset(-r * .010 * q, r * .007 * q), w * scale, h * scale, (i.isEven ? .18 : -.22) + (i < 2 ? .05 : -.05), 700 + i * 19 + q * 13);
        canvas.drawPath(inner, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0035..color = Colors.white.withValues(alpha: selected == i ? .075 : .014));
      }
      for (var k = 0; k < 4; k++) {
        final ridge = Rect.fromCenter(center: tc + Offset(r * .015 * k, -r * .008 * k), width: w * (.50 - k * .055), height: h * (.28 + k * .018));
        canvas.drawArc(ridge, .25 + k * .34, 1.95, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .009..color = Colors.white.withValues(alpha: selected == i ? .028 : .009));
      }
    }

    // Subtle planetary latitude and surface structure keep the regions embedded in one sphere.
    for (var i = 0; i < 12; i++) {
      final y = c.dy - r * .70 + i * r * .145;
      canvas.drawArc(Rect.fromCenter(center: Offset(c.dx - r * .04, y), width: r * 1.88, height: r * .17), math.pi * .09, math.pi * .82, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .008..color = Colors.white.withValues(alpha: .012));
    }
    for (var i = 0; i < 165; i++) {
      final x = c.dx + (rnd.nextDouble() * 2 - 1) * r * .88, y = c.dy + (rnd.nextDouble() * 2 - 1) * r * .82;
      canvas.drawCircle(Offset(x,y), r * (.0008 + rnd.nextDouble() * .0045), Paint()..color = Colors.white.withValues(alpha: .008 + rnd.nextDouble() * .030));
    }
    canvas.restore();

    final shadow = c + Offset(r * .57, r * .09);
    canvas.drawCircle(shadow, r * .94, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .83)], stops: const [.28,1]).createShader(Rect.fromCircle(center: shadow, radius: r * .94)));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.008), math.pi * .59, math.pi * .91, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .012..color = Colors.white.withValues(alpha: selected == null ? .25 : .30));
    canvas.drawArc(Rect.fromCircle(center: c + Offset(-r * .04,-r * .04), radius: r * .96), math.pi, math.pi * .45, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .028..color = Colors.white.withValues(alpha: .035));
    canvas.drawCircle(c + Offset(-r * .27,-r * .30), r * .075, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .075),Colors.transparent]).createShader(Rect.fromCircle(center: c + Offset(-r * .27,-r * .30), radius: r * .075)));
  }

  Path _territory(Offset center, double width, double height, double rotation, int seed) {
    final rnd = math.Random(seed), points = <Offset>[];
    const n = 18;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final wave = math.sin(a * 2 + seed) * .11 + math.sin(a * 3.7 + seed * .17) * .07 + math.sin(a * 6.0 + seed * .09) * .025;
      final rad = .80 + wave + rnd.nextDouble() * .10;
      final x = math.cos(a) * width * .5 * rad;
      final y = math.sin(a) * height * .5 * (.90 + .10 * math.sin(a * 2.3 + seed));
      final xr = x * math.cos(rotation) - y * math.sin(rotation), yr = x * math.sin(rotation) + y * math.cos(rotation);
      points.add(Offset(center.dx + xr, center.dy + yr));
    }
    final p = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < n; i++) { final a = points[i], b = points[(i + 1) % n], m = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2); p.quadraticBezierTo(a.dx, a.dy, m.dx, m.dy); }
    p.close();
    return p;
  }

  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _GameSpacePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0,-.08), radius: 1.1, colors: [Color(0xFF15162A),Color(0xFF060710),Color(0xFF010205)]).createShader(rect));
    final r = math.Random(711);
    for (var i = 0; i < 280; i++) canvas.drawCircle(Offset(r.nextDouble() * size.width, r.nextDouble() * size.height), .15 + r.nextDouble() * .75, Paint()..color = Colors.white.withValues(alpha: .028 + r.nextDouble() * .11));
  }
  @override bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => false;
}
