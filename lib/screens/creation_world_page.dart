import 'dart:math' as math;
import 'package:flutter/material.dart';

class CreationWorldPage extends StatefulWidget {
  const CreationWorldPage({super.key});

  @override
  State<CreationWorldPage> createState() => _CreationWorldPageState();
}

class _CreationWorldPageState extends State<CreationWorldPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 52),
  )..repeat();

  int selectedTool = 0;
  double zoom = 1;
  double atmosphere = .72;
  double moisture = .58;
  double lightAngle = .35;
  int seed = 31;

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _nextSeed() => setState(() => seed = seed >= 99 ? 1 : seed + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _CreationSpacePainter(
                    _clock.value,
                    selectedTool,
                  ),
                ),
                Center(
                  child: Transform.scale(
                    scale: zoom,
                    child: SizedBox(
                      width: math.min(constraints.maxWidth * .72, 820),
                      height: math.min(constraints.maxHeight * .78, 820),
                      child: CustomPaint(
                        painter: _CreationPlanetPainter(
                          phase: _clock.value,
                          seed: seed,
                          mode: selectedTool,
                          atmosphere: atmosphere,
                          moisture: moisture,
                          lightAngle: lightAngle,
                        ),
                      ),
                    ),
                  ),
                ),
                _CreationAtmosphere(compact: compact),
                _TopBar(compact: compact, seed: seed, onSeed: _nextSeed),
                if (!compact)
                  Positioned(
                    left: 22,
                    top: 94,
                    bottom: 94,
                    width: 194,
                    child: _CreationPanel(
                      title: 'WORLD BUILDER',
                      children: [
                        _ToolButton('TERRAIN', Icons.terrain, selectedTool == 0, () => setState(() => selectedTool = 0)),
                        _ToolButton('BIOMES', Icons.blur_on, selectedTool == 1, () => setState(() => selectedTool = 1)),
                        _ToolButton('CLIMATE', Icons.cloud_outlined, selectedTool == 2, () => setState(() => selectedTool = 2)),
                        _ToolButton('LIGHTING', Icons.wb_sunny_outlined, selectedTool == 3, () => setState(() => selectedTool = 3)),
                        const SizedBox(height: 14),
                        _SliderMetric('ATMOSPHERE', atmosphere, (v) => setState(() => atmosphere = v)),
                        _SliderMetric('MOISTURE', moisture, (v) => setState(() => moisture = v)),
                        _SliderMetric('LIGHT VECTOR', lightAngle, (v) => setState(() => lightAngle = v)),
                        const Spacer(),
                        _Metric('SURFACE', selectedTool == 0 ? 'TERRAIN' : selectedTool == 1 ? 'BIOME' : selectedTool == 2 ? 'CLIMATE' : 'LIGHT'),
                        _Metric('RENDER', 'CINEMATIC'),
                        _Metric('STATE', 'LIVE'),
                      ],
                    ),
                  ),
                if (!compact)
                  Positioned(
                    right: 22,
                    top: 94,
                    bottom: 94,
                    width: 194,
                    child: _CreationPanel(
                      title: 'WORLD DATA',
                      children: [
                        _DataRow('SEED', 'DARK-${seed.toString().padLeft(3, '0')}'),
                        const _DataRow('TYPE', 'CREATION'),
                        const _DataRow('SCALE', '1.00 PLANET'),
                        _DataRow('DETAIL', selectedTool == 0 ? 'HIGH' : 'ULTRA'),
                        _DataRow('FOG', '${(atmosphere * 100).round()}%'),
                        _DataRow('CLIMATE', '${(moisture * 100).round()}%'),
                        const Spacer(),
                        _PlanetTelemetry(seed: seed, phase: _clock.value),
                      ],
                    ),
                  ),
                Positioned(
                  left: compact ? 12 : 220,
                  right: compact ? 12 : 220,
                  bottom: compact ? 12 : 22,
                  child: _BottomConsole(
                    compact: compact,
                    zoom: zoom,
                    mode: selectedTool,
                    onZoomOut: () => setState(() => zoom = math.max(.82, zoom - .05)),
                    onZoomIn: () => setState(() => zoom = math.min(1.18, zoom + .05)),
                    onReset: () => setState(() {
                      zoom = 1;
                      atmosphere = .72;
                      moisture = .58;
                      lightAngle = .35;
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CreationAtmosphere extends StatelessWidget {
  final bool compact;
  const _CreationAtmosphere({required this.compact});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(.02, -.05),
                  radius: .84,
                  colors: [
                    const Color(0x151B1730),
                    const Color(0x08070B18),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x70000000),
                    const Color(0x00000000),
                    const Color(0xA6000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 12 : 24,
            top: compact ? 62 : 72,
            child: const _MicroLabel('CREATION / PLANETARY LAB / LIVE'),
          ),
        ]),
      );
}

class _TopBar extends StatelessWidget {
  final bool compact;
  final int seed;
  final VoidCallback onSeed;
  const _TopBar({required this.compact, required this.seed, required this.onSeed});

  @override
  Widget build(BuildContext context) => Positioned(
        left: compact ? 12 : 22,
        right: compact ? 12 : 22,
        top: 12,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xE8070810),
            border: Border.all(color: const Color(0x387F70B0)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
          ),
          child: Row(children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, size: 14),
              color: const Color(0xAAFFFFFF),
            ),
            const SizedBox(width: 4),
            const Text('CREATION-WORLD', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white)),
            const SizedBox(width: 12),
            if (!compact) const Text('PLANETARY CONSTRUCTION / LIVE PREVIEW', style: TextStyle(fontSize: 5.5, letterSpacing: 1.3, color: Color(0x557F8AA2))),
            const Spacer(),
            Text('DARK-${seed.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x667F8AA2))),
            const SizedBox(width: 8),
            InkWell(onTap: onSeed, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: const Color(0x12151A2D), border: Border.all(color: const Color(0x287F70B0))), child: const Text('NEW SEED', style: TextStyle(fontSize: 5, letterSpacing: 1.1, color: Color(0xAABFC0CB))))),
            const SizedBox(width: 10),
          ]),
        ),
      );
}

