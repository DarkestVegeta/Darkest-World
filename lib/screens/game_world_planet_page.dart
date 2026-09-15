import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String routeName, name, title, description;
  final List<GamePlatformGroup> groups;
  final double x, y;
  const _TerritoryData(this.routeName, this.name, this.title, this.description, this.groups, this.x, this.y);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 110))..repeat();
  int? selected;

  final territories = const <_TerritoryData>[
    _TerritoryData('NINTENDO', 'NORTHLAND', 'NORTHLAND', 'Northern forests, cold lakes and layered mountain ranges.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ], 24, 29),
    _TerritoryData('SEGA', 'WESTERN REACH', 'WESTERN REACH', 'Dry western plains, coastal forests and a long mountain spine.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ], 70, 34),
    _TerritoryData('PLAYSTATION', 'SOUTHERN CONTINENT', 'SOUTHERN CONTINENT', 'Warm coasts, deep river valleys and dense southern highlands.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])]),
    ], 48, 71),
    _TerritoryData('XBOX', 'EASTERN HIGHLANDS', 'EASTERN HIGHLANDS', 'Cold upland lakes, cliffs, plateaus and rugged eastern ranges.', [
      GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])]),
    ], 77, 57),
  ];

  @override void dispose() { clock.dispose(); super.dispose(); }
  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].routeName, groups: territories[i].groups)));

  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF010307),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _SpacePainter(clock.value)),
          Positioned(left: compact ? 14 : 38, top: compact ? 14 : 30, child: _Header(back: () => Navigator.pop(context))),
          Positioned(top: compact ? 82 : 92, left: compact ? 14 : 38, right: compact ? 14 : 38, child: _Telemetry(compact: compact)),
          Center(child: LayoutBuilder(builder: (context, b) {
            final w = b.maxWidth * (compact ? .98 : .92);
            final h = math.min(b.maxHeight * (compact ? .72 : .79), w * .70);
            return SizedBox(width: w, height: h, child: Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: _PlanetWorldPainter(clock.value)),
              for (var i = 0; i < territories.length; i++)
                _TerritoryNode(data: territories[i], selected: selected == i, onTap: () => setState(() => selected = i), onOpen: () => enter(i)),
            ]));
          })),
          Positioned(left: compact ? 14 : 38, right: compact ? 14 : 38, bottom: compact ? 14 : 24, child: selected == null
              ? _Hint(compact: compact)
              : _RegionPanel(data: territories[selected!], index: selected!, compact: compact, close: () => setState(() => selected = null), open: () => enter(selected!))),
          if (!compact) const Positioned(right: 38, top: 34, child: _BuildStamp()),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback back;
  const _Header({required this.back});
  @override Widget build(BuildContext c) => Row(children: [
    InkWell(onTap: back, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xB8FFFFFF)))),
    const SizedBox(width: 8),
    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('GAME-WORLD', style: TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 5.5, fontWeight: FontWeight.w500)),
      SizedBox(height: 6),
      Text('PLANETARY ARCHIVE  /  WORLD MAP', style: TextStyle(color: Color(0x72B5C6D0), fontSize: 6.5, letterSpacing: 2.8)),
    ]),
  ]);
}

class _Telemetry extends StatelessWidget {
  final bool compact;
  const _Telemetry({required this.compact});
  @override Widget build(BuildContext c) => Row(children: [
    const _Metric('WORLD', '01'), const _Metric('REGIONS', '04'), const _Metric('STATE', 'STABLE'),
    const Spacer(),
    if (!compact) const Text('ORBITAL CARTOGRAPHY  /  LIVE', style: TextStyle(color: Color(0x52C0D0D8), fontSize: 6, letterSpacing: 2.3)),
  ]);
}

