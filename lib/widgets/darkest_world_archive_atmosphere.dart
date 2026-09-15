import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Global cinematic atmosphere for archive surfaces. It deliberately stays
/// lightweight: one animation, procedural particles/orbits, no textures.
class DarkestWorldArchiveAtmosphere extends StatefulWidget {
  const DarkestWorldArchiveAtmosphere({super.key});
  @override State<DarkestWorldArchiveAtmosphere> createState()=>_DarkestWorldArchiveAtmosphereState();
}

class _DarkestWorldArchiveAtmosphereState extends State<DarkestWorldArchiveAtmosphere> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:120))..repeat();
  @override void dispose(){_clock.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>CustomPaint(painter:_ArchiveAtmospherePainter(_clock.value),size:Size.infinite)));
}

class _ArchiveAtmospherePainter extends CustomPainter {
  final double phase; const _ArchiveAtmospherePainter(this.phase);
  @override void paint(Canvas c,Size s){
    final center=Offset(s.width*.5,s.height*.43); final short=math.min(s.width,s.height);
    final vignette=Paint()..shader=RadialGradient(colors:[Colors.transparent,const Color(0x30040A18),const Color(0xB8010308)],stops:const[.34,.72,1]).createShader(Offset.zero&s);c.drawRect(Offset.zero&s,vignette);
    final rng=math.Random(4207);
    for(var i=0;i<360;i++){final x=rng.nextDouble()*s.width,y=rng.nextDouble()*s.height;final twinkle=.16+.18*math.sin(phase*math.pi*2+(i%17));c.drawCircle(Offset(x,y),.25+rng.nextDouble()*1.05,Paint()..color=Colors.white.withValues(alpha:twinkle.clamp(.05,.38)));}
    for(var i=0;i<4;i++){final r=short*(.30+i*.075);c.drawOval(Rect.fromCenter(center:center,width:r*2.2,height:r*.62),Paint()..style=PaintingStyle.stroke..strokeWidth=.5..color=const Color(0x187B8CA8));}
    c.drawArc(Rect.fromCenter(center:center,width:short*.72,height:short*.22),phase*math.pi*2,1.05,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.1..color=const Color(0x497F72A8));
    c.drawCircle(center,short*.12,Paint()..shader=RadialGradient(colors:[const Color(0x182B4568),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:short*.12)));
    final lineY=(phase*s.height*1.4)%s.height;c.drawRect(Rect.fromLTWH(0,lineY,s.width,1),Paint()..color=const Color(0x087F90B8));
  }
  @override bool shouldRepaint(covariant _ArchiveAtmospherePainter old)=>old.phase!=phase;
}