class _CreationPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _CreationPanel({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xE8080911),
          border: Border.all(color: const Color(0x307F70B0)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 32)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 6, letterSpacing: 1.8, color: Color(0xAAB6AEC8))),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x1C7F70B0)),
          const SizedBox(height: 10),
          ...children,
        ]),
      );
}

class _ToolButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToolButton(this.label, this.icon, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0x1B1A1630) : const Color(0x07000000),
              border: Border.all(color: active ? const Color(0x607F70B0) : const Color(0x147F70B0)),
            ),
            child: Row(children: [
              Icon(icon, size: 12, color: active ? const Color(0xD8FFFFFF) : const Color(0x667F8AA2)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: active ? Colors.white : const Color(0x667F8AA2))),
            ]),
          ),
        ),
      );
}

class _SliderMetric extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderMetric(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1, color: Color(0x557F8AA2)))),
            Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 4.5, color: Color(0x99FFFFFF))),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 1, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3), overlayShape: const RoundSliderOverlayShape(overlayRadius: 8), activeTrackColor: const Color(0x667F70B0), inactiveTrackColor: const Color(0x147F70B0), thumbColor: const Color(0xCCBFC0CB)),
            child: Slider(value: value, onChanged: onChanged, min: 0, max: 1),
          ),
        ]),
      );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1, color: Color(0x557F8AA2)))),
          Text(value, style: const TextStyle(fontSize: 5, letterSpacing: .8, color: Color(0x99FFFFFF))),
        ]),
      );
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1, color: Color(0x557F8AA2)))),
          Text(value, style: const TextStyle(fontSize: 5, letterSpacing: .7, color: Color(0xAABFC0CB))),
        ]),
      );
}

class _PlanetTelemetry extends StatelessWidget {
  final int seed;
  final double phase;
  const _PlanetTelemetry({required this.seed, required this.phase});

  @override
  Widget build(BuildContext context) => Container(
        height: 128,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x247F70B0)),
          gradient: const RadialGradient(colors: [Color(0x251F1A35), Color(0x08000000)]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PLANET TELEMETRY', style: TextStyle(fontSize: 4.5, letterSpacing: 1.2, color: Color(0x557F8AA2))),
          const Spacer(),
          _TelemetryRow('ROTATION', '${((phase * 360 + seed) % 360).round()}°'),
          _TelemetryRow('TERRAIN', '07 PLATES'),
          _TelemetryRow('ORBIT', 'STABLE'),
          _TelemetryRow('VOLUME', '100%'),
        ]),
      );
}

class _TelemetryRow extends StatelessWidget {
  final String label;
  final String value;
  const _TelemetryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 4, letterSpacing: .8, color: Color(0x447F8AA2)))),
          Text(value, style: const TextStyle(fontSize: 4.5, color: Color(0x88FFFFFF))),
        ]),
      );
}

