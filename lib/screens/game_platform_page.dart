import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;
  const GamePlatformPage({super.key, required this.territory, required this.groups});
  @override State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage> {
  int? hovered;
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList(growable: false);

  void _open(int index) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
    territory: widget.territory,
    platform: platforms[index].name,
    externalPlatformIds: platforms[index].externalPlatformIds,
    navigationPlatforms: platforms,
    navigationIndex: index,
  )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        final width = math.min(constraints.maxWidth * .94, 1280.0);
        final height = math.min(constraints.maxHeight * .78, 720.0);
        final center = Offset(width / 2, height / 2);
        final positions = _positions(center, width, height, platforms.length);
        return Stack(children: [
          const Positioned.fill(child: CustomPaint(painter: _PlatformWorldPainter())),
          SafeArea(child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 28, compact ? 12 : 22, 20, 0),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
              const SizedBox(width: 5),
              Text(widget.territory.toUpperCase(), style: const TextStyle(fontSize: 14, letterSpacing: 4)),
              Text('  /  WORLDS', style: TextStyle(fontSize: 8, letterSpacing: 2.6, color: Colors.white.withValues(alpha: .28))),
            ]),
          )),
          Center(child: SizedBox(width: width, height: height, child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: CustomPaint(painter: _PlatformLandscapePainter(center: center, positions: positions))),
            for (var i = 0; i < platforms.length; i++)
              Positioned(
                left: positions[i].dx - 58,
                top: positions[i].dy - 58,
                child: _PlatformNode(
                  platform: platforms[i], selected: hovered == i, compact: compact,
                  onEnter: () => setState(() => hovered = i),
                  onExit: () => setState(() => hovered = null),
                  onTap: () => _open(i),
                ),
              ),
            Positioned(left: center.dx - 78, top: center.dy - 78, child: _WorldCore(territory: widget.territory, count: platforms.length)),
          ]))),
          if (hovered != null)
            Positioned(left: 0, right: 0, bottom: compact ? 18 : 28, child: IgnorePointer(child: Center(child: Text(
              '${platforms[hovered!].name.toUpperCase()}  •  ENTER WORLD',
              style: TextStyle(fontSize: 9, letterSpacing: 3, color: Colors.white.withValues(alpha: .52)),
            )))),
        ]);
      }),
    );
  }

  List<Offset> _positions(Offset c, double w, double h, int count) {
    final result = <Offset>[];
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / math.max(1, count);
      final depth = i % 3;
      final rx = w * (depth == 0 ? .35 : depth == 1 ? .27 : .19);
      final ry = h * (depth == 0 ? .31 : depth == 1 ? .24 : .17);
      result.add(Offset(c.dx + math.cos(a) * rx, c.dy + math.sin(a) * ry));
    }
    return result;
  }
}

class GamePlatformGroup {
  final String name;
  final String subtitle;
  final List<GamePlatform> platforms;
  const GamePlatformGroup(this.name, this.subtitle, this.platforms);
}

class GamePlatform {
  final String name;
  final List<int> externalPlatformIds;
  const GamePlatform(this.name, this.externalPlatformIds);
}

class _PlatformNode extends StatelessWidget {
  final GamePlatform platform;
  final bool selected, compact;
  final VoidCallback onEnter, onExit, onTap;
  const _PlatformNode({required this.platform, required this.selected, required this.compact, required this.onEnter, required this.onExit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = selected ? 122.0 : (compact ? 82.0 : 96.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(), onExit: (_) => onExit(),
      child: GestureDetector(onTap: onTap, child: SizedBox(width: 116, height: 116, child: Stack(alignment: Alignment.center, children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              const Color(0xFF8572A9).withValues(alpha: selected ? .38 : .20),
              const Color(0xFF252237).withValues(alpha: .78),
              const Color(0xFF05060C),
            ]),
            border: Border.all(color: Colors.white.withValues(alpha: selected ? .26 : .09), width: selected ? 1.2 : .7),
            boxShadow: selected ? [BoxShadow(color: const Color(0xFF8C72B7).withValues(alpha: .18), blurRadius: 28, spreadRadius: 3)] : const [],
          ),
          child: CustomPaint(painter: _NodeTerrainPainter(seed: platform.name.hashCode)),
        ),
        Text(platform.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: selected ? 10 : 8, letterSpacing: selected ? 1.5 : 1, color: Colors.white.withValues(alpha: selected ? .94 : .60), shadows: const [Shadow(color: Colors.black, blurRadius: 10)])),
      ])),
    );
  }
}

