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

class _GameListPageState extends State<GameListPage> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  @override void dispose() { _clock.dispose(); super.dispose(); }
  void _openLibrary() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(title: '${widget.platform} • GAMES', contentType: 'game', platformIds: widget.externalPlatformIds)));
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final previous = widget.navigationIndex > 0 ? widget.navigationPlatforms[widget.navigationIndex - 1] : null;
    final next = widget.navigationIndex >= 0 && widget.navigationIndex + 1 < widget.navigationPlatforms.length ? widget.navigationPlatforms[widget.navigationIndex + 1] : null;
    return Scaffold(backgroundColor: const Color(0xFF010208), body: AnimatedBuilder(animation: _clock, builder: (context, _) => Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: _ArchiveSpacePainter(_clock.value)),
      SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 30, compact ? 12 : 24, compact ? 14 : 30, 0), child: Row(children: [
        InkWell(onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0x99FFFFFF)))),
        const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GAME-WORLD / ${widget.territory.toUpperCase()} / ${widget.platform.toUpperCase()}', style: const TextStyle(fontSize: 10, letterSpacing: 2.4, color: Colors.white)), const SizedBox(height: 5), const Text('ARCHIVE ORBIT / CATALOG ENTRY', style: TextStyle(fontSize: 6.5, letterSpacing: 2.2, color: Color(0x55FFFFFF)))])),
        const Text('ARCHIVE 01', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x55FFFFFF))),
      ]))),
      Center(child: LayoutBuilder(builder: (context, box) { final d = math.min(box.maxWidth * (compact ? .9 : .62), box.maxHeight * (compact ? .55 : .66)); return SizedBox.square(dimension: d, child: Stack(children: [Positioned.fill(child: CustomPaint(painter: _ArchiveSystemPainter(_clock.value))), Center(child: _ArchiveCore(platform: widget.platform, phase: _clock.value))])); })),
      Positioned(left: compact ? 14 : 30, right: compact ? 14 : 30, bottom: compact ? 16 : 26, child: _ArchivePanel(platform: widget.platform, territory: widget.territory, onOpen: _openLibrary, previous: previous, next: next, onPrevious: previous == null ? null : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: previous.name, externalPlatformIds: previous.externalPlatformIds, navigationPlatforms: widget.navigationPlatforms, navigationIndex: widget.navigationIndex - 1))), onNext: next == null ? null : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: next.name, externalPlatformIds: next.externalPlatformIds, navigationPlatforms: widget.navigationPlatforms, navigationIndex: widget.navigationIndex + 1))))),
    ])));
  }
}

class _ArchiveCore extends StatelessWidget { final String platform; final double phase; const _ArchiveCore({required this.platform, required this.phase}); @override Widget build(BuildContext context) => Stack(alignment: Alignment.center, children: [Container(width: 180, height: 180, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFF8996B1), Color(0xFF3D4A61), Color(0xFF111827), Color(0xFF02040A)], stops: [.08,.28,.65,1]), boxShadow: [BoxShadow(color: Color(0x664D6D9A), blurRadius: 70, spreadRadius: 12)])), CustomPaint(size: const Size(210,210), painter: _CoreSurfacePainter(phase)), Positioned(bottom: 25, child: Text(platform.toUpperCase(), style: const TextStyle(fontSize: 9, letterSpacing: 2.5, color: Colors.white70))), ]); }

class _CoreSurfacePainter extends CustomPainter { final double phase; const _CoreSurfacePainter(this.phase); @override void paint(Canvas c, Size s) { final center=s.center(Offset.zero), r=s.width*.39; final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.7..color=const Color(0x357F93B0); for(var i=0;i<6;i++){ final y=center.dy+(i-2.5)*r*.25; c.drawArc(Rect.fromCenter(center: Offset(center.dx,y), width:r*1.8, height:r*(.25+i*.08)), math.pi, math.pi, false,p); } c.drawArc(Rect.fromCircle(center:center,radius:r*1.12), phase*math.pi*2, 1.3,false, Paint()..color=const Color(0x8A9AB1CA)..style=PaintingStyle.stroke..strokeWidth=1.1); }
 @override bool shouldRepaint(covariant _CoreSurfacePainter old)=>old.phase!=phase; }

class _ArchiveSystemPainter extends CustomPainter { final double phase; const _ArchiveSystemPainter(this.phase); @override void paint(Canvas c, Size s){final m=s.center(Offset.zero); for(var i=0;i<7;i++){final r=s.shortestSide*(.22+i*.065); c.drawOval(Rect.fromCenter(center:m,width:r*2,height:r*1.08),Paint()..style=PaintingStyle.stroke..strokeWidth=i==6?1:.55..color=const Color(0x278CA0B8));} c.drawArc(Rect.fromCircle(center:m,radius:s.shortestSide*.45),phase*math.pi*2,.65,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.4..color=const Color(0x7298ABC0)); }
 @override bool shouldRepaint(covariant _ArchiveSystemPainter old)=>old.phase!=phase; }

class _ArchiveSpacePainter extends CustomPainter { final double phase; const _ArchiveSpacePainter(this.phase); @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(colors:[Color(0xFF11182B),Color(0xFF050711),Color(0xFF010207)]).createShader(Offset.zero&s)); final r=math.Random(771); for(var i=0;i<260;i++){final x=r.nextDouble()*s.width,y=r.nextDouble()*s.height, a=.12+r.nextDouble()*.48; c.drawCircle(Offset(x,y),.35+r.nextDouble()*1.2,Paint()..color=Colors.white.withValues(alpha:a));} c.drawCircle(Offset(s.width*.5,s.height*.46),s.shortestSide*.28,Paint()..shader=RadialGradient(colors:[const Color(0x263B5477),Colors.transparent]).createShader(Rect.fromCircle(center:Offset(s.width*.5,s.height*.46),radius:s.shortestSide*.28))); }
 @override bool shouldRepaint(covariant _ArchiveSpacePainter old)=>old.phase!=phase; }

class _ArchivePanel extends StatelessWidget { final String platform,territory; final VoidCallback onOpen; final GamePlatform? previous,next; final VoidCallback? onPrevious,onNext; const _ArchivePanel({required this.platform,required this.territory,required this.onOpen,required this.previous,required this.next,required this.onPrevious,required this.onNext}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.fromLTRB(18,14,14,14),decoration:BoxDecoration(color:const Color(0xEE060A12),border:Border.all(color:const Color(0x4B7288A2)),boxShadow:const[BoxShadow(color:Colors.black87,blurRadius:34)]),child:Row(children:[if(onPrevious!=null)IconButton(onPressed:onPrevious,icon:const Icon(Icons.chevron_left,size:18)),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CATALOG WORLD  •  ${territory.toUpperCase()}',style:const TextStyle(fontSize:6.5,color:Color(0x55FFFFFF),letterSpacing:1.8)),const SizedBox(height:5),Text(platform,style:const TextStyle(fontSize:16,color:Colors.white,letterSpacing:2.5)),const SizedBox(height:4),const Text('GAME ARCHIVE / OPEN THE COMPLETE LIBRARY',style:TextStyle(fontSize:6.5,color:Color(0x66FFFFFF),letterSpacing:1.3))])),FilledButton(onPressed:onOpen,child:const Text('OPEN LIBRARY')),if(onNext!=null)IconButton(onPressed:onNext,icon:const Icon(Icons.chevron_right,size:18))])); }
