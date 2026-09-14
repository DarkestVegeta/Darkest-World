import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;
  const GamePlatformPage({super.key, required this.territory, required this.groups});
  @override State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage> with SingleTickerProviderStateMixin {
  int? selected;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 80))..repeat();
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList();
  @override void dispose() { clock.dispose(); super.dispose(); }
  void open(int i) { final p = platforms[i]; Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: p.name, externalPlatformIds: p.externalPlatformIds, navigationPlatforms: platforms, navigationIndex: i))); }

  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _PlatformSpace(clock.value)),
        SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 28, compact ? 12 : 22, compact ? 14 : 28, 0), child: Row(children: [
          InkWell(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0x99FFFFFF)))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${widget.territory.toUpperCase()} / PLATFORM WORLDS', style: const TextStyle(fontSize: 11, letterSpacing: 3.2, color: Colors.white)), const SizedBox(height: 5), const Text('GENERATIONS / ORBITAL ATLAS', style: TextStyle(fontSize: 6.5, letterSpacing: 2.4, color: Color(0x55FFFFFF)))]),
          const Spacer(), Text('${platforms.length.toString().padLeft(2, '0')} WORLDS', style: const TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x55FFFFFF)))
        ]))),
        Center(child: LayoutBuilder(builder: (_, box) {
          final d = math.min(box.maxWidth * (compact ? .96 : .82), box.maxHeight * (compact ? .70 : .78));
          return SizedBox(width: d, height: d, child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _SystemPainter(clock.value, widget.groups.length))),
            for (var i = 0; i < platforms.length; i++) _PlanetNode(platform: platforms[i], index: i, total: platforms.length, selected: selected == i, size: d, phase: clock.value, onTap: () => setState(() => selected = selected == i ? null : i), onOpen: () => open(i)),
            Positioned(left: d * .50 - 25, top: d * .50 - 25, child: const _StarCore()),
          ]);
        })),
        Positioned(left: compact ? 14 : 28, right: compact ? 14 : 28, bottom: compact ? 14 : 22, child: selected == null ? const _Hint() : _Panel(platform: platforms[selected!], index: selected!, total: platforms.length, onClose: () => setState(() => selected = null), onOpen: () => open(selected!))),
      ])),
    );
  }
}

class GamePlatformGroup { final String name; final String subtitle; final List<GamePlatform> platforms; const GamePlatformGroup(this.name, this.subtitle, this.platforms); }
class GamePlatform { final String name; final List<int> externalPlatformIds; const GamePlatform(this.name, this.externalPlatformIds); }

class _PlanetNode extends StatelessWidget {
  final GamePlatform platform; final int index, total; final bool selected; final double size, phase; final VoidCallback onTap, onOpen;
  const _PlanetNode({required this.platform, required this.index, required this.total, required this.selected, required this.size, required this.phase, required this.onTap, required this.onOpen});
  @override Widget build(BuildContext context) {
    final ring = size * (.19 + (index % 5) * .052);
    final a = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + phase * math.pi * .20 * (index.isEven ? 1 : -1);
    final c = size / 2;
    final p = Offset(c + math.cos(a) * ring, c + math.sin(a) * ring);
    final d = selected ? math.max(74, size * .105) : math.max(52, size * .075);
    return Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d + 25, child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, onDoubleTap: onOpen, child: Column(children: [
      SizedBox(width: d, height: d, child: CustomPaint(painter: _PlanetPainter(index, selected, phase))),
      const SizedBox(height: 4),
      Text(platform.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: selected ? 8 : 6.5, letterSpacing: 1.5, color: Colors.white.withValues(alpha: selected ? .95 : .48), fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    ])));
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed; final bool selected; final double phase;
  const _PlanetPainter(this.seed, this.selected, this.phase);
  @override void paint(Canvas x, Size s) {
    final c = s.center(Offset.zero); final r = s.width * .37; final rect = Rect.fromCircle(center: c, radius: r);
    if (selected) x.drawCircle(c, r * 1.58, Paint()..shader = RadialGradient(colors: [const Color(0xFF92A8C0).withValues(alpha: .15), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.58)));
    final light = Alignment(-.42 + math.sin(phase * math.pi * 2 + seed) * .04, -.48);
    final base = [const Color(0xFFB9A99A), const Color(0xFF8C9A9D), const Color(0xFF6D7F8D), const Color(0xFFA08F82), const Color(0xFF778C86)][seed % 5];
    x.drawCircle(c, r, Paint()..shader = RadialGradient(center: light, radius: 1.02, colors: [base.withValues(alpha: .98), base.withValues(alpha: .72), const Color(0xFF202733), const Color(0xFF05070B)]).createShader(rect));
    x.save(); x.clipPath(Path()..addOval(rect));
    final rnd = math.Random(900 + seed * 17);
    for (var i = 0; i < 18; i++) { final px = c.dx + (rnd.nextDouble() * 2 - 1) * r * .88; final py = c.dy + (rnd.nextDouble() * 2 - 1) * r * .88; final rr = 1.2 + rnd.nextDouble() * r * .08; x.drawCircle(Offset(px, py), rr, Paint()..color = Colors.white.withValues(alpha: .035 + rnd.nextDouble() * .055)); }
    final longitude = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x309EADB5);
    for (var i = 0; i < 4; i++) { final dx = (i - 1.5) * r * .32; x.drawOval(Rect.fromCenter(center: c.translate(dx, 0), width: r * (.35 + i * .22), height: r * 1.82), longitude); }
    final terminator = Paint()..shader = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, const Color(0xDD00030A), const Color(0x99000308)]).createShader(Rect.fromLTWH(c.dx - r, c.dy - r, r * 2, r * 2));
    x.drawOval(rect, terminator);
    x.restore();
    x.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.3 : .65..color = const Color(0x689BAAB5));
    if (selected) x.drawArc(Rect.fromCircle(center: c, radius: r * 1.16), -1.8, 1.5, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x7898B0C5));
  }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.seed != seed || old.selected != selected || old.phase != phase;
}