class _WorldCore extends StatelessWidget {
  final String territory; final int count;
  const _WorldCore({required this.territory, required this.count});
  @override
  Widget build(BuildContext context) => Container(width: 156, height: 156,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF302A45), Color(0xFF0B0A12), Color(0xFF020208)]), border: Border.all(color: Colors.white.withValues(alpha: .16)), boxShadow: [BoxShadow(color: const Color(0xFF75609B).withValues(alpha: .12), blurRadius: 46, spreadRadius: 5)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(territory.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 2.7)), const SizedBox(height: 8), Text('WORLD', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .32))), const SizedBox(height: 12), Text('$count WORLDS', style: TextStyle(fontSize: 7, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .22)))]));
}

class _PlatformWorldPainter extends CustomPainter {
  const _PlatformWorldPainter();
  @override
  void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.05), radius: 1.15, colors: [Color(0xFF17142A), Color(0xFF06060D), Color(0xFF010106)]).createShader(rect));
    final q = math.Random(412); final p = Paint();
    for (var i = 0; i < 260; i++) { p.color = Colors.white.withValues(alpha: .025 + q.nextDouble() * .13); c.drawCircle(Offset(q.nextDouble() * s.width, q.nextDouble() * s.height), .2 + q.nextDouble() * .7, p); }
    c.drawOval(Rect.fromCenter(center: s.center(Offset.zero), width: s.width * .78, height: s.height * .66), Paint()..shader = RadialGradient(colors: [const Color(0xFF70599A).withValues(alpha: .055), Colors.transparent]).createShader(Rect.fromCenter(center: s.center(Offset.zero), width: s.width * .78, height: s.height * .66)));
  }
  @override bool shouldRepaint(covariant _PlatformWorldPainter old) => false;
}

class _PlatformLandscapePainter extends CustomPainter {
  final Offset center; final List<Offset> positions;
  const _PlatformLandscapePainter({required this.center, required this.positions});
  @override
  void paint(Canvas c, Size s) {
    final route = Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0xFF8C7BA5).withValues(alpha: .07);
    for (final point in positions) { final path = Path()..moveTo(center.dx, center.dy)..quadraticBezierTo((center.dx + point.dx) / 2, point.dy, point.dx, point.dy); c.drawPath(path, route); }
    final inner = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0xFF9B8BB7).withValues(alpha: .055);
    c.drawCircle(center, math.min(s.width, s.height) * .20, inner);
  }
  @override bool shouldRepaint(covariant _PlatformLandscapePainter old) => false;
}

class _NodeTerrainPainter extends CustomPainter {
  final int seed;
  const _NodeTerrainPainter({required this.seed});
  @override
  void paint(Canvas c, Size s) {
    final r = s.width / 2; final center = s.center(Offset.zero); final q = math.Random(seed); final paint = Paint();
    for (var i = 0; i < 5; i++) {
      final o = center + Offset((q.nextDouble() * 2 - 1) * r * .45, (q.nextDouble() * 2 - 1) * r * .45);
      final rx = r * (.18 + q.nextDouble() * .24), ry = r * (.09 + q.nextDouble() * .16); final path = Path();
      for (var j = 0; j < 12; j++) { final a = j / 12 * math.pi * 2; final w = .78 + q.nextDouble() * .32; final p = Offset(o.dx + math.cos(a) * rx * w, o.dy + math.sin(a) * ry * w); if (j == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy); }
      path.close(); paint.color = const Color(0xFF9A8D88).withValues(alpha: .07 + q.nextDouble() * .10); c.drawPath(path, paint);
    }
  }
  @override bool shouldRepaint(covariant _NodeTerrainPainter old) => false;
}
