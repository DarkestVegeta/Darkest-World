import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
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

  void openTerritory(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(
      territory: territories[index].name,
      groups: territories[index].groups,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010307),
      body: LayoutBuilder(builder: (context, box) {
        final compact = box.maxWidth < 760;
        final diameter = math.min(box.maxWidth * (compact ? .86 : .62), box.maxHeight * (compact ? .66 : .76));
        return Stack(children: [
          const Positioned.fill(child: CustomPaint(painter: _GameSpacePainter())),
          SafeArea(child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 28),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
              const SizedBox(width: 10),
              const Text('GAME-WORLD', style: TextStyle(fontSize: 16, letterSpacing: 4)),
              const Spacer(),
              Text('TERRITORIES', style: TextStyle(fontSize: 8, letterSpacing: 2.5, color: Colors.white.withValues(alpha: .28))),
            ]),
          )),
          Center(child: SizedBox(
            width: diameter,
            height: diameter,
            child: GestureDetector(
              onTapUp: (details) {
                final hit = _hit(details.localPosition, diameter);
                if (hit != null) setState(() => selected = selected == hit ? null : hit);
              },
              child: CustomPaint(
                painter: _GamePlanetPainter(selected: selected, diameter: diameter),
                child: Stack(children: [
                  _label('NINTENDO', .29, .30, 0, diameter),
                  _label('SEGA', .70, .30, 1, diameter),
                  _label('PLAYSTATION', .30, .70, 2, diameter),
                  _label('XBOX', .70, .70, 3, diameter),
                  Center(child: IgnorePointer(child: Opacity(
                    opacity: selected == null ? 1 : .25,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('GAME', style: TextStyle(fontSize: compact ? 15 : 20, letterSpacing: 7, color: Colors.white.withValues(alpha: .70))),
                      const SizedBox(height: 5),
                      Text('WORLD', style: TextStyle(fontSize: 8, letterSpacing: 5, color: Colors.white.withValues(alpha: .28))),
                    ]),
                  ))),
                ]),
              ),
            ),
          )),
          if (selected != null)
            Positioned(
              left: compact ? 14 : 30,
              right: compact ? 14 : 30,
              bottom: compact ? 52 : 62,
              child: Center(child: Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 620),
                decoration: BoxDecoration(color: const Color(0xE6090913), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x227F70B0))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(territories[selected!].name, style: const TextStyle(fontSize: 13, letterSpacing: 3)),
                    const SizedBox(height: 5),
                    Text(territories[selected!].description, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .40))),
                  ])),
                  TextButton(onPressed: () => openTerritory(selected!), child: const Text('ENTER')),
                ]),
              )),
            ),
          Positioned(
            left: compact ? 16 : 30,
            bottom: compact ? 18 : 26,
            child: Text(selected == null ? 'SELECT A TERRITORY' : 'SELECTED TERRITORY  •  ENTER TO OPEN', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .22))),
          ),
        ]);
      }),
    );
  }

  Widget _label(String text, double x, double y, int index, double d) {
    return Positioned(
      left: d * x - 65,
      top: d * y - 25,
      width: 130,
      child: IgnorePointer(child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(
        fontSize: selected == index ? 11 : 9,
        letterSpacing: 2.4,
        color: Colors.white.withValues(alpha: selected != null && selected != index ? .18 : .66),
      )))),
    );
  }

  int? _hit(Offset p, double d) {
    final center = Offset(d / 2, d / 2);
    final r = d * .49;
    const regions = [Offset(-.31, -.25), Offset(.31, -.24), Offset(-.30, .27), Offset(.29, .27)];
    for (var i = 0; i < regions.length; i++) {
      final c = center + Offset(regions[i].dx * r, regions[i].dy * r);
      if ((p - c).distance < r * .28) return i;
    }
    return null;
  }
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;
  final double diameter;
  const _GamePlanetPainter({required this.selected, required this.diameter});
  @override
  void paint(Canvas c, Size s) {
    final o = Offset(s.width / 2, s.height / 2);
    final r = diameter * .49;
    final rect = Rect.fromCircle(center: o, radius: r);
    c.drawCircle(o, r * 1.05, Paint()..shader = const RadialGradient(colors: [Color(0x226679A5), Colors.transparent]).createShader(Rect.fromCircle(center: o, radius: r * 1.08)));
    c.drawCircle(o, r, Paint()..shader = const RadialGradient(center: Alignment(-.34, -.38), radius: 1.05, colors: [Color(0xFF2B3B50), Color(0xFF172538), Color(0xFF070D16)]).createShader(rect));
    c.save();
    c.clipPath(Path()..addOval(rect));
    const regions = [Offset(-.31, -.25), Offset(.31, -.24), Offset(-.30, .27), Offset(.29, .27)];
    const colors = [0xFF8B73D6, 0xFF4D82C4, 0xFF756A9E, 0xFF4F8A86];
    for (var i = 0; i < regions.length; i++) {
      final center = o + Offset(regions[i].dx * r, regions[i].dy * r);
      final shape = Rect.fromCenter(center: center, width: r * .62, height: r * .48);
      final active = selected == i;
      final alpha = selected == null ? .07 : (active ? .25 : .015);
      c.drawOval(shape, Paint()..color = Color(colors[i]).withValues(alpha: alpha));
      if (selected == null || active) {
        c.drawOval(shape, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2 : 1..color = Color(colors[i]).withValues(alpha: active ? .60 : .20));
      }
    }
    c.restore();
    c.drawCircle(o + Offset(r * .38, r * .08), r * .80, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .34)]).createShader(Rect.fromCircle(center: o + Offset(r * .38, r * .08), radius: r * .80)));
  }
  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _GameSpacePainter extends CustomPainter {
  const _GameSpacePainter();
  @override void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(colors: [Color(0xFF15162A), Color(0xFF060710), Color(0xFF010205)]).createShader(Offset.zero & s));
    final r = math.Random(711);
    final p = Paint();
    for (var i = 0; i < 240; i++) {
      p.color = Colors.white.withValues(alpha: .04 + r.nextDouble() * .12);
      c.drawCircle(Offset(r.nextDouble() * s.width, r.nextDouble() * s.height), .2 + r.nextDouble() * .7, p);
    }
  }
  @override bool shouldRepaint(covariant _GameSpacePainter oldDelegate) => false;
}
