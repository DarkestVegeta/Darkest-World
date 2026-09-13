import 'dart:math' as math;
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

enum GalaxyVisualTier { eco, balanced, cinematic }

enum GalaxyCameraMode { free, focus }

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

  const DarkestWorldUniverse({
    super.key,
    required this.worlds,
    this.onWorldTap,
  });

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 96),
  );

  GalaxyWorldKind? selected;
  GalaxyWorldKind? hovered;
  GalaxyCameraMode cameraMode = GalaxyCameraMode.free;
  GalaxyVisualTier visualTier = GalaxyVisualTier.balanced;

  double orbit = 0;
  double zoom = 1;
  double targetZoom = 1;
  double dragVelocity = 0;
  bool systemMap = false;
  bool labels = true;
  bool detail = true;
  bool grid = false;
  bool autoOrbit = true;
  bool lowMotion = false;
  bool autoQuality = true;
  bool controlsOpen = true;
  bool helpOpen = false;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clock.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncClock();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      clock.stop();
    }
  }

  GalaxyWorld? get current {
    final key = selected;
    if (key == null) return null;
    for (final world in widget.worlds) {
      if (world.kind == key) return world;
    }
    return null;
  }

  int _qualityFor(Size size) {
    if (!autoQuality) {
      switch (visualTier) {
        case GalaxyVisualTier.eco:
          return 0;
        case GalaxyVisualTier.balanced:
          return 1;
        case GalaxyVisualTier.cinematic:
          return 2;
      }
    }
    final shortest = math.min(size.width, size.height);
    if (shortest < 520) return 0;
    if (shortest < 980) return 1;
    return 1;
  }

  bool get _animate =>
      !paused && !lowMotion && (autoOrbit || visualTier != GalaxyVisualTier.eco);

  void _syncClock() {
    if (_animate) {
      if (!clock.isAnimating) clock.repeat();
    } else {
      clock.stop();
    }
  }

  void _select(GalaxyWorld world) {
    setState(() {
      selected = selected == world.kind ? null : world.kind;
      cameraMode = selected == null
          ? GalaxyCameraMode.free
          : GalaxyCameraMode.focus;
    });
  }

  void _next(int direction) {
    if (widget.worlds.isEmpty) return;
    final index = selected == null
        ? 0
        : widget.worlds.indexWhere((w) => w.kind == selected);
    final base = index < 0 ? 0 : index;
    setState(() {
      selected = widget.worlds[
        (base + direction + widget.worlds.length) % widget.worlds.length
      ].kind;
      cameraMode = GalaxyCameraMode.focus;
    });
  }

  void _visit() {
    final world = current;
    if (world != null) widget.onWorldTap?.call(world);
  }

  void _closeFocus() {
    setState(() {
      selected = null;
      cameraMode = GalaxyCameraMode.free;
    });
  }

  void _setZoom(double value) {
    setState(() => targetZoom = value.clamp(.72, 1.50).toDouble());
  }

  void _cycleQuality() {
    setState(() {
      autoQuality = false;
      visualTier = switch (visualTier) {
        GalaxyVisualTier.eco => GalaxyVisualTier.balanced,
        GalaxyVisualTier.balanced => GalaxyVisualTier.cinematic,
        GalaxyVisualTier.cinematic => GalaxyVisualTier.eco,
      };
    });
    _syncClock();
  }

  void _reset() {
    setState(() {
      selected = null;
      hovered = null;
      cameraMode = GalaxyCameraMode.free;
      visualTier = GalaxyVisualTier.balanced;
      orbit = 0;
      zoom = 1;
      targetZoom = 1;
      dragVelocity = 0;
      systemMap = false;
      labels = true;
      detail = true;
      grid = false;
      autoOrbit = true;
      lowMotion = false;
      autoQuality = true;
      controlsOpen = true;
      helpOpen = false;
      paused = false;
    });
    _syncClock();
  }

  void _toggleMotion() {
    setState(() => lowMotion = !lowMotion);
    _syncClock();
  }

  void _toggleAutoOrbit() {
    setState(() => autoOrbit = !autoOrbit);
    _syncClock();
  }

  void _togglePause() {
    setState(() => paused = !paused);
    _syncClock();
  }

  void _scrollZoom(PointerScrollEvent event) {
    final amount = event.scrollDelta.dy > 0 ? -.065 : .065;
    _setZoom(targetZoom + amount);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 780;
    final chosen = current;

    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextWorldIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousWorldIntent(),
        SingleActivator(LogicalKeyboardKey.space): TogglePauseIntent(),
        SingleActivator(LogicalKeyboardKey.keyM): ToggleMapIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): ToggleFocusIntent(),
        SingleActivator(LogicalKeyboardKey.keyL): ToggleLabelsIntent(),
        SingleActivator(LogicalKeyboardKey.keyQ): CycleQualityIntent(),
        SingleActivator(LogicalKeyboardKey.keyA): ToggleAutoQualityIntent(),
        SingleActivator(LogicalKeyboardKey.keyR): ResetViewIntent(),
        SingleActivator(LogicalKeyboardKey.equal, shift: true): IncreaseZoomIntent(),
        SingleActivator(LogicalKeyboardKey.minus): DecreaseZoomIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { _visit(); return null; }),
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) { _closeFocus(); return null; }),
        NextWorldIntent: CallbackAction<NextWorldIntent>(onInvoke: (_) { _next(1); return null; }),
        PreviousWorldIntent: CallbackAction<PreviousWorldIntent>(onInvoke: (_) { _next(-1); return null; }),
        TogglePauseIntent: CallbackAction<TogglePauseIntent>(onInvoke: (_) { _togglePause(); return null; }),
        ToggleMapIntent: CallbackAction<ToggleMapIntent>(onInvoke: (_) { setState(() => systemMap = !systemMap); return null; }),
        ToggleFocusIntent: CallbackAction<ToggleFocusIntent>(onInvoke: (_) { setState(() => cameraMode = cameraMode == GalaxyCameraMode.free ? GalaxyCameraMode.focus : GalaxyCameraMode.free); return null; }),
        ToggleLabelsIntent: CallbackAction<ToggleLabelsIntent>(onInvoke: (_) { setState(() => labels = !labels); return null; }),
        CycleQualityIntent: CallbackAction<CycleQualityIntent>(onInvoke: (_) { _cycleQuality(); return null; }),
        ToggleAutoQualityIntent: CallbackAction<ToggleAutoQualityIntent>(onInvoke: (_) { setState(() => autoQuality = !autoQuality); return null; }),
        ResetViewIntent: CallbackAction<ResetViewIntent>(onInvoke: (_) { _reset(); return null; }),
        IncreaseZoomIntent: CallbackAction<IncreaseZoomIntent>(onInvoke: (_) { _setZoom(targetZoom + .1); return null; }),
        DecreaseZoomIntent: CallbackAction<DecreaseZoomIntent>(onInvoke: (_) { _setZoom(targetZoom - .1); return null; }),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) _scrollZoom(event);
          },
          child: GestureDetector(
            onDoubleTap: _reset,
            onScaleStart: (_) => dragVelocity = 0,
            onScaleUpdate: (details) {
              setState(() {
                if (details.pointerCount > 1) {
                  targetZoom = (targetZoom * details.scale).clamp(.72, 1.50).toDouble();
                } else {
                  final dx = details.focalPointDelta.dx / math.max(260.0, size.width);
                  orbit += dx;
                  dragVelocity = dx;
                }
              });
            },
            child: AnimatedBuilder(
              animation: clock,
              builder: (_, __) {
                final phase = lowMotion || paused ? 0.0 : clock.value;
                zoom += (targetZoom - zoom) * .11;
                if (!lowMotion && !paused && dragVelocity.abs() > .0002) {
                  orbit += dragVelocity;
                  dragVelocity *= .90;
                }
                final quality = _qualityFor(size);
                final cinematic = quality == 2 && visualTier == GalaxyVisualTier.cinematic;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _DeepSpacePainter(
                          phase: phase,
                          quality: quality,
                          detail: detail,
                          grid: grid,
                          lowMotion: lowMotion,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: Transform.scale(
                        scale: zoom,
                        child: CustomPaint(
                          painter: _OrbitArchitecturePainter(
                            phase,
                            orbit,
                            systemMap,
                            detail,
                            quality,
                            grid,
                          ),
                        ),
                      ),
                    ),
                    _WorldOrbit(
                      worlds: widget.worlds,
                      phase: phase,
                      orbit: orbit,
                      selected: selected,
                      hovered: hovered,
                      labels: labels,
                      detail: detail,
                      cinematic: cinematic,
                      mapMode: systemMap,
                      compact: compact,
                      autoOrbit: autoOrbit && !lowMotion && !paused,
                      focusMode: cameraMode == GalaxyCameraMode.focus,
                      quality: quality,
                      onTap: _select,
                      onHover: (world) {
                        if (hovered != world?.kind) setState(() => hovered = world?.kind);
                      },
                    ),
                    _Header(
                      compact: compact,
                      systemMap: systemMap,
                      selected: chosen,
                      zoom: zoom,
                      cameraMode: cameraMode,
                      quality: quality,
                      autoQuality: autoQuality,
                      paused: paused,
                    ),
                    if (controlsOpen)
                      Positioned(
                        right: compact ? 10 : 26,
                        top: compact ? 70 : 26,
                        child: _Controls(
                          compact: compact,
                          map: systemMap,
                          labels: labels,
                          detail: detail,
                          grid: grid,
                          autoOrbit: autoOrbit,
                          lowMotion: lowMotion,
                          focus: cameraMode == GalaxyCameraMode.focus,
                          paused: paused,
                          autoQuality: autoQuality,
                          tier: visualTier,
                          onIn: () => _setZoom(targetZoom + .1),
                          onOut: () => _setZoom(targetZoom - .1),
                          onMap: () => setState(() => systemMap = !systemMap),
                          onLabels: () => setState(() => labels = !labels),
                          onDetail: () => setState(() => detail = !detail),
                          onGrid: () => setState(() => grid = !grid),
                          onAuto: _toggleAutoOrbit,
                          onMotion: _toggleMotion,
                          onFocus: () => setState(() => cameraMode = cameraMode == GalaxyCameraMode.free ? GalaxyCameraMode.focus : GalaxyCameraMode.free),
                          onQuality: _cycleQuality,
                          onAutoQuality: () => setState(() => autoQuality = !autoQuality),
                          onPause: _togglePause,
                          onHelp: () => setState(() => helpOpen = !helpOpen),
                          onReset: _reset,
                        ),
                      ),
                    Positioned(
                      right: compact ? 10 : 26,
                      top: compact ? 42 : 20,
                      child: _TinyToggle(
                        text: controlsOpen ? '−' : '+',
                        onTap: () => setState(() => controlsOpen = !controlsOpen),
                      ),
                    ),
                    Positioned(
                      left: compact ? 12 : 30,
                      top: compact ? 112 : 92,
                      child: _Telemetry(
                        phase: phase,
                        selected: chosen,
                        hovered: hovered,
                        map: systemMap,
                        zoom: zoom,
                        quality: quality,
                        autoQuality: autoQuality,
                        focus: cameraMode == GalaxyCameraMode.focus,
                        lowMotion: lowMotion,
                        paused: paused,
                        count: widget.worlds.length,
                      ),
                    ),
                    if (chosen != null)
                      _FloatingVisitPanel(
                        world: chosen,
                        compact: compact,
                        orbit: orbit,
                        mapMode: systemMap,
                        count: widget.worlds.length,
                        index: widget.worlds.indexOf(chosen),
                        onVisit: _visit,
                        onClose: _closeFocus,
                        onPrev: () => _next(-1),
                        onNext: () => _next(1),
                      )
                    else
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 22,
                        child: Center(child: _Hint()),
                      ),
                    if (helpOpen)
                      Positioned(
                        right: compact ? 10 : 26,
                        top: compact ? 135 : 102,
                        child: _HelpPanel(compact: compact),
                      ),
                    Positioned(
                      left: compact ? 12 : 30,
                      bottom: compact ? 55 : 34,
                      child: _Legend(quality: quality, mapMode: systemMap, lowMotion: lowMotion, paused: paused),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool compact, systemMap, autoQuality, paused;
  final GalaxyWorld? selected;
  final double zoom;
  final GalaxyCameraMode cameraMode;
  final int quality;

  const _Header({
    required this.compact,
    required this.systemMap,
    required this.selected,
    required this.zoom,
    required this.cameraMode,
    required this.quality,
    required this.autoQuality,
    required this.paused,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: compact ? 16 : 34,
      top: compact ? 16 : 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5)),
          const SizedBox(height: 7),
          Text(systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
          const SizedBox(height: 5),
          Text(
            selected == null ? 'WORLD NETWORK  •  ${autoQuality ? 'AUTO' : 'MANUAL'}' : 'FOCUS  •  ${selected!.title.toUpperCase()}',
            style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6),
          ),
          const SizedBox(height: 3),
          Text(
            '${cameraMode == GalaxyCameraMode.focus ? 'FOCUS' : 'FREE'}  •  VIEW ${(zoom * 100).round()}%  •  Q${quality + 1}${paused ? '  •  PAUSED' : ''}',
            style: const TextStyle(color: Colors.white12, fontSize: 5, letterSpacing: 1.25),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final bool compact, map, labels, detail, grid, autoOrbit, lowMotion, focus, paused, autoQuality;
  final GalaxyVisualTier tier;
  final VoidCallback onIn, onOut, onMap, onLabels, onDetail, onGrid, onAuto, onMotion, onFocus, onQuality, onAutoQuality, onPause, onHelp, onReset;

  const _Controls({
    required this.compact,
    required this.map,
    required this.labels,
    required this.detail,
    required this.grid,
    required this.autoOrbit,
    required this.lowMotion,
    required this.focus,
    required this.paused,
    required this.autoQuality,
    required this.tier,
    required this.onIn,
    required this.onOut,
    required this.onMap,
    required this.onLabels,
    required this.onDetail,
    required this.onGrid,
    required this.onAuto,
    required this.onMotion,
    required this.onFocus,
    required this.onQuality,
    required this.onAutoQuality,
    required this.onPause,
    required this.onHelp,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 170 : 310,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 4,
        runSpacing: 4,
        children: [
          _Btn('+', onIn),
          _Btn('−', onOut),
          _Btn(map ? 'ORBIT' : 'MAP', onMap),
          _Btn(labels ? 'LABELS' : 'CLEAN', onLabels),
          _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail),
          _Btn(grid ? 'GRID ON' : 'GRID', onGrid),
          _Btn(autoOrbit ? 'AUTO' : 'STILL', onAuto),
          _Btn(lowMotion ? 'MOTION OFF' : 'MOTION', onMotion),
          _Btn(focus ? 'FREE' : 'FOCUS', onFocus),
          _Btn(autoQuality ? 'AUTO Q' : tier.name.toUpperCase(), onAutoQuality),
          _Btn('Q+', onQuality),
          _Btn(paused ? 'PLAY' : 'PAUSE', onPause),
          _Btn('HELP', onHelp),
          _Btn('RESET', onReset),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Btn(this.text, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .62),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.05)),
        ),
      );
}

class _TinyToggle extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _TinyToggle({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .60), border: Border.all(color: Colors.white12)),
          child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
      );
}

