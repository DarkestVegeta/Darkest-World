import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;

  const GamePlatformPage({
    super.key,
    required this.territory,
    required this.groups,
  });

  @override
  State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  )..repeat();

  int? _selected;

  List<GamePlatform> get _platforms => widget.groups
      .expand((group) => group.platforms)
      .toList(growable: false);

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _enter(int index) {
    final platform = _platforms[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameListPage(
          territory: widget.territory,
          platform: platform.name,
          externalPlatformIds: platform.externalPlatformIds,
          navigationPlatforms: _platforms,
          navigationIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;

    return Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _PlatformSpacePainter(_clock.value)),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 14 : 30,
                    compact ? 12 : 24,
                    compact ? 14 : 30,
                    0,
                  ),
                  child: _Header(
                    territory: widget.territory,
                    count: _platforms.length,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Center(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final diameter = math.min(
                      box.maxWidth * (compact ? .96 : .82),
                      box.maxHeight * (compact ? .70 : .78),
                    ).toDouble();
                    return SizedBox.square(
                      dimension: diameter,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SystemPainter(
                                _clock.value,
                                widget.groups.length,
                              ),
                            ),
                          ),
                          for (var i = 0; i < _platforms.length; i++)
                            _PlanetNode(
                              platform: _platforms[i],
                              index: i,
                              total: _platforms.length,
                              selected: _selected == i,
                              size: diameter,
                              phase: _clock.value,
                              onTap: () => setState(() {
                                _selected = _selected == i ? null : i;
                              }),
                              onOpen: () => _enter(i),
                            ),
                          const Positioned.fill(
                            child: IgnorePointer(
                              child: Center(child: _StarCore()),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: compact ? 14 : 30,
                right: compact ? 14 : 30,
                bottom: compact ? 14 : 24,
                child: _selected == null
                    ? const _Hint()
                    : _PlatformPanel(
                        platform: _platforms[_selected!],
                        index: _selected!,
                        total: _platforms.length,
                        onClose: () => setState(() => _selected = null),
                        onOpen: () => _enter(_selected!),
                      ),
              ),
            ],
          );
        },
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

  const _Header({
    required this.territory,
    required this.count,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: Color(0x99FFFFFF),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${territory.toUpperCase()} / PLATFORM WORLDS',
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 3.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'GENERATIONS / ORBITAL ATLAS',
              style: TextStyle(
                fontSize: 6.5,
                letterSpacing: 2.4,
                color: Color(0x55FFFFFF),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '${count.toString().padLeft(2, '0')} WORLDS',
          style: const TextStyle(
            fontSize: 7,
            letterSpacing: 2,
            color: Color(0x55FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _PlanetNode extends StatelessWidget {
  final GamePlatform platform;
  final int index;
  final int total;
  final bool selected;
  final double size;
  final double phase;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  const _PlanetNode({
    required this.platform,
    required this.index,
    required this.total,
    required this.selected,
    required this.size,
    required this.phase,
    required this.onTap,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final orbit =
        (size * (.18 + (index % 5) * .055)).toDouble();
    final angle = (-math.pi / 2 +
            index * math.pi * 2 / math.max(1, total) +
            phase * math.pi * .18 * (index.isEven ? 1 : -1))
        .toDouble();
    final center = size / 2;
    final position = Offset(
      center + math.cos(angle) * orbit,
      center + math.sin(angle) * orbit,
    );
    final diameter = (selected
            ? math.max(76.0, size * .105)
            : math.max(54.0, size * .074))
        .toDouble();

    return Positioned(
      left: position.dx - diameter / 2,
      top: position.dy - diameter / 2,
      width: diameter,
      height: diameter + 28,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onOpen,
          child: Column(
            children: [
              SizedBox.square(
                dimension: diameter,
                child: CustomPaint(
                  painter: _PlanetPainter(
                    seed: index,
                    selected: selected,
                    phase: phase,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                platform.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: selected ? 8 : 6.5,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(
                    alpha: selected ? .95 : .48,
                  ),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed;
  final bool selected;
  final double phase;

  const _PlanetPainter({
    required this.seed,
    required this.selected,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .37;
    final sphere = Rect.fromCircle(center: center, radius: radius);
    final base = [
      const Color(0xFFB8A797),
      const Color(0xFF89979A),
      const Color(0xFF687B88),
      const Color(0xFFA08E80),
      const Color(0xFF748881),
    ][seed % 5];

    if (selected) {
      canvas.drawCircle(
        center,
        radius * 1.6,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF9FB4C8).withValues(alpha: .16),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius * 1.6),
          ),
      );
    }

    final light = Alignment(
      -.42 + math.sin(phase * math.pi * 2 + seed) * .04,
      -.48,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: light,
          radius: 1.02,
          colors: [
            base,
            base.withValues(alpha: .72),
            const Color(0xFF202833),
            const Color(0xFF05070B),
          ],
        ).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    final random = math.Random(900 + seed * 17);
    for (var i = 0; i < 20; i++) {
      final px = center.dx +
          (random.nextDouble() * 2 - 1) * radius * .88;
      final py = center.dy +
          (random.nextDouble() * 2 - 1) * radius * .88;
      final crater = 1.1 + random.nextDouble() * radius * .075;
      canvas.drawCircle(
        Offset(px, py),
        crater,
        Paint()
          ..color = Colors.white.withValues(
            alpha: .03 + random.nextDouble() * .055,
          ),
      );
    }

    final longitude = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..color = const Color(0x309EADB5);
    for (var i = 0; i < 4; i++) {
      final dx = (i - 1.5) * radius * .32;
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(dx, 0),
          width: radius * (.35 + i * .22),
          height: radius * 1.82,
        ),
        longitude,
      );
    }

    final night = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Color(0xDD00030A),
          Color(0x99000308),
        ],
      ).createShader(sphere);
    canvas.drawOval(sphere, night);
    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.3 : .65
        ..color = const Color(0x689BAAB5),
    );

    if (selected) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 1.16),
        -1.8,
        1.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = const Color(0x7898B0C5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter old) =>
      old.seed != seed || old.selected != selected || old.phase != phase;
}

class _SystemPainter extends CustomPainter {
  final double phase;
  final int groups;

  const _SystemPainter(this.phase, this.groups);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide * .43;

    for (var i = 0; i < 5; i++) {
      final radius = size.shortestSide * (.19 + i * .052);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 1.18,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 4 ? 1 : .55
          ..color = const Color(0x2493A4B2),
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      phase * math.pi * 2,
      .55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x487D91A3),
    );

    final axis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55
      ..color = const Color(0x183F5362);
    for (var i = 0; i < groups + 1; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: maxRadius * 2 * (.48 + i * .12),
          height: maxRadius * 1.15,
        ),
        axis,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SystemPainter old) =>
      old.phase != phase || old.groups != groups;
}

class _StarCore extends StatelessWidget {
  const _StarCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFD7C6A1),
            Color(0xFF74644D),
            Color(0x00000000),
          ],
          stops: [0, .25, .5, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x669C8868),
            blurRadius: 28,
            spreadRadius: 7,
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '1× CLICK  FOCUS     2× CLICK  ENTER WORLD     •     SCROLL TO ZOOM',
        style: TextStyle(
          color: Color(0x4FFFFFFF),
          fontSize: 6.5,
          letterSpacing: 1.9,
        ),
      ),
    );
  }
}

