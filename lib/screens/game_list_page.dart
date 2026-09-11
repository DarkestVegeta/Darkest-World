import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';
import 'game_platform_page.dart';

class GameListPage extends StatefulWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
  final List<GamePlatform> navigationPlatforms;
  final int navigationIndex;
  const GameListPage({super.key, required this.territory, required this.platform, required this.externalPlatformIds, this.navigationPlatforms = const [], this.navigationIndex = -1});
  @override State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  int focus = 2;
  void openPlatform(GamePlatform target) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: target.name, externalPlatformIds: target.externalPlatformIds, navigationPlatforms: widget.navigationPlatforms, navigationIndex: widget.navigationPlatforms.indexOf(target))));
  void openLibrary() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(title: '${widget.platform} • GAMES', contentType: 'game', platformIds: widget.externalPlatformIds)));

  @override
  Widget build(BuildContext context) {
    final platforms = widget.navigationPlatforms;
    final validIndex = widget.navigationIndex >= 0 && widget.navigationIndex < platforms.length;
    final previous = validIndex && widget.navigationIndex > 0 ? platforms[widget.navigationIndex - 1] : null;
    final next = validIndex && widget.navigationIndex < platforms.length - 1 ? platforms[widget.navigationIndex + 1] : null;
    return Scaffold(backgroundColor: const Color(0xFF010107), body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 900;
      return Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _GamesBackgroundPainter())),
        SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 26), child: Row(children: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
          const SizedBox(width: 6), Expanded(child: Text('GAME-WORLD  /  ${widget.territory}  /  ${widget.platform}  /  GAMES', style: TextStyle(fontSize: 10, letterSpacing: 2))),
        ]))),
        Center(child: _PlatformStrip(platforms: platforms, currentIndex: widget.navigationIndex, focus: focus, currentName: widget.platform, compact: compact, onFocus: (i) => setState(() => focus = i), onOpenCurrent: openLibrary, onOpenPlatform: (i) { if (i >= 0 && i < platforms.length) openPlatform(platforms[i]); })),
        Positioned(left: 0, right: 0, bottom: compact ? 18 : 28, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Nav(label: 'PREVIOUS', value: previous?.name, onTap: previous == null ? null : () => openPlatform(previous)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('|')),
          Text(widget.platform, style: const TextStyle(fontSize: 10, letterSpacing: 1.8)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('|')),
          _Nav(label: 'NEXT', value: next?.name, onTap: next == null ? null : () => openPlatform(next)),
        ])),
      ]);
    }));
  }
}

class _PlatformStrip extends StatelessWidget {
  final List<GamePlatform> platforms; final int currentIndex; final int focus; final String currentName; final bool compact; final ValueChanged<int> onFocus; final VoidCallback onOpenCurrent; final ValueChanged<int> onOpenPlatform;
  const _PlatformStrip({required this.platforms, required this.currentIndex, required this.focus, required this.currentName, required this.compact, required this.onFocus, required this.onOpenCurrent, required this.onOpenPlatform});
  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - (compact ? 20 : 60), 1320.0);
    return SizedBox(width: width, height: compact ? 430 : 510, child: Column(children: [
      Text('GAME LIBRARY', style: TextStyle(fontSize: 9, letterSpacing: 3.5, color: Colors.white.withValues(alpha: .28))),
      const SizedBox(height: 8), Text(currentName.toUpperCase(), style: const TextStyle(fontSize: 21, letterSpacing: 4)), const SizedBox(height: 28),
      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (slot) {
        final index = currentIndex + slot - 2;
        final available = index >= 0 && index < platforms.length;
        final title = available ? platforms[index].name : slot == 2 ? currentName : '—';
        final main = slot == 2;
        final active = focus == slot;
        return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: MouseRegion(onEnter: (_) => onFocus(slot), cursor: available || main ? SystemMouseCursors.click : SystemMouseCursors.basic, child: GestureDetector(onTap: main ? onOpenCurrent : available ? () => onOpenPlatform(index) : null, child: _LibraryCard(title: title, main: main, active: active, available: available, height: main ? (compact ? 280 : 335) : (compact ? 225 : 270))))));
      }))),
      const SizedBox(height: 14), Text(focus == 2 ? 'CURRENT  •  ENTER' : 'SELECT PLATFORM  •  ENTER', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white.withValues(alpha: .28))),
    ]));
  }
}

class _LibraryCard extends StatelessWidget {
  final String title; final bool main, active, available; final double height;
  const _LibraryCard({required this.title, required this.main, required this.active, required this.available, required this.height});
  @override Widget build(BuildContext context) => AnimatedContainer(duration: const Duration(milliseconds: 120), height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(main ? 18 : 14), border: Border.all(color: Colors.white.withValues(alpha: main ? .24 : available ? .10 : .04), width: main ? 1.5 : 1), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF17152A), Color(0xFF080811), Color(0xFF030307)]), boxShadow: main ? const [BoxShadow(color: Color(0x667765D0), blurRadius: 35)] : const []), child: Padding(padding: EdgeInsets.all(main ? 20 : 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(main ? 'CURRENT' : available ? 'PLATFORM' : 'EMPTY', style: TextStyle(fontSize: 7, letterSpacing: 2.2, color: Colors.white.withValues(alpha: main ? .46 : .24))), const Spacer(), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: main ? 16 : 11, letterSpacing: main ? 2 : 1, fontWeight: main ? FontWeight.w600 : FontWeight.w500, color: Colors.white.withValues(alpha: available || main ? 1 : .25))), const SizedBox(height: 8), Text(available || main ? (main ? 'OPEN LIBRARY' : 'ENTER WORLD') : 'NO WORLD', style: TextStyle(fontSize: 7, letterSpacing: 1.6, color: Colors.white.withValues(alpha: .22))) ])));
}

class _Nav extends StatelessWidget { final String label; final String? value; final VoidCallback? onTap; const _Nav({required this.label, required this.value, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Column(children: [Text(label, style: TextStyle(fontSize: 7, letterSpacing: 2, color: Colors.white.withValues(alpha: onTap == null ? .12 : .30))), const SizedBox(height: 4), Text(value ?? '—', style: TextStyle(fontSize: 9, color: onTap == null ? Colors.white.withValues(alpha: .10) : const Color(0xFF9A82FF)))])); }

class _GamesBackgroundPainter extends CustomPainter { const _GamesBackgroundPainter(); @override void paint(Canvas canvas, Size size) { canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.1, colors: [Color(0xFF161330), Color(0xFF060612), Color(0xFF010105)]).createShader(Offset.zero & size)); final r = math.Random(442); final p = Paint(); for (var i = 0; i < 140; i++) { p.color = Colors.white.withValues(alpha: .04 + (i % 5) * .025); canvas.drawCircle(Offset(r.nextDouble() * size.width, r.nextDouble() * size.height), .25 + r.nextDouble() * .7, p); } } @override bool shouldRepaint(covariant _GamesBackgroundPainter oldDelegate) => false; }
