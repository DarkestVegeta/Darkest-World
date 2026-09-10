import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestGalaxy extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;

  const DarkestGalaxy({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestGalaxy> createState() => _DarkestGalaxyState();
}

class _DarkestGalaxyState extends State<DarkestGalaxy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 55),
  )..repeat();

  int? selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        return Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(painter: _GalaxyPainter(_controller)),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300, maxHeight: 820),
                child: Stack(
                  children: [
                    _planet(
                      index: 0,
                      alignment: const Alignment(0.02, 0.02),
                      size: compact ? 190 : 285,
                      central: true,
                    ),
                    ..._positions(compact).asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final p = entry.value;
                      return Positioned(
                        left: p.dx,
                        top: p.dy,
                        child: _planet(
                          index: index,
                          alignment: Alignment.topLeft,
                          size: compact ? 78 : 112,
                        ),
                      );
                    }),
                    if (selected != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _WorldPanel(
                          world: widget.worlds[selected!],
                          onClose: () => setState(() => selected = null),
                          onEnter: () => widget.onWorldTap?.call(widget.worlds[selected!]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _planet({
    required int index,
    required Alignment alignment,
    required double size,
    bool central = false,
  }) {
    if (index >= widget.worlds.length) return const SizedBox.shrink();
    final world = widget.worlds[index];
    final isSelected = selected == index;
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => setState(() => selected = index),
        child: SizedBox(
          width: size + 125,
          height: size + 100,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: size + 34,
                  height: size + 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9B6CFF).withValues(alpha: .38),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF743CFF).withValues(alpha: .22),
                        blurRadius: 42,
                        spreadRadius: 7,
                      ),
                    ],
                  ),
                ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-.38, -.38),
                    radius: 1.0,
                    colors: _planetColors(world.kind),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6537B9).withValues(alpha: central ? .30 : .18),
                      blurRadius: central ? 70 : 28,
                      spreadRadius: central ? 8 : 1,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _PlanetPainter(
                    seed: index * 29 + 7,
                    damaged: world.kind == GalaxyWorldKind.vegeta,
                  ),
                ),
              ),
              Positioned(
                left: size + 10,
                top: size * .50 - 14,
                child: _WorldLabel(
                  title: world.title,
                  active: isSelected || central,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Offset> _positions(bool compact) {
    if (compact) {
      return const [
        Offset(18, 55), Offset(270, 24), Offset(18, 300), Offset(278, 285),
        Offset(92, 480), Offset(318, 470), Offset(148, 150), Offset(205, 610),
      ];
    }
    return const [
      Offset(45, 95), Offset(430, 18), Offset(865, 90), Offset(80, 455),
      Offset(820, 420), Offset(405, 600), Offset(585, 180), Offset(1010, 575),
    ];
  }

  List<Color> _planetColors(GalaxyWorldKind kind) {
    switch (kind) {
      case GalaxyWorldKind.vegeta:
        return const [Color(0xFF4B376E), Color(0xFF19152A), Color(0xFF050309)];
      case GalaxyWorldKind.game:
        return const [Color(0xFF5A3D8C), Color(0xFF251744), Color(0xFF07040E)];
      case GalaxyWorldKind.music:
        return const [Color(0xFF3B5D91), Color(0xFF18284C), Color(0xFF050811)];
      case GalaxyWorldKind.identity:
        return const [Color(0xFF6C478F), Color(0xFF28193A), Color(0xFF070409)];
      case GalaxyWorldKind.family:
        return const [Color(0xFF536A86), Color(0xFF22283D), Color(0xFF07090F)];
      case GalaxyWorldKind.cinema:
        return const [Color(0xFF765C95), Color(0xFF2D1E3C), Color(0xFF08050C)];
      case GalaxyWorldKind.creation:
        return const [Color(0xFF4C6695), Color(0xFF202846), Color(0xFF060811)];
      case GalaxyWorldKind.archive:
        return const [Color(0xFF655C78), Color(0xFF292633), Color(0xFF08070B)];
      case GalaxyWorldKind.comingSoon:
        return const [Color(0xFF8A67C4), Color(0xFF32204E), Color(0xFF09050F)];
    }
  }
}

class _WorldLabel extends StatelessWidget {
  final String title;
  final bool active;
  const _WorldLabel({required this.title, required this.active});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontSize: active ? 10 : 8.5,
          letterSpacing: active ? 2.4 : 1.8,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: active ? .86 : .54),
          shadows: const [Shadow(blurRadius: 12, color: Colors.black)],
        ),
      ),
    );
  }
}

