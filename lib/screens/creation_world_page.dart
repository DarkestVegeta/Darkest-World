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
    duration: const Duration(seconds: 48),
  )..repeat();

  int selectedTool = 0;
  double zoom = 1;

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02030A),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 820;
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _CreationSpacePainter(_clock.value)),
                Center(
                  child: Transform.scale(
                    scale: zoom,
                    child: SizedBox(
                      width: math.min(constraints.maxWidth * .72, 780),
                      height: math.min(constraints.maxHeight * .76, 780),
                      child: CustomPaint(
                        painter: _CreationPlanetPainter(_clock.value),
                      ),
                    ),
                  ),
                ),
                _CreationAtmosphere(compact: compact),
                _TopBar(compact: compact),
                if (!compact)
                  Positioned(
                    left: 22,
                    top: 94,
                    bottom: 94,
                    width: 184,
                    child: _CreationPanel(
                      title: 'WORLD BUILDER',
                      children: [
                        _ToolButton('TERRAIN', Icons.terrain, selectedTool == 0, () => setState(() => selectedTool = 0)),
                        _ToolButton('BIOMES', Icons.blur_on, selectedTool == 1, () => setState(() => selectedTool = 1)),
                        _ToolButton('CLIMATE', Icons.cloud_outlined, selectedTool == 2, () => setState(() => selectedTool = 2)),
                        _ToolButton('LIGHTING', Icons.wb_sunny_outlined, selectedTool == 3, () => setState(() => selectedTool = 3)),
                        const Spacer(),
                        _Metric('SURFACE', '01 / 04'),
                        _Metric('ATMOSPHERE', 'ACTIVE'),
                        _Metric('LIGHT VECTOR', 'LOCKED'),
                      ],
                    ),
                  ),
                if (!compact)
                  Positioned(
                    right: 22,
                    top: 94,
                    bottom: 94,
                    width: 184,
                    child: _CreationPanel(
                      title: 'WORLD DATA',
                      children: [
                        const _DataRow('SEED', 'DARK-031'),
                        const _DataRow('TYPE', 'CREATION'),
                        const _DataRow('SCALE', '1.00 PLANET'),
                        const _DataRow('DETAIL', 'HIGH'),
                        const _DataRow('FOG', 'LOW'),
                        const Spacer(),
                        _MiniPreview(),
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
                    onZoomOut: () => setState(() => zoom = math.max(.86, zoom - .05)),
                    onZoomIn: () => setState(() => zoom = math.min(1.12, zoom + .05)),
                    onReset: () => setState(() => zoom = 1),
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
                    const Color(0x101A1730),
                    const Color(0x09070B18),
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
                    const Color(0x66000000),
                    const Color(0x00000000),
                    const Color(0x99000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 12 : 24,
            top: compact ? 62 : 72,
            child: const _MicroLabel('CREATION / PLANETARY LAB'),
          ),
        ]),
      );
}

class _TopBar extends StatelessWidget {
  final bool compact;
  const _TopBar({required this.compact});

  @override
  Widget build(BuildContext context) => Positioned(
        left: compact ? 12 : 22,
        right: compact ? 12 : 22,
        top: 12,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xD4070810),
            border: Border.all(color: const Color(0x327F70B0)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 22)],
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
            const Text('PLANETARY CONSTRUCTION / LIVE PREVIEW', style: TextStyle(fontSize: 5.5, letterSpacing: 1.3, color: Color(0x557F8AA2))),
            const Spacer(),
            const _MicroLabel('BUILD 031'),
            const SizedBox(width: 12),
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
          color: const Color(0xE7080911),
          border: Border.all(color: const Color(0x2B7F70B0)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30)],
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
              color: active ? const Color(0x181A1630) : const Color(0x07000000),
              border: Border.all(color: active ? const Color(0x587F70B0) : const Color(0x147F70B0)),
            ),
            child: Row(children: [
              Icon(icon, size: 12, color: active ? const Color(0xCCFFFFFF) : const Color(0x667F8AA2)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: active ? Colors.white : const Color(0x667F8AA2))),
            ]),
          ),
        ),
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
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1, color: Color(0x557F8AA2)))),
          Text(value, style: const TextStyle(fontSize: 5, letterSpacing: .7, color: Color(0xAABFC0CB))),
        ]),
      );
}

