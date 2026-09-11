import 'dart:math' as math;
import 'package:flutter/material.dart';

class ComingSoonWorldPage extends StatelessWidget {
  const ComingSoonWorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: const Text('COMING SOON'), backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _ComingSoonSpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _ComingSoonPlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ComingSoonSpacePainter extends CustomPainter {
  const _ComingSoonSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010105));
    final random = math.Random(91);
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

class _ComingSoonPlanetPainter extends CustomPainter {
  const _ComingSoonPlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius * 1.16,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x332E2940), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.16)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.34, -.28),
          radius: 1.08,
          colors: [Color(0xFF605A70), Color(0xFF322E3B), Color(0xFF17151D), Color(0xFF08080D)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final terrain = Paint()..color = const Color(0x354D485A);
    final blobs = [
      (Offset(-.32, -.24), .52, .22),
      (Offset(.27, -.28), .56, .29),
      (Offset(.34, .18), .60, .24),
      (Offset(-.28, .31), .56, .28),
      (Offset(.03, .03), .50, .25),
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
        ..color = const Color(0x775E5870),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
