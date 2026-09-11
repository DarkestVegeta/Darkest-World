import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;

  const GamePlatformPage({super.key, required this.territory, required this.groups});

  @override
  State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 80),
  )..repeat();
  int? hovered;

  List<GamePlatform> get platforms =>
      widget.groups.expand((group) => group.platforms).toList(growable: false);

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _openPlatform(GamePlatform platform) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameListPage(
        territory: widget.territory,
        platform: platform.name,
        externalPlatformIds: platform.externalPlatformIds,
        navigationPlatforms: platforms,
        navigationIndex: platforms.indexOf(platform),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        final width = math.min(constraints.maxWidth * .96, 1320.0);
        final height = math.min(constraints.maxHeight * .78, 720.0);
        final center = Offset(width / 2, height / 2);
        final positions = <Offset>[];
        final count = platforms.length;
        for (var i = 0; i < count; i++) {
          final angle = -math.pi / 2 + i * math.pi * 2 / math.max(1, count);
          final ring = i % 3 == 0 ? .82 : (i % 3 == 1 ? .62 : .42);
          positions.add(Offset(
            center.dx + math.cos(angle) * width * .36 * ring,
            center.dy + math.sin(angle) * height * .37 * ring,
          ));
        }

        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PlatformWorldPainter(_motion))),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(compact ? 16 : 30, compact ? 14 : 24, 16, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                  ),
                  const SizedBox(width: 6),
                  Text(widget.territory.toUpperCase(), style: const TextStyle(letterSpacing: 4, fontSize: 14)),
                  Text('  /  PLATFORM WORLD', style: TextStyle(letterSpacing: 2.4, fontSize: 9, color: Colors.white.withValues(alpha: .34))),
                ]),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PlatformRoutesPainter(center: center, positions: positions)),
                ),
                for (var i = 0; i < count; i++)
                  Positioned(
                    left: positions[i].dx - 58,
                    top: positions[i].dy - 58,
                    child: _PlatformNode(
                      platform: platforms[i],
                      index: i,
                      selected: hovered == i,
                      compact: compact,
                      onEnter: () => setState(() => hovered = i),
                      onExit: () => setState(() => hovered = null),
                      onTap: () => _openPlatform(platforms[i]),
                    ),
                  ),
                Positioned(
                  left: center.dx - 82,
                  top: center.dy - 82,
                  child: _PlatformHub(
                    territory: widget.territory,
                    count: count,
                  ),
                ),
              ]),
            ),
          ),
          if (hovered != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: compact ? 22 : 30,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    '${platforms[hovered!].name.toUpperCase()}  •  ENTER PLATFORM',
                    style: TextStyle(letterSpacing: 3.2, fontSize: 9, color: Colors.white.withValues(alpha: .58)),
                  ),
                ),
              ),
            ),
        ]);
      }),
    );
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
  final int index;
  final bool selected;
  final bool compact;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _PlatformNode({
    required this.platform,
    required this.index,
    required this.selected,
    required this.compact,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = selected ? 132.0 : (compact ? 88.0 : 104.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 116,
          height: 116,
          alignment: Alignment.center,
          child: Stack(alignment: Alignment.center, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF8C70C0).withValues(alpha: selected ? .55 : .28),
                  const Color(0xFF1B1830).withValues(alpha: .88),
                  const Color(0xFF06060D),
                ]),
                border: Border.all(
                  color: Colors.white.withValues(alpha: selected ? .28 : .10),
                  width: selected ? 1.4 : .8,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: const Color(0xFF8D6BC7).withValues(alpha: .28), blurRadius: 30, spreadRadius: 4)]
                    : const [],
              ),
              child: CustomPaint(painter: _NodeTerrainPainter(seed: index * 31 + 8)),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 105),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                platform.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: selected ? 10 : 8,
                  letterSpacing: selected ? 1.6 : 1.1,
                  color: Colors.white.withValues(alpha: selected ? .95 : .66),
                  shadows: const [Shadow(color: Colors.black, blurRadius: 12)],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PlatformHub extends StatelessWidget {
  final String territory;
  final int count;
  const _PlatformHub({required this.territory, required this.count});

  @override
  Widget build(BuildContext context) => Container(
        width: 164,
        height: 164,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Color(0xFF302A4A), Color(0xFF0B0A13), Color(0xFF030309)]),
          border: Border.all(color: const Color(0xFFB19BD5).withValues(alpha: .25)),
          boxShadow: [BoxShadow(color: const Color(0xFF8060B5).withValues(alpha: .18), blurRadius: 50, spreadRadius: 8)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(territory.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('PLATFORM HUB', style: TextStyle(fontSize: 8, letterSpacing: 2.2, color: Colors.white.withValues(alpha: .38))),
          const SizedBox(height: 13),
          Text('$count WORLDS', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Colors.white.withValues(alpha: .25))),
        ]),
      );

