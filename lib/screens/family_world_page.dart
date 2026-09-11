import 'dart:math' as math;

import 'package:flutter/material.dart';

class FamilyWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const FamilyWorldPage({super.key, required this.title, required this.description});

  @override
  State<FamilyWorldPage> createState() => _FamilyWorldPageState();
}

class _FamilyWorldPageState extends State<FamilyWorldPage> {
  int? selected;

  static const members = <_FamilyMember>[
    _FamilyMember('VEGETARR', 'The central avatar and identity of DarkestVegeta.'),
    _FamilyMember('MURKHAL', 'A member of the Burdened and part of the DarkestFamily.'),
    _FamilyMember('VALKYRRA', 'A member of the Burdened and part of the DarkestFamily.'),
    _FamilyMember('ELDRAVER', 'A one-armed warrior and member of the Burdened.'),
    _FamilyMember('EIRLYTH', 'A member of the Burdened and part of the DarkestFamily.'),
    _FamilyMember('SKJARNETH', 'A member of the Burdened and part of the DarkestFamily.'),
    _FamilyMember('HELVYR', 'A member of the Burdened and part of the DarkestFamily.'),
    _FamilyMember('THUNVARR', 'The wolf companion and remembered presence of the DarkestFamily.'),
  ];

  @override
  Widget build(BuildContext context) {
    final active = selected == null ? null : members[selected!];
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _FamilySpacePainter())),
          SafeArea(
            child: Stack(
              children: [
                const Positioned(left: 28, top: 20, child: Text('DARKESTFAMILY', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 4))),
                Positioned.fill(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = math.min(constraints.maxWidth * .68, constraints.maxHeight * .72);
                        return SizedBox(
                          width: size,
                          height: size,
                          child: GestureDetector(
                            onTapUp: (details) => _selectFromPoint(details.localPosition, size),
                            child: CustomPaint(
                              painter: _FamilyPlanetPainter(selected: selected),
                              foregroundPainter: _FamilyMemberPainter(members.length, selected: selected),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (active != null)
                  Positioned(left: 28, bottom: 28, child: _SelectionPanel(member: active, onClose: () => setState(() => selected = null))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectFromPoint(Offset point, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > size * .47) return;
    final angle = (math.atan2(dy, dx) + math.pi * 2) % (math.pi * 2);
    final index = ((angle / (math.pi * 2)) * members.length).floor() % members.length;
    setState(() => selected = selected == index ? null : index);
  }
}

class _FamilyMember {
  final String name;
  final String description;
  const _FamilyMember(this.name, this.description);
}

class _SelectionPanel extends StatelessWidget {
  final _FamilyMember member;
  final VoidCallback onClose;
  const _SelectionPanel({required this.member, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF070A12).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF829BC4).withValues(alpha: .22)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member.name, style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          Text(member.description, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 12, height: 1.4)),
          const SizedBox(height: 12),
          Text('ENTER', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 10, letterSpacing: 3)),
        ])),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17, color: Colors.white54)),
      ]),
    );
  }
}

class _FamilySpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF10182A), Color(0xFF04060D), Color(0xFF010207)]).createShader(Offset.zero & size));
    final random = math.Random(84);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: .22);
    for (var i = 0; i < 240; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(p, .35 + random.nextDouble() * 1.1, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FamilyPlanetPainter extends CustomPainter {
  final int? selected;
  const _FamilyPlanetPainter({this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .46;
    canvas.drawCircle(center, radius * 1.07, Paint()..shader = RadialGradient(colors: [const Color(0xFF6E84A9).withValues(alpha: .15), Colors.transparent], stops: const [.55, 1]).createShader(Rect.fromCircle(center: center, radius: radius * 1.07)));
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(-.24, -.28), radius: 1, colors: const [Color(0xFF52698D), Color(0xFF23334F), Color(0xFF0A111F), Color(0xFF02040A)], stops: [.0, .34, .72, 1]).createShader(Rect.fromCircle(center: center, radius: radius)));
    final terrain = Paint()..color = const Color(0xFFB1BDD1).withValues(alpha: .11);
    for (var i = 0; i < 15; i++) {
      final a = i * .83;
      final p = Offset(center.dx + math.cos(a) * radius * .45, center.dy + math.sin(a) * radius * .37);
      canvas.drawOval(Rect.fromCenter(center: p, width: radius * (.14 + (i % 3) * .09), height: radius * (.07 + (i % 2) * .05)), terrain);
    }
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(-.18, -.12), radius: 1, colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .64)]).createShader(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.3..color = const Color(0xFF9EAFCA).withValues(alpha: .32));
  }

  @override
  bool shouldRepaint(covariant _FamilyPlanetPainter oldDelegate) => oldDelegate.selected != selected;
}

class _FamilyMemberPainter extends CustomPainter {
  final int count;
  final int? selected;
  const _FamilyMemberPainter(this.count, {this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .36;
    for (var i = 0; i < count; i++) {
      final angle = i * (math.pi * 2 / count) + math.pi / 8;
      final p = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      final active = selected == i;
      final paint = Paint()..color = (active ? const Color(0xFFC2D0E8) : Colors.white).withValues(alpha: active ? .9 : .3);
      canvas.drawCircle(p, active ? 6 : 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FamilyMemberPainter oldDelegate) => oldDelegate.selected != selected;
}
