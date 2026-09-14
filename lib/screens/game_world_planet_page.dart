import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget { const GameWorldPlanetPage({super.key}); @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState(); }

class _TerritoryData {
  final String routeName, displayName, description; final List<GamePlatformGroup> groups; final double x, y;
  const _TerritoryData(this.routeName, this.displayName, this.description, this.groups, this.x, this.y);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 100))..repeat();
  int? selected;
  final territories = const <_TerritoryData>[
    _TerritoryData('NINTENDO', 'NORTHLAND', 'A cool northern territory of forests, lakes and old mountain ranges.', [GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]), GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])])], 24, 29),
    _TerritoryData('SEGA', 'WESTERN REACH', 'A broad western coast with dry plains, forests and a long mountain spine.', [GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]), GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])])], 70, 34),
    _TerritoryData('PLAYSTATION', 'SOUTHERN CONTINENT', 'A deep southern land of warm coasts, river valleys and dense highlands.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])])], 48, 71),
    _TerritoryData('XBOX', 'EASTERN HIGHLANDS', 'A rugged eastern territory shaped by cliffs, plateaus and cold upland lakes.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])])], 77, 57),
  ];
  @override void dispose() { clock.dispose(); super.dispose(); }
  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].routeName, groups: territories[i].groups)));
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(backgroundColor: const Color(0xFF03060A), body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: _MapBackground(clock.value)),
      Positioned(left: compact ? 14 : 38, top: compact ? 14 : 30, child: _Header(back: () => Navigator.pop(context))),
      Center(child: LayoutBuilder(builder: (context, b) {
        final w = b.maxWidth * (compact ? .96 : .89), h = math.min(b.maxHeight * (compact ? .79 : .84), w * .64);
        return SizedBox(width: w, height: h, child: Stack(children: [Positioned.fill(child: CustomPaint(painter: _WorldMapPainter(clock.value))), for (var i = 0; i < territories.length; i++) _TerritoryNode(data: territories[i], selected: selected == i, onTap: () => setState(() => selected = i), onOpen: () => enter(i))]));
      })),
      if (selected != null) Positioned(left: compact ? 16 : 38, right: compact ? 16 : 38, bottom: compact ? 16 : 28, child: _Info(data: territories[selected!], index: selected!, close: () => setState(() => selected = null)))
      else const Positioned(left: 0, right: 0, bottom: 28, child: Center(child: Text('1× CLICK  FOCUS     2× CLICK  ENTER REGION', style: TextStyle(color: Color(0x58FFFFFF), fontSize: 7, letterSpacing: 2)))),
    ])));
  }
}

class _Header extends StatelessWidget { final VoidCallback back; const _Header({required this.back}); @override Widget build(BuildContext c) => Row(children: [InkWell(onTap: back, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0x90FFFFFF)))), const SizedBox(width: 7), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GAME-WORLD', style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 4.8)), SizedBox(height: 7), Text('WORLD MAP / REGIONS', style: TextStyle(color: Color(0x72FFFFFF), fontSize: 7, letterSpacing: 3.1))])]); }

class _TerritoryNode extends StatelessWidget {
  final _TerritoryData data; final bool selected; final VoidCallback onTap, onOpen;
  const _TerritoryNode({required this.data, required this.selected, required this.onTap, required this.onOpen});
  @override Widget build(BuildContext c) => LayoutBuilder(builder: (context, b) { final p = Offset(b.maxWidth * data.x / 100, b.maxHeight * data.y / 100), d = b.maxWidth * (selected ? .13 : .095); return Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d, child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, onDoubleTap: onOpen, child: CustomPaint(painter: _NodePainter(data.displayName, selected))))); });
}

