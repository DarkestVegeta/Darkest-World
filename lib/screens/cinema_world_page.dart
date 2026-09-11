import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class CinemaWorldPage extends StatefulWidget {
  final String title;
  final String description;
  const CinemaWorldPage({super.key, required this.title, required this.description});
  @override State<CinemaWorldPage> createState() => _CinemaWorldPageState();
}

class _CinemaWorldPageState extends State<CinemaWorldPage> {
  String? _selected;
  void _open(String type, String label) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(title: label, contentType: type)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010105),
    appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent),
    body: LayoutBuilder(builder: (context, constraints) {
      final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
      return Stack(alignment: Alignment.center, children: [
        Positioned.fill(child: CustomPaint(painter: _CinemaSpacePainter())),
        SizedBox(width: size, height: size, child: CustomPaint(
          painter: _CinemaPlanetPainter(),
          child: Stack(children: [
            _region('FILMS', .34, .46, 'FILMS', Icons.movie_outlined),
            _region('SERIES', .67, .56, 'SERIES', Icons.tv_outlined),
            const Center(child: Text('CINEMA\nWORLD', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, letterSpacing: 5, height: 1.5, fontWeight: FontWeight.w300))),
          ]),
        )),
        if (_selected != null) Positioned(left: 28, bottom: 28, child: _selectionPanel()),
      ]);
    }),
  );

  Widget _region(String id, double x, double y, String title, IconData icon) {
    final selected = _selected == id;
    return Align(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      child: GestureDetector(
        onTap: () => setState(() => _selected = selected ? null : id),
        child: AnimatedScale(
          scale: selected ? 1.12 : 1,
          duration: const Duration(milliseconds: 140),
          child: SizedBox(width: 104, height: 84, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 24, color: Colors.white.withValues(alpha: selected ? .95 : .65)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 11, letterSpacing: 3, color: Colors.white.withValues(alpha: selected ? 1 : .65))),
          ])),
        ),
      ),
    );
  }

  Widget _selectionPanel() {
    final films = _selected == 'FILMS';
    return Container(
      width: 360, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF090914).withValues(alpha: .94), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF9B89D8).withValues(alpha: .25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(films ? 'FILMS' : 'SERIES', style: const TextStyle(fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Text(films ? 'Films and movie discovery.' : 'Series and television worlds.', style: TextStyle(color: Colors.white.withValues(alpha: .55))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _open(films ? 'movie' : 'series', '${films ? 'FILMS' : 'SERIES'} • CINEMA-WORLD'), child: const Text('ENTER'))),
      ]),
    );
  }
}

class _CinemaSpacePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF020208);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(19)..nextInt(1);
    paint.color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 220; i++) canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 1.1, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CinemaPlanetPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    final halo = Paint()..shader = RadialGradient(colors: [const Color(0xFF5E4B9B).withValues(alpha: .18), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, halo);
    final planet = Paint()..shader = const RadialGradient(center: Alignment(-.28, -.30), radius: .95, colors: [Color(0xFF35304D), Color(0xFF16152A), Color(0xFF060611)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, planet);
    final land = Paint()..color = const Color(0xFF5A5270).withValues(alpha: .18);
    final blobs = [(Offset(-.27, -.18), .25, .18, .25), (Offset(.28, -.08), .22, .15, -.25), (Offset(-.10, .28), .30, .13, .10), (Offset(.34, .30), .17, .10, -.35), (Offset(-.38, .32), .14, .20, .20)];
    for (final b in blobs) {
      canvas.save(); canvas.translate(center.dx + b.$1.dx * radius, center.dy + b.$1.dy * radius); canvas.rotate(b.$4);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: b.$2 * radius * 2, height: b.$3 * radius * 2), land); canvas.restore();
    }
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0xFFB5A4F0).withValues(alpha: .22));
    final shade = Paint()..shader = RadialGradient(center: const Alignment(.72, .42), radius: 1.05, colors: [Colors.transparent, Colors.black.withValues(alpha: .58)]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shade);
  }
  @override bool shouldRepaint(covariant _CinemaPlanetPainter oldDelegate) => false;
}