class _PlatformPanel extends StatelessWidget {
  final GamePlatform platform;
  final int index;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _PlatformPanel({
    required this.platform,
    required this.index,
    required this.total,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
      decoration: BoxDecoration(
        color: const Color(0xED070B11),
        border: Border.all(color: const Color(0x457C91A1)),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 34),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 45,
            color: const Color(0x907C91A1),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLATFORM WORLD  •  ${index + 1}/$total',
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: Color(0x55FFFFFF),
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  platform.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 2.7,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GENERATION ARCHIVE / GAME CATALOG',
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Color(0x66FFFFFF),
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Text(
                '×',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0x99FFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: onOpen,
            child: const Text('ENTER'),
          ),
        ],
      ),
    );
  }
}

class _PlatformSpacePainter extends CustomPainter {
  final double phase;

  const _PlatformSpacePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(.5, .45),
          radius: 1.15,
          colors: [
            Color(0xFF151C27),
            Color(0xFF070A10),
            Color(0xFF010207),
          ],
        ).createShader(rect),
    );

    final random = math.Random(412);
    for (var i = 0; i < 430; i++) {
      final x = (random.nextDouble() * size.width +
              phase * size.width * .012) %
          size.width;
      final y = random.nextDouble() * size.height;
      final alpha = .025 + random.nextDouble() * .075;
      canvas.drawCircle(
        Offset(x, y),
        .15 + random.nextDouble() * .7,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    final center = Offset(size.width * .5, size.height * .5);
    final radius = math.min(size.width, size.height) * .48;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x667F8DA0),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _PlatformSpacePainter old) =>
      old.phase != phase;
}