class _NodePainter extends CustomPainter {
  final String name; final bool selected; const _NodePainter(this.name, this.selected);
  @override void paint(Canvas x, Size s) { final c = s.center(Offset.zero), r = s.width * .29, glow = r * (selected ? 4.8 : 2.5); x.drawCircle(c, glow, Paint()..shader = RadialGradient(colors: [const Color(0xFF8EA7BE).withValues(alpha: selected ? .24 : .07), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: glow))); x.drawCircle(c, r, Paint()..shader = const RadialGradient(center: Alignment(-.35, -.4), colors: [Color(0xFFE8E0EA), Color(0xFF71818E), Color(0xFF151B22)]).createShader(Rect.fromCircle(center: c, radius: r))); x.drawCircle(c, r * 1.34, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.6 : .55..color = const Color(0x5599AAB8)); final tp = TextPainter(text: TextSpan(text: name, style: TextStyle(color: Colors.white.withValues(alpha: selected ? .96 : .68), fontSize: math.max(6.5, s.width * .043), letterSpacing: 1.5, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 1.9); tp.paint(x, Offset(c.dx - tp.width / 2, s.height * .68)); }
  @override bool shouldRepaint(covariant _NodePainter o) => o.name != name || o.selected != selected;
}

class _Info extends StatelessWidget {
  final _TerritoryData data; final int index; final VoidCallback close; const _Info({required this.data, required this.index, required this.close});
  @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.fromLTRB(20, 16, 12, 16), decoration: BoxDecoration(color: const Color(0xE0090C11), border: Border.all(color: const Color(0x35FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 38)]), child: Row(children: [Container(width: 3, height: 52, decoration: BoxDecoration(color: const Color(0x887F98AD), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('REGION ${(index + 1).toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x58FFFFFF), fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 5), Text(data.displayName, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3)), const SizedBox(height: 5), Text(data.description, style: const TextStyle(color: Color(0x78FFFFFF), fontSize: 8))])), InkWell(onTap: close, child: const Padding(padding: EdgeInsets.all(9), child: Text('×', style: TextStyle(color: Color(0x90FFFFFF), fontSize: 19))))]));
}

class _MapBackground extends CustomPainter {
  final double phase; const _MapBackground(this.phase);
  @override void paint(Canvas x, Size s) { final rect = Offset.zero & s; x.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF03060A), Color(0xFF0A1017), Color(0xFF03050A)]).createShader(rect)); final r = math.Random(410); for (var i = 0; i < 360; i++) x.drawCircle(Offset(r.nextDouble() * s.width, r.nextDouble() * s.height), .15 + r.nextDouble() * .7, Paint()..color = Colors.white.withValues(alpha: .015 + r.nextDouble() * .06)); final c = Offset(s.width * .5, s.height * .5), g = math.min(s.width, s.height) * .66; x.drawCircle(c, g, Paint()..shader = RadialGradient(colors: [const Color(0xFF5D7A95).withValues(alpha: .055), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: g))); }
  @override bool shouldRepaint(covariant _MapBackground o) => o.phase != phase;
}

class _WorldMapPainter extends CustomPainter {
  final double phase; const _WorldMapPainter(this.phase);
  Path shape(Size s, List<Offset> pts) { final p = Path()..moveTo(pts.first.dx * s.width, pts.first.dy * s.height); for (var i = 1; i < pts.length; i++) p.lineTo(pts[i].dx * s.width, pts[i].dy * s.height); return p..close(); }
  @override void paint(Canvas x, Size s) {
    final rect = Offset.zero & s;
    x.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(34)), Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B1A25), Color(0xFF142A35), Color(0xFF09151E)]).createShader(rect));
    final rnd = math.Random(991);
    final land = <Path>[
      shape(s, [const Offset(.03,.18), const Offset(.11,.10), const Offset(.23,.13), const Offset(.30,.23), const Offset(.27,.37), const Offset(.17,.44), const Offset(.07,.38)]),
      shape(s, [const Offset(.35,.07), const Offset(.48,.04), const Offset(.61,.10), const Offset(.67,.22), const Offset(.61,.34), const Offset(.49,.37), const Offset(.38,.29)]),
      shape(s, [const Offset(.72,.14), const Offset(.88,.12), const Offset(.98,.23), const Offset(.94,.39), const Offset(.81,.49), const Offset(.69,.40), const Offset(.66,.27)]),
      shape(s, [const Offset(.25,.51), const Offset(.39,.45), const Offset(.55,.49), const Offset(.64,.62), const Offset(.60,.79), const Offset(.50,.91), const Offset(.35,.87), const Offset(.27,.71)]),
      shape(s, [const Offset(.69,.55), const Offset(.82,.50), const Offset(.95,.61), const Offset(.92,.80), const Offset(.79,.89), const Offset(.66,.79), const Offset(.63,.65)]),
    ];
    final fills = [const Color(0xFF3C5549), const Color(0xFF46523E), const Color(0xFF3E4C57), const Color(0xFF4E443F), const Color(0xFF3B5149)];
    for (var i = 0; i < land.length; i++) { x.drawPath(land[i], Paint()..color = fills[i]); x.drawPath(land[i], Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x4B9DA99A)); }
    // Rivers and natural region boundaries.
    final river = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0x496B9FB1);
    final river2 = Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0x365E8B9B);
    for (var i = 0; i < 8; i++) { final path = Path()..moveTo(s.width * (.08 + i * .105), s.height * (.08 + (i % 2) * .06)); for (var j = 1; j <= 6; j++) path.quadraticBezierTo(s.width * (.08 + i * .105 + math.sin(j + i) * .055), s.height * (.12 + j * .115), s.width * (.09 + i * .105), s.height * (.16 + j * .11)); x.drawPath(path, river2); }
    x.drawPath(Path()..moveTo(s.width*.48,s.height*.08)..cubicTo(s.width*.40,s.height*.28,s.width*.54,s.height*.42,s.width*.45,s.height*.58)..cubicTo(s.width*.38,s.height*.70,s.width*.51,s.height*.81,s.width*.46,s.height*.94), river);
    // Mountain chains.
    final mountain = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x586C756C);
    for (var i = 0; i < 7; i++) { final path = Path()..moveTo(s.width*(.07+i*.13),s.height*(.16+(i%3)*.06)); for (var j=0;j<5;j++) { path.lineTo(s.width*(.10+i*.13+j*.018),s.height*(.11+j*.055)); } x.drawPath(path,mountain); }
    // Forest clusters, kept abstract and generic.
    for (var i = 0; i < 145; i++) { final px = .06 + rnd.nextDouble()*.88, py = .10 + rnd.nextDouble()*.80; if ((px>.31&&px<.67&&py>.38&&py<.48) || (px>.61&&py>.50)) continue; final rr = .8 + rnd.nextDouble()*1.9; x.drawCircle(Offset(px*s.width,py*s.height), rr, Paint()..color = Color(0x384A6956)); }
    // Dry region texture.
    for (var i = 0; i < 80; i++) { final px = (.69 + rnd.nextDouble()*.24)*s.width, py = (.13 + rnd.nextDouble()*.32)*s.height; x.drawLine(Offset(px,py), Offset(px+4,py-1), Paint()..color = const Color(0x344E5A42)..strokeWidth = .7); }
    // Coastal contour lines and subtle latitude-like map texture.
    final contour = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x1F9BB1B6);
    for (var i = 0; i < 9; i++) { final yy = s.height*(.08+i*.105)+math.sin(phase*math.pi*2+i)*2; x.drawArc(Rect.fromLTWH(-s.width*.08,yy,s.width*1.16,s.height*.20),math.pi*1.02,math.pi*.96,false,contour); }
    x.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(34)), Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0x397D93A0));
    final scanY = (.12 + phase*.76)*s.height; x.drawLine(Offset(s.width*.06,scanY), Offset(s.width*.94,scanY), Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x18D2E2E7));
    // Four small natural landmarks; no platform or franchise iconography.
    for (final p in [Offset(.18,.27),Offset(.53,.20),Offset(.82,.33),Offset(.45,.68),Offset(.77,.70)]) { final c=Offset(p.dx*s.width,p.dy*s.height); x.drawCircle(c,3.2,Paint()..color=const Color(0x70B4C0B4)); x.drawCircle(c,7,Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x264D6C73)); }
  }
  @override bool shouldRepaint(covariant _WorldMapPainter o) => o.phase != phase;
}
