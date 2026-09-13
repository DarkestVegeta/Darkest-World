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
  const _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> with SingleTickerProviderStateMixin {
  late final AnimationController orbit = AnimationController(vsync: this, duration: const Duration(seconds: 36))..repeat();
  int? selected;
  bool autoOrbit = true;
  bool mapMode = false;
  double zoom = 1.0;

  final territories = const <_TerritoryData>[
    _TerritoryData('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ]),
    _TerritoryData('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'PlayStation generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])])]),
    _TerritoryData('XBOX', 'Xbox generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])])]),
  ];

  @override void dispose() { orbit.dispose(); super.dispose(); }
  void enter(int index) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[index].name, groups: territories[index].groups)));
  void toggleOrbit() { setState(() => autoOrbit = !autoOrbit); if (autoOrbit) orbit.repeat(); else orbit.stop(); }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010207),
    body: AnimatedBuilder(animation: orbit, builder: (_, __) => LayoutBuilder(builder: (context, box) {
      final side = math.min(box.maxWidth * .72, box.maxHeight * .72) * zoom;
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _SpacePainter(orbit.value))),
        SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 18), child: Row(children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
          const Text('GAME-WORLD', style: TextStyle(fontSize: 15, letterSpacing: 4)), const Spacer(),
          _Control(label: mapMode ? 'PLANET' : 'MAP', onTap: () => setState(() => mapMode = !mapMode)), const SizedBox(width: 6),
          _Control(label: autoOrbit ? 'ORBIT ON' : 'ORBIT OFF', onTap: toggleOrbit), const SizedBox(width: 6),
          _Control(label: '−', onTap: () => setState(() => zoom = math.max(.82, zoom - .08))), const SizedBox(width: 4),
          _Control(label: '+', onTap: () => setState(() => zoom = math.min(1.25, zoom + .08)), wide: false),
        ]))),
        if (mapMode) Positioned.fill(child: _MapMode(territories: territories, selected: selected, onSelect: (i) => setState(() => selected = i), onEnter: enter))
        else Center(child: SizedBox(width: side, height: side, child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PlanetPainter(orbit.value))),
          for (var i = 0; i < territories.length; i++) _PlanetRegion(index: i, total: territories.length, name: territories[i].name, selected: selected == i, phase: orbit.value, onTap: () => setState(() => selected = selected == i ? null : i)),
        ]))),
        if (selected != null && !mapMode) Positioned(left: 22, right: 22, bottom: 20, child: _Detail(data: territories[selected!], onClose: () => setState(() => selected = null), onEnter: () => enter(selected!)))
        else Positioned(left: 22, bottom: 20, child: _Legend()),
      ];
    })),
  );
}

