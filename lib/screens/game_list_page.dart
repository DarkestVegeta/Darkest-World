import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';
import 'game_platform_page.dart';

class GameListPage extends StatefulWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
  final List<GamePlatform> navigationPlatforms;
  final int navigationIndex;

  const GameListPage({
    super.key,
    required this.territory,
    required this.platform,
    required this.externalPlatformIds,
    this.navigationPlatforms = const [],
    this.navigationIndex = -1,
  });

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  int? _hovered;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openGames(BuildContext context, GamePlatform target) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GameListPage(
      territory: widget.territory,
      platform: target.name,
      externalPlatformIds: target.externalPlatformIds,
      navigationPlatforms: widget.navigationPlatforms,
      navigationIndex: widget.navigationPlatforms.indexOf(target),
    )));
  }

  void _openBrowser(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(
    title: '${widget.platform} • GAMES', contentType: 'game', platformIds: widget.externalPlatformIds,
  )));

  @override
  Widget build(BuildContext context) {
    final hasNavigation = widget.navigationPlatforms.length > 1 && widget.navigationIndex >= 0;
    final previous = hasNavigation && widget.navigationIndex > 0 ? widget.navigationPlatforms[widget.navigationIndex - 1] : null;
    final next = hasNavigation && widget.navigationIndex < widget.navigationPlatforms.length - 1 ? widget.navigationPlatforms[widget.navigationIndex + 1] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: Stack(children: [
        Positioned.fill(child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(painter: _GamesWorldPainter(_controller.value)),
        )),
        SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          return Stack(children: [
            Positioned(top: 14, left: 18, child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 17),
              tooltip: 'Back',
            )),
            Positioned(top: 25, left: 70, child: _HierarchyTrail(territory: widget.territory, platform: widget.platform)),
            Center(child: SizedBox(
              width: math.min(constraints.maxWidth - 32, 1180),
              height: math.min(constraints.maxHeight - 32, 700),
              child: Stack(children: [
                Positioned.fill(child: CustomPaint(painter: _GameRoutesPainter())),
                Center(child: _GameHub(platform: widget.platform, count: widget.externalPlatformIds.length)),
                ..._worlds(compact),
              ]),
            )),
            Positioned(left: 0, right: 0, bottom: compact ? 12 : 22, child: Column(children: [
              if (hasNavigation) _PlatformNavigation(
                previous: previous,
                current: widget.platform,
                next: next,
                onPrevious: previous == null ? null : () => _openGames(context, previous),
                onNext: next == null ? null : () => _openGames(context, next),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openBrowser(context),
                icon: const Icon(Icons.explore_outlined, size: 17),
                label: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('ENTER GAME LIBRARY', style: TextStyle(letterSpacing: 2.1, fontSize: 10))),
              ),
            ])),
          ];
        })),
      ]),
    );
  }

  List<Widget> _worlds(bool compact) {
    final platforms = widget.navigationPlatforms.isNotEmpty ? widget.navigationPlatforms : <GamePlatform>[];
    if (platforms.isEmpty) return const [];
    final positions = <Offset>[
      const Offset(.22, .24), const Offset(.50, .12), const Offset(.78, .24),
      const Offset(.86, .52), const Offset(.72, .80), const Offset(.50, .88),
      const Offset(.28, .80), const Offset(.14, .52),
    ];
    final count = math.min(platforms.length, positions.length);
    return List.generate(count, (i) {
      final p = platforms[i];
      final pos = positions[i];
      return Align(alignment: Alignment(pos.dx * 2 - 1, pos.dy * 2 - 1), child: _GameTerritoryNode(
        platform: p.name,
        index: i,
        hovered: _hovered == i,
        compact: compact,
        onHover: (v) => setState(() => _hovered = v ? i : null),
        onTap: () => _openBrowser(context),
      ));
    });
  }
}

