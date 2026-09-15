import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldAtlasRadar extends StatefulWidget {
  const DarkestWorldAtlasRadar({super.key});
  @override State<DarkestWorldAtlasRadar> createState() => _DarkestWorldAtlasRadarState();
}
class _DarkestWorldAtlasRadarState extends State<DarkestWorldAtlasRadar> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 72))..repeat();
  @override void dispose(){clock.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>IgnorePointer(child:AnimatedBuilder(animation:clock,builder:(_,__)=>CustomPaint(painter:_RadarPainter(clock.value,GalaxyNavigationSession.instance.contentNavigation?.current.title),size:Size.infinite)));
}
class _RadarPainter extends CustomPainter {
  final double t; final String? title; const _RadarPainter(this.t,this.title);
  @override void paint(Canvas x,Size s){if(s.isEmpty)return;final c=Offset(s.width*.5,s.height*.52);final r=math.min(s.width,s.height)*.31;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x1D9AB1BA);for(var i=1;i<=5;i++)x.drawCircle(c,r*i/5,p);for(var i=0;i<12;i++){final a=i*math.pi/6;x.drawLine(c,c+Offset(math.cos(a)*r,math.sin(a)*r),p);}x.drawCircle(c,r,Paint()..shader=SweepGradient(startAngle:t*math.pi*2,endAngle:t*math.pi*2+.8,colors:[Colors.transparent,const Color(0x428EAAB5),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r)));x.drawCircle(c,r*.075,Paint()..shader=const RadialGradient(colors:[Color(0xD9E5ECEF),Color(0x4B8199A3),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*.18)));for(var i=0;i<16;i++){final a=i*math.pi*2/16+t*.16;final q=c+Offset(math.cos(a)*r*.7,math.sin(a)*r*.7);x.drawCircle(q,1.1+(i%3)*.45,Paint()..color=const Color(0x5A9CB5BF));}final tp=TextPainter(text:const TextSpan(text:'ATLAS RADAR',style:TextStyle(color:Color(0x4DFFFFFF),fontSize:5.5,letterSpacing:2.5)),textDirection:TextDirection.ltr)..layout();tp.paint(x,c+Offset(-tp.width/2,r+12));if(title!=null&&title!.isNotEmpty){final cp=TextPainter(text:TextSpan(text:title!.toUpperCase(),style:const TextStyle(color:Color(0x66D9E5EA),fontSize:5,letterSpacing:1.8)),textDirection:TextDirection.ltr)..layout(maxWidth:r*1.7);cp.paint(x,c+Offset(-cp.width/2,-r-18));}}
  @override bool shouldRepaint(covariant _RadarPainter o)=>o.t!=t||o.title!=title;
}
