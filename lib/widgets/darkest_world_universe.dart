import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GalaxyWorldKind {
  vegeta,
  game,
  identity,
  cinema,
  creation,
  music,
  family,
  archive,
  comingSoon,
}

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;

  const GalaxyWorld({
    required this.kind,
    required this.title,
    required this.description,
  });
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  final ValueChanged<GalaxyWorld>? onWorldSelect;

  const DarkestWorldUniverse({
    super.key,
    required this.worlds,
    this.onWorldTap,
    this.onWorldSelect,
  });

  @override
  State<DarkestWorldUniverse> createState() => _UniverseState();
}

class _UniverseState extends State<DarkestWorldUniverse>
    with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 70),
  )..repeat();

  int? selected;
  double manualPhase = 0;
  double zoom = 1;
  bool autoOrbit = true;
  bool map = false;
  bool labels = true;
  bool detail = true;
  bool safeMode = false;
  bool locked = false;

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  void select(int index, {bool open = false}) {
    if (index < 0 || index >= widget.worlds.length) return;
    setState(() {
      selected = index;
      locked = true;
    });
    widget.onWorldSelect?.call(widget.worlds[index]);
    if (open) visitSelected();
  }

  void move(int delta) {
    if (widget.worlds.isEmpty) return;
    final current = selected ?? 0;
    final next = (current + delta + widget.worlds.length) % widget.worlds.length;
    select(next);
  }

  void visitSelected() {
    final index = selected;
    if (index == null || index < 0 || index >= widget.worlds.length) return;
    widget.onWorldTap?.call(widget.worlds[index]);
  }

  void resetTarget() {
    setState(() {
      selected = null;
      locked = false;
    });
  }

  void resetAll() {
    setState(() {
      zoom = 1;
      manualPhase = 0;
      selected = null;
      locked = false;
      autoOrbit = true;
      map = false;
      labels = true;
      detail = true;
      safeMode = false;
    });
  }

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    const digits = <LogicalKeyboardKey>[
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    final digit = digits.indexOf(key);
    if (digit >= 0) {
      select(digit);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter) {
      visitSelected();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyM) {
      setState(() => map = !map);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyL) {
      setState(() => labels = !labels);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyD) {
      setState(() => detail = !detail);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyS) {
      setState(() => safeMode = !safeMode);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space) {
      setState(() => autoOrbit = !autoOrbit);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      resetTarget();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: handleKey,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            setState(() {
              zoom = (zoom - event.scrollDelta.dy * .00065)
                  .clamp(.65, 1.7)
                  .toDouble();
            });
          }
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            if (!autoOrbit && !map) {
              setState(() {
                manualPhase += details.delta.dx /
                    math.max(220, MediaQuery.sizeOf(context).width);
              });
            }
          },
          onDoubleTap: resetAll,
          child: AnimatedBuilder(
            animation: clock,
            builder: (_, __) {
              final phase = autoOrbit ? clock.value * math.pi * 2 : manualPhase;
              final target = selected == null ? null : widget.worlds[selected!];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: SpacePainter(clock.value, safeMode: safeMode),
                  ),
                  if (map)
                    MapView(
                      worlds: widget.worlds,
                      selected: selected,
                      onSelect: (i) => select(i, open: true),
                    )
                  else
                    OrbitView(
                      worlds: widget.worlds,
                      phase: phase,
                      selected: selected,
                      labels: labels,
                      zoom: zoom,
                      detail: detail,
                      safeMode: safeMode,
                      onSelect: (i) => select(i, open: true),
                    ),
                  Positioned(
                    left: 18,
                    top: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DARKESTWORLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          map ? 'MAP VIEW' : 'GALAXY VIEW',
                          style: const TextStyle(
                            color: Color(0x66FFFFFF),
                            fontSize: 7,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          target == null
                              ? 'NO TARGET LOCK'
                              : 'TARGET LOCK / ${target.title}',
                          style: TextStyle(
                            color: target == null
                                ? const Color(0x44FFFFFF)
                                : const Color(0xAAFFFFFF),
                            fontSize: 6,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Positioned(
                      right: 18,
                      bottom: 58,
                      child: WorldPanel(
                        world: widget.worlds[selected!],
                        locked: locked,
                        onPrevious: () => move(-1),
                        onCurrent: visitSelected,
                        onNext: () => move(1),
                        onEnter: visitSelected,
                        onClose: resetTarget,
                      ),
                    ),
                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: Hud(
                      worlds: widget.worlds.length,
                      selected: selected,
                      zoom: zoom,
                      map: map,
                      orbit: autoOrbit,
                      detail: detail,
                      safeMode: safeMode,
                      locked: locked,
                    ),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 16,
                    child: Row(
                      children: [
                        Control(
                          label: 'PAUSE',
                          active: !autoOrbit,
                          onTap: () => setState(() => autoOrbit = false),
                        ),
                        const SizedBox(width: 5),
                        Control(
                          label: map ? 'PLANET' : 'MAP',
                          onTap: () => setState(() => map = !map),
                        ),
                        const SizedBox(width: 5),
                        Control(
                          label: labels ? 'LABELS' : 'NO LABELS',
                          onTap: () => setState(() => labels = !labels),
                        ),
                        const SizedBox(width: 5),
                        Control(
                          label: detail ? 'DETAIL' : 'NO DETAIL',
                          onTap: () => setState(() => detail = !detail),
                        ),
                        const SizedBox(width: 5),
                        Control(
                          label: safeMode ? 'SAFE' : 'SAFE',
                          active: safeMode,
                          onTap: () => setState(() => safeMode = !safeMode),
                        ),
                        const SizedBox(width: 5),
                        Control(
                          label: 'MOTION',
                          active: autoOrbit,
                          onTap: () => setState(() => autoOrbit = !autoOrbit),
                        ),
                        const SizedBox(width: 5),
                        Control(label: 'RESET', onTap: resetAll),
                        const SizedBox(width: 5),
                        Control(
                          label: '−',
                          onTap: () => setState(
                            () => zoom = math.max(.65, zoom - .1),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Control(
                          label: '+',
                          onTap: () => setState(
                            () => zoom = math.min(1.7, zoom + .1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 18,
                    top: 78,
                    child: Text(
                      '← → SELECT  •  ENTER VISIT  •  M MAP  •  L LABELS  •  D DETAIL  •  S SAFE  •  SPACE MOTION',
                      style: TextStyle(
                        color: Color(0x36FFFFFF),
                        fontSize: 5.5,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SpacePainter extends CustomPainter {
  final double t;
  final bool safeMode;

  const SpacePainter(this.t, {this.safeMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF171326), Color(0xFF07070F), Color(0xFF010106)],
        ).createShader(Offset.zero & size),
    );
    final random = math.Random(412);
    final count = safeMode ? 85 : 150;
    for (var i = 0; i < count; i++) {
      final x = safeMode
          ? random.nextDouble() * size.width
          : (random.nextDouble() * size.width + t * 12) % size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        .2 + random.nextDouble() * (safeMode ? .3 : .45),
        Paint()..color = const Color(0x18FFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpacePainter old) =>
      old.t != t || old.safeMode != safeMode;
}

class OrbitView extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final double phase;
  final double zoom;
  final int? selected;
  final bool labels;
  final bool detail;
  final bool safeMode;
  final ValueChanged<int> onSelect;

  const OrbitView({
    super.key,
    required this.worlds,
    required this.phase,
    required this.selected,
    required this.labels,
    required this.zoom,
    required this.detail,
    required this.safeMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(700, 360),
              painter: OrbitPainter(detail: detail),
            ),
          ),
          for (var i = 0; i < worlds.length; i++)
            Node(
              world: worlds[i],
              index: i,
              count: worlds.length,
              phase: phase,
              selected: selected == i,
              labels: labels,
              zoom: zoom,
              detail: detail,
              safeMode: safeMode,
              onTap: () => onSelect(i),
            ),
        ],
      );
}

class Node extends StatelessWidget {
  final GalaxyWorld world;
  final int index;
  final int count;
  final double phase;
  final double zoom;
  final bool selected;
  final bool labels;
  final bool detail;
  final bool safeMode;
  final VoidCallback onTap;

  const Node({
    super.key,
    required this.world,
    required this.index,
    required this.count,
    required this.phase,
    required this.selected,
    required this.labels,
    required this.zoom,
    required this.detail,
    required this.safeMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final angle = phase + index / math.max(1, count) * math.pi * 2;
    final x = .5 + math.cos(angle) * .28;
    final y = .5 + math.sin(angle) * .20;
    final depth = (.5 + math.sin(angle) * .5).clamp(0.0, 1.0);
    final base = detail ? 38.0 : 32.0;
    final size = (base +
            depth * (detail ? 22 : 14) +
            (selected ? (detail ? 18 : 12) : 0)) *
        zoom;

    return Align(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      child: Semantics(
        label: world.title,
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF77718D),
                      Color(0xFF211D32),
                      Color(0xFF05060C),
                    ],
                  ),
                  border: Border.all(
                    color: selected
                        ? const Color(0xCCFFFFFF)
                        : const Color(0x445F5870),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected && detail && !safeMode
                      ? const [
                          BoxShadow(
                            color: Color(0x555D4F79),
                            blurRadius: 24,
                          ),
                        ]
                      : const [],
                ),
              ),
              if (labels && !selected)
                Text(
                  world.title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 6,
                    letterSpacing: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  final bool detail;

  const OrbitPainter({this.detail = true});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x223F4A65);
    for (var i = 1; i <= (detail ? 4 : 2); i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 120.0 * i,
          height: 38.0 * i,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OrbitPainter old) => old.detail != detail;
}

class MapView extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final int? selected;
  final ValueChanged<int> onSelect;

  const MapView({
    super.key,
    required this.worlds,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: GridView.builder(
            padding: const EdgeInsets.all(50),
            shrinkWrap: true,
            itemCount: worlds.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisExtent: 110,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final active = selected == i;
              return Semantics(
                label: worlds[i].title,
                button: true,
                selected: active,
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0x221A1D2A)
                          : const Color(0x0AFFFFFF),
                      border: Border.all(
                        color: active
                            ? const Color(0x88FFFFFF)
                            : const Color(0x1AFFFFFF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${i + 1}'.padLeft(2, '0'),
                          style: const TextStyle(
                            color: Color(0x40FFFFFF),
                            fontSize: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          worlds[i].title,
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 10,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          worlds[i].description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0x59FFFFFF),
                            fontSize: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class WorldPanel extends StatelessWidget {
  final GalaxyWorld world;
  final bool locked;
  final VoidCallback onPrevious;
  final VoidCallback onCurrent;
  final VoidCallback onNext;
  final VoidCallback onEnter;
  final VoidCallback onClose;

  const WorldPanel({
    super.key,
    required this.world,
    required this.locked,
    required this.onPrevious,
    required this.onCurrent,
    required this.onNext,
    required this.onEnter,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 310,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xE8070910),
          border: Border.all(
            color: locked
                ? const Color(0x667D7399)
                : const Color(0x44FFFFFF),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TARGET LOCK',
              style: TextStyle(
                color: Color(0x66FFFFFF),
                fontSize: 6,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              locked ? 'ACQUIRED' : 'READY',
              style: const TextStyle(
                color: Color(0x447FFFFFF),
                fontSize: 5,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              world.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              world.description,
              style: const TextStyle(
                color: Color(0x77FFFFFF),
                fontSize: 7,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Control(label: 'PREVIOUS', onTap: onPrevious)),
                const SizedBox(width: 4),
                Expanded(child: Control(label: 'CURRENT', onTap: onCurrent)),
                const SizedBox(width: 4),
                Expanded(child: Control(label: 'NEXT', onTap: onNext)),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(child: Control(label: 'VISIT', onTap: onEnter)),
                const SizedBox(width: 4),
                Expanded(child: Control(label: 'CLOSE', onTap: onClose)),
              ],
            ),
          ],
        ),
      );
}

class Hud extends StatelessWidget {
  final int worlds;
  final int? selected;
  final double zoom;
  final bool map;
  final bool orbit;
  final bool detail;
  final bool safeMode;
  final bool locked;

  const Hud({
    super.key,
    required this.worlds,
    required this.selected,
    required this.zoom,
    required this.map,
    required this.orbit,
    required this.detail,
    required this.safeMode,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) => Text(
        '${selected == null ? 'NO TARGET' : 'TARGET ${selected! + 1}/$worlds'}  •  ${map ? 'MAP' : 'GALAXY'}  •  ${orbit ? 'MOTION' : 'PAUSED'}  •  ZOOM ${zoom.toStringAsFixed(1)}  •  ${detail ? 'DETAIL' : 'SAFE DETAIL'}${safeMode ? '  •  SAFE' : ''}',
        style: const TextStyle(
          color: Color(0x44FFFFFF),
          fontSize: 5.5,
          letterSpacing: .9,
        ),
      );
}

class Control extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool active;

  const Control({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0x221A1D2A)
                : const Color(0x0AFFFFFF),
            border: Border.all(
              color: active
                  ? const Color(0x667D7399)
                  : const Color(0x1AFFFFFF),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xAAFFFFFF),
              fontSize: 5.5,
              letterSpacing: 1,
            ),
          ),
        ),
      );
}
