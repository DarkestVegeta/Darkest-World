import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_navigation_session.dart';

class DarkestWorldDetailOrbit extends StatefulWidget {
  const DarkestWorldDetailOrbit({super.key});
  @override State<DarkestWorldDetailOrbit> createState() => _DarkestWorldDetailOrbitState();
}

class _DarkestWorldDetailOrbitState extends State<DarkestWorldDetailOrbit> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 118))..repeat();
  final session = GalaxyNavigationSession.instance;
  @override void initState(){super.initState();session.addListener(_changed);}
  @override void dispose(){session.removeListener(_changed);_clock.dispose();super.dispose();}
  void _changed(){if(mounted)setState((){});}
  @override Widget build(BuildContext context){final nav=session.contentNavigation;if(nav==null)return const SizedBox.shrink();final compact=MediaQuery.sizeOf(context).width<760;return IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>SizedBox.expand(child:CustomPaint(painter:_OrbitPainter(_clock.value,current:nav.current.title,related:nav.related.length,compact:compact)))));}
}

class _OrbitPainter extends CustomPainter{
 final double phase;final String current;final int related;final bool compact;
 const _OrbitPainter(this.phase,{required this.current,required this.related,required this.compact});
 @override void paint(Canvas c,Size s){
  final center=Offset(s.width*.5,s.height*(compact ? .53 : .55));
  final radius=math.min(s.width,s.height)*(compact ? .27 : .32);
  final base=Paint()..style=PaintingStyle.stroke..strokeWidth=.7..color=const Color(0x287F70B0);
  for(var i=0;i<5;i++){final r=radius*(.62+i*.13);c.drawOval(Rect.fromCenter(center:center,width:r*2,height:r*.46),base);}
  final sweep=(phase*math.pi*2)%(math.pi*2);
  c.drawArc(Rect.fromCenter(center:center,width:radius*2.3,height:radius*.58),sweep,.72,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.4..color=const Color(0x708D7DB5));
  final rnd=math.Random(2291);for(var i=0;i<180;i++){final a=rnd.nextDouble()*math.pi*2;final rr=radius*(.58+rnd.nextDouble()*.72);final p=Offset(center.dx+math.cos(a)*rr,center.dy+math.sin(a)*rr*.23);c.drawCircle(p,.3+rnd.nextDouble()*.8,Paint()..color=Colors.white.withValues(alpha:.025+rnd.nextDouble()*.09));}
  c.drawCircle(center,radius*.33,Paint()..shader=const RadialGradient(colors:[Color(0x3C8875B5),Color(0x00000000)]).createShader(Rect.fromCircle(center:center,radius:radius*.33)));
  c.drawCircle(center,radius*.22,Paint()..shader=const RadialGradient(colors:[Color(0xFF181322),Color(0xFF07070D)]).createShader(Rect.fromCircle(center:center,radius:radius*.22)));
  final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x6E9A8BC0);c.drawCircle(center,radius*.22,p);
  final title=current.length>30?'${current.substring(0,30)}…':current;
  _label(c,Offset(center.dx,center.dy+radius*.31),'CURRENT / ${title.toUpperCase()}');
  _label(c,Offset(24,s.height-70),'DETAIL ORBIT  /  RELATED ${related.toString().padLeft(2,'0')}  /  SIGNAL LOCK');
  final scan=(phase*s.height*1.15)%(s.height+120)-60;c.drawRect(Rect.fromLTWH(0,scan,s.width,1),Paint()..color=const Color(0x0F8E7BC0));
 }
 void _label(Canvas c,Offset p,String text){final tp=TextPainter(text:TextSpan(text:text,style:const TextStyle(fontSize:6,letterSpacing:1.7,color:Color(0x558F82A9))),textDirection:TextDirection.ltr)..layout();tp.paint(c,Offset(p.dx-tp.width*.5,p.dy));}
 @override bool shouldRepaint(covariant _OrbitPainter old)=>old.phase!=phase||old.current!=current||old.related!=related||old.compact!=compact;
}