class _Telemetry extends StatelessWidget {
  final double phase, zoom;
  final GalaxyWorld? selected;
  final GalaxyWorldKind? hovered;
  final bool map, autoQuality, focus, lowMotion, paused;
  final int quality, count;

  const _Telemetry({
    required this.phase,
    required this.selected,
    required this.hovered,
    required this.map,
    required this.zoom,
    required this.quality,
    required this.autoQuality,
    required this.focus,
    required this.lowMotion,
    required this.paused,
    required this.count,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text('AZ ${(phase * 360).round() % 360}°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}', style: const TextStyle(color: Colors.white12, fontSize: 6, letterSpacing: 1.1)),
          const SizedBox(height: 3),
          Text('${count.toString().padLeft(2, '0')} NODES  •  Q${quality + 1} ${autoQuality ? 'AUTO' : 'MANUAL'}  •  ${focus ? 'FOCUS' : 'FREE'}', style: const TextStyle(color: Colors.white10, fontSize: 5.5, letterSpacing: 1.05)),
          const SizedBox(height: 2),
          Text('${paused ? 'PAUSED' : lowMotion ? 'LOW MOTION' : 'LIVE'}  •  OLD-PC SAFE', style: const TextStyle(color: Colors.white10, fontSize: 5.2, letterSpacing: 1.0)),
        ],
      );
}

