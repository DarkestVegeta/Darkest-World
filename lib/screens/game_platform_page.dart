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

class _GamePlatformPageState extends State<GamePlatformPage> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 100))..repeat();
  int? _selected;

  List<GamePlatform> get _platforms => widget.groups.expand((g) => g.platforms).toList(growable: false);

  @override
  void dispose() { _clock.dispose(); super.dispose(); }

  void _enter(int index) {
    final platform = _platforms[index];
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
      territory: widget.territory,
      platform: platform.name,
      externalPlatformIds: platform.externalPlatformIds,
      navigationPlatforms: _platforms,
      navigationIndex: index,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 820;
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _DeepSpacePainter(_clock.value)),
            SafeArea(child: Padding(
              padding: EdgeInsets.fromLTRB(compact ? 14 : 34, compact ? 12 : 24, compact ? 14 : 34, 0),
              child: _Header(territory: widget.territory, count: _platforms.length, onBack: () => Navigator.of(context).pop()),
            )),
            Center(child: LayoutBuilder(builder: (context, box) {
              final diameter = math.min(box.maxWidth * (compact ? .98 : .84), box.maxHeight * (compact ? .72 : .80));
              return SizedBox.square(dimension: diameter, child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _OrbitalSystemPainter(_clock.value, _platforms.length))),
                  for (var i = 0; i < _platforms.length; i++)
                    _OrbitalPlatform(
                      platform: _platforms[i],
                      index: i,
                      total: _platforms.length,
                      selected: _selected == i,
                      diameter: diameter,
                      phase: _clock.value,
                      onTap: () => setState(() => _selected = _selected == i ? null : i),
                      onOpen: () => _enter(i),
                    ),
                  const Positioned.fill(child: IgnorePointer(child: Center(child: _ArchiveCore()))),
                ],
              ));
            })),
            Positioned(left: compact ? 12 : 34, right: compact ? 12 : 34, bottom: compact ? 12 : 24,
              child: _selected == null
                  ? const _InteractionHint()
                  : _PlatformDataPanel(
                      platform: _platforms[_selected!],
                      index: _selected!, total: _platforms.length,
                      onClose: () => setState(() => _selected = null),
                      onOpen: () => _enter(_selected!),
                    )),
            Positioned(top: compact ? 74 : 92, right: compact ? 14 : 36, child: _Telemetry(count: _platforms.length, selected: _selected)),
          ],
        ),
      ),
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

class _Header extends StatelessWidget {
  final String territory;
  final int count;
  final VoidCallback onBack;
  const _Header({required this.territory, required this.count, required this.onBack});
  @override
  Widget build(BuildContext context) => Row(children: [
    InkWell(onTap: onBack, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0x99FFFFFF)))),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${territory.toUpperCase()} / PLATFORM WORLDS', style: const TextStyle(fontSize: 11, letterSpacing: 3.2, color: Colors.white)),
      const SizedBox(height: 5),
      const Text('GENERATIONAL ARCHIVE / ORBITAL SYSTEM', style: TextStyle(fontSize: 6.5, letterSpacing: 2.4, color: Color(0x5AFFFFFF))),
    ]),
    const Spacer(),
    Text('${count.toString().padLeft(2, '0')} WORLDS', style: const TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x66FFFFFF))),
  ]);
}

