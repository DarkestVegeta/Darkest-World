import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/content_models.dart';

class DarkestWorldDetailChamber extends StatefulWidget {
  final ContentItem item;
  final String? artUrl;
  const DarkestWorldDetailChamber({super.key, required this.item, this.artUrl});
  @override State<DarkestWorldDetailChamber> createState() => _DarkestWorldDetailChamberState();
}

class _DarkestWorldDetailChamberState extends State<DarkestWorldDetailChamber> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 88))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    return AnimatedBuilder(
      animation: clock,
      builder: (_, __) => Container(
        height: compact ? 520 : 600,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: const Color(0xD9050610), border: Border.all(color: const Color(0x507F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 45, offset: Offset(0, 22))]),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _ChamberPainter(clock.value))),
            Padding(
              padding: EdgeInsets.all(compact ? 14 : 24),
              child: compact
                  ? Column(children: [Expanded(child: _ObjectStage(url: widget.artUrl, title: widget.item.title, phase: clock.value)), _Info(item: widget.item, compact: true)])
                  : Row(children: [Expanded(flex: 7, child: _ObjectStage(url: widget.artUrl, title: widget.item.title, phase: clock.value)), Expanded(flex: 5, child: _Info(item: widget.item, compact: false))]),
            ),
            const Positioned(left: 16, top: 14, child: _Tag('ARCHIVE DETAIL / CHAMBER 01')),
            const Positioned(right: 16, top: 14, child: _Tag('LIVE OBJECT')),
            const Positioned(left: 16, bottom: 14, child: _Tag('DEPTH LOCK / STABLE')),
            const Positioned(right: 16, bottom: 14, child: _Tag('CINEMATIC MEDIA')),
          ],
        ),
      ),
    );
  }
}

class _ObjectStage extends StatelessWidget {
  final String? url;
  final String title;
  final double phase;
  const _ObjectStage({required this.url, required this.title, required this.phase});
  @override
  Widget build(BuildContext context) {
    final side = math.min(MediaQuery.sizeOf(context).width * .34, 330.0);
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _StagePainter(phase))),
      Center(child: Transform.rotate(angle: math.sin(phase * math.pi * 2) * .018, child: Container(width: side, height: side * 1.28, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xE60B0D15), border: Border.all(color: const Color(0x6A8A789E)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 42, offset: Offset(16, 24))]), child: url == null ? Center(child: Text(title, textAlign: TextAlign.center)) : Image.network(url!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(title, textAlign: TextAlign.center))))),
    ]);
  }
}

class _Info extends StatelessWidget {
  final ContentItem item;
  final bool compact;
  const _Info({required this.item, required this.compact});
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(compact ? 12 : 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text('CURRENT ARCHIVE OBJECT', style: TextStyle(fontSize: 7, letterSpacing: 3, color: Color(0x7F9AA8B8))), const SizedBox(height: 14), Text(item.title.toUpperCase(), maxLines: compact ? 2 : 5, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 21 : 31, fontWeight: FontWeight.w300, height: 1.02, letterSpacing: 2)), const SizedBox(height: 18), _Line('TYPE', item.type.name.toUpperCase()), if (item.franchise?.isNotEmpty ?? false) _Line('FRANCHISE', item.franchise!.toUpperCase()), if (item.releaseYear != null) _Line('RELEASE', '${item.releaseYear}'), const SizedBox(height: 22), const Text('OBJECT STATUS', style: TextStyle(fontSize: 6, letterSpacing: 2, color: Color(0x557F90A4))), const SizedBox(height: 8), const Text('PHYSICAL MEDIA / ARCHIVED / READY', style: TextStyle(fontSize: 7.5, letterSpacing: 1.4))]));
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [SizedBox(width: 75, child: Text(label, style: const TextStyle(fontSize: 5.5, color: Color(0x557F90A4)))), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7.5)))]));
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xD905060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.7, color: Color(0x667F8EA2)))));
}

class _ChamberPainter extends CustomPainter {
  final double phase;
  const _ChamberPainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.15, colors: [Color(0xFF211B2D), Color(0xFF080913), Color(0xFF010207)]).createShader(rect));
    final center = Offset(size.width * .42, size.height * .48);
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x287F90A4);
    for (var i = 0; i < 6; i++) { final w = size.width * (.3 + i * .11); canvas.drawOval(Rect.fromCenter(center: center, width: w, height: w * .24), ring); }
    canvas.drawArc(Rect.fromCenter(center: center, width: size.width * .82, height: size.width * .34), phase * math.pi * 2, .85, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x657D91A5));
    canvas.drawCircle(center, size.width * .1, Paint()..shader = const RadialGradient(colors: [Color(0x357B6CA0), Color(0x00000000)]).createShader(Rect.fromCircle(center: center, radius: size.width * .1)));
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(colors: [Color(0x00000000), Color(0xB5000000)]).createShader(rect));
  }
  @override bool shouldRepaint(covariant _ChamberPainter old) => old.phase != phase;
}

class _StagePainter extends CustomPainter {
  final double phase;
  const _StagePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x227F90A4);
    for (var i = 0; i < 8; i++) canvas.drawCircle(center, size.width * (.12 + i * .1), paint);
    final y = (phase * size.height) % size.height;
    canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), Paint()..color = const Color(0x167F70B0));
  }
  @override bool shouldRepaint(covariant _StagePainter old) => old.phase != phase;
}
