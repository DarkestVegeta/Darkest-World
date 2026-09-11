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

class _GamePlatformPageState extends State<GamePlatformPage> {
  int? selected;

  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList();

  void openPlatform(int index) {
    final platform = platforms[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameListPage(
          territory: widget.territory,
          platform: platform.name,
          externalPlatformIds: platform.externalPlatformIds,
          navigationPlatforms: platforms,
          navigationIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxWidth < 850;
          final width = math.min(box.maxWidth * 0.94, 1280.0);
          final height = math.min(box.maxHeight * 0.78, 720.0);
          final center = Offset(width / 2, height / 2);
          final positions = _positions(center, width, height, platforms.length);

          return Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _PlatformBackgroundPainter()),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 14 : 26),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.territory.toUpperCase()} / WORLDS',
                        style: const TextStyle(fontSize: 13, letterSpacing: 3.5),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: _RoutesPainter(center: center, positions: positions),
                      ),
                      for (var i = 0; i < platforms.length; i++)
                        Positioned(
                          left: positions[i].dx - 50,
                          top: positions[i].dy - 50,
                          child: _Node(
                            platform: platforms[i],
                            active: selected == i,
                            onTap: () => openPlatform(i),
                            onHover: () => setState(() => selected = i),
                          ),
                        ),
                      Positioned(
                        left: center.dx - 65,
                        top: center.dy - 65,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF302A45),
                                Color(0xFF0B0A12),
                                Color(0xFF020208),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.territory,
                                  style: const TextStyle(fontSize: 10, letterSpacing: 2),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'WORLD',
                                  style: TextStyle(
                                    fontSize: 7,
                                    letterSpacing: 2.4,
                                    color: Colors.white.withValues(alpha: 0.28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: compact ? 18 : 28,
                child: Text(
                  selected == null
                      ? 'SELECT PLATFORM'
                      : '${platforms[selected!].name.toUpperCase()} • ENTER WORLD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.4,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Offset> _positions(Offset center, double width, double height, int count) {
    final result = <Offset>[];
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / math.max(1, count);
      final rx = width * (0.18 + (i % 3) * 0.09);
      final ry = height * (0.16 + (i % 3) * 0.07);
      result.add(
        Offset(
          center.dx + math.cos(angle) * rx,
          center.dy + math.sin(angle) * ry,
        ),
      );
    }
    return result;
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

  const _Node({
    required this.platform,
    required this.active,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF6B608A), Color(0xFF242136), Color(0xFF05060C)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: active ? 0.28 : 0.09),
              width: active ? 1.4 : 0.7,
            ),
          ),
          child: Center(
            child: Text(
              platform.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: active ? 10 : 8,
                letterSpacing: 1.1,
                color: Colors.white.withValues(alpha: active ? 0.95 : 0.62),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformBackgroundPainter extends CustomPainter {
  const _PlatformBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF17142A), Color(0xFF06060D), Color(0xFF010106)],
        ).createShader(Offset.zero & size),
    );

    final random = math.Random(412);
    final paint = Paint();
    for (var i = 0; i < 260; i++) {
      paint.color = Colors.white.withValues(alpha: 0.025 + random.nextDouble() * 0.10);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.2 + random.nextDouble() * 0.7,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlatformBackgroundPainter oldDelegate) => false;
}

class _RoutesPainter extends CustomPainter {
  final Offset center;
  final List<Offset> positions;

  const _RoutesPainter({required this.center, required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = const Color(0x227F72A0);

    for (final point in positions) {
      canvas.drawLine(center, point, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutesPainter oldDelegate) => false;
}
