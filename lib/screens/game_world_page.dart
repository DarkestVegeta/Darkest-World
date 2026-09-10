import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class GameWorldPage extends StatefulWidget {
  const GameWorldPage({super.key});

  @override
  State<GameWorldPage> createState() => _GameWorldPageState();
}

class _GameWorldPageState extends State<GameWorldPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int selected = 0;

  static const territories = [
    _Territory('NINTENDO', 'Console history, worlds and games.', 0xFF9A72FF),
    _Territory('SEGA', 'Arcade roots, consoles and speed.', 0xFF4F86FF),
    _Territory('PLAYSTATION', 'A broad library of worlds and stories.', 0xFF776BFF),
    _Territory('XBOX', 'A modern frontier of interactive worlds.', 0xFF58A5FF),
    _Territory('PC', 'An open territory without fixed borders.', 0xFFB084FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openTerritory(int index) {
    setState(() => selected = index);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContentBrowserPage(
          title: '${territories[index].name} • GAME-WORLD',
          contentType: 'game',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(painter: _GameWorldPainter(_controller.value)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                      ),
                      const SizedBox(width: 10),
                      const Text('GAME-WORLD', style: TextStyle(letterSpacing: 4.5, fontSize: 18)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 390,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final center = Offset(constraints.maxWidth / 2, 195);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _TerritoryLinesPainter(center: center, selected: selected),
                            ),
                          ),
                          ...List.generate(territories.length, (index) {
                            final angle = -math.pi / 2 + index * (math.pi * 2 / 5);
                            final radius = math.min(constraints.maxWidth * .29, 260.0);
                            final size = index == selected ? 116.0 : 92.0;
                            final p = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
                            return Positioned(
                              left: p.dx - size / 2,
                              top: p.dy - size / 2,
                              child: GestureDetector(
                                onTap: () => _openTerritory(index),
                                child: _TerritoryOrb(
                                  size: size,
                                  accent: Color(territories[index].accent),
                                  selected: index == selected,
                                ),
                              ),
                            );
                          }),
                          Positioned(
                            left: center.dx - 62,
                            top: center.dy - 62,
                            child: const _CoreOrb(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Padding(
                    key: ValueKey(selected),
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 34),
                    child: Column(
                      children: [
                        Text(
                          territories[selected].name,
                          style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 5,
                            color: Color(territories[selected].accent),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          territories[selected].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: .48), fontSize: 12),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'ENTER TERRITORY',
                          style: TextStyle(letterSpacing: 3.2, fontSize: 9, color: Colors.white.withValues(alpha: .28)),
                        ),
                      ],
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

class _Territory {
  final String name;
  final String description;
  final int accent;
  const _Territory(this.name, this.description, this.accent);
}

class _CoreOrb extends StatelessWidget {
  const _CoreOrb();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFF24204A), Color(0xFF090817), Color(0xFF020208)]),
        boxShadow: [BoxShadow(color: const Color(0xFF7258FF).withValues(alpha: .35), blurRadius: 38, spreadRadius: 4)],
        border: Border.all(color: const Color(0xFF9B7CFF).withValues(alpha: .35)),
      ),
      child: const Center(child: Text('GAME', style: TextStyle(letterSpacing: 4, fontSize: 14))),
    );
  }
}

class _TerritoryOrb extends StatelessWidget {
  final double size;
  final Color accent;
  final bool selected;
  const _TerritoryOrb({required this.size, required this.accent, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [accent.withValues(alpha: .34), const Color(0xFF0B0B16), const Color(0xFF030309)]),
        border: Border.all(color: accent.withValues(alpha: selected ? .72 : .27), width: selected ? 1.6 : 1),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: selected ? .30 : .10), blurRadius: selected ? 30 : 15)],
      ),
      child: Center(
        child: Text(
          selected ? '●' : '○',
          style: TextStyle(color: accent.withValues(alpha: .75), fontSize: selected ? 13 : 10),
        ),
      ),
    );
  }
}

class _TerritoryLinesPainter extends CustomPainter {
  final Offset center;
  final int selected;
  const _TerritoryLinesPainter({required this.center, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width * .29, 260.0);
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF806CFF).withValues(alpha: .13);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2.25, height: radius * 1.65), orbit);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 1.62, height: radius * 1.18), orbit..color = const Color(0xFF4C8FFF).withValues(alpha: .10));

    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * (math.pi * 2 / 5);
      final end = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == selected ? 1.5 : .7
        ..color = Color(territories[i].accent).withValues(alpha: i == selected ? .24 : .09);
      canvas.drawLine(center, end, p);
    }
  }

  @override
  bool shouldRepaint(covariant _TerritoryLinesPainter oldDelegate) => oldDelegate.selected != selected;
}

class _GameWorldPainter extends CustomPainter {
  final double t;
  const _GameWorldPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, .05),
        radius: 1.0,
        colors: [Color(0xFF11102A), Color(0xFF060612), Color(0xFF010105)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final nebula = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
    for (var i = 0; i < 6; i++) {
      final x = size.width * (.18 + i * .14) + math.sin(t * math.pi * 2 + i) * 35;
      final y = size.height * (.26 + (i % 3) * .22);
      nebula.color = (i.isEven ? const Color(0xFF694CFF) : const Color(0xFF397BFF)).withValues(alpha: .035);
      canvas.drawCircle(Offset(x, y), 105 + i * 15, nebula);
    }

    final star = Paint();
    for (var i = 0; i < 170; i++) {
      final seed = i * 47.17;
      final x = math.sin(seed).abs() * size.width;
      final y = math.sin(seed * 1.37).abs() * size.height;
      final twinkle = .25 + .35 * ((math.sin(t * math.pi * 2 + i) + 1) / 2);
      star.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(x, y), i % 9 == 0 ? 1.25 : .55, star);
    }
  }

  @override
  bool shouldRepaint(covariant _GameWorldPainter oldDelegate) => true;
}
