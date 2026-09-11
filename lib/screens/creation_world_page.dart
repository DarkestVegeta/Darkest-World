import 'dart:math' as math;
import 'package:flutter/material.dart';

class CreationWorldPage extends StatelessWidget {
  const CreationWorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: const Text('CREATION-WORLD'), backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _CreationSpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _CreationPlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CreationSpacePainter extends CustomPainter {
  const _CreationSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF010105);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(31);
    paint.color = const Color(0x559C96B0);
    for (var i = 0; i < 230; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .35 + random.nextDouble() * 1.15,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreationPlanetPainter extends CustomPainter {
  const _CreationPlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius * 1.18,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x332F2948), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.18)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.30, -.28),
          radius: 1,
          colors: [Color(0xFF65607A), Color(0xFF343143), Color(0xFF171621), Color(0xFF08080E)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final terrain = Paint()..color = const Color(0x919089).withValues(alpha: .18);
    final blobs = [
      (Offset(-.32, -.22), .55, .22),
      (Offset(.24, -.30), .59, .28),
      (Offset(.37, .18), .62, .24),
      (Offset(-.24, .34), .58, .27),
      (Offset(.02, .04), .52, .25),
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
