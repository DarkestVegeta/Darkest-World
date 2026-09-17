import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld { final GalaxyWorldKind kind; final String title; final String description; const GalaxyWorld({required this.kind,required this.title,required this.description}); }

/// Game-only visual core. CreateWorld references define the visual language;
/// the island composition is a strong structural guide, never a literal copy.
class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds; final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key,required this.worlds,this.onWorldTap});
  @override State<DarkestWorldUniverse> createState()=>_DarkestWorldUniverseState();
}
class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock=AnimationController(vsync:this,duration:const Duration(seconds:32))..repeat();
  bool worldOpen=false;
  GalaxyWorld get gameWorld=>widget.worlds.firstWhere((w)=>w.kind==GalaxyWorldKind.game,orElse:()=>const GalaxyWorld(kind:GalaxyWorldKind.game,title:'Game World',description:'The Game World'));
  @override void dispose(){clock.dispose();super.dispose();}
  void enterWorld(){setState(()=>worldOpen=true);GalaxyNavigationSession.instance.selected=GalaxyWorldKind.game.name;widget.onWorldTap?.call(gameWorld);}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF02040A),body:Stack(fit:StackFit.expand,children:[CustomPaint(painter:_DeepSpacePainter(clock)),AnimatedSwitcher(duration:const Duration(milliseconds:750),switchInCurve:Curves.easeOutCubic,switchOutCurve:Curves.easeInCubic,child:worldOpen?_GameWorldView(key:const ValueKey('game-world'),clock:clock):_GamePlanetView(key:const ValueKey('game-planet'),clock:clock,onEnter:enterWorld)),if(worldOpen)Positioned(top:28,left:28,child:_BackButton(onTap:()=>setState(()=>worldOpen=false)))]));
}

class _GamePlanetView extends StatelessWidget { final Animation<double> clock; final VoidCallback onEnter; const _GamePlanetView({super.key,required this.clock,required this.onEnter});
  @override Widget build(BuildContext context)=>Center(child:LayoutBuilder(builder:(context,box){final size=math.min(box.maxWidth,box.maxHeight)*.55;return GestureDetector(onTap:onEnter,child:SizedBox(width:size,height:size,child:Stack(alignment:Alignment.center,children:[CustomPaint(size:Size.square(size),painter:_PlanetAtmosphere(clock)),CustomPaint(size:Size.square(size),painter:_GamePlanetPainter(clock)),Positioned(bottom:size*.08,child:Text('GAME',style:TextStyle(color:Colors.white.withValues(alpha:.86),fontSize:math.max(13,size*.035),letterSpacing:math.max(4,size*.012),fontWeight:FontWeight.w500)))])));}));
}

class _GameWorldView extends StatelessWidget { final Animation<double> clock; const _GameWorldView({super.key,required this.clock});
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,box)=>Center(child:SizedBox(width:box.maxWidth*.94,height:box.maxHeight*.86,child:CustomPaint(painter:_IslandGameWorldPainter(clock)))));
}
class _BackButton extends StatelessWidget { final VoidCallback onTap; const _BackButton({required this.onTap}); @override Widget build(BuildContext context)=>GestureDetector(onTap:onTap,child:Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:const Color(0x66101722),border:Border.all(color:const Color(0x335C6F87)),borderRadius:BorderRadius.circular(20)),child:Text('GAME PLANET',style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:11,letterSpacing:1.8)))); }

class _DeepSpacePainter extends CustomPainter { final Animation<double> clock; _DeepSpacePainter(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final r=Offset.zero&size;canvas.drawRect(r,Paint()..shader=const RadialGradient(center:Alignment(0,-.12),radius:1.1,colors:[Color(0xFF111A2B),Color(0xFF070B15),Color(0xFF020309)]).createShader(r));final star=Paint();final random=math.Random(9127);for(var i=0;i<150;i++){final x=random.nextDouble()*size.width,y=random.nextDouble()*size.height;star.color=Colors.white.withValues(alpha:.10+.07*math.sin(clock.value*math.pi*2+i));canvas.drawCircle(Offset(x,y),.35+random.nextDouble()*.55,star);}}
  @override bool shouldRepaint(covariant _DeepSpacePainter oldDelegate)=>false;
}

class _PlanetAtmosphere extends CustomPainter { final Animation<double> clock; _PlanetAtmosphere(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.315;canvas.drawCircle(c,r*1.30,Paint()..shader=RadialGradient(colors:[const Color(0x443F6DAA),const Color(0x18283F72),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*1.30)));final rim=Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..shader=const SweepGradient(colors:[Color(0x008EA8E2),Color(0x997B8FD0),Color(0x005B6B9D)]).createShader(Rect.fromCircle(center:c,radius:r*1.04));canvas.drawCircle(c,r*1.04,rim);}
  @override bool shouldRepaint(covariant _PlanetAtmosphere oldDelegate)=>true;
}

class _GamePlanetPainter extends CustomPainter { final Animation<double> clock; _GamePlanetPainter(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.315;canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(center:Alignment(-.45,-.48),radius:.86,colors:[Color(0xFF75839B),Color(0xFF414E68),Color(0xFF1B263A),Color(0xFF050911)],stops:[0,.34,.70,1]).createShader(Rect.fromCircle(center:c,radius:r)));
    final rng=math.Random(4207);final land=Paint();for(var i=0;i<22;i++){final a=rng.nextDouble()*math.pi*2;final rr=math.sqrt(rng.nextDouble())*r*.76;final p=Offset(c.dx+math.cos(a)*rr,c.dy+math.sin(a)*rr*.70);final rw=5+rng.nextDouble()*20;land.color=Color.lerp(const Color(0xFF7F8790),const Color(0xFF202A3A),rng.nextDouble())!.withValues(alpha:.18+rng.nextDouble()*.18);canvas.drawOval(Rect.fromCenter(center:p,width:rw,height:rw*.5),land);}
    canvas.drawCircle(c,r,Paint()..shader=RadialGradient(center:const Alignment(.62,.55),colors:[const Color(0xAA000000),const Color(0x22000000),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r)));canvas.drawCircle(c,r,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x6694A7C4));}
  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>true;
}

