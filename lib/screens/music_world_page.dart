import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/music_world_repository.dart';
import 'chatbox.dart';

class MusicWorldPage extends StatefulWidget {
  final String title;
  final String description;
  const MusicWorldPage({super.key, required this.title, required this.description});
  @override State<MusicWorldPage> createState() => _MusicWorldPageState();
}

class _MusicWorldPageState extends State<MusicWorldPage> {
  final _repository = MusicWorldRepository();
  late Future<List<MusicWorldCategory>> _categories;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _categories = _repository.loadCategories();
  }

  void _reload() => setState(() => _categories = _repository.loadCategories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent, actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh, size: 18))]),
      floatingActionButton: const Chatbox(contextData: ChatContext(scope: ChatScope.music)),
      body: FutureBuilder<List<MusicWorldCategory>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Music World laden mislukt: ${snapshot.error}'), const SizedBox(height: 12), OutlinedButton(onPressed: _reload, child: const Text('Opnieuw'))]));
          final categories = snapshot.data ?? const <MusicWorldCategory>[];
          if (categories.isEmpty) return const Center(child: Text('Nog geen muziekcategorieën beschikbaar.'));
          return LayoutBuilder(builder: (context, constraints) {
            final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
            return Stack(alignment: Alignment.center, children: [
              const Positioned.fill(child: CustomPaint(painter: _MusicSpacePainter())),
              SizedBox(width: size, height: size, child: CustomPaint(
                painter: _MusicPlanetPainter(),
                child: Stack(children: [
                  for (var i = 0; i < categories.length; i++) _category(categories[i], i, categories.length),
                  const Center(child: Text('MUSIC\nWORLD', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, letterSpacing: 5, height: 1.5, fontWeight: FontWeight.w300))),
                ]),
              )),
              if (_selected != null) Positioned(left: 28, bottom: 28, child: _selectionPanel(categories.firstWhere((c) => c.id == _selected))),
            ]);
          });
        },
      ),
    );
  }

  Widget _category(MusicWorldCategory category, int index, int count) {
    final selected = _selected == category.id;
    final angle = -math.pi / 2 + (index / math.max(1, count)) * math.pi * 2;
    final x = .5 + math.cos(angle) * .29;
    final y = .5 + math.sin(angle) * .29;
    return Align(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      child: GestureDetector(
        onTap: () => setState(() => _selected = selected ? null : category.id),
        child: AnimatedScale(
          scale: selected ? 1.14 : 1,
          duration: const Duration(milliseconds: 140),
          child: SizedBox(width: 150, height: 72, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.music_note, size: 23, color: Colors.white.withValues(alpha: selected ? .95 : .60)),
            const SizedBox(height: 5),
            Text(category.name.toUpperCase(), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, letterSpacing: 2.2, color: Colors.white.withValues(alpha: selected ? 1 : .62))),
          ])),
        ),
      ),
    );
  }

  Widget _selectionPanel(MusicWorldCategory category) {
    return Container(
      width: 390, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF090914).withValues(alpha: .94), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF9B89D8).withValues(alpha: .25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(category.name.toUpperCase(), style: const TextStyle(fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Text(category.description.isEmpty ? 'Music category.' : category.description, style: TextStyle(color: Colors.white.withValues(alpha: .55))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('ENTER'))),
      ]),
    );
  }
}

class _MusicSpacePainter extends CustomPainter {
  const _MusicSpacePainter();
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF020208);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(27);
    paint.color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 240; i++) canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 1.1, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MusicPlanetPainter extends CustomPainter {
  const _MusicPlanetPainter();
  @override void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(center, radius * 1.35, Paint()..shader = RadialGradient(colors: [const Color(0xFF55439A).withValues(alpha: .18), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.35)));
    canvas.drawCircle(center, radius, Paint()..shader = const RadialGradient(center: Alignment(-.28, -.30), radius: .95, colors: [Color(0xFF302D4B), Color(0xFF151427), Color(0xFF060611)]).createShader(Rect.fromCircle(center: center, radius: radius)));
    final land = Paint()..color = const Color(0xFF655A82).withValues(alpha: .17);
    final blobs = [(Offset(-.27, -.18), .25, .18, .25), (Offset(.28, -.08), .22, .15, -.25), (Offset(-.10, .28), .30, .13, .10), (Offset(.34, .30), .17, .10, -.35), (Offset(-.38, .32), .14, .20, .20)];
    for (final b in blobs) { canvas.save(); canvas.translate(center.dx + b.$1.dx * radius, center.dy + b.$1.dy * radius); canvas.rotate(b.$4); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: b.$2 * radius * 2, height: b.$3 * radius * 2), land); canvas.restore(); }
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0xFFB5A4F0).withValues(alpha: .22));
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(.72, .42), radius: 1.05, colors: [Colors.transparent, Colors.black.withValues(alpha: .58)]).createShader(Rect.fromCircle(center: center, radius: radius)));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