class _Control extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool wide;
  const _Control({required this.label, required this.onTap, this.wide = true});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(width: wide ? null : 30, padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8), decoration: BoxDecoration(color: const Color(0xAA05060D), border: Border.all(color: Colors.white12)), child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.1))));
}
class _Legend extends StatelessWidget { @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xAA05060D), border: Border.all(color: Colors.white10)), child: const Text('GAME-WORLD  /  ONE PLANET  /  FOUR REGIONS', style: TextStyle(color: Colors.white30, fontSize: 6, letterSpacing: 1.3))); }
class _Detail extends StatelessWidget {
  final _TerritoryData data; final VoidCallback onClose, onEnter;
  const _Detail({required this.data, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xEE080812), border: Border.all(color: Colors.white18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.name, style: const TextStyle(fontSize: 13, letterSpacing: 3)), const SizedBox(height: 4), Text(data.description, style: const TextStyle(fontSize: 7, color: Colors.white38))])), TextButton(onPressed: onClose, child: const Text('CLOSE')), const SizedBox(width: 5), FilledButton(onPressed: onEnter, child: const Text('ENTER'))]));
}
class _PlanetRegion extends StatelessWidget {
  final int index, total; final String name; final bool selected; final double phase; final VoidCallback onTap;
  const _PlanetRegion({required this.index, required this.total, required this.name, required this.selected, required this.phase, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / total + phase * math.pi * 2;
    final x = .5 + math.cos(angle) * .34, y = .5 + math.sin(angle) * .27;
    final visible = math.cos(angle) > -.35;
    return Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: Opacity(opacity: visible ? 1 : .22, child: GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(duration: const Duration(milliseconds: 180), width: selected ? 92 : 70, height: selected ? 52 : 42, decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0x443F385A) : const Color(0x33211D32), border: Border.all(color: selected ? Colors.white54 : Colors.white18), boxShadow: selected ? const [BoxShadow(color: Color(0x554F4670), blurRadius: 24)] : const []), child: CustomPaint(painter: _RegionPainter(index))),
      const SizedBox(height: 5), Text(name, style: TextStyle(color: Colors.white.withOpacity(selected ? .9 : .55), fontSize: selected ? 9 : 7, letterSpacing: 1.7)),
    ]))));
  }
}
class _PlanetPainter extends CustomPainter {
  final double phase; const _PlanetPainter(this.phase);
  @override void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide * .47;
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.28, -.32), radius: .9, colors: [Color(0xFF77718D), Color(0xFF29253A), Color(0xFF090A12), Color(0xFF020307)]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0x667E7893));
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x223F4A65);
    for (var i = 0; i < 7; i++) canvas.drawOval(Rect.fromCenter(center: c, width: r * (1.25 + i * .12), height: r * (.22 + i * .035)), ring);
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x1CFFFFFF);
    for (var i = -2; i <= 2; i++) canvas.drawArc(Rect.fromCircle(center: c, radius: r * .93), -math.pi / 2 + i * .38 + phase * .08, math.pi, false, grid);
    for (var i = 0; i < 5; i++) canvas.drawOval(Rect.fromCenter(center: c, width: r * (1.6 - i * .22), height: r * (.24 + i * .1)), grid);
  }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.phase != phase;
}
class _RegionPainter extends CustomPainter {
  final int seed; const _RegionPainter(this.seed);
  @override void paint(Canvas canvas, Size size) { final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x667D7591); final random = math.Random(seed + 17); for (var i = 0; i < 4; i++) canvas.drawOval(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * (.35 + i * .15), height: size.height * (.22 + i * .12)), p); for (var i = 0; i < 9; i++) canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .45, p); }
  @override bool shouldRepaint(covariant _RegionPainter old) => false;
}
class _MapMode extends StatelessWidget {
  final List<_TerritoryData> territories; final int? selected; final ValueChanged<int> onSelect; final ValueChanged<int> onEnter;
  const _MapMode({required this.territories, required this.selected, required this.onSelect, required this.onEnter});
  @override Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: Padding(padding: const EdgeInsets.fromLTRB(30, 90, 30, 90), child: GridView.builder(shrinkWrap: true, itemCount: territories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2), itemBuilder: (_, i) { final active = selected == i; return InkWell(onTap: () => onSelect(i), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: active ? const Color(0x332D2940) : const Color(0x180A0B12), border: Border.all(color: active ? Colors.white38 : Colors.white12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(territories[i].name, style: TextStyle(color: Colors.white.withOpacity(active ? .9 : .6), fontSize: 10, letterSpacing: 2)), const SizedBox(height: 5), Text(territories[i].description, style: const TextStyle(color: Colors.white30, fontSize: 6))])), if (active) TextButton(onPressed: () => onEnter(i), child: const Text('ENTER'))]))); }))));
}
class _SpacePainter extends CustomPainter {
  final double t; const _SpacePainter(this.t);
  @override void paint(Canvas canvas, Size size) { final random = math.Random(412); canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF19152B), Color(0xFF07070F), Color(0xFF010106)]).createShader(Offset.zero & size)); for (var i = 0; i < 190; i++) { final x = (random.nextDouble() * size.width + t * size.width * .015) % size.width, y = random.nextDouble() * size.height; canvas.drawCircle(Offset(x, y), .2 + random.nextDouble() * .55, Paint()..color = Colors.white.withOpacity(.02)); } }
  @override bool shouldRepaint(covariant _SpacePainter old) => old.t != t;
}
