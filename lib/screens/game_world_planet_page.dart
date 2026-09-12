import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String name, description;
  final List<GamePlatformGroup> groups;
  const _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> with SingleTickerProviderStateMixin {
  int? selected;
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();

  final territories = const <_TerritoryData>[
    _TerritoryData('NINTENDO', 'Nintendo generations.', [
      GamePlatformGroup('HOME CONSOLES', 'Home generations.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ]),
    _TerritoryData('SEGA', 'Sega generations.', [
      GamePlatformGroup('CONSOLES', 'Console generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Portable generation.', [GamePlatform('Game Gear', [35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'PlayStation generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])])]),
    _TerritoryData('XBOX', 'Xbox generations.', [GamePlatformGroup('GENERATIONS', 'Main generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])])]),
  ];

  @override void dispose() { _clock.dispose(); super.dispose(); }
  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].name, groups: territories[i].groups)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010207),
    body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 760;
      final diameter = math.min(box.maxWidth * .92, box.maxHeight * .88);
      return AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _SpacePainter(t: _clock.value))),
          SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 28), child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
            const SizedBox(width: 8),
            const Text('GAME-WORLD', style: TextStyle(fontSize: 16, letterSpacing: 4)),
            const Spacer(),
            const Text('ONE WORLD  •  FOUR REGIONS', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white24)),
          ]))),
          Center(child: AnimatedScale(
            duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic,
            scale: selected == null ? 1 : 1.035,
            child: SizedBox(width: diameter, height: diameter, child: GestureDetector(
              onTapUp: (e) { final hit = _hit(e.localPosition, diameter, _clock.value); if (hit != null) setState(() => selected = selected == hit ? null : hit); },
              child: CustomPaint(
                painter: _PlanetPainter(selected: selected, rotation: _clock.value),
                child: Stack(children: [
                  _label('NINTENDO', .24, .22, 0, diameter),
                  _label('SEGA', .75, .28, 1, diameter),
                  _label('PLAYSTATION', .26, .74, 2, diameter),
                  _label('XBOX', .75, .65, 3, diameter),
                  Center(child: AnimatedOpacity(duration: const Duration(milliseconds: 350), opacity: selected == null ? .48 : .05, child: const Text('GAME-WORLD', style: TextStyle(fontSize: 11, letterSpacing: 5, color: Colors.white))),
                ]),
              ),
            )),
          )),
          if (selected != null) Positioned(left: compact ? 14 : 30, right: compact ? 14 : 30, bottom: compact ? 42 : 54, child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), constraints: const BoxConstraints(maxWidth: 660),
            decoration: BoxDecoration(color: const Color(0xED080913), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Color(0x77000000), blurRadius: 34, offset: Offset(0, 14))]),
            child: Row(children: [
              Container(width: 3, height: 34, decoration: BoxDecoration(color: const Color(0xAA9A8AC5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(territories[selected!].name, style: const TextStyle(fontSize: 14, letterSpacing: 3)), const SizedBox(height: 5), Text(territories[selected!].description, style: const TextStyle(fontSize: 9, color: Colors.white38))])),
              TextButton(onPressed: () => enter(selected!), child: const Text('ENTER')),
            ]),
          ))),
          Positioned(left: compact ? 16 : 30, bottom: compact ? 16 : 24, child: Text(selected == null ? 'SELECT A REGION' : 'REGION SELECTED  •  ENTER TO OPEN', style: const TextStyle(fontSize: 8, letterSpacing: 2.5, color: Colors.white24))),
        ]),
      );
    }),
  );

  Widget _label(String text, double x, double y, int i, double d) {
    final alpha = selected == null || selected == i ? .82 : .06;
    return Positioned(left: d * x - 105, top: d * y - 22, width: 210, child: IgnorePointer(child: Center(child: Text(text, style: TextStyle(fontSize: selected == i ? 11 : 9, letterSpacing: 2.5, color: Colors.white.withValues(alpha: alpha))))));
  }

  int? _hit(Offset p, double d, double rotation) {
    final c = Offset(d / 2, d / 2), r = d * .47;
    const base = [Offset(-.22, -.25), Offset(.27, -.18), Offset(-.20, .27), Offset(.23, .23)];
    const scale = [.34, .29, .37, .30];
    for (var i = 0; i < 4; i++) {
      final longitude = base[i].dx + math.sin(rotation * math.pi * 2 + i) * .018;
      final q = c + Offset(longitude * r, base[i].dy * r);
      if ((p - q).distance < r * scale[i]) return i;
    }
    return null;
  }
}

class _PlanetPainter extends CustomPainter {
  final int? selected;
  final double rotation;
  const _PlanetPainter({required this.selected, required this.rotation});

