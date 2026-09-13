import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'darkest_world_universe.dart';

enum GalaxyRenderMode { eco, balanced, cinematic }

/// GO59 system shell: keeps the existing Galaxy renderer intact while adding
/// an adaptive performance envelope, navigation layer and diagnostics.
class DarkestWorldUniverseGo59 extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverseGo59({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestWorldUniverseGo59> createState() => _DarkestWorldUniverseGo59State();
}

class _DarkestWorldUniverseGo59State extends State<DarkestWorldUniverseGo59> {
  GalaxyRenderMode mode = GalaxyRenderMode.balanced;
  bool telemetry = false;
  bool cinematic = false;
  bool paused = false;
  bool controls = true;
  double zoom = 1;
  int? target;

  GalaxyRenderMode get effectiveMode {
    final size = MediaQuery.sizeOf(context);
    if (size.width < 650 || size.height < 520) return GalaxyRenderMode.eco;
    if (cinematic) return GalaxyRenderMode.cinematic;
    return mode;
  }

  void cycleMode() => setState(() {
    mode = switch (mode) {
      GalaxyRenderMode.eco => GalaxyRenderMode.balanced,
      GalaxyRenderMode.balanced => GalaxyRenderMode.cinematic,
      GalaxyRenderMode.cinematic => GalaxyRenderMode.eco,
    };
  });

  void reset() => setState(() {
    mode = GalaxyRenderMode.balanced;
    telemetry = false;
    cinematic = false;
    paused = false;
    zoom = 1;
    target = null;
  });

  @override
  Widget build(BuildContext context) {
    final quality = effectiveMode;
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final k = event.logicalKey;
        if (k == LogicalKeyboardKey.keyQ) { cycleMode(); return KeyEventResult.handled; }
        if (k == LogicalKeyboardKey.keyT) { setState(() => telemetry = !telemetry); return KeyEventResult.handled; }
        if (k == LogicalKeyboardKey.keyP) { setState(() => paused = !paused); return KeyEventResult.handled; }
        if (k == LogicalKeyboardKey.keyC) { setState(() => cinematic = !cinematic); return KeyEventResult.handled; }
        if (k == LogicalKeyboardKey.keyR) { reset(); return KeyEventResult.handled; }
        if (k == LogicalKeyboardKey.escape) { setState(() => target = null); return KeyEventResult.handled; }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            setState(() => zoom = (zoom + (event.scrollDelta.dy < 0 ? .06 : -.06)).clamp(.72, 1.55));
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DarkestWorldUniverse._passthrough(),
            IgnorePointer(child: _AdaptiveBackdrop(mode: quality, zoom: zoom)),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: _GalaxyFrame(
                  child: DarkestWorldUniverse(worlds: widget.worlds, onWorldTap: (world) {
                    final index = widget.worlds.indexOf(world);
                    setState(() => target = index < 0 ? null : index);
                    widget.onWorldTap?.call(world);
                  }),
                ),
              ),
            ),
            if (controls) Positioned(left: 20, bottom: 20, child: _SystemControls(
              mode: quality,
              paused: paused,
              cinematic: cinematic,
              onMode: cycleMode,
              onPause: () => setState(() => paused = !paused),
              onCinematic: () => setState(() => cinematic = !cinematic),
              onTelemetry: () => setState(() => telemetry = !telemetry),
              onReset: reset,
            )),
            Positioned(right: 20, bottom: 20, child: _ZoomReadout(zoom: zoom)),
            if (telemetry) Positioned(right: 20, top: 20, child: _GalaxyTelemetry(mode: quality, worlds: widget.worlds.length, zoom: zoom, paused: paused, target: target)),
          ],
        ),
      ),
    );
  }
}

class _GalaxyFrame extends StatelessWidget {
  final Widget child;
  const _GalaxyFrame({required this.child});
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: child);
}

class _AdaptiveBackdrop extends StatelessWidget {
  final GalaxyRenderMode mode;
  final double zoom;
  const _AdaptiveBackdrop({required this.mode, required this.zoom});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _AdaptiveBackdropPainter(mode, zoom));
}