class _Metric extends StatelessWidget {
  final String a, b;
  const _Metric(this.a, this.b);
  @override Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(right: 7),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: const Color(0x160A1118), border: Border.all(color: const Color(0x327E98A5))),
    child: Row(children: [
      Text(a, style: const TextStyle(color: Color(0x568FA8B4), fontSize: 5, letterSpacing: 1.25)),
      const SizedBox(width: 6),
      Text(b, style: const TextStyle(color: Color(0xC2D7E0E5), fontSize: 6, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
    ]),
  );
}

class _TerritoryNode extends StatelessWidget {
  final _TerritoryData data; final bool selected; final VoidCallback onTap, onOpen;
  const _TerritoryNode({required this.data, required this.selected, required this.onTap, required this.onOpen});
  @override Widget build(BuildContext c) => LayoutBuilder(builder: (context, b) {
    final p = Offset(b.maxWidth * data.x / 100, b.maxHeight * data.y / 100);
    final d = b.maxWidth * (selected ? .12 : .075);
    return Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d, child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, onDoubleTap: onOpen, child: CustomPaint(painter: _MarkerPainter(data.name, selected))),
    ));
  });
}

class _MarkerPainter extends CustomPainter {
  final String name; final bool selected;
  const _MarkerPainter(this.name, this.selected);
  @override void paint(Canvas x, Size s) {
    final c = s.center(Offset.zero), r = s.width * .19, halo = r * (selected ? 7 : 4);
    x.drawCircle(c, halo, Paint()..shader = RadialGradient(colors: [const Color(0xFFB9D8E2).withValues(alpha: selected ? .22 : .055), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: halo)));
    x.drawCircle(c, r * 2.2, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.4 : .55..color = const Color(0x8099B9C5));
    x.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.35, -.55), colors: [Color(0xFFF0F6F8), Color(0xFF91AAB3), Color(0xFF25333A), Color(0xFF060A0E)]).createShader(Rect.fromCircle(center: c, radius: r)));
    final tp = TextPainter(text: TextSpan(text: name, style: TextStyle(color: Colors.white.withValues(alpha: selected ? .95 : .68), fontSize: math.max(6, s.width * .035), letterSpacing: 1.6, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.8);
    tp.paint(x, Offset(c.dx - tp.width / 2, c.dy + r * 3.2));
  }
  @override bool shouldRepaint(covariant _MarkerPainter o) => o.name != name || o.selected != selected;
}

class _RegionPanel extends StatelessWidget {
  final _TerritoryData data; final int index; final bool compact; final VoidCallback close, open;
  const _RegionPanel({required this.data, required this.index, required this.compact, required this.close, required this.open});
  @override Widget build(BuildContext c) => Container(
    padding: EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 12 : 16, 10, compact ? 12 : 16),
    decoration: BoxDecoration(color: const Color(0xF0060A0E), border: Border.all(color: const Color(0x4A8DA7B1)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 46, spreadRadius: 3)]),
    child: Row(children: [
      Container(width: 3, height: compact ? 54 : 66, decoration: BoxDecoration(color: const Color(0xA2A5C3CC), borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('REGION ${(index + 1).toString().padLeft(2, '0')}  /  ${data.routeName}', style: const TextStyle(color: Color(0x6EAFC3CB), fontSize: 5.5, letterSpacing: 1.8)),
        const SizedBox(height: 5),
        Text(data.title, style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 18, letterSpacing: 2.9)),
        const SizedBox(height: 4),
        Text(data.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x88C3D0D5), fontSize: 7.5, height: 1.35)),
      ])),
      if (!compact) ...[
        const SizedBox(width: 14),
        InkWell(onTap: open, child: Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: const Color(0x1B29404A), border: Border.all(color: const Color(0x5A7898A5))), child: const Text('ENTER REGION', style: TextStyle(color: Color(0xC4D7E1E5), fontSize: 6, letterSpacing: 1.8)))),
      ],
      InkWell(onTap: close, child: const Padding(padding: EdgeInsets.all(9), child: Text('×', style: TextStyle(color: Color(0xA8FFFFFF), fontSize: 19)))),
    ]),
  );
}

