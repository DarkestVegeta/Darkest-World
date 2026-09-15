import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/darkest_world_navigation_state.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldArchiveLens extends StatefulWidget {
  const DarkestWorldArchiveLens({super.key});
  @override State<DarkestWorldArchiveLens> createState() => _DarkestWorldArchiveLensState();
}

class _DarkestWorldArchiveLensState extends State<DarkestWorldArchiveLens> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 72))..repeat();
  final session = GalaxyNavigationSession.instance;
  @override void dispose() { _clock.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_clock, session]),
      builder: (_, __) {
        final nav = session.contentNavigation;
        if (nav == null || nav.source != 'archive') return const SizedBox.shrink();
        final compact = MediaQuery.sizeOf(context).width < 850;
        return Positioned(
          right: compact ? 12 : 28,
          bottom: compact ? 88 : 112,
          width: compact ? 128 : 190,
          height: compact ? 174 : 250,
          child: IgnorePointer(child: _LensCard(nav: nav, phase: _clock.value, compact: compact)),
        );
      },
    );
  }
}

class _LensCard extends StatelessWidget {
  final DarkestWorldNavigationState nav; final double phase; final bool compact;
  const _LensCard({required this.nav, required this.phase, required this.compact});
  @override Widget build(BuildContext context) {
    final url = '${nav.current.metadata['public_url'] ?? nav.current.metadata['image_url'] ?? ''}';
    return CustomPaint(
      painter: _LensPainter(phase: phase, active: true),
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ARCHIVE LENS', style: TextStyle(fontSize: 6, letterSpacing: 2.2, color: Color(0x8097A8BE))),
          const SizedBox(height: 7),
          Expanded(child: Stack(alignment: Alignment.center, children: [
            if (url.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(3), child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
            Positioned.fill(child: CustomPaint(painter: _GlassPainter(phase))),
          ])),
          const SizedBox(height: 7),
          Text(nav.current.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 7.5 : 9, letterSpacing: 1.2, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${nav.entryLabel}  /  ${nav.current.contentType.toUpperCase()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: Color(0x5FFFFFFF))),
        ]),
      ),
    );
  }
}

class _LensPainter extends CustomPainter {
  final double phase; final bool active;
  const _LensPainter({required this.phase, required this.active});
  @override void paint(Canvas c, Size s) {
    final r = Offset.zero & s; final center = Offset(s.width * .5, s.height * .45); final short = math.min(s.width, s.height);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), Paint()..color = const Color(0xD9060810));
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x687F70B0));
    for (var i = 0; i < 3; i++) {
      final rr = short * (.34 + i * .08);
      c.drawOval(Rect.fromCenter(center: center, width: rr * 1.35, height: rr * .55), Paint()..style = PaintingStyle.stroke..strokeWidth = .45..color = const Color(0x257E91AA));
    }
    final a = phase * math.pi * 2;
    c.drawArc(Rect.fromCenter(center: center, width: short * .78, height: short * .31), a, 1.0, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x6A8E7FB3));
    c.drawCircle(center, short * (.16 + .01 * math.sin(a)), Paint()..shader = RadialGradient(colors: const [Color(0x1F9A8AB8), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: short * .25)));
    final scan = (phase * s.height * 1.3) % s.height;
    c.drawRect(Rect.fromLTWH(0, scan, s.width, .8), Paint()..color = const Color(0x0E9AAAC0));
  }
  @override bool shouldRepaint(covariant _LensPainter old) => old.phase != phase;
}

class _GlassPainter extends CustomPainter {
  final double phase; const _GlassPainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final x = ((phase * 1.6) % 1.4) * s.width - s.width * .25;
    final band = Rect.fromLTWH(x, 0, s.width * .22, s.height);
    c.drawRect(band, Paint()..shader = const LinearGradient(colors: [Colors.transparent, Color(0x0DFFFFFF), Colors.transparent]).createShader(band));
    c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x12000000), Colors.transparent, Color(0x30000000)]).createShader(Offset.zero & s));
  }
  @override bool shouldRepaint(covariant _GlassPainter old) => old.phase != phase;
}