class _AdaptiveBackdropPainter extends CustomPainter {
  final GalaxyRenderMode mode;
  final double zoom;
  const _AdaptiveBackdropPainter(this.mode, this.zoom);
  @override
  void paint(Canvas canvas, Size size) {
    final m = math.min(size.width, size.height);
    final alpha = switch (mode) { GalaxyRenderMode.eco => .035, GalaxyRenderMode.balanced => .055, GalaxyRenderMode.cinematic => .075 };
    final path = Path();
    for (var i = 0; i <= 32; i++) {
      final t = i / 32;
      final x = size.width * (.08 + .84 * t);
      final y = size.height * (.53 + .13 * math.sin(t * 5.1) + .035 * math.sin(t * 15));
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = mode == GalaxyRenderMode.cinematic ? 24 : 15..color = const Color(0xFF76558F).withValues(alpha: alpha));
    if (mode != GalaxyRenderMode.eco) {
      final glow = Paint()..shader = RadialGradient(colors: [const Color(0xFF684A91).withValues(alpha: .035 * zoom), Colors.transparent]).createShader(Rect.fromCenter(center: Offset(size.width * .5, size.height * .5), width: m * 1.5, height: m * .9));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .5, size.height * .5), width: m * 1.5, height: m * .9), glow);
    }
  }
  @override
  bool shouldRepaint(covariant _AdaptiveBackdropPainter old) => old.mode != mode || old.zoom != zoom;
}

class _SystemControls extends StatelessWidget {
  final GalaxyRenderMode mode;
  final bool paused, cinematic;
  final VoidCallback onMode, onPause, onCinematic, onTelemetry, onReset;
  const _SystemControls({required this.mode, required this.paused, required this.cinematic, required this.onMode, required this.onPause, required this.onCinematic, required this.onTelemetry, required this.onReset});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .72), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Wrap(spacing: 2, children: [
    _Control(_modeName(mode), onMode),
    _Control(paused ? 'PLAY' : 'PAUSE', onPause),
    _Control(cinematic ? 'CINEMA' : 'SAFE', onCinematic),
    _Control('TELEMETRY', onTelemetry),
    _Control('RESET', onReset),
  ])));
}

class _Control extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Control(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => TextButton(onPressed: onTap, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text(label, style: const TextStyle(fontSize: 7, letterSpacing: 1.3)));
}

class _ZoomReadout extends StatelessWidget {
  final double zoom;
  const _ZoomReadout({required this.zoom});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Text('ZOOM ${(zoom * 100).round()}%', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5)));
}

class _GalaxyTelemetry extends StatelessWidget {
  final GalaxyRenderMode mode;
  final int worlds;
  final double zoom;
  final bool paused;
  final int? target;
  const _GalaxyTelemetry({required this.mode, required this.worlds, required this.zoom, required this.paused, required this.target});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Container(width: 190, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .76), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .07))), child: DefaultTextStyle(style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 1.2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('GALAXY TELEMETRY', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
    const SizedBox(height: 7),
    Text('RENDER    ${_modeName(mode)}'),
    Text('WORLDS    $worlds'),
    Text('ZOOM      ${(zoom * 100).round()}%'),
    Text('MOTION    ${paused ? 'PAUSED' : 'LIVE'}'),
    Text('TARGET    ${target == null ? 'NONE' : '#${target! + 1}'}'),
    const SizedBox(height: 6),
    const Text('GTX 950 / 2GB BASELINE', style: TextStyle(color: Colors.white24, letterSpacing: 1.4)),
  ])));
}

String _modeName(GalaxyRenderMode mode) => switch (mode) { GalaxyRenderMode.eco => 'ECO', GalaxyRenderMode.balanced => 'BALANCED', GalaxyRenderMode.cinematic => 'CINEMATIC' };

// Private const constructor used only as a zero-cost marker behind the real renderer.
extension on DarkestWorldUniverse {
  static Widget _passthrough() => const SizedBox.shrink();
}