class _Hint extends StatelessWidget {
  final bool compact;
  const _Hint({required this.compact});
  @override Widget build(BuildContext c) => Center(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xC8060A0E), border: Border.all(color: const Color(0x327C9AA5))),
    child: Text(compact ? 'TAP  FOCUS   •   DOUBLE-TAP  ENTER' : '1× CLICK  FOCUS     2× CLICK  ENTER REGION', style: const TextStyle(color: Color(0x82C4D1D6), fontSize: 6.5, letterSpacing: 2.15)),
  ));
}

class _BuildStamp extends StatelessWidget {
  const _BuildStamp();
  @override Widget build(BuildContext c) => const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text('DW / GW-01', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 5, letterSpacing: 1.8)),
    SizedBox(height: 4),
    Text('PLANETARY SURFACE  •  CARTOGRAPHIC MODE', style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 4.5, letterSpacing: 1.3)),
  ]);
}

class _SpacePainter extends CustomPainter {
  final double phase;
  const _SpacePainter(this.phase);
  @override void paint(Canvas x, Size s) {
    final r = Offset.zero & s;
    x.drawRect(r, Paint()..shader = const RadialGradient(center: Alignment(0, .02), radius: 1.1, colors: [Color(0xFF09131A), Color(0xFF02060A), Color(0xFF010204)]).createShader(r));
    final rnd = math.Random(420);
    for (var i = 0; i < 520; i++) {
      final px = rnd.nextDouble() * s.width, py = rnd.nextDouble() * s.height;
      final tw = .012 + .032 * (.5 + .5 * math.sin(phase * math.pi * 2 + i * .71));
      x.drawCircle(Offset(px, py), .18 + rnd.nextDouble() * .62, Paint()..color = Colors.white.withValues(alpha: tw));
    }
    final center = Offset(s.width * .52, s.height * .51);
    x.drawCircle(center, math.min(s.width, s.height) * .72, Paint()..shader = RadialGradient(colors: [const Color(0x2C5B8395), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: math.min(s.width, s.height) * .72)));
  }
  @override bool shouldRepaint(covariant _SpacePainter o) => o.phase != phase;
}

