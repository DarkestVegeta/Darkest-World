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
    duration: const Duration(seconds: 88),
  )..repeat();

  GalaxyWorldKind? selected;
  GalaxyWorldKind? hovered;

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
  bool focusMode = false;
  bool autoQuality = true;

  GalaxyVisualTier visualTier = GalaxyVisualTier.balanced;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      if (!lowMotion && !clock.isAnimating) clock.repeat();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      clock.stop();
    }
  }

  GalaxyWorld? get current {
    if (selected == null) return null;
    for (final world in widget.worlds) {
      if (world.kind == selected) return world;
    }
    return null;
  }

  int _qualityFor(Size size) {
    if (autoQuality) {
      final shortest = math.min(size.width, size.height);
      if (shortest < 520) return 0;
      if (shortest < 900) return 1;
    }
    switch (visualTier) {
      case GalaxyVisualTier.eco:
        return 0;
      case GalaxyVisualTier.balanced:
        return 1;
      case GalaxyVisualTier.cinematic:
        return 2;
    }
  }

  bool get _wantsAnimation =>
      !lowMotion && (autoOrbit || visualTier != GalaxyVisualTier.eco);

  void _syncClock() {
    if (_wantsAnimation) {
      if (!clock.isAnimating) clock.repeat();
    } else {
      clock.stop();
    }
  }

  void visit() {
    final world = current;
    if (world != null) widget.onWorldTap?.call(world);
  }

  void select(GalaxyWorld world) {
    setState(() {
      selected = selected == world.kind ? null : world.kind;
      focusMode = selected != null;
    });
  }

  void next(int direction) {
    if (widget.worlds.isEmpty) return;
    final currentIndex = selected == null
        ? 0
        : widget.worlds.indexWhere((world) => world.kind == selected);
    final base = currentIndex < 0 ? 0 : currentIndex;
    setState(() {
      selected = widget.worlds[
        (base + direction + widget.worlds.length) % widget.worlds.length
      ].kind;
      focusMode = true;
    });
  }

  void setZoom(double value) {
    setState(() {
      targetZoom = value.clamp(.70, 1.55).toDouble();
    });
  }

  void closeFocus() {
    setState(() {
      selected = null;
      focusMode = false;
    });
  }

  void resetView() {
    setState(() {
      orbit = 0;
      zoom = 1;
      targetZoom = 1;
      dragVelocity = 0;
      selected = null;
      hovered = null;
      systemMap = false;
      labels = true;
      detail = true;
      grid = false;
      autoOrbit = true;
      lowMotion = false;
      focusMode = false;
      autoQuality = true;
      visualTier = GalaxyVisualTier.balanced;
    });
    _syncClock();
  }

  void toggleLowMotion() {
    setState(() => lowMotion = !lowMotion);
    _syncClock();
  }

  void toggleAutoOrbit() {
    setState(() => autoOrbit = !autoOrbit);
    _syncClock();
  }

  void cycleQuality() {
    setState(() {
      autoQuality = false;
      visualTier = switch (visualTier) {
        GalaxyVisualTier.eco => GalaxyVisualTier.balanced,
        GalaxyVisualTier.balanced => GalaxyVisualTier.cinematic,
        GalaxyVisualTier.cinematic => GalaxyVisualTier.eco,
      };
    });
  }

  void _scrollZoom(PointerScrollEvent event) {
    final amount = event.scrollDelta.dy > 0 ? -.07 : .07;
    setZoom(targetZoom + amount);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final chosen = current;

    return FocusableActionDetector(
      autofocus: true,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.space): ToggleMapIntent(),
        SingleActivator(LogicalKeyboardKey.keyM): ToggleMapIntent(),
        SingleActivator(LogicalKeyboardKey.equal, shift: true):
            IncreaseZoomIntent(),
        SingleActivator(LogicalKeyboardKey.minus): DecreaseZoomIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): ToggleFocusIntent(),
        SingleActivator(LogicalKeyboardKey.keyL): ToggleLabelsIntent(),
        SingleActivator(LogicalKeyboardKey.keyQ): CycleQualityIntent(),
        SingleActivator(LogicalKeyboardKey.keyA): ToggleAutoQualityIntent(),
        SingleActivator(LogicalKeyboardKey.keyR): ResetViewIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            visit();
            return null;
          },
        ),
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) {
            closeFocus();
            return null;
          },
        ),
        NextFocusIntent: CallbackAction<NextFocusIntent>(
          onInvoke: (_) {
            next(1);
            return null;
          },
        ),
        PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: (_) {
            next(-1);
            return null;
          },
        ),
        ToggleMapIntent: CallbackAction<ToggleMapIntent>(
          onInvoke: (_) {
            setState(() => systemMap = !systemMap);
            return null;
          },
        ),
        IncreaseZoomIntent: CallbackAction<IncreaseZoomIntent>(
          onInvoke: (_) {
            setZoom(targetZoom + .1);
            return null;
          },
        ),
        DecreaseZoomIntent: CallbackAction<DecreaseZoomIntent>(
          onInvoke: (_) {
            setZoom(targetZoom - .1);
            return null;
          },
        ),
        ToggleFocusIntent: CallbackAction<ToggleFocusIntent>(
          onInvoke: (_) {
            setState(() => focusMode = !focusMode);
            return null;
          },
        ),
        ToggleLabelsIntent: CallbackAction<ToggleLabelsIntent>(
          onInvoke: (_) {
            setState(() => labels = !labels);
            return null;
          },
        ),
        CycleQualityIntent: CallbackAction<CycleQualityIntent>(
          onInvoke: (_) {
            cycleQuality();
            return null;
          },
        ),
        ToggleAutoQualityIntent: CallbackAction<ToggleAutoQualityIntent>(
          onInvoke: (_) {
            setState(() => autoQuality = !autoQuality);
            return null;
          },
        ),
        ResetViewIntent: CallbackAction<ResetViewIntent>(
          onInvoke: (_) {
            resetView();
            return null;
          },
        ),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) _scrollZoom(event);
          },
          child: GestureDetector(
            onDoubleTap: resetView,
            onScaleStart: (_) => dragVelocity = 0,
            onScaleUpdate: (details) {
              setState(() {
                if (details.pointerCount > 1) {
                  targetZoom = (targetZoom * details.scale)
                      .clamp(.70, 1.55)
                      .toDouble();
                } else {
                  final dx = details.focalPointDelta.dx /
                      math.max(240.0, size.width);
                  orbit += dx;
                  dragVelocity = dx;
                }
              });
            },
            child: AnimatedBuilder(
              animation: clock,
              builder: (_, __) {
                final phase = lowMotion ? 0.0 : clock.value;
                zoom += (targetZoom - zoom) * .10;

                if (!lowMotion && dragVelocity.abs() > .0002) {
                  orbit += dragVelocity;
                  dragVelocity *= .90;
                }

                final quality = _qualityFor(size);
                final effectiveCinematic =
                    quality >= 2 && visualTier == GalaxyVisualTier.cinematic;
                final modeLabel = autoQuality
                    ? 'AUTO'
                    : visualTier.name.toUpperCase();

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _DeepSpacePainter(
                          phase: phase,
                          detail: detail,
                          grid: grid,
                          lowMotion: lowMotion,
                          quality: quality,
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
                      cinematic: effectiveCinematic,
                      mapMode: systemMap,
                      compact: compact,
                      autoOrbit: autoOrbit && !lowMotion,
                      focusMode: focusMode,
                      quality: quality,
                      onTap: select,
                      onHover: (world) {
                        if (hovered != world?.kind) {
                          setState(() => hovered = world?.kind);
                        }
                      },
                    ),
                    _Header(
                      systemMap: systemMap,
                      compact: compact,
                      modeLabel: modeLabel,
                      selected: chosen,
                      zoom: zoom,
                      focusMode: focusMode,
                      lowMotion: lowMotion,
                    ),
                    Positioned(
                      right: compact ? 10 : 26,
                      top: compact ? 70 : 26,
                      child: _Controls(
                        map: systemMap,
                        labels: labels,
                        detail: detail,
                        grid: grid,
                        autoOrbit: autoOrbit,
                        lowMotion: lowMotion,
                        focus: focusMode,
                        autoQuality: autoQuality,
                        tier: visualTier,
                        onIn: () => setZoom(targetZoom + .1),
                        onOut: () => setZoom(targetZoom - .1),
                        onMap: () =>
                            setState(() => systemMap = !systemMap),
                        onLabels: () => setState(() => labels = !labels),
                        onDetail: () => setState(() => detail = !detail),
                        onGrid: () => setState(() => grid = !grid),
                        onAuto: toggleAutoOrbit,
                        onMotion: toggleLowMotion,
                        onFocus: () =>
                            setState(() => focusMode = !focusMode),
                        onQuality: cycleQuality,
                        onAutoQuality: () =>
                            setState(() => autoQuality = !autoQuality),
                        onReset: resetView,
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
                        tier: visualTier,
                        autoQuality: autoQuality,
                        focus: focusMode,
                        lowMotion: lowMotion,
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
                        onVisit: visit,
                        onClose: closeFocus,
                        onPrev: () => next(-1),
                        onNext: () => next(1),
                      )
                    else
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 22,
                        child: Center(child: _Hint()),
                      ),
                    Positioned(
                      left: compact ? 12 : 30,
                      bottom: compact ? 55 : 34,
                      child: _Legend(
                        quality: quality,
                        mapMode: systemMap,
                        lowMotion: lowMotion,
                      ),
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
  final bool systemMap, compact, focusMode, lowMotion;
  final String modeLabel;
  final GalaxyWorld? selected;
  final double zoom;

  const _Header({
    required this.systemMap,
    required this.compact,
    required this.modeLabel,
    required this.selected,
    required this.zoom,
    required this.focusMode,
    required this.lowMotion,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: compact ? 16 : 34,
      top: compact ? 16 : 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DARKESTWORLD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            systemMap ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 7,
              letterSpacing: 2.6,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            selected == null
                ? 'WORLD NETWORK  •  ${modeLabel.toUpperCase()}'
                : 'FOCUS  •  ${selected!.title.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 6,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${focusMode ? 'FOCUS CAMERA' : 'FREE CAMERA'}  •  VIEW ${(zoom * 100).round()}%  •  ${lowMotion ? 'STATIC' : 'LIVE'}',
            style: const TextStyle(
              color: Colors.white12,
              fontSize: 5,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final bool map, labels, detail, grid, autoOrbit, lowMotion, focus, autoQuality;
  final GalaxyVisualTier tier;
  final VoidCallback onIn,
      onOut,
      onMap,
      onLabels,
      onDetail,
      onGrid,
      onAuto,
      onMotion,
      onFocus,
      onQuality,
      onAutoQuality,
      onReset;

  const _Controls({
    required this.map,
    required this.labels,
    required this.detail,
    required this.grid,
    required this.autoOrbit,
    required this.lowMotion,
    required this.focus,
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
    required this.onReset,
  });

  String get qualityLabel =>
      autoQuality ? 'AUTO' : tier.name.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _Btn('+', onIn),
        _Btn('−', onOut),
        _Btn(map ? 'ORBIT' : 'MAP', onMap),
        _Btn(labels ? 'LABELS' : 'CLEAN', onLabels),
        _Btn(detail ? 'DETAIL' : 'MINIMAL', onDetail),
        _Btn('Q: $qualityLabel', onQuality),
        _Btn(autoQuality ? 'AUTO Q ON' : 'AUTO Q OFF', onAutoQuality),
        _Btn(grid ? 'GRID ON' : 'GRID', onGrid),
        _Btn(autoOrbit ? 'AUTO' : 'STILL', onAuto),
        _Btn(lowMotion ? 'MOTION OFF' : 'MOTION', onMotion),
        _Btn(focus ? 'FREE' : 'FOCUS', onFocus),
        _Btn('RESET', onReset),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _Btn(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .62),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 6,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _Telemetry extends StatelessWidget {
  final double phase, zoom;
  final GalaxyWorld? selected;
  final GalaxyWorldKind? hovered;
  final bool map, focus, lowMotion, autoQuality;
  final int quality, count;
  final GalaxyVisualTier tier;

  const _Telemetry({
    required this.phase,
    required this.selected,
    required this.hovered,
    required this.map,
    required this.zoom,
    required this.quality,
    required this.tier,
    required this.autoQuality,
    required this.count,
    required this.focus,
    required this.lowMotion,
  });

  @override
  Widget build(BuildContext context) {
    final qualityName = autoQuality ? 'AUTO' : tier.name.toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${map ? 'SYSTEM MAP' : 'DEEP ORBIT'}  •  ${selected?.title.toUpperCase() ?? 'SCANNING'}',
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 7,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'AZ ${(phase * 360).round() % 360}°  •  Z ${(zoom * 100).round()}%  •  ${hovered == null ? 'NO TARGET' : 'TARGET LOCK'}',
          style: const TextStyle(
            color: Colors.white12,
            fontSize: 6,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${count.toString().padLeft(2, '0')} NODES  •  $qualityName  •  LEVEL $quality  •  ${focus ? 'FOCUS' : 'FREE'}  •  ${lowMotion ? 'STATIC' : 'LIVE'}',
          style: const TextStyle(
            color: Colors.white10,
            fontSize: 5.5,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CentralSystemPainter(
                phase,
                orbit,
                detail,
                cinematic,
                quality,
              ),
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
                onHover: (value) => onHover(value ? worlds[i] : null),
              ),
          ],
        );
      },
    );
  }
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world;
  final int index, count;
  final double phase, orbit;
  final bool selected,
      hovered,
      labels,
      detail,
      cinematic,
      mapMode,
      compact,
      autoOrbit,
      focusMode;
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final minSize =
            math.min(constraints.maxWidth, constraints.maxHeight);
        final base = index / math.max(1, count) * math.pi * 2;
        final angle = base +
            orbit * .9 +
            (autoOrbit ? phase * math.pi * 2 * .018 : 0);
        final radius = minSize *
            (mapMode
                ? (compact ? .285 : .315)
                : (compact ? .255 : .285));
        final focusScale = focusMode && selected ? 1.10 : 1.0;
        final x = constraints.maxWidth * .52 +
            math.cos(angle) * radius * (mapMode ? 1.70 : 1.62);
        final y = constraints.maxHeight * .52 +
            math.sin(angle) * radius * (mapMode ? .66 : .72);
        final depth = (math.sin(angle) + 1) / 2;
        final planetRadius = minSize *
            (.039 +
                depth * .022 +
                (selected ? .018 : 0) +
                (hovered ? .010 : 0)) *
            focusScale;
        final size = planetRadius * 3.45;

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
}

class _CentralSystemPainter extends CustomPainter {
  final double phase, orbit;
  final bool detail, cinematic;
  final int quality;

  _CentralSystemPainter(
    this.phase,
    this.orbit,
    this.detail,
    this.cinematic,
    this.quality,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, size.height * .52);
    final minSize = math.min(size.width, size.height);
    final stroke = Paint()..style = PaintingStyle.stroke;

    final rings = quality == 0
        ? 4
        : quality == 1
            ? 8
            : cinematic
                ? 12
                : 9;

    for (var i = 0; i < rings; i++) {
      final radius = minSize * (.075 + i * .035);
      stroke
        ..color = Colors.white.withValues(
          alpha: .009 + (i % 4) * .003,
        )
        ..strokeWidth = i % 6 == 0 ? .8 : .32;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.55,
          height: radius * (.25 + (i % 6) * .035) * 2,
        ),
        stroke,
      );
    }

    final glow = minSize * (quality == 0 ? .13 : cinematic ? .19 : .15);
    canvas.drawCircle(
      center,
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: .17),
            const Color(0xFF76538F).withValues(alpha: .09),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: glow),
        ),
    );

    canvas.drawCircle(
      center,
      minSize * .045,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white54,
            const Color(0xFF72508A).withValues(alpha: .55),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: minSize * .045,
          ),
        ),
    );

    final markers = quality == 0
        ? 4
        : quality == 1
            ? 9
            : 16;

    for (var i = 0; i < markers; i++) {
      final angle = phase *
              math.pi *
              2 *
              (.12 + (i % 5) * .018) +
          orbit * .45 +
          i * math.pi * 2 / markers;
      final radius = minSize * (.11 + (i % 7) * .018);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius * 1.35,
          center.dy + math.sin(angle) * radius * .46,
        ),
        .34 + (i % 2) * .18,
        Paint()
          ..color = Colors.white.withValues(
            alpha: .024 + (i % 3) * .006,
          ),
      );
    }

    if (detail && quality >= 1) {
      final line = Paint()
        ..color = Colors.white.withValues(alpha: .014)
        ..strokeWidth = .65;
      final lineCount = quality == 2 ? 5 : 2;
      for (var i = 0; i < lineCount; i++) {
        final angle = phase * 3.2 + i * math.pi / 5;
        final radius = minSize * (.07 + i * .015);
        canvas.drawLine(
          center,
          Offset(
            center.dx + math.cos(angle) * radius,
            center.dy + math.sin(angle) * radius * .58,
          ),
          line,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CentralSystemPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.orbit != orbit ||
      oldDelegate.detail != detail ||
      oldDelegate.cinematic != cinematic ||
      oldDelegate.quality != quality;
}

class _OrbitArchitecturePainter extends CustomPainter {
  final double phase, orbit;
  final bool map, detail, grid;
  final int quality;

  _OrbitArchitecturePainter(
    this.phase,
    this.orbit,
    this.map,
    this.detail,
    this.quality,
    this.grid,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, size.height * .52);
    final minSize = math.min(size.width, size.height);
    final paint = Paint()..style = PaintingStyle.stroke;

    final count = quality == 0 ? (map ? 6 : 5) : (map ? 10 : 8);

    for (var i = 0; i < count; i++) {
      final radius = minSize * (.12 + i * .035);
      final wobble =
          1 + math.sin(phase * math.pi * 2 + i) * .0015;
      paint
        ..color = Colors.white.withValues(
          alpha: map ? .028 : .012 + (i % 3) * .002,
        )
        ..strokeWidth = i == 5 ? .75 : .30;

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.4 * wobble,
          height: radius * (.31 + (i % 5) * .065) * 2,
        ),
        paint,
      );
    }

    if (detail && quality >= 1) {
      for (var i = 0; i < (quality == 2 ? 5 : 2); i++) {
        final radius = minSize * (.15 + i * .045);
        paint
          ..color = Colors.white.withValues(
            alpha: map ? .014 : .008,
          )
          ..strokeWidth = .28;
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: radius * 2.7,
            height: radius * .28,
          ),
          paint,
        );
      }
    }

    if (grid && quality >= 1) {
      paint
        ..color = Colors.white.withValues(alpha: .008)
        ..strokeWidth = .35;
      for (var i = -4; i <= 4; i++) {
        final x = size.width * .5 + i * minSize * .12;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x + minSize * .22, size.height),
          paint,
        );
        final y = size.height * .5 + i * minSize * .08;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y - minSize * .12),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitArchitecturePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.orbit != orbit ||
      oldDelegate.map != map ||
      oldDelegate.detail != detail ||
      oldDelegate.quality != quality ||
      oldDelegate.grid != grid;
}