class _Telemetry extends StatelessWidget {
  final int count;
  final int? selected;
  const _Telemetry({required this.count, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xB8060A12), border: Border.all(color: const Color(0x2E8EA5B8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const Text('ATLAS LINK  /  ONLINE', style: TextStyle(fontSize: 6, letterSpacing: 1.6, color: Color(0x709BB0BF))),
      const SizedBox(height: 5),
      Text('WORLDS  ${count.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 6, letterSpacing: 1.4, color: Color(0x8AFFFFFF))),
      Text('FOCUS   ${selected == null ? '--' : (selected! + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 6, letterSpacing: 1.4, color: Color(0x8AFFFFFF))),
    ]),
  );
}

class _OrbitalPlatform extends StatelessWidget {
  final GamePlatform platform;
  final int index;
  final int total;
  final bool selected;
  final double diameter;
  final double phase;
  final VoidCallback onTap;
  final VoidCallback onOpen;
  const _OrbitalPlatform({required this.platform, required this.index, required this.total, required this.selected, required this.diameter, required this.phase, required this.onTap, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final center = diameter / 2;
    final orbit = diameter * (.19 + (index % 5) * .065);
    final angle = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + phase * math.pi * .22 * (index.isEven ? 1 : -1);
    final p = Offset(center + math.cos(angle) * orbit, center + math.sin(angle) * orbit);
    final node = selected ? math.max(72, diameter * .112) : math.max(52, diameter * .073);
    return Positioned(left: p.dx - node / 2, top: p.dy - node / 2, width: node, height: node + 28,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, onDoubleTap: onOpen,
        child: Column(children: [
          SizedBox.square(dimension: node, child: CustomPaint(painter: _WorldPainter(seed: index, selected: selected, phase: phase))),
          const SizedBox(height: 4),
          Text(platform.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: selected ? 8 : 6.2, letterSpacing: 1.5, color: Colors.white.withValues(alpha: selected ? .96 : .5), fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ])));
  }
}

class _WorldPainter extends CustomPainter {
  final int seed;
  final bool selected;
  final double phase;
  const _WorldPainter({required this.seed, required this.selected, required this.phase});
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * .36;
    final sphere = Rect.fromCircle(center: c, radius: r);
    final bases = [0xFF8B7A6D, 0xFF647B87, 0xFF8C927E, 0xFF7D6F83, 0xFF718A86, 0xFF9A806B];
    final base = Color(bases[seed % bases.length]);
    if (selected) {
      canvas.drawCircle(c, r * 1.58, Paint()..shader = RadialGradient(colors: [const Color(0x5E8EA9BC), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.58)));
    }
    final lightX = -.42 + math.sin(phase * math.pi * 2 + seed) * .035;
    canvas.drawCircle(c, r, Paint()..shader = RadialGradient(center: Alignment(lightX, -.5), radius: 1.05, colors: [base, base.withValues(alpha: .76), const Color(0xFF26313A), const Color(0xFF04060A)]).createShader(sphere));
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    final random = math.Random(700 + seed * 91);
    for (var i = 0; i < 34; i++) {
      final x = c.dx + (random.nextDouble() * 2 - 1) * r * .88;
      final y = c.dy + (random.nextDouble() * 2 - 1) * r * .88;
      final rr = .7 + random.nextDouble() * r * .065;
      canvas.drawCircle(Offset(x, y), rr, Paint()..color = Colors.white.withValues(alpha: .025 + random.nextDouble() * .06));
    }
    final contour = Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = const Color(0x329BAFBA);
    for (var i = -2; i <= 2; i++) {
      canvas.drawOval(Rect.fromCenter(center: c.translate(i * r * .19, 0), width: r * (.44 + (i + 2) * .16), height: r * 1.82), contour);
    }
    final night = Paint()..shader = const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Color(0xE6000207), Color(0xA6000207)]).createShader(sphere);
    canvas.drawOval(sphere, night);
    canvas.restore();
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.25 : .65..color = const Color(0x6A9AAEBB));
    if (selected) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.17), phase * math.pi * 2, 1.35, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x8A9DB5C6));
      canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.27), -phase * math.pi * 2 - 1, .8, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x457C92A4));
    }
  }
  @override
  bool shouldRepaint(covariant _WorldPainter old) => old.seed != seed || old.selected != selected || old.phase != phase;
}