  static const centers = [Offset(-.22, -.25), Offset(.27, -.18), Offset(-.20, .27), Offset(.23, .23)];
  static const sizes = [Offset(.70, .46), Offset(.50, .39), Offset(.65, .48), Offset(.51, .40)];
  static const colors = [Color(0xFF9175A9), Color(0xFF66829A), Color(0xFF786C98), Color(0xFF5D847A)];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .47;
    final sphere = Rect.fromCircle(center: c, radius: r);
    final rnd = math.Random(442);

    // Large atmospheric volume behind the globe.
    canvas.drawCircle(c, r * 1.62, Paint()..shader = const RadialGradient(colors: [Color(0x66758CB4), Color(0x20536B91), Colors.transparent], stops: [0, .43, 1]).createShader(Rect.fromCircle(center: c, radius: r * 1.62)));
    canvas.drawCircle(c, r * 1.045, Paint()..shader = const RadialGradient(center: Alignment(-.56, -.62), radius: 1.12, colors: [Color(0xFFE2D7C8), Color(0xFFA49D99), Color(0xFF676974), Color(0xFF272A35), Color(0xFF05070D)], stops: [0, .13, .35, .68, 1]).createShader(sphere));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // A restrained planetary crust beneath the four named regions.
    for (var i = 0; i < 11; i++) {
      final y = c.dy + math.sin(i * .55 + rotation * math.pi * 2) * r * .13;
      final w = r * (1.25 + math.sin(i * .8) * .16);
      canvas.drawArc(Rect.fromCenter(center: Offset(c.dx + math.sin(i * .8) * r * .08, y), width: w, height: r * .40), math.pi * .08, math.pi * .84, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0032..color = Colors.white.withValues(alpha: .010));
    }

    for (var i = 0; i < 4; i++) {
      final longitude = centers[i].dx + math.sin(rotation * math.pi * 2 + i) * .018;
      final latitude = centers[i].dy + math.sin(rotation * math.pi * 4 + i * 1.7) * .008;
      final side = longitude;
      final depth = latitude;
      final center = c + Offset(longitude * r - side * r * .035, latitude * r + depth * r * .018);
      final edge = math.sqrt(math.max(.04, 1 - side * side));
      final vertical = math.sqrt(math.max(.04, 1 - depth * depth));
      final pw = r * sizes[i].dx * (.64 + .36 * edge);
      final ph = r * sizes[i].dy * (.72 + .28 * vertical);
      final rot = [.18, -.24, -.08, .25][i];
      final active = selected == null ? .34 : selected == i ? .86 : .010;

      // Deep base gives every territory a physical elevation.
      final base = _shape(center + Offset(r * .018, r * .030), pw * 1.06, ph * 1.08, rot, 1800 + i * 37, 1);
      canvas.drawPath(base, Paint()..color = Colors.black.withValues(alpha: selected == i ? .40 : .18));
      final baseRim = _shape(center + Offset(r * .008, r * .018), pw * 1.015, ph * 1.02, rot, 1830 + i * 37, .99);
      canvas.drawPath(baseRim, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .009..color = Colors.black.withValues(alpha: selected == i ? .32 : .08));

      final land = _shape(center, pw, ph, rot, 700 + i * 19, 1);
      canvas.drawPath(land, Paint()..color = colors[i].withValues(alpha: active));
      canvas.drawPath(land, Paint()..style = PaintingStyle.stroke..strokeWidth = r * (selected == i ? .016 : .006)..color = Colors.white.withValues(alpha: selected == i ? .44 : .06));

      // Layered contour relief.
      for (var q = 1; q <= 10; q++) {
        final sc = 1 - q * .078;
        final drift = Offset(-side * r * .007 * q, depth * r * .004 * q);
        final inner = _shape(center + drift, pw * sc, ph * sc, rot, 740 + i * 19 + q * 23, 1 - q * .012);
        canvas.drawPath(inner, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0028..color = Colors.white.withValues(alpha: selected == i ? .075 : .012));
      }

      // Curved strata, following the globe's surface instead of a flat map.
      for (var band = 0; band < 8; band++) {
        final t = (band - 3.5) * .135;
        final y = center.dy + t * ph;
        final left = center.dx - pw * .46;
        final right = center.dx + pw * .46;
        final p = Path()..moveTo(left, y);
        for (var k = 1; k <= 22; k++) {
          final u = k / 22;
          final globeBend = math.sin(u * math.pi) * ph * (.11 + .11 * (1 - t.abs()));
          final wave = math.sin(u * math.pi * 2.15 + band * 1.55 + i) * ph * .021;
          p.lineTo(left + (right - left) * u, y - globeBend + wave);
        }
        canvas.drawPath(p, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0036..color = Colors.white.withValues(alpha: selected == i ? .07 : .017));
      }

      // Three broad geological cuts make the regions feel like terrain, not UI shapes.
      for (var ridge = 0; ridge < 3; ridge++) {
        final y = center.dy + (ridge - 1) * ph * .23;
        final p = Path()..moveTo(center.dx - pw * .33, y);
        for (var k = 1; k <= 12; k++) {
          final u = k / 12;
          p.lineTo(center.dx - pw * .33 + pw * .66 * u, y + math.sin(u * math.pi * 2.5 + ridge + i) * ph * .085);
        }
        canvas.drawPath(p, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0042..color = Colors.black.withValues(alpha: selected == i ? .12 : .025));
      }

      final lightEdge = _shape(center + Offset(-r * .004, -r * .007), pw * .975, ph * .975, rot, 1700 + i * 29, .99);
      canvas.drawPath(lightEdge, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .004..color = Colors.white.withValues(alpha: selected == i ? .12 : .025));
    }

