import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestGalaxy extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestGalaxy({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestGalaxy> createState() => _DarkestGalaxyState();
}

class _DarkestGalaxyState extends State<DarkestGalaxy> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  int? selected;
  double zoom = 1;

  @override
  void dispose() { _motion.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final compact = c.maxWidth < 800;
      return Stack(fit: StackFit.expand, children: [
        RepaintBoundary(child: CustomPaint(painter: _GalaxyPainter(_motion))),
        InteractiveViewer(
          minScale: .82, maxScale: 1.35, panEnabled: true, scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(140),
          child: Transform.scale(
            scale: zoom,
            child: _GalaxyMap(compact: compact, worlds: widget.worlds, selected: selected, onSelect: (i) => setState(() => selected = i)),
          ),
        ),
        Positioned(left: 28, top: 24, child: _GalaxyHeading()),
        Positioned(right: 22, bottom: 24, child: _GalaxyHint()),
        if (selected != null) Align(alignment: Alignment.bottomCenter, child: _WorldPanel(
          world: widget.worlds[selected!],
          onClose: () => setState(() => selected = null),
          onEnter: () => widget.onWorldTap?.call(widget.worlds[selected!]),
        )),
      ]);
    });
  }
}

class _GalaxyMap extends StatelessWidget {
  final bool compact;
  final List<GalaxyWorld> worlds;
  final int? selected;
  final ValueChanged<int> onSelect;
  const _GalaxyMap({required this.compact, required this.worlds, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final w = compact ? 760.0 : 1320.0;
    final h = compact ? 760.0 : 820.0;
    final positions = compact
        ? const [Offset(380,300), Offset(110,110), Offset(565,105), Offset(100,420), Offset(575,405), Offset(260,560), Offset(400,120), Offset(620,590), Offset(170,650)]
        : const [Offset(620,330), Offset(165,180), Offset(545,65), Offset(1015,160), Offset(105,515), Offset(1000,475), Offset(410,620), Offset(760,135), Offset(1170,600)];
    final sizes = compact ? const [220.0,100,94,112,108,96,82,102,88] : const [330.0,128,118,132,126,120,110,118,108];
    return SizedBox(width: w, height: h, child: Stack(children: [
      CustomPaint(size: Size(w, h), painter: _OrbitPainter()),
      for (var i = 0; i < worlds.length && i < positions.length; i++) Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: _PlanetNode(world: worlds[i], size: sizes[i], central: i == 0, selected: selected == i, onTap: () => onSelect(i)),
      ),
    ]));
  }
}

class _PlanetNode extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool central, selected;
  final VoidCallback onTap;
  const _PlanetNode({required this.world, required this.size, required this.central, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: SizedBox(width: size + 180, height: size + 70, child: Stack(clipBehavior: Clip.none, children: [
      if (selected) Positioned(left: -12, top: -12, child: Container(
        width: size + 24, height: size + 24,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF9D70FF).withValues(alpha: .5)), boxShadow: [BoxShadow(color: const Color(0xFF713BFF).withValues(alpha: .28), blurRadius: 45, spreadRadius: 8)]),
      )),
      Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: const Alignment(-.38, -.38), colors: _colors(world.kind), stops: const [0, .48, 1]),
          boxShadow: [BoxShadow(color: const Color(0xFF6B40B5).withValues(alpha: central ? .34 : .18), blurRadius: central ? 85 : 35, spreadRadius: central ? 12 : 2)],
        ),
        child: CustomPaint(painter: _PlanetPainter(seed: world.kind.index * 47 + 13, damaged: world.kind == GalaxyWorldKind.vegeta, central: central)),
      ),
      Positioned(left: size + 16, top: size * .48, child: _WorldLabel(world.title, active: central || selected)),
    ]));
  }

  List<Color> _colors(GalaxyWorldKind k) { switch (k) {
    case GalaxyWorldKind.vegeta: return const [Color(0xFF7252A8), Color(0xFF241B39), Color(0xFF05030A)];
    case GalaxyWorldKind.game: return const [Color(0xFF6750B0), Color(0xFF29205A), Color(0xFF070511)];
    case GalaxyWorldKind.music: return const [Color(0xFF4D7FBA), Color(0xFF203B68), Color(0xFF050914)];
    case GalaxyWorldKind.identity: return const [Color(0xFF8654A8), Color(0xFF321D48), Color(0xFF08040D)];
    case GalaxyWorldKind.family: return const [Color(0xFF6283A8), Color(0xFF27384D), Color(0xFF060A11)];
    case GalaxyWorldKind.cinema: return const [Color(0xFF8A67A9), Color(0xFF38264B), Color(0xFF09060D)];
    case GalaxyWorldKind.creation: return const [Color(0xFF557DB4), Color(0xFF253D68), Color(0xFF050A13)];
    case GalaxyWorldKind.archive: return const [Color(0xFF766D8D), Color(0xFF302C3D), Color(0xFF09080D)];
    case GalaxyWorldKind.comingSoon: return const [Color(0xFF9A73D2), Color(0xFF3C285D), Color(0xFF0A0611)];
  }}
}

class _WorldLabel extends StatelessWidget {
  final String text;
  final bool active;
  const _WorldLabel(this.text, {required this.active});
  @override Widget build(BuildContext context) => Text(text, style: TextStyle(fontSize: active ? 11 : 9, letterSpacing: active ? 2.8 : 2.0, color: Colors.white.withValues(alpha: active ? .9 : .58), shadows: const [Shadow(color: Colors.black, blurRadius: 14)]));
}