class _WorldOrbit extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final double phase, orbit;
  final GalaxyWorldKind? selected, hovered;
  final bool labels, detail, cinematic, mapMode, compact, autoOrbit, focusMode;
  final int quality;
  final ValueChanged<GalaxyWorld> onTap;
  final ValueChanged<GalaxyWorld?> onHover;

  const _WorldOrbit({
    required this.worlds,
    required this.phase,
    required this.orbit,
    required this.selected,
    required this.hovered,
    required this.labels,
    required this.detail,
    required this.cinematic,
    required this.mapMode,
    required this.compact,
    required this.autoOrbit,
    required this.focusMode,
    required this.quality,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(c.maxWidth, c.maxHeight),
                painter: _CentralSystemPainter(phase, orbit, detail, cinematic, quality, mapMode),
              ),
              for (var i = 0; i < worlds.length; i++)
                _WorldNode(
                  world: worlds[i],
                  index: i,
                  count: worlds.length,
                  phase: phase,
                  orbit: orbit,
                  selected: selected == worlds[i].kind,
                  hovered: hovered == worlds[i].kind,
                  labels: labels,
                  detail: detail,
                  cinematic: cinematic,
                  mapMode: mapMode,
                  compact: compact,
                  autoOrbit: autoOrbit,
                  focusMode: focusMode,
                  quality: quality,
                  onTap: () => onTap(worlds[i]),
                  onHover: (v) => onHover(v ? worlds[i] : null),
                ),
            ],
          );
        },
      );
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world;
  final int index, count;
  final double phase, orbit;
  final bool selected, hovered, labels, detail, cinematic, mapMode, compact, autoOrbit, focusMode;
  final int quality;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _WorldNode({
    required this.world,
    required this.index,
    required this.count,
    required this.phase,
    required this.orbit,
    required this.selected,
    required this.hovered,
    required this.labels,
    required this.detail,
    required this.cinematic,
    required this.mapMode,
    required this.compact,
    required this.autoOrbit,
    required this.focusMode,
    required this.quality,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) {
          final m = math.min(c.maxWidth, c.maxHeight);
          final base = index / math.max(1, count) * math.pi * 2;
          final angle = base + orbit * .88 + (autoOrbit ? phase * math.pi * 2 * .018 : 0);
          final rr = m * (compact ? .245 : .275);
          final x = c.maxWidth * .52 + math.cos(angle) * rr * (mapMode ? 1.72 : 1.58);
          final y = c.maxHeight * .52 + math.sin(angle) * rr * (mapMode ? .76 : .68);
          final depth = (math.sin(angle) + 1) / 2;
          final radius = m * (.040 + depth * .020 + (selected ? .018 : 0) + (hovered ? .009 : 0));
          final scale = focusMode && selected ? 1.10 : 1.0;
          final size = radius * 3.35 * scale;
          return Positioned(
            left: x - size / 2,
            top: y - size / 2,
            width: size,
            height: size,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => onHover(true),
              onExit: (_) => onHover(false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: CustomPaint(
                  painter: _NodePainter(
                    world.kind,
                    phase,
                    index,
                    selected,
                    hovered,
                    labels,
                    detail,
                    cinematic,
                    world.title,
                    quality,
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit;
  final bool detail, cinematic, mapMode;
  final int quality;

  _CentralSystemPainter(this.phase, this.orbit, this.detail, this.cinematic, this.quality, this.mapMode);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52);
    final m = math.min(s.width, s.height);
    final rings = quality == 0 ? 5 : cinematic ? 11 : 8;
    final p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < rings; i++) {
      final r = m * (.075 + i * .036);
      p.color = Colors.white.withValues(alpha: .010 + (i % 3) * .004);
      p.strokeWidth = i == 0 ? .65 : .32;
      c.drawOval(Rect.fromCenter(center: center, width: r * (mapMode ? 2.8 : 2.5), height: r * (mapMode ? .62 : .52)), p);
    }
    final glow = m * (cinematic ? .18 : .13);
    c.drawCircle(center, glow, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .20), const Color(0xFF76538F).withValues(alpha: .10), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: glow)));
    c.drawCircle(center, m * .045, Paint()..shader = RadialGradient(colors: [Colors.white54, const Color(0xFF72508A).withValues(alpha: .25), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: m * .045)));
    final markers = quality == 0 ? 5 : cinematic ? 16 : 9;
    for (var i = 0; i < markers; i++) {
      final a = phase * math.pi * 2 * .10 + orbit * .30 + i * math.pi * 2 / markers;
      final r = m * (.11 + (i % 5) * .018);
      c.drawCircle(Offset(center.dx + math.cos(a) * r * 1.35, center.dy + math.sin(a) * r * .46), .45, Paint()..color = Colors.white.withValues(alpha: .035));
    }
  }

  @override
  bool shouldRepaint(covariant _CentralSystemPainter old) => old.phase != phase || old.orbit != orbit || old.detail != detail || old.cinematic != cinematic || old.quality != quality || old.mapMode != mapMode;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit;
  final bool map, detail, grid;
  final int quality;

  _OrbitArchitecturePainter(this.phase, this.orbit, this.map, this.detail, this.quality, this.grid);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .52);
    final m = math.min(s.width, s.height);
    final p = Paint()..style = PaintingStyle.stroke;
    final count = quality == 0 ? 5 : map ? 10 : 8;
    for (var i = 0; i < count; i++) {
      final r = m * (.12 + i * .040);
      p.color = Colors.white.withValues(alpha: map ? .034 : .015 + (i % 3) * .003);
      p.strokeWidth = i == count ~/ 2 ? .72 : .30;
      c.drawOval(Rect.fromCenter(center: center, width: r * 2.45, height: r * .62), p);
    }
    if (detail && quality > 0) {
      for (var i = 0; i < (quality == 2 ? 5 : 3); i++) {
        final r = m * (.17 + i * .052);
        p.color = Colors.white.withValues(alpha: .008);
        p.strokeWidth = .28;
        c.drawOval(Rect.fromCenter(center: center, width: r * 2.8, height: r * .31), p);
      }
    }
    if (grid && quality > 0) {
      p.color = Colors.white.withValues(alpha: .012);
      p.strokeWidth = .35;
      for (var i = -4; i <= 4; i++) {
        final x = s.width * .5 + i * m * .15;
        c.drawLine(Offset(x, 0), Offset(x + m * .18, s.height), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitArchitecturePainter old) => old.phase != phase || old.orbit != orbit || old.map != map || old.detail != detail || old.quality != quality || old.grid != grid;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind;
  final double phase;
  final int index;
  final bool selected, hovered, labels, detail, cinematic;
  final String title;
  final int quality;

  _NodePainter(this.kind, this.phase, this.index, this.selected, this.hovered, this.labels, this.detail, this.cinematic, this.title, this.quality);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final r = s.width * .30;
    final rect = Rect.fromCircle(center: center, radius: r);
    final pulse = quality == 0 ? 1.0 : 1 + math.sin(phase * math.pi * 2 * 1.5 + index) * .018;
    c.drawCircle(center, r * (hovered ? 1.85 : 1.55) * pulse, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: selected ? .18 : hovered ? .11 : .045), Colors.transparent]).createShader(rect.inflate(r)));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(-.38, -.42), radius: 1.04, colors: [const Color(0xFFB5BFCA), _tone(kind), const Color(0xFF03040A)]).createShader(rect));
    c.drawCircle(center, r, Paint()..shader = RadialGradient(center: const Alignment(.70, .62), radius: .92, colors: [Colors.transparent, Colors.black.withValues(alpha: .72)]).createShader(rect));
    if (detail && quality > 0) {
      final loops = quality == 2 && cinematic ? 5 : 2;
      final surface = Paint()..style = PaintingStyle.stroke..strokeWidth = .42;
      for (var j = 0; j < loops; j++) {
        final rr = r * (.45 + j * .07);
        final path = Path();
        for (var k = 0; k <= 18; k++) {
          final a = k / 18 * math.pi * 2;
          final wave = math.sin(a * (2 + j % 2) + index) * r * .020;
          final point = Offset(center.dx + math.cos(a) * (rr + wave), center.dy + math.sin(a) * (rr + wave) * .60);
          if (k == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        surface.color = Colors.white.withValues(alpha: .035 - j * .004);
        c.drawPath(path, surface);
      }
    }
    if (selected) {
      c.drawCircle(center, r * 1.20, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1);
      c.drawArc(Rect.fromCircle(center: center, radius: r * 1.43), phase * math.pi * 2 * .55 + index, .85, false, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }
    if (labels) {
      final tp = TextPainter(
        text: TextSpan(text: title.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: selected ? .84 : hovered ? .68 : .40), fontSize: math.max(6, s.width * .024), letterSpacing: 1.15)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: s.width * 2.2);
      tp.paint(c, Offset(center.dx - tp.width / 2, center.dy + r * 1.36));
    }
  }

  @override
  bool shouldRepaint(covariant _NodePainter old) => old.kind != kind || old.phase != phase || old.index != index || old.selected != selected || old.hovered != hovered || old.labels != labels || old.detail != detail || old.cinematic != cinematic || old.title != title || old.quality != quality;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase;
  final int quality;
  final bool detail, grid, lowMotion;

  _DeepSpacePainter({required this.phase, required this.quality, required this.detail, required this.grid, required this.lowMotion});

  @override
  void paint(Canvas c, Size s) {
    final m = math.min(s.width, s.height);
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF010107));
    final center = Offset(s.width * .50, s.height * .49);
    c.drawCircle(center, m * .84, Paint()..shader = RadialGradient(colors: [const Color(0xFF342049).withValues(alpha: .18), const Color(0xFF17264D).withValues(alpha: .09), Colors.transparent], stops: const [0, .48, 1]).createShader(Rect.fromCircle(center: center, radius: m * .84)));

    // One continuous natural cosmic filament: irregular, asymmetrical and fading off-screen.
    final path = Path()..moveTo(-m * .20, s.height * .78);
    path.cubicTo(s.width * .01, s.height * .73, s.width * .07, s.height * .59, s.width * .19, s.height * .56);
    path.cubicTo(s.width * .30, s.height * .53, s.width * .27, s.height * .35, s.width * .39, s.height * .24);
    path.cubicTo(s.width * .48, s.height * .16, s.width * .54, s.height * .38, s.width * .63, s.height * .47);
    path.cubicTo(s.width * .71, s.height * .55, s.width * .77, s.height * .48, s.width * .84, s.height * .41);
    path.cubicTo(s.width * .92, s.height * .33, s.width * .99, s.height * .47, s.width * 1.08, s.height * .45);
    path.cubicTo(s.width * 1.17, s.height * .43, s.width * 1.23, s.height * .35, s.width * 1.30, s.height * .30);

    final outer = quality == 0 ? .075 : quality == 1 ? .11 : .15;
    c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * outer..color = const Color(0xFF526AA0).withValues(alpha: quality == 0 ? .014 : .022));
    if (quality > 0) {
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * (quality == 2 ? .070 : .050)..shader = LinearGradient(colors: [Colors.transparent, const Color(0xFF536E9E).withValues(alpha: .020), const Color(0xFF75538D).withValues(alpha: .085), const Color(0xFF536E9E).withValues(alpha: .035), Colors.transparent], stops: const [0, .18, .46, .70, 1]).createShader(Rect.fromLTWH(0, 0, s.width, s.height)));
    }
    if (quality == 2) {
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = m * .022..color = const Color(0xFF9A7AB0).withValues(alpha: .028));
    }

    if (quality > 0) {
      final dust = quality == 2 ? 30 : 14;
      for (var i = 0; i < dust; i++) {
        final t = (i + .61) / dust;
        final x = _curveX(t, s);
        final y = _curveY(t, s);
        final spread = m * (.025 + _noise(i + 7) * .085);
        final dx = (_noise(i * 2.7) - .5) * spread;
        final dy = (_noise(i * 4.2 + 2) - .5) * spread * .60;
        c.drawCircle(Offset(x + dx, y + dy), .55 + _noise(i * 3.1) * 1.25, Paint()..color = const Color(0xFF8D79A8).withValues(alpha: .006 + _noise(i * 5.1) * .013));
      }
    }

    final stars = quality == 0 ? 18 : quality == 1 ? 30 : 54;
    for (var i = 0; i < stars; i++) {
      final x = _noise(i * 2.13) * s.width;
      final y = _noise(i * 4.71 + 3) * s.height;
      final twinkle = lowMotion ? 1.0 : .78 + .22 * math.sin(phase * math.pi * 2 * (1 + i % 2) + i);
      final radius = quality == 0 ? .20 : .20 + (i % 3) * .11;
      c.drawCircle(Offset(x, y), radius, Paint()..color = Colors.white.withValues(alpha: (.012 + (i % 4) * .0025) * twinkle));
    }

    if (detail && quality == 2) {
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 8;
      for (var i = 0; i < 2; i++) {
        final rr = m * (.43 + i * .11);
        p.color = (i == 0 ? const Color(0xFF66467F) : const Color(0xFF3E5D8D)).withValues(alpha: .010);
        c.drawOval(Rect.fromCenter(center: center, width: rr * 2, height: rr * .34), p);
      }
    }
    if (grid && quality > 0) {
      final p = Paint()..color = Colors.white.withValues(alpha: .007)..style = PaintingStyle.stroke..strokeWidth = .35;
      for (var i = 0; i < 8; i++) {
        final x = s.width * i / 7;
        final y = s.height * i / 7;
        c.drawLine(Offset(x, 0), Offset(x, s.height), p);
        c.drawLine(Offset(0, y), Offset(s.width, y), p);
      }
    }
    c.drawRect(Offset.zero & s, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .48)]).createShader(Rect.fromLTWH(-m * .2, -m * .2, s.width + m * .4, s.height + m * .4)));
  }

  double _noise(double x) => (math.sin(x * 12.9898) * 43758.5453).abs() % 1.0;
  double _curveX(double t, Size s) {
    final u = t * 4;
    if (u < 1) return _lerp(-s.width * .20, s.width * .19, u);
    if (u < 2) return _lerp(s.width * .19, s.width * .39, u - 1);
    if (u < 3) return _lerp(s.width * .39, s.width * .84, u - 2);
    return _lerp(s.width * .84, s.width * 1.30, u - 3);
  }
  double _curveY(double t, Size s) {
    final u = t * 4;
    if (u < 1) return _lerp(s.height * .78, s.height * .56, u);
    if (u < 2) return _lerp(s.height * .56, s.height * .24, u - 1);
    if (u < 3) return _lerp(s.height * .24, s.height * .41, u - 2);
    return _lerp(s.height * .41, s.height * .30, u - 3);
  }
  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _DeepSpacePainter old) => old.phase != phase || old.quality != quality || old.detail != detail || old.grid != grid || old.lowMotion != lowMotion;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world;
  final bool compact, mapMode;
  final double orbit;
  final int count, index;
  final VoidCallback onVisit, onClose, onPrev, onNext;

  const _FloatingVisitPanel({required this.world, required this.compact, required this.orbit, required this.mapMode, required this.count, required this.index, required this.onVisit, required this.onClose, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final width = compact ? 230.0 : 292.0;
    return LayoutBuilder(builder: (_, c) {
      final m = math.min(c.maxWidth, c.maxHeight);
      final a = index / math.max(1, count) * math.pi * 2 + orbit * .88;
      final rr = m * (compact ? .245 : .275);
      final x = c.maxWidth * .52 + math.cos(a) * rr * (mapMode ? 1.72 : 1.58);
      final y = c.maxHeight * .52 + math.sin(a) * rr * (mapMode ? .76 : .68);
      final left = (x + 42).clamp(10.0, math.max(10.0, c.maxWidth - width - 10));
      final top = (y - 54).clamp(compact ? 150.0 : 108.0, math.max(150.0, c.maxHeight - 168));
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xE8080910),
              border: Border.all(color: Colors.white12),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 28)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Expanded(child: Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(3), child: Text('×', style: TextStyle(color: Colors.white38, fontSize: 15))))]),
                const SizedBox(height: 7),
                Text(world.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1.35)),
                const SizedBox(height: 11),
                Row(children: [Expanded(child: InkWell(onTap: onVisit, child: Container(padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center, color: Colors.white10, child: const Text('VISIT PLANET  →', style: TextStyle(color: Colors.white, fontSize: 7, letterSpacing: 1.5)))), const SizedBox(width: 6), _MiniBtn('‹', onPrev), const SizedBox(width: 4), _MiniBtn('›', onNext)]),
                const SizedBox(height: 8),
                Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}  •  PREV / CURRENT / NEXT', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.0)),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MiniBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _MiniBtn(this.text, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: Colors.white12)), child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))));
}