class _PlatformWorldPainter extends CustomPainter {
  final Animation<double> animation;
  _PlatformWorldPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.05), radius: 1.15,
      colors: [Color(0xFF17132A), Color(0xFF06050C), Color(0xFF010106)],
    ).createShader(rect));

    final random = math.Random(412);
    final stars = Paint();
    for (var i = 0; i < 260; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final pulse = .65 + .35 * math.sin(animation.value * math.pi * 2 + i);
      stars.color = Colors.white.withValues(alpha: (.015 + random.nextDouble() * .16) * pulse);
      canvas.drawCircle(p, .25 + random.nextDouble() * .8, stars);
    }

    final glow = Paint()..shader = RadialGradient(colors: [
      const Color(0xFF7356A1).withValues(alpha: .07),
      Colors.transparent,
    ]).createShader(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * .85, height: size.height * .75));
    canvas.drawOval(Rect.fromCenter(center: size.center(Offset.zero), width: size.width * .85, height: size.height * .75), glow);
  }

  @override
  bool shouldRepaint(covariant _PlatformWorldPainter oldDelegate) => false;
}

class _PlatformRoutesPainter extends CustomPainter {
  final Offset center;
  final List<Offset> positions;
  _PlatformRoutesPainter({required this.center, required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = const Color(0xFF9B82C1).withValues(alpha: .075);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .72, height: size.height * .72), orbit);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .50, height: size.height * .50), orbit);

    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65
      ..color = const Color(0xFF8297B7).withValues(alpha: .08);
    for (final point in positions) {
      final path = Path()..moveTo(center.dx, center.dy);
      final mid = Offset((center.dx + point.dx) / 2, point.dy);
      path.quadraticBezierTo(mid.dx, mid.dy, point.dx, point.dy);
      canvas.drawPath(path, route);
    }
  }

  @override
  bool shouldRepaint(covariant _PlatformRoutesPainter oldDelegate) => false;
}

class _NodeTerrainPainter extends CustomPainter {
  final int seed;
  _NodeTerrainPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final random = math.Random(seed);
    final terrain = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final cx = c.dx + (random.nextDouble() * 2 - 1) * r * .48;
      final cy = c.dy + (random.nextDouble() * 2 - 1) * r * .48;
      final rw = r * (.22 + random.nextDouble() * .24);
      final rh = r * (.10 + random.nextDouble() * .20);
      final path = Path();
      for (var p = 0; p < 9; p++) {
        final a = p / 9 * math.pi * 2;
        final wobble = .72 + random.nextDouble() * .4;
        final x = cx + math.cos(a) * rw * wobble;
        final y = cy + math.sin(a) * rh * wobble;
        if (p == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      terrain.color = const Color(0xFF8D7E76).withValues(alpha: .12 + random.nextDouble() * .12);
      canvas.drawPath(path, terrain);
    }
  }

  @override
  bool shouldRepaint(covariant _NodeTerrainPainter oldDelegate) => false;
}