class _GameHub extends StatelessWidget {
  final String platform; final int count;
  const _GameHub({required this.platform, required this.count});
  @override
  Widget build(BuildContext context) => Container(
    width: 172, height: 172,
    decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: const RadialGradient(colors: [Color(0xFF33275E), Color(0xFF100D22), Color(0xFF030309)]),
      border: Border.all(color: const Color(0xFF9A82FF).withValues(alpha: .46)),
      boxShadow: [BoxShadow(color: const Color(0xFF8068FF).withValues(alpha: .18), blurRadius: 52, spreadRadius: 6)],
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(platform, style: const TextStyle(fontSize: 12, letterSpacing: 2.8, fontWeight: FontWeight.w600)),
      const SizedBox(height: 9),
      Text('GAME WORLD', style: TextStyle(color: Colors.white.withValues(alpha: .40), fontSize: 8, letterSpacing: 2.5)),
      const SizedBox(height: 13),
      Text('$count SOURCES', style: TextStyle(color: Colors.white.withValues(alpha: .23), fontSize: 7, letterSpacing: 1.7)),
    ]),
  );
}

class _GameTerritoryNode extends StatelessWidget {
  final String platform; final int index; final bool hovered; final bool compact;
  final ValueChanged<bool> onHover; final VoidCallback onTap;
  const _GameTerritoryNode({required this.platform, required this.index, required this.hovered, required this.compact, required this.onHover, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = hovered ? (compact ? 94.0 : 112.0) : (compact ? 72.0 : 92.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(onTap: onTap, child: AnimatedContainer(
        duration: const Duration(milliseconds: 220), width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            Color.lerp(const Color(0xFF2B244C), const Color(0xFF4A3D78), hovered ? .75 : .15)!,
            const Color(0xFF0A0915), const Color(0xFF020207),
          ]),
          border: Border.all(color: const Color(0xFF8E79D5).withValues(alpha: hovered ? .65 : .28)),
          boxShadow: [BoxShadow(color: const Color(0xFF7057D5).withValues(alpha: hovered ? .22 : .07), blurRadius: hovered ? 34 : 20, spreadRadius: hovered ? 3 : 0)],
        ),
        child: CustomPaint(painter: _GameNodeTerrainPainter(seed: index), child: Center(child: Text(
          platform, textAlign: TextAlign.center,
          style: TextStyle(fontSize: hovered ? 10 : 8, letterSpacing: 1.5, fontWeight: FontWeight.w600),
        ))),
      )),
    );
  }
}

class _GameRoutesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final route = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF7565A8).withValues(alpha: .13);
    for (final rect in [
      Rect.fromCenter(center: center, width: size.width * .74, height: size.height * .50),
      Rect.fromCenter(center: center, width: size.width * .56, height: size.height * .78),
    ]) canvas.drawOval(rect, route);
    final nodes = [
      Offset(size.width*.22, size.height*.24), Offset(size.width*.50, size.height*.12), Offset(size.width*.78, size.height*.24),
      Offset(size.width*.86, size.height*.52), Offset(size.width*.72, size.height*.80), Offset(size.width*.50, size.height*.88),
      Offset(size.width*.28, size.height*.80), Offset(size.width*.14, size.height*.52),
    ];
    for (final node in nodes) {
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF7768A9).withValues(alpha: .12);
      canvas.drawLine(center, node, p);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlatformNavigation extends StatelessWidget {
  final GamePlatform? previous; final String current; final GamePlatform? next;
  final VoidCallback? onPrevious; final VoidCallback? onNext;
  const _PlatformNavigation({required this.previous, required this.current, required this.next, required this.onPrevious, required this.onNext});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _NavNode(label: 'PREVIOUS', value: previous?.name, onTap: onPrevious, alignment: CrossAxisAlignment.end),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('|', style: TextStyle(color: Color(0xFF5C5577), fontSize: 12))),
    Column(mainAxisSize: MainAxisSize.min, children: [Text('CURRENT', style: TextStyle(color: Colors.white.withValues(alpha: .38), fontSize: 8, letterSpacing: 2.4)), const SizedBox(height: 5), Text(current, style: const TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w600))]),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('|', style: TextStyle(color: Color(0xFF5C5577), fontSize: 12))),
    _NavNode(label: 'NEXT', value: next?.name, onTap: onNext, alignment: CrossAxisAlignment.start),
  ]);
}

