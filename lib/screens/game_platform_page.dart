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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 112))..repeat();
  int? selected;
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList(growable: false);
  @override void dispose() { clock.dispose(); super.dispose(); }
  void enter(int index) {
    final p = platforms[index];
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
      territory: widget.territory,
      platform: p.name,
      externalPlatformIds: p.externalPlatformIds,
      navigationPlatforms: platforms,
      navigationIndex: index,
    )));
  }
  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 820;
    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _PlatformSpace(clock.value)),
            SafeArea(child: Padding(
              padding: EdgeInsets.fromLTRB(compact ? 12 : 28, compact ? 10 : 22, compact ? 12 : 28, 0),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 14)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.territory.toUpperCase()} / PLATFORM WORLDS', style: const TextStyle(fontSize: 10, letterSpacing: 3.4)),
                  const SizedBox(height: 3),
                  const Text('GENERATIONS / PHYSICAL MEDIA ARCHIVE / ORBITAL ATLAS', style: TextStyle(fontSize: 6.5, letterSpacing: 2.1, color: Color(0x668D95A5))),
                ])),
                if (!compact) const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('WORLD SYSTEM 04', style: TextStyle(fontSize: 6, letterSpacing: 2, color: Color(0x668D95A5))),
                  SizedBox(height: 4),
                  Text('VOLUME / STABLE', style: TextStyle(fontSize: 6, letterSpacing: 2, color: Color(0x557E9AA8))),
                ]),
              ]),
            )),
            Center(child: LayoutBuilder(builder: (_, box) {
              final d = math.min(box.maxWidth * (compact ? .98 : .82), box.maxHeight * (compact ? .68 : .76)).toDouble();
              return SizedBox.square(dimension: d, child: Stack(children: [
                CustomPaint(size: Size(d, d), painter: _AtlasRings(clock.value)),
                for (var i = 0; i < platforms.length; i++)
                  _PlatformNode(
                    platform: platforms[i], index: i, total: platforms.length, selected: selected == i,
                    diameter: d, phase: clock.value,
                    onTap: () => setState(() => selected = selected == i ? null : i),
                    onOpen: () => enter(i),
                  ),
                const Center(child: IgnorePointer(child: _ArchiveSun())),
              ]));
            })),
            Positioned(left: compact ? 10 : 28, right: compact ? 10 : 28, bottom: compact ? 10 : 22,
              child: selected == null
                ? const _Instruction()
                : _PlatformPanel(platform: platforms[selected!], index: selected!, total: platforms.length, onClose: () => setState(() => selected = null), onOpen: () => enter(selected!))),
            if (!compact) const Positioned(top: 96, left: 30, child: _Telemetry()),
          ],
        ),
      ),
    );
  }
}

class GamePlatformGroup {
  final String name; final String subtitle; final List<GamePlatform> platforms;
  const GamePlatformGroup(this.name, this.subtitle, this.platforms);
}
class GamePlatform {
  final String name; final List<int> externalPlatformIds;
  const GamePlatform(this.name, this.externalPlatformIds);
}

class _PlatformNode extends StatelessWidget {
  final GamePlatform platform; final int index, total; final bool selected; final double diameter, phase; final VoidCallback onTap, onOpen;
  const _PlatformNode({required this.platform, required this.index, required this.total, required this.selected, required this.diameter, required this.phase, required this.onTap, required this.onOpen});
  @override Widget build(BuildContext context) {
    final c = diameter / 2;
    final band = index % 6;
    final orbit = diameter * (.18 + band * .058);
    final direction = index.isEven ? 1.0 : -1.0;
    final angle = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + phase * math.pi * .18 * direction;
    final p = Offset(c + math.cos(angle) * orbit, c + math.sin(angle) * orbit * .72);
    final node = (selected ? math.max(76, diameter * .112) : math.max(54, diameter * .072)).toDouble();
    return Positioned(left: p.dx - node / 2, top: p.dy - node / 2, width: node, height: node,
      child: GestureDetector(onTap: onTap, onDoubleTap: onOpen, child: CustomPaint(painter: _PlatformPlanet(seed: index, selected: selected, phase: phase))));
  }
}

