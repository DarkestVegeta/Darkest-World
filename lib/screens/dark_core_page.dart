import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkCorePage extends StatelessWidget {
  final String title;
  final String description;
  const DarkCorePage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _DarkCoreSpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _DarkCorePlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DarkCoreSpacePainter extends CustomPainter {
  const _DarkCoreSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010105));
    final random = math.Random(13);
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

class _DarkCorePlanetPainter extends CustomPainter {
  const _DarkCorePlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius * 1.2,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x553A2B55), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.28, -.32),
          radius: 1.05,
          colors: [Color(0xFF51406F), Color(0xFF2B203D), Color(0xFF120D1C), Color(0xFF050409)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final terrain = Paint()..color = const Color(0x725E4A78).withValues(alpha: .25);
    final blobs = [
      (Offset(-.30, -.25), .52, .22),
      (Offset(.26, -.20), .57, .27),
      (Offset(.36, .17), .60, .23),
      (Offset(-.25, .32), .55, .28),
      (Offset(.01, .03), .48, .24),
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
          center: Alignment(-.16, -.12),
          radius: 1,
          colors: [Colors.transparent, Colors.transparent, Color(0xB8000000)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0x886D5A8C),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
