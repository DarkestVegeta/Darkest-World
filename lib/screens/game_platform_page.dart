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
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 28))..repeat();
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList();

  @override void dispose() { _clock.dispose(); super.dispose(); }

  void open(int index) {
    final p = platforms[index];
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
      territory: widget.territory,
      platform: p.name,
      externalPlatformIds: p.externalPlatformIds,
      navigationPlatforms: platforms,
      navigationIndex: index,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: LayoutBuilder(builder: (context, box) {
        final compact = box.maxWidth < 850;
        final width = math.min(box.maxWidth * .94, 1320.0);
        final height = math.min(box.maxHeight * .78, 760.0);
        final center = Offset(width / 2, height / 2);
        final positions = _positions(center, width, height, platforms.length, _clock.value);
        return AnimatedBuilder(
          animation: _clock,
          builder: (context, _) => Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _PlatformBackgroundPainter(t: _clock.value))),
            SafeArea(child: Padding(
              padding: EdgeInsets.all(compact ? 14 : 26),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
                const SizedBox(width: 8),
                Text('${widget.territory.toUpperCase()} / WORLDS', style: const TextStyle(fontSize: 13, letterSpacing: 3.5)),
                const Spacer(),
                Text('${platforms.length} PLATFORMS', style: const TextStyle(fontSize: 8, letterSpacing: 2.3, color: Colors.white24)),
              ]),
            )),
            Center(child: SizedBox(
              width: width,
              height: height,
              child: Stack(children: [
                CustomPaint(size: Size(width, height), painter: _OrbitalPainter(center: center, positions: positions, selected: selected, t: _clock.value)),
                for (var i = 0; i < platforms.length; i++)
                  Positioned(
                    left: positions[i].dx - (selected == i ? 58 : 50),
                    top: positions[i].dy - (selected == i ? 58 : 50),
                    child: _Node(
                      platform: platforms[i],
                      active: selected == i,
                      onTap: () => open(i),
                      onHover: () => setState(() => selected = i),
                    ),
                  ),
                Positioned(left: center.dx - 82, top: center.dy - 82, child: _CoreNode(territory: widget.territory, count: platforms.length, active: selected != null)),
                for (var g = 0; g < widget.groups.length; g++)
                  _GroupLabel(group: widget.groups[g], index: g, total: widget.groups.length, center: center, width: width, height: height),
              ]),
            )),
            if (selected != null) Positioned(
              left: compact ? 14 : 30,
              right: compact ? 14 : 30,
              bottom: compact ? 42 : 54,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                constraints: const BoxConstraints(maxWidth: 700),
                decoration: BoxDecoration(
                  color: const Color(0xED080913),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x557F70B0)),
                  boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 34, offset: Offset(0, 14))],
                ),
                child: Row(children: [
                  Container(width: 3, height: 34, decoration: BoxDecoration(color: const Color(0xAA9A8AC5), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(platforms[selected!].name.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 2.7)),
                    const SizedBox(height: 4),
                    Text('${widget.territory}  •  PLATFORM WORLD', style: const TextStyle(fontSize: 8, letterSpacing: 1.7, color: Colors.white38)),
                  ])),
                  TextButton(onPressed: () => open(selected!), child: const Text('ENTER')),
                ]),
              )),
            ),
            Positioned(left: compact ? 16 : 30, bottom: compact ? 16 : 24, child: Text(selected == null ? 'SELECT A PLATFORM WORLD' : 'PLATFORM SELECTED  •  ENTER TO OPEN', style: const TextStyle(fontSize: 8, letterSpacing: 2.5, color: Colors.white24))),
          ]),
        );
      }),
    );
  }

  List<Offset> _positions(Offset center, double width, double height, int count, double t) {
    return List.generate(count, (i) {
      final angle = -math.pi / 2 + i * math.pi * 2 / math.max(1, count) + t * math.pi * .42;
      final ring = i % 3;
      final rx = width * (.20 + ring * .075);
      final ry = height * (.17 + ring * .065);
      final wobble = math.sin(t * math.pi * 2 + i * 1.7) * 7;
      return Offset(center.dx + math.cos(angle) * rx + wobble, center.dy + math.sin(angle) * ry + math.cos(t * math.pi * 2 + i) * 5);
    });
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

class _Node extends StatelessWidget {
  final GamePlatform platform;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onHover;
  const _Node({required this.platform, required this.active, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => onHover(),
    child: GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: active ? 116 : 100,
      height: active ? 116 : 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: active ? const [Color(0xFF9A8CC0), Color(0xFF302A45), Color(0xFF05060C)] : const [Color(0xFF655B82), Color(0xFF242136), Color(0xFF05060C)]),
        border: Border.all(color: Colors.white.withValues(alpha: active ? .34 : .09), width: active ? 1.5 : .7),
        boxShadow: active ? const [BoxShadow(color: Color(0x557F70B0), blurRadius: 28)] : null,
      ),
      child: Center(child: Text(platform.name, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: active ? 10 : 8, letterSpacing: 1.1, color: Colors.white.withValues(alpha: active ? .96 : .62)))),
    )),
  );
}