class _NodePainter extends CustomPainter {
  final GalaxyWorldKind kind;
  final double phase;
  final int index;
  final bool selected, hovered, labels, detail, cinematic;
  final String title;
  final int quality;

  _NodePainter(
    this.kind,
    this.phase,
    this.index,
    this.selected,
    this.hovered,
    this.labels,
    this.detail,
    this.cinematic,
    this.title,
    this.quality,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .30;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final pulse =
        1 + math.sin(phase * math.pi * 2 * 1.35 + index) * .016;

    if (quality >= 1 || selected || hovered) {
      canvas.drawCircle(
        center,
        radius * (hovered ? 1.85 : 1.52) * pulse,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(
                alpha: selected
                    ? .16
                    : hovered
                        ? .10
                        : .035,
              ),
              Colors.transparent,
            ],
          ).createShader(rect.inflate(radius)),
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.38, -.42),
          radius: 1.04,
          colors: [
            const Color(0xFFB5BFCA),
            _tone(kind),
            const Color(0xFF03040A),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(.70, .62),
          radius: .92,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: .70),
          ],
        ).createShader(rect),
    );

    if (detail && quality >= 1) {
      final surface = Paint()..style = PaintingStyle.stroke;
      final loops = quality == 2 ? 5 : 2;
      for (var j = 0; j < loops; j++) {
        final loopRadius = radius * (.45 + j * .075);
        final path = Path();
        final steps = quality == 2 ? 20 : 12;
        for (var k = 0; k <= steps; k++) {
          final angle = k / steps * math.pi * 2;
          final wave = math.sin(
                angle * (2 + j % 3) + index * .8,
              ) *
              radius *
              .018;
          final point = Offset(
            center.dx + math.cos(angle) * (loopRadius + wave),
            center.dy +
                math.sin(angle) * (loopRadius + wave) * .60,
          );
          if (k == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        surface
          ..color = Colors.white.withValues(
            alpha: .032 - j * .003,
          )
          ..strokeWidth = .42;
        canvas.drawPath(path, surface);
      }
    }

    if (selected) {
      canvas.drawCircle(
        center,
        radius * 1.22,
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = .9,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius * 1.46,
        ),
        phase * math.pi * 2 * .55 + index,
        .9,
        false,
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    if (labels) {
      final text = TextPainter(
        text: TextSpan(
          text: title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: selected
                  ? .82
                  : hovered
                      ? .68
                      : .38,
            ),
            fontSize: math.max(6, size.width * .025),
            letterSpacing: 1.15,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 2.2);
      text.paint(
        canvas,
        Offset(
          center.dx - text.width / 2,
          center.dy + radius * 1.36,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodePainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.phase != phase ||
      oldDelegate.index != index ||
      oldDelegate.selected != selected ||
      oldDelegate.hovered != hovered ||
      oldDelegate.labels != labels ||
      oldDelegate.detail != detail ||
      oldDelegate.cinematic != cinematic ||
      oldDelegate.title != title ||
      oldDelegate.quality != quality;
}

class _DeepSpacePainter extends CustomPainter {
  final double phase;
  final bool detail, grid, lowMotion;
  final int quality;

  _DeepSpacePainter({
    required this.phase,
    required this.detail,
    required this.grid,
    required this.lowMotion,
    required this.quality,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minSize = math.min(size.width, size.height);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF010107),
    );

    final center = Offset(size.width * .50, size.height * .49);

    canvas.drawCircle(
      center,
      minSize * .84,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.05, -.08),
          radius: 1,
          colors: [
            const Color(0xFF342049).withValues(
              alpha: quality == 0 ? .10 : .18,
            ),
            const Color(0xFF17264D).withValues(
              alpha: quality == 0 ? .06 : .09,
            ),
            const Color(0xFF090A18).withValues(alpha: .025),
            Colors.transparent,
          ],
          stops: const [0, .38, .68, 1],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: minSize * .84,
          ),
        ),
    );

    _drawSingleFilament(canvas, size, minSize);

    final starCount = switch (quality) {
      0 => 18,
      1 => 34,
      _ => 56,
    };

    for (var i = 0; i < starCount; i++) {
      final x = _noise(i * 2.13) * size.width;
      final y = _noise(i * 4.71 + 3) * size.height;
      final twinkle = lowMotion
          ? .78
          : .70 +
              .30 *
                  math.sin(
                    phase * math.pi * 2 * (1 + i % 2) + i,
                  );
      final radius = .20 + (i % 3) * .11;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withValues(
            alpha: (.012 + (i % 5) * .0025) * twinkle,
          ),
      );
    }

    if (detail && quality >= 1) {
      final band = Paint()..style = PaintingStyle.stroke;
      final bandCount = quality == 2 ? 3 : 1;
      for (var i = 0; i < bandCount; i++) {
        final radius = minSize * (.43 + i * .11);
        band
          ..color = (i.isEven
                  ? const Color(0xFF66467F)
                  : const Color(0xFF3E5D8D))
              .withValues(alpha: .009)
          ..strokeWidth = 7 + i * 3;
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * .34,
          ),
          band,
        );
      }
    }

    if (grid && quality >= 1) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: .007)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .35;
      final lines = quality == 2 ? 9 : 5;
      for (var i = 0; i < lines; i++) {
        final x = size.width * i / (lines - 1);
        final y = size.height * i / (lines - 1);
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          gridPaint,
        );
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: .44),
          ],
        ).createShader(
          Rect.fromLTWH(
            -minSize * .2,
            -minSize * .2,
            size.width + minSize * .4,
            size.height + minSize * .4,
          ),
        ),
    );
  }

  void _drawSingleFilament(
    Canvas canvas,
    Size size,
    double minSize,
  ) {
    final path = Path()
      ..moveTo(-minSize * .20, size.height * .76)
      ..cubicTo(
        size.width * .01,
        size.height * .73,
        size.width * .04,
        size.height * .59,
        size.width * .17,
        size.height * .56,
      )
      ..cubicTo(
        size.width * .29,
        size.height * .53,
        size.width * .26,
        size.height * .35,
        size.width * .39,
        size.height * .24,
      )
      ..cubicTo(
        size.width * .49,
        size.height * .16,
        size.width * .53,
        size.height * .39,
        size.width * .61,
        size.height * .47,
      )
      ..cubicTo(
        size.width * .69,
        size.height * .55,
        size.width * .76,
        size.height * .49,
        size.width * .83,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .91,
        size.height * .35,
        size.width * .96,
        size.height * .48,
        size.width * 1.08,
        size.height * .45,
      )
      ..cubicTo(
        size.width * 1.18,
        size.height * .43,
        size.width * 1.22,
        size.height * .35,
        size.width * 1.30,
        size.height * .31,
      );

    final outerWidth = switch (quality) {
      0 => .075,
      1 => .11,
      _ => .145,
    };

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = minSize * outerWidth
        ..color = const Color(0xFF526AA0).withValues(
          alpha: quality == 0 ? .012 : .022,
        ),
    );

    if (quality >= 1) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = minSize * (quality == 2 ? .070 : .050)
          ..shader = const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0x22536E9E),
              Color(0x5575538D),
              Color(0x22536E9E),
              Colors.transparent,
            ],
            stops: [0, .18, .45, .68, 1],
          ).createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
      );
    }

    if (quality == 2) {
      const dustCount = 18;
      for (var i = 0; i < dustCount; i++) {
        final t = (i + .41) / dustCount;
        final x = _curveX(t, size);
        final y = _curveY(t, size);
        final spread =
            minSize * (.025 + _noise(i + 8) * .065);
        final dx = (_noise(i * 2.3) - .5) * spread;
        final dy = (_noise(i * 4.1 + 2) - .5) * spread * .62;
        canvas.drawCircle(
          Offset(x + dx, y + dy),
          .55 + _noise(i * 3.7) * 1.1,
          Paint()
            ..color = const Color(0xFF8D79A8).withValues(
              alpha: .006 + _noise(i * 5.2) * .012,
            ),
        );
      }
    }
  }

  double _noise(double value) =>
      (math.sin(value * 12.9898) * 43758.5453).abs() % 1.0;

  double _curveX(double t, Size size) {
    final u = t * 4;
    if (u < 1) {
      return _lerp(-size.width * .20, size.width * .17, u);
    }
    if (u < 2) {
      return _lerp(size.width * .17, size.width * .39, u - 1);
    }
    if (u < 3) {
      return _lerp(size.width * .39, size.width * .83, u - 2);
    }
    return _lerp(size.width * .83, size.width * 1.30, u - 3);
  }

  double _curveY(double t, Size size) {
    final u = t * 4;
    if (u < 1) {
      return _lerp(size.height * .76, size.height * .56, u);
    }
    if (u < 2) {
      return _lerp(size.height * .56, size.height * .24, u - 1);
    }
    if (u < 3) {
      return _lerp(size.height * .24, size.height * .43, u - 2);
    }
    return _lerp(size.height * .43, size.height * .31, u - 3);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.detail != detail ||
      oldDelegate.grid != grid ||
      oldDelegate.lowMotion != lowMotion ||
      oldDelegate.quality != quality;
}

