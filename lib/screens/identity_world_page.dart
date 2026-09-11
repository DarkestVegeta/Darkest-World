import 'dart:math' as math;
import 'package:flutter/material.dart';

class IdentityWorldPage extends StatelessWidget {
  final String title;
  final String description;

  const IdentityWorldPage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, constraints.maxHeight - 30) * .86;
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _IdentitySpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _IdentityPlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IdentitySpacePainter extends CustomPainter {
  const _IdentitySpacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0C1020), Color(0xFF03050B), Color(0xFF010207)],
        ).createShader(Offset.zero & size),
    );
    final random = math.Random(42);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 230; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(p, .35 + random.nextDouble() * 1.15, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IdentityPlanetPainter extends CustomPainter {
  const _IdentityPlanetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .43;

    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF697FAE).withValues(alpha: .16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.12)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.25, -.28),
          radius: 1,
          colors: [Color(0xFF465A82), Color(0xFF1B2740), Color(0xFF080D18), Color(0xFF02040A)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final terrain = Paint()..color = const Color(0xFF91A0BD).withValues(alpha: .12);
    for (var i = 0; i < 13; i++) {
      final a = i * .91;
      final p = Offset(
        center.dx + math.cos(a) * radius * .46,
        center.dy + math.sin(a) * radius * .36,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: radius * (.18 + (i % 3) * .08),
          height: radius * (.08 + (i % 2) * .05),
        ),
        terrain,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.2, -.15),
          radius: 1,
          colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .62)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0xFF9AAED0).withValues(alpha: .32),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