class _MiniPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 112,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x247F70B0)),
          gradient: const RadialGradient(colors: [Color(0x221F1A35), Color(0x07000000)]),
        ),
        child: const Center(child: Icon(Icons.public, size: 32, color: Color(0x557F70B0))),
      );
}

class _BottomConsole extends StatelessWidget {
  final bool compact;
  final double zoom;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onReset;
  const _BottomConsole({required this.compact, required this.zoom, required this.onZoomOut, required this.onZoomIn, required this.onReset});

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
          const Text('WORLD STABLE', style: TextStyle(fontSize: 5.5, letterSpacing: 1.4, color: Color(0xAABFC0CB))),
          const SizedBox(width: 14),
          const _ConsoleValue('ATMOSPHERE', '01'),
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
  Widget build(BuildContext context) => Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x997F70B0), boxShadow: const [BoxShadow(color: Color(0x447F70B0), blurRadius: 8)]));
}

class _MicroLabel extends StatelessWidget {
  final String text;
  const _MicroLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x667F8AA2)));
}

class _CreationSpacePainter extends CustomPainter {
  final double phase;
  _CreationSpacePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF02030A));
    final random = math.Random(31031);
    final stars = Paint();
    for (var i = 0; i < 520; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = .25 + random.nextDouble() * 1.15;
      final alpha = 30 + random.nextInt(100);
      stars.color = Color.fromARGB(alpha, 184, 188, 218);
      canvas.drawCircle(Offset(x, y), r, stars);
    }
    final haze = Paint()
      ..shader = RadialGradient(
        center: Alignment(.05, -.04),
        radius: .85,
        colors: const [Color(0x181B1730), Color(0x06101022), Color(0x00000000)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, haze);
    final sweep = Paint()
      ..color = const Color(0x167F70B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.width * .72, height: size.height * .42);
    canvas.drawArc(rect, phase * math.pi * 2, math.pi * .45, false, sweep);
  }

  @override
  bool shouldRepaint(covariant _CreationSpacePainter oldDelegate) => oldDelegate.phase != phase;
}

class _CreationPlanetPainter extends CustomPainter {
  final double phase;
  _CreationPlanetPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .31;
    final halo = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0x3C7F70B0), Color(0x101C1730), Color(0x00000000)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.7));
    canvas.drawCircle(center, radius * 1.7, halo);

    final sphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.34, -.34),
        radius: 1,
        colors: const [Color(0xFF858097), Color(0xFF4C485B), Color(0xFF272633), Color(0xFF080911)],
        stops: const [.0, .34, .68, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sphere);

    final terrain = Paint()..color = const Color(0xA3B4B0B9);
    final shadowTerrain = Paint()..color = const Color(0x523C3947);
    final features = [
      (-.38, -.22, .24, .11),
      (-.05, -.34, .29, .13),
      (.28, -.18, .22, .16),
      (.37, .13, .27, .12),
      (.08, .30, .31, .15),
      (-.30, .28, .20, .12),
      (-.04, .02, .20, .10),
    ];
    for (var i = 0; i < features.length; i++) {
      final f = features[i];
      final p = center + Offset(f.$1 * radius, f.$2 * radius);
      final rect = Rect.fromCenter(center: p, width: radius * f.$3, height: radius * f.$4);
      canvas.drawOval(rect, i.isEven ? terrain : shadowTerrain);
    }

    final latitude = Paint()
      ..color = const Color(0x347F8AA2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * radius * .23;
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.82, height: radius * .20), latitude);
    }

    final movingLight = .52 + math.sin(phase * math.pi * 2) * .10;
    final shade = Paint()
      ..shader = RadialGradient(
        center: Alignment(movingLight, -.20),
        radius: 1,
        colors: const [Colors.transparent, Color(0x0A000000), Color(0xD0000000)],
        stops: const [.45, .68, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shade);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x7C9A91B6);
    canvas.drawCircle(center, radius, rim);

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x267F70B0);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2.45, height: radius * .55), orbit);
    final markerAngle = phase * math.pi * 2;
    final marker = Offset(center.dx + math.cos(markerAngle) * radius * 1.22, center.dy + math.sin(markerAngle) * radius * .27);
    canvas.drawCircle(marker, 2.2, Paint()..color = const Color(0x997F70B0));
  }

  @override
  bool shouldRepaint(covariant _CreationPlanetPainter oldDelegate) => oldDelegate.phase != phase;
}