class _CoreNode extends StatelessWidget {
  final String territory;
  final int count;
  final bool active;
  const _CoreNode({required this.territory, required this.count, required this.active});
  @override Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 450),
    width: 164, height: 164,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: active ? const [Color(0xFF413A58), Color(0xFF100F19), Color(0xFF020208)] : const [Color(0xFF302A45), Color(0xFF0B0A12), Color(0xFF020208)]), border: Border.all(color: Colors.white.withValues(alpha: active ? .23 : .14)), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 35)]),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(territory, style: const TextStyle(fontSize: 11, letterSpacing: 2.5)), const SizedBox(height: 7), Text('$count WORLDS', style: const TextStyle(fontSize: 7, letterSpacing: 2.3, color: Colors.white30))])),
  );
}

class _GroupLabel extends StatelessWidget {
  final GamePlatformGroup group; final int index, total; final Offset center; final double width, height;
  const _GroupLabel({required this.group, required this.index, required this.total, required this.center, required this.width, required this.height});
  @override Widget build(BuildContext context) {
    final a = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + .35;
    final p = Offset(center.dx + math.cos(a) * width * .38, center.dy + math.sin(a) * height * .35);
    return Positioned(left: p.dx - 85, top: p.dy - 13, width: 170, child: IgnorePointer(child: Column(children: [Text(group.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 7, letterSpacing: 2.2, color: Colors.white24)), Text(group.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 6, color: Colors.white12))])));
  }
}

class _PlatformBackgroundPainter extends CustomPainter {
  final double t;
  const _PlatformBackgroundPainter({required this.t});
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.05, colors: [Color(0xFF17142A), Color(0xFF06060D), Color(0xFF010106)]).createShader(rect));
    final r = math.Random(412);
    for (var i = 0; i < 280; i++) {
      final x = (r.nextDouble() * s.width + t * s.width * .025) % s.width;
      c.drawCircle(Offset(x, r.nextDouble() * s.height), .18 + r.nextDouble() * .75, Paint()..color = Colors.white.withValues(alpha: .018 + r.nextDouble() * .075));
    }
    c.drawCircle(Offset(s.width * .5, s.height * .52), math.min(s.width, s.height) * .43, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x0D9B8FC2));
  }
  @override bool shouldRepaint(covariant _PlatformBackgroundPainter old) => old.t != t;
}

class _OrbitalPainter extends CustomPainter {
  final Offset center; final List<Offset> positions; final int? selected; final double t;
  const _OrbitalPainter({required this.center, required this.positions, required this.selected, required this.t});
  @override void paint(Canvas c, Size s) {
    final maxR = math.min(s.width, s.height);
    for (var ring = 0; ring < 3; ring++) {
      final rect = Rect.fromCenter(center: center, width: maxR * (.48 + ring * .17), height: maxR * (.33 + ring * .12));
      c.drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = ring == 1 ? 1.0 : .65..color = Colors.white.withValues(alpha: ring == 1 ? .055 : .025));
    }
    final route = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x267F72A0);
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      final path = Path()..moveTo(center.dx, center.dy);
      final mid = Offset((center.dx + p.dx) / 2 + math.sin(i + t * math.pi * 2) * 18, (center.dy + p.dy) / 2 - 12);
      path.quadraticBezierTo(mid.dx, mid.dy, p.dx, p.dy);
      c.drawPath(path, route);
      if (selected == i) {
        c.drawCircle(p, 72, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x557F70B0));
      }
    }
  }
  @override bool shouldRepaint(covariant _OrbitalPainter old) => old.t != t || old.selected != selected || old.positions != positions;
}
