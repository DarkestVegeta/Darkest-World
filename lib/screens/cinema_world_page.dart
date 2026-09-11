import 'dart:math' as math;
import 'package:flutter/material.dart';

class CinemaWorldPage extends StatelessWidget {
  final String title;
  final String description;
  const CinemaWorldPage({super.key, required this.title, required this.description});

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
              const Positioned.fill(child: CustomPaint(painter: _CinemaSpacePainter())),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(painter: const _CinemaPlanetPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CinemaSpacePainter extends CustomPainter {
  const _CinemaSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF020208);
    canvas.drawRect(Offset.zero & size, paint);
    final random = math.Random(19);
    paint.color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 220; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.1,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CinemaPlanetPainter extends CustomPainter {
  const _CinemaPlanetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF5E4B9B).withValues(alpha: .18), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.28, -.30),
          radius: .95,
          colors: [Color(0xFF35304D), Color(0xFF16152A), Color(0xFF060611)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final land = Paint()..color = const Color(0xFF5A5270).withValues(alpha: .18);
    final blobs = [
      (Offset(-.27, -.18), .25, .18, .25),
      (Offset(.28, -.08), .22, .15, -.25),
      (Offset(-.10, .28), .30, .13, .10),
      (Offset(.34, .30), .17, .10, -.35),
      (Offset(-.38, .32), .14, .20, .20),
    ];
    for (final b in blobs) {
      canvas.save();
      canvas.translate(center.dx + b.$1.dx * radius, center.dy + b.$1.dy * radius);
      canvas.rotate(b.$4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: b.$2 * radius * 2,
          height: b.$3 * radius * 2,
        ),
        land,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFB5A4F0).withValues(alpha: .22),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(.72, .42),
          radius: 1.05,
          colors: [Colors.transparent, Colors.black.withValues(alpha: .58)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
