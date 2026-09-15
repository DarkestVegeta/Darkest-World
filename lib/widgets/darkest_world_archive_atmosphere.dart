import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Site-wide cinematic finishing layer. Procedural only: depth stars, haze,
/// restrained bloom, scan light and framing without textures or dependencies.
class DarkestWorldArchiveAtmosphere extends StatefulWidget {
  const DarkestWorldArchiveAtmosphere({super.key});
  @override State<DarkestWorldArchiveAtmosphere> createState()=>_DarkestWorldArchiveAtmosphereState();
}

class _DarkestWorldArchiveAtmosphereState extends State<DarkestWorldArchiveAtmosphere> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:150))..repeat();
  @override void dispose(){_clock.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>CustomPaint(painter:_ArchiveAtmospherePainter(_clock.value),size:Size.infinite)));
}

class _ArchiveAtmospherePainter extends CustomPainter {
  final double phase; const _ArchiveAtmospherePainter(this.phase);
  @override void paint(Canvas c,Size s){
    final r=Offset.zero&s; final short=math.min(s.width,s.height); final center=Offset(s.width*.5,s.height*.46);
    c.drawRect(r,Paint()..shader=RadialGradient(center:const Alignment(0,.05),radius:1.05,colors:[Colors.transparent,const Color(0x16040A18),const Color(0xA8010308)],stops:const[.34,.72,1]).createShader(r));
    final rng=math.Random(4207);
    for(var i=0;i<520;i++){
      final depth=rng.nextDouble(); final x=rng.nextDouble()*s.width; final y=rng.nextDouble()*s.height;
      final drift=math.sin(phase*math.pi*2*(.25+depth*.7)+i*.31)*(.7+depth*2.2);
      final twinkle=.45+.55*math.sin(phase*math.pi*2*(.5+depth*1.4)+i*.77);
      final radius=.18+depth*1.05;
      c.drawCircle(Offset(x+drift,y),radius,Paint()..color=Colors.white.withValues(alpha:(.018+depth*.12)*twinkle.clamp(.25,1)));
    }
    final hazeRect=Rect.fromCenter(center:Offset(center.dx,center.dy+short*.06),width:s.width*.92,height:short*.30);
    c.drawOval(hazeRect,Paint()..shader=RadialGradient(colors:[const Color(0x1B8D78AA),const Color(0x0A526B89),Colors.transparent]).createShader(hazeRect));
    for(var i=0;i<5;i++){
      final rr=short*(.27+i*.072); final rot=math.sin(phase*math.pi*2+i)*.025;
      c.save(); c.translate(center.dx,center.dy); c.rotate(rot); c.translate(-center.dx,-center.dy);
      c.drawOval(Rect.fromCenter(center:center,width:rr*2.25,height:rr*.60),Paint()..style=PaintingStyle.stroke..strokeWidth=.42+i*.08..color=const Color(0x167D8FA8)); c.restore();
    }
    final arcRect=Rect.fromCenter(center:center,width:short*.76,height:short*.235);
    c.drawArc(arcRect,phase*math.pi*2,1.12,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.15..strokeCap=StrokeCap.round..color=const Color(0x4D8D7CB4));
    c.drawArc(arcRect,phase*math.pi*2+math.pi,0.42,false,Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x2E9DB1C1));
    final core=short*.13;
    c.drawCircle(center,core*2.8,Paint()..shader=RadialGradient(colors:[const Color(0x1E7D70A0),const Color(0x091D2D42),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:core*2.8)));
    c.drawCircle(center,core*.62,Paint()..shader=RadialGradient(colors:[const Color(0x4B8E86AE),const Color(0x0A8C7EA0),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:core*.62)));
    final scan=(phase*s.height*1.25)%s.height;
    c.drawRect(Rect.fromLTWH(0,scan,s.width,1.1),Paint()..color=const Color(0x0A92A7C2));
    c.drawRect(Rect.fromLTWH(0,scan-7,s.width,15),Paint()..shader=LinearGradient(colors:[Colors.transparent,const Color(0x052C5B7A),Colors.transparent]).createShader(Rect.fromLTWH(0,scan-7,s.width,15)));
    final frame=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x0C9BA9BC);
    const arm=34.0;
    c.drawLine(const Offset(18,arm),const Offset(18,18),frame); c.drawLine(const Offset(18,18),const Offset(arm,18),frame);
    c.drawLine(Offset(s.width-18,arm),Offset(s.width-18,18),frame); c.drawLine(Offset(s.width-18,18),Offset(s.width-arm,18),frame);
    c.drawLine(Offset(18,s.height-arm),Offset(18,s.height-18),frame); c.drawLine(Offset(18,s.height-18),Offset(arm,s.height-18),frame);
    c.drawLine(Offset(s.width-18,s.height-arm),Offset(s.width-18,s.height-18),frame); c.drawLine(Offset(s.width-18,s.height-18),Offset(s.width-arm,s.height-18),frame);
  }
  @override bool shouldRepaint(covariant _ArchiveAtmospherePainter old)=>old.phase!=phase;
}
