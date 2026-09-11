import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatelessWidget {
  final String territory;
  final List<GamePlatformGroup> groups;

  const GamePlatformPage({super.key, required this.territory, required this.groups});

  @override
  Widget build(BuildContext context) {
    final allPlatforms = groups.expand((group) => group.platforms).toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _PlatformBackgroundPainter())),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 18, 24, 8), child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 17)),
            const SizedBox(width: 8),
            Expanded(child: Text('$territory • GAME-WORLD', style: const TextStyle(letterSpacing: 3.2, fontSize: 16))),
          ])),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(24, 18, 24, 40), children: [
            Text(territory, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, letterSpacing: 5)),
            const SizedBox(height: 8),
            Text('PLATFORMS & GENERATIONS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .35), fontSize: 9, letterSpacing: 3)),
            const SizedBox(height: 30),
            ...groups.map((group) => _GroupCard(territory: territory, group: group, allPlatforms: allPlatforms)),
          ])),
        ])),
      ]),
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
  // Technical bridge used only when the visitor chooses live external search.
  // It does not define or populate DarkestWorld's own game hierarchy/database.
  final List<int> externalPlatformIds;
  const GamePlatform(this.name, this.externalPlatformIds);
}

class _GroupCard extends StatelessWidget {
  final String territory;
  final GamePlatformGroup group;
  final List<GamePlatform> allPlatforms;
  const _GroupCard({required this.territory, required this.group, required this.allPlatforms});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFF080817).withValues(alpha: .82), border: Border.all(color: const Color(0xFF8170FF).withValues(alpha: .14))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(group.name, style: const TextStyle(fontSize: 15, letterSpacing: 3)),
        const SizedBox(height: 5),
        Text(group.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .35), fontSize: 10)),
        const SizedBox(height: 14),
        Wrap(spacing: 9, runSpacing: 9, children: group.platforms.map((platform) => _PlatformButton(territory: territory, platform: platform, allPlatforms: allPlatforms)).toList()),
      ]),
    ),
  );
}

class _PlatformButton extends StatelessWidget {
  final String territory;
  final GamePlatform platform;
  final List<GamePlatform> allPlatforms;
  const _PlatformButton({required this.territory, required this.platform, required this.allPlatforms});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
      territory: territory,
      platform: platform.name,
      externalPlatformIds: platform.externalPlatformIds,
      navigationPlatforms: allPlatforms,
      navigationIndex: allPlatforms.indexOf(platform),
    ))),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF8D7BFF).withValues(alpha: .16)), gradient: const LinearGradient(colors: [Color(0xFF11102A), Color(0xFF080812)])),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8D7BFF))),
        const SizedBox(width: 9),
        Text(platform.name, style: const TextStyle(fontSize: 11, letterSpacing: 1.2)),
      ]),
    ),
  );
}

class _PlatformBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.1, colors: [Color(0xFF15132F), Color(0xFF060612), Color(0xFF010105)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final star = Paint();
    for (var i = 0; i < 120; i++) {
      final x = (i * 83.17) % size.width;
      final y = (i * 47.31) % size.height;
      star.color = Colors.white.withValues(alpha: .16 + (i % 5) * .04);
      canvas.drawCircle(Offset(x, y), i % 13 == 0 ? 1.0 : .45, star);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