class _PlatformPlanet extends CustomPainter {
  final int seed; final bool selected; final double phase;
  const _PlatformPlanet({required this.seed, required this.selected, required this.phase});
  @override void paint(Canvas c, Size s) {
    final center = s.center(Offset.zero);
    final r = s.width * .36;
    final rect = Rect.fromCircle(center: center, radius: r);
    final palette = <List<Color>>[
      [const Color(0xFFB49C83), const Color(0xFF5C5049), const Color(0xFF16191E)],
      [const Color(0xFF87A6B4), const Color(0xFF354D5B), const Color(0xFF10161B)],
      [const Color(0xFFB0A487), const Color(0xFF665F4C), const Color(0xFF171713)],
      [const Color(0xFF9A8CA4), const Color(0xFF4F4859), const Color(0xFF13121A)],
      [const Color(0xFF789D8E), const Color(0xFF354F4B), const Color(0xFF101713)],
      [const Color(0xFFA29BAE), const Color(0xFF514B59), const Color(0xFF121116)],
    ][seed % 6];
    c.drawCircle(center, r * 1.48, Paint()..shader = RadialGradient(colors: [const Color(0x3C8FA8B8), const Color(0x00000000)]).createShader(Rect.fromCircle(center: center, radius: r * 1.48)));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.42, -.54), radius: 1.04, colors: [...palette, const Color(0xFF020307)], stops: const [.0, .33, .72, 1]).createShader(rect));
    c.save();
    c.clipPath(Path()..addOval(rect));
    final rnd = math.Random(6000 + seed * 91);
    for (var i = 0; i < 34; i++) {
      final a = rnd.nextDouble() * math.pi * 2 + phase * .035;
      final rr = r * math.sqrt(rnd.nextDouble()) * .88;
      final p = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .74);
      final w = r * (.015 + rnd.nextDouble() * .08);
      c.drawOval(Rect.fromCenter(center: p, width: w, height: w * (.25 + rnd.nextDouble() * .8)), Paint()..color = Colors.white.withValues(alpha: .025 + rnd.nextDouble() * .065));
    }
    for (var i = 0; i < 9; i++) {
      final y = center.dy - r * .72 + i * r * .18;
      c.drawLine(Offset(center.dx - r, y), Offset(center.dx + r, y + math.sin(i + phase * 2) * r * .018), Paint()..strokeWidth = i % 3 == 0 ? .65 : .3..color = const Color(0x245E6972));
    }
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi * 2 / 10 + phase * .025;
      c.drawArc(Rect.fromCircle(center: center, radius: r * (.48 + (i % 3) * .11)), a, .36, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .35..color = const Color(0x245C7280));
    }
    c.restore();
    c.drawCircle(center, r, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.5 : .7..color = selected ? const Color(0xA7D4C9D9) : const Color(0x5E9BAEB7));
    if (selected) {
      c.drawCircle(center, r * 1.2, Paint()..style = PaintingStyle.stroke..strokeWidth = .9..color = const Color(0x709FB7C5));
      c.drawArc(Rect.fromCircle(center: center, radius: r * 1.34), phase * math.pi * 2, 1.15, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = const Color(0x7EA99ABD));
      c.drawArc(Rect.fromCircle(center: center, radius: r * 1.48), phase * math.pi * 2 + math.pi, .4, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x567C9EAD));
    }
  }
  @override bool shouldRepaint(covariant _PlatformPlanet old) => old.seed != seed || old.selected != selected || old.phase != phase;
}

class _AtlasRings extends CustomPainter {
  final double phase; const _AtlasRings(this.phase);
  @override void paint(Canvas c, Size s) {
    final center = s.center(Offset.zero);
    for (var i = 0; i < 9; i++) {
      final r = s.shortestSide * (.17 + i * .046);
      final rect = Rect.fromCenter(center: center, width: r * 2, height: r * (1.05 + i * .018));
      c.drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = i == 8 ? .95 : .42..color = Color.lerp(const Color(0x2B8299A8), const Color(0x0B6E8190), i / 9)!);
    }
    final sweep = Rect.fromCenter(center: center, width: s.width * .91, height: s.height * .5);
    c.drawArc(sweep, phase * math.pi * 2, .7, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..strokeCap = StrokeCap.round..color = const Color(0x668AA7B5));
    c.drawArc(sweep, phase * math.pi * 2 + math.pi, .24, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0x3C877F9E));
    c.drawCircle(center, s.shortestSide * .47, Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x263E5260));
  }
  @override bool shouldRepaint(covariant _AtlasRings old) => old.phase != phase;
}