class _BottomConsole extends StatelessWidget {
  final bool compact;
  final double zoom;
  final int mode;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onReset;
  const _BottomConsole({required this.compact, required this.zoom, required this.mode, required this.onZoomOut, required this.onZoomIn, required this.onReset});

  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 48 : 54,
        decoration: BoxDecoration(
          color: const Color(0xE8080911),
          border: Border.all(color: const Color(0x327F70B0)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 28)],
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          const _StatusDot(),
          const SizedBox(width: 8),
          Text(mode == 0 ? 'TERRAIN LIVE' : mode == 1 ? 'BIOME LIVE' : mode == 2 ? 'CLIMATE LIVE' : 'LIGHT LIVE', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.4, color: Color(0xAABFC0CB))),
          const SizedBox(width: 14),
          const _ConsoleValue('ATMOSPHERE', 'ACTIVE'),
          const _ConsoleValue('SURFACE', 'HIGH'),
          if (!compact) const _ConsoleValue('RENDER', 'CINEMATIC'),
          const Spacer(),
          IconButton(onPressed: onZoomOut, icon: const Icon(Icons.remove, size: 13), color: const Color(0x88FFFFFF)),
          Text('${(zoom * 100).round()}%', style: const TextStyle(fontSize: 5.5, color: Color(0x88FFFFFF))),
          IconButton(onPressed: onZoomIn, icon: const Icon(Icons.add, size: 13), color: const Color(0x88FFFFFF)),
          TextButton(onPressed: onReset, child: const Text('RESET', style: TextStyle(fontSize: 5.5, letterSpacing: 1))),
          const SizedBox(width: 7),
        ]),
      );
}

class _ConsoleValue extends StatelessWidget {
  final String label;
  final String value;
  const _ConsoleValue(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 4, letterSpacing: 1, color: Color(0x447F8AA2))),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 5.5, letterSpacing: .7, color: Color(0x99FFFFFF))),
        ]),
      );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();
  @override
  Widget build(BuildContext context) => Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x997F70B0), boxShadow: [BoxShadow(color: Color(0x447F70B0), blurRadius: 8)]));
}

class _MicroLabel extends StatelessWidget {
  final String text;
  const _MicroLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x667F8AA2)));
}

class _CreationSpacePainter extends CustomPainter {
  final double phase;
  final int mode;
  _CreationSpacePainter(this.phase, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(center: Alignment(0, 0), radius: 1.2, colors: [Color(0xFF11101D), Color(0xFF04050C), Color(0xFF010207)]).createShader(Offset.zero & size));
    final random = math.Random(31031);
    for (var i = 0; i < 560; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final twinkle = .6 + .4 * math.sin(phase * 16 + i * .71);
      canvas.drawCircle(p, .18 + random.nextDouble() * .72, Paint()..color = Colors.white.withValues(alpha: (.018 + random.nextDouble() * .09) * twinkle));
    }
    final c = size.center(Offset.zero);
    final haze = Paint()..shader = RadialGradient(center: const Alignment(.02, -.05), radius: .78, colors: [const Color(0x207F70B0), const Color(0x081B1730), Colors.transparent]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, haze);
    final sweep = Paint()..color = Color.lerp(const Color(0x167F70B0), const Color(0x205C718E), mode / 3)!
      ..style = PaintingStyle.stroke..strokeWidth = .8;
    final rect = Rect.fromCenter(center: Offset(c.dx, c.dy + 20), width: size.width * .72, height: size.height * .40);
    canvas.drawArc(rect, phase * math.pi * 2, math.pi * .48, false, sweep);
  }

  @override
  bool shouldRepaint(covariant _CreationSpacePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.mode != mode;
}