    // Faint spherical grid: enough to sell the globe, never enough to look technical.
    for (var i = 0; i < 9; i++) {
      final t = -0.80 + i * .20;
      final half = r * math.sqrt(math.max(0, 1 - t * t));
      canvas.drawOval(Rect.fromCenter(center: Offset(c.dx + t * r * .18, c.dy), width: half * 1.48, height: r * .024), Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0025..color = Colors.white.withValues(alpha: .010));
    }

    for (var i = 0; i < 7; i++) {
      final t = -.70 + i * .233;
      final half = r * math.sqrt(math.max(0, 1 - t * t));
      canvas.drawArc(Rect.fromCenter(center: Offset(c.dx, c.dy + t * r * .10), width: r * 1.90, height: half * 1.22), math.pi * .08, math.pi * .84, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .0032..color = Colors.white.withValues(alpha: .012));
    }

    for (var i = 0; i < 135; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final rr = r * (.10 + rnd.nextDouble() * .82);
      canvas.drawCircle(Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr * .78), r * (.0007 + rnd.nextDouble() * .0035), Paint()..color = Colors.white.withValues(alpha: .005 + rnd.nextDouble() * .018));
    }
    canvas.restore();

    // Night-side volume and hard atmospheric rim.
    final night = c + Offset(r * .60, r * .10);
    canvas.drawCircle(night, r * .965, Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0xE5000208)], stops: [.22, 1]).createShader(Rect.fromCircle(center: night, radius: r * .965)));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.012), math.pi * .58, math.pi * .94, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .014..color = Colors.white.withValues(alpha: .32));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.022), math.pi * 1.04, math.pi * .86, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .020..color = const Color(0x668CA4C7));
  }

  Path _shape(Offset center, double width, double height, double rotation, int seed, double shape) {
    final rnd = math.Random(seed);
    const count = 32;
    final points = <Offset>[];
    for (var i = 0; i < count; i++) {
      final a = i / count * math.pi * 2;
      final wave = math.sin(a * 2.1 + seed) * .14 + math.sin(a * 3.7 + seed * .10) * .09 + math.sin(a * 6.5 + seed * .07) * .045;
      final notch = math.sin(a * 9.0 + seed * .04) * .018;
      final rad = (.80 + wave + notch + rnd.nextDouble() * .07) * shape;
      final x = math.cos(a) * width * .5 * rad;
      final y = math.sin(a) * height * .5 * rad * (.88 + .12 * math.sin(a * 2.6 + seed));
      final xr = x * math.cos(rotation) - y * math.sin(rotation);
      final yr = x * math.sin(rotation) + y * math.cos(rotation);
      points.add(Offset(center.dx + xr, center.dy + yr));
    }
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < count; i++) {
      final a = points[i], b = points[(i + 1) % count];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    return path..close();
  }

  @override bool shouldRepaint(covariant _PlanetPainter old) => old.selected != selected || old.rotation != rotation;
}

class _SpacePainter extends CustomPainter {
  final double t;
  const _SpacePainter({required this.t});
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.12, colors: [Color(0xFF17182D), Color(0xFF060710), Color(0xFF010205)]).createShader(rect));
    final rnd = math.Random(711);
    for (var i = 0; i < 260; i++) {
      final x = (rnd.nextDouble() * size.width + t * size.width * .022) % size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), .12 + rnd.nextDouble() * .72, Paint()..color = Colors.white.withValues(alpha: .024 + rnd.nextDouble() * .095));
    }
  }
  @override bool shouldRepaint(covariant _SpacePainter old) => old.t != t;
}
