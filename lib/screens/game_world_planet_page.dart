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
  int? selected;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 55))..repeat();

  final territories = const <_TerritoryData>[
    _TerritoryData('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ]),
    _TerritoryData('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'PlayStation generations.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])]),
    ]),
    _TerritoryData('XBOX', 'Xbox generations.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])]),
    ]),
  ];

  @override void dispose() { clock.dispose(); super.dispose(); }
  void _enter(int index) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[index].name, groups: territories[index].groups)));

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF02010A),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _GameSpacePainter(clock.value)),
          Positioned(left: compact ? 18 : 34, top: compact ? 18 : 30, child: _GameTitle(onBack: () => Navigator.pop(context))),
          Center(child: LayoutBuilder(builder: (context, box) {
            final d = math.min(box.maxWidth * (compact ? .82 : .72), box.maxHeight * (compact ? .68 : .76));
            return SizedBox(width: d, height: d, child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _WorldCorePainter(clock.value))),
              for (var i = 0; i < territories.length; i++) _Region(
                index: i, total: territories.length, selected: selected == i, size: d,
                onTap: () => setState(() => selected = i), onOpen: () => _enter(i),
              ),
            ]));
          })),
          if (selected != null) Positioned(left: compact ? 18 : 34, right: compact ? 18 : 34, bottom: compact ? 18 : 30, child: _TerritoryInfo(
            territory: territories[selected!], index: selected!, onClose: () => setState(() => selected = null),
          )),
          if (selected == null) Positioned(left: 0, right: 0, bottom: compact ? 18 : 30, child: const Center(child: Text('CLICK TO FOCUS   •   DOUBLE-CLICK TO ENTER', style: TextStyle(color: Color(0x45FFFFFF), fontSize: 6.5, letterSpacing: 1.8)))),
        ]),
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  final VoidCallback onBack;
  const _GameTitle({required this.onBack});
  @override Widget build(BuildContext context) => Row(children: [
    InkWell(onTap: onBack, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0x88FFFFFF)))),
    const SizedBox(width: 5), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GAME-WORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 4.5)), SizedBox(height: 7), Text('WORLD MAP', style: TextStyle(color: Color(0x78FFFFFF), fontSize: 7, letterSpacing: 3.0))]),
  ]);
}

class _TerritoryInfo extends StatelessWidget {
  final _TerritoryData territory; final int index; final VoidCallback onClose;
  const _TerritoryInfo({required this.territory, required this.index, required this.onClose});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 15, 12, 15),
    decoration: BoxDecoration(color: const Color(0xC9070710), border: Border.all(color: const Color(0x28FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]),
    child: Row(children: [
      Container(width: 3, height: 42, color: const Color(0x667D5AA2)), const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('REGION ${(index + 1).toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5.5, letterSpacing: 1.6)), const SizedBox(height: 4), Text(territory.name, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2.6)), const SizedBox(height: 4), Text(territory.description, style: const TextStyle(color: Color(0x68FFFFFF), fontSize: 7.5))])),
      InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(8), child: Text('×', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 18)))),
    ]),
  );
}

class _Region extends StatelessWidget {
  final int index, total; final bool selected; final double size; final VoidCallback onTap, onOpen;
  const _Region({required this.index, required this.total, required this.selected, required this.size, required this.onTap, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / total;
    final center = size / 2;
    final p = Offset(center + math.cos(angle) * size * .29, center + math.sin(angle) * size * .29);
    final d = size * (selected ? .18 : .14);
    return Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d, child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onDoubleTap: onOpen,
        child: CustomPaint(painter: _RegionPainter(index, selected)),
      ),
    ));
  }
}

class _RegionPainter extends CustomPainter {
  final int index; final bool selected;
  const _RegionPainter(this.index, this.selected);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.width * .36;
    final halo = r * (selected ? 2.0 : 1.35);
    canvas.drawCircle(c, halo, Paint()..shader = RadialGradient(colors: [const Color(0xFF8B6AA0).withValues(alpha: selected ? .22 : .10), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: halo)));
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.3, -.35), colors: [Color(0xFFE0D8E5), Color(0xFF766080), Color(0xFF17121D)]).createShader(Rect.fromCircle(center: c, radius: r)));
    for (var i = 0; i < 4; i++) canvas.drawOval(Rect.fromCenter(center: c, width: r * (1.0 + i * .25), height: r * (.45 + i * .14)), Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = const Color(0x38101015));
    if (selected) canvas.drawCircle(c, r * 1.2, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x88FFFFFF));
  }
  @override bool shouldRepaint(covariant _RegionPainter old) => old.index != index || old.selected != selected;
}

class _WorldCorePainter extends CustomPainter {
  final double phase;
  const _WorldCorePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = math.min(size.width, size.height) * .16;
    final outer = r * 2.6;
    canvas.drawCircle(c, outer, Paint()..shader = RadialGradient(colors: [const Color(0xFF79578E).withValues(alpha: .12), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: outer)));
    canvas.drawCircle(c, r, Paint()..shader = const RadialGradient(colors: [Color(0xFFD8CDE1), Color(0xFF6D557D), Color(0xFF15101A)]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r * .83, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x60FFFFFF));
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x22FFFFFF);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 6.0, height: r * 2.0), ring);
    canvas.drawArc(Rect.fromCenter(center: c, width: r * 6.0, height: r * 2.0), phase * math.pi * 2, math.pi * .45, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x45FFFFFF));
  }
  @override bool shouldRepaint(covariant _WorldCorePainter old) => old.phase != phase;
}

class _GameSpacePainter extends CustomPainter {
  final double phase;
  const _GameSpacePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF05030C), Color(0xFF02020A), Color(0xFF090414)]).createShader(rect));
    final random = math.Random(412);
    for (var i = 0; i < 340; i++) canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .2 + random.nextDouble() * .7, Paint()..color = Colors.white.withValues(alpha: .025 + random.nextDouble() * .14));
    final c = Offset(size.width * .5, size.height * .5), glow = math.min(size.width, size.height) * .45;
    canvas.drawCircle(c, glow, Paint()..shader = RadialGradient(colors: [const Color(0xFF624675).withValues(alpha: .07), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: glow)));
  }
  @override bool shouldRepaint(covariant _GameSpacePainter old) => old.phase != phase;
}