class _FloatingVisitPanel extends StatelessWidget {
  final GalaxyWorld world;
  final bool compact, mapMode;
  final double orbit;
  final int count, index;
  final VoidCallback onVisit, onClose, onPrev, onNext;

  const _FloatingVisitPanel({
    required this.world,
    required this.compact,
    required this.orbit,
    required this.mapMode,
    required this.count,
    required this.index,
    required this.onVisit,
    required this.onClose,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final width = compact ? 238.0 : 300.0;
    return LayoutBuilder(
      builder: (_, constraints) {
        final minSize =
            math.min(constraints.maxWidth, constraints.maxHeight);
        final angle =
            index / math.max(1, count) * math.pi * 2 + orbit * .9;
        final radius = minSize *
            (mapMode
                ? (compact ? .285 : .315)
                : (compact ? .255 : .285));
        final x = constraints.maxWidth * .52 +
            math.cos(angle) * radius * (mapMode ? 1.70 : 1.62);
        final y = constraints.maxHeight * .52 +
            math.sin(angle) * radius * (mapMode ? .66 : .72);
        final left = (x + 46).clamp(
          12.0,
          constraints.maxWidth - width - 12,
        );
        final top = (y - 58).clamp(
          compact ? 150.0 : 110.0,
          constraints.maxHeight - 170.0,
        );

        return Positioned(
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          world.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onClose,
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            '×',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    world.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onVisit,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 9),
                            alignment: Alignment.center,
                            color: Colors.white10,
                            child: const Text(
                              'VISIT PLANET  →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _MiniBtn('‹', onPrev),
                      const SizedBox(width: 4),
                      _MiniBtn('›', onNext),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}  •  PREV / CURRENT / NEXT',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 5.5,
                      letterSpacing: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _MiniBtn(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final int quality;
  final bool mapMode, lowMotion;

  const _Legend({
    required this.quality,
    required this.mapMode,
    required this.lowMotion,
  });

  @override
  Widget build(BuildContext context) {
    final mode = switch (quality) {
      0 => 'ECO',
      1 => 'BALANCED',
      _ => 'CINEMATIC',
    };
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white38,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          mapMode ? 'MAP / STRUCTURE' : 'ORBIT / WORLD NODES',
          style: const TextStyle(
            color: Colors.white18,
            fontSize: 5.5,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          mode,
          style: const TextStyle(
            color: Colors.white12,
            fontSize: 5.5,
            letterSpacing: 1.25,
          ),
        ),
        if (lowMotion)
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'LOW MOTION',
              style: TextStyle(
                color: Colors.white12,
                fontSize: 5.5,
                letterSpacing: 1.25,
              ),
            ),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'DRAG • ORBIT    WHEEL / PINCH / + − • ZOOM    ← → • WORLD    ENTER • VISIT    ESC • CLOSE    M • MAP    F • FOCUS    Q • QUALITY    A • AUTO QUALITY    R • RESET',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white24,
        fontSize: 7,
        letterSpacing: 1.15,
      ),
    );
  }
}

class IncreaseZoomIntent extends Intent {
  const IncreaseZoomIntent();
}

class DecreaseZoomIntent extends Intent {
  const DecreaseZoomIntent();
}

class ToggleMapIntent extends Intent {
  const ToggleMapIntent();
}

class ToggleFocusIntent extends Intent {
  const ToggleFocusIntent();
}

class ToggleLabelsIntent extends Intent {
  const ToggleLabelsIntent();
}

class CycleQualityIntent extends Intent {
  const CycleQualityIntent();
}

class ToggleAutoQualityIntent extends Intent {
  const ToggleAutoQualityIntent();
}

class ResetViewIntent extends Intent {
  const ResetViewIntent();
}

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
