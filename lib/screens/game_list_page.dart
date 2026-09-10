import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class GameListPage extends StatelessWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;

  const GameListPage({super.key, required this.territory, required this.platform, required this.externalPlatformIds});

  void _openGames(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(
    title: '$platform • GAMES', contentType: 'game', platformIds: externalPlatformIds,
  )));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF020208),
    body: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _GamesBackgroundPainter())),
      SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 18, 24, 8), child: Row(children: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 17)),
          const SizedBox(width: 8),
          Expanded(child: Text('$platform • GAMES', style: const TextStyle(letterSpacing: 3.2, fontSize: 16))),
        ])),
        Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _HierarchyTrail(territory: territory, platform: platform),
            const SizedBox(height: 24),
            Container(width: 118, height: 118, decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF30265D), Color(0xFF0A0918), Color(0xFF030309)]),
              border: Border.all(color: const Color(0xFF9A82FF).withValues(alpha: .42)),
              boxShadow: [BoxShadow(color: const Color(0xFF765CFF).withValues(alpha: .20), blurRadius: 38, spreadRadius: 4)],
            ), child: const Center(child: Text('GAMES', style: TextStyle(letterSpacing: 2.5, fontSize: 12)))),
            const SizedBox(height: 26),
            Text(platform, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, letterSpacing: 5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('GAME LIBRARY', style: TextStyle(color: Colors.white.withValues(alpha: .34), fontSize: 10, letterSpacing: 4)),
            const SizedBox(height: 28),
            SizedBox(width: 280, child: FilledButton.icon(
              onPressed: () => _openGames(context), icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('OPEN GAMES', style: TextStyle(letterSpacing: 2.4))),
            )),
            const SizedBox(height: 18),
            Text('DarkestWorld owns this hierarchy. The live browser is only an external visitor service.', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: .18), fontSize: 9, letterSpacing: .3)),
          ]),
        )))),
      ])),
    ]),
  );
}

class _HierarchyTrail extends StatelessWidget {
  final String territory; final String platform;
  const _HierarchyTrail({required this.territory, required this.platform});

  @override Widget build(BuildContext context) => Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
    Text('GAME-WORLD', style: TextStyle(color: Colors.white.withValues(alpha: .24), fontSize: 9, letterSpacing: 2)),
    _arrow,
    Text(territory, style: TextStyle(color: Colors.white.withValues(alpha: .34), fontSize: 9, letterSpacing: 2)),
    _arrow,
    Text(platform, style: const TextStyle(fontSize: 9, letterSpacing: 2)),
    _arrow,
    Text('GAMES', style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 9, letterSpacing: 2)),
  ]);

  static const _arrow = Icon(Icons.chevron_right, size: 14, color: Color(0xFF7467A8));
}

class _GamesBackgroundPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.1,
      colors: [Color(0xFF15132F), Color(0xFF060612), Color(0xFF010105)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final glow = Paint()..color = const Color(0xFF7560FF).withValues(alpha: .035)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width / 2, size.height * .46), 220, glow);
    final star = Paint();
    for (var i = 0; i < 100; i++) {
      final x = (i * 91.13) % size.width; final y = (i * 53.71) % size.height;
      star.color = Colors.white.withValues(alpha: .12 + (i % 5) * .035);
      canvas.drawCircle(Offset(x, y), i % 17 == 0 ? .95 : .42, star);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