class _HelpPanel extends StatelessWidget {
  final bool compact;
  const _HelpPanel({required this.compact});

  @override
  Widget build(BuildContext context) => Container(
        width: compact ? 230 : 300,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xE6080910), border: Border.all(color: Colors.white12)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GALAXY CONTROLS', style: TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1.5)),
            SizedBox(height: 9),
            Text('DRAG             ORBIT', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('WHEEL / + −      ZOOM', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('← →              WORLD', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('ENTER             VISIT', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('SPACE             PAUSE', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('M / F / L         MAP / FOCUS / LABELS', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('Q / A              QUALITY / AUTO', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
            Text('R                 RESET', style: TextStyle(color: Colors.white38, fontSize: 6, letterSpacing: 1.1)),
          ],
        ),
      );
}

class _Legend extends StatelessWidget {
  final int quality;
  final bool mapMode, lowMotion, paused;
  const _Legend({required this.quality, required this.mapMode, required this.lowMotion, required this.paused});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white38)),
        const SizedBox(width: 7),
        Text(mapMode ? 'MAP / STRUCTURE' : 'ORBIT / WORLD NODES', style: const TextStyle(color: Colors.white18, fontSize: 5.5, letterSpacing: 1.2)),
        const SizedBox(width: 14),
        Text('Q${quality + 1}', style: const TextStyle(color: Colors.white12, fontSize: 5.5, letterSpacing: 1.2)),
        if (lowMotion) const Padding(padding: EdgeInsets.only(left: 12), child: Text('LOW MOTION', style: TextStyle(color: Colors.white12, fontSize: 5.5, letterSpacing: 1.1))),
        if (paused) const Padding(padding: EdgeInsets.only(left: 12), child: Text('PAUSED', style: TextStyle(color: Colors.white12, fontSize: 5.5, letterSpacing: 1.1))),
      ]);
}