class _PlanetWorldPainter extends CustomPainter {
  final double phase;
  const _PlanetWorldPainter(this.phase);
  void land(Canvas x, Size s, List<Offset> q, Color a, Color b) {
    final p = Path()..moveTo(q.first.dx * s.width, q.first.dy * s.height);
    for (var i = 1; i < q.length; i++) p.cubicTo(q[i - 1].dx * s.width, q[i - 1].dy * s.height, q[i].dx * s.width, q[i].dy * s.height, q[i].dx * s.width, q[i].dy * s.height);
    p.close();
    x.drawPath(p, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]).createShader(Offset.zero & s));
    x.drawPath(p, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x6A91A69A));
  }
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width * .5, s.height * .52), r = math.min(s.width, s.height) * .42, sphere = Rect.fromCircle(center: c, radius: r);
    x.drawCircle(c, r * 1.09, Paint()..shader = RadialGradient(colors: [const Color(0x5A87AFC0), const Color(0x18759BAC), Colors.transparent], stops: const [.70, .82, 1]).createShader(Rect.fromCircle(center: c, radius: r * 1.09)));
    x.drawCircle(c, r * 1.015, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .025..color = const Color(0x6597C0CF));
    x.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.38, -.48), colors: [Color(0xFF668C83), Color(0xFF2E5550), Color(0xFF142C2E), Color(0xFF050C10)], stops: [.0, .38, .74, 1]).createShader(sphere));
    final lands = <List<Offset>>[
      [const Offset(.23,.35),const Offset(.28,.28),const Offset(.39,.25),const Offset(.46,.31),const Offset(.43,.40),const Offset(.35,.45),const Offset(.25,.42)],
      [const Offset(.49,.26),const Offset(.61,.23),const Offset(.70,.29),const Offset(.74,.39),const Offset(.67,.47),const Offset(.55,.44),const Offset(.48,.36)],
      [const Offset(.28,.52),const Offset(.38,.47),const Offset(.49,.51),const Offset(.51,.62),const Offset(.45,.73),const Offset(.34,.78),const Offset(.27,.68)],
      [const Offset(.58,.54),const Offset(.70,.50),const Offset(.79,.57),const Offset(.78,.69),const Offset(.69,.76),const Offset(.58,.70),const Offset(.54,.61)],
      [const Offset(.78,.33),const Offset(.86,.31),const Offset(.91,.39),const Offset(.87,.48),const Offset(.79,.47),const Offset(.75,.40)],
    ];
    final fills = [const Color(0xFF526C52),const Color(0xFF667454),const Color(0xFF4E624D),const Color(0xFF5D684A),const Color(0xFF465C52)];
    for (var i = 0; i < lands.length; i++) land(x, s, lands[i], fills[i], fills[i].withValues(alpha: .38));
    x.drawArc(Rect.fromCircle(center: c, radius: r * .93), math.pi * 1.05, math.pi * .48, false, Paint()..color = const Color(0xB6D6E1DF));
    final ridge = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x766C7D68);
    for (var i = 0; i < 12; i++) { final bx = s.width * (.20 + i * .052); final p = Path()..moveTo(bx, s.height * (.29 + (i % 3) * .02)); for (var j = 0; j < 6; j++) p.lineTo(bx + s.width * (.018 * j), s.height * (.31 + j * .018 + (i % 2) * .018)); x.drawPath(p, ridge); }
    final river = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x887EB2B5);
    for (var i = 0; i < 9; i++) { final bx = s.width * (.27 + i * .058); final p = Path()..moveTo(bx, s.height * .35)..cubicTo(bx - s.width * .025, s.height * .44, bx + s.width * .05, s.height * .54, bx - s.width * .005, s.height * .66)..cubicTo(bx - s.width * .03, s.height * .70, bx + s.width * .02, s.height * .76, bx + s.width * .025, s.height * .80); x.drawPath(p, river); }
    final rnd = math.Random(77), forest = Paint()..color = const Color(0x5032473C);
    for (var i = 0; i < 260; i++) { final px = c.dx - r * .88 + rnd.nextDouble() * r * 1.76, py = c.dy - r * .78 + rnd.nextDouble() * r * 1.56, dx = (px - c.dx) / r, dy = (py - c.dy) / r; if (dx * dx + dy * dy < .86) x.drawCircle(Offset(px, py), .7 + rnd.nextDouble() * 1.4, forest); }
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x2A9DB6B4);
    for (var i = -3; i <= 3; i++) x.drawOval(Rect.fromCenter(center: c, width: r * 1.92 * math.max(.16, 1 - i.abs() * .19), height: r * 1.9), grid);
    for (var i = -2; i <= 2; i++) x.drawArc(Rect.fromCenter(center: c, width: r * 1.94, height: r * (.48 + i.abs() * .18)), 0, math.pi * 2, false, grid);
    x.drawCircle(c, r, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.transparent, const Color(0x9901080D), const Color(0xD8000205)], stops: const [.38, .70, 1]).createShader(sphere));
    final a = phase * math.pi * 2;
    x.drawArc(Rect.fromCircle(center: c, radius: r * 1.035), a, math.pi * .22, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x4BBDD7DF));
    x.drawArc(Rect.fromCircle(center: c, radius: r * 1.012), -2.25, 1.25, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.1..color = const Color(0x739FC9D2));
    x.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .04..color = const Color(0x1E86B7C7));
  }
  @override bool shouldRepaint(covariant _PlanetWorldPainter o) => o.phase != phase;
}
