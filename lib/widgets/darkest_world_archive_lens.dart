import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldArchiveLens extends StatelessWidget {
  const DarkestWorldArchiveLens({super.key});
  @override Widget build(BuildContext context) {
    final nav = GalaxyNavigationSession.instance.contentNavigation;
    if (nav == null || nav.source != 'archive') return const SizedBox.shrink();
    final url = '${nav.current.metadata['public_url'] ?? nav.current.metadata['image_url'] ?? ''}';
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Positioned(top: compact ? 92 : 112, right: compact ? 12 : 28, width: compact ? 150 : 210, height: compact ? 170 : 230, child: IgnorePointer(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xB8070911), border: Border.all(color: const Color(0x2E8EA5B8))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ARCHIVE LENS', style: TextStyle(fontSize: 6, letterSpacing: 2.2, color: Color(0x8097A8BE))), const SizedBox(height: 7),
      Expanded(child: Stack(children: [if (url.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(3), child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => const SizedBox.shrink())), Positioned.fill(child: CustomPaint(painter: _Glass()))])),
      const SizedBox(height: 7), Text(nav.current.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, letterSpacing: 1.2)), const SizedBox(height: 4), const Text('ARCHIVE / MEDIA', style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: Color(0x5FFFFFFF)))
    ]))));
  }
}
class _Glass extends CustomPainter { @override void paint(Canvas canvas, Size size) { final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x258FA6BA); canvas.drawRect(Offset.zero & size, p); canvas.drawLine(Offset(size.width * .18, size.height * .12), Offset(size.width * .82, size.height * .12), p); canvas.drawLine(Offset(size.width * .18, size.height * .88), Offset(size.width * .82, size.height * .88), p); } @override bool shouldRepaint(covariant _Glass old) => false; }