class _NavNode extends StatelessWidget {
  final String label; final String? value; final VoidCallback? onTap; final CrossAxisAlignment alignment;
  const _NavNode({required this.label, required this.value, required this.onTap, required this.alignment});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: alignment, children: [
    Text(label, style: TextStyle(color: onTap == null ? Colors.white.withValues(alpha: .14) : Colors.white.withValues(alpha: .32), fontSize: 8, letterSpacing: 2.2)), const SizedBox(height: 5),
    Text(value ?? '—', style: TextStyle(color: onTap == null ? Colors.white.withValues(alpha: .12) : const Color(0xFF9A82FF), fontSize: 10, letterSpacing: .8)),
  ])));
}

class _HierarchyTrail extends StatelessWidget {
  final String territory; final String platform;
  const _HierarchyTrail({required this.territory, required this.platform});
  @override Widget build(BuildContext context) => Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
    Text('GAME-WORLD', style: TextStyle(color: Colors.white.withValues(alpha: .24), fontSize: 9, letterSpacing: 2)), const Icon(Icons.chevron_right, size: 14, color: Color(0xFF7467A8)),
    Text(territory, style: TextStyle(color: Colors.white.withValues(alpha: .34), fontSize: 9, letterSpacing: 2)), const Icon(Icons.chevron_right, size: 14, color: Color(0xFF7467A8)),
    Text(platform, style: const TextStyle(fontSize: 9, letterSpacing: 2)), const Icon(Icons.chevron_right, size: 14, color: Color(0xFF7467A8)),
    Text('GAMES', style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 9, letterSpacing: 2)),
  ]);
}

class _GamesWorldPainter extends CustomPainter {
  final double t;
  _GamesWorldPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const RadialGradient(center: Alignment(0, -.05), radius: 1.05, colors: [Color(0xFF161330), Color(0xFF060612), Color(0xFF010105)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final glow = Paint()..color = const Color(0xFF7560FF).withValues(alpha: .045)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width/2, size.height*.48), 250, glow);
    final star = Paint();
    for (var i = 0; i < 125; i++) {
      final x = (i * 91.13 + math.sin(t * math.pi * 2 + i) * 3) % size.width;
      final y = (i * 53.71 + math.cos(t * math.pi * 2 + i) * 2) % size.height;
      star.color = Colors.white.withValues(alpha: .10 + (i % 5) * .028);
      canvas.drawCircle(Offset(x, y), i % 19 == 0 ? .9 : .38, star);
    }
  }
  @override bool shouldRepaint(covariant _GamesWorldPainter oldDelegate) => true;
}

class _GameNodeTerrainPainter extends CustomPainter {
  final int seed;
  _GameNodeTerrainPainter({required this.seed});
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed + 41);
    final paint = Paint()..color = const Color(0xFF7466A5).withValues(alpha: .15);
    for (var patch = 0; patch < 4; patch++) {
      final center = Offset(size.width*(.28 + random.nextDouble()*.44), size.height*(.25 + random.nextDouble()*.5));
      final path = Path();
      final points = 7;
      for (var j = 0; j <= points; j++) {
        final a = math.pi * 2 * j / points;
        final r = size.width * (.09 + random.nextDouble()*.10);
        final p = center + Offset(math.cos(a)*r, math.sin(a)*r*.62);
        if (j == 0) path.moveTo(p.dx,p.dy); else path.lineTo(p.dx,p.dy);
      }
      path.close(); canvas.drawPath(path, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