class _OrbitalSystemPainter extends CustomPainter {
  final double phase;
  final int count;
  const _OrbitalSystemPainter(this.phase, this.count);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 7; i++) {
      final r = size.shortestSide * (.18 + i * .052);
      canvas.drawOval(Rect.fromCenter(center: c, width: r * 2, height: r * 1.15), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 6 ? .9 : .45..color = Color(0x1F90A7B7));
    }
    final sweep = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x507F9AAC);
    canvas.drawArc(Rect.fromCenter(center: c, width: size.width * .84, height: size.height * .48), phase * math.pi * 2, .65, false, sweep);
    final tick = Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = const Color(0x334E6879);
    for (var i = 0; i < math.min(8, count + 2); i++) {
      final a = i * math.pi * 2 / math.max(1, math.min(8, count + 2));
      final p1 = Offset(c.dx + math.cos(a) * size.width * .42, c.dy + math.sin(a) * size.height * .23);
      final p2 = Offset(c.dx + math.cos(a) * size.width * .455, c.dy + math.sin(a) * size.height * .25);
      canvas.drawLine(p1, p2, tick);
    }
  }
  @override
  bool shouldRepaint(covariant _OrbitalSystemPainter old) => old.phase != phase || old.count != count;
}

class _ArchiveCore extends StatelessWidget {
  const _ArchiveCore();
  @override
  Widget build(BuildContext context) => Container(width: 58, height: 58, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFFFFFFF), Color(0xFFD4C4A4), Color(0xFF695A48), Color(0x00000000)], stops: [0, .2, .48, 1]), boxShadow: [BoxShadow(color: Color(0x668F7B5D), blurRadius: 30, spreadRadius: 8)]));
}

class _InteractionHint extends StatelessWidget {
  const _InteractionHint();
  @override
  Widget build(BuildContext context) => const Center(child: Text('1× CLICK  FOCUS     2× CLICK  ENTER PLATFORM     •     SCROLL TO ZOOM', style: TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x55FFFFFF))));
}

class _PlatformDataPanel extends StatelessWidget {
  final GamePlatform platform;
  final int index;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onOpen;
  const _PlatformDataPanel({required this.platform, required this.index, required this.total, required this.onClose, required this.onOpen});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
    decoration: BoxDecoration(color: const Color(0xF2070B12), border: Border.all(color: const Color(0x527E98A9)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 40, spreadRadius: 2)]),
    child: Row(children: [
      Container(width: 3, height: 48, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF9DB7C7), Color(0x22728A9A)]))),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PLATFORM WORLD  /  ${index + 1}/$total', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x62FFFFFF))),
        const SizedBox(height: 5),
        Text(platform.name, style: const TextStyle(fontSize: 16, letterSpacing: 2.8, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('GENERATION ARCHIVE  •  GAME CATALOG  •  REGION LINKED', style: TextStyle(fontSize: 6.2, letterSpacing: 1.3, color: Color(0x70FFFFFF))),
      ])),
      InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(8), child: Text('×', style: TextStyle(fontSize: 18, color: Color(0xAAFFFFFF))))),
      const SizedBox(width: 4),
      FilledButton(onPressed: onOpen, child: const Text('ENTER ARCHIVE')),
    ]),
  );
}

class _DeepSpacePainter extends CustomPainter {
  final double phase;
  const _DeepSpacePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(center: Alignment(0, -.05), radius: 1.15, colors: [Color(0xFF0C1420), Color(0xFF030711), Color(0xFF010207)]).createShader(Offset.zero & size));
    final random = math.Random(1188);
    for (var i = 0; i < 520; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final twinkle = .16 + .38 * ((math.sin(phase * math.pi * 2 * (1 + i % 3) + i) + 1) / 2);
      final radius = i % 17 == 0 ? 1.05 : .35 + random.nextDouble() * .55;
      canvas.drawCircle(p, radius, Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final haze = Paint()..shader = RadialGradient(colors: [const Color(0x255B7891), Colors.transparent]).createShader(Rect.fromCenter(center: Offset(size.width * .52, size.height * .5), width: size.width * .9, height: size.height * .65));
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .52, size.height * .5), width: size.width * .9, height: size.height * .65), haze);
    final vignette = Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0xC9000000)], stops: [.5, 1]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }
  @override
  bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase;
}
