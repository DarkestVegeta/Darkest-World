import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class GameListPage extends StatelessWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;

  const GameListPage({
    super.key,
    required this.territory,
    required this.platform,
    required this.externalPlatformIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GamesBackgroundPainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$platform • GAMES',
                          style: const TextStyle(letterSpacing: 3.2, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              territory,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .38),
                                fontSize: 10,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              platform,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 34,
                                letterSpacing: 5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'GAMES',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .34),
                                fontSize: 11,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFF090918).withValues(alpha: .9),
                                border: Border.all(
                                  color: const Color(0xFF8D7BFF).withValues(alpha: .18),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'GAME BROWSER',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .55),
                                      fontSize: 12,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Browse the games belonging to this platform.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .38),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: 260,
                                    child: FilledButton(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ContentBrowserPage(
                                            title: '$platform • GAME-WORLD',
                                            contentType: 'game',
                                            platformIds: externalPlatformIds,
                                          ),
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        child: Text(
                                          'OPEN GAMES',
                                          style: TextStyle(letterSpacing: 2.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'DarkestWorld hierarchy: $territory → $platform → Games',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .20),
                                fontSize: 10,
                                letterSpacing: .8,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Live external search remains separate and is never stored here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .16),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GamesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -.1),
        radius: 1.1,
        colors: [Color(0xFF15132F), Color(0xFF060612), Color(0xFF010105)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final glow = Paint()
      ..color = const Color(0xFF7560FF).withValues(alpha: .035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width / 2, size.height * .46), 220, glow);

    final star = Paint();
    for (var i = 0; i < 100; i++) {
      final x = (i * 91.13) % size.width;
      final y = (i * 53.71) % size.height;
      star.color = Colors.white.withValues(alpha: .12 + (i % 5) * .035);
      canvas.drawCircle(Offset(x, y), i % 17 == 0 ? .95 : .42, star);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