enum GalaxyWorldKind { vegeta, game, music, identity, family, cinema, creation, archive, comingSoon }

class GalaxyWorld {
  final String title;
  final String description;
  final GalaxyWorldKind kind;
  const GalaxyWorld(this.title, this.description, this.kind);
}

class _GalaxyPainter extends CustomPainter {
  final Animation<double> animation;
  _GalaxyPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.12, -0.05),
          radius: 1.05,
          colors: [Color(0xFF110B20), Color(0xFF05030A), Color(0xFF010106)],
        ).createShader(rect),
    );

    final center = Offset(size.width * .5, size.height * .5);
    final nebulaRect = Rect.fromCircle(center: center, radius: size.longestSide * .46);
    canvas.drawCircle(
      center,
      size.longestSide * .46,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF7A4BB7).withValues(alpha: .10),
            const Color(0xFF304F9B).withValues(alpha: .035),
            Colors.transparent,
          ],
        ).createShader(nebulaRect),
    );

    final random = math.Random(91);
    final stars = Paint();
    for (var i = 0; i < 420; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final pulse = .30 + .70 * ((math.sin(animation.value * math.pi * 2 + i * 1.71) + 1) / 2);
      stars.color = Colors.white.withValues(alpha: (.05 + random.nextDouble() * .32) * pulse);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.15, stars);
    }

    final dust = Paint()..color = const Color(0xFF8C67C4).withValues(alpha: .12);
    final orbit = math.min(size.width, size.height) * .36;
    for (var i = 0; i < 28; i++) {
      final a = animation.value * math.pi * 2 + i * math.pi * 2 / 28;
      canvas.drawCircle(
        center + Offset(math.cos(a) * orbit, math.sin(a) * orbit * .42),
        1.1,
        dust,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final int seed;
  final bool damaged;
  _PlanetPainter({required this.seed, required this.damaged});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final random = math.Random(seed);

    final surface = Paint()..color = Colors.white.withValues(alpha: .055);
    for (var i = 0; i < 8; i++) {
      final y = c.dy - r * .70 + i * r * .19;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(c.dx, y), width: r * (1.35 + i * .06), height: r * .12),
        surface,
      );
    }

    final dots = Paint();
    for (var i = 0; i < 50; i++) {
      final x = c.dx + (random.nextDouble() * 2 - 1) * r * .82;
      final y = c.dy + (random.nextDouble() * 2 - 1) * r * .82;
      if ((Offset(x, y) - c).distance < r * .88) {
        dots.color = Colors.white.withValues(alpha: .035 + random.nextDouble() * .055);
        canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.3, dots);
      }
    }

    if (damaged) {
      final crack = Paint()
        ..color = const Color(0xFF120C18).withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .018;
      final path = Path()
        ..moveTo(c.dx - r * .52, c.dy - r * .08)
        ..lineTo(c.dx - r * .15, c.dy + r * .04)
        ..lineTo(c.dx - r * .27, c.dy + r * .31)
        ..moveTo(c.dx + r * .10, c.dy - r * .58)
        ..lineTo(c.dx + r * .02, c.dy - r * .18)
        ..lineTo(c.dx + r * .26, c.dy + r * .12);
      canvas.drawPath(path, crack);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) => false;
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _WorldPanel({required this.world, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: math.min(MediaQuery.sizeOf(context).width - 32, 430),
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(20, 17, 16, 17),
      decoration: BoxDecoration(
        color: const Color(0xFF08050D).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D65C7).withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6D3FAD).withValues(alpha: .12), blurRadius: 35),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(world.title, style: const TextStyle(fontSize: 13, letterSpacing: 2.6)),
                const SizedBox(height: 7),
                Text(world.description, style: TextStyle(fontSize: 11, height: 1.45, color: Colors.white.withValues(alpha: .48))),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17)),
          TextButton(onPressed: onEnter, child: const Text('ENTER')),
        ],
      ),
    );
  }
}