class _Hint extends StatelessWidget {
  const _Hint();
  @override
  Widget build(BuildContext context) => const Text('DRAG • ORBIT    WHEEL / + − • ZOOM    ← → • WORLD    ENTER • VISIT    SPACE • PAUSE    R • RESET', style: TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.15));
}

class NextWorldIntent extends Intent { const NextWorldIntent(); }
class PreviousWorldIntent extends Intent { const PreviousWorldIntent(); }
class TogglePauseIntent extends Intent { const TogglePauseIntent(); }
class ToggleMapIntent extends Intent { const ToggleMapIntent(); }
class ToggleFocusIntent extends Intent { const ToggleFocusIntent(); }
class ToggleLabelsIntent extends Intent { const ToggleLabelsIntent(); }
class CycleQualityIntent extends Intent { const CycleQualityIntent(); }
class ToggleAutoQualityIntent extends Intent { const ToggleAutoQualityIntent(); }
class ResetViewIntent extends Intent { const ResetViewIntent(); }
class IncreaseZoomIntent extends Intent { const IncreaseZoomIntent(); }
class DecreaseZoomIntent extends Intent { const DecreaseZoomIntent(); }

Color _tone(GalaxyWorldKind kind) {
  switch (kind) {
    case GalaxyWorldKind.vegeta:
      return const Color(0xFF4C536B);
    case GalaxyWorldKind.game:
      return const Color(0xFF425B66);
    case GalaxyWorldKind.identity:
      return const Color(0xFF554A66);
    case GalaxyWorldKind.cinema:
      return const Color(0xFF614F62);
    case GalaxyWorldKind.creation:
      return const Color(0xFF50635F);
    case GalaxyWorldKind.music:
      return const Color(0xFF5D4D67);
    case GalaxyWorldKind.family:
      return const Color(0xFF5D6254);
    case GalaxyWorldKind.archive:
      return const Color(0xFF5B5960);
    case GalaxyWorldKind.comingSoon:
      return const Color(0xFF4D5560);
  }
}
