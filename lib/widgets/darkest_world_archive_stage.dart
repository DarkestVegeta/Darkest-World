import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldArchiveStage extends StatefulWidget {
  const DarkestWorldArchiveStage({super.key});
  @override State<DarkestWorldArchiveStage> createState() => _DarkestWorldArchiveStageState();
}

class _DarkestWorldArchiveStageState extends State<DarkestWorldArchiveStage> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  final session = GalaxyNavigationSession.instance;
  @override void initState() { super.initState(); session.addListener(_changed); }
  @override void dispose() { session.removeListener(_changed); clock.dispose(); super.dispose(); }
  void _changed() { if (mounted) setState(() {}); }
  @override Widget build(BuildContext context) {
    final nav = session.contentNavigation;
    if (nav == null || nav.source != 'archive') return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 760;
    return IgnorePointer(child: AnimatedBuilder(animation: clock, builder: (_, __) => CustomPaint(painter: _ArchiveStagePainter(clock.value, compact, nav.current.title), size: Size.infinite)));
  }
}

class _ArchiveStagePainter extends CustomPainter {
  final double phase; final bool compact; final String title;
  const _ArchiveStagePainter(this.phase, this.compact, this.title);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width*.5, s.height*(compact ? .49 : .50));
    final r = math.min(s.width, s.height)*(compact ? .22 : .25);
    final rect = Offset.zero & s;
    final rng = math.Random(90205);
    c.drawRect(rect, Paint()..shader = RadialGradient(center: const Alignment(0,0), radius: 1.15, colors: [const Color(0x160B0B1B), Colors.transparent, const Color(0x39000000)]).createShader(rect));
    for (var i=0;i<140;i++) {
      final p=Offset(rng.nextDouble()*s.width,rng.nextDouble()*s.height);
      c.drawCircle(p,.25+rng.nextDouble()*.75,Paint()..color=Colors.white.withValues(alpha:.025+rng.nextDouble()*.07));
    }
    for (var i=0;i<4;i++) {
      final rr=r*(1.42+i*.23);
      c.drawOval(Rect.fromCenter(center:center,width:rr*2.25,height:rr*.62),Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x18A18DBB));
    }
    final sweep=phase*math.pi*2;
    c.drawArc(Rect.fromCenter(center:center,width:r*4.2,height:r*1.15),sweep,1.05,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..strokeCap=StrokeCap.round..color=const Color(0x5A9B8DBB));
    c.drawCircle(center,r*1.62,Paint()..shader=RadialGradient(colors:[const Color(0x2B8976A9),const Color(0x0910182A),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:r*1.62)));
    c.drawCircle(center,r*1.01,Paint()..shader=RadialGradient(center:const Alignment(-.38,-.55),colors:const [Color(0xFF9A8AB3),Color(0xFF403B52),Color(0xFF0A0B12)]).createShader(Rect.fromCircle(center:center,radius:r)));
    c.save(); c.clipPath(Path()..addOval(Rect.fromCircle(center:center,radius:r*.985)));
    for(var i=0;i<12;i++) {
      final y=center.dy-r*.75+i*r*.13+math.sin(phase*math.pi*2+i)*r*.015;
      c.drawLine(Offset(center.dx-r,y),Offset(center.dx+r,y),Paint()..strokeWidth=.6..color=const Color(0x287F718F));
    }
    for(var i=0;i<18;i++) {
      final a=i*math.pi*2/18+phase*.045;
      final p=Offset(center.dx+math.cos(a)*r*.72,center.dy+math.sin(a)*r*.72);
      c.drawCircle(p,r*(.012+(i%3)*.006),Paint()..color=const Color(0x4AABA0BA));
    }
    c.restore();
    c.drawCircle(center,r,Paint()..style=PaintingStyle.stroke..strokeWidth=1.1..color=const Color(0x55C0B4CE));
    c.drawCircle(center,r*1.08,Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x28C7B9D5));
    final label=title.toUpperCase();
    final tp=TextPainter(text:TextSpan(text:label,style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:compact?8:10,letterSpacing:3,fontWeight:FontWeight.w300)),textDirection:TextDirection.ltr)..layout(maxWidth:s.width*.42);
    tp.paint(c,Offset(center.dx-tp.width/2,center.dy+r+18));
    final meta=TextPainter(text:const TextSpan(text:'ARCHIVE CORE  /  LIVE SELECTION',style:TextStyle(color:Color(0x55FFFFFF),fontSize:6,letterSpacing:2)),textDirection:TextDirection.ltr)..layout();
    meta.paint(c,Offset(center.dx-meta.width/2,center.dy+r+36));
    c.drawRect(Rect.fromLTWH(0,(phase*s.height*1.2)%s.height,s.width,1),Paint()..color=const Color(0x08118FAE));
  }
  @override bool shouldRepaint(covariant _ArchiveStagePainter old) => old.phase!=phase || old.compact!=compact || old.title!=title;
}