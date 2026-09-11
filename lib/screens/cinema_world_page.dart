import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class CinemaWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const CinemaWorldPage({super.key, required this.title, required this.description});

  @override
  State<CinemaWorldPage> createState() => _CinemaWorldPageState();
}

class _CinemaWorldPageState extends State<CinemaWorldPage> {
  String? _selected;

  void _open(String type, String label) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ContentBrowserPage(title: label, contentType: type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent),
      body: LayoutBuilder(builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: _CinemaSpacePainter())),
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _CinemaPlanetPainter(selected: _selected),
                child: Stack(
                  children: [
                    _region('FILMS', .34, .46, 'Films', Icons.movie_outlined, 'Films and movie discovery.'),
                    _region('SERIES', .67, .56, 'Series', Icons.tv_outlined, 'Series and television worlds.'),
                    const Center(
                      child: Text('CINEMA\nWORLD', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, letterSpacing: 5, height: 1.5, fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
            if (_selected != null)
              Positioned(
                left: 28,
                bottom: 28,
                child: _selectionPanel(),
              ),
          ],
        );
      }),
    );
  }

  Widget _region(String id, double x, double y, String title, IconData icon, String subtitle) {
    final selected = _selected == id;
    return Positioned(
      left: x * 1000 - 52,
      top: y * 1000 - 42,
      child: GestureDetector(
        onTap: () => setState(() => _selected = selected ? null : id),
        child: AnimatedScale(
          scale: selected ? 1.12 : 1,
          duration: const Duration(milliseconds: 140),
          child: Container(
            width: 104,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(45),
              boxShadow: selected ? [BoxShadow(color: const Color(0xFF8E75D6).withValues(alpha: .30), blurRadius: 28)] : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 24, color: Colors.white.withValues(alpha: selected ? .95 : .65)),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontSize: 11, letterSpacing: 3, color: Colors.white.withValues(alpha: selected ? 1 : .65))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _selectionPanel() {
    final films = _selected == 'FILMS';
    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF090914).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9B89D8).withValues(alpha: .25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(films ? 'FILMS' : 'SERIES', style: const TextStyle(fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Text(films ? 'Films and movie discovery.' : 'Series and television worlds.', style: TextStyle(color: Colors.white.withValues(alpha: .55))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => _open(films ? 'movie' : 'series', '${films ? 'FILMS' : 'SERIES'} • CINEMA-WORLD'),
          child: const Text('ENTER'),
        )),
      ]),
    );
  }
}

class _CinemaSpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = const Color(0xFF020208);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(19);
    paint.color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 220; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble() * 1.1;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CinemaPlanetPainter extends CustomPainter {
  final String? selected;
  _CinemaPlanetPainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    final halo = Paint()..shader = RadialGradient(colors: [const Color(0xFF5E4B9B).withValues(alpha: .18), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, halo);
    final planet = Paint()..shader = const RadialGradient(center: Alignment(-.28, -.30), radius: .95, colors: [Color(0xFF35304D), Color(0xFF16152A), Color(0xFF060611)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, planet);

    final land = Paint()..style = PaintingStyle.fill;
    final blobs = [
      (Offset(-.27, -.18), .25, .18, .25),
      (Offset(.28, -.08), .22, .15, -.25),
      (Offset(-.10, .28), .30, .13, .10),
      (Offset(.34, .30), .17, .10, -.35),
      (Offset(-.38, .32), .14, .20, .20),
    ];
    for (final b in blobs) {
      land.color = const Color(0xFF5A5270).withValues(alpha: .18);
      canvas.save();
      canvas.translate(center.dx + b.$1.dx * radius, center.dy + b.$1.dy * radius);
      canvas.rotate(b.$4);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: b.$2 * radius * 2, height: b.$3 * radius * 2), land);
      canvas.restore();
    }

    final edge = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0xFFB5A4F0).withValues(alpha: .22);
    canvas.drawCircle(center, radius, edge);
    final shade = Paint()..shader = RadialGradient(center: const Alignment(.72, .42), radius: 1.05, colors: [Colors.transparent, Colors.black.withValues(alpha: .58)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shade);
  }

  @override
  bool shouldRepaint(covariant _CinemaPlanetPainter oldDelegate) => oldDelegate.selected != selected;
}
