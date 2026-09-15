import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestWorldArchiveDepth extends StatefulWidget {
  const DarkestWorldArchiveDepth({super.key});
  @override State<DarkestWorldArchiveDepth> createState()=>_DarkestWorldArchiveDepthState();
}
class _DarkestWorldArchiveDepthState extends State<DarkestWorldArchiveDepth> with SingleTickerProviderStateMixin{
 late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:104))..repeat();
 @override void dispose(){_clock.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>CustomPaint(painter:_ArchiveDepthPainter(_clock.value),size:Size.infinite)));
}
class _ArchiveDepthPainter extends CustomPainter{
 final double phase;const _ArchiveDepthPainter(this.phase);
 @override void paint(Canvas c,Size s){
  final m=math.min(s.width,s.height),center=Offset(s.width*.5,s.height*.52),rx=m*.39,ry=m*.25;
  c.save();c.translate(center.dx,center.dy);c.rotate(math.sin(phase*math.pi*2)*.018);c.translate(-center.dx,-center.dy);
  for(var i=0;i<11;i++){final f=1-i*.065;c.drawOval(Rect.fromCenter(center:center,width:rx*2*f,height:ry*2*f),Paint()..style=PaintingStyle.stroke..strokeWidth=.4+i*.035..color=const Color(0x187F70B0));}
  final sweep=phase*math.pi*2,arc=Rect.fromCenter(center:center,width:rx*2.08,height:ry*2.08);
  c.drawArc(arc,sweep,.58,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..strokeCap=StrokeCap.round..color=const Color(0x5B8E7FB9));
  c.drawArc(arc,sweep+math.pi,.25,false,Paint()..style=PaintingStyle.stroke..strokeWidth=.6..color=const Color(0x319FB4C8));
  for(var i=0;i<18;i++){final a=i*math.pi*2/18+phase*.17,orbit=.60+(i%5)*.075,p=Offset(center.dx+math.cos(a)*rx*orbit,center.dy+math.sin(a)*ry*orbit);c.drawCircle(p,.65+(i%3)*.5,Paint()..color=const Color(0x63CDD6E1));}
  c.restore();
  final edge=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x129BA9BC);const k=30.0;
  for(final p in <Offset>[Offset(16,k),Offset(s.width-16,k),Offset(16,s.height-k),Offset(s.width-16,s.height-k)]){final x=p.dx,y=p.dy, sx=x<s.width/2?1:-1,sy=y<s.height/2?1:-1;c.drawLine(Offset(x,y),Offset(x,y+sy*14),edge);c.drawLine(Offset(x,y),Offset(x+sx*14,y),edge);}
  final scan=(phase*s.height*1.25)%(s.height+100)-50;c.drawRect(Rect.fromLTWH(0,scan,s.width,1),Paint()..color=const Color(0x109AB0C5));
  final band=Rect.fromLTWH(0,scan-10,s.width,20);c.drawRect(band,Paint()..shader=const LinearGradient(colors:[Colors.transparent,Color(0x061C4E6B),Colors.transparent]).createShader(band));
 }
 @override bool shouldRepaint(covariant _ArchiveDepthPainter old)=>old.phase!=phase;
}
