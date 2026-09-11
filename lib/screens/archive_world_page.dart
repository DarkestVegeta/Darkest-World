import 'dart:math' as math;
import 'package:flutter/material.dart';

class ArchiveWorldPage extends StatelessWidget {
  const ArchiveWorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: const Text('ARCHIVE-WORLD'), backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _ArchiveSpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _ArchivePlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArchiveSpacePainter extends CustomPainter {
  const _ArchiveSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010105));
    final random = math.Random(47);
    final stars = Paint()..color = const Color(0x559C96B0);
    for (var i = 0; i < 230; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .35 + random.nextDouble() * 1.15,
        stars,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArchivePlanetPainter extends CustomPainter {
  const _ArchivePlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius * 1.16,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x332B3442), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.16)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.32, -.30),
          radius: 1.08,
          colors: [Color(0xFF657080), Color(0xFF343B46), Color(0xFF171A20), Color(0xFF08090D)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final terrain = Paint()..color = const Color(0x3D98A1B0);
    final blobs = [
      (Offset(-.30, -.24), .52, .22),
      (Offset(.25, -.28), .56, .29),
      (Offset(.38, .14), .60, .24),
      (Offset(-.28, .34), .56, .28),
      (Offset(.03, .04), .50, .25),
    ];
    for (final b in blobs) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(b.$1.dx * radius, b.$1.dy * radius),
          width: radius * b.$2,
          height: radius * b.$3,
        ),
        terrain,
      );
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.18, -.12),
          radius: 1,
          colors: [Colors.transparent, Colors.transparent, Color(0xA6000000)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0x775C6470),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
