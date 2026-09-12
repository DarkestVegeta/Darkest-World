import 'package:flutter/material.dart';
import 'content_browser_page.dart';
import 'game_platform_page.dart';

class GameListPage extends StatelessWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
  final List<GamePlatform> navigationPlatforms;
  final int navigationIndex;
  const GameListPage({super.key, required this.territory, required this.platform, required this.externalPlatformIds, this.navigationPlatforms = const [], this.navigationIndex = -1});

  @override
  Widget build(BuildContext context) {
    final previous = navigationIndex > 0 ? navigationPlatforms[navigationIndex - 1] : null;
    final next = navigationIndex >= 0 && navigationIndex + 1 < navigationPlatforms.length ? navigationPlatforms[navigationIndex + 1] : null;
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _LibraryBackground())),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
              Expanded(child: Text('GAME-WORLD / ${territory.toUpperCase()} / ${platform.toUpperCase()}', style: const TextStyle(fontSize: 10, letterSpacing: 2))),
              const Text('GAME LIBRARY', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Colors.white24)),
            ]),
            const Spacer(),
            Center(child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xCC080812), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x447F70B0))),
              child: Column(children: [
                Text(platform.toUpperCase(), style: const TextStyle(fontSize: 20, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('$territory  •  GAME ARCHIVE', style: const TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white38)),
                const SizedBox(height: 22),
                FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(title: '$platform • GAMES', contentType: 'game', platformIds: externalPlatformIds))), child: const Text('OPEN GAME LIBRARY')),
              ]),
            )),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(onPressed: previous == null ? null : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameListPage(territory: territory, platform: previous.name, externalPlatformIds: previous.externalPlatformIds, navigationPlatforms: navigationPlatforms, navigationIndex: navigationIndex - 1))), child: Text(previous == null ? '—' : '‹ ${previous.name}')),
              Text('${navigationIndex >= 0 ? navigationIndex + 1 : 1} / ${navigationPlatforms.length}', style: const TextStyle(fontSize: 7, color: Colors.white24)),
              TextButton(onPressed: next == null ? null : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameListPage(territory: territory, platform: next.name, externalPlatformIds: next.externalPlatformIds, navigationPlatforms: navigationPlatforms, navigationIndex: navigationIndex + 1))), child: Text(next == null ? '—' : '${next.name} ›')),
            ]),
          ]),
        )),
      ]),
    );
  }
}

class _LibraryBackground extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(colors: [Color(0xFF18142A), Color(0xFF07070F), Color(0xFF010106)]).createShader(Offset.zero & s));
  }
  @override bool shouldRepaint(covariant _LibraryBackground old) => false;
}