class _ArchiveSun extends StatelessWidget {
  const _ArchiveSun();
  @override Widget build(BuildContext context) => Container(width: 72, height: 72, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFFFFFFF), Color(0xFFE1D1B2), Color(0xFF796A55), Color(0x00000000)], stops: [.0, .18, .48, 1]), boxShadow: [BoxShadow(color: Color(0x708C7C63), blurRadius: 38, spreadRadius: 10)]));
}

class _Telemetry extends StatelessWidget {
  const _Telemetry();
  @override Widget build(BuildContext context) => Container(width: 210, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0x9A050912), border: Border.all(color: const Color(0x253E5361))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('PLATFORM ATLAS', style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Color(0x9EAFB6C0))),
    SizedBox(height: 10),
    Text('ORBITAL BANDS       09', style: TextStyle(fontSize: 6.5, letterSpacing: 1.6, color: Color(0x5D9BA5B0))),
    SizedBox(height: 5),
    Text('ARCHIVE WORLDS      LIVE', style: TextStyle(fontSize: 6.5, letterSpacing: 1.6, color: Color(0x5D9BA5B0))),
    SizedBox(height: 5),
    Text('MATERIAL FIELD      STABLE', style: TextStyle(fontSize: 6.5, letterSpacing: 1.6, color: Color(0x5D9BA5B0))),
  ]));
}

class _Instruction extends StatelessWidget {
  const _Instruction();
  @override Widget build(BuildContext context) => Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9), decoration: BoxDecoration(color: const Color(0xB5070A10), border: Border.all(color: const Color(0x263B4A56))), child: const Text('1× CLICK FOCUS    2× CLICK ENTER PLATFORM    /    SELECT A WORLD', style: TextStyle(fontSize: 6.5, letterSpacing: 1.7, color: Color(0x687D8994)))));
}

class _PlatformPanel extends StatelessWidget {
  final GamePlatform platform; final int index, total; final VoidCallback onClose, onOpen;
  const _PlatformPanel({required this.platform, required this.index, required this.total, required this.onClose, required this.onOpen});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xF2070A11), border: Border.all(color: const Color(0x557B94A3)), boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 26, spreadRadius: 4)]), child: Row(children: [
    Container(width: 42, height: 42, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFC6BACB), Color(0xFF4B4553), Color(0xFF08090D)]))),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PLATFORM WORLD / ${index + 1}/$total', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.9, color: Color(0x6988939E))), const SizedBox(height: 4), Text(platform.name, style: const TextStyle(fontSize: 16, letterSpacing: 2.4)), const SizedBox(height: 3), Text('${platform.externalPlatformIds.length.toString().padLeft(2, '0')} CONTENT SOURCES  /  ARCHIVE READY', style: const TextStyle(fontSize: 6, letterSpacing: 1.5, color: Color(0x557F8A96)))])),
    TextButton(onPressed: onClose, child: const Text('×')), FilledButton(onPressed: onOpen, child: const Text('ENTER ARCHIVE')),
  ]));
}

class _PlatformSpace extends CustomPainter {
  final double phase; const _PlatformSpace(this.phase);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.18, colors: [Color(0xFF101A29), Color(0xFF040914), Color(0xFF010208)]).createShader(rect));
    final rnd = math.Random(1188);
    for (var i = 0; i < 520; i++) {
      final depth = .15 + rnd.nextDouble() * .85;
      final x = rnd.nextDouble() * s.width;
      final y = rnd.nextDouble() * s.height;
      final drift = math.sin(phase * math.pi * 2 * (.16 + depth * .28) + i) * (1 + depth * 3);
      c.drawCircle(Offset(x + drift, y), .2 + depth * .85, Paint()..color = Colors.white.withValues(alpha: .018 + depth * .065));
    }
    final haze = Rect.fromCenter(center: Offset(s.width * .5, s.height * .47), width: s.width * .75, height: s.height * .6);
    c.drawOval(haze, Paint()..shader = RadialGradient(colors: const [Color(0x0D7787A0), Color(0x00000000)]).createShader(haze));
    final scanY = (phase * s.height * 1.2) % (s.height + 30) - 15;
    c.drawRect(Rect.fromLTWH(0, scanY, s.width, 1), Paint()..color = const Color(0x0B9CB7C4));
    final vignette = Rect.fromLTWH(0, 0, s.width, s.height);
    c.drawRect(vignette, Paint()..shader = RadialGradient(radius: 1.12, colors: const [Color(0x00000000), Color(0x55000000)]).createShader(vignette));
  }
  @override bool shouldRepaint(covariant _PlatformSpace old) => old.phase != phase;
}