class _GalaxyHeading extends StatelessWidget {
  @override Widget build(BuildContext context) => IgnorePointer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKESTWORLD', style: TextStyle(fontSize: 15, letterSpacing: 6, color: Colors.white.withValues(alpha: .82))), const SizedBox(height: 5), Text('GALAXY', style: TextStyle(fontSize: 8, letterSpacing: 4, color: Colors.white.withValues(alpha: .34)))]));
}

class _GalaxyHint extends StatelessWidget {
  @override Widget build(BuildContext context) => IgnorePointer(child: Text('DRAG • ZOOM • EXPLORE', style: TextStyle(fontSize: 8, letterSpacing: 2.6, color: Colors.white.withValues(alpha: .28))));
}

enum GalaxyWorldKind { vegeta, game, music, identity, family, cinema, creation, archive, comingSoon }
class GalaxyWorld { final String title; final String description; final GalaxyWorldKind kind; const GalaxyWorld(this.title, this.description, this.kind); }

class _GalaxyPainter extends CustomPainter {
  final Animation<double> animation;
  _GalaxyPainter(this.animation): super(repaint: animation);
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.1, colors: [Color(0xFF140C24), Color(0xFF05030B), Color(0xFF010106)]).createShader(rect));
    final center = Offset(size.width * .5, size.height * .5);
    canvas.drawCircle(center, size.longestSide * .42, Paint()..shader = RadialGradient(colors: [const Color(0xFF8B55C9).withValues(alpha: .11), const Color(0xFF345FA7).withValues(alpha: .045), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: size.longestSide * .42)));
    final random = math.Random(731);
    final star = Paint();
    for (var i = 0; i < 650; i++) { final x = random.nextDouble() * size.width, y = random.nextDouble() * size.height, p = .25 + .75 * ((math.sin(animation.value * math.pi * 2 + i * 1.37) + 1) / 2); star.color = Colors.white.withValues(alpha: (.035 + random.nextDouble() * .27) * p); canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.25, star); }
    final dust = Paint()..color = const Color(0xFF8A69C9).withValues(alpha: .13);
    final rx = size.width * .34, ry = size.height * .20;
    for (var i = 0; i < 65; i++) { final a = animation.value * math.pi * 2 + i * math.pi * 2 / 65; canvas.drawCircle(center + Offset(math.cos(a) * rx, math.sin(a) * ry), .9, dust); }
  }
  @override bool shouldRepaint(covariant _GalaxyPainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final c = Offset(size.width * .5, size.height * .46); final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF8362B8).withValues(alpha: .09); for (final r in [180.0, 290, 390]) { canvas.drawOval(Rect.fromCenter(center: c, width: r * 2, height: r * .62), p); } }
  @override bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final int seed; final bool damaged, central;
  _PlanetPainter({required this.seed, required this.damaged, required this.central});
  @override void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.width / 2, random = math.Random(seed);
    final haze = Paint()..color = Colors.white.withValues(alpha: central ? .045 : .035);
    for (var i = 0; i < 7; i++) { final y = c.dy - r * .66 + i * r * .21; canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, y), width: r * (1.25 + i * .08), height: r * .10), haze); }
    final detail = Paint();
    for (var i = 0; i < (central ? 85 : 38); i++) { final x = c.dx + (random.nextDouble() * 2 - 1) * r * .82, y = c.dy + (random.nextDouble() * 2 - 1) * r * .82; if ((Offset(x, y) - c).distance < r * .88) { detail.color = Colors.white.withValues(alpha: .025 + random.nextDouble() * .05); canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5, detail); } }
    if (damaged) { final crack = Paint()..color = const Color(0xFF0C0712).withValues(alpha: .7)..style = PaintingStyle.stroke..strokeWidth = r * .014; final path = Path()..moveTo(c.dx-r*.56,c.dy-r*.08)..lineTo(c.dx-r*.18,c.dy+r*.02)..lineTo(c.dx-r*.31,c.dy+r*.34)..moveTo(c.dx+r*.04,c.dy-r*.60)..lineTo(c.dx-r*.02,c.dy-r*.20)..lineTo(c.dx+r*.28,c.dy+r*.10)..moveTo(c.dx+r*.43,c.dy+r*.34)..lineTo(c.dx+r*.17,c.dy+r*.20); canvas.drawPath(path, crack); }
  }
  @override bool shouldRepaint(covariant _PlanetPainter oldDelegate) => false;
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world; final VoidCallback onClose, onEnter;
  const _WorldPanel({required this.world, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(width: math.min(MediaQuery.sizeOf(context).width-40,520),margin:const EdgeInsets.only(bottom:22),padding:const EdgeInsets.fromLTRB(20,17,12,17),decoration:BoxDecoration(color:const Color(0xFF08050D).withValues(alpha:.95),borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFF9367D0).withValues(alpha:.25)),boxShadow:[BoxShadow(color:const Color(0xFF713FB0).withValues(alpha:.15),blurRadius:40)]),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(world.title,style:const TextStyle(fontSize:13,letterSpacing:2.7)),const SizedBox(height:6),Text(world.description,style:TextStyle(fontSize:11,height:1.45,color:Colors.white.withValues(alpha:.48)))])),IconButton(onPressed:onClose,icon:const Icon(Icons.close,size:17)),TextButton(onPressed:onEnter,child:const Text('ENTER'))]));
}
