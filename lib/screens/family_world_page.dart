import 'dart:math' as math;
import 'package:flutter/material.dart';

class FamilyWorldPage extends StatelessWidget {
  final String title;
  final String description;
  const FamilyWorldPage({super.key, required this.title, required this.description});

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
              const Positioned.fill(child: CustomPaint(painter: _FamilySpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _FamilyPlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FamilySpacePainter extends CustomPainter {
  const _FamilySpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF10182A), Color(0xFF04060D), Color(0xFF010207)],
        ).createShader(Offset.zero & size),
    );
    final random = math.Random(84);
    final stars = Paint()..color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 240; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .35 + random.nextDouble() * 1.1,
        stars,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FamilyPlanetPainter extends CustomPainter {
  const _FamilyPlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .43;
    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF6E84A9).withValues(alpha: .16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.12)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.24, -.28),
          radius: 1,
          colors: [Color(0xFF52698D), Color(0xFF23334F), Color(0xFF0A111F), Color(0xFF02040A)],
          stops: [.0, .34, .72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final terrain = Paint()..color = const Color(0xFFB1BDD1).withValues(alpha: .11);
    for (var i = 0; i < 15; i++) {
      final a = i * .83;
      final p = Offset(center.dx + math.cos(a) * radius * .45, center.dy + math.sin(a) * radius * .37);
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: radius * (.14 + (i % 3) * .09),
          height: radius * (.07 + (i % 2) * .05),
        ),
        terrain,
      );
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.18, -.12),
          radius: 1,
          colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .64)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0xFF9EAFCA).withValues(alpha: .32),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