class _IslandGameWorldPainter extends CustomPainter { final Animation<double> clock; _IslandGameWorldPainter(this.clock):super(repaint:clock);
  Path island(Size s,List<Offset> pts){final p=Path()..moveTo(pts.first.dx*s.width,pts.first.dy*s.height);for(var i=1;i<pts.length;i++)p.lineTo(pts[i].dx*s.width,pts[i].dy*s.height);return p..close();}
  void drawIsland(Canvas c,Size s,List<Offset> pts,Color base,double scale){final path=island(s,pts),b=path.getBounds();c.drawPath(path.shift(Offset(0,10*scale)),Paint()..color=const Color(0x88000000));c.drawPath(path,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[base.withValues(alpha:.98),base.withValues(alpha:.82),const Color(0xFF151D29)]).createShader(b));c.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2*scale..color=const Color(0x66758CA4));}
  void terrain(Canvas c,Size s,Rect area,int seed){final rng=math.Random(seed);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x365F7389);for(var i=0;i<9;i++){final cx=area.left+area.width*(.15+rng.nextDouble()*.7),cy=area.top+area.height*(.18+rng.nextDouble()*.64),rx=area.width*(.04+rng.nextDouble()*.12),ry=area.height*(.03+rng.nextDouble()*.10);c.drawOval(Rect.fromCenter(center:Offset(cx,cy),width:rx*2,height:ry*2),p);}}
  @override void paint(Canvas canvas,Size s){
    // Deep water gives the islands the same spacious, floating-world reading as the reference.
    canvas.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(center:Alignment(.1,-.15),radius:1.0,colors:[Color(0xFF16253A),Color(0xFF0A1424),Color(0xFF030812)]).createShader(Offset.zero&s)));
    final water=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x182F6086);for(var i=0;i<7;i++){final rr=Rect.fromCenter(center:Offset(s.width*.52,s.height*.49),width:s.width*(.30+i*.10),height:s.height*(.20+i*.065));canvas.drawOval(rr,water);}
    final main=[const Offset(.18,.40),const Offset(.23,.29),const Offset(.37,.21),const Offset(.53,.23),const Offset(.65,.34),const Offset(.67,.49),const Offset(.58,.63),const Offset(.43,.71),const Offset(.27,.65),const Offset(.19,.54)];
    drawIsland(canvas,s,main,const Color(0xFF596A68),1.0);drawIsland(canvas,s,[const Offset(.67,.17),const Offset(.78,.12),const Offset(.89,.18),const Offset(.86,.30),const Offset(.74,.33)],const Color(0xFF465963),.74);drawIsland(canvas,s,[const Offset(.06,.24),const Offset(.15,.16),const Offset(.25,.20),const Offset(.26,.31),const Offset(.13,.36)],const Color(0xFF4C5C61),.72);drawIsland(canvas,s,[const Offset(.70,.64),const Offset(.82,.59),const Offset(.92,.66),const Offset(.87,.79),const Offset(.74,.78)],const Color(0xFF40515B),.70);drawIsland(canvas,s,[const Offset(.18,.74),const Offset(.29,.73),const Offset(.36,.82),const Offset(.29,.91),const Offset(.16,.85)],const Color(0xFF3D4D57),.66);
    terrain(canvas,s,Rect.fromLTWH(s.width*.20,s.height*.24,s.width*.45,s.height*.43),7301);terrain(canvas,s,Rect.fromLTWH(s.width*.67,s.height*.15,s.width*.24,s.height*.18),7302);terrain(canvas,s,Rect.fromLTWH(s.width*.69,s.height*.60,s.width*.23,s.height*.20),7303);
    final route=Paint()..style=PaintingStyle.stroke..strokeWidth=1.6..color=const Color(0x4A8295A8);final path=Path()..moveTo(s.width*.31,s.height*.56)..quadraticBezierTo(s.width*.42,s.height*.47,s.width*.52,s.height*.52)..quadraticBezierTo(s.width*.57,s.height*.46,s.width*.61,s.height*.37);canvas.drawPath(path,route);
    final nodes=[const Offset(.33,.45),const Offset(.48,.51),const Offset(.59,.36),const Offset(.77,.23),const Offset(.17,.27),const Offset(.79,.69)];final node=Paint()..color=const Color(0x9A9BAFC5);for(var i=0;i<nodes.length;i++){final q=Offset(nodes[i].dx*s.width,nodes[i].dy*s.height);final pulse=.8+.25*math.sin(clock.value*math.pi*2+i);canvas.drawCircle(q,2.5*pulse,node);}
    final title=TextPainter(text:TextSpan(text:'GAME WORLD',style:TextStyle(color:Colors.white.withValues(alpha:.80),fontSize:math.max(13,s.width*.018),letterSpacing:4.2,fontWeight:FontWeight.w500)),textDirection:TextDirection.ltr)..layout();title.paint(canvas,Offset((s.width-title.width)/2,s.height*.94));
  }
  @override bool shouldRepaint(covariant _IslandGameWorldPainter oldDelegate)=>true;
}