class _SystemPainter extends CustomPainter {
  final double t; final int groups; const _SystemPainter(this.t, this.groups);
  @override void paint(Canvas x, Size s) {
    final c = s.center(Offset.zero); final maxR = s.shortestSide * .43;
    for (var i = 0; i < 5; i++) { final rr = s.shortestSide * (.19 + i * .052); x.drawOval(Rect.fromCenter(center: c, width: rr * 2.0, height: rr * 1.18), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 4 ? 1.0 : .55..color = const Color(0x2493A4B2)); }
    final sweep = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x487D91A3);
    x.drawArc(Rect.fromCircle(center: c, radius: maxR), t * math.pi * 2, .55, false, sweep);
    final axis = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x183F5362);
    for (var i = 0; i < groups + 1; i++) x.drawOval(Rect.fromCenter(center: c, width: maxR * 2 * (.48 + i * .12), height: maxR * 1.15), axis);
  }
  @override bool shouldRepaint(covariant _SystemPainter old) => old.t != t || old.groups != groups;
}

class _StarCore extends StatelessWidget { const _StarCore(); @override Widget build(BuildContext c) => Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFFFFFFFF), Color(0xFFD7C6A1), Color(0xFF74644D), Color(0x00000000)], stops: [0, .25, .5, 1]), boxShadow: const [BoxShadow(color: Color(0x669C8868), blurRadius: 28, spreadRadius: 7)])); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext c) => Center(child: Text('1× CLICK  FOCUS     2× CLICK  ENTER WORLD     •     SCROLL TO ZOOM', style: const TextStyle(color: Color(0x4FFFFFFF), fontSize: 6.5, letterSpacing: 1.9))); }
class _Panel extends StatelessWidget { final GamePlatform platform; final int index,total; final VoidCallback onClose,onOpen; const _Panel({required this.platform,required this.index,required this.total,required this.onClose,required this.onOpen}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.fromLTRB(18,14,10,14), decoration: BoxDecoration(color: const Color(0xED070B11), border: Border.all(color: const Color(0x457C91A1)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 34)]), child: Row(children: [Container(width: 3, height: 45, color: const Color(0x907C91A1)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PLATFORM WORLD  •  ${index+1}/$total', style: const TextStyle(fontSize: 6.5, color: Color(0x55FFFFFF), letterSpacing: 1.8)), const SizedBox(height: 5), Text(platform.name, style: const TextStyle(fontSize: 15, color: Colors.white, letterSpacing: 2.7)), const SizedBox(height: 4), const Text('GENERATION ARCHIVE / GAME CATALOG', style: TextStyle(fontSize: 6.5, color: Color(0x66FFFFFF), letterSpacing: 1.4))])), InkWell(onTap:onClose, child: const Padding(padding: EdgeInsets.all(9), child: Text('×', style: TextStyle(fontSize: 18, color: Color(0x99FFFFFF))))), const SizedBox(width: 4), FilledButton(onPressed:onOpen, child: const Text('ENTER'))])); }
class _PlatformSpace extends CustomPainter { final double t; const _PlatformSpace(this.t); @override void paint(Canvas x, Size s) { final rect=Offset.zero&s; x.drawRect(rect,Paint()..shader=const RadialGradient(center: Alignment(.5,.45),radius:1.15,colors:[Color(0xFF151C27),Color(0xFF070A10),Color(0xFF010207)]).createShader(rect)); final r=math.Random(412); for(var i=0;i<430;i++){final px=(r.nextDouble()*s.width+t*s.width*.012)%s.width;final py=r.nextDouble()*s.height;final a=.025+r.nextDouble()*.075;x.drawCircle(Offset(px,py),.15+r.nextDouble()*.7,Paint()..color=Colors.white.withValues(alpha:a));} final glow=Paint()..shader=RadialGradient(colors:[const Color(0x667F8DA0),Colors.transparent]).createShader(Rect.fromCircle(center:Offset(s.width*.5,s.height*.5),radius:math.min(s.width,s.height)*.48)); x.drawCircle(Offset(s.width*.5,s.height*.5),math.min(s.width,s.height)*.48,glow); } @override bool shouldRepaint(covariant _PlatformSpace old)=>old.t!=t; }
