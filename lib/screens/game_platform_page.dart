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
  int? selected;
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList();
  void open(int index) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: platforms[index].name, externalPlatformIds: platforms[index].externalPlatformIds, navigationPlatforms: platforms, navigationIndex: index)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF010208), body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 850; final width = math.min(box.maxWidth * .94, 1280.0); final height = math.min(box.maxHeight * .78, 720.0);
      final center = Offset(width / 2, height / 2); final positions = _positions(center, width, height, platforms.length);
      return Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _PlatformBackgroundPainter())),
        SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 26), child: Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)), const SizedBox(width: 8), Text('${widget.territory.toUpperCase()}  /  WORLDS', style: const TextStyle(fontSize: 13, letterSpacing: 3.5))]))),
        Center(child: SizedBox(width: width, height: height, child: Stack(children: [
          CustomPaint(size: Size(width, height), painter: _RoutesPainter(center: center, positions: positions)),
          for (var i = 0; i < platforms.length; i++) Positioned(left: positions[i].dx - 50, top: positions[i].dy - 50, child: _Node(platform: platforms[i], active: selected == i, onTap: () => open(i), onHover: () => setState(() => selected = i))),
          Positioned(left: center.dx - 65, top: center.dy - 65, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF302A45), Color(0xFF0B0A12), Color(0xFF020208)]), border: Border.all(color: Colors.white.withValues(alpha: .14))), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(widget.territory, style: const TextStyle(fontSize: 10, letterSpacing: 2)), const SizedBox(height: 5), Text('WORLD', style: TextStyle(fontSize: 7, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .28)))]))))),
        ]))),
        Positioned(left: 0, right: 0, bottom: compact ? 18 : 28, child: Text(selected == null ? 'SELECT PLATFORM' : '${platforms[selected!].name.toUpperCase()}  •  ENTER WORLD', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .30)))),
      ]);
    }));
  }

  List<Offset> _positions(Offset center, double width, double height, int count) {
    return [for (var i = 0; i < count; i++) Offset(center.dx + math.cos(-math.pi / 2 + i * math.pi * 2 / math.max(1, count)) * width * (.18 + (i % 3) * .09), center.dy + math.sin(-math.pi / 2 + i * math.pi * 2 / math.max(1, count)) * height * (.16 + (i % 3) * .07))];
  }
}

class GamePlatformGroup { final String name; final String subtitle; final List<GamePlatform> platforms; const GamePlatformGroup(this.name, this.subtitle, this.platforms); }
class GamePlatform { final String name; final List<int> externalPlatformIds; const GamePlatform(this.name, this.externalPlatformIds); }

class _Node extends StatelessWidget {
  final GamePlatform platform; final bool active; final VoidCallback onTap, onHover;
  const _Node({required this.platform, required this.active, required this.onTap, required this.onHover});
  @override Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(), child: GestureDetector(onTap: onTap, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF6B608A), Color(0xFF242136), Color(0xFF05060C)]), border: Border.all(color: Colors.white.withValues(alpha: active ? .28 : .09), width: active ? 1.4 : .7), boxShadow: active ? const [BoxShadow(color: Color(0x556F60A0), blurRadius: 28)] : const []), child: Center(child: Text(platform.name, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: active ? 10 : 8, letterSpacing: 1.1, color: Colors.white.withValues(alpha: active ? .95 : .62)))))));
}

class _PlatformBackgroundPainter extends CustomPainter { const _PlatformBackgroundPainter(); @override void paint(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(colors: [Color(0xFF17142A), Color(0xFF06060D), Color(0xFF010106)]).createShader(Offset.zero & s)); final r = math.Random(412); final p = Paint(); for (var i = 0; i < 260; i++) { p.color = Colors.white.withValues(alpha: .025 + r.nextDouble() * .10); c.drawCircle(Offset(r.nextDouble() * s.width, r.nextDouble() * s.height), .2 + r.nextDouble() * .7, p); } } @override bool shouldRepaint(covariant _PlatformBackgroundPainter old) => false; }
class _RoutesPainter extends CustomPainter { final Offset center; final List<Offset> positions; const _RoutesPainter({required this.center, required this.positions}); @override void paint(Canvas c, Size s) { final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x227F72A0); for (final point in positions) { final path = Path()..moveTo(center.dx, center.dy)..lineTo(point.dx, point.dy); c.drawPath(path, p); } } @override bool shouldRepaint(covariant _RoutesPainter old) => false; }
