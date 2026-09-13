import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class Territory {
  final String name, description;
  final List<GamePlatformGroup> groups;
  const Territory(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 36))..repeat();
  int? selected;
  bool orbitOn = true, mapMode = false;
  double zoom = 1;

  static const territories = <Territory>[
    Territory('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ]),
    Territory('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ]),
    Territory('PLAYSTATION', 'PlayStation generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])])]),
    Territory('XBOX', 'Xbox generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])])]),
  ];

  @override void dispose() { controller.dispose(); super.dispose(); }
  void toggleOrbit() { setState(() => orbitOn = !orbitOn); if (orbitOn) controller.repeat(); else controller.stop(); }
  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].name, groups: territories[i].groups)));

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010207),
    body: AnimatedBuilder(animation: controller, builder: (_, __) => LayoutBuilder(builder: (context, box) {
      final side = math.min(box.maxWidth, box.maxHeight) * .68 * zoom;
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: SpacePainter(controller.value))),
        SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), child: Row(children: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
          const Text('GAME-WORLD', style: TextStyle(fontSize: 15, letterSpacing: 4)), const Spacer(),
          Button(label: mapMode ? 'PLANET' : 'MAP', onTap: () => setState(() => mapMode = !mapMode)), const SizedBox(width: 6),
          Button(label: orbitOn ? 'ORBIT ON' : 'ORBIT OFF', onTap: toggleOrbit), const SizedBox(width: 6),
          Button(label: '−', onTap: () => setState(() => zoom = math.max(.82, zoom - .08))), const SizedBox(width: 4),
          Button(label: '+', onTap: () => setState(() => zoom = math.min(1.25, zoom + .08))),
        ]))),
        if (mapMode)
          Positioned.fill(child: MapView(territories: territories, selected: selected, onSelect: (i) => setState(() => selected = i), onEnter: enter))
        else
          Center(child: SizedBox(width: side, height: side, child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: PlanetPainter(controller.value))),
            for (var i = 0; i < territories.length; i++) Region(index: i, count: territories.length, name: territories[i].name, phase: controller.value, selected: selected == i, onTap: () => setState(() => selected = selected == i ? null : i)),
          ]))),
        if (!mapMode && selected != null)
          Positioned(left: 20, right: 20, bottom: 18, child: Detail(data: territories[selected!], close: () => setState(() => selected = null), enter: () => enter(selected!))),
        if (!mapMode && selected == null)
          const Positioned(left: 20, bottom: 18, child: InfoLabel()),
      ]);
    })),
  );
}

class Button extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const Button({super.key, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8), decoration: BoxDecoration(color: const Color(0xAA05060D), border: Border.all(color: const Color(0x1FFFFFFF))), child: Text(label, style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 6))));
}
class InfoLabel extends StatelessWidget {
  const InfoLabel({super.key});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xAA05060D), border: Border.all(color: const Color(0x1AFFFFFF))), child: const Text('GAME-WORLD / ONE PLANET / FOUR REGIONS', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 6, letterSpacing: 1.2)));
}
class Detail extends StatelessWidget {
  final Territory data; final VoidCallback close, enter;
  const Detail({super.key, required this.data, required this.close, required this.enter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xEE080812), border: Border.all(color: const Color(0x2EFFFFFF))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.name, style: const TextStyle(fontSize: 13, letterSpacing: 3)), const SizedBox(height: 4), Text(data.description, style: const TextStyle(fontSize: 7, color: Color(0x61FFFFFF)))])), TextButton(onPressed: close, child: const Text('CLOSE')), FilledButton(onPressed: enter, child: const Text('ENTER'))]));
}
class Region extends StatelessWidget {
  final int index, count; final String name; final double phase; final bool selected; final VoidCallback onTap;
  const Region({super.key, required this.index, required this.count, required this.name, required this.phase, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / count + phase * math.pi * 2;
    final x = .5 + math.cos(angle) * .34;
    final y = .5 + math.sin(angle) * .27;
    final opacity = math.cos(angle) > -.35 ? 1.0 : .2;
    return Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: Opacity(opacity: opacity, child: GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: selected ? 90 : 68, height: selected ? 50 : 40, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x33211D32), border: Border.all(color: selected ? const Color(0x99FFFFFF) : const Color(0x2EFFFFFF))), child: CustomPaint(painter: RegionPainter(index))), const SizedBox(height: 5), Text(name, style: TextStyle(color: selected ? Colors.white : const Color(0x8CFFFFFF), fontSize: selected ? 9 : 7, letterSpacing: 1.6))]))));
  }
}
class PlanetPainter extends CustomPainter {
  final double phase; const PlanetPainter(this.phase);
  @override void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide * .47;
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.28, -.32), radius: .9, colors: [Color(0xFF77718D), Color(0xFF29253A), Color(0xFF090A12), Color(0xFF020307)]).createShader(Rect.fromCircle(center: c, radius: r)));
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x223F4A65);
    for (var i = 0; i < 6; i++) canvas.drawOval(Rect.fromCenter(center: c, width: r * (1.2 + i * .12), height: r * (.22 + i * .035)), line);
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x1CFFFFFF);
    for (var i = -2; i <= 2; i++) canvas.drawArc(Rect.fromCircle(center: c, radius: r * .93), -math.pi / 2 + i * .38 + phase * .08, math.pi, false, grid);
  }
  @override bool shouldRepaint(covariant PlanetPainter old) => old.phase != phase;
}
class RegionPainter extends CustomPainter {
  final int seed; const RegionPainter(this.seed);
  @override void paint(Canvas canvas, Size size) { final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x667D7591); for (var i = 0; i < 4; i++) canvas.drawOval(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * (.4 + i * .13), height: size.height * (.25 + i * .1)), p); }
  @override bool shouldRepaint(covariant RegionPainter old) => false;
}
class MapView extends StatelessWidget {
  final List<Territory> territories; final int? selected; final ValueChanged<int> onSelect; final ValueChanged<int> onEnter;
  const MapView({super.key, required this.territories, required this.selected, required this.onSelect, required this.onEnter});
  @override Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: GridView.builder(padding: const EdgeInsets.all(50), itemCount: territories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2), itemBuilder: (_, i) { final active = selected == i; return InkWell(onTap: () => onSelect(i), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: active ? const Color(0x332D2940) : const Color(0x180A0B12), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1FFFFFFF))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(territories[i].name, style: TextStyle(color: active ? Colors.white : const Color(0x99FFFFFF), fontSize: 10, letterSpacing: 2)), const SizedBox(height: 5), Text(territories[i].description, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6))])), if (active) TextButton(onPressed: () => onEnter(i), child: const Text('ENTER'))])); }))); 
}
class SpacePainter extends CustomPainter {
  final double t; const SpacePainter(this.t);
  @override void paint(Canvas canvas, Size size) { canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF19152B), Color(0xFF07070F), Color(0xFF010106)]).createShader(Offset.zero & size)); final random = math.Random(412); for (var i = 0; i < 150; i++) { final x = (random.nextDouble() * size.width + t * 12) % size.width; final y = random.nextDouble() * size.height; canvas.drawCircle(Offset(x, y), .2 + random.nextDouble() * .45, Paint()..color = const Color(0x18FFFFFF)); } }
  @override bool shouldRepaint(covariant SpacePainter old) => old.t != t;
}