class _CreationPlanetPainter extends CustomPainter {
  final double phase;
  final int seed;
  final int mode;
  final double atmosphere;
  final double moisture;
  final double lightAngle;
  _CreationPlanetPainter({required this.phase, required this.seed, required this.mode, required this.atmosphere, required this.moisture, required this.lightAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .305;
    final random = math.Random(seed * 7919 + mode * 97);
    final light = Offset(math.cos(lightAngle * math.pi * 2 - .8), math.sin(lightAngle * math.pi * 2 - .8));

    final halo = Paint()..shader = RadialGradient(colors: [const Color(0x467F70B0).withValues(alpha: .15 + atmosphere * .16), const Color(0x101C1730), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.72));
    canvas.drawCircle(center, radius * 1.72, halo);

    final sphere = Paint()..shader = RadialGradient(center: Alignment(light.dx * .55, light.dy * .55), radius: 1.02, colors: [const Color(0xFFB7B1BF), const Color(0xFF716C7D), const Color(0xFF373442), const Color(0xFF070810)], stops: const [.0, .30, .64, 1]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sphere);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * .997)));
    _drawTerrain(canvas, center, radius, random);
    _drawClimate(canvas, center, radius, random);
    _drawLatitude(canvas, center, radius);
    _drawNight(canvas, center, radius, light);
    canvas.restore();

    _drawAtmosphericRim(canvas, center, radius, atmosphere, light);
    _drawOrbitalHardware(canvas, center, radius, phase);
  }

  void _drawTerrain(Canvas canvas, Offset center, double radius, math.Random random) {
    final land = mode == 1 ? const Color(0xB0A9B39E) : const Color(0xA7B0AAA8);
    final shadow = const Color(0x66433F4C);
    final water = Color.lerp(const Color(0x7A596B7B), const Color(0x6E71808A), moisture)!;
    final features = <(double, double, double, double)>[];
    for (var i = 0; i < 12; i++) {
      features.add((random.nextDouble() * 1.45 - .72, random.nextDouble() * 1.35 - .67, .10 + random.nextDouble() * .27, .06 + random.nextDouble() * .15));
    }
    for (var i = 0; i < features.length; i++) {
      final f = features[i];
      final p = center + Offset(f.$1 * radius, f.$2 * radius);
      final rect = Rect.fromCenter(center: p, width: radius * f.$3, height: radius * f.$4);
      final paint = Paint()..color = i % 4 == 0 ? water.withValues(alpha: .75) : i.isEven ? land : shadow;
      canvas.drawOval(rect, paint);
      if (i % 3 == 0) {
        canvas.drawOval(rect.deflate(rect.width * .12), Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x286F7380));
      }
    }
    if (mode == 0) {
      for (var i = 0; i < 18; i++) {
        final a = random.nextDouble() * math.pi * 2;
        final rr = radius * (.18 + random.nextDouble() * .68);
        final p = center + Offset(math.cos(a) * rr, math.sin(a) * rr * .72);
        canvas.drawCircle(p, .8 + random.nextDouble() * 2.2, Paint()..color = const Color(0x384F4C59));
      }
    }
  }

  void _drawClimate(Canvas canvas, Offset center, double radius, math.Random random) {
    if (mode != 1 && mode != 2) return;
    for (var i = 0; i < 8; i++) {
      final y = center.dy + (i - 3.5) * radius * .17;
      final width = radius * (.75 + random.nextDouble() * .65);
      final cloud = Rect.fromCenter(center: Offset(center.dx + (random.nextDouble() - .5) * radius * .45, y), width: width, height: radius * (.045 + random.nextDouble() * .055));
      canvas.drawOval(cloud, Paint()..color = Colors.white.withValues(alpha: mode == 2 ? .10 : .06));
    }
  }

  void _drawLatitude(Canvas canvas, Offset center, double radius) {
    final line = Paint()..color = const Color(0x257F8AA2)..style = PaintingStyle.stroke..strokeWidth = .65;
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * radius * .22;
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.86, height: radius * .20), line);
    }
  }

  void _drawNight(Canvas canvas, Offset center, double radius, Offset light) {
    final shade = Paint()..shader = RadialGradient(center: Alignment(light.dx, light.dy), radius: 1.0, colors: [Colors.transparent, Colors.transparent, const Color(0xE6000000)], stops: const [.36, .64, 1]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shade);
  }

  void _drawAtmosphericRim(Canvas canvas, Offset center, double radius, double strength, Offset light) {
    canvas.drawCircle(center, radius * 1.008, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .032..color = const Color(0x8B9BA4B7).withValues(alpha: .14 + strength * .20));
    canvas.drawCircle(center, radius * 1.028, Paint()..style = PaintingStyle.stroke..strokeWidth = radius * .012..color = Color.lerp(const Color(0x405A6780), const Color(0x8C9D90B5), strength)!);
    final rim = Paint()..shader = SweepGradient(transform: GradientRotation(math.atan2(light.dy, light.dx)), colors: [Colors.transparent, const Color(0x809E9AB8).withValues(alpha: .22 + strength * .22), Colors.transparent, Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.03));
    canvas.drawCircle(center, radius * 1.03, rim);
  }

  void _drawOrbitalHardware(Canvas canvas, Offset center, double radius, double phase) {
    final orbit = Paint()..style = PaintingStyle.stroke..strokeWidth = .85..color = const Color(0x267F70B0);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2.5, height: radius * .55), orbit);
    final a = phase * math.pi * 2;
    final p = Offset(center.dx + math.cos(a) * radius * 1.25, center.dy + math.sin(a) * radius * .275);
    canvas.drawCircle(p, 2.3, Paint()..color = const Color(0x997F70B0));
    canvas.drawCircle(p, 5.5, Paint()..shader = RadialGradient(colors: [const Color(0x447F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: p, radius: 5.5)));
  }

  @override
  bool shouldRepaint(covariant _CreationPlanetPainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.seed != seed || oldDelegate.mode != mode || oldDelegate.atmosphere != atmosphere || oldDelegate.moisture != moisture || oldDelegate.lightAngle != lightAngle;
}